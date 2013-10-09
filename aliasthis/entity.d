module aliasthis.entity;

import gfm.math.all;

// basis for players and monsters
import aliasthis.tcod_console,
       aliasthis.world;


class Entity
{
    public
    {
        vec3i position;
    }
}

class Human : Entity
{
    public
    {

        void go(Direction dir)
        {
            position += getDirection(dir);
        }      
    }
}
