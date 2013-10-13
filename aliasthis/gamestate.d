module aliasthis.gamestate;

import std.random;

import aliasthis.tcod_console,
       aliasthis.command,
       aliasthis.entity,
       aliasthis.utils,
       aliasthis.change,
       aliasthis.cell,
       aliasthis.world;

// Holds the whole game state
// SHOULD know nothing about Change and ChangeSet
class GameState
{
    public
    {
        World _world;
        Human _human;

        this(World world, Human human)
        {
            _world = world;
            _human = human;
        }

        static GameState createNewGame(ref Xorshift rng)
        {
            auto world = new World(rng);

            auto human = new Human();
            human.position = vec3i(10, 10, WORLD_DEPTH - 1);

            return new GameState(world, human);
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


        // compile a Command to a ChangeSet
        // returns null is not a valid command
        ChangeSet compileCommand(Entity entity, Command command /*, out bool needConfirmation */ )
        {
            Change[] changes;
            final switch (command.type)
            {
                case CommandType.WAIT:
                    break; // no change

                case CommandType.MOVE:
                    vec3i movement = command.movement;
                    if (std.math.abs(movement.x) + std.math.abs(movement.y) + std.math.abs(movement.z) != 1)
                        return null;

                    vec3i oldPos = _human.position;
                    vec3i newPos = _human.position + movement;

                    // out of the space
                    if (!_world.contains(newPos))
                        return null;
                    
                    Cell* cell = _world.cell(newPos);
                    if (canMoveInto(cell.type))
                        changes ~= Change.createMovement(oldPos, newPos);
                    else
                        return null;
            }

            return new ChangeSet(changes);
        }
    }

  
}