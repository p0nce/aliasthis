module aliasthis.serialize;

import std.typecons;

// dumb serialization module
ubyte[] serialize(T)(T x)
{
    static if (is(T : uint))
    {
        ubyte[] bytes;
        bytes.length = 4;
        bytes[0] = x & 255;
        bytes[1] = (x >> 8) & 255;
        bytes[2] = (x >> 16) & 255;
        bytes[3] = (x >> 24) & 255;
        return bytes;
    }
    else static if (is(T : ushort))
    {
        ubyte[] bytes;
        bytes.length = 2;
        bytes[0] = x & 255;
        bytes[1] = (x >> 8) & 255;
        return bytes;
    }
    else static if (is(T == ubyte))
    {
        return [x];
    }
    else static if(is(T == string))
    {
        ubyte[] bytes = new ubyte[x.length];
        for(size_t i = 0; i < x.length; ++i)
            bytes[i] = x[i];
        return bytes;
    }
    else
    {
        static_assert(false, "Can't serialize this type");
    }
}