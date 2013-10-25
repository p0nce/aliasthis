module aliasthis.statemachine;

import std.random; 

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
    this(SDL2 sdl2, Console console)
    {
        _sdl2 = sdl2;
        _console = console;    
        _state = new StatePlay(0);
        _frameCounter = new FrameCounter(sdl2);
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
                            newState = _state.handleKeypress(event.key.keysym);   
                            break;

                        default:
                            break;
                    }

                    if (newState !is null)
                    {
                        if (cast(StateExit)newState !is null)
                            finished = true;
                        else if (cast(StateToggleFullscreen)newState !is null)
                            _console.toggleFullscreen();
                        else
                        {
                            _state = newState;
                        }
                    }
                }

            }

            // clear the console
            _console.setForegroundColor(color(0, 0, 0));
            _console.setBackgroundColor(color(0, 0, 0));
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

