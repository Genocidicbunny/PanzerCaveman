/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.capi;

private import core.stdc.stdlib;

extern(C):

/// awesomium int64
alias long aint64;

version(Windows) import std.c.windows.windows;

struct cString
{
	uint len;
	char* str;

	/*
	// need to find way to not release active buffer
	~this()
	{
		if ( len )
			free(str);
	}
	*/
}

struct cRect
{
	int x, y, width, height;
}

struct cStringArray
{
	cString** ptr;
	uint size;
}

struct cWebConf
{
	int log_level;
	int debug_port;
	uint addOptNum;

	cString user_agent;
	cString plugin_path;
	cString child_process_path;
	cString log_path;
	cString package_path;

	cStringArray additional_options;
}

struct cWebPrefs
{
	cString accept_charset;
	cString accept_language;

	cString default_encoding;
	cString proxy_config;
	cString user_stylesheet;

	bool allow_file_access_from_file_url;
	bool allow_running_insecure_content;
	bool allow_scripts_to_access_clipboard;
	bool allow_scripts_to_close_windows;
	bool allow_scripts_to_open_windows;
	bool allow_universal_access_from_file_url;

	bool enable_app_cache;
	bool enable_dart;
	bool enable_databases;
	bool enable_gpu_acceleration;
	bool enable_javascript;
	bool enable_local_storage;
	bool enable_plugins;
	bool enable_remote_fonts;
	bool enable_smooth_scrolling;
	bool enable_web_audio;
	bool enable_web_gl;
	bool enable_web_security;

	bool load_images_automatically;

	bool shrink_standalone_images_to_fit;
}

struct cWebPopupMenuInfo_t {
	cRect bounds;  ///< The location to display the menu
	int item_height;         ///< The height of each menu item
	double item_font_size;   ///< The font-size of each menu item
	int selected_item;       ///< The index of the currently-selected item
	cWebMenuItemArrayPtr_t items;  ///< The actual menu items
	bool right_aligned;      ///< Whether or not the menu is right-aligned
} 

struct cWebContextMenuInfo_t {
	int pos_x;                 ///< The x-coordinate of the menu's position.
	int pos_y;                 ///< The y-coordinate of the menu's position.
	int media_type;      ///< The type of media (if any) that was clicked.
	int media_state;           ///< The state of the media (if any).
	cWebUrlPtr_t link_url;           ///< The URL of the link (if any).
	cWebUrlPtr_t src_url;            ///< The URL of the media (if any).
	cWebUrlPtr_t page_url;           ///< The URL of the web-page.
	cWebUrlPtr_t frame_url;          ///< The URL of the frame.
	aint64 frame_id;            ///< The ID of the frame.
	cWebStringPtr_t selection_text;  ///< The selected text (if any).
	bool is_editable;          ///< Whether or not this node is editable.
	int edit_flags;            ///< Which edit actions can be performed
}

struct cWebFileChooserInfo_t {
	int mode;       ///< The type of dialog to display
	cWebStringPtr_t title;               ///< Title of the dialog
	cWebStringPtr_t default_file_name;   ///< Suggested file name for the dialog
	cWebStringArrayPtr_t accept_types;   ///< Valid mime type
}

struct cWebLoginDialogInfo_t {
	int request_id;         ///< The unique ID of the request.
	cWebStringPtr_t request_url;  ///< The URL of the web-page requesting login.
	bool is_proxy;          ///< Whether or not this is a proxy auth.
	cWebStringPtr_t host;         ///< The hostname of the server.
	ushort port;    ///< The port of the server.
	cWebStringPtr_t scheme;       ///< The scheme of the server.
	cWebStringPtr_t realm;        ///< The realm of the server
}
	
struct cWebCertificateDialogInfo_t {
	cWebUrlPtr_t page_url;			///< URL of the page with a SSL error 
	int cert_err;					///< Error type
	bool is_overridable;
}

struct cWebPageInfDialogInfo_t {
	cWebUrlPtr_t page_url;			///< The current URL of the page.
	int security_status;			///< The page's authentication status.
	int content_status;				///< The page's content security status. See ContentStatusFlags.
	int cert_err;					///< The current error in the page's SSL certificate (if any).
	cWebStringPtr_t cert_subject;	///< The subject of the page's SSL certificate (should match server hostname).
	cWebStringPtr_t cert_issuer;	///< The issuer of the page's SSL certificate.
}

/// this structure holds Awesomium WebKeyboardEvent data
struct cKeyEventData
{
	int type;
	int modifiers;

	int virtual_key_code;
	int native_key_code;

	char[20] key_identifier;

	wchar[4] text;
	wchar[4] unmodified_text;

	bool is_system_key;
}

// ====================================

struct _cWebView;
alias _cWebView* cWebViewPtr_t;

struct _cWebCore;
alias _cWebCore* cWebCorePtr_t;

struct _cWebUrl;
alias _cWebUrl* cWebUrlPtr_t;

struct _cWebSession;
alias _cWebSession* cWebSessionPtr_t;


struct _cWebString;
alias _cWebString* cWebStringPtr_t;

struct _cWebStringArray;
alias _cWebStringArray* cWebStringArrayPtr_t;


struct _cJSObject;
alias _cJSObject* cJSObjectPtr_t;

struct _cJSArray; 
alias _cJSArray* cJSArrayPtr_t;

struct _cJSValue;
alias _cJSValue* cJSValuePtr_t;

struct _cJSMethodHandler;
alias _cJSMethodHandler* cJSMethodHandlerPtr_t;


struct _cKeyboardEvt;
alias _cKeyboardEvt* cKeyboardEvtPtr_t;

struct _cTouchEvt;
alias _cTouchEvt* cTouchEvtPtr_t;


alias void* cSurfacePtr_t;

alias void* cBitSurfacePtr_t;

alias void* cSurfaceFactoryPtr_t;

alias void* cWebMenuItemArrayPtr_t;


struct _cResInterceptor;
alias _cResInterceptor* cResInterceptorPtr_t;

struct _cResRequest;
alias _cResRequest* cResRequestPtr_t;

struct _cResResponse;
alias _cResResponse* cResResponsePtr_t;

struct _cUploadElement;
alias _cUploadElement* cUploadElementPtr_t;

struct _cDataSource;
alias _cDataSource* cDataSourcePtr_t;


struct _cWebView_onView;
alias _cWebView_onView* cWebView_onViewPtr_t;

struct _cWebView_onLoad;
alias _cWebView_onLoad* cWebView_onLoadPtr_t;

struct _cWebView_onProcess;
alias _cWebView_onProcess* cWebView_onProcessPtr_t;

struct _cWebView_onMenu;
alias _cWebView_onMenu* cWebView_onMenuPtr_t;

struct _cWebView_onDialog;
alias _cWebView_onDialog* cWebView_onDialogPtr_t;

struct _cWebView_onPrint;
alias _cWebView_onPrint* cWebView_onPrintPtr_t;

struct _cWebView_onDownload;
alias _cWebView_onDownload* cWebView_onDownloadPtr_t;

struct _cWebView_onIME;
alias _cWebView_onIME* cWebView_onIMEPtr_t;

// ===== CALLBACKS ======

// JS EVENTS
/// this method gets called on javascript method call which doesn't return value
alias void function(cWebViewPtr_t caller, uint remoteObjId, cWebStringPtr_t methodName, cJSArrayPtr_t args, void* userPointer) jshnd_onMethodCall;

/// this method gets called on javascript method call which returns value
alias cJSValuePtr_t function(cWebViewPtr_t caller, uint remoteObjId, cWebStringPtr_t methodName, cJSArrayPtr_t args, void* userPointer) jshnd_onMethodCallValue;

///
/// this structure stores JavaScript callback method handlers
struct cJSMethodCallback_t 
{
	///
	/// this function will be called whenever JS handler attached to view,
	/// and javascript function without returning value called.
	/// it may be NULL, in this case it will be ignored
	jshnd_onMethodCall call;

	///
	/// this function will be called whenever JS handler attached to view,
	/// and javascript function which returns value called.
	/// it may be NULL, in this case it will be ignored
	jshnd_onMethodCallValue callval;

	///
	/// you could use this to set object instance pointer or something
	void* userptr;
}

// --------------------------------
// WEBVIEW EVENTS

// -- view
alias void function(cWebViewPtr_t caller, const cWebStringPtr_t title, void* userPointer) wvview_onChangeTitle;
alias void function(cWebViewPtr_t caller, const cWebUrlPtr_t title, void* userPointer) wvview_onChangeAddressBar;
alias void function(cWebViewPtr_t caller, const cWebStringPtr_t tooltip, void* userPointer) wvview_onChangeTooltip;
alias void function(cWebViewPtr_t caller, const cWebUrlPtr_t url, void* userPointer) wvview_onChangeTargetURL;
alias void function(cWebViewPtr_t caller, int cursor, void* userPointer) wvview_onChangeCursor;
alias void function(cWebViewPtr_t caller, int focused_type, void* userPointer) wvview_onChangeFocus;
alias void function(cWebViewPtr_t caller, cWebViewPtr_t new_view, 
											const (cWebUrlPtr_t) opener_url, const (cWebUrlPtr_t) target_url,
											const (cRect)* initial_pos, bool is_popup, void* userPointer) wvview_onShowCreatedWebView;
alias void function(cWebViewPtr_t caller, const cWebStringPtr_t msg, 
											int line_number, const cWebStringPtr_t source, void *userPointer) wvview_onConsoleMsg;


struct cWebView_View
{
	wvview_onChangeTitle title;
	wvview_onChangeAddressBar address;
	wvview_onChangeTooltip tooltip;
	wvview_onChangeTargetURL url;
	wvview_onChangeCursor cursor;
	wvview_onChangeFocus focus;
	wvview_onShowCreatedWebView show;
	wvview_onConsoleMsg console;

	/// you could use this to set object instance or something
	void* userPointer;
}



// -- load
alias void function(cWebViewPtr_t caller, aint64 frame_id,
										   bool is_main_frame, const cWebUrlPtr_t url,
										   bool is_error_page, void* userptr) wvload_onBeginLoadingFrame;
alias void function(cWebViewPtr_t caller, aint64 frame_id,
										  bool is_main_frame, const cWebUrlPtr_t url,
										  int error_code, const cWebStringPtr_t error_desc,
										  void* userptr) wvload_onFailLoadingFrame;
alias void function(cWebViewPtr_t caller, aint64 frame_id, bool is_main_frame,
											const cWebUrlPtr_t url, void* userptr) wvload_onFinishLoadingFrame;
alias void function(cWebViewPtr_t caller, const cWebUrlPtr_t url, void* userptr) wvload_onDocumentReady;


struct cWebView_Load
{
	wvload_onBeginLoadingFrame begin;
	wvload_onFailLoadingFrame fail;
	wvload_onFinishLoadingFrame finish;
	wvload_onDocumentReady ready;

	void* userPointer;
}



// -- process
alias void function(cWebViewPtr_t caller, void* userptr) wvproc_onUnresponsive;
alias void function(cWebViewPtr_t caller, void* userptr) wvproc_onResponsive;
alias void function(cWebViewPtr_t caller, int status, void* userptr) wvproc_onCrashed;


struct cWebView_Process
{
	wvproc_onUnresponsive unresponsive;
	wvproc_onResponsive responsive;
	wvproc_onCrashed crashed;

	void* userPointer;
}


// -- menu
alias void function(cWebViewPtr_t caller, cWebPopupMenuInfo_t menu_info, void* userptr) wvmenu_onShowPopupMenu;
alias void function(cWebViewPtr_t caller, cWebContextMenuInfo_t menu_info, void* userptr) wvmenu_onShowContextMenu;


struct cWebView_Menu
{
	wvmenu_onShowPopupMenu popup;
	wvmenu_onShowContextMenu context;

	void* userPointer;
}


// -- dialog
alias void function(cWebViewPtr_t caller, cWebFileChooserInfo_t chooser_info, void* userptr) wvdialog_onShowFileChooser;
alias void function(cWebViewPtr_t caller, cWebLoginDialogInfo_t dialog_info, void* userptr) wvdialog_onShowLoginDialog;
alias void function(cWebViewPtr_t caller, cWebCertificateDialogInfo_t cert_info, void* userptr) wvdialog_onShowCertificateDialog;
alias void function(cWebViewPtr_t caller, cWebPageInfDialogInfo_t page_info, void* userptr) wvdialog_onShowPageInfoDialog;

struct cWebView_Dialog
{
	wvdialog_onShowFileChooser file;
	wvdialog_onShowLoginDialog login;
	wvdialog_onShowCertificateDialog cert;
	wvdialog_onShowPageInfoDialog pageinfo;
	void* userPointer;
}


// -- print
alias void function(cWebViewPtr_t caller, void* userptr) wvprint_onRequestPrint;
alias void function(cWebViewPtr_t caller, int request_id, void* userptr) wvprint_onFailPrint;
alias void function(cWebViewPtr_t caller, int request_id, const cWebStringArrayPtr_t file_list, void* userptr) wvprint_onFinishPrint;

struct cWebView_Print
{
	wvprint_onRequestPrint request;
	wvprint_onFailPrint fail;
	wvprint_onFinishPrint finish;

	void* userPointer;
}

// -- download
alias void function(cWebViewPtr_t caller, int download_id,
											 const cWebUrlPtr_t url,
											 const cWebStringPtr_t suggested_filename,
											 const cWebStringPtr_t mime_type,
											 void* userptr) wvdownload_onRequestDownload;
alias void function(cWebViewPtr_t caller,
											int download_id,
											aint64 total_bytes,
											aint64 received_bytes,
											aint64 current_speed,
											void* userptr) wvdownload_onUpdateDownload;

alias void function(cWebViewPtr_t caller,
											int download_id,
											const (cWebUrlPtr_t) url,
											const (cWebStringPtr_t) saved_path,
											void* userptr) wvdownload_onFinishDownload;

struct cWebView_Download
{
	wvdownload_onRequestDownload request;
	wvdownload_onUpdateDownload update;
	wvdownload_onFinishDownload finish;

	void* userPointer;
}


// -- IME
alias void function(cWebViewPtr_t caller, int type, int caret_x, int caret_y, void* userptr) wvime_onUpdateIME;
alias void function(cWebViewPtr_t caller, void* userptr) wvime_onCancelIME;
alias void function(cWebViewPtr_t caller, uint start, 
									   uint end, void* userptr) wvime_onChangeIMERange;


struct cWebView_IME
{
	wvime_onUpdateIME update;
	wvime_onCancelIME cancel;
	wvime_onChangeIMERange range;

	void* userPointer;
}


// --------------------------------

// ====== WEB STRING ======
cWebStringPtr_t         aws_webstring_new ();
cWebStringPtr_t         aws_webstring_new_substring (cWebStringPtr_t srcstring, uint start, uint len);
cWebStringPtr_t         aws_webstring_new_utf8 (const char* string, uint len);
cWebStringPtr_t         aws_webstring_new_webstring (cWebStringPtr_t string);

void                    aws_webstring_delete (cWebStringPtr_t string);

uint                    aws_webstring_to_utf8 (cWebStringPtr_t string, char* dest, uint length);
const (wchar)*          aws_webstring_data (cWebStringPtr_t string);
cString                 aws_webstring_to_cstring (cWebStringPtr_t string);

// ====== WEB CORE =======
const(cWebCorePtr_t)    aws_webcore_init (cWebConf wc);
const(cWebCorePtr_t)    aws_webcore_initDefault ();
void                    aws_webcore_shutdown ();
const(cWebCorePtr_t)    aws_webcore_instance ();
cWebSessionPtr_t        aws_webcore_createWebSession (cWebCorePtr_t webcore, cWebStringPtr_t path, cWebPrefs wp);
cWebViewPtr_t           aws_webcore_createWebView (cWebCorePtr_t webcore, int w, int h, cWebSessionPtr_t sess, int type);
void                    aws_webcore_setSurfaceFactory (cWebCorePtr_t webcore, cSurfaceFactoryPtr_t factory);
cSurfaceFactoryPtr_t    aws_webcore_getSurfaceFactory (cWebCorePtr_t webcore);
void                    aws_webcore_setResourceInterceptor (cWebCorePtr_t webcore, cResInterceptorPtr_t interceptor);
cResInterceptorPtr_t    aws_webcore_getResourceInterceptor (cWebCorePtr_t webcore);
void                    aws_webcore_update (cWebCorePtr_t webcore);
const(char)*            aws_webcore_versionString (cWebCorePtr_t webcore);

// ====== WEB VIEW =======
void                    aws_webview_destroy (cWebViewPtr_t webview);
int                     aws_webview_getType (cWebViewPtr_t webview);
int                     aws_webview_getProcId (cWebViewPtr_t webview);
void*                   aws_webview_getHandle (cWebViewPtr_t webview);
void                    aws_webview_setParentWindow (cWebViewPtr_t webview, void* window);
void*                   aws_webview_getParentWindow (cWebViewPtr_t webview);
void*                   aws_webview_getWindow (cWebViewPtr_t webview);

void                    aws_webview_setViewListener (cWebViewPtr_t webview, cWebView_onViewPtr_t listener);
void                    aws_webview_setLoadListener (cWebViewPtr_t webview, cWebView_onLoadPtr_t listener);
void                    aws_webview_setProcessListener (cWebViewPtr_t webview, cWebView_onProcessPtr_t listener);
void                    aws_webview_setMenuListener (cWebViewPtr_t webview, cWebView_onMenuPtr_t listener);
void                    aws_webview_setDialogListener (cWebViewPtr_t webview, cWebView_onDialogPtr_t listener);
void                    aws_webview_setPrintListener (cWebViewPtr_t webview, cWebView_onPrintPtr_t listener);
void                    aws_webview_setDownloadListener (cWebViewPtr_t webview, cWebView_onDownloadPtr_t listener);
void                    aws_webview_setIMEListener (cWebViewPtr_t webview, cWebView_onIMEPtr_t listener);

cWebView_onViewPtr_t    aws_webview_getViewListener (cWebViewPtr_t webview);
cWebView_onLoadPtr_t    aws_webview_getLoadListener (cWebViewPtr_t webview);
cWebView_onProcessPtr_t aws_webview_getProcessListener (cWebViewPtr_t webview);
cWebView_onMenuPtr_t    aws_webview_getMenuListener (cWebViewPtr_t webview);
cWebView_onDialogPtr_t  aws_webview_getDialogListener (cWebViewPtr_t webview);
cWebView_onPrintPtr_t   aws_webview_getPrintListener (cWebViewPtr_t webview);
cWebView_onDownloadPtr_t aws_webview_getDownloadListener (cWebViewPtr_t webview);
cWebView_onIMEPtr_t     aws_webview_getIMEListener (cWebViewPtr_t webview);

void                    aws_webview_loadURL (cWebViewPtr_t webview, cWebUrlPtr_t url);
void                    aws_webview_goBack (cWebViewPtr_t webview);
void                    aws_webview_goForward(cWebViewPtr_t webview);
void                    aws_webview_goToHistoryOffset (cWebViewPtr_t webview, int offset);
void                    aws_webview_stop (cWebViewPtr_t webview);
void                    aws_webview_reload (cWebViewPtr_t webview, bool ignoreCache);
bool                    aws_webview_canGoBack (cWebViewPtr_t webview);
bool                    aws_webview_canGoForward (cWebViewPtr_t webview);
cSurfacePtr_t           aws_webview_getSurface (cWebViewPtr_t webview);
cWebUrlPtr_t            aws_webview_getURL (cWebViewPtr_t webview);
cWebStringPtr_t         aws_webview_getTitle (cWebViewPtr_t webview);
cWebSessionPtr_t        aws_webview_getSession (cWebViewPtr_t webview);
bool                    aws_webview_isLoading (cWebViewPtr_t webview);
bool                    aws_webview_isCrashed (cWebViewPtr_t webview);
void                    aws_webview_resize (cWebViewPtr_t webview, int x, int y);
void                    aws_webview_setTransparent (cWebViewPtr_t webview, bool state);
bool                    aws_webview_isTransparent (cWebViewPtr_t webview);
void                    aws_webview_pauseRendering (cWebViewPtr_t webview);
void                    aws_webview_resumeRendering (cWebViewPtr_t webview);
void                    aws_webview_focus (cWebViewPtr_t webview);
void                    aws_webview_unfocus (cWebViewPtr_t webview);
int                     aws_webview_focusedElementType (cWebViewPtr_t webview);
void                    aws_webview_injectMouseMove (cWebViewPtr_t webview, int mx, int my);
void                    aws_webview_injectMouseButton (cWebViewPtr_t webview, int button, bool down);
void                    aws_webview_injectMouseWheel (cWebViewPtr_t webview, int wx, int wy);
void                    aws_webview_injectKeyboardEvent (cWebViewPtr_t webview, cKeyboardEvtPtr_t keyevent);
void                    aws_webview_injectTouchEvent (cWebViewPtr_t webview, cTouchEvtPtr_t touchevent);
void                    aws_webview_activateIME (cWebViewPtr_t webview, bool state);
void                    aws_webview_setIMEComposition (cWebViewPtr_t webview, cWebStringPtr_t target_string, int cursorpos, int targetstart, int tartgetend);
void                    aws_webview_cancelIMEComposition (cWebViewPtr_t webview);
void                    aws_webview_undo (cWebViewPtr_t webview);
void                    aws_webview_redo (cWebViewPtr_t webview);
void                    aws_webview_cut (cWebViewPtr_t webview);
void                    aws_webview_copy (cWebViewPtr_t webview);
void                    aws_webview_copyImageAt (cWebViewPtr_t webview, int x, int y);
void                    aws_webview_paste (cWebViewPtr_t webview);
void                    aws_webview_pasteAndMatchStyle (cWebViewPtr_t webview);
void                    aws_webview_selectAll (cWebViewPtr_t webview);
void                    aws_webview_printToFile (cWebViewPtr_t webview, cWebStringPtr_t outDir, void* printconf);
int                     aws_webview_lastError (cWebViewPtr_t webview);
cJSValuePtr_t           aws_webview_createGlobalJSObject (cWebViewPtr_t webview, cWebStringPtr_t objname);
void                    aws_webview_executeJS (cWebViewPtr_t webview, cWebStringPtr_t script, cWebStringPtr_t fxpath);
cJSValuePtr_t           aws_webview_executeJSWithResult (cWebViewPtr_t webview, cWebStringPtr_t script, cWebStringPtr_t fxpath);
void                    aws_webview_setJSMethodHandler (cWebViewPtr_t webview, cJSMethodHandlerPtr_t jshandler);
void                    aws_webview_didSelectPopupMenuItem (cWebViewPtr_t webview, int idx);
void                    aws_webview_didCancelPopupMenu (cWebViewPtr_t webview);
void                    aws_webview_didChooseFiles (cWebViewPtr_t webview, cWebStringArrayPtr_t arr, bool write);
void                    aws_webview_didLogin (cWebViewPtr_t webview, int reqId, cWebStringPtr_t uname, cWebStringPtr_t pwd);
void                    aws_webview_didCancelLogin (cWebViewPtr_t webview, int reqId);
void                    aws_webview_didChooseDownloadPath (cWebViewPtr_t webview, int downloadId, cWebStringPtr_t path);
void                    aws_webview_didCancelDownload (cWebViewPtr_t webview, int downloadId);

// ====== JS VALUE =======
cJSValuePtr_t           aws_jsvalue_new_bool (bool val);
cJSValuePtr_t           aws_jsvalue_new_int (int val);
cJSValuePtr_t           aws_jsvalue_new_double (double val);
cJSValuePtr_t           aws_jsvalue_new_string (cWebStringPtr_t val);
cJSValuePtr_t           aws_jsvalue_new_object (cJSObjectPtr_t val);
cJSValuePtr_t           aws_jsvalue_new_array (cJSArrayPtr_t val);
cJSValuePtr_t           aws_jsvalue_new_jsvalue (cJSValuePtr_t val);

void                    aws_jsvalue_delete (cJSValuePtr_t jsvalue);

const(cJSValuePtr_t)    aws_jsvalue_undefined ();
const(cJSValuePtr_t)    aws_jsvalue_null ();

bool                    aws_jsvalue_isBoolean (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isInteger (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isDouble (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isNumber (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isString (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isArray (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isObject (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isNull (cJSValuePtr_t jsval);
bool                    aws_jsvalue_isUndefined (cJSValuePtr_t jsval);

cWebStringPtr_t         aws_jsvalue_toString (cJSValuePtr_t jsval);
int                     aws_jsvalue_toInteger (cJSValuePtr_t jsval);
double                  aws_jsvalue_toDouble (cJSValuePtr_t jsval);
bool                    aws_jsvalue_toBoolean (cJSValuePtr_t jsval);
cJSArrayPtr_t           aws_jsvalue_toArray (cJSValuePtr_t jsval);
cJSObjectPtr_t          aws_jsvalue_toObject (cJSValuePtr_t jsval);

// ====== JS OBJECT =======
cJSObjectPtr_t          aws_jsobject_new ();

void                    aws_jsobject_delete (cJSObjectPtr_t jsobj);

uint                    aws_jsobject_getRemoteId (cJSObjectPtr_t jsobj);
int                     aws_jsobject_getRefCount (cJSObjectPtr_t jsobj);
int                     aws_jsobject_getType (cJSObjectPtr_t jsobj);
const(cWebViewPtr_t)    aws_jsobject_getOwner (cJSObjectPtr_t jsobj);

bool                    aws_jsobject_hasProperty (cJSObjectPtr_t jsobj, cWebStringPtr_t name);
cJSValuePtr_t           aws_jsobject_getProperty (cJSObjectPtr_t jsobj, cWebStringPtr_t name);
void                    aws_jsobject_setProperty (cJSObjectPtr_t jsobj, cWebStringPtr_t name, cJSValuePtr_t jsval);
void                    aws_jsobject_removeProperty (cJSObjectPtr_t jsobj, cWebStringPtr_t name);

cJSArrayPtr_t           aws_jsobject_getPropertyNames (cJSObjectPtr_t jsobj);
cJSArrayPtr_t           aws_jsobject_getMethodNames (cJSObjectPtr_t jsobj);
bool                    aws_jsobject_hasMethod (cJSObjectPtr_t jsobj, cWebStringPtr_t name);
cJSValuePtr_t           aws_jsobject_invoke (cJSObjectPtr_t jsobj, cWebStringPtr_t name, cJSArrayPtr_t args);
cWebStringPtr_t         aws_jsobject_toString (cJSObjectPtr_t jsobj);

// ====== JS ARRAY =======
cJSArrayPtr_t           aws_jsarray_new_size (uint size);
cJSArrayPtr_t           aws_jsarray_new ();

void                    aws_jsarray_delete (cJSArrayPtr_t jsarray);

uint                    aws_jsarray_getSize (cJSArrayPtr_t jsarray);
uint                    aws_jsarray_getCapacity (cJSArrayPtr_t jsarray);
const(cJSValuePtr_t)    aws_jsarray_getItemAt (cJSArrayPtr_t jsarray, uint pos);
void                    aws_jsarray_push (cJSArrayPtr_t jsarray, cJSValuePtr_t item);
void                    aws_jsarray_pop (cJSArrayPtr_t jsarray);
void                    aws_jsarray_insert (cJSArrayPtr_t jsarray, cJSValuePtr_t item, uint pos);
void                    aws_jsarray_erase (cJSArrayPtr_t jsarray, uint pos);
void                    aws_jsarray_clear (cJSArrayPtr_t jsarray);

// ====== WEB URL =======
cWebUrlPtr_t            aws_weburl_new ();
cWebUrlPtr_t            aws_weburl_new_cstring (cString str);
cWebUrlPtr_t            aws_weburl_new_webstring (cWebStringPtr_t str);

void                    aws_weburl_delete (cWebUrlPtr_t weburl);

bool                    aws_weburl_isValid (cWebUrlPtr_t weburl);
bool                    aws_weburl_isEmpty (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getSpec (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getScheme (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getUsername (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getPassword (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getHost (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getPort (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getPath (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getQuery (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getAnchor (cWebUrlPtr_t weburl);
cWebStringPtr_t         aws_weburl_getFilename (cWebUrlPtr_t weburl);

// ====== WEB SESSION =======
void                    aws_websession_release (cWebSessionPtr_t sess);

bool                    aws_websession_isOnDisk (cWebSessionPtr_t sess);
cWebStringPtr_t         aws_websession_getDataPath (cWebSessionPtr_t sess);
cWebPrefs               aws_websession_getPreferences (cWebSessionPtr_t sess);
void                    aws_websession_addDataSource (cWebSessionPtr_t sess, cWebStringPtr_t asset_host, cDataSourcePtr_t source);
void                    aws_websession_setCookie (cWebSessionPtr_t sess, cWebUrlPtr_t url, cWebStringPtr_t asset_host, bool http_only, bool force_session);
void                    aws_websession_clearCookies (cWebSessionPtr_t sess);


// ====== BITMAP SURFACE =======
cBitSurfacePtr_t        aws_bitmapsurface_new (int x, int y);

void                    aws_bitmapsurface_delete (cBitSurfacePtr_t surface);

const (ubyte)*          aws_bitmapsurface_getBuffer (cBitSurfacePtr_t surface);
int                     aws_bitmapsurface_getWidth (cBitSurfacePtr_t surface);
int                     aws_bitmapsurface_getHeight (cBitSurfacePtr_t surface);
int                     aws_bitmapsurface_getRowSpan (cBitSurfacePtr_t surface);
bool                    aws_bitmapsurface_isDirty (cBitSurfacePtr_t surface);
void                    aws_bitmapsurface_setIsDirty (cBitSurfacePtr_t surface, bool val);
void                    aws_bitmapsurface_copyTo (cBitSurfacePtr_t surface, ubyte* dst_buffer, int dst_row_span, int dst_depth, bool to_rgba, bool flip_y);
bool                    aws_bitmapsurface_saveToPNG (cBitSurfacePtr_t surface, cWebStringPtr_t path, bool preserve_transparency);
bool                    aws_bitmapsurface_saveToJPEG (cBitSurfacePtr_t surface, cWebStringPtr_t path, int quality);
ubyte                   aws_bitmapsurface_getAlphaAtPoint (cBitSurfacePtr_t surface, int x, int y);

// --- factory methods, untested
cSurfaceFactoryPtr_t    aws_surfacefactory_new ();
void                    aws_surfacefactory_delete (cSurfaceFactoryPtr_t factory);

cSurfacePtr_t           aws_bitmapsurface_create (cWebViewPtr_t webview, int width, int height);
void                    aws_bitmapsurface_destroy (cSurfacePtr_t surface);

//================================
// JS HANDLER STUFF

void                    aws_webview_setInternalJSHandler (cWebViewPtr_t webview);

void                    aws_jshandler_addCallback (cWebViewPtr_t webview, cJSMethodCallback_t callback);
void                    aws_jshandler_removeCallback (cWebViewPtr_t webview);
void                    aws_jshandler_removeCallbackAll ();

//================================
// WEBVIEW HANDLERS STUFF

// this functions sets internal wrapper listener which allow setting callbacks to that events
void                    aws_webview_setInternalLoadHandler (cWebViewPtr_t webview);
void                    aws_webview_setInternalViewHandler (cWebViewPtr_t webview);
void                    aws_webview_setInternalPrintHandler (cWebViewPtr_t webview);
void                    aws_webview_setInternalProcessHandler (cWebViewPtr_t webview);
void                    aws_webview_setInternalMenuHandler (cWebViewPtr_t webview);
void                    aws_webview_setInternalDownloadHandler (cWebViewPtr_t webview);
void                    aws_webview_setInternalDialogHandler (cWebViewPtr_t webview);
void                    aws_webview_setInternalIMEHandler (cWebViewPtr_t webview);

// set callbacks
void                    aws_webview_setListenerLoad (cWebViewPtr_t webview, cWebView_Load loadclbks);
void                    aws_webview_setListenerView (cWebViewPtr_t webview, cWebView_View viewclbks);
void                    aws_webview_setListenerPrint (cWebViewPtr_t webview, cWebView_Print prntclbks);
void                    aws_webview_setListenerProcess (cWebViewPtr_t webview, cWebView_Process procclbks);
void                    aws_webview_setListenerMenu (cWebViewPtr_t webview, cWebView_Menu menuclbks);
void                    aws_webview_setListenerDialog (cWebViewPtr_t webview, cWebView_Dialog dlgclbks);
void                    aws_webview_setListenerDownload (cWebViewPtr_t webview, cWebView_Download dlclbks);
void                    aws_webview_setListenerIME (cWebViewPtr_t webview, cWebView_IME imeclbks);

//================================
// RESOURCE INTERCEPTOR STUFF


// ===== RESOURCE RESPONSE ======
cResResponsePtr_t       aws_resresponse_create (uint numBytes, ubyte* buffer, cWebStringPtr_t mimeType);
cResResponsePtr_t       aws_resresponse_create_path (cWebStringPtr_t filePath);

// ===== RESOURCE REQUEST ======
void                    aws_resrequest_cancel (cResRequestPtr_t request);
uint                    aws_resrequest_originProcId (cResRequestPtr_t request);
cWebUrlPtr_t            aws_resrequest_getUrl (cResRequestPtr_t request);
cWebStringPtr_t         aws_resrequest_getMethod (cResRequestPtr_t request);
void                    aws_resrequest_setMethod (cResRequestPtr_t request, cWebStringPtr_t method);
cWebStringPtr_t         aws_resrequest_getReferrer (cResRequestPtr_t request);
void                    aws_resrequest_setReferrer (cResRequestPtr_t request, cWebStringPtr_t referrer);
cWebStringPtr_t         aws_resrequest_getExtraHeaders (cResRequestPtr_t request);
void                    aws_resrequest_setExtraHeaders (cResRequestPtr_t request, cWebStringPtr_t headers);
void                    aws_resrequest_appendExtraHeader (cResRequestPtr_t request, cWebStringPtr_t name, cWebStringPtr_t value);
uint                    aws_resrequest_getNumUploadedElements (cResRequestPtr_t request);
cUploadElementPtr_t     aws_resrequest_getUploadElement (cResRequestPtr_t request);
void                    aws_resrequest_clearUploadElements (cResRequestPtr_t request);
void                    aws_resrequest_appendUploadFilePath (cResRequestPtr_t request, cWebStringPtr_t filePath);
void                    aws_resrequest_appendUploadBytes (cResRequestPtr_t request, ubyte* bytes, uint numBytes);

// ===== UPLOAD ELEMENT ======
bool                    aws_uploadelem_isFilePath (cUploadElementPtr_t upelem);
bool                    aws_uploadelem_isBytes (cUploadElementPtr_t upelem);
uint                    aws_uploadelem_getNumBytes (cUploadElementPtr_t upelem);
ubyte*                  aws_uploadelem_getBytes (cUploadElementPtr_t upelem);
cWebStringPtr_t         aws_uploadelem_getFilePath (cUploadElementPtr_t upelem);


// ===== OTHER STUFF ======
cKeyboardEvtPtr_t       aws_keyboardevent_from_keycode (int virtkey, int scancode, int modifiers, int type, char text);
void                    aws_keyboardevent_set_data (cKeyboardEvtPtr_t evt, cKeyEventData data);
cKeyEventData           aws_keyboardevent_get_data (cKeyboardEvtPtr_t evt);

version(OSX)
cKeyboardEvtPtr_t       aws_keyboardevent_from_system (NSEvent* evt);

version(Windows)
cKeyboardEvtPtr_t       aws_keyboardevent_from_system (UINT msg, WPARAM wparam, LPARAM lparam);


void                    aws_keyboardevent_delete (cKeyboardEvtPtr_t evt);