import std.random,
       std.typecons,
       std.stdio,
       std.path,
       std.getopt;

import drogue.game;
import drogue.tcod_console;

void main(string[] args)
{    
    try
    {
        string absolutePathOfExecutable = absolutePath(args[0], getcwd()); 
        string gameDir = dirName(absolutePathOfExecutable);
       
        auto seed = unpredictableSeed();
        getopt(args,
               "seed",  &seed);

        auto rng = Xorshift(seed);

        // create new game and play it

        auto console = scoped!TCODConsole(gameDir);
        auto game = scoped!Game(console, rng);

        game.mainLoop();
    }
    catch(Exception e)
    {
        writefln("%s", e.msg);
    }
}
