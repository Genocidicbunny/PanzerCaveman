module pzc.game;


private:
import std.stdio;
import std.string;
import std.datetime;
import derelict.util.exception;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.assimp3.assimp;
import derelict.lua.lua;
import soild.soild;
import awesomium.dapi;
import pzc.logger;
import pzc.pzcexception;

debug {
	version = enable_logging;
}

public:

class Game 
{
	private:
		GLFWvidmode window_info;
		GLFWwindow *window;
		Logger logger;



	public:
		@property string GameName() { return "Panzer Caveman"; }
		@property ref Logger GameLogger() { return logger; }

	this() {
		logger = new Logger("panzer_caveman.log", "./logs/");		
	}
	~this() {

	}

	void initialize() {
		logger.run();
		try {
			SysTime cur_time = Clock.currTime();
			logger.log_simple("Starting new session %2d-%02d-%4d", cur_time.month, cur_time.day, cur_time.year);
		} catch(Exception e) {
			logger.log_error("Clock.currTime(): \n%s", e);
		}

		//Load and initialize derelict libs
		logger.log_info("Loading Derelict");
		try {
			DerelictGL3.load();
			DerelictGLFW3.load();
			DerelictASSIMP3.load();
			DerelictLua.load();
		} catch(Exception e) {
			logger.log_error("Failed to load Derelict libs (%s)", e);
			logger.stop();
			throw new PZCException(format("Loading Exception. See %s for more info", logger.Path ~ logger.Filename));
		}
		logger.log_info("Load Derelict: Done");
	}
	
	void shutdown() {
	   if(logger.isRunning) {
			logger.stop();
	   }
	}

}
