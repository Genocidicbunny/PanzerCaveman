module main;

import std.stdio;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.assimp3.assimp;
import derelict.lua.lua;
import derelict.devil.il;
import awesomium.dapi;

int main(string[] argv)
{
	DerelictSDL2.load();
	DerelictGL3.load();
	DerelictASSIMP3.load();
	DerelictLua.load();
	DerelictIL.load();

   writeln("Hello D-World!");
   return 0;
}
