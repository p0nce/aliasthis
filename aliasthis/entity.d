module aliasthis.entity;

import gfm.math.all;

// basis for players and monsters
import aliasthis.tcod_console,
       aliasthis.cell,
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
        bool go(World world, Direction dir)
        {
            vec3i m = getDirection(dir);
            vec3i newPos = position + m;

            if (world.contains(newPos))
            {
                Cell* cell = world.cell(newPos);
                if (CanMoveInto(cell.type))
                {
                    position = newPos;
                    return true;
                }
            }
            return false;
        }      
    }
}
