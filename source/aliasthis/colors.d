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

    float t = gfm.math.clamp!float(levelDifference / 2.5f, 0.0f, 1.0f);

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

    hsv.y = gfm.math.clamp!float(hsv.y, 0, 1);
    hsv.z = gfm.math.clamp!float(hsv.z, 0, 1);

    vec3f rgb = hsv2rgb(hsv);
    return cast(vec3ub)(0.5f + rgb * 255.0f);
}

vec4ub perturbColorSV(vec4ub color, float Samount, float Vamount, ref Xorshift rng)
{
    return vec4ub(perturbColorSV(color.xyz, Samount, Vamount, rng), color.w);
}

/**
  This module defines RGB <-> HSV conversions.
*/

// RGB <-> HSV conversions.

/// Converts a RGB triplet to HSV.
/// Authors: Sam Hocevar 
/// See_also: $(WEB http://lolengine.net/blog/2013/01/13/fast-rgb-to-hsv)
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

/// Convert a HSV triplet to RGB.
/// Authors: Sam Hocevar.
/// See_also: $(WEB http://lolengine.net/blog/2013/01/13/fast-rgb-to-hsv).
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


/+
/// RGB <-> HLS conversion
/// based on http://support.microsoft.com/kb/29240

struct HLS(COLOR, HLSTYPE=ushort, HLSTYPE HLSMAX=240)
{
    static assert(HLSMAX <= ushort.max, "TODO");

    // H,L, and S vary over 0-HLSMAX
    // HLSMAX BEST IF DIVISIBLE BY 6

    alias COLOR.ChannelType RGBTYPE;

    // R,G, and B vary over 0-RGBMAX
    enum RGBMAX = RGBTYPE.max;

    // Hue is undefined if Saturation is 0 (grey-scale)
    // This value determines where the Hue scrollbar is
    // initially set for achromatic colors
    enum UNDEFINED = HLSMAX*2/3;

    void toHLS(COLOR rgb, out HLSTYPE h, out HLSTYPE l, out HLSTYPE s)
    {
        auto R = rgb.r;
        auto G = rgb.g;
        auto B = rgb.b;

        /* calculate lightness */
        auto cMax = max( max(R,G), B); /* max and min RGB values */
        auto cMin = min( min(R,G), B);
        l = ( ((cMax+cMin)*HLSMAX) + RGBMAX )/(2*RGBMAX);

        if (cMax == cMin)              /* r=g=b --> achromatic case */
        {
            s = 0;                     /* saturation */
            h = UNDEFINED;             /* hue */
        }
        else                           /* chromatic case */
        {
            /* saturation */
            if (l <= (HLSMAX/2))
                s = cast(HLSTYPE)(( ((cMax-cMin)*HLSMAX) + ((cMax+cMin)/2) ) / (cMax+cMin));
            else
                s = cast(HLSTYPE)(( ((cMax-cMin)*HLSMAX) + ((2*RGBMAX-cMax-cMin)/2) )
                   / (2*RGBMAX-cMax-cMin));

            /* hue */
            auto Rdelta = ( ((cMax-R)*(HLSMAX/6)) + ((cMax-cMin)/2) ) / (cMax-cMin); /* intermediate value: % of spread from max */
            auto Gdelta = ( ((cMax-G)*(HLSMAX/6)) + ((cMax-cMin)/2) ) / (cMax-cMin);
            auto Bdelta = ( ((cMax-B)*(HLSMAX/6)) + ((cMax-cMin)/2) ) / (cMax-cMin);

            if (R == cMax)
                h = cast(HLSTYPE)(Bdelta - Gdelta);
            else if (G == cMax)
                h = cast(HLSTYPE)((HLSMAX/3) + Rdelta - Bdelta);
            else /* B == cMax */
                h = cast(HLSTYPE)(((2*HLSMAX)/3) + Gdelta - Rdelta);

            if (h < 0)
                h += HLSMAX;
            if (h > HLSMAX)
                h -= HLSMAX;
        }
    }

    /* utility routine for HLStoRGB */
    private HLSTYPE hueToRGB(HLSTYPE n1,HLSTYPE n2,HLSTYPE hue)
    {
        /* range check: note values passed add/subtract thirds of range */
        if (hue < 0)
            hue += HLSMAX;

        if (hue > HLSMAX)
            hue -= HLSMAX;

        /* return r,g, or b value from this tridrant */
        if (hue < (HLSMAX/6))
            return cast(HLSTYPE)( n1 + (((n2-n1)*hue+(HLSMAX/12))/(HLSMAX/6)) );
        if (hue < (HLSMAX/2))
            return cast(HLSTYPE)( n2 );
        if (hue < ((HLSMAX*2)/3))
            return cast(HLSTYPE)( n1 +    (((n2-n1)*(((HLSMAX*2)/3)-hue)+(HLSMAX/12))/(HLSMAX/6)));
        else
            return cast(HLSTYPE)( n1 );
    }

    COLOR fromHLS(HLSTYPE hue, HLSTYPE lum, HLSTYPE sat)
    {
        COLOR c;
        HLSTYPE Magic1, Magic2;       /* calculated magic numbers (really!) */

        if (sat == 0) {            /* achromatic case */
            c.r = c.g = c.b = cast(RGBTYPE)((lum*RGBMAX)/HLSMAX);
        //  assert(hue == UNDEFINED);
        }
        else  {                    /* chromatic case */
            /* set up magic numbers */
            if (lum <= (HLSMAX/2))
                Magic2 = cast(HLSTYPE)((lum*(HLSMAX + sat) + (HLSMAX/2))/HLSMAX);
            else
                Magic2 = cast(HLSTYPE)(lum + sat - ((lum*sat) + (HLSMAX/2))/HLSMAX);
            Magic1 = cast(HLSTYPE)(2*lum-Magic2);

            /* get RGB, change units from HLSMAX to RGBMAX */
            c.r = cast(RGBTYPE)((hueToRGB(Magic1,Magic2,cast(HLSTYPE)(hue+(HLSMAX/3)))*RGBMAX + (HLSMAX/2))/HLSMAX);
            c.g = cast(RGBTYPE)((hueToRGB(Magic1,Magic2,cast(HLSTYPE)(hue           ))*RGBMAX + (HLSMAX/2))/HLSMAX);
            c.b = cast(RGBTYPE)((hueToRGB(Magic1,Magic2,cast(HLSTYPE)(hue-(HLSMAX/3)))*RGBMAX + (HLSMAX/2))/HLSMAX);
        }
        return c;
    }
}

unittest
{
    import ae.utils.graphics.color;
    HLS!RGB hls;
    auto red = hls.fromHLS(0, 120, 240);
    assert(red == RGB(255, 0, 0));
    ushort h,l,s;
    hls.toHLS(red, h, l, s);
    assert(h==0 && l==120 && s==240);
}

+/