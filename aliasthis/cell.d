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



struct Cell
{
    CellType type;

    CellGraphics graphics;
}

// is it blocking?
bool canMoveInto(CellType type)
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
bool canTryToMoveIntoSafely(CellType type)
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

struct CellGraphics
{
    int charIndex; // index in TCOD font
    vec3ub foregroundColor;
    vec3ub backgroundColor;
}

CellGraphics defaultCellGraphics(CellType type) pure
{
    final switch(type)
    {
        case CellType.STAIR_UP:      return CellGraphics(ctCharacter!'<', color(255, 255, 0), color(0, 0, 0));
        case CellType.STAIR_DOWN:    return CellGraphics(ctCharacter!'>', color(255, 255, 0), color(0, 0, 0));
        case CellType.SHALLOW_WATER: return CellGraphics(ctCharacter!'~', color(60, 70, 116), color(101, 116, 193));
        case CellType.DEEP_WATER:    return CellGraphics(ctCharacter!'~', color(31, 39, 90), color(63, 78, 157));
        case CellType.LAVA:          return CellGraphics(ctCharacter!'~', color(255, 255, 255), color(255, 0, 0));
        case CellType.HOLE:          return CellGraphics(ctCharacter!'ː', color(47, 47, 87), color(0, 0, 0));
        case CellType.WALL:          return CellGraphics(ctCharacter!'▪', color(192, 192, 192), color(128, 128, 128));
        case CellType.FLOOR:         return CellGraphics(ctCharacter!'ˑ', color(200, 200, 200), color(30, 30, 40));
        case CellType.DOOR_OPEN:     return CellGraphics(ctCharacter!'Π', color(128, 128, 128), color(192, 192, 192));
        case CellType.DOOR_CLOSED:   return CellGraphics(ctCharacter!'Π', color(200, 200, 200), color(35, 12, 12));
    }
}