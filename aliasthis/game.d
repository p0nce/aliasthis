module aliasthis.game;

import std.random;

import aliasthis.console,
       aliasthis.command,
       aliasthis.change,
       aliasthis.worldstate;

// Holds the game state and how we got there.
// 
class Game
{
public:
    this(uint initialSeed)
    {
        rng.seed(initialSeed);
        _worldState = WorldState.createNewWorld(rng);
        _changeLog = [];
        _commandLog = [];
    }    

    void draw(Console console, double dt)
    {
        _worldState.estheticUpdate(dt);
        _worldState.draw(console);
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
}
