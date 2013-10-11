module aliasthis.entity;

import std.math;

import gfm.math.all;

// basis for players and monsters
import aliasthis.tcod_console,
       aliasthis.cell,
       aliasthis.command,
       aliasthis.world;


// a dungeon object with a position (vegetal, table, etc...)
class Entity
{
    public
    {
        vec3i position;
    }
}

// a living entity (animal, human)
class Creature : Entity
{
    public
    {
       
    }

    protected
    {


    }
}

// a human player
class Human : Entity
{
    public
    {       
    }
}
