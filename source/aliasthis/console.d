module aliasthis.console;

import std.typecons,
       std.path,
       std.string;

import std.experimental.logger;

import gfm.sdl2,
       gfm.math;

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

enum DEFORM_GLYPHS_TO_FIT = true;

class Console
{
    public
    {
        this(SDL2 sdl2, Logger logger, string gameDir, int width, int height)
        {
            _fontTexture = null;
            _font = null;
            SDL_SetHint("SDL_HINT_RENDER_DRIVER", "software");

            _gameDir = gameDir;
            _width = width;
            _height = height;
            _sdl2 = sdl2;

            _glyphs.length = _width * _height;

            SDL_DisableScreenSaver();

            // hide mouse cursor
            SDL_ShowCursor(SDL_DISABLE);

            // TODO: choose the right display
            vec2i initialWindowSize = vec2i(1366, 768);

            // get resolution
            _window = new Window(_sdl2, this, initialWindowSize.x, initialWindowSize.y);
            _window.setTitle("Aliasthis v0.1");

            // start fullscreen in release mode
            debug{} else
            {
                toggleFullscreen();
            }

            _renderer = new SDL2Renderer(_window, SDL_RENDERER_SOFTWARE);
            updateFont();
        }

        ~this()
        {
            _fontTexture.close();
            _renderer.close();
            _font.close();
            _window.close();
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
            vec2i windowSize = vec2i(_window.getSize().x, _window.getSize().y);
            selectBestFontForDimension(_gameDir, windowSize, _width, _height);
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
            setFullscreen(_isFullscreen);
            updateFont();
        }

        bool isClosed()
        {
            return _sdl2.wasQuitRequested();
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
            int i = 0;
            foreach (dchar ch; text)
            {
                putChar(cx + i, cy, character(ch));
                i += 1;
            }
        }

        // format text into a rectangle
        void putFormattedText(int cx, int cy, int width, int height, string text)
        {
            int x = 0;
            int y = 0;
            dchar[] fifo;

            void flush()
            {
                foreach (dchar ch; fifo)
                {
                    if (ch != '\n')
                    {
                        // crop
                        if (cx < width && cy < height)
                            putChar(cx + x, cy + y, character(ch)); // draw char
                        x++;
                    }
                }
                fifo.length = 0;
            }

            foreach (int i, dchar ch; text)
            {
                if (ch == ' ')
                {
                    if (x + fifo.length < width)
                    {
                        flush();
                        fifo ~= ch;
                    }
                    else
                    {
                        x = 0;
                        y += 1;
                        if (fifo.length > 0 && fifo[0] == ' ')
                            fifo = fifo[1..$];
                        flush();
                        fifo ~= ch;
                    }
                }
                else if (ch == '\n')
                {
                    if (x + fifo.length < width)
                        flush();
                    x = 0;
                    y += 1;
                    flush();
                }
                else
                {
                    fifo ~= ch;
                }
            }
            flush();
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
                    SDL2Surface.RGBA rgba = surface.getRGBA(x, y);
                    vec4ub color = vec4ub(rgba.r, rgba.g, rgba.b, rgba.a);
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
            import gfm.image.stb_image;
            import std.file;

            string fullPath = buildNormalizedPath(_gameDir, relPath);
            void[] data = std.file.read(fullPath);
            int width, height, components;
            ubyte* decoded = stbi_load_from_memory(data, width, height, components, 4);
            scope(exit) stbi_image_free(decoded);

            // stb_image guarantees that ouput will always have 4 components when asked
            SDL2Surface loaded = new SDL2Surface(_sdl2, decoded, width, height, 32, 4 * width,
                                                 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);

            SDL2Surface cloned = loaded.clone(); // to gain pixel ownership
            loaded.close(); // scoped! strangely didn't worked out
            return cloned;
        }

        void flush()
        {     
            _renderer.setViewportFull();
            _renderer.setColor(0, 0, 0, 255);
            _renderer.clear();

            _fontTexture.setBlendMode(SDL_BLENDMODE_BLEND);
            _fontTexture.setAlphaMod(254); // Work-around: 255 yield nothing, strange!

            for (int j = 0; j < _height; ++j)
            {
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

                    int destX0 = _consoleOffsetX + i * _glyphWidth;
                    int destX1 = _consoleOffsetX + k * _glyphWidth;
                    int destY = _consoleOffsetY + j * _glyphHeight;
                    box2i destRect = box2i(destX0, destY, destX1 + _glyphWidth, destY + _glyphHeight);

                    i = k;

                    _renderer.setColor(g.backgroundColor.x, g.backgroundColor.y, g.backgroundColor.z, 255);
                    _renderer.fillRect(destRect.min.x, destRect.min.y, destRect.width, destRect.height);
                }
            }

            int spacex = _glyphWidth - _fontWidth;
            int spacey = _glyphHeight - _fontHeight;
            assert(0 <= spacex && spacex <= 2);
            assert(0 <= spacey && spacey <= 2);

            // draw glyphs
            for (int j = 0; j < _height; ++j)
                for (int i = 0; i < _width; ++i)
                {
                    Glyph g = glyph(i, j);
                    int destX = _consoleOffsetX + i * _glyphWidth;
                    int destY = _consoleOffsetY + j * _glyphHeight;
                    if (spacex == 2) 
                        destX += 1;
                    if (spacey == 2) 
                        destY += 1;

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
                    _renderer.copy(_fontTexture, fontRect.toSDLRect, destRect.toSDLRect);
                }

               
            
            _renderer.present();
        }

        final void setFullscreen(bool activated)
        {
            _window.setFullscreenSetting(activated ? SDL_WINDOW_FULLSCREEN : 0);
        }
    }

    private
    {        
        SDL2 _sdl2;
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

        int _glyphWidth;
        int _glyphHeight; // The glyph can be slightly larger than a font glyph

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

            // extend glyph size by up-to 2 pixels in each direction to better match the screen.
            _glyphWidth = _fontWidth;
            _glyphHeight = _fontHeight;

            if (DEFORM_GLYPHS_TO_FIT)
            {
                for (int s = 0; s < 2; ++s)
                {
                    if (consoleWidth * (_glyphWidth + 1) <= desktopWidth)
                        _glyphWidth++;
                    if (consoleHeight * (_glyphHeight + 1) <= desktopHeight)
                        _glyphHeight++;
                }
            }

            // initialize custom font
            string fontPath = format("data/fonts/consola_%sx%s.png", _fontWidth, _fontHeight);
            if (_font !is null)
                _font.close();
            _font = loadImage(fontPath);
            assert(_font.width == _fontWidth * 16);
            assert(_font.height == _fontHeight * 16);

            _consoleOffsetX = (desktopWidth - _glyphWidth * consoleWidth) / 2;
            _consoleOffsetY = (desktopHeight - _glyphHeight * consoleHeight) / 2;
        }
    }
}

final class Window
{
    public
    {
        this(SDL2 sdl2, Console console, int width, int height)
        {
            _window = new SDL2Window(sdl2, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                  width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_MOUSE_FOCUS);
            _console = console;
        }

        alias _window this;
    }

    private
    {
        SDL2Window _window;
        Console _console;
    }
    
}

 SDL_Rect toSDLRect(box2i b)
{
    SDL_Rect r;
    r.x = b.min.x;
    r.y = b.min.y;
    r.w = b.width;
    r.h = b.height;
    return r;
}