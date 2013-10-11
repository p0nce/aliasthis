module aliasthis.game;

import std.random; 

import derelict.tcod.libtcod;

import gfm.math.all;

import aliasthis.tcod_console,
       aliasthis.tcod_lib,
       aliasthis.world,
       aliasthis.cell,
       aliasthis.command,
       aliasthis.utils,
       aliasthis.state,
       aliasthis.entity;

// holds both a game state and the mean to diaplay it
class Game
{
public:
    this(TCODConsole console, ref Xorshift rng)
    {
        _console = console;
        _state = State.createNewGame(rng);        
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
                        if (key.vk == TCODK_ESCAPE)
                        {
                            finished = true;
                        }
                        else if (key.vk == TCODK_ENTER && ((0 != key.lalt) || (key.ralt != 0)))
                        {
                            _console.toggleFullscreen();
                        }
                        else if (key.vk == TCODK_LEFT)
                        {
                            _state.executeCommand(Command.createMovement(Direction.WEST));
                        }
                        else if (key.vk == TCODK_RIGHT)
                        {
                            _state.executeCommand(Command.createMovement(Direction.EAST));
                        }
                        else if (key.vk == TCODK_UP)
                        {
                            _state.executeCommand(Command.createMovement(Direction.NORTH));
                        }
                        else if (key.vk == TCODK_DOWN)
                        {
                            _state.executeCommand(Command.createMovement(Direction.SOUTH));
                        }
                        else if (key.c == '<')
                        {
                            _state.executeCommand(Command.createMovement(Direction.ABOVE));
                        }
                        else if (key.c == '>')
                        {
                            _state.executeCommand(Command.createMovement(Direction.BELOW));
                        }
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
    State _state;

    void redraw()
    {
        _console.setForegroundColor(color(0, 0, 0));
        _console.setBackgroundColor(color(0, 0, 0));
        _console.clear();

        _state.draw(_console);

        _console.flush();
    }
}
