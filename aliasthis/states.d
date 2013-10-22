module aliasthis.states;

import std.random; 

import gfm.sdl2.all,
       gfm.math.all;

import aliasthis.console,
       aliasthis.utils,
       aliasthis.command,
       aliasthis.game;


// base class for states
class State
{
    // handle keypress, return next State
    State handleKeypress(SDL_Keysym key)
    {
        return this; // default -> do nothing
    }

    void draw(Console console, double dt)
    {
        // default: do nothing
    }
}

// terminal state, special value
class StateExit : State
{
}

// terminal state, special value recognized as a command
class StateToggleFullscreen : State
{
}

class StateMainMenu : State
{
public:
    override void draw(Console console, double dt)
    {
        console.setBackgroundColor(color(0, 0, 0));
        console.setForegroundColor(color(255, 255, 255));
        console.putText(1, 1, "StateMainMenu");
    }

    override State handleKeypress(SDL_Keysym key)
    {
        return this; // default -> do nothing
    }
}

class StatePlay : State
{
public:

    this(uint initialSeed)
    {
        _game = new Game(initialSeed);
    }    

    override void draw(Console console, double dt)
    {
        _game.draw(console, dt);
        console.setBackgroundColor(color(0, 0, 0));
        console.setForegroundColor(color(255, 255, 255));
        console.putText(1, 1, "StatePlay");
    }

    override State handleKeypress(SDL_Keysym key)
    {
        Command[] commands;
        if (key.sym == SDLK_ESCAPE)
        {
            return new StateExit();
        }
        else if (key.sym == SDLK_RETURN && ((key.mod & KMOD_ALT) != 0))
        {
            return new StateToggleFullscreen();
        }
        else if (key.sym == SDLK_LEFT || key.sym == SDLK_KP_4)
        {
            commands ~= Command.createMovement(Direction.WEST);
        }
        else if (key.sym == SDLK_RIGHT || key.sym == SDLK_KP_6)
        {
            commands ~= Command.createMovement(Direction.EAST);
        }
        else if (key.sym == SDLK_UP || key.sym == SDLK_KP_8)
        {
            commands ~= Command.createMovement(Direction.NORTH);
        }
        else if (key.sym == SDLK_DOWN || key.sym == SDLK_KP_2)
        {
            commands ~= Command.createMovement(Direction.SOUTH);
        }
        else if (key.sym == SDLK_KP_7)
        {
            commands ~= Command.createMovement(Direction.NORTH_WEST);
        }
        else if (key.sym == SDLK_KP_9)
        {
            commands ~= Command.createMovement(Direction.NORTH_EAST);
        }
        else if (key.sym == SDLK_KP_1)
        {
            commands ~= Command.createMovement(Direction.SOUTH_WEST);
        }
        else if (key.sym == SDLK_KP_3)
        {
            commands ~= Command.createMovement(Direction.SOUTH_EAST);
        }
        else if (key.sym == SDLK_KP_5 || key.sym == SDLK_SPACE)
        {
            commands ~= Command.createWait();
        }
        else if (key.sym == SDLK_LESS)
        {
            commands ~= Command.createMovement(Direction.ABOVE);
        }
        else if (key.sym == SDLK_GREATER)
        {
            commands ~= Command.createMovement(Direction.BELOW);
        }
        else if (key.sym == SDLK_u)
        {
            _game.undo();          
        }

        assert(commands.length <= 1);

        if (commands.length)
        {
            _game.executeCommand(commands[0]);
        }

        return this;
    }

private:
    Game _game;
}