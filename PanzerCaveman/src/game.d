module pzc.game;


private:
import std.stdio, std.string, std.datetime, std.conv, std.exception, std.math,
	core.thread;

import derelict.util.exception;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.assimp3.assimp;
import derelict.lua.lua;
import derelict.physfs.physfs;
import soild.soild;
import awesomium.dapi;
import dchip.all;

import pzc.math;
import pzc.logger;
import pzc.pzcexception;
import pzc.input_manager;

extern(C) void glfw_error_reporter(int err, const(char)* msg) {
    Logger logger = Game.CurrentGame.GameLogger;
    logger.log_error("GLFW Error (%d): %s", err, to!string(msg));
};

public:

class Timer
{
	public:
		
		this(double initial_dt = 0.0)  { 
			last_tick = initial_dt;
			accumulated_time = 0.0 + initial_dt;
			running = false;
		}

		void start() {
			assert(!running, "Timer already running");
			glfwSetTime(0.0);
			last_pulse_time = glfwGetTime();
			running = true;
		}
		void tick() {
			assert(running, "Cannot tick(). Timer not running");
			auto current_pulse_time = glfwGetTime();
			last_tick = current_pulse_time - last_pulse_time;
			last_pulse_time = current_pulse_time;
			accumulated_time += last_tick;
			//glfwSetTime(0.0);
		}
		void stop() {
			assert(running, "Timer not running");
			last_tick = 0.0;
			running = false;
		}

		@property double dt() { return last_tick; }
		@property double total() { return accumulated_time; }

	private:

		bool running;
		double accumulated_time;	
		double last_tick;
		double last_pulse_time;
}

class FrameTimer : Timer {
	public:

	this(double initial_dt = 0.0, uint target_fps = 60) {
		super(initial_dt);
		last_fps = target_fps;
		target_frame_time = 1.0/target_fps;
		ema_accumulator = initial_dt;;
	}

	void update_fps() {
		tick();
		ema_accumulator = (alpha_const * dt) + (1.0 - alpha_const) * ema_accumulator;
		last_fps = to!long(floor(1.0/ema_accumulator));

	}

	@property double alpha() { return alpha_const; }
	@property double alpha(double n_alpha) { return alpha_const = n_alpha; }

	@property long FPS() { return last_fps; }
	@property double TPS() { return ema_accumulator; }
	@property double TargetTime() { return target_frame_time; }

	private:

	double alpha_const = .12;
	double ema_accumulator = 0.0;
	long last_fps;
	const double target_frame_time;
}

class Game 
{
	public:
		@property string GameName() { return "Panzer Caveman"; }
		@property Logger GameLogger() { return logger; }
		@property InputManager GameInput() { return input; }
		@property FrameTimer GameTimer() { return main_timer; }
		
		@property vec2 ScreenDimensions() { 
			return vec2(screen_info.width, screen_info.height);
		}
		@property int ScreenWidth() {
			return screen_info.width;
		}
		@property int ScreenHeight() {
			return screen_info.height;
		}

		@property static ref Game CurrentGame() { assert(curr_game !is null); return curr_game; }

	this() {
		logger = new Logger("panzer_caveman.log", "./logs/");
		input = InputManager();
		main_timer = new FrameTimer(.016, 60); //we're shooting for .016s per frame (60fps)
	}
	~this() {

	}

	void initialize() {
		logger.run();
		try {
			SysTime cur_time = Clock.currTime();
			logger.log_simple("Starting new session %2d-%02d-%4d", cur_time.month, cur_time.day, cur_time.year);
		} catch(Exception e) {
			logger.log_error("Starting new Session (Failed to get current time: %s\n)", e);
		}

		curr_game = this;

		//Load and initialize derelict libs
		logger.log_info("Loading Derelict");
		try {
			DerelictGL3.load();
			DerelictGLFW3.load();
			DerelictASSIMP3.load();
			DerelictLua.load();
			DerelictPHYSFS.load();
		} catch(Exception e) {
			logger.log_error("Failed to load Derelict libs (%s)", e);
			throw new PZCException(format("Loading Exception. See %s for more info", logger.FullPathname));
		}
		logger.log_info("Loading Derelict: Done");

		//Attempt to initialize GLFW3 and get a GL context
		logger.log_info("Initializing GLFW");
		glfwSetErrorCallback(&glfw_error_reporter);
		enforce(glfwInit(), new PZCException(format("Loading Exception. See %s for more info", logger.FullPathname)));
		logger.log_info("Initializing GLFW: Done");

		logger.log_info("Getting monitor info");
		enforce(setup_monitor(), new PZCException("Failed to get monitor information"));

		logger.log_info("Creating Window");
		enforce(create_window("Panzer Caveman", ScreenWidth, ScreenHeight), new PZCException("Window creation failed"));
		
		logger.log_info("Connecting input");
		enforce(connect_input_mgr(), new PZCException("Failed to initialize input"));

		//Awesomium initialization
		auto web_config = WebConfig();
		web_config.log_level = WebConfig.LogLevel.NORMAL;
		web_config.log_path = logger.Path ~ "awesomium.log";
		web_config.remote_debugging_port = 5678;
		debug {
			web_config.log_level = WebConfig.LogLevel.VERBOSE;
		}
		WebCore.Initialize(web_config);
  	}
	
	void shutdown() {
		close_window();

		//Shut down glfw
		logger.log_info("Terminating GLFW");
		glfwTerminate();

		if(logger.isRunning) {
			logger.log_simple("=========================");
			logger.stop();
		}
	}

	void run() {
		assert(window !is null, "Cannot run before initializing.");

		double frame_accumulator = 0.0;
		double t = 0.0;

		logger.log_info("Starting %s", GameName);
		main_timer.start();
		while(!glfwWindowShouldClose(window)) {
			main_timer.update_fps();
			frame_accumulator += main_timer.dt;
			
			input.Update(main_timer.dt);
			glfwPollEvents();

			while(frame_accumulator > main_timer.TargetTime) {
				//do game updates here


				t += main_timer.TargetTime;
				frame_accumulator -= main_timer.TargetTime;
				version(HeartbeatMainLoop) {
					logger.log_info("Main Loop Pulse T=%f", main_timer.total);
					logger.log_info("Average Frame Time (Actual) : %.5f (FPS) : %05d", main_timer.TPS, main_timer.FPS);
				}
			}

			auto state_alpha = frame_accumulator / main_timer.dt;

			//render here

			glfwSwapBuffers(window);

			version(SleepMainLoop) {
				core.thread.Thread.sleep(dur!"msecs"(0));
			}

			
		}
		main_timer.stop();
	}

	private:

	bool setup_monitor() {
		assert(monitor is null, "Monitor already setup");
		monitor = glfwGetPrimaryMonitor();
		assert(monitor !is null, "Failed to get monitor info");
		auto vidmode = glfwGetVideoMode(monitor);
		assert(vidmode !is null, "Failed to get video mode");
		screen_info = ScreenInfo(vidmode.width, vidmode.height);
		return true;
	}

	bool create_window(string title, size_t width, size_t height, bool fullscreen = false) {
		//Set up window hints
		glfwWindowHint(GLFW_DECORATED, GL_FALSE);
		glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
		//opengl hints
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
		debug(rendering) {
			glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
		}
		//create the window
		window = glfwCreateWindow(width, height, title.ptr, fullscreen ? glfwGetPrimaryMonitor() : null, null);
		if(!window) {
			logger.log_error("Failed to create a new window");
			return false;
		}
		logger.log_info("Window \"%s\" Created", title);
		//check the opengl version
		auto major_v = glfwGetWindowAttrib(window, GLFW_CONTEXT_VERSION_MAJOR);
		auto minor_v = glfwGetWindowAttrib(window, GLFW_CONTEXT_VERSION_MINOR);

		if(major_v < 3 || (major_v == 3 && minor_v < 2)) {
			//version too low
			logger.log_error("Could not initialize OpengGL 3.2 or higher context");
			glfwDestroyWindow(window);
			window = null;
			return false;
		}
		glfwMakeContextCurrent(window);

		glfwSwapInterval(0);

		logger.log_info("OpenGL %d.%d Context created", major_v, minor_v);

		return true;
	}

	void close_window() {
		if(window !is null) {
			//detach context if this windows is the current one
			if(glfwGetCurrentContext() == window) {
				glfwMakeContextCurrent(null); 
			}
			glfwDestroyWindow(window);
			window = null;
		}
	}

	bool connect_input_mgr() {
		assert(window !is null, "No window to connect to input manager");
		auto kbres = glfwSetKeyCallback(window, &key_button_glfw_cb);
		auto mbres = glfwSetMouseButtonCallback(window, &mouse_button_glfw_cb);
		auto mbdres = glfwSetCursorEnterCallback(window, &mouse_bounds_glfw_cb);
		auto mpres = glfwSetCursorPosCallback(window, &mouse_pos_glfw_cb);

		assert(kbres is null, "key callback wasn't null");
		assert(mbres is null, "mb callback wasn't null");
		assert(mbdres is null, "mbd callback wasn't null");
		assert(mpres is null, "mp callback wasn't null");

		//maybe will do more here later
		return true;
	}


	private:

		struct ScreenInfo {
			int width = 0;
			int height = 0;
		}
		ScreenInfo screen_info;

		GLFWmonitor *monitor = null;
		GLFWwindow *window = null;
		Logger logger;
		InputManager input;
		FrameTimer main_timer;
		WebCore web_core;

		static Game curr_game;

}




