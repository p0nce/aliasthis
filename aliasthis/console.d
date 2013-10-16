module aliasthis.console;

import std.typecons,
       std.path;

import gfm.core.all,
       gfm.sdl2.all,
       gfm.math.all;


struct Glyph
{
    ubyte index;
    vec3ub foregroundColor;
    vec3ub backgroundColor;
}

class Console
{
    public
    {
        this(SDL2 sdl2, Log log, string gameDir, int width, int height)
        {
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

            _window.setFullscreen(true);
            _window.show();
            

            // create an event queue and register that window
            _eventQueue = new SDL2EventQueue(_sdl2);
            _eventQueue.registerWindow(_window);
        }

        ~this()
        {
            delete _font;
            delete _eventQueue;
            delete _window;
            delete _sdlImage;
        }

        SDL2EventQueue eventQueue()
        {
            return _eventQueue;
        }

        bool isClosed()
        {
            return _eventQueue.wasQuitResquested();
            //return _window.isClosed();
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
                g.index = 0;
                g.foregroundColor = _foregroundColor;
                g.backgroundColor = _backgroundColor;
            }
        }

        void putChar(int cx, int cy, int index)
        {
            if (cx < 0 || cx >= _width || cy < 0 || cy >= _height)
                return;

            glyph(cx, cy).index = cast(ubyte)index;
            glyph(cx, cy).foregroundColor = _foregroundColor;
            glyph(cx, cy).backgroundColor = _backgroundColor;
        }

        void flush()
        {            
            // TODO draw things

            
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
        int _width;
        int _height;
        Glyph[] _glyphs;

        // currentl colors
        vec3ub _foregroundColor;
        vec3ub _backgroundColor;

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

            int fontWidth = fontDim[bestFont][0];
            int fontHeight = fontDim[bestFont][1];

            // initialize custom font
            string fontFile = buildNormalizedPath(gameDir, format("data/fonts/consola_%sx%s.png", fontWidth, fontHeight));
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
