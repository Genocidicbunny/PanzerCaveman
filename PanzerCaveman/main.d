import pzc.game;
import std.conv;
import std.stdio;

int main(string[] argv)
{
	try{
		auto pzc_game = new Game();
		pzc_game.initialize();
		pzc_game.run();
		pzc_game.shutdown();
	} catch(Exception e) {
		writeln(e);
	}
	
	return 0;
}






