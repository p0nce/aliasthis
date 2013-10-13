module aliasthis.game;

import std.random; 

import derelict.tcod.libtcod;

import gfm.math.all;

import aliasthis.tcod_console,
       aliasthis.tcod_lib,
       aliasthis.world,
       aliasthis.cell,
       aliasthis.command,
       aliasthis.change,
       aliasthis.utils,
       aliasthis.gamestate,
       aliasthis.entity;

// holds both a game state and the mean to display it
class Game
{
public:
    this(TCODConsole console, ref Xorshift rng)
    {
        _console = console;
        _gameState = GameState.createNewGame(rng);

        _changeLog = [];
    }

    void mainLoop()
    {
        bool finished = false;
        while(true)
        {
            redraw();
            // handle one event
            {
                TCOD_key_t key;
                TCOD_mouse_t mouse;
                TCOD_event_t event = TCOD_sys_wait_for_event(TCOD_EVENT_ANY, &key, &mouse, false);

                switch (event)
                {
                    case TCOD_EVENT_KEY_PRESS:
                        handleKeypress(key, finished);
                        break;

                    case TCOD_EVENT_KEY_RELEASE:
                        break;

                    case TCOD_EVENT_MOUSE_MOVE:
                        break;

                    case TCOD_EVENT_MOUSE_PRESS:
                        break;

                    case TCOD_EVENT_MOUSE_RELEASE:
                        break;

                    default:
                }

                if (TCOD_console_is_window_closed())
                {
                    finished = true;
                }

                if (finished)
                    break;
            }
        }

        
    }

private:

    TCODConsole _console;
    GameState _gameState;
    Change[] _changeLog;

    void redraw()
    {
        _console.setForegroundColor(color(0, 0, 0));
        _console.setBackgroundColor(color(0, 0, 0));
        _console.clear();

        _gameState.draw(_console);

        _console.flush();
    }

    void handleKeypress(TCOD_key_t key, ref bool finished)
    {
        Command[] commands;
        if (key.vk == TCODK_ESCAPE)
        {
            finished = true;
        }
        else if (key.vk == TCODK_ENTER && ((0 != key.lalt) || (key.ralt != 0)))
        {
            _console.toggleFullscreen();
        }
        else if (key.vk == TCODK_LEFT || key.vk == TCODK_KP4)
        {
            commands ~= Command.createMovement(Direction.WEST);
        }
        else if (key.vk == TCODK_RIGHT || key.vk == TCODK_KP6)
        {
            commands ~= Command.createMovement(Direction.EAST);
        }
        else if (key.vk == TCODK_UP || key.vk == TCODK_KP8)
        {
            commands ~= Command.createMovement(Direction.NORTH);
        }
        else if (key.vk == TCODK_DOWN || key.vk == TCODK_KP2)
        {
            commands ~= Command.createMovement(Direction.SOUTH);
        }
        else if (key.vk == TCODK_KP7)
        {
            commands ~= Command.createMovement(Direction.NORTH_WEST);
        }
        else if (key.vk == TCODK_KP9)
        {
            commands ~= Command.createMovement(Direction.NORTH_EAST);
        }
        else if (key.vk == TCODK_KP1)
        {
            commands ~= Command.createMovement(Direction.SOUTH_WEST);
        }
        else if (key.vk == TCODK_KP3)
        {
            commands ~= Command.createMovement(Direction.SOUTH_EAST);
        }
        else if (key.vk == TCODK_KP5 || key.c == ' ')
        {
            commands ~= Command.createWait();
        }
        else if (key.c == '<')
        {
            commands ~= Command.createMovement(Direction.ABOVE);
        }
        else if (key.c == '>')
        {
            commands ~= Command.createMovement(Direction.BELOW);
        }
        else if (key.c == 'u')
        {
            // undo one change
            size_t n = _changeLog.length;
            if (n > 0)
            {
                revertChange(_gameState, _changeLog[n - 1]);
                _changeLog = _changeLog[0..n-1];
            }
        }

        assert(commands.length <= 1);

        if (commands.length)
        {
            Change[] changes = _gameState.compileCommand(_gameState._human, commands[0]);

            if (changes !is null) // command is valid
            {
                applyChangeSet(_gameState, changes);

                // enqueue all changes
                foreach (ref Change c ; changes)
                {
                    _changeLog ~= changes;
                }
            }
        }
    }
}
