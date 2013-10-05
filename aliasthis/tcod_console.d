module aliasthis.tcod_console;

import std.string,
       std.path; 

import derelict.tcod.libtcod;

import aliasthis.tcod_lib;

// Wrapper for TCOD console, both root and offscreen
class TCODConsole
{
public:

    // create the root console
    this(TCODLib lib, int width, int height, bool fullscreen)
    {
        _lib = lib;
        _handle = null;

        TCOD_console_init_root(width, height, "drogue", fullscreen, TCOD_RENDERER_SDL);        
    }

    void toggleFullscreen()
    {
        assert(isRoot());
        TCOD_console_set_fullscreen(!TCOD_console_is_fullscreen());
    }

    void clear()
    {
        TCOD_console_clear(_handle);
    }

    void flush()
    {
        assert(isRoot());
        TCOD_console_flush();
    }

    bool isRoot()
    {
        return _handle is null;
    }

private:
    TCODLib _lib;
    TCOD_console_t _handle;
}
