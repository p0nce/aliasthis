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
            // redraw all
            for (int i = 1; i < _console.width; ++i)
                for (int j = 1; j < _console.height; ++j)
                {
                    _console.setBackgroundColor(TCOD_color_t((j * -47 + i * 7) & 255, (i*j +78 * 4241) & 255, 255 & (i ^ j) ));
                    _console.putChar(i, j, ' ', TCOD_BKGND_SET);
                }

            _console.flush();    


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
}
