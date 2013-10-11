module aliasthis.state;

import std.random;

import aliasthis.tcod_console,
       aliasthis.command,
       aliasthis.entity,
       aliasthis.utils,
       aliasthis.cell,
       aliasthis.world;

// Holds the whole game state
class State
{
    public
    {
        this(World world, Human human)
        {
            _world = world;
            _human = human;
        }

        static State createNewGame(ref Xorshift rng)
        {
            auto world = new World(rng);

            auto human = new Human();
            human.position = vec3i(10, 10, WORLD_DEPTH - 1);

            return new State(world, human);
        }

        void draw(TCODConsole console)
        {
            int levelToDisplay = _human.position.z;
            for (int y = 0; y < WORLD_HEIGHT; ++y)
            {
                for (int x = 0; x < WORLD_WIDTH; ++x)
                {
                    int lowest = levelToDisplay;

                    while (lowest > 0 && _world.cell(vec3i(x, y, lowest)).type == CellType.HOLE)
                        lowest--;

                    // render bottom to up
                    for (int z = lowest; z <= levelToDisplay; ++z)
                    {
                        Cell* cell = _world.cell(vec3i(x, y, z));

                        int cx = 15 + x;
                        int cy = 1 + y;

                        CellGraphics gr = cell.graphics;

                        // don't render holes except at level 0
                        if (cell.type != CellType.HOLE || z == 0)
                        {
                            int levelDiff = levelToDisplay - lowest;
                            console.setForegroundColor(colorFog(gr.foregroundColor, levelDiff));
                            console.setBackgroundColor(colorFog(gr.backgroundColor, levelDiff));
                            console.put(cx, cy, gr.charIndex, TCOD_BKGND_SET);
                        }
                    }
                }   
            }

            // put players
            {
                int cx = _human.position.x + 15;
                int cy = _human.position.y + 1;

                Cell* cell = _world.cell(vec3i(_human.position.x, _human.position.y, levelToDisplay));
                CellGraphics gr = cell.graphics;
                console.setBackgroundColor(mulColor(gr.backgroundColor, 0.95f));
                console.setForegroundColor(color(223, 105, 71));
                console.putChar(cx, cy, 'Ѭ', TCOD_BKGND_SET);
            }
        }   


        // return true if successfully executed
        bool executeCommand(Command command)
        {
            final switch (command.type)
            {
                case CommandType.MOVE:
                    vec3i movement = command.movement;
                    if (std.math.abs(movement.x) + std.math.abs(movement.y) + std.math.abs(movement.z) != 1)
                        return false;

                    vec3i newPos = _human.position + movement;

                    if (_world.contains(newPos))
                    {
                        Cell* cell = _world.cell(newPos);
                        if (canMoveInto(cell.type))
                        {
                            _human.position = newPos;
                            return true;
                        }
                    }
                    return false;
            }
        }

    }

    // TODO separate commands from state changes
    private 
    {
        World _world;
        Human _human;
    }
}