module pzc.logger;

private {
	import std.datetime, std.stdio,	std.file, std.concurrency,
		std.path, std.variant, std.process, std.string,	std.conv;

	import core.time, core.thread;

	//alias log_msg = Tuple!(SysTime, string, string, string, string, size_t);
	//alias log_config = Tuple!(string, string, bool, long, size_t);

}

public {

	class Logger {
	public:
		this(string filename = null, string log_path = "./", bool overwrite_log = false, long writer_sleep = 500, size_t queue_size = 1024)
		{
			//info = logger_info(filename, path, overwrite_log, writer_sleep, queue_size);
			this.log_filename = filename;
			this.log_path = log_path;
			this.overwrite_log = overwrite_log;
			this.writer_sleep_interval = writer_sleep;
			this.writer_queue_size = queue_size;
		}
		~this() {
			stop();
		}

		void run() {
			if(!running) run_logger_thread();
		}

		void stop() {
			if(running) shutdown_logger();
		}

		void restart() {
			stop();
			run();
		}

		void log(string severity, string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__)
		{
			assert(running, "Logger needs to be running first!");
			send(writer_thread, Clock.currTime(), severity, message, file, func, line);
		}

		void log_error(string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__)
		{
			log("ERROR", message, file, func, line);
		}

		version(enable_logging) {
			void log_debug(string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__)
			{
				log("DEBUG", message, file, func, line);
			}
			void log_debug(string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__)
			{
				log("WARNING", message, file, func, line);
			}
			void log_info(string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__)
			{
				log("INFO", message, file, func, line);
			}
		} else { //disable all other logging funcs
			void log_debug(string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__) {}
			void log_warn(string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__) {}
			void log_info(string message, string file = __FILE__, string func = __FUNCTION__, size_t line = __LINE__) {}
		}


		@property string Filename() { return log_filename; }
		@property string Filename(string fn) { return log_filename = fn; }

		@property string Path() { return log_path; }
		@property string Path(string path) { return log_path = path; }

		@property bool OverwriteLog() { return overwrite_log; }
		@property bool OverwriteLog(bool owl) { return overwrite_log = owl; }

		@property long WriterSleepInterval() { return writer_sleep_interval; }
		@property long WriterSleepInterval(long interval) { return writer_sleep_interval = interval; }

		@property size_t LogQueueSize() { return writer_queue_size; }
		@property size_t LogQueueSize(size_t lqs) { return writer_queue_size = lqs; }

	private:
		void run_logger_thread() {

			if(log_filename == null) {
				log_filename = Clock.currTime().toISOString() ~ to!string(thisProcessID()) ~ ".log";
			}
			//} else {
			//    log_filename = Clock.currTime().toISOString() ~ log_filename;
			//}
			//check that dir exists
			if(!exists(log_path)) {
				try {
					mkdir(log_path);
				} catch(FileException e) {
					//couldn't make the dir, use current dir
					writef("Couldn't make log path %s", log_path);
					log_path = ".";
				}
			}

			////spawn logging thread
			writer_thread = spawn(&logger_runner, log_path ~ log_filename, overwrite_log, writer_sleep_interval, writer_queue_size);
			running = true;
			//send(writer_thread, tuple(log_path, log_filename, overwrite_log, writer_sleep_interval, writer_queue_size));
		}
		void shutdown_logger() {
			writeln("Shutting down logger thread");
			send(writer_thread, true);
			receive( (bool shutdown_result) { /*do nothing but still need to get this message*/});
			running = false;
			writeln("Thread shut down");
		}
	private:
		string log_filename;
		string log_path;
		bool overwrite_log;	 //Overwrite existing log files?
		long writer_sleep_interval; //Max sleep interval for writer thread
		size_t writer_queue_size; //Max number of unlogged messages (currently anything past this is ignored)
		Tid writer_thread;
		bool running;
	}

} 
private {

	//logger thread
	void logger_runner(string log_fullpath, immutable bool owl, immutable long sleep_interval, immutable size_t queue_size) {
		TickDuration frame_start;
		bool thread_running = true;
		bool has_msg = true;
		long frame_duration;											   

		setMaxMailboxSize(thisTid, queue_size, OnCrowding.block);
		File log_fh;
		//open logging file
		try {
			log_fh = File(log_fullpath, owl ? "a" : "w");
		} catch (Exception e) {
			//cant launch thread....
			return;
		}

		while(thread_running) {
			frame_start = TickDuration.currSystemTick;
			//process log messages
			has_msg = true;
			while(has_msg && thread_running) {
				has_msg = receiveTimeout(
							 dur!("msecs")(sleep_interval),
							 (SysTime s, string sev, string msg, string fl, string fn, size_t ln) { write_log_message(log_fh, s, sev, msg, fl ~":" ~ fn ~":" ~ to!string(ln)); },
							 delegate (bool shutdown) { if(shutdown) thread_running = false;},
							 (OwnerTerminated ot) { thread_running = false;},
							 (Variant other) { debug {writeln(other); }} //silently ignore
						);
				debug {
					//if(has_msg) writef("Got a message from parent\n");
				}
			}
			writeln("Flushing log file");
			log_fh.flush();

			//sleep the thread until the next interval 
			if(thread_running) { //ignore sleep if we're exiting
				frame_duration = (TickDuration.currSystemTick.msecs() - frame_start.msecs()) % sleep_interval;
				writef("Sleep duration %d", sleep_interval - frame_duration);
				Thread.sleep(dur!("msecs")(sleep_interval - frame_duration));
			}
		}

		writeln("flushing log before close");
		if(log_fh.isOpen) {
			log_fh.flush();
			log_fh.close();
		}
		//send true and close
		send(ownerTid, true);
		return;
	};

	void write_log_message(ref File logfile, SysTime time, string severity, string msg, string debug_inf){
		assert(logfile.isOpen, "logfile is not open!");
		logfile.writef("[%s] %02d:%02d:%03d %s [%s]\n",
					severity,
					time.hour,
					time.minute,
					time.fracSec.msecs,
					msg,
					debug_inf);
	}
}