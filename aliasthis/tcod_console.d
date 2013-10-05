module drogue.tcod_console;

import std.string,
       std.path; 

import derelict.tcod.libtcod;

class TCODConsole
{
public:
    this(string gameDir, bool fullscreen)
    {
        // load libtcod
        DerelictTCOD.load();        

        // initialize custom fonts
        string fontFile = buildNormalizedPath(gameDir, "data/fonts/consolas_unicode_16x16.png");
        TCOD_console_set_custom_font(toStringz(fontFile), TCOD_FONT_TYPE_GREYSCALE | TCOD_FONT_LAYOUT_ASCII_INCOL, 32, 64);

        int width, height;
        TCOD_sys_get_current_resolution(&width, &height);

        // TODO
        TCOD_console_init_root(120, 67, "drogue", fullscreen, TCOD_RENDERER_SDL);

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

    void toggleFullscreen()
    {
        TCOD_console_set_fullscreen(!TCOD_console_is_fullscreen());
    }

private:
    bool _initialized;
}
