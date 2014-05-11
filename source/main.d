import std.random,
       std.typecons,
       std.stdio,
       std.file,
       std.path,
       std.getopt;

import gfm.sdl2;

import aliasthis.statemachine,
       aliasthis.config,
       aliasthis.console;

import gfm.core.log;
import std.logger;

void main(string[] args)
{    
    Logger logger = new ConsoleLogger();
    try
    {
        string gameDir = dirName(thisExePath());
       
        auto sdl2 = scoped!SDL2(logger);
        auto console = scoped!Console(sdl2, logger, gameDir, CONSOLE_WIDTH, CONSOLE_HEIGHT);
        auto stateMachine = scoped!StateMachine(sdl2, gameDir, console);
        stateMachine.mainLoop();
    }
    catch(Exception e)
    {
        writefln("%s", e.msg);
    }
}
