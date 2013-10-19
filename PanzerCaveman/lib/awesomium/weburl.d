/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.weburl;

import awesomium.capi, awesomium.util,
	awesomium.webstring;

/// alias to match C++ Awesomium::WebURL name
alias WebUrl WebURL;

///
/// @brief  This class represents a parsed URL. It provides convenience methods
///         to access parsed details of the url.
///
class WebUrl
{
public:
	///
	/// Create an empty WebURL.
	///
	this() 
	{
		_internal = aws_weburl_new();
	}

	///
	/// Create a WebURL from a string.
	///
	/// @param  url_string  A properly-formatted URL string. For example,
	///                     http://www.google.com is valid, www.google.com is not
	///
	this(string url_string)
	{
		_internal = aws_weburl_new_webstring(new WebString(url_string));
	}


	/// Whether or not this URL is valid (was parsed successfully).
	bool IsValid()
	{
		return aws_weburl_isValid(this);
	}

	/// Whether or not this URL is empty.
	bool IsEmpty()
	{
		return aws_weburl_isEmpty(this);
	}

	/// The actual URL string.
	string spec()
	{
		return fromWebString(aws_weburl_getSpec(this));
	}

	/// The parsed scheme (ex, 'http')
	string scheme()
	{
		return fromWebString(aws_weburl_getScheme(this));
	}

	/// The parsed username (if any)
	string username()
	{
		return fromWebString(aws_weburl_getUsername(this));
	}

	/// The parsed password (if any)
	string password()
	{
		return fromWebString(aws_weburl_getPassword(this));
	}

	/// The parsed hostname, IPv4 Address, or IPv6 Address
	string host()
	{
		return fromWebString(aws_weburl_getHost(this));
	}

	/// The parsed port (if any)
	string port()
	{
		return fromWebString(aws_weburl_getPort(this));
	}

	/// The parsed path
	string path()
	{
		return fromWebString(aws_weburl_getPath(this));
	}

	/// The parsed query portion (anything following '?')
	string query()
	{
		return fromWebString(aws_weburl_getQuery(this));
	}

	/// The parsed anchor portion (anything following '#')
	string anchor()
	{
		return fromWebString(aws_weburl_getAnchor(this));
	}

	/// The filename of the path (if any)
	string filename()
	{
		return fromWebString(aws_weburl_getFilename(this));
	}

package:
	alias _internal this;
	cWebUrlPtr_t _internal;
	bool _owner = true;

	/// reference constructor to already exising object
	this(cWebUrlPtr_t other)
	{
		_internal = other;
		_owner = false;
	}
}