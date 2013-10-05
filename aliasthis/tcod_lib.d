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
        string fontFile = buildNormalizedPath(gameDir, "data/fonts/consolas_unicode_16x16.png");
        TCOD_console_set_custom_font(toStringz(fontFile), TCOD_FONT_TYPE_GREYSCALE /*| TCOD_FONT_LAYOUT_ASCII_INCOL*/, 32, 64);



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
        TCOD_console_map_ascii_codes_to_font(0, 2048, 0, 0);
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
