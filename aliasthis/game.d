module aliasthis.game;

import std.random; 

import derelict.tcod.libtcod;

import aliasthis.tcod_console;

class Game
{
public:
    this(TCODConsole console, ref Xorshift rng)
    {
        _console = console;        
    }

    void mainLoop()
    {
        bool finished = false;
        while(true)
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

            // tick
            TCOD_console_print(null, 1, 1, "test");
            _console.flush();

            
        }

        
    }

private:

    TCODConsole _console;
}
