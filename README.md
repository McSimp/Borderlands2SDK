Borderlands 2 Mod SDK
=====================

Claptrap can go die in a fire.

Compiling
---------

To compile the SDK you'll need the following:

* Microsoft Visual Studio 2012 (2010 will work if you change the platform toolset and the version in the SLN file)
* Windows SDK (I'm currently using 8.0)
* DirectX SDK ([Download Link](https://www.microsoft.com/en-au/download/details.aspx?id=6812))

Just open up the solution file in the build folder and compile in Debug mode. Hopefully it compiles, you're pretty lucky if it does.

Running
-------

Running the SDK at the moment is still a little bit involed, and will not work correctly with the Steam version. I'll be improving the launcher to make things a bit easier. 

### Compiling and setting up

To compile, open the solution and build it as you normally would. After you've done that, copy the `lua` folder in the root directory of the repository into the `build\Debug` or `build\Release` directory.

### Launching Borderlands 2 with the SDK

After you've compiled the SDK, just open up `bin\Debug\Launcher.exe`, make sure it has the right location for `Borderlands2.exe` and click 'Launch Game'.

### Profit

After it's injected into the game, you'll have a Windows console open up and if you press your in-game console key, you should be able to see some various messages in that console too.

Resources
---------

Here are some useful resources.

* [Unreal Developer Network](http://udn.epicgames.com)
* [UDK Console Commands](http://udn.epicgames.com/Three/ConsoleCommands.html)
* [Luai Reference](http://pgl.yoyo.org/luai/i/_)