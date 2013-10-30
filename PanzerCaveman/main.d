import pzc.logger;
import std.conv;
import std.stdio;

int main(string[] argv)
{
	Logger testLogger1 = new Logger("tl.log", "./");
	Logger testLogger2 = new Logger("testlog.log", "./logs/");

	testLogger1.run();
	testLogger2.run();
	for(int i = 0; i < 100000; ++i) {
		testLogger1.log_error("Testing logger 1 " ~ to!string(i));
		testLogger2.log_error("Testing logger 2 " ~	to!string(i));
	}
	testLogger1.stop();
	testLogger2.stop();
	writeln("Loggers stopped");
	return 0;
}






