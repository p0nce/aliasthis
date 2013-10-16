module aliasthis.console;

import std.typecons;

import gfm.core.all,
       gfm.sdl2.all,
       gfm.math.all;


class Console
{
    public
    {
        this(Log log)
        {
            _sdl2 = new SDL2(log);

            SDL_DisableScreenSaver();

            // TODO: choose the right display
            vec2i screenRes = _sdl2.firstDisplaySize();

            // get resolution
            _window = new Window(_sdl2, screenRes.x, screenRes.y);
        }

        ~this()
        {
            delete _window;
            delete _sdl2;
        }
    }

    private
    {        
        SDL2 _sdl2;
        Window _window;
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

            // create an event queue and register that window
            _eventQueue = new SDL2EventQueue(sdl2);
            _eventQueue.registerWindow(this);
        }

        ~this()
        {
            delete _eventQueue;
        }
    }

    private
    {
        SDL2EventQueue _eventQueue;
    }
    
}