/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.websession;

import awesomium.capi;

class WebSession
{
public:

	~this()
	{
		if ( _owner )
			aws_websession_release(this);

		_internal = null;
		_owner = false;
	}

package:
	alias _internal this;
	cWebSessionPtr_t _internal;

	///
	/// indicates whether current object is actual reference owner, 
	/// in this case it should clean on delete.
	bool _owner = true;
}