module aliasthis.utils;

public import std.random;
public import gfm.math.vector;
public import gfm.math.simplerng;


vec3ub color(int r, int g, int b)
{
    return vec3ub(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b);
}
