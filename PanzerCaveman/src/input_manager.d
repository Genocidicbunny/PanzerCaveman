module pzc.input_manager;

private:
import derelict.opengl3.constants;
import derelict.glfw3.glfw3;
import gl3n.linalg;

public:

//glfw callbacks
extern(C) {
	//ignore the window param since for now we don't create any extra windows
	void key_button_glfw_cb(GLFWwindow* window, int button, int scancode, int action, int mod) {
		//ignore scancode, we dont need it for anything (I think?)
		InputManager().RecordKey(button, action, mod);
	}
	void mouse_button_glfw_cb(GLFWwindow* window, int button, int action, int mod) {
		InputManager().RecordMouseButton(button, action, mod);
	}
	void mouse_bounds_glfw_cb(GLFWwindow* window, int in_bounds) {
		InputManager().RecordMouseBounds(in_bounds);
	}
	void mouse_pos_glfw_cb(GLFWwindow* window, double xpos, double ypos) {
		InputManager().RecordMousePos(xpos, ypos);
	}
}

enum ButtonState {
	Pressed,
	Repeat,
	Released,
	Up
};

enum Key {
	Unknown			= GLFW_KEY_UNKNOWN,
    Space			= GLFW_KEY_SPACE,
    Apostrophe		= GLFW_KEY_APOSTROPHE,
    Comma			= GLFW_KEY_COMMA,
    Minus			= GLFW_KEY_MINUS,
    Period			= GLFW_KEY_PERIOD,
    Slash			= GLFW_KEY_SLASH,
    Zero			= GLFW_KEY_0,
    One				= GLFW_KEY_1,
    Two				= GLFW_KEY_2,
    Three			= GLFW_KEY_3,
    Four			= GLFW_KEY_4,
    Five			= GLFW_KEY_5,
    Six				= GLFW_KEY_6,
    Seven			= GLFW_KEY_7,
    Eight			= GLFW_KEY_8,
    Nine			= GLFW_KEY_9,
    Semicolon		= GLFW_KEY_SEMICOLON,
	Equal			= GLFW_KEY_EQUAL,
	A				= GLFW_KEY_A,
	B				= GLFW_KEY_B,
	C				= GLFW_KEY_C,
	D				= GLFW_KEY_D,
	E				= GLFW_KEY_E,
	F				= GLFW_KEY_F,
	G				= GLFW_KEY_G,
	H				= GLFW_KEY_H,
	I				= GLFW_KEY_I,
	J				= GLFW_KEY_J,
	K				= GLFW_KEY_K,
	L				= GLFW_KEY_L,
	M				= GLFW_KEY_M,
	N				= GLFW_KEY_N,
	O				= GLFW_KEY_O,
	P				= GLFW_KEY_P,
	Q				= GLFW_KEY_Q,
	R				= GLFW_KEY_R,
	S				= GLFW_KEY_S,
	T				= GLFW_KEY_T,
	U				= GLFW_KEY_U,
	V				= GLFW_KEY_V,
	W				= GLFW_KEY_W,
	X				= GLFW_KEY_X,
	Y				= GLFW_KEY_Y,
	Z				= GLFW_KEY_Z,
	LBracket		= GLFW_KEY_LEFT_BRACKET,
	Backslash		= GLFW_KEY_BACKSLASH,
	RBracket		= GLFW_KEY_RIGHT_BRACKET,
	GraveAcc		= GLFW_KEY_GRAVE_ACCENT,
	World1			= GLFW_KEY_WORLD_1,
	World2			= GLFW_KEY_WORLD_2,
	Escape			= GLFW_KEY_ESCAPE,
	Enter			= GLFW_KEY_ENTER,
	Tab				= GLFW_KEY_TAB,
	Backspace		= GLFW_KEY_BACKSPACE,
	Insert			= GLFW_KEY_INSERT,
	Del				= GLFW_KEY_DELETE,
	Right			= GLFW_KEY_RIGHT,
	Left			= GLFW_KEY_LEFT,
	Down			= GLFW_KEY_DOWN,
	Up				= GLFW_KEY_UP,
	PageUp			= GLFW_KEY_PAGE_UP,
	PageDown		= GLFW_KEY_PAGE_DOWN,
	Home			= GLFW_KEY_HOME,
	End				= GLFW_KEY_END,
	CapsLock		= GLFW_KEY_CAPS_LOCK,
	ScrollLock		= GLFW_KEY_SCROLL_LOCK,
	NumLock			= GLFW_KEY_NUM_LOCK,
	PrintScreen		= GLFW_KEY_PRINT_SCREEN,
	Pause			= GLFW_KEY_PAUSE,
	F1				= GLFW_KEY_F1,
	F2				= GLFW_KEY_F2,
	F3				= GLFW_KEY_F3,
	F4				= GLFW_KEY_F4,
	F5				= GLFW_KEY_F5,
	F6				= GLFW_KEY_F6,
	F7				= GLFW_KEY_F7,
	F8				= GLFW_KEY_F8,
	F9				= GLFW_KEY_F9,
	F10				= GLFW_KEY_F10,
	F11				= GLFW_KEY_F11,
	F12				= GLFW_KEY_F12,
	F13				= GLFW_KEY_F13,
	F14				= GLFW_KEY_F14,
	F15				= GLFW_KEY_F15,
	F16				= GLFW_KEY_F16,
	F17				= GLFW_KEY_F17,
	F18				= GLFW_KEY_F18,
	F19				= GLFW_KEY_F19,
	F20				= GLFW_KEY_F20,
	F21				= GLFW_KEY_F21,
	F22				= GLFW_KEY_F22,
	F23				= GLFW_KEY_F23,
	F24				= GLFW_KEY_F24,
	F25				= GLFW_KEY_F25,
	KP0				= GLFW_KEY_KP_0,
	KP1				= GLFW_KEY_KP_1,
	KP2				= GLFW_KEY_KP_2,
	KP3				= GLFW_KEY_KP_3,
	KP4				= GLFW_KEY_KP_4,
	KP5				= GLFW_KEY_KP_5,
	KP6				= GLFW_KEY_KP_6,
	KP7				= GLFW_KEY_KP_7,
	KP8				= GLFW_KEY_KP_8,
	KP9				= GLFW_KEY_KP_9,
	KPDecimal		= GLFW_KEY_KP_DECIMAL,
	KPDivide		= GLFW_KEY_KP_DIVIDE,
	KPMultiply		= GLFW_KEY_KP_MULTIPLY,
	KPSubtract		= GLFW_KEY_KP_SUBTRACT,
	KPAdd			= GLFW_KEY_KP_ADD,
	KPEnter			= GLFW_KEY_KP_ENTER,
	KPEqual			= GLFW_KEY_KP_EQUAL,
	LShift			= GLFW_KEY_LEFT_SHIFT,
	LCtrl			= GLFW_KEY_LEFT_CONTROL,
	LAlt			= GLFW_KEY_LEFT_ALT,
	LSuper			= GLFW_KEY_LEFT_SUPER,
	RShift			= GLFW_KEY_RIGHT_SHIFT,
	RCtrl			= GLFW_KEY_RIGHT_CONTROL,
	RAlt			= GLFW_KEY_RIGHT_ALT,
	RSuper			= GLFW_KEY_RIGHT_SUPER,
	RMenu			= GLFW_KEY_MENU
};

enum KeyMod {
	Shift = GLFW_MOD_SHIFT,
	Ctrl = GLFW_MOD_CONTROL,
	Alt = GLFW_MOD_ALT,
	Super =	GLFW_MOD_SUPER
};

enum MouseButton {
	MB1			= GLFW_MOUSE_BUTTON_1,
	MB2			= GLFW_MOUSE_BUTTON_2,
	MB3			= GLFW_MOUSE_BUTTON_3,
	MB4			= GLFW_MOUSE_BUTTON_4,
	MB5			= GLFW_MOUSE_BUTTON_5,
	MB6			= GLFW_MOUSE_BUTTON_6,
	MB7			= GLFW_MOUSE_BUTTON_7,
	MB8			= GLFW_MOUSE_BUTTON_8,
	Left		= GLFW_MOUSE_BUTTON_LEFT,
	Right		= GLFW_MOUSE_BUTTON_RIGHT,
	Middle		= GLFW_MOUSE_BUTTON_MIDDLE,
};

class InputManager {
private:
    //double-checked lock for thread-safe access of singleton
	static bool initialized;  // Thread-local
    __gshared static InputManager instance;

	//pre-initialize table of keys
	ButtonState[Key] key_state;
	ButtonState[MouseButton] mouse_state; 

	//mouse position
	vec2 mouse_position = vec2(0.0, 0.0);
	bool mouse_inbounds = true;

    this() {
		key_state = [
			Key.Unknown		: 	ButtonState.Up,
			Key.Space		: 	ButtonState.Up,
			Key.Apostrophe	: 	ButtonState.Up,
			Key.Comma		: 	ButtonState.Up,
			Key.Minus		: 	ButtonState.Up,
			Key.Period		: 	ButtonState.Up,
			Key.Slash		: 	ButtonState.Up,
			Key.Zero		: 	ButtonState.Up,
			Key.One			: 	ButtonState.Up,
			Key.Two			: 	ButtonState.Up,
			Key.Three		: 	ButtonState.Up,
			Key.Four		: 	ButtonState.Up,
			Key.Five		: 	ButtonState.Up,
			Key.Six			: 	ButtonState.Up,
			Key.Seven		: 	ButtonState.Up,
			Key.Eight		: 	ButtonState.Up,
			Key.Nine		: 	ButtonState.Up,
			Key.Semicolon	: 	ButtonState.Up,
			Key.Equal		: 	ButtonState.Up,
			Key.A			: 	ButtonState.Up,
			Key.B			: 	ButtonState.Up,
			Key.C			: 	ButtonState.Up,
			Key.D			: 	ButtonState.Up,
			Key.E			: 	ButtonState.Up,
			Key.F			: 	ButtonState.Up,
			Key.G			: 	ButtonState.Up,
			Key.H			: 	ButtonState.Up,
			Key.I			: 	ButtonState.Up,
			Key.J			: 	ButtonState.Up,
			Key.K			: 	ButtonState.Up,
			Key.L			: 	ButtonState.Up,
			Key.M			: 	ButtonState.Up,
			Key.N			: 	ButtonState.Up,
			Key.O			: 	ButtonState.Up,
			Key.P			: 	ButtonState.Up,
			Key.Q			: 	ButtonState.Up,
			Key.R			: 	ButtonState.Up,
			Key.S			: 	ButtonState.Up,
			Key.T			: 	ButtonState.Up,
			Key.U			: 	ButtonState.Up,
			Key.V			: 	ButtonState.Up,
			Key.W			: 	ButtonState.Up,
			Key.X			: 	ButtonState.Up,
			Key.Y			: 	ButtonState.Up,
			Key.Z			: 	ButtonState.Up,
			Key.LBracket	: 	ButtonState.Up,
			Key.Backslash	: 	ButtonState.Up,
			Key.RBracket	: 	ButtonState.Up,
			Key.GraveAcc	: 	ButtonState.Up,
			Key.World1		: 	ButtonState.Up,
			Key.World2		: 	ButtonState.Up,
			Key.Escape		: 	ButtonState.Up,
			Key.Enter		: 	ButtonState.Up,
			Key.Tab			: 	ButtonState.Up,
			Key.Backspace	: 	ButtonState.Up,
			Key.Insert		: 	ButtonState.Up,
			Key.Del			: 	ButtonState.Up,
			Key.Right		: 	ButtonState.Up,
			Key.Left		: 	ButtonState.Up,
			Key.Down		: 	ButtonState.Up,
			Key.Up			: 	ButtonState.Up,
			Key.PageUp		: 	ButtonState.Up,
			Key.PageDown	: 	ButtonState.Up,
			Key.Home		: 	ButtonState.Up,
			Key.End			: 	ButtonState.Up,
			Key.CapsLock	: 	ButtonState.Up,
			Key.ScrollLock	: 	ButtonState.Up,
			Key.NumLock		: 	ButtonState.Up,
			Key.PrintScreen	: 	ButtonState.Up,
			Key.Pause		: 	ButtonState.Up,
			Key.F1			: 	ButtonState.Up,
			Key.F2			: 	ButtonState.Up,
			Key.F3			: 	ButtonState.Up,
			Key.F4			: 	ButtonState.Up,
			Key.F5			: 	ButtonState.Up,
			Key.F6			: 	ButtonState.Up,
			Key.F7			: 	ButtonState.Up,
			Key.F8			: 	ButtonState.Up,
			Key.F9			: 	ButtonState.Up,
			Key.F10			: 	ButtonState.Up,
			Key.F11			: 	ButtonState.Up,
			Key.F12			: 	ButtonState.Up,
			Key.F13			: 	ButtonState.Up,
			Key.F14			: 	ButtonState.Up,
			Key.F15			: 	ButtonState.Up,
			Key.F16			: 	ButtonState.Up,
			Key.F17			: 	ButtonState.Up,
			Key.F18			: 	ButtonState.Up,
			Key.F19			: 	ButtonState.Up,
			Key.F20			: 	ButtonState.Up,
			Key.F21			: 	ButtonState.Up,
			Key.F22			: 	ButtonState.Up,
			Key.F23			: 	ButtonState.Up,
			Key.F24			: 	ButtonState.Up,
			Key.F25			: 	ButtonState.Up,
			Key.KP0			: 	ButtonState.Up,
			Key.KP1			: 	ButtonState.Up,
			Key.KP2			: 	ButtonState.Up,
			Key.KP3			: 	ButtonState.Up,
			Key.KP4			: 	ButtonState.Up,
			Key.KP5			: 	ButtonState.Up,
			Key.KP6			: 	ButtonState.Up,
			Key.KP7			: 	ButtonState.Up,
			Key.KP8			: 	ButtonState.Up,
			Key.KP9			: 	ButtonState.Up,
			Key.KPDecimal	: 	ButtonState.Up,
			Key.KPDivide	: 	ButtonState.Up,
			Key.KPMultiply	: 	ButtonState.Up,
			Key.KPSubtract	: 	ButtonState.Up,
			Key.KPAdd		: 	ButtonState.Up,
			Key.KPEnter		: 	ButtonState.Up,
			Key.KPEqual		: 	ButtonState.Up,
			Key.LShift		: 	ButtonState.Up,
			Key.LCtrl		: 	ButtonState.Up,
			Key.LAlt		: 	ButtonState.Up,
			Key.LSuper		: 	ButtonState.Up,
			Key.RShift		: 	ButtonState.Up,
			Key.RCtrl		: 	ButtonState.Up,
			Key.RAlt		: 	ButtonState.Up,
			Key.RSuper		: 	ButtonState.Up,
			Key.RMenu		: 	ButtonState.Up
		];
		mouse_state = [
			MouseButton.MB1		: ButtonState.Up,
			MouseButton.MB2		: ButtonState.Up,
			MouseButton.MB3		: ButtonState.Up,
			MouseButton.MB4		: ButtonState.Up,
			MouseButton.MB5		: ButtonState.Up,
			MouseButton.MB6		: ButtonState.Up,
			MouseButton.MB7		: ButtonState.Up,
			MouseButton.MB8		: ButtonState.Up,
			MouseButton.Left	: ButtonState.Up,
			MouseButton.Right	: ButtonState.Up,
			MouseButton.Middle	: ButtonState.Up
		];
	}

	void release_keys_up() {
		foreach(ref key ; key_state) {
			if(key == ButtonState.Released) 
				key = ButtonState.Up;
		}
	}

	void release_mouse_up() {
		foreach(ref mouse ; mouse_state) {
			if(mouse == ButtonState.Released)
				mouse = ButtonState.Up;
		}
	}

public:

	//fakes a constructor-like call
    static InputManager opCall() {
        if(initialized) {
            return instance;
        }

        synchronized(InputManager.classinfo) {
            scope(success) initialized = true;
            if(instance !is null) {
                return instance;
            }

            instance = new InputManager;
            return instance;
		}
    }

	//needs to be called before glfwPoll is called
	void Update(float dt) {
			release_keys_up();
			release_mouse_up();
	}

	void RecordMouseButton(int button, int action, int modifier) {
		//currently just ignore the modifier
		//We will assume glfw wont report GLFW_PRESS when GLFW_REPEAT is set.
		MouseButton button_cnv = to!MouseButton(button);
		if(button_cnv in mouse_state) {
			switch(action) {
				case GLFW_PRESS : {
					mouse_state[button_cnv] = ButtonState.Pressed;
					break;
				}
				case GLFW_REPEAT : {
					mouse_state[button_cnv] = ButtonState.Repeat;
					break;
				}
				case GLFW_RELEASE : {
					mouse_state[button_cnv] = ButtonState.Released;
					break;
				}
				default : break;
			}
		}
	}

	void RecordMousePos(double x_pos, double y_pos) {
		if(mouse_inbounds) {
			mouse_position = vec2(x_pos, y_pos);
		}
	}

	void RecordMouseBounds(int in_bounds) {
		if(in_bounds == GL_TRUE) {
			mouse_inbounds = true;
		} else {
			mouse_inbounds = false;
		}
	}

	void RecordKey(int key, int action, int mod) {
		//ignore unknown keys
		//currently ignore modifiers
		Key key_cnv = to!Key(key);
		if(key_cnv in key_state) {
			switch(action) { 
				case GLFW_PRESS : {
					key_state[key_cnv] = ButtonState.Pressed;
					break;
				}
				case GLFW_REPEAT : {
					key_state[key_cnv] = ButtonState.Repeat;
					break;
				}
				case GLFW_RELEASE : {
					key_state[key_cnv] = ButtonState.Released;
				}
				default : break;
			}
		}
	}

	@property bool KeyDown(Key k) { 
		assert(k in key_state, format("Invalid Key [%d] state query", to!int(k)));
		auto ks = key_state[k]; 
		if(ks == ButtonState.Pressed || ks == ButtonState.Repeat) 
			return true; 
		else 
			return false; 
	}

	@property ButtonState KeyState(Key k) {
		assert(k in key_state, format("Invalid Key [%d] state query", to!int(k)));
		return key_state[k];
	}

	@property bool MouseDown(MouseButton mb) {
		assert(mb in mouse_state, format("Invalid MouseButton [%d] state query", to!int(mb)));
		auto ms = mouse_state[mb];
		if(ms == ButtonState.Pressed || ms == ButtonState.Repeat) 
			return true;
		else
			return false;
	}
	@property ButtonState MouseState(MouseButton mb) {
		assert(mb in mouse_state, format("Invalid MouseButton [%d] state query", to!int(mb)));
		return mouse_state[mb];
	}
	@property vec2 MousePosition() { return mouse_position; }

}