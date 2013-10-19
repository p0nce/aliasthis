module aliasthis.console;

import std.typecons,
       std.path;

import gfm.core.all,
       gfm.sdl2.all,
       gfm.math.all;


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

            SDL_SetHint("SDL_HINT_RENDER_DRIVER", "software");

            _width = width;
            _height = height;
            _sdl2 = sdl2;
            _sdlImage = new SDLImage(_sdl2, IMG_INIT_PNG);

            _glyphs.length = _width * _height;

            SDL_DisableScreenSaver();

            // TODO: choose the right display
            vec2i screenRes = _sdl2.firstDisplaySize();

            // get resolution
            _window = new Window(_sdl2, screenRes.x, screenRes.y);

            selectBestFontForDimension(gameDir, screenRes, width, height);

         //   _window.setFullscreen(true);
            _window.show();

            // create an event queue and register that window
            _eventQueue = new SDL2EventQueue(_sdl2);
            _eventQueue.registerWindow(_window);

            _renderer = new SDL2Renderer(_window, SDL_RENDERER_SOFTWARE);

            _fontTexture = new SDL2Texture(_renderer, _font);
        }

        ~this()
        {
            _fontTexture.close();
            _renderer.close();
            _font.close();
            _window.close();
            _sdlImage.close();
        }

        SDL2EventQueue eventQueue()
        {
            return _eventQueue;
        }

        bool isClosed()
        {
            return _eventQueue.wasQuitResquested();
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
                    box2i destRect = box2i(i * _fontWidth, j * _fontHeight, (i + 1) * _fontWidth, (j + 1) * _fontHeight);

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
        SDL2EventQueue _eventQueue;
        SDL2Surface _font;
        SDL2Renderer _renderer;
        SDL2Texture _fontTexture;
        int _width;
        int _height;
        Glyph[] _glyphs;

        // currentl colors
        vec3ub _foregroundColor;
        vec3ub _backgroundColor;

        int _fontWidth;
        int _fontHeight;

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
            string fontFile = buildNormalizedPath(gameDir, format("data/fonts/consola_%sx%s.png", _fontWidth, _fontHeight));
            _font = _sdlImage.load(fontFile);
        }
    }
}

class Window : SDL2Window
{
    public
    {
        this(SDL2 sdl2, int width, int height)
        {
            super(sdl2, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                  width, height, 0);
            _closed = false;
            
        }

        override void onResized(int width, int height)
        {
            super.onResized(width, height);
        }

        override void onClose()
        {
            _closed = true;
        }
    }

    private
    {     
        bool _closed;
    }
    
}
