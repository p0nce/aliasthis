module aliasthis.game;

import std.random;

import gfm.core.queue;

import aliasthis.console,
       aliasthis.command,
       aliasthis.change,
       aliasthis.config,
       aliasthis.worldstate;

// Holds the game state and how we got there.
// 
class Game
{
public:
    enum NUM_BUFFERED_MESSAGES = 100;

    this(uint initialSeed)
    {
        rng.seed(initialSeed);
        _worldState = WorldState.createNewWorld(rng);
        _changeLog = [];
        _commandLog = [];

        _messageLog = new RingBuffer!string(NUM_BUFFERED_MESSAGES);
        foreach (i ; 0..NUM_BUFFERED_MESSAGES)
            _messageLog.pushBack("");
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

        // draw last log line
        console.setBackgroundColor(color(0, 0, 0));
        console.setForegroundColor(color(255, 255, 255));
        console.putText(0, console.height - 1, _messageLog.front());

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



private:
    Xorshift rng;
    int initialSeed;
    WorldState _worldState;
    Change[] _changeLog;
    Command[] _commandLog;
    RingBuffer!string _messageLog;
}
