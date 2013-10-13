module aliasthis.murmurhash3;

//-----------------------------------------------------------------------------
// MurmurHash3 was written by Austin Appleby, and is placed in the public
// domain. The author hereby disclaims copyright to this source code.

// Note - The x86 and x64 versions do _not_ produce the same results, as the
// algorithms are optimized for their respective platforms. You can still
// compile and run any of them on any platform, but your performance with the
// non-native version will be less than optimal.


uint MurmurHash3_x86_32 (ubyte[] key, uint seed)
{
    int len = cast(int)key.length;
    const int nblocks = len / 4;

    uint h1 = seed;

    immutable uint c1 = 0xcc9e2d51;
    immutable uint c2 = 0x1b873593;

    const(uint)* blocks = cast(const(uint)*)(key.ptr + nblocks*4);

    for(int i = -nblocks; i; i++)
    {
        uint k1 = blocks[i];

        k1 *= c1;
        k1 = rotl32(k1,15);
        k1 *= c2;

        h1 ^= k1;
        h1 = rotl32(h1,13);
        h1 = h1*5+0xe6546b64;
    }

    const(ubyte)* tail = (key.ptr + nblocks*4);

    uint k1 = 0;

    switch(len & 3)
    {
        case 3: k1 ^= tail[2] << 16;
        case 2: k1 ^= tail[1] << 8;
        case 1: k1 ^= tail[0];
            k1 *= c1; 
            k1 = rotl32(k1,15); 
            k1 *= c2; 
            h1 ^= k1;
        case 0:
        default:
    };

    h1 ^= len;
    h1 = fmix32(h1);
    return h1;
}

private
{
    uint rotl32 ( uint x, byte r ) pure nothrow
    {
        return (x << r) | (x >> (32 - r));
    }

    ulong rotl64 ( ulong x, byte r ) pure nothrow
    {
        return (x << r) | (x >> (64 - r));
    }

    // Finalization mix - force all bits of a hash block to avalanche
    uint fmix32 ( uint h ) pure nothrow
    {
        h ^= h >> 16;
        h *= 0x85ebca6b;
        h ^= h >> 13;
        h *= 0xc2b2ae35;
        h ^= h >> 16;
        return h;
    }

    ulong fmix64 ( ulong k ) pure nothrow
    {
        k ^= k >> 33;
        k *= 0xff51afd7ed558ccd;
        k ^= k >> 33;
        k *= 0xc4ceb9fe1a85ec53;
        k ^= k >> 33;
        return k;
    }
}