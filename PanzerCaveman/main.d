module main;

import std.stdio;
import derelict.util.exception;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.assimp3.assimp;
import derelict.lua.lua;
import derelict.freeimage.freeimage;
import awesomium.dapi;

int main(string[] argv)
{
	try{
		DerelictSDL2.load();
		DerelictGL3.load();
		DerelictASSIMP3.load();
		DerelictLua.load();
		DerelictFI.load();
	}catch (DerelictException de)
	{
		writeln("failed to load lib %s", de.msg);
		return -2;
	}

	if(SDL_Init(SDL_INIT_EVERYTHING) == -1)
	{
		writeln("SDL failed to init");
		return -1;
	}

	return 0;
}


