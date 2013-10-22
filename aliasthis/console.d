module aliasthis.console;

import std.typecons,
       std.path;

import gfm.core.all,
       gfm.sdl2.all,
       gfm.math.all;

import aliasthis.chartable;
public import aliasthis.utils;

struct Glyph
{
    ubyte fontIndex;
    vec3ub foregroundColor;
    vec3ub backgroundColor;
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
            vec2i initialWindowSize = vec2i(800,600);//_sdl2.firstDisplaySize();

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
            _foregroundColor = fg;
        }

        void setBackgroundColor(vec3ub bg)
        {
            _backgroundColor = bg;
        }

        void clear()
        {
            foreach (ref g ; _glyphs)
            {
                g.fontIndex = 0;
                g.foregroundColor = _foregroundColor;
                g.backgroundColor = _backgroundColor;
            }
        }

        void putChar(int cx, int cy, int fontIndex)
        {
            if (cx < 0 || cx >= _width || cy < 0 || cy >= _height)
                return;

            glyph(cx, cy).fontIndex = cast(ubyte)fontIndex;
            glyph(cx, cy).foregroundColor = _foregroundColor;
            glyph(cx, cy).backgroundColor = _backgroundColor;
        }

        void putText(int cx, int cy, string text)
        {
            foreach (dchar ch, int i; text)
                putChar(cx + i, cy, character(ch));
        }

        void flush()
        {     
            _renderer.setColor(0, 0, 0, 255);
            _renderer.clear();

            _fontTexture.setBlendMode(SDL_BLENDMODE_BLEND);
            _fontTexture.setAlphaMod(255);

            for (int j = 0; j < _height; ++j)
                for (int i = 0; i < _width; ++i)
                {
                    Glyph g = glyph(i, j);
                    box2i fontRect = glyphRect(g.fontIndex);
                    int destX = _consoleOffsetX + i * _fontWidth;
                    int destY = _consoleOffsetY + j * _fontHeight;
                    box2i destRect = box2i(destX, destY, destX + _fontWidth, destY + _fontHeight);

                    _renderer.setColor(g.backgroundColor.x, g.backgroundColor.y, g.backgroundColor.z, 255);
                    _renderer.fillRect(destRect);
                    
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

        // currentl colors
        vec3ub _foregroundColor;
        vec3ub _backgroundColor;

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
