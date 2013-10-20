module aliasthis.game;

import std.random; 

import gfm.sdl2.all,
       gfm.math.all;

import aliasthis.console,
       aliasthis.grid,
       aliasthis.cell,
       aliasthis.command,
       aliasthis.change,
       aliasthis.utils,
       aliasthis.worldstate,
       aliasthis.entity;

// holds both a game state and the mean to display it
class Game
{
public:
    this(SDL2 sdl2, Console console, ref Xorshift rng)
    {
        _sdl2 = sdl2;
        _console = console;
        _worldState = WorldState.createNewGame(rng);

        _changeLog = [];
    }

    void mainLoop()
    {
        bool finished = false;

        immutable int POLL_DELAY = 35;

        while(true)
        {
            uint timeBeforeInput = _sdl2.getTicks();

            if (_console.isClosed())
            {
                finished = true;
            }

            if (finished)
                break;

            // handle one event
            {
                SDL_Event event;
                while (_sdl2.pollEvent(&event))
                {
                    switch (event.type)
                    {
                        case SDL_KEYDOWN:
                            handleKeypress(event.key.keysym, finished);
                            break;

                        default:
                            break;
                    }

                }

            }

            _worldState.estheticUpdate(POLL_DELAY / 1000.0);
            redraw();

            int waitMs = cast(int)(POLL_DELAY + (timeBeforeInput - _sdl2.getTicks()));
            if (0 < waitMs && waitMs <= POLL_DELAY)
                _sdl2.delay(waitMs);
        }
    }

private:

    SDL2 _sdl2;
    Console _console;
    WorldState _worldState;
    Change[] _changeLog;

    void redraw()
    {
        _console.setForegroundColor(color(0, 0, 0));
        _console.setBackgroundColor(color(0, 0, 0));
        _console.clear();

        _worldState.draw(_console);

        _console.flush();
    }

    void handleKeypress(SDL_Keysym key, ref bool finished)
    {
        Command[] commands;
        if (key.sym == SDLK_ESCAPE)
        {
            finished = true;
        }
        else if (key.sym == SDLK_RETURN && ((key.mod & KMOD_ALT) != 0))
        {
            _console.toggleFullscreen();
        }
        else if (key.sym == SDLK_LEFT || key.sym == SDLK_KP_4)
        {
            commands ~= Command.createMovement(Direction.WEST);
        }
        else if (key.sym == SDLK_RIGHT || key.sym == SDLK_KP_6)
        {
            commands ~= Command.createMovement(Direction.EAST);
        }
        else if (key.sym == SDLK_UP || key.sym == SDLK_KP_8)
        {
            commands ~= Command.createMovement(Direction.NORTH);
        }
        else if (key.sym == SDLK_DOWN || key.sym == SDLK_KP_2)
        {
            commands ~= Command.createMovement(Direction.SOUTH);
        }
        else if (key.sym == SDLK_KP_7)
        {
            commands ~= Command.createMovement(Direction.NORTH_WEST);
        }
        else if (key.sym == SDLK_KP_9)
        {
            commands ~= Command.createMovement(Direction.NORTH_EAST);
        }
        else if (key.sym == SDLK_KP_1)
        {
            commands ~= Command.createMovement(Direction.SOUTH_WEST);
        }
        else if (key.sym == SDLK_KP_3)
        {
            commands ~= Command.createMovement(Direction.SOUTH_EAST);
        }
        else if (key.sym == SDLK_KP_5 || key.sym == SDLK_SPACE)
        {
            commands ~= Command.createWait();
        }
        else if (key.sym == SDLK_LESS)
        {
            commands ~= Command.createMovement(Direction.ABOVE);
        }
        else if (key.sym == SDLK_GREATER)
        {
            commands ~= Command.createMovement(Direction.BELOW);
        }
        else if (key.sym == SDLK_u)
        {
            // undo one change
            size_t n = _changeLog.length;
            if (n > 0)
            {
                revertChange(_worldState, _changeLog[n - 1]);
                _changeLog = _changeLog[0..n-1];
            }
        }

        assert(commands.length <= 1);

        if (commands.length)
        {
            Change[] changes = _worldState.compileCommand(_worldState._human, commands[0]);

            if (changes !is null) // command is valid
            {
                applyChangeSet(_worldState, changes);

                // enqueue all changes
                foreach (ref Change c ; changes)
                {
                    _changeLog ~= changes;
                }
            }
        }
    }
}
