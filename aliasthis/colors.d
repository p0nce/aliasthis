module aliasthis.utils;

public import std.random;

import std.algorithm,
       std.math;

public import gfm.math.vector,
              gfm.math.funcs,
              gfm.math.simplerng;


vec3ub rgb(int r, int g, int b) pure nothrow
{
    return vec3ub(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b);
}

vec4ub rgba(int r, int g, int b, int a) pure nothrow
{
    return vec4ub(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b, cast(ubyte)a);
}

vec3ub lerpColor(vec3ub a, vec3ub b, float t) pure nothrow
{
    vec3f af = cast(vec3f)a;
    vec3f bf = cast(vec3f)b;
    vec3f of = af * (1 - t) + bf * t;
    return cast(vec3ub)(0.5f + of);
}

vec3ub mulColor(vec3ub color, float amount) pure nothrow
{
    vec3f fcolor = cast(vec3f)color / 255.0f;
    fcolor *= amount;
    return cast(vec3ub)(0.5f + fcolor * 255.0f);
}

vec3ub colorFog(vec3ub color, int levelDifference) pure nothrow
{
    assert(levelDifference >= 0);
    if (levelDifference == 0)
        return color;

    vec3f fcolor = cast(vec3f)color / 255.0f;

    fcolor *= 0.3f; // darken

    vec3f hsv = rgb2hsv(fcolor);

    hsv.y *= (1.5f ^^ (-levelDifference));

    vec3f beforeFog = hsv2rgb(hsv);
    vec3f fog = vec3f(0.0f,0.0f,0.02f);

    float t = clamp!float(levelDifference / 2.5f, 0.0f, 1.0f);

    vec3f foggy = lerp(beforeFog, fog, t);
    return cast(vec3ub)(0.5f + foggy * 255.0f);
}

// gaussian color SV perturbation
vec3ub perturbColorSV(vec3ub color, float Samount, float Vamount, ref Xorshift rng)
{
    vec3f fcolor = cast(vec3f)color / 255.0f;
    vec3f hsv = rgb2hsv(fcolor);

    hsv.y += randNormal(rng) * Samount;
    hsv.z += randNormal(rng) * Vamount;

    hsv.y = clamp!float(hsv.y, 0, 1);
    hsv.z = clamp!float(hsv.z, 0, 1);

    vec3f rgb = hsv2rgb(hsv);
    return cast(vec3ub)(0.5f + rgb * 255.0f);
}

// Credits: Sam Hocevar 
// http://lolengine.net/blog/2013/01/13/fast-rgb-to-hsv
vec3f rgb2hsv(vec3f rgb) pure nothrow
{
    float K = 0.0f;

    if (rgb.y < rgb.z)
    {
        swap(rgb.y, rgb.z);
        K = -1.0f;
    }

    if (rgb.x < rgb.y)
    {
        swap(rgb.x, rgb.y);
        K = -2.0f / 6.0f - K;
    }

    float chroma = rgb.x - (rgb.y < rgb.z ? rgb.y : rgb.z);
    float h = abs(K + (rgb.y - rgb.z) / (6.0f * chroma + 1e-20f));
    float s = chroma / (rgb.x + 1e-20f);
    float v = rgb.x;

    return vec3f(h, s, v);
}

vec3f hsv2rgb(vec3f hsv) pure nothrow
{
    float S = hsv.y;
    float H = hsv.x;
    float V = hsv.z;

    vec3f rgb;

    if ( S == 0.0 ) 
    {
        rgb.x = V;
        rgb.y = V;
        rgb.z = V;
    } 
    else 
    {        
        if (H >= 1.0) 
        {
            H = 0.0;
        } 
        else 
        {
            H = H * 6;
        }
        int I = cast(int)H;
        assert(I >= 0 && I < 6);
        float F = H - I;     /* fractional part */

        float M = V * (1 - S);
        float N = V * (1 - S * F);
        float K = V * (1 - S * (1 - F));

        if (I == 0) { rgb.x = V; rgb.y = K; rgb.z = M; }
        if (I == 1) { rgb.x = N; rgb.y = V; rgb.z = M; }
        if (I == 2) { rgb.x = M; rgb.y = V; rgb.z = K; }
        if (I == 3) { rgb.x = M; rgb.y = N; rgb.z = V; }
        if (I == 4) { rgb.x = K; rgb.y = M; rgb.z = V; }
        if (I == 5) { rgb.x = V; rgb.y = M; rgb.z = N; }
    }
    return rgb;
}