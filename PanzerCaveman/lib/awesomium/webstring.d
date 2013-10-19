/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.webstring;

import awesomium.capi, awesomium.util;


string fromWebString(cWebStringPtr_t wstr)
{
	char[] str;
	auto len = aws_webstring_to_utf8(wstr, null, 0);
	if ( len > 0 )
	{
		str.length = len;
		aws_webstring_to_utf8(wstr, str.ptr, len);
		return str.idup;
	}
	return string.init;
}


final class WebString
{
public:
	/// new empty string
	this()
	{
		_owner = true;
		_internal = aws_webstring_new();
	}

	/// new string from utf8 data
	this(string str)
	{
		_owner = true;
		_internal = aws_webstring_new_utf8(str.ptr, str.length);
	}

	/// new string from substring
	this(WebString other, uint start, uint len)
	{
		_owner = true;
		_internal = aws_webstring_new_substring(other, start, len);
	}

	/// cast webstring to D string
	string opCast(T)() if (is(T == string)) 
	{
		return fromWebString(this);
	}
	
	~this()
	{
		if ( _internal && _owner )
			aws_webstring_delete(this);
		_internal = null;
	}

package:
	this(cWebStringPtr_t other)
	{
		_internal = other;
	}

	// c++ copy constructor
	this(const(cWebStringPtr_t) other)
	{
		_internal = aws_webstring_new_webstring(cast(cWebStringPtr_t)other);
		_owner = true;
	}

package:
	alias _internal this;
	cWebStringPtr_t _internal;
	bool _owner = false;
}