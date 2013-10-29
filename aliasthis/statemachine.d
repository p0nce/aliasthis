module aliasthis.statemachine;

import std.random,
       std.typecons;

import gfm.sdl2.all,
       gfm.math.all;

import aliasthis.utils,
       aliasthis.console,
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
        _state = new StateMainMenu(console);
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
            uint timeBeforeInput = _sdl2.getTicks();

            // user clicked close, application was terminated, etc...
            if (_console.isClosed())
                finished = true;

            // terminal state
            if (cast(StateExit)_state !is null)
                finished = true;            

            if (finished)
                break;

            // handle all pending events
            {
                SDL_Event event;
                while (_sdl2.pollEvent(&event))
                {
                    State newState = null;
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

                    if (newState !is null)
                    {
                        if (cast(StateExit)newState !is null)
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
            _console.setBackgroundColor(rgba(0, 0, 0, 255));
            _console.clear();

            // draw current state
            ulong deltaMs = _frameCounter.tickMs();
            double dt = deltaMs / 1000.0;
            _state.draw(_console, dt);

            _console.flush();
/*
            int waitMs = cast(int)(POLL_DELAY + (timeBeforeInput - _sdl2.getTicks()));
            if (0 < waitMs && waitMs <= POLL_DELAY)
                _sdl2.delay(waitMs);*/
        }
    }

private:

    SDL2 _sdl2;
    Console _console;
    State _state;
    FrameCounter _frameCounter;
}

