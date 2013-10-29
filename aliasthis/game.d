module aliasthis.game;

import std.random;

import msgpack;

import gfm.core.queue;

import aliasthis.console,
       aliasthis.command,
       aliasthis.config,
       aliasthis.change,
       aliasthis.serialize,
       aliasthis.worldstate;


struct SaveFile
{
    string magic;
    ubyte majorVersion;
    ubyte minorVersion;
    uint seed;
    uint commandLength;
    ubyte[] commandLog; // commands bytecode
}

string SAVE_MAGIC_STRING = "ATSave";

// Holds the game state and how we got there.
// 
class Game
{
public:
    enum NUM_BUFFERED_MESSAGES = 100;

    // create a new game
    this(uint initialSeed)
    {
        rng.seed(initialSeed);
        _initialSeed = initialSeed;
        _worldState = WorldState.createNewWorld(rng);
        _changeLog = [];
        _commandLog = [];

        _messageLog = new RingBuffer!string(NUM_BUFFERED_MESSAGES);
        foreach (i ; 0..NUM_BUFFERED_MESSAGES)
            _messageLog.pushBack("");
    }    

    // restore a game from a save
    this(ubyte[] binarySave)
    {
        // save seed + sequence of commands
        // is enough to recreate game state
        try
        {
            SaveFile s;
            msgpack.unpack(binarySave, s);

            if (s.magic != SAVE_MAGIC_STRING)
                throw new AliasthisException("Invalid save file");

            if (s.majorVersion != ALIASTHIS_MAJOR_VERSION)
                throw new AliasthisException("Can't load this save file: different major versions");

            if (s.minorVersion != ALIASTHIS_MINOR_VERSION)
                throw new AliasthisException("Can't load this save file: different minor versions");

            // create the game anew
            this(s.seed);

            // replay all commands :) can be very slow

            assert(0); // TODO
        }
        catch(MessagePackException e)
        {
            throw new AliasthisException(e.msg);
        }
    }

    // enqueue a game log message
    void message(string m)
    {
        _messageLog.pushFront(m);
    }

    void draw(Console console, double dt)
    {
        _worldState.estheticUpdate(dt);
        _worldState.draw(console);

        // draw last 3 log line
        console.setBackgroundColor(rgba(0, 0, 0, 255));
        console.setForegroundColor(rgba(255, 255, 255, 255));
        for (int i = 0; i < 3; ++i)
        {
            console.putText(1, console.height - 3 + i, _messageLog[i]);
        }
    }

    void executeCommand(Command command)
    {
        Change[] changes = _worldState.compileCommand(_worldState._human, command);

        if (changes !is null) // command is valid
        {
            applyChangeSet(_worldState, changes);

            // enqueue all changes
            foreach (ref Change c ; changes)
            {
                _changeLog ~= changes;
            }

            _commandLog ~= command;
        }
    }

    void undo()
    {
        // undo one change
        size_t n = _changeLog.length;
        if (n > 0)
        {
            revertChange(_worldState, _changeLog[n - 1]);
            _changeLog = _changeLog[0..n-1];
        }
    }

    // save seed + sequence of commands
    // is enough to recreate game state
    ubyte[] saveGame()
    {
        ubyte[] commands;
        foreach(ref command; _commandLog)
        {
            commands ~= command.serialize();
        }

        return msgpack.pack(SaveFile(SAVE_MAGIC_STRING, ALIASTHIS_MAJOR_VERSION, ALIASTHIS_MINOR_VERSION, _initialSeed, _commandLog.length, commands));
    }

private:
    Xorshift rng;
    uint _initialSeed;
    WorldState _worldState;
    Change[] _changeLog;
    Command[] _commandLog;
    RingBuffer!string _messageLog;   
}
