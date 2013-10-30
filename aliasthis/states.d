module aliasthis.states;

import std.random; 

import gfm.sdl2.all,
       gfm.math.all;

import aliasthis.console,
       aliasthis.utils,
       aliasthis.config,
       aliasthis.command,
       aliasthis.game;


// base class for states
class State
{
public:
    this(Console console)
    {
        _console = console;
    }

    void close()
    {
    }

    // handle keypress, return next State
    State handleKeypress(SDL_Keysym key)
    {
        return this; // default -> do nothing
    }

    void draw(double dt)
    {
        // default: do nothing
    }

protected:
    Console _console;
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
        vec4ub bgSelected = rgba(110, 18, 27, 255);
        vec4ub bgNormal = rgba(6, 6, 10, 128);
        for (int y = -1; y < cast(int)_items.length + 1; ++y)
            for (int x = -2; x < cast(int)_maxLength + 2; ++x)
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
                console.setForegroundColor(rgba(255, 255, 255, 255));
            }
            else
            {
                console.setForegroundColor(rgba(255, 182, 172, 255));
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
    SDL2Surface _splash;

public:

    this(Console console)
    {
        super(console);
        _menu = new Menu( [
            "New game",
            "Load game",
            "View recording",
            "Quit"
        ] );

        _splash = console.loadImage("data/mainmenu.png");
    }   

    ~this()
    {
        close();
    }

    override void close()
    {
        if (_splash !is null)
        {
            _splash.close();
            _splash = null;
        }
    }

    override void draw(double dt)
    {
        void getCharStyle(int x, int y, out int charIndex, out vec4ub fgColor)
        {
            Xorshift rng;
            rng.seed(x + y * 80);
            int ij = uniform(0, 16, rng);
            int ci = (9 * 16 + 14);
            if (ij < 7)/*
            if (x % 2 == 0 && y % 2 == 0)*/ ci = (6 * 16 + 14);
            if (ij < 2)/*
            if (x % 4 == 0 && y % 4 == 0)*/ ci = (6 * 16 + 12);
            
            fgColor = rgba(0, 0, 0, 235);
            charIndex = (x < 32 /*&& y > 0 && y + 1 < 32*/) ? ci : 0;
            if (y == 0 || y == 31) 
            {
                charIndex = (6 * 16 + 14);
                fgColor = rgba(0, 0, 0, 160);
            }
        }

        _console.putImage(0, 0, _splash, &getCharStyle);

        
        _menu.draw(55, 19, _console);
    }

    override State handleKeypress(SDL_Keysym key)
    {
        // quit without confirmation
        if (key.sym == SDLK_ESCAPE)
            return null;
        else if (key.sym == SDLK_UP)
            _menu.up();
        else if (key.sym == SDLK_DOWN)
            _menu.down();
        else if (key.sym == SDLK_RETURN)
        {
            if (_menu.index() == 0) // new game
                return new StatePlay(_console, unpredictableSeed);
            else if (_menu.index() == 1) // load game
            {
            }
            else if (_menu.index() == 2) // view recording
            {
            }
            else if (_menu.index() == 3) // quit
            {
                return null;
            }
        }

        return this; // default -> do nothing
    }
}

class StatePlay : State
{
public:

    this(Console console, uint initialSeed)
    {
        super(console);
        _game = new Game(initialSeed);
        _game.message("You entered the crypt of Aliasthis");
    }    

    override void draw(double dt)
    {
        _game.draw(_console, dt);

        // TODO hud
    }

    override State handleKeypress(SDL_Keysym key)
    {
        Command[] commands;
        if (key.sym == SDLK_ESCAPE)
        {
            return new StateMainMenu(_console);
        }
        else if (key.sym == SDLK_LEFT || key.sym == SDLK_KP_4)
        {
            _game.message("You go west.");
            commands ~= Command.createMovement(Direction.WEST);
        }
        else if (key.sym == SDLK_RIGHT || key.sym == SDLK_KP_6)
        {
            _game.message("You go east.");
            commands ~= Command.createMovement(Direction.EAST);
        }
        else if (key.sym == SDLK_UP || key.sym == SDLK_KP_8)
        {
            _game.message("You go north.");
            commands ~= Command.createMovement(Direction.NORTH);
        }
        else if (key.sym == SDLK_DOWN || key.sym == SDLK_KP_2)
        {
            _game.message("You go south.");
            commands ~= Command.createMovement(Direction.SOUTH);
        }
        else if (key.sym == SDLK_KP_7)
        {
            _game.message("You go north-west.");
            commands ~= Command.createMovement(Direction.NORTH_WEST);
        }
        else if (key.sym == SDLK_KP_9)
        {
            _game.message("You go north-east.");
            commands ~= Command.createMovement(Direction.NORTH_EAST);
        }
        else if (key.sym == SDLK_KP_1)
        {
            _game.message("You go south-west.");
            commands ~= Command.createMovement(Direction.SOUTH_WEST);
        }
        else if (key.sym == SDLK_KP_3)
        {
            _game.message("You go south-east.");
            commands ~= Command.createMovement(Direction.SOUTH_EAST);
        }
        else if (key.sym == SDLK_KP_5 || key.sym == SDLK_SPACE)
        {
            _game.message("You wait a moment.");
            commands ~= Command.createWait();
        }
        else if (key.sym == SDLK_LESS)
        {
            _game.message("You go downstairs.");
            commands ~= Command.createMovement(Direction.ABOVE);
        }
        else if (key.sym == SDLK_GREATER)
        {
            _game.message("You go upstairs.");
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