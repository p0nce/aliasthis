module aliasthis.world;

import gfm.math.all;

import aliasthis.utils;
import aliasthis.tcod_lib;
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
            worldGeneration(rng);
        }

        Cell* cell(vec3i pos)
        {
            return &_cells[pos.x + WORLD_WIDTH * pos.y + (WORLD_WIDTH * WORLD_HEIGHT) * pos.z];
        }

        Cell* cell(int x, int y, int z)
        {
            return &_cells[x + WORLD_WIDTH * y + (WORLD_WIDTH * WORLD_HEIGHT) * z];
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


        void worldGeneration(ref Xorshift rng)
        {
            // set cell types

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

                        if (i >  4 && i < 10 && j > 4 && j < 20)
                            c.type = CellType.DEEP_WATER;

                        if (i >  14 && i < 28 && j > 4 && j < 20)
                            c.type = CellType.SHALLOW_WATER;

                        if (i == 0 && j == 15)
                            c.type = CellType.DOOR_CLOSED;

                        if (i >  30 && i < (32 + k) && j > 4 && j < 20)
                            c.type = CellType.HOLE;

                        if (i >  40 && i < 59 && j > 21 && j < 28)
                            c.type = CellType.LAVA;

                    }
                }
            }

            // render cell types

            struct LevelInfo
            {
                int wallCharIndex;     
                vec3ub wallColor;
            }

            LevelInfo level[WORLD_DEPTH];
            for (int k = 0; k < WORLD_DEPTH; ++k)
            {
                immutable int[] wallTypes = [ctCharacter!'▪', ctCharacter!'♦'];                
                level[k].wallCharIndex = wallTypes[uniform(0, wallTypes.length, rng)];

                float hue = uniform(0.0f, 1.0f, rng);

                level[k].wallColor = cast(vec3ub)(0.5f + hsv2rgb(vec3f(hue, 0.40f, 0.25f)) * 255.0f);

            }

            for (int k = 0; k < WORLD_DEPTH; ++k)
            {
                for (int j = 0; j < WORLD_HEIGHT; ++j)
                {
                    for (int i = 0; i < WORLD_WIDTH; ++i)
                    {
                        Cell* c = cell(i, j, k);
                        CellGraphics gr = defaultCellGraphics(c.type);
                        if (c.type == CellType.WALL)
                        {
                            gr.charIndex = level[k].wallCharIndex;


                            gr.backgroundColor = level[k].wallColor;
                        }

                        // perturb color
                        CellVariability var = cellVariability(c.type);
                        gr.foregroundColor = perturbColorSV(gr.foregroundColor, var.SNoise, var.VNoise, rng);
                        gr.backgroundColor = perturbColorSV(gr.backgroundColor, var.SNoise, var.VNoise, rng);

                        c.graphics = gr;
                    }
                }
            }

            
        }
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