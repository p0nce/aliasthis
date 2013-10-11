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
    State _state;

    void redraw()
    {
        _console.setForegroundColor(color(0, 0, 0));
        _console.setBackgroundColor(color(0, 0, 0));
        _console.clear();

        _state.draw(_console);

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
            _state.executeCommand(Command.createMovement(Direction.EAST));
        }
        else if (key.vk == TCODK_UP || key.vk == TCODK_KP8)
        {
            _state.executeCommand(Command.createMovement(Direction.NORTH));
        }
        else if (key.vk == TCODK_DOWN || key.vk == TCODK_KP2)
        {
            _state.executeCommand(Command.createMovement(Direction.SOUTH));
        }
        else if (key.vk == TCODK_KP7)
        {
            _state.executeCommand(Command.createMovement(Direction.NORTH_WEST));
        }
        else if (key.vk == TCODK_KP9)
        {
            _state.executeCommand(Command.createMovement(Direction.NORTH_EAST));
        }
        else if (key.vk == TCODK_KP1)
        {
            _state.executeCommand(Command.createMovement(Direction.SOUTH_WEST));
        }
        else if (key.vk == TCODK_KP3)
        {
            _state.executeCommand(Command.createMovement(Direction.SOUTH_EAST));
        }
        else if (key.vk == TCODK_KP5 || key.c == ' ')
        {
            _state.executeCommand(Command.createWait());
        }
        else if (key.c == '<')
        {
            _state.executeCommand(Command.createMovement(Direction.ABOVE));
        }
        else if (key.c == '>')
        {
            _state.executeCommand(Command.createMovement(Direction.BELOW));
        }


        if (commands.length)
        {
            foreach(command; commands)
                _state.executeCommand(command);
        }
    }
}
