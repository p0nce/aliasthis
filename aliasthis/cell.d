module aliasthis.cell;

import aliasthis.tcod_lib;
import aliasthis.utils;

enum CellType
{
    STAIR_UP,
    STAIR_DOWN,
    SHALLOW_WATER,
    DEEP_WATER,
    LAVA,
    HOLE,
    WALL,
    FLOOR,
    DOOR_OPEN,
    DOOR_CLOSED,
}

struct CellGraphics
{
    int tcodCh; // index in TCOD font
    vec3ub foregroundColor;
    vec3ub backgroundColor;
}

struct Cell
{
    CellType type;

    CellGraphics graphics()
    {
        final switch(type)
        {
            case CellType.STAIR_UP:      return CellGraphics(ctCharacter!'<', color(255, 255, 0), color(0, 0, 0));
            case CellType.STAIR_DOWN:    return CellGraphics(ctCharacter!'>', color(255, 255, 0), color(0, 0, 0));
            case CellType.SHALLOW_WATER: return CellGraphics(ctCharacter!'~', color(255, 255, 255), color(128, 128, 255));
            case CellType.DEEP_WATER:    return CellGraphics(ctCharacter!'~', color(255, 255, 255), color(128, 128, 255));
            case CellType.LAVA:          return CellGraphics(ctCharacter!'~', color(255, 255, 255), color(255, 0, 0));
            case CellType.HOLE:          return CellGraphics(ctCharacter!'ː', color(47, 47, 87), color(0, 0, 0));
            case CellType.WALL:          return CellGraphics(0x75/*ctCharacter!'■'*/, color(128, 128, 128), color(192, 192, 192));
            case CellType.FLOOR:         return CellGraphics(ctCharacter!'ˑ', color(200, 200, 200), color(30, 30, 40));
            case CellType.DOOR_OPEN:     return CellGraphics(ctCharacter!'Π', color(128, 128, 128), color(192, 192, 192));
            case CellType.DOOR_CLOSED:   return CellGraphics(ctCharacter!'Π', color(200, 200, 200), color(35, 12, 12));
        }
    }
}

// is it blocking?
bool CanMoveInto(CellType type)
{
    switch(type)
    {
        case CellType.WALL:
        case CellType.DOOR_CLOSED:
            return false;

        default:
            return true;
    }
}

// can an entity move into it, or at least try?
bool CanTryToMoveIntoSafely(CellType type)
{
    switch(type)
    {
        case CellType.STAIR_UP:
        case CellType.STAIR_DOWN:
        case CellType.WALL:
        case CellType.FLOOR:
        case CellType.DOOR_OPEN:
        case CellType.DOOR_CLOSED:
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

