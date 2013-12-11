module pzc.logger;

private {
	import std.datetime, std.stdio,	std.file, std.concurrency,
		std.path, std.variant, std.process, std.string,	std.conv;

	import core.time, core.thread;

	import pzc.pzcexception;

	//alias log_msg = Tuple!(SysTime, string, string, string, string, size_t);
	//alias log_config = Tuple!(string, string, bool, long, size_t);

}

public {

	//Simple multithreaded logging class. 
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

		void log(string severity, string message)
		{
			assert(running, "Logger needs to be running first!");
			send(writer_thread, Clock.currTime(), severity, message);
		}
		void log_simple(T...)(string fmt, T args) 
		{
			assert(running, "Logger needs to be running first!");
			send(writer_thread, Clock.currTime(), format(fmt, args));
		}

		//always enabled
		void log_error(T...)(string fmt, T args) {
			log_error_i(format(fmt, args));			
		}	

		version(enable_logging) {
			void log_debug(T...)(string fmt, T args) {
				log_debug_i(format(fmt, args));
			}
			void log_warn(T...)(string fmt, T args) {
				log_warn_i(format(fmt, args));
			}
			void log_info(T...)(string fmt, T args) {
				log_info_i(format(fmt, args));
			}	
		} else { //disable all other logging funcs
			void log_debug(T...)(string fmt, T args) {}
			void log_warn(T...)(string fmt, T args) {}
			void log_info(T...)(string fmt, T args) {}
		}

		private {
			void log_error_i(string message)
			{
				log("ERROR", message);
			}
			void log_debug_i(string message)
			{
				log("DEBUG", message);
			}
			void log_warn_i(string message)
			{
				log("WARNING", message);
			}
			void log_info_i(string message)
			{
				log("INFO", message);
			}
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

		@property string FullPathname() {	
			if(!running) { 
				return log_path ~ log_filename; 
			} else {
				return full_pathname;
			} 
		}

		@property bool isRunning() { return running; }

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
			
			//set the full pathname;
			full_pathname = log_path ~ log_filename;

			////spawn logging thread
			writer_thread = spawn(&logger_runner, full_pathname, overwrite_log, writer_sleep_interval, writer_queue_size);
			//Get okay back from thread
			receive((bool started) {
						running = started;
						if(!started) throw new PZCException("Failed to start logger thread");
					});
			
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
		string full_pathname;
		bool overwrite_log;	 //Overwrite existing log files?
		long writer_sleep_interval; //Max sleep interval for writer thread
		size_t writer_queue_size; //Max number of unlogged messages (currently anything past this is ignored)
		Tid writer_thread;
		bool running;
	}

}

//Logging thread runner
private {

	//logger thread
	void logger_runner(string log_fullpath, immutable bool owl, immutable long sleep_interval, immutable size_t queue_size) {
		TickDuration frame_start;
		bool thread_running;
		bool has_msg;
		long frame_duration;											   

		setMaxMailboxSize(thisTid, queue_size, OnCrowding.block);
		File log_fh;
		//open logging file
		try {
			log_fh = File(log_fullpath, owl ? "w" : "a");
		} catch (Exception e) {
			//cant launch thread....
			send(ownerTid, false);
			return;
		}
		thread_running = true;
		send(ownerTid, true);
		debug { writeln(thread_running); }
		while(thread_running == true) {
			frame_start = TickDuration.currSystemTick;
			//process log messages
			has_msg = true;
			while(has_msg) {
				has_msg = receiveTimeout(
							 dur!("msecs")(sleep_interval),
							 (SysTime s, string msg) { write_simple_log_message(log_fh, s, msg); },
							 (SysTime s, string sev, string msg) { write_log_message(log_fh, s, sev, msg); },
							 (bool shutdown) { if(shutdown) thread_running = false;},
							 (OwnerTerminated ot) { thread_running = false;},
							 (Variant other) { debug {writeln(other); }} //silently ignore
						);
				debug {
					//if(has_msg) writef("Got a message from parent\n");
				}
			}
			log_fh.flush();

			//sleep the thread until the next interval 
			if(thread_running == true) { //ignore sleep if we're exiting
				frame_duration = (TickDuration.currSystemTick.msecs() - frame_start.msecs()) % sleep_interval;
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

	void write_log_message(ref File logfile, SysTime time, string severity, string msg){
		assert(logfile.isOpen, "logfile is not open!");
		logfile.writef("[%s] %02d:%02d:%03d %s\n",
					severity,
					time.hour,
					time.minute,
					time.fracSec.msecs,
					msg);
	}
	void write_simple_log_message(ref File logfile, SysTime time, string msg) {
		assert(logfile.isOpen, "logfile is not open!");
		logfile.writef("%02d:%02d:%03d %s\n",
					   time.hour,
					   time.minute,
					   time.fracSec.msecs,
					   msg);
	}
}