import std.random,
       std.typecons,
       std.getopt;

import derelict.

import drogue.game;

void main(string[] args)
{
    auto seed = unpredictableSeed();
       
    getopt(args,
           "seed",  &seed);

    auto rng = Xorshift(seed);

    // create new game and play it

    auto game = scoped!Game(rng);
}