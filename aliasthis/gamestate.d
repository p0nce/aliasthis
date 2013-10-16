module aliasthis.gamestate;

import std.random;

import aliasthis.console,
       aliasthis.command,
       aliasthis.entity,
       aliasthis.utils,
       aliasthis.revrng,
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

        void draw(Console console)
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
                            console.putChar(cx, cy, gr.charIndex);
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
                console.putChar(cx, cy, 'Ѭ');
            }
        }

        // make things move
        void estheticUpdate(double dt)
        {
            int visibleLevel = _human.position.z;
            _world.estheticUpdate(visibleLevel, dt);
        }


        // compile a Command to a ChangeSet
        // returns null is not a valid command
        Change[] compileCommand(Entity entity, Command command /*, out bool needConfirmation */ )
        {
            Change[] changes;
            final switch (command.type)
            {
                case CommandType.WAIT:
                    break; // no change

                case CommandType.MOVE:
                    
                    vec3i movement = command.movement;
                    vec3i oldPos = _human.position;
                    vec3i newPos = _human.position + movement;

                    // going out of the map is not possible
                    if (!_world.contains(newPos))
                        return null;

                    Cell* oldCell = _world.cell(oldPos);
                    Cell* cell = _world.cell(newPos);

                    int abs_x = std.math.abs(movement.x);
                    int abs_y = std.math.abs(movement.y);
                    int abs_z = std.math.abs(movement.z);
                    if (abs_z == 0)
                    {
                        if (abs_x > 1 || abs_y > 1)
                            return null; // too large movement
                    }
                    else 
                    {
                        if (abs_x != 0 || abs_y != 0)
                            return null; // too large movement

                        if (abs_z > 1)
                            return null;

                        if (movement.z == -1 && oldCell.type != CellType.STAIR_DOWN)
                            return null;
                        
                        if (movement.z == 1 && oldCell.type != CellType.STAIR_UP)
                            return null;
                    }
                    
                    if (canMoveInto(cell.type))
                        changes ~= Change.createMovement(oldPos, newPos);
                    else
                        return null;
            }

            return changes;
        }
    }

  
}