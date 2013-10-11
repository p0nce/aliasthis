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
    DOOR
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
        case CellType.DOOR:
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

CellGraphics defaultCellGraphics(CellType type) pure nothrow
{
    final switch(type)
    {
        case CellType.STAIR_UP:      return CellGraphics(ctCharacter!'<', color(255, 255, 0), color(0, 0, 0));
        case CellType.STAIR_DOWN:    return CellGraphics(ctCharacter!'>', color(255, 255, 0), color(0, 0, 0));
        case CellType.SHALLOW_WATER: return CellGraphics(ctCharacter!'~', color(60, 70, 116), color(101, 116, 193));
        case CellType.DEEP_WATER:    return CellGraphics(ctCharacter!'~', color(31, 39, 90), color(63, 78, 157));
        case CellType.LAVA:          return CellGraphics(ctCharacter!'~', color(205, 140, 0), color(148, 82, 0));
        case CellType.HOLE:          return CellGraphics(ctCharacter!' ', color(47, 47, 87), color(0, 0, 0));
        case CellType.WALL:          return CellGraphics(/* dummy */ctCharacter!'▪', color(128, 128, 138), /* dummy */color(20, 32, 64));
        case CellType.FLOOR:         return CellGraphics(ctCharacter!'ˑ', color(70, 70, 80), color(30, 30, 40));
        case CellType.DOOR:   return CellGraphics(ctCharacter!'Π', color(200, 200, 200), color(35, 12, 12));
    }
}

struct CellVariability
{
    float SNoise;
    float VNoise;
}

CellVariability cellVariability(CellType type) pure nothrow
{
    final switch(type)
    {
        case CellType.STAIR_UP:      return CellVariability(0.018f, 0.009f);
        case CellType.STAIR_DOWN:    return CellVariability(0.018f, 0.009f);
        case CellType.SHALLOW_WATER: return CellVariability(0.018f* 2.0f, 0.009f* 1.1f);
        case CellType.DEEP_WATER:    return CellVariability(0.018f * 2.0f, 0.009f* 1.1f);
        case CellType.LAVA:          return CellVariability(0.018f * 3.0f, 0.009f * 3.0f);
        case CellType.HOLE:          return CellVariability(0.018f, 0.009f);
        case CellType.WALL:          return CellVariability(0.018f, 0.009f);
        case CellType.FLOOR:         return CellVariability(0.018f * 0.4f, 0.009f * 0.4f);
        case CellType.DOOR:          return CellVariability(0.018f, 0.009f);
    }
}
