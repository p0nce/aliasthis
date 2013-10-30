module aliasthis.console;

import std.typecons,
       std.path;

import gfm.core.all,
       gfm.sdl2.all,
       gfm.math.all;

public import aliasthis.chartable,
              aliasthis.utils;

struct Glyph
{
    ubyte fontIndex;
    vec4ub foregroundColor;
    vec3ub backgroundColor;
}

enum 
{
    BG_OP_SET = 0,
    BG_OP_KEEP = 1
}

class Console
{
    public
    {
        this(SDL2 sdl2, Log log, string gameDir, int width, int height)
        {
            _fontTexture = null;
            _font = null;
            SDL_SetHint("SDL_HINT_RENDER_DRIVER", "software");

            _gameDir = gameDir;
            _width = width;
            _height = height;
            _sdl2 = sdl2;
            _sdlImage = new SDLImage(_sdl2, IMG_INIT_PNG);

            _glyphs.length = _width * _height;

            SDL_DisableScreenSaver();

            // TODO: choose the right display
            vec2i initialWindowSize = vec2i(1366, 768);

            // get resolution
            _window = new Window(_sdl2, this, initialWindowSize.x, initialWindowSize.y);
            _window.setTitle("Aliasthis v0.1");

            _renderer = new SDL2Renderer(_window, SDL_RENDERER_SOFTWARE);
            updateFont();
        }

        ~this()
        {
            _fontTexture.close();
            _renderer.close();
            _font.close();
            _window.close();
            _sdlImage.close();
        }

        @property width()
        {
            return _width;
        }

        @property height()
        {
            return _height;
        }

        void updateFont()
        {
            selectBestFontForDimension(_gameDir, _window.getSize(), _width, _height);
            if (_fontTexture !is null)
                _fontTexture.close();

            _fontTexture = new SDL2Texture(_renderer, _font);
        }

        void toggleFullscreen()
        {
             _isFullscreen = !_isFullscreen;
            if (_isFullscreen)
            {
                _window.maximize();
            }
            _window.setFullscreen(_isFullscreen);
            updateFont();
        }

        bool isClosed()
        {
            return _sdl2.wasQuitResquested();
        }

        ref glyph(int x, int y)
        {
            return _glyphs[x + y * _width];
        }

        void setForegroundColor(vec3ub fg)
        {
            ubyte alpha = 255;
            setForegroundColor(vec4ub(fg.x, fg.y, fg.z, alpha));
        }

        void setForegroundColor(vec4ub fg)
        {
            _foregroundColor = fg;
        }

        void setBackgroundColor(vec4ub bg)
        {
            _backgroundColor = bg;
        }

        void clear()
        {
            foreach (ref g ; _glyphs)
            {
                g.fontIndex = 0;
                g.foregroundColor = _foregroundColor;
                g.backgroundColor = _backgroundColor.xyz;
            }
        }

        void putChar(int cx, int cy, int fontIndex)
        {
            if (cx < 0 || cx >= _width || cy < 0 || cy >= _height)
                return;

            Glyph* g = &glyph(cx, cy);

            g.fontIndex = cast(ubyte)fontIndex;
            g.foregroundColor = _foregroundColor; // do not consider alpha, will be composited at render time

            if (_backgroundColor.w != 0)
                g.backgroundColor = lerpColor(g.backgroundColor, _backgroundColor.xyz, _backgroundColor.w / 255.0f);            
        }

        void putText(int cx, int cy, string text)
        {
            foreach (int i, dchar ch; text)
                putChar(cx + i, cy, character(ch));
        }

        void putImage(int cx, int cy, SDL2Surface surface, void delegate(int x, int y, out int charIndex, out vec4ub fgColor) getCharStyle)
        {
            surface.lock();
            scope(exit) surface.unlock();

            int w = surface.width();
            int h = surface.height();

            for(int y = 0; y < h; ++y)
            {
                for(int x = 0; x < w; ++x)
                {
                    vec4ub color = surface.getRGBA(x, y);
                    Glyph* g = &glyph(x + cx, y + cy);

                    int charIndex;
                    vec4ub fg;
                    getCharStyle(x, y, charIndex, fg);
                    g.backgroundColor = color.xyz;
                    g.foregroundColor = fg;
                    g.fontIndex = cast(ubyte)charIndex;
                }
            }
        }

        SDL2Surface loadImage(string relPath)
        {
            string fullPath = buildNormalizedPath(_gameDir, relPath);
            return _sdlImage.load(fullPath);
        }

        void flush()
        {     
            _renderer.setViewportFull();
            _renderer.setColor(0, 0, 0, 255);
            _renderer.clear();

            _fontTexture.setBlendMode(SDL_BLENDMODE_BLEND);
            _fontTexture.setAlphaMod(254); // Work-around: 255 yield nothing, strange!

            for (int j = 0; j < _height; ++j)
                for (int i = 0; i < _width; ++i)
                {
                    Glyph g = glyph(i, j);
                    vec3ub bg = g.backgroundColor;

                    int k = i;
                    while (true)
                    {
                        if (k + 1 >= _width)
                            break;
                        Glyph gNext = glyph(k + 1, j);
                        if (bg != gNext.backgroundColor)
                            break;
                        k += 1;
                    }

                    int destX0 = _consoleOffsetX + i * _fontWidth;
                    int destX1 = _consoleOffsetX + k * _fontWidth;
                    int destY = _consoleOffsetY + j * _fontHeight;
                    box2i destRect = box2i(destX0, destY, destX1 + _fontWidth, destY + _fontHeight);

                    i = k;

                    _renderer.setColor(g.backgroundColor.x, g.backgroundColor.y, g.backgroundColor.z, 255);
                    _renderer.fillRect(destRect);
                }

            // draw glyphs
            for (int j = 0; j < _height; ++j)
                for (int i = 0; i < _width; ++i)
                {
                    Glyph g = glyph(i, j);
                    int destX = _consoleOffsetX + i * _fontWidth;
                    int destY = _consoleOffsetY + j * _fontHeight;
                    box2i destRect = box2i(destX, destY, destX + _fontWidth, destY + _fontHeight);
                    
                    // optimization: skip index 0 (space)
                    if (g.fontIndex == 0)
                        continue;

                    ubyte alpha = g.foregroundColor.w;
                    if (alpha == 255)
                        alpha = 254;
                    _fontTexture.setAlphaMod(alpha);
                    box2i fontRect = glyphRect(g.fontIndex);
                    _fontTexture.setColorMod(g.foregroundColor.x, g.foregroundColor.y, g.foregroundColor.z);
                    _renderer.copy(_fontTexture, fontRect, destRect);
                }
            
            _renderer.present();
        }

        final void setFullscreen(bool activated)
        {
            _window.setFullscreen(activated);
        }
    }

    private
    {        
        SDL2 _sdl2;
        SDLImage _sdlImage;
        Window _window;
        SDL2Surface _font;
        SDL2Renderer _renderer;
        SDL2Texture _fontTexture;
        int _width;
        int _height;
        Glyph[] _glyphs;
        bool _isFullscreen;
        string _gameDir;

        // current colors
        vec4ub _foregroundColor;
        vec4ub _backgroundColor;

        int _fontWidth;
        int _fontHeight;
        int _consoleOffsetX;
        int _consoleOffsetY;

        box2i glyphRect(int fontIndex)
        {
            int ix = (fontIndex & 15);
            int iy = (fontIndex / 16);
            box2i rectFont = box2i(ix * _fontWidth, iy * _fontHeight, (ix + 1) * _fontWidth, (iy + 1) * _fontHeight);
            return rectFont;
        }

        void selectBestFontForDimension(string gameDir, vec2i screenRes, int consoleWidth, int consoleHeight)
        {
            // find biggest font that can fit
            int[2][7] fontDim = 
            [
                [9, 14], [11, 17], [13, 20], [15, 24], [17, 27], [19, 30], [21, 33]
            ];

            int desktopWidth = screenRes.x;
            int desktopHeight = screenRes.y;

            int bestFont = 0;

            while (bestFont < 6
                   && fontDim[bestFont+1][0] * consoleWidth < desktopWidth 
                   && fontDim[bestFont+1][1] * consoleHeight < desktopHeight)
                bestFont++;

            _fontWidth = fontDim[bestFont][0];
            _fontHeight = fontDim[bestFont][1];

            // initialize custom font
            string fontPath = format("data/fonts/consola_%sx%s.png", _fontWidth, _fontHeight);
            fontPath = buildNormalizedPath(gameDir, fontPath);
            if (_font !is null)
                _font.close();
            _font = _sdlImage.load(fontPath);
            assert(_font.width == _fontWidth * 16);
            assert(_font.height == _fontHeight * 16);

            _consoleOffsetX = (desktopWidth - _fontWidth * consoleWidth) / 2;
            _consoleOffsetY = (desktopHeight - _fontHeight * consoleHeight) / 2;
        }
    }
}

class Window : SDL2Window
{
    public
    {
        this(SDL2 sdl2, Console console, int width, int height)
        {
            super(sdl2, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                  width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_MOUSE_FOCUS);
            _closed = false;
            _console = console;
        }

        override void onResized(int width, int height)
        {
            _console.updateFont();
            super.onResized(width, height);
        }

        override void onClose()
        {
            _closed = true;
        }
    }

    private
    {     
        Console _console;
        bool _closed;
    }
    
}
