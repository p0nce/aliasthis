module aliasthis.tcod_lib;

import std.string,
       std.path; 

import derelict.tcod.libtcod;

class TCODLib
{
public:
    this(string gameDir)
    {
        // load libtcod
        DerelictTCOD.load();        

        // initialize custom fonts
        string fontFile = buildNormalizedPath(gameDir, "data/fonts/consolas_unicode_16x16.png");
        TCOD_console_set_custom_font(toStringz(fontFile), TCOD_FONT_TYPE_GREYSCALE | TCOD_FONT_LAYOUT_ASCII_INCOL, 32, 64);

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

private:
    bool _initialized;
}
