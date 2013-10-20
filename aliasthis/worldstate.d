module aliasthis.worldstate;

import std.random;

import aliasthis.console,
       aliasthis.command,
       aliasthis.entity,
       aliasthis.chartable,
       aliasthis.utils,
       aliasthis.revrng,
       aliasthis.change,
       aliasthis.cell,
       aliasthis.grid;

// Holds the whole game state
// SHOULD know nothing about Change and ChangeSet
class WorldState
{
    public
    {
        Grid _grid;
        Human _human;

        this(Grid grid, Human human)
        {
            _grid = grid;
            _human = human;
        }

        // generate a WorldState from a seed (new game)
        static WorldState createNewGame(ref Xorshift rng)
        {
            auto grid = new Grid(rng);

            auto human = new Human();
            human.position = vec3i(10, 10, GRID_DEPTH - 1);

            return new WorldState(grid, human);
        }

        void draw(Console console)
        {
            int levelToDisplay = _human.position.z;
            for (int y = 0; y < GRID_HEIGHT; ++y)
            {
                for (int x = 0; x < GRID_WIDTH; ++x)
                {
                    int lowest = levelToDisplay;

                    while (lowest > 0 && _grid.cell(vec3i(x, y, lowest)).type == CellType.HOLE)
                        lowest--;

                    // render bottom to up
                    for (int z = lowest; z <= levelToDisplay; ++z)
                    {
                        Cell* cell = _grid.cell(vec3i(x, y, z));

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

                Cell* cell = _grid.cell(vec3i(_human.position.x, _human.position.y, levelToDisplay));
                CellGraphics gr = cell.graphics;
                console.setBackgroundColor(mulColor(gr.backgroundColor, 0.95f));
                console.setForegroundColor(color(223, 105, 71));
                console.putChar(cx, cy, ctCharacter!'Ѭ');
            }
        }

        // make things move
        void estheticUpdate(double dt)
        {
            int visibleLevel = _human.position.z;
            _grid.estheticUpdate(visibleLevel, dt);
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
                    if (!_grid.contains(newPos))
                        return null;

                    Cell* oldCell = _grid.cell(oldPos);
                    Cell* cell = _grid.cell(newPos);

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