module aliasthis.change;

import gfm.math.vector;

import aliasthis.gamestate;

// GameState changes


// A change must be a small, reversible change.
// - cannot fail else unrecoverable error
// - reversible
struct Change
{
    enum Type
    {
        MOVE,
   //     PICK_DROP,
   //     HP_CHANGE
    }

    Type type;
    vec3i sourcePosition;
    vec3i destPosition;

    static Change createMovement(vec3i source, vec3i dest)
    {
        Change res;
        res.type = Type.MOVE;
        res.sourcePosition = source;
        res.destPosition = dest;
        return res;
    }
}

void applyChange(GameState gameState, Change change)
{
    final switch (change.type)
    {
        case Change.Type.MOVE:
            gameState._human.position = change.destPosition;
            break;
    }
}

void revertChange(GameState gameState, Change change)
{
    final switch (change.type)
    {
        case Change.Type.MOVE:
            gameState._human.position = change.sourcePosition;
            break;
    }
}

void applyChangeSet(GameState gameState, Change[] changeSet)
{
    foreach (ref Change change ; changeSet)
        applyChange(gameState, change);
}

void revertChangeSet(GameState gameState, Change[] changeSet)
{
    foreach_reverse (ref Change change ; changeSet)
        revertChange(gameState, change);
}

