/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.inputevt;

import awesomium.capi;

enum MouseButton 
{
	LEFT = 0,
	MIDDLE,
	RIGHT,
}


struct WebKeyboardEvent
{
	static WebKeyboardEvent fromKeyCode(int code, int scancode, int modifiers, int type, char text)
	{
		auto evt = WebKeyboardEvent();
		
		evt._internal = aws_keyboardevent_from_keycode(code, scancode, modifiers, type, text);

		if ( evt._internal !is null )
			evt._owner = true;

		return evt;
	}

	cKeyEventData getData()
	{
		return aws_keyboardevent_get_data(_internal);
	}

	void setData(cKeyEventData data)
	{
		aws_keyboardevent_set_data(_internal, data);
	}

package:
	cKeyboardEvtPtr_t _internal;
	bool _owner = false;
}




struct WebTouchEvent
{
}