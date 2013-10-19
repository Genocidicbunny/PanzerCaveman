/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.util;

import awesomium.capi, awesomium.webview, awesomium.webcore;

@disable package @property cString toWebString(string str)
{
	return cString(str.length, cast(char*)str.ptr);
}

package @property cString toCString(string str)
{
	cString cs;

	cs.len = str.length;
	cs.str = cast(char*)str.ptr;

	return cs;
}

package @property cWebPrefs toCWebPrefs(WebPreferences wp)
{
	cWebPrefs cw;

	cw.accept_charset = wp.accept_charset.toCString;
	cw.accept_language = wp.accept_language.toCString;


	cw.default_encoding = wp.default_encoding.toCString;
	cw.proxy_config = wp.proxy_config.toCString;
	cw.user_stylesheet = wp.user_stylesheet.toCString;

	cw.allow_file_access_from_file_url = wp.allow_file_access_from_file_url;
	cw.allow_running_insecure_content = wp.allow_file_access_from_file_url;
	cw.allow_scripts_to_access_clipboard = wp.allow_file_access_from_file_url;
	cw.allow_scripts_to_close_windows = wp.allow_file_access_from_file_url;
	cw.allow_scripts_to_open_windows = wp.allow_file_access_from_file_url;
	cw.allow_universal_access_from_file_url = wp.allow_file_access_from_file_url;

	cw.enable_app_cache = wp.allow_file_access_from_file_url;
	cw.enable_dart = wp.allow_file_access_from_file_url;
	cw.enable_databases = wp.allow_file_access_from_file_url;
	cw.enable_gpu_acceleration = wp.allow_file_access_from_file_url;
	cw.enable_javascript = wp.allow_file_access_from_file_url;
	cw.enable_local_storage = wp.allow_file_access_from_file_url;
	cw.enable_plugins = wp.allow_file_access_from_file_url;
	cw.enable_remote_fonts = wp.allow_file_access_from_file_url;
	cw.enable_smooth_scrolling = wp.allow_file_access_from_file_url;
	cw.enable_web_audio = wp.allow_file_access_from_file_url;
	cw.enable_web_gl = wp.allow_file_access_from_file_url;
	cw.enable_web_security = wp.allow_file_access_from_file_url;

	cw.load_images_automatically = wp.allow_file_access_from_file_url;

	cw.shrink_standalone_images_to_fit = wp.allow_file_access_from_file_url;

	return cw;
}


package cStringArray toCStringArray(string[] args)
{
	cStringArray temp;

	if ( args is null )
		return temp;

	cString[] arr;

	arr.length=args.length+1;

	for( int i ; i < arr.length; ++i ) {
		arr[i] = args[i].toCString;
	}

	temp.ptr = cast(cString**)arr.ptr;

	return temp;
}

package @property cWebConf toCWebConf(WebConfig wc)
{
	cWebConf cw;

	cw.child_process_path = wc.child_process_path.toCString;
	cw.debug_port = wc.remote_debugging_port;
	cw.log_level = wc.log_level;
	cw.log_path = wc.log_path.toCString;
	cw.package_path = wc.package_path.toCString;
	cw.plugin_path = wc.plugin_path.toCString;
	cw.user_agent = wc.user_agent.toCString;

	cw.addOptNum = wc.additional_options.length;
	cw.additional_options = toCStringArray(wc.additional_options);

	return cw;
}