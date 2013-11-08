module aliasthis.utils;

public import std.random;

import std.algorithm,
       std.math;

public import gfm.math.vector,
              gfm.math.funcs,
              gfm.math.simplerng,
              gfm.image.hsv;


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

vec4ub lerpColor(vec4ub a, vec4ub b, float t) pure nothrow
{
    vec4f af = cast(vec4f)a;
    vec4f bf = cast(vec4f)b;
    vec4f of = af * (1 - t) + bf * t;
    return cast(vec4ub)(0.5f + of);
}

vec3ub mulColor(vec3ub color, float amount) pure nothrow
{
    vec3f fcolor = cast(vec3f)color / 255.0f;
    fcolor *= amount;
    return cast(vec3ub)(0.5f + fcolor * 255.0f);
}

vec4ub mulColor(vec4ub color, float amount) pure nothrow
{
    return vec4ub(mulColor(color.xyz, amount), color.w);
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

vec4ub colorFog(vec4ub color, int levelDifference) pure nothrow
{
    return vec4ub(colorFog(color.xyz, levelDifference), color.w);
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

vec4ub perturbColorSV(vec4ub color, float Samount, float Vamount, ref Xorshift rng)
{
    return vec4ub(perturbColorSV(color.xyz, Samount, Vamount, rng), color.w);
}

