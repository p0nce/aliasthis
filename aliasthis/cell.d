module aliasthis.cell;


enum CellType
{
    STAIR_UP,
    STAIR_DOWN,
    SHALLOW_WATER,
    DEEP_WATER,
    LAVA,
    HOLE,
    WALL,
    FLOOR
}

struct Cell
{
    CellType type;
}

bool CanMoveIntoSafe(CellType type)
{
    switch(type)
    {
        case CellType.STAIR_UP:
        case CellType.STAIR_DOWN:
        case CellType.WALL:
        case CellType.FLOOR:
            return true;

        case CellType.SHALLOW_WATER:
        case CellType.DEEP_WATER:
        case CellType.LAVA:
        case CellType.HOLE:
            return false;

        default:
            assert(false);
    }
}


