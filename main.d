import std.random,
       std.typecons,
       std.stdio,
       std.path,
       std.getopt;

import gfm.core.log,
       gfm.sdl2.all;

import aliasthis.statemachine,
       aliasthis.config,
       aliasthis.console;

void main(string[] args)
{    
    Log log = new ConsoleLog();
    try
    {
        string absolutePathOfExecutable = absolutePath(args[0], getcwd()); 
        string gameDir = dirName(absolutePathOfExecutable);
       
        auto sdl2 = scoped!SDL2(log);
        auto console = scoped!Console(sdl2, log, gameDir, CONSOLE_WIDTH, CONSOLE_HEIGHT);
        auto stateMachine = scoped!StateMachine(sdl2, gameDir, console);
        stateMachine.mainLoop();
    }
    catch(Exception e)
    {
        writefln("%s", e.msg);
    }
}
