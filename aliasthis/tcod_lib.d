module aliasthis.tcod_lib;

import std.string,
       std.path; 

import derelict.tcod.libtcod;

import aliasthis.tcod_console;



class TCODLib
{
public:
    this(string gameDir)
    {
        // load libtcod
        DerelictTCOD.load();        

        // initialize custom fonts
        string fontFile = buildNormalizedPath(gameDir, "data/fonts/consola_21x33.png");
        TCOD_console_set_custom_font(toStringz(fontFile), TCOD_FONT_TYPE_GREYSCALE | TCOD_FONT_LAYOUT_ASCII_INCOL, 16, 16);
        _initialized = true;
    }

    ~this()
    {
        close();
    }

    void close()
    {
        if (_initialized)
        {
            _initialized = false;
            DerelictTCOD.unload();
        }
    }

    // return the root console, can only be done once
    TCODConsole createRootConsole(int width, int height, bool fullscreen, string title)
    {
        TCOD_console_init_root(width, height, toStringz(title), fullscreen, TCOD_RENDERER_SDL);        

        // map characters
        for (int y = 0; y < 16; ++y)
            for (int x = 0; x < 16; ++x)
            {
                TCOD_console_map_ascii_code_to_font(charCodes[y * 16 + x], x, y);
            }
        //TCOD_console_map_ascii_codes_to_font(0, 2048, 0, 0);
        return new TCODConsole(this, null, width, height);
    }

    // return an offscreen console
    TCODConsole createOffscreenConsole(TCODLib lib, int width, int height)
    {
        TCOD_console_t handle = TCOD_console_new(width, height);
        return new TCODConsole(this, handle, width, height);
    }

private:
    bool _initialized;
}

private static immutable int charCodes[256] = 
[
    32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
    48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
    64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
    96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111,
    112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,0xA1,
    0xB7,0xAC,0x03BB,0x2190,0x2191,0x2192,0x2193,0x2206,0x220f,0x2248,0x221A,0x263C,0x25A0,0x25A1,0x25AA,0x25B2,
    0x2640,0x2642,0x2660,0x2663,0x2665,0x2666,0x266A,0x266B,0x2736,0x25CB,0x00A6,0xA7,0xA4,0xA9,0x3EE,0,
    0x1E3D,0x1E29,0x1D60,0x1D85,0x0489,0x03DE,0x03A0,0x0284,0x0287, 0x02A1,0x01AC,0x0194,0x01AE,0x01C2,0x01AA,0x0126,
    0x01E4,0x00A2,0xA5,0x01C0,0xDF,0x01B3,0x3E1,0x3D9,0x3E8,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
];