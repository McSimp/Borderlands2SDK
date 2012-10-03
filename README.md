Borderlands 2 Mod SDK
=====================

Claptrap can go die in a fire.

Compiling
---------

To compile the SDK you'll need the following:

* Microsoft Visual Studio 2012 (2010 probably works too, haven't tested)
* Microsoft Detours library. If you don't have it, you can get it from the downloads page and put the contents in `build/BL2SDKDLL`

Just open up the solution file in the build folder and compile in Debug mode. Hopefully it compiles,
you're pretty lucky if it does.

Running
-------

Running the SDK at the moment is a bit involved, but I'll make a launcher for it at some point which will
make the whole process a bit easier. 

### Binding a console key

Before you do anything, I suggest binding a key to the in-game console. 
Browse to `%USERPROFILE%\Documents\My Games\Borderlands 2\WillowGame\Config\` and open up `WillowInput.ini`.
You'll then want to search for `ConsoleKey=` and change that line to `ConsoleKey=Tilde` (or whatever key you want).

### Injecting the DLL

After you've compiled the SDK you'll have a DLL called "BL2SDKDLL.dll" somewhere in bin/Debug. You'll now need to
launch your game and use a DLL injector to inject it into the process. I've uploaded Winject to the Downloads page,
so use that if you don't have your own.

### Profit

After it's injected into the game, you'll have a Windows console open up and if you press your in-game console key,
you should be able to see some various messages in that console too.

