module aliasthis.tcod_console;

import std.string,
       std.path; 

public import derelict.tcod.libtcod;

import aliasthis.utils,
       aliasthis.tcod_lib;

// Wrapper for TCOD console, both root and offscreen
class TCODConsole
{
public:

    this(TCODLib lib, TCOD_console_t handle, int width, int height)
    {
        _lib = lib;
        _handle = handle;
        _width = width;
        _height = height;
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

    void setForegroundColor(vec3ub fg)
    {
        TCOD_color_t tcodColor = TCOD_color_t(fg.x, fg.y, fg.z);
        TCOD_console_set_default_foreground(_handle, tcodColor);
    }

    void setBackgroundColor(vec3ub bg)
    {
        TCOD_color_t tcodColor = TCOD_color_t(bg.x, bg.y, bg.z);
        TCOD_console_set_default_background(_handle, tcodColor);
    }

    void putChar(int x, int y, dchar c, TCOD_bkgnd_flag_t flag)
    {
        int index = _lib.invMap(c);
        TCOD_console_put_char(_handle, x, y, index, flag);
    }

    void put(int x, int y, int c, TCOD_bkgnd_flag_t flag)
    {
        TCOD_console_put_char(_handle, x, y, c, flag);
    }

    void print(int x, int y, string text, TCOD_bkgnd_flag_t flag)
    {
        // handle UTF-8
        int i = 0;
        foreach(dchar d; text)
        {
            TCOD_console_put_char(_handle, x + i, y, _lib.invMap(d), flag);
            ++i;
        }
    }

    @property int width()
    {
        return _width;
    }

    @property int height()
    {
        return _height;
    }

private:
    TCODLib _lib;
    TCOD_console_t _handle;
    int _width, _height;
}
