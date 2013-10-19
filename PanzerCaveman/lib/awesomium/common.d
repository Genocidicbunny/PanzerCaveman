/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.common;


import awesomium.capi;

/// Represents a generic error.
enum Error {
	None = 0,        ///< No error (everything is cool!)
	BadParameters,   ///< Bad parameters were supplied.
	ObjectGone,      ///< The object no longer exists.
	ConnectionGone,  ///< The IPC connection no longest exists.
	TimedOut,        ///< The operation timed out.
	WebViewGone,     ///< The WebView no longer exists.
	Generic,         ///< A generic error was encountered.
}

/// Represents a generic rectangle with pixel dimensions
struct Rect 
{
	/// The x-coordinate of the origin of the rectangle
	int x;

	/// The y-coordinate of the origin of the rectangle
	int y;

	/// The width of the rectangle
	int width;

	/// The height of the rectangle
	int height;

	/// Create a Rect with certain dimensions
	this(int x, int y, int width, int height)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	this(cRect rect)
	{
		this(rect.x, rect.y,
			 rect.width, rect.height);
	}

	/// Check whether or not this Rect is empty (width and height == 0)
	@property bool IsEmpty()
	{
		return (width == 0 && height == 0);
	}
}