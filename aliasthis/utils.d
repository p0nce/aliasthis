module aliasthis.utils;

import derelict.tcod.libtcod;

TCOD_color_t color(int r, int g, int b)
{
    return TCOD_color_t(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b);
}
