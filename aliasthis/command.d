module aliasthis.command;

import aliasthis.utils,
       aliasthis.grid;

enum CommandType 
{
    MOVE,
    WAIT
}

// Command are a high-level overview of instructions.
// They map to actually different effects (eg: MOVE can move, dig or attack).
// Considering a GameState, a Command executes into a ChangeSet.
// A successful ChangeSet can be applied or not to the GameState.
// A command SHOULD be able to be asked to any Entity.
struct Command
{
    CommandType type;
    vec3i movement;

    static Command createMovement(Direction dir)
    {
        Command res;
        res.type = CommandType.MOVE;
        res.movement = getDirection(dir);
        return res;
    }

    static Command createWait()
    {
        Command res;
        res.type = CommandType.WAIT;
        return res;
    }
}
