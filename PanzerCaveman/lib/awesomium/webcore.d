/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.webcore;

import awesomium.capi, awesomium.util, 
	awesomium.webview, awesomium.websession,
	awesomium.webstring;

class WebCore
{
public:
	static WebCore Initialize(WebConfig conf = WebConfig.init) 
	{
		if  ( !_instance ) {
			_instance = new WebCore();
			_internal = cast(cWebCorePtr_t) aws_webcore_init(conf.toCWebConf);
		}

		return _instance;
	}

	static void Shutdown()
	{
		aws_webcore_shutdown();

		_internal = null;
		delete _instance;
	}

	WebSession CreateWebSession(string path, WebPreferences prefs = WebPreferences.init)
	{
		auto ses = new WebSession();
		ses._internal = aws_webcore_createWebSession( this, new WebString(path), prefs.toCWebPrefs );
		return ses;
	}

	WebView CreateWebView(int width, int height,
						  WebSession session = null,
						  WebViewType type = WebViewType.OFFSCREEN)
	{
		cWebSessionPtr_t ses;

		if  ( session is null )
			ses = null;
		else
			ses = session._internal;

		auto view = new WebView( aws_webcore_createWebView( this, width, height, ses, type ) );
		return view;
	}
	
	static @property instance()
	{
		return _instance;
	}

	void Update()
	{
		aws_webcore_update(this);
	}

	string version_string()
	{
		auto buf = aws_webcore_versionString(this);
		auto len = strlen(buf);

		char[] tmp;
		tmp.length = len;
		tmp = cast(char[])buf[0..len];

		string ver = tmp.idup;
		return ver;
	}

package:
	alias _internal this;
	this() {}; // better to disable it?

	static cWebCorePtr_t _internal;
	static WebCore _instance;
}



struct WebConfig {

	enum LogLevel {
		NONE = 0,  ///< No log is created
		NORMAL,    ///< Logs only errors
		VERBOSE,   ///< Logs everything
	}

	///
	/// The level of verbosity for the logger.
	///
	LogLevel log_level = LogLevel.NONE;

	///
	/// The directory path that contains the Awesomium package. Will be used to
	/// resolve all other paths. The working directory is used by default.
	///
	string package_path;

	///
	/// The directory path to search for additional plugins. This is useful for
	/// bundling plugins with your application.
	///
	string plugin_path;

	///
	/// The file path to the log file (should include filename, for example:
	/// `C:\\my_path\\out.log`). This is `./awesomium.log` by default.
	///
	string log_path = "./awesomium.log";

	///
	/// The file path to the child process. This is `./awesomium_process.exe`
	/// by default.
	///
	
	// note to self: works fine on windows, having problem on mac due to symlink in framework,
	// need to workaround or add symlink to symlink in framework.
version(Windows)
	string child_process_path = "./awesomium_process.exe";
else
	string child_process_path = "./awesomium_process";

	///
	/// The user-agent string to use instead of the default. You should only
	/// specify this if you want to spoof the user-agent.
	///
	string user_agent;

	///
	/// The port that the Awesomium Inspector's HTTP server should listen on.
	///
	/// To enable the inspector, set this value to any non-zero port (ex, 1337)
	/// and then go to http://127.0.0.1:1337 (or whatever port you specified)
	/// in some other browser.
	///
	/// Please note you must have `inspector.pak` in your working directory
	/// for the Inspector to load correctly.
	///
	/// Specify 0 to disable the inspector (the default).
	///
	int remote_debugging_port;

	///
	/// Additional command-line options for Chromium (this is for advanced users
	/// only, use these at your own risk).
	///
	/// @see https://gist.github.com/2999122 for a list of compatible options.
	///
	/// @note 
	///   Each option should be formatted as "--switch=value" or just "--switch"
	///
	///   For example: `"--use-gl=desktop"` to force native WebGL rendering.
	///
	string[] additional_options;
}