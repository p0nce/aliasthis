import std.random,
       std.typecons,
       std.stdio,
       std.path,
       std.getopt;

import aliasthis.game;
import aliasthis.tcod_lib;
import aliasthis.tcod_console;

void main(string[] args)
{    
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

        // create new game and play it
        int width  = 67;
        int height  = 67;

        auto tcodLib = scoped!TCODLib(gameDir);
        auto console = tcodLib.createRootConsole(width, height, fullscreen, "aliasthis");
        auto game = scoped!Game(console, rng);

        game.mainLoop();
    }
    catch(Exception e)
    {
        writefln("%s", e.msg);
    }
}
