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


class Menu
{
public:
    this(string[] items)
    {
        _select = 0;
        _items = items;

        _maxLength = 0;
        for (size_t i = 0; i < items.length; ++i)
            if (_maxLength < items[i].length)
                _maxLength = items[i].length;
    }

    void up()
    {
        _select = (_select + _items.length - 1) % _items.length; 
    }

    void down()
    {
        _select = (_select + 1) % _items.length; 
    }

    int index()
    {
        return _select;
    }

    void draw(int posx, int posy, Console console)
    {
        vec4ub bgSelected = rgba(32, 32, 15, 255);
        vec4ub bgNormal = rgba(9, 9, 15, 255);
        for (int y = -1; y < cast(int)_items.length + 1; ++y)
            for (int x = -1; x < cast(int)_maxLength + 1; ++x)
            {
                if (y == _select)
                    console.setBackgroundColor(bgSelected);
                else
                    console.setBackgroundColor(bgNormal);

                console.putChar(posx + x, posy + y, ctCharacter!' ');
            }

        for (int y = 0; y < _items.length; ++y)
        {
            if (y == _select)
            {
                console.setForegroundColor(rgba(255, 128, 128, 255));
            }
            else
            {
                console.setForegroundColor(rgba(255, 255, 255, 255));
            }
            console.setBackgroundColor(rgba(255, 255, 255, 0));
            int offset = posx + (_maxLength - _items[y].length)/2;
            console.putText(offset, posy + y, _items[y]);
        }        
    }

private:
    string[] _items;
    int _select;
    int _maxLength;
}

class StateMainMenu : State
{
private:
    Menu _menu;

public:

    this()
    {
        _menu = new Menu( [
            "New game",
            "Load game",
            "View recording",
            "Quit"
        ] );
    }   

    override void draw(Console console, double dt)
    {
        _menu.draw(30, 20, console);        
    }

    override State handleKeypress(SDL_Keysym key)
    {
        // quit without confirmation
        if (key.sym == SDLK_ESCAPE)
            return new StateExit();
        else if (key.sym == SDLK_UP)
            _menu.up();
        else if (key.sym == SDLK_DOWN)
            _menu.down();
        else if (key.sym == SDLK_RETURN)
        {
            if (_menu.index() == 0) // new game
                return new StatePlay(unpredictableSeed);
            else if (_menu.index() == 1) // load game
            {
            }
            else if (_menu.index() == 2) // view recording
            {
            }
            else if (_menu.index() == 3) // quit
            {
                return new StateExit();
            }
        }

        return this; // default -> do nothing
    }
}

class StatePlay : State
{
public:

    this(uint initialSeed)
    {
        _game = new Game(initialSeed);
        _game.message("You entered the crypt of Aliasthis");
    }    

    override void draw(Console console, double dt)
    {
        _game.draw(console, dt);

        // TODO hud
    }

    override State handleKeypress(SDL_Keysym key)
    {
        Command[] commands;
        if (key.sym == SDLK_ESCAPE)
        {
            return new StateExit();
        }
        else if (key.sym == SDLK_LEFT || key.sym == SDLK_KP_4)
        {
            _game.message("You go west");
            commands ~= Command.createMovement(Direction.WEST);
        }
        else if (key.sym == SDLK_RIGHT || key.sym == SDLK_KP_6)
        {
            _game.message("You go east");
            commands ~= Command.createMovement(Direction.EAST);
        }
        else if (key.sym == SDLK_UP || key.sym == SDLK_KP_8)
        {
            _game.message("You go north");
            commands ~= Command.createMovement(Direction.NORTH);
        }
        else if (key.sym == SDLK_DOWN || key.sym == SDLK_KP_2)
        {
            _game.message("You go south");
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