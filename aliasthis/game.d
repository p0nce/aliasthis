module aliasthis.game;

import std.random; 

import derelict.tcod.libtcod;

import gfm.math.all;

import aliasthis.tcod_console,
       aliasthis.tcod_lib,
       aliasthis.world,
       aliasthis.cell,
       aliasthis.utils,
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
                            _human.go(_world, Direction.WEST);
                        }
                        else if (key.vk == TCODK_RIGHT)
                        {
                            _human.go(_world, Direction.EAST);
                        }
                        else if (key.vk == TCODK_UP)
                        {
                            _human.go(_world, Direction.NORTH);
                        }
                        else if (key.vk == TCODK_DOWN)
                        {
                            _human.go(_world, Direction.SOUTH);
                        }
                        else if (key.c == '<')
                        {
                            _human.go(_world, Direction.ABOVE);
                        }
                        else if (key.c == '>')
                        {
                            _human.go(_world, Direction.BELOW);
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
        int cameraLevel = _human.position.z;
        
        _console.setForegroundColor(color(0, 0, 0));
        _console.setBackgroundColor(color(0, 0, 0));
        _console.clear();
        for (int y = 0; y < WORLD_HEIGHT; ++y)
            for (int x = 0; x < WORLD_WIDTH; ++x)
            {
                int lowest = cameraLevel;

                while (lowest > 0 && _world.cell(vec3i(x, y, lowest)).type == CellType.HOLE)
                    lowest--;

                // render bottom to up
                for (int z = lowest; z <= cameraLevel; ++z)
                {
                    Cell* cell = _world.cell(vec3i(x, y, z));
                
                    int cx = 15 + x;
                    int cy = 1 + y;

                    CellGraphics gr = cell.graphics;

                    // don't render holes except at level 0
                    if (cell.type != CellType.HOLE || z == 0)
                    {
                        int levelDiff = cameraLevel - lowest;
                        _console.setForegroundColor(colorFog(gr.foregroundColor, levelDiff));
                        _console.setBackgroundColor(colorFog(gr.backgroundColor, levelDiff));
                        _console.put(cx, cy, gr.charIndex, TCOD_BKGND_SET);
                    }
                }
            }      

        // put players
        {
            int cx = _human.position.x + 15;
            int cy = _human.position.y + 1;

            Cell* cell = _world.cell(vec3i(_human.position.x, _human.position.y, cameraLevel));
            CellGraphics gr = cell.graphics;
            _console.setBackgroundColor(mulColor(gr.backgroundColor, 0.95f));
            _console.setForegroundColor(color(223, 105, 71));
            _console.putChar(cx, cy, 'Ѭ', TCOD_BKGND_SET);
        }



        _console.flush();
    }
}
