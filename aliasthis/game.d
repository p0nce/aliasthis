module aliasthis.game;

import std.random; 

import derelict.tcod.libtcod;

import gfm.math.all;

import aliasthis.tcod_console,
       aliasthis.world,
       aliasthis.entity;

class Game
{
public:
    this(TCODConsole console, ref Xorshift rng)
    {
        _console = console;       
        _world = new World(rng);

        _human = new Human();
        _human.position = vec3i(10, 10, WORLD_DEPTH - 1);

        _levelToShow = WORLD_DEPTH - 1; // top-most level
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
                            _human.go(Direction.WEST);
                        }
                        else if (key.vk == TCODK_RIGHT)
                        {
                            _human.go(Direction.EAST);
                        }
                        else if (key.vk == TCODK_UP)
                        {
                            _human.go(Direction.NORTH);
                        }
                        else if (key.vk == TCODK_DOWN)
                        {
                            _human.go(Direction.SOUTH);
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
    World _world;
    Human _human;

    int _levelToShow;

    void redraw()
    {
        int level = 0;

        // redraw all
        for (int i = 0; i < _console.width; i += 10)
            for (int j = 0; j < _console.height; ++j)
            {
                _console.setBackgroundColor(TCOD_color_t((j * -47 + i * 7) & 255, (i*j +78 * 4241) & 255, 255 & (i ^ j) ));
                _console.print(i, j, "hello world", TCOD_BKGND_SET);
            }

        _console.flush();
    }
}
