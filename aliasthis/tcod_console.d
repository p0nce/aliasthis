module aliasthis.tcod_console;

import std.string,
       std.path; 

import derelict.tcod.libtcod;

import aliasthis.tcod_lib;

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

    void setForegroundColor(TCOD_color_t fg)
    {
        TCOD_console_set_default_foreground(_handle, fg);
    }

    void setBackgroundColor(TCOD_color_t bg)
    {
        TCOD_console_set_default_background(_handle, bg);
    }

    void putChar(int x, int y, dchar c, TCOD_bkgnd_flag_t flag)
    {
        TCOD_console_put_char(_handle, x, y, c, flag);
    }

    void print(int x, int y, const(char)* text)
    {
        TCOD_console_print(_handle, x, y, text);
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
