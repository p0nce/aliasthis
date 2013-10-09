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

            for (int i = 0; i < WORLD_NUM_CELLS; ++i)
            {
                _cells[i].type = CellType.WALL;
            }
        }

        Cell* cell(vec3i pos)
        {
            return &_cells[pos.x + WORLD_WIDTH * pos.y + (WORLD_WIDTH * WORLD_HEIGHT) * pos.z];
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