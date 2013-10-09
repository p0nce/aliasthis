module aliasthis.world;

import gfm.math.all;

import aliasthis.cell;

// basically a big cube

enum WORLD_NUM_CELLS = WORLD_WIDTH * WORLD_HEIGHT * WORLD_DEPTH;

enum WORLD_WIDTH = 60;
enum WORLD_HEIGHT = 30;
enum WORLD_DEPTH = 20;

class World
{
    public
    {
        this(ref Xorshift rng)
        {
            _cells.length = WORLD_NUM_CELLS;

            for (int k = 0; k < WORLD_DEPTH; ++k)
            {
                for (int j = 0; j < WORLD_HEIGHT; ++j)
                {
                    for (int i = 0; i < WORLD_WIDTH; ++i)
                    {
                        Cell* c = cell(vec3i(i, j, k));
                        c.type = CellType.FLOOR;

                        if (i == 0 || i == WORLD_WIDTH - 1 || j == 0 || j == WORLD_HEIGHT - 1)
                            c.type = CellType.WALL;

                    }
                }
            }

        }

        Cell* cell(vec3i pos)
        {
            return &_cells[pos.x + WORLD_WIDTH * pos.y + (WORLD_WIDTH * WORLD_HEIGHT) * pos.z];
        }

        static bool contains(vec3i pos)
        {
            if (cast(uint)pos.x >= cast(uint)WORLD_WIDTH) 
                return false;
            if (cast(uint)pos.y >= cast(uint)WORLD_HEIGHT) 
                return false;
            if (cast(uint)pos.z >= cast(uint)WORLD_DEPTH) 
                return false;
            return true;
        }
    }

    private
    {
        Cell[] _cells;
    }
}


enum Direction
{
    WEST,
    EAST,
    NORTH,
    SOUTH,
    BELOW,
    ABOVE
}

vec3i getDirection(Direction dir)
{
    final switch(dir)
    {
        case Direction.WEST: return vec3i(-1, 0, 0);
        case Direction.EAST: return vec3i(+1, 0, 0);
        case Direction.NORTH: return vec3i(0, -1, 0);
        case Direction.SOUTH: return vec3i(0, +1, 0);
        case Direction.BELOW: return vec3i(0, 0, -1);
        case Direction.ABOVE: return vec3i(0, 0, +1);
    }
}