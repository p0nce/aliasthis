import std.random,
       std.typecons,
       std.stdio,
       std.path,
       std.getopt;

import gfm.core.log,
       gfm.sdl2.all;

import aliasthis.game,
       aliasthis.console;



void main(string[] args)
{    
    Log log = new ConsoleLog();
    try
    {
        string absolutePathOfExecutable = absolutePath(args[0], getcwd()); 
        string gameDir = dirName(absolutePathOfExecutable);
       
        auto seed = unpredictableSeed();
        bool fullscreen = true;
        getopt(args,
               "seed", &seed,
               "fullscreen", &fullscreen);

        auto rng = Xorshift(seed);

        auto sdl2 = scoped!SDL2(log);

        // create new game and play it

        int width = 91;
        int height = 32;

        auto console = scoped!Console(sdl2, log, gameDir, width, height);

        auto game = scoped!Game(sdl2, console, rng);
        game.mainLoop();
    }
    catch(Exception e)
    {
        writefln("%s", e.msg);
    }
}
