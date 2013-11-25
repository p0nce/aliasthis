module aliasthis.statemachine;

import std.random,
       std.typecons;

import gfm.sdl2.all,
       gfm.math.all;

import aliasthis.utils,
       aliasthis.console,
       aliasthis.lang,
       aliasthis.states;

immutable int POLL_DELAY = 35;

// Convert input into tractable state transitions.
// Hold the last, current state and the display.
class StateMachine
{
public:
    this(SDL2 sdl2, string gameDir, Console console)
    {
        _sdl2 = sdl2;
        _console = console;    
        _state = new StateMainMenu(console, new LangFrench);
        _frameCounter = new FrameCounter(sdl2);
    }

    ~this()
    {
        if (_state !is null)
        {
            _state.close();
            _state = null;
        }
    }

    void mainLoop()
    {
        bool finished = false;        

        while(true)
        {
            // user clicked close, application was terminated, etc...
            if (_console.isClosed())
                finished = true;

            if (finished)
                break;

            // handle all pending events
            {
                SDL_Event event;
                while (_sdl2.pollEvent(&event))
                {
                    State newState = _state;
                    switch (event.type)
                    {
                        case SDL_KEYDOWN:
                        {
                            auto key = event.key.keysym;
                            if (key.sym == SDLK_RETURN && ((key.mod & KMOD_ALT) != 0))
                                _console.toggleFullscreen();
                            else
                                newState = _state.handleKeypress(key);   
                            break;
                        }

                        default:
                            break;
                    }

                    {
                        if (newState is null)
                            finished = true;
                        else
                        {
                            if (newState != _state)
                            {
                                if (_state !is null)
                                    _state.close();
                                _state = newState;
                            }
                        }
                    }
                }

            }

            // clear the console
            _console.setForegroundColor(rgba(0, 0, 0, 255));
            _console.setBackgroundColor(rgba(7, 7, 12, 255));
            _console.clear();

            // draw current state
            ulong deltaMs = _frameCounter.tickMs();
            double dt = deltaMs / 1000.0;
            _state.draw(dt);

            _console.flush();
        }
    }

private:

    SDL2 _sdl2;
    Console _console;
    State _state;
    FrameCounter _frameCounter;
}

