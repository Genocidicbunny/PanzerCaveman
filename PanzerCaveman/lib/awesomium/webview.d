/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.webview;

import awesomium.capi, awesomium.util, 
	awesomium.inputevt, awesomium.websession,
	awesomium.surface, awesomium.webstring,
	awesomium.weburl, awesomium.common;

import std.c.string : strlen;


// should be replaced with actual structs later
alias cWebPopupMenuInfo_t WebPopupMenuInfo;
alias cWebLoginDialogInfo_t WebLoginDialogInfo;
alias cWebContextMenuInfo_t WebContextMenuInfo;
alias cWebFileChooserInfo_t WebFileChooserInfo;
alias cWebStringArrayPtr_t WebStringArray;

enum WebViewType
{
	OFFSCREEN = 0,
	WINDOWED,
}


enum FocusedElementType
{
	NONE = 0,         ///< Nothing is focused
	TEXT,             ///< A text-node is focused
	LINK,             ///< A link is focused
	INPUT,            ///< An input element is focused
	TEXTINPUT,        ///< A text-input element is focused
	EDITABLECONTENT,  ///< Some editable content is focused
	PLUGIN,           ///< A plugin (eg, Flash) is focused
	OTHER,            ///< Some other element is focused
}

/// Used with WebViewListener.Process.OnCrashed
enum TerminationStatus {
	NORMAL,       ///< Zero Exit Status
	ABNORMAL,     ///< Non-Zero exit status
	KILLED,       ///< e.g. SIGKILL or Task Manager kill
	CRASHED,      ///< e.g. Segmentation Fault
	STILLRUNNING  ///< Process hasn't exited yet
};

/// Used with WebViewListener::InputMethodEditor::OnUpdate
enum TextInputType {
	NONE,      ///< Input is not editable, no IME should be displayed.
	TEXT,      ///< Input is editable, IME should be displayed.
	PASSWORD,  ///< Input is a password box, IME should only be displayed if suitable.
	SEARCH,    ///< Input is a search box, IME should only be displayed if suitable.
	EMAIL,     ///< Input is an email input, IME should only be displayed if suitable.
	NUMBER,    ///< Input is a number input, IME should only be displayed if suitable.
	TELEPHONE, ///< Input is a telephone input, IME should only be displayed if suitable.
	URL,       ///< Input is a URL input, IME should only be displayed if suitable.
};


///
/// An enumeration of all the possible web cursors.
///
/// @see WebViewListener.View.OnChangeCursor
///
enum Cursor {
	POINTER,
	CROSS,
	HAND,
	IBEAM,
	WAIT,
	HELP,
	EASTRESIZE,
	NORTHRESIZE,
	NORTHEASTRESIZE,
	NORTHWESTRESIZE,
	SOUTHRESIZE,
	SOUTHEASTRESIZE,
	SOUTHWESTRESIZE,
	WESTRESIZE,
	NORTHSOUTHRESIZE,
	EASTWESTRESIZE,
	NORTHEASTSOUTHWESTRESIZE,
	NORTHWESTSOUTHEASTRESIZE,
	COLUMNRESIZE,
	ROWRESIZE,
	MIDDLEPANNING,
	EASTPANNING,
	NORTHPANNING,
	NORTHEASTPANNING,
	NORTHWESTPANNING,
	SOUTHPANNING,
	SOUTHEASTPANNING,
	SOUTHWESTPANNING,
	WESTPANNING,
	MOVE,
	VERTICALTEXT,
	CELL,
	CONTEXTMENU,
	ALIAS,
	PROGRESS,
	NODROP,
	COPY,
	NONE,
	NOTALLOWED,
	ZOOMIN,
	ZOOMOUT,
	GRAB,
	GRABBING,
	CUSTOM,
}

alias int NativeWindow;
alias int PrintConfig;

// placeholder for JSValue
struct JSValue
{

}



class WebView
{
public:


	///
	/// Begin loading a certain URL asynchronously.
	///
	/// @param  url  The URL to begin loading.
	///
	/// @note  The page is not guaranteed to be loaded after this method returns.
	///        You should use WebViewListener::Load::OnFinishLoadingFrame to do
	///        something after the page is loaded.
	///
	void loadURL(string url)
	{
		auto weburl = aws_weburl_new_cstring(url.toCString);
		aws_webview_loadURL( this, weburl );
		aws_weburl_delete(weburl);
	}

	///
	/// The type of this WebView (declared at WebCore::CreateWebView). If this
	/// is an Offscreen WebView, you will need to display the Surface and pass
	/// all input yourself.
	///
	@property WebViewType type()
	{
		return cast(WebViewType) aws_webview_getType(this);
	}

	///
	/// Get the unique ID for the corresponding child-process hosting this
	/// WebView. May return 0 if the WebView has crashed or there is no
	/// process active.
	///
	int process_id() {
		return aws_webview_getProcId(this);
	}

	///
	/// Get the handle for the corresponding child-process hosting this
	/// WebView. This may not be initialized until some time after the
	/// WebView is actually created (when we receive the first IPC message
	/// from the child-process).
	///
	void* /*ProcessHandle*/ process_handle() {
		return aws_webview_getHandle(this);
	}

	///
	/// Set the parent window for this WebView. You should only call this
	/// for windowed WebViews (eg, those created with kWebViewType_Window)
	/// on the Windows platform.
	///
	/// You should call this method immediately after calling CreateWebView,
	/// the window for this WebView will not be created until the first
	/// call to set_parent_window on the Windows platform.
	///
	void set_parent_window(NativeWindow parent)
	{
		aws_webview_setParentWindow(this, cast(void*)parent);
	}

	///
	/// Get the parent window for this WebView.
	///
	NativeWindow parent_window()
	{
		return cast(NativeWindow)aws_webview_getParentWindow(this);
	}

	///
	/// Get the actual window handle that was created by this WebView. This is
	/// only valid for windowed WebViews.
	///
	/// On the Mac OSX platform, you will need to retrieve this window (NSView)
	/// and add it to your application's view container to display it.
	///
	NativeWindow window()
	{
		return cast(NativeWindow)aws_webview_getWindow(this);
	}

	///
	/// Register a listener to handle view-related events.
	///
	/// @param  listener  The instance to register.
	///
	void set_view_listener(WebViewListener.View listener)
	{
		_lsnview = listener;
	}

	///
	/// Register a listener to handle page-load events.
	///
	/// @param  listener  The instance to register (you retain ownership).
	///
	//void set_load_listener(WebViewListener::Load* listener) = 0;

	///
	/// Register a listener to handle process-related events (crash, hangs, etc).
	///
	/// @param  listener  The instance to register (you retain ownership).
	///
	//void set_process_listener(WebViewListener::Process* listener) = 0;

	///
	/// Register a listener to handle the display of various menus.
	///
	/// @param  listener  The instance to register (you retain ownership).
	///
	//void set_menu_listener(WebViewListener::Menu* listener) = 0;

	///
	/// Register a listener to handle the display of various dialogs.
	///
	/// @param  listener  The instance to register (you retain ownership).
	///
	//void set_dialog_listener(WebViewListener::Dialog* listener) = 0;

	///
	/// Register a listener to handle printing-related events.
	///
	/// @param  listener  The instance to register (you retain ownership).
	///
	//void set_print_listener(WebViewListener::Print* listener) = 0;

	///
	/// Register a listener to handle download-related events.
	///
	/// @param  listener  The instance to register (you retain ownership).
	///
	//void set_download_listener(WebViewListener::Download* listener) = 0;

	///
	/// Register a listener to handle IME-related events.
	///
	/// @param  listener  The instance to register (you retain ownership).
	///
	//void set_input_method_editor_listener(WebViewListener::InputMethodEditor* listener) = 0;

	/// Get the current view-event listener (may be NULL).
	//WebViewListener::View* view_listener() = 0;

	/// Get the current load-event listener (may be NULL).
	//WebViewListener::Load* load_listener() = 0;

	/// Get the current process-event listener (may be NULL).
	//WebViewListener::Process* process_listener() = 0;

	/// Get the current menu-event listener (may be NULL).
	//WebViewListener::Menu* menu_listener() = 0;

	/// Get the current dialog-event listener (may be NULL).
	//WebViewListener::Dialog* dialog_listener() = 0;

	/// Get the current print-event listener (may be NULL).
	//WebViewListener::Print* print_listener() = 0;

	/// Get the current download-event listener (may be NULL).
	//WebViewListener::Download* download_listener() = 0;

	/// Get the current download-event listener (may be NULL).
	//WebViewListener::InputMethodEditor* input_method_editor_listener() = 0;

	///
	/// Go back one page in history.
	///
	void GoBack()
	{
		aws_webview_goBack(this);
	}

	///
	/// Go forward one page in history.
	///
	void GoForward()
	{
		aws_webview_goForward(this);
	}

	///
	/// Go to a specific offset in history (for example, -1 would
	/// go back one page).
	///
	/// @param  The offset to go to.
	///
	void GoToHistoryOffset(int offset)
	{
		aws_webview_goToHistoryOffset(this, offset);
	}

	///
	/// Stop all page loads.
	///
	void Stop()
	{
		aws_webview_stop(this);
	}

	///
	/// Reload the current page.
	///
	/// @param  ignore_cache  Whether or not we force cached resources to
	///                       to be reloaded as well.
	///
	void Reload(bool ignore_cache)
	{
		aws_webview_reload(this, ignore_cache);
	}

	///
	/// Check whether or not we can go back in history.
	///
	bool CanGoBack()
	{
		return aws_webview_canGoBack(this);
	}

	///
	/// Check whether or not we can go forward in history.
	///
	bool CanGoForward()
	{
		return aws_webview_canGoForward(this);
	}

	///
	/// Get the current rendering Surface. May be NULL. This is only valid for
	/// offscreen WebViews (this will be NULL for windowed WebViews).
	///
	/// @note: If you never call WebCore::SetSurfaceFactory, the returned
	///        Surface will always be of type BitmapSurface.
	///
	/// @see WebCore::set_surface_factory
	///
	Surface surface()
	{
		BitmapSurface surf;
		
		if ( _surface is null ) 
			surf = new BitmapSurface();
		else
			surf = cast(BitmapSurface)_surface;

		surf._owner = false;
		surf._internal = cast(cBitSurfacePtr_t) aws_webview_getSurface(this);
		return surf;
	}

	void Destroy()
	{
		aws_webview_destroy(this);
	}

	/// Get the current page URL.
	//WebURL url();

	/// Get the current page title.
	@property string title()
	{	
		return cast(string) new WebString( aws_webview_getTitle(this) );
	}

	/// Get the session associated with this WebView.
	WebSession session()
	{
		WebSession ses;

		if ( _session is null ) 
		{
			_session = new WebSession();
			ses = _session;
		}

		ses._owner = false;
		ses._internal = aws_webview_getSession(this);

		return ses;
	}

	/// Check whether or not any page resources are loading.
	bool IsLoading()
	{
		return aws_webview_isLoading(this);
	}

	/// Check whether or not the WebView process has crashed.
	bool IsCrashed()
	{
		return aws_webview_isCrashed(this);
	}

	///
	/// Resize to certain pixel dimensions (will trigger a new Surface to
	/// be created). This operation is asynchronous and may not complete
	/// by the time this method returns.
	///
	/// @param  width  The width in pixels.
	///
	/// @param  height  The height in pixels.
	///
	void Resize(int width, int height)
	{
		aws_webview_resize(this, width, height);
	}

	///
	/// Set the background of the view to be transparent. You must call this
	/// if you intend to preserve the transparency of a page (eg, your
	/// body element has "background-color: transparent;" or some other
	/// semi-translucent background). Please note that the alpha channel is
	/// premultiplied.
	///
	/// This is only compatible with Offscreen WebViews.
	///
	/// If you never call this, the view will have an opaque, white background
	/// by default.
	///
	/// @param  is_transparent  Whether or not the view should support
	///                         transparency.
	///
	void SetTransparent(bool is_transparent)
	{
		aws_webview_setTransparent(this, is_transparent);
	}

	///
	/// Whether or not the view supports transparency.
	///
	bool IsTransparent()
	{
		return aws_webview_isTransparent(this);
	}

	///
	/// Pause the renderer. All rendering is done asynchronously in a separate
	/// process so you should call this when your view is hidden to save
	/// some CPU cycles.
	///
	void PauseRendering()
	{
		aws_webview_pauseRendering(this);
	}

	///
	/// Resume the renderer (will force a full repaint).
	///
	/// @see WebView::PauseRendering
	///
	void ResumeRendering()
	{
		aws_webview_resumeRendering(this);
	}

	///
	/// Give the appearance of input focus. You should call this whenever the
	/// view gains focus.
	///
	/// @note If you fail to see a blinking caret when you select a textbox,
	///       it's usually because you forgot to call this method.
	///
	void Focus()
	{
		aws_webview_focus(this);
	}

	///
	/// Remove the appearance of input focus. You should call this whenever the
	/// view loses focus.
	///
	void Unfocus()
	{
		aws_webview_unfocus(this);
	}

	///
	/// Get the type of the currently-focused element. This is useful for
	/// determining if the WebView should capture keyboard events. If no element
	/// is focused, this will return kFocusedElementType_None.
	///
	/// @see FocusedElementType
	///
	@disable FocusedElementType focused_element_type()
	{
		return cast(FocusedElementType) aws_webview_focusedElementType(this);
	}

	///
	/// Passes a mouse-move event to the view.
	///
	/// @param  x  The x-coordinate of the current mouse position
	///
	/// @param  y  The y-coordinate of the current mouse position
	///
	/// @note All coordinates should be localized to the view. All values are in
	///       pixels, the origin (0,0) begins at the top-left corner of the view,
	///       positive-y values are "down" and positive-x values are "right".
	///
	void InjectMouseMove(int x, int y)
	{
		aws_webview_injectMouseMove(this, x, y);
	}

	///
	/// Passes a mouse-down event using the last mouse-move coordinates.
	///
	/// @param  button  The button that was pressed.
	///
	void InjectMouseDown(MouseButton button)
	{
		aws_webview_injectMouseButton(this, button, true);
	}

	///
	/// Passes a mouse-up event using the last mouse-move coordinates.
	///
	/// @param  button  The button that was released.
	///
	void InjectMouseUp(MouseButton button)
	{
		aws_webview_injectMouseButton(this, button, false);
	}

	///
	/// Passes a mouse-wheel event.
	///
	/// @param  scroll_vert  The amount of pixels to scroll vertically by.
	///
	/// @param  scroll_horz  The amount of pixels to scroll horizontally by.
	///
	void InjectMouseWheel(int scroll_vert, int scroll_horz)
	{
		aws_webview_injectMouseWheel(this, scroll_vert, scroll_horz);
	}

	///
	/// Passes a keyboard event.
	///
	/// @param  key_event  The keyboard event.
	///
	void InjectKeyboardEvent(WebKeyboardEvent key_event)
	{
		aws_webview_injectKeyboardEvent(this, key_event._internal);
	}

	///
	/// Passes a multi-touch event.
	///
	/// @param  touch_event  The multi-touch event.
	///
	@disable void InjectTouchEvent(WebTouchEvent touch_event)
	{

	}

	///
	/// Call this method to let the WebView know you will be passing
	/// text input via IME and will need to be notified of any
	/// IME-related events (caret position, user unfocusing textbox, etc.)
	/// Please see WebViewListener::InputMethodEditor.
	///
	/// Please note this is only compatible with Offscreen WebViews.
	///
	/// @param  activate  Whether or not IME should be activated.
	///
	void ActivateIME(bool activate)
	{
		aws_webview_activateIME(this, activate);
	}

	///
	/// Update the current IME text composition.
	///
	/// @param  input_string  The string generated by your IME.
	/// @param  cursor_pos    The current cursor position in your IME composition.
	/// @param  target_start  The position of the beginning of the selection.
	/// @param  target_end    The position of the end of the selection.
	///
	@disable void SetIMEComposition(string input_string,
								   int cursor_pos,
								   int target_start,
								   int target_end)
	{

	}

	///
	/// Confirm a current IME text composition.
	///
	/// @param  input_string  The string generated by your IME.
	///
	@disable void ConfirmIMEComposition(string input_string)
	{
		
	}

	///
	/// Cancel a current IME text composition.
	///
	void CancelIMEComposition()
	{
		aws_webview_cancelIMEComposition(this);
	}

	///
	/// Undo the last 'edit' operation. (Similar to CTRL+Z).
	///
	void Undo()
	{
		aws_webview_undo(this);
	}

	///
	/// Redo the last 'edit' operation. (Similar to CTRL+Y).
	///
	void Redo()
	{
		aws_webview_redo(this);
	}

	///
	/// Performs a 'cut' operation using the system clipboard.
	///
	void Cut()
	{
		aws_webview_cut(this);
	}

	///
	/// Performs a 'copy' operation using the system clipboard.
	///
	void Copy()
	{
		aws_webview_copy(this);
	}

	///
	/// Attempt to copy an image on the page to the system clipboard.
	/// This is meant to be used with Menu::OnShowContextMenu.
	///
	/// @param  x  The x-coordinate.
	///
	/// @param  y  The y-coordinate.
	///
	/// @note All coordinates should be localized to the view. All values are in
	///       pixels, the origin (0,0) begins at the top-left corner of the view,
	///       positive-y values are "down" and positive-x values are "right".
	///
	void CopyImageAt(int x, int y)
	{
		aws_webview_copyImageAt(this, x, y);
	}

	///
	/// Performs a 'paste' operation using the system clipboard.
	///
	void Paste()
	{
		aws_webview_paste(this);
	}

	///
	/// Performs a 'paste' operation using the system clipboard while attempting
	/// to preserve any styles of the original text.
	///
	void PasteAndMatchStyle()
	{
		aws_webview_pasteAndMatchStyle(this);
	}

	///
	/// Performs a 'select all' operation.
	///
	void SelectAll()
	{
		aws_webview_selectAll(this);
	}

	///
	/// Prints this WebView to a PDF file asynchronously.
	///
	/// @param  output_directory  A writeable directory to write the file(s) to.
	///
	/// @param  config  The configuration settings to use (you must specify
	///                 a writable output_path or this operation will fail).
	///
	/// @see WebView::set_print_listener
	///
	/// @return  Returns a unique request ID that you can use later to identify
	///          this specific request (see WebViewListener::Print). May return 0
	///          if this method fails prematurely (eg, if the view has crashed).
	///
	@disable int PrintToFile(string output_directory, PrintConfig config) 
	{
		return 0;
	}

	///
	/// Check if an error occurred during the last synchronous API call.
	///
	/// @see WebView::CreateGlobalJavascriptObject
	/// @see WebView::ExecuteJavascriptWithResult
	///
	@disable /*Error*/int last_error()
	{
		return 0;
	}

	///
	/// Create a JavaScript Object that will persist between all loaded pages.
	///
	/// @note
	///
	/// Global Objects can only contain the following JavaScript types as
	/// properties:
	///
	/// - Number
	/// - String
	/// - Array
	/// - Other Global Objects
	/// - Null
	/// - Undefined
	///
	/// Global Objects will retain any custom methods that are registered.
	///
	/// You can only create objects on pages with an active DOM. (You should
	/// wait until the first DOMReady event before creating your objects).
	///
	/// @param  name  The name of the object as it will appear in JavaScript.
	///               To create a child global-object, you should specify the
	///               the full name with dot-notation for example:
	///                  parentobject.childobject
	///
	///               The parent object should exist before attempting to make
	///               any children.
	///
	/// @return The returned JSValue will be of 'Object' type if this call
	/// succeeds. You can check the reason why the call failed by calling
	/// WebView::last_error() after this method.
	///
	@disable JSValue CreateGlobalJavascriptObject(string name)
	{
		return JSValue();
	}

	///
	/// Executes some JavaScript asynchronously on the page.
	///
	/// @param  script       The string of JavaScript to execute.
	///
	/// @param  frame_xpath  The xpath of the frame to execute within; leave
	///                      this blank to execute in the main frame.
	///
	void ExecuteJavascript(string script, string frame_xpath)
	{
		//aws_webview_executeJS(this, script.toCString, frame_xpath.toCString);
		aws_webview_executeJS(this, new WebString(script), new WebString(frame_xpath) );
	}

	///
	/// Executes some JavaScript synchronously on the page and returns a result.
	///
	/// @param  script       The string of JavaScript to execute.
	///
	/// @param  frame_xpath  The xpath of the frame to execute within; leave
	///                      this blank to execute in the main frame.
	///
	/// @return  Returns the result (if any). Any JSObject returned from this
	///          method will be a remote proxy for an object contained within
	///          the WebView process. If this call fails, JSValue will have an
	///          Undefined type. You can check WebView::last_error() for more
	///          information about the failure.
	///
	/// @note  You should never call this from within any of the following
	///        callbacks:
	///
	///        - JSMethodHandler::OnMethodCall
	///        - JSMethodHandler::OnMethodCallWithReturnValue
	///        - DataSource::OnRequest
	///
	@disable JSValue ExecuteJavascriptWithResult(string script, string frame_xpath)
	{
		return JSValue();
	}

	///
	/// Register a handler for custom JSObject methods.
	///
	/// @param  handler  The handler to register (you retain ownership).
	///
	/// @see JSObject::SetCustomMethod
	///
	//void set_js_method_handler(JSMethodHandler handler) ;

	/// Get the handler for custom JSObject methods.
	//JSMethodHandler* js_method_handler() = 0;

	///
	/// This method should be called as the result of a user selecting an item
	/// in a popup (dropdown) menu.
	///
	/// @param  item_index  The index of the item selected. Item index starts
	///                     at 0. You can pass -1 as a shortcut for
	///                     WebView::DidCancelPopupMenu.
	///
	/// @see  WebViewListener::Menu::OnShowPopupMenu
	///
	void DidSelectPopupMenuItem(int item_index)
	{
		aws_webview_didSelectPopupMenuItem(this, item_index);
	}

	///
	/// This method should be called as the result of a user cancelling a popup
	/// menu.
	///
	/// @see  WebViewListener::Menu::OnShowPopupMenu
	///
	void DidCancelPopupMenu()
	{
		aws_webview_didCancelPopupMenu(this);
	}

	///
	/// This method should be called as the result of a user selecting files in
	/// a file-chooser dialog.
	///
	/// @param  files  An array of file-paths that the user selected. If the
	///                user cancelled the dialog, you should pass an empty array.
	///
	/// @param  should_write_files  Whether or not this was a Save File dialog.
	///
	/// @see  WebViewListener::Dialog::OnShowFileChooser
	///
	@disable void DidChooseFiles(string[] files, bool should_write_files)
	{

	}

	///
	/// This method should be called as the result of a user supplying
	/// their credentials in a login dialog.
	///
	/// @param  request_id  The id of the request that was handled (see
	///                     WebLoginDialogInfo::request_id).
	///
	/// @param  username  The username supplied.
	///
	/// @param  password  The password supplied.
	///
	/// @see  WebViewListener::Dialog::OnShowLoginDialog
	///
	void DidLogin(int request_id, string username, string password)
	{
		aws_webview_didLogin(this, request_id, new WebString(username), new WebString(password));
	}

	///
	/// This method should be called as the result of a user cancelling
	/// a login dialog.
	///
	/// @param  request_id  The id of the request that was handled (see
	///                     WebLoginDialogInfo::request_id).
	///
	/// @see  WebViewListener::Dialog::OnShowLoginDialog
	///
	void DidCancelLogin(int request_id)
	{
		aws_webview_didCancelLogin(this, request_id);
	}

	///
	/// This method should be called as the result of a user selecting
	/// a path to download a file. The file will only begin downloading
	/// after this call is made.
	///
	/// @param  download_id  The id of the download.
	///
	/// @param  path  The full path (including filename) to write the download to.
	///
	/// @see  WebViewListener::Download::OnRequestDownload
	///
	void DidChooseDownloadPath(int download_id, string path)
	{
		aws_webview_didChooseDownloadPath(this, download_id, new WebString(path));
	}

	///
	/// This method should be called as the result of a user cancelling a
	/// download.
	///
	/// @param  download_id  The id of the download.
	///
	/// @see  WebViewListener::Download::OnRequestDownload
	///
	void DidCancelDownload(int download_id)
	{
		aws_webview_didCancelDownload(this, download_id);
	}

package:
	alias _internal this;
	cWebViewPtr_t _internal;

	void prepCallbacks()
	{
		aws_webview_setInternalViewHandler(this);
		aws_webview_setInternalLoadHandler(this);
		aws_webview_setInternalMenuHandler(this);
		aws_webview_setInternalDialogHandler(this);
		aws_webview_setInternalDownloadHandler(this);
		aws_webview_setInternalPrintHandler(this);
		aws_webview_setInternalIMEHandler(this);
		aws_webview_setInternalProcessHandler(this);

		aws_webview_setListenerView(this,_view._cbv);
		aws_webview_setListenerLoad(this,_load._cb);
		aws_webview_setListenerMenu(this,_menu._cb);
		aws_webview_setListenerDialog(this,_dialog._cb);
		aws_webview_setListenerProcess(this,_proc._cb);
		aws_webview_setListenerPrint(this,_print._cb);
		aws_webview_setListenerDownload(this,_download._cb);
		aws_webview_setListenerIME(this,_ime._cb);
	}

	@disable this()
	{

	}
	
	this(cWebViewPtr_t other)
	{
		// view
		if ( _view is null )
			_view = new ViewLsn();

		// load
		if ( _load is null )
			_load = new LoadLsn();

		// download
		if ( _download is null )
			_download = new DownloadLsn();

		// dialog
		if ( _dialog is null )
			_dialog = new DialogLsn();

		// process
		if ( _proc is null )
			_proc = new ProcLsn();

		// menu
		if ( _menu is null )
			_menu = new MenuLsn();

		// print
		if ( _print is null )
			_print = new PrintLsn();

		// ime
		if ( _ime is null )
			_ime = new IMELsn();

		_internal = other;
		_webviews[other] = this;
		prepCallbacks();
	}

	// static one-to-one mapping between C++ and D worlds
	static WebView[cWebViewPtr_t] _webviews;

private:
	/// internal webview objects, because they stored on the C++ side,
	/// we need to know when they changed to avoid unneeded instantiation

	WebSession _session;

	Surface _surface;

	final class ViewLsn : WebViewListener.View
	{
		// interferes with instance this
		//alias _cbv this;
		cWebView_View _cbv;

		
		this()
		{
			_cbv.address = &_onChangeAddressBar;
			_cbv.cursor = &_onChangeCursor;
			_cbv.focus = &_onChangeFocus;
			_cbv.show = &_onShowCreatedWebView;
			_cbv.title = &_onChangeTitle;
			_cbv.tooltip = &_onChangeTooltip;
			_cbv.url = &_onChangeTargetURL;
			
			_cbv.userPointer = cast(void*)this;
		}

		///
		/// internal View.OnChangeFocus handler which retransmit this callback
		static extern(C) void _onChangeFocus(cWebViewPtr_t caller, int focusedtype, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnChangeFocus(view, cast(FocusedElementType) focusedtype);
			}
		}

		///
		/// internal View.OnChangeAddressBar handler which retransmit this callback
		static extern(C) void _onChangeAddressBar(cWebViewPtr_t caller, const(cWebUrlPtr_t) url, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnChangeAddressBar(view, new WebURL(cast(cWebUrlPtr_t)url));
			}
		}

		///
		/// internal View.OnChangeAddressBar handler which retransmit this callback
		static extern(C) void _onChangeTitle(cWebViewPtr_t caller, const(cWebStringPtr_t) title, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnChangeTitle(view, cast(string)new WebString(title));
			}
		}

		///
		/// internal View.OnChangeTargetURL handler which retransmit this callback
		static extern(C) void _onChangeTargetURL(cWebViewPtr_t caller, const(cWebUrlPtr_t) targeturl, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null && lst is _view )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					_view.OnChangeTargetURL(view, new WebURL(cast(cWebUrlPtr_t)targeturl));
			}
		}

		///
		/// internal View.OnChangeCursor handler which retransmit this callback
		static extern(C) void _onChangeCursor(cWebViewPtr_t caller, int cursor, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnChangeCursor(view, cast(Cursor)cursor);
			}
		}

		///
		/// internal View.OnChangeFocus handler which retransmit this callback
		static extern(C) void _onChangeFocus(cWebViewPtr_t caller, FocusedElementType element, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnChangeFocus(view, cast(FocusedElementType)element);
			}
		}

		///
		/// internal View.OnChangeTooltip handler which retransmit this callback
		static extern(C) void _onChangeTooltip(cWebViewPtr_t caller, const(cWebStringPtr_t) tooltip, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null ) {
					lst.OnChangeTooltip(view, cast(string)new WebString(tooltip));
				}
			}
		}

		///
		/// internal View.OnShowCreatedWebView handler which retransmit this callback
		static extern(C) void _onShowCreatedWebView(cWebViewPtr_t caller, cWebViewPtr_t new_view, 
													const (cWebUrlPtr_t) opener_url,  const (cWebUrlPtr_t) target_url, 
													const (cRect)* initial_pos, bool is_popup, 
													void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ViewLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
				{
					_webviews[new_view] = new WebView(new_view);
					lst.OnShowCreatedWebView(view, 
											 _webviews[new_view],
											 new WebURL(cast(cWebUrlPtr_t)opener_url), 
											 new WebURL(cast(cWebUrlPtr_t)target_url),
											 Rect(*initial_pos), is_popup);
				}
			}
		}


		void OnChangeTitle(WebView caller, 
						   string title)
		{
			// get webview callback from caller if any
			auto viewlsn = caller._lsnview;

			// if callback attached call appropriate method
			if ( viewlsn !is null )
				viewlsn.OnChangeTitle(caller, title);
		}

		void OnChangeAddressBar(WebView caller,
								WebURL url)
		{
			// get webview callback from caller if any
			auto viewlsn = caller._lsnview;

			// if callback attached call appropriate method
			if ( viewlsn !is null )
				viewlsn.OnChangeAddressBar(caller, url);
		}

		void OnChangeTooltip(WebView caller,
							 string tooltip)
		{
			// get webview callback from caller if any
			auto viewlsn = caller._lsnview;

			// if callback attached call appropriate method
			if ( viewlsn !is null )
				viewlsn.OnChangeTooltip(caller, tooltip);
		}

		void OnChangeTargetURL(WebView caller,
							   WebURL url)
		{
			// get webview callback from caller if any
			auto viewlsn = caller._lsnview;

			// if callback attached call appropriate method
			if ( viewlsn !is null )
				viewlsn.OnChangeTargetURL(caller, url);
		}


		void OnChangeCursor(WebView caller,
							Cursor cursor)
		{
			// get webview callback from caller if any
			auto viewlsn = caller._lsnview;

			// if callback attached call appropriate method
			if ( viewlsn !is null )
				viewlsn.OnChangeCursor(caller, cursor);
		}

		void OnChangeFocus(WebView caller,
						   FocusedElementType focused_type)
		{
			// get webview callback from caller if any
			auto viewlsn = caller._lsnview;

			// if callback attached call appropriate method
			if ( viewlsn !is null )
				viewlsn.OnChangeFocus(caller, focused_type);
		}

		void OnShowCreatedWebView(WebView caller, WebView new_view, WebURL opener_url,
								  WebURL target_url, Rect initial_pos, bool is_popup)
		{
			// get webview callback from caller if any
			auto viewlsn = caller._lsnview;

			// if callback attached call appropriate method
			if ( viewlsn !is null )
				viewlsn.OnShowCreatedWebView(caller, new_view, opener_url,
													 target_url, initial_pos, is_popup);
		}
	} // class ViewLsn


	final class LoadLsn : WebViewListener.Load
	{
		cWebView_Load _cb;

		this()
		{
			_cb.begin = &_onBeginLoadingFrame;
			_cb.fail = &_onFailLoadingFrame;
			_cb.finish = &_onFinishLoadingFrame;
			_cb.ready = &_onDocumentReady;

			_cb.userPointer = cast(void*)this;
		}

		///
		/// internal Load.OnBeginLoadingFrame handler which retransmit this callback
		static extern(C) void _onBeginLoadingFrame(cWebViewPtr_t caller, aint64 frame_id,
												   bool is_main_frame, const cWebUrlPtr_t url,
												   bool is_error_page, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.LoadLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnBeginLoadingFrame(view, frame_id, is_main_frame,
											new WebUrl(cast(cWebUrlPtr_t)url), is_error_page);
			}
		}

		///
		/// internal Load.OnFailLoadingFrame handler which retransmit this callback
		static extern(C) void _onFailLoadingFrame(cWebViewPtr_t caller, aint64 frame_id,
												  bool is_main_frame, const cWebUrlPtr_t url,
												  int error_code, const cWebStringPtr_t error_desc,
												  void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.LoadLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnFailLoadingFrame(view, frame_id, is_main_frame,
											new WebUrl(cast(cWebUrlPtr_t)url), error_code,
											new WebString(error_desc));
			}
		}

		///
		/// internal Load.OnFinishLoadingFrame handler which retransmit this callback
		static extern(C) void _onFinishLoadingFrame(cWebViewPtr_t caller, aint64 frame_id, bool is_main_frame,
												  const cWebUrlPtr_t url, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.LoadLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnFinishLoadingFrame(view, frame_id, is_main_frame,
											new WebUrl(cast(cWebUrlPtr_t)url));
			}
		}

		///
		/// internal Load.OnDocumentReady handler which retransmit this callback
		static extern(C) void _onDocumentReady(cWebViewPtr_t caller, const cWebUrlPtr_t url, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.LoadLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnDocumentReady(view, new WebUrl(cast(cWebUrlPtr_t)url));
			}
		}

		
		void OnBeginLoadingFrame(WebView caller,
								 long frame_id,
								 bool is_main_frame,
								 WebURL url,
								 bool is_error_page)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnload;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnBeginLoadingFrame(caller, frame_id, is_main_frame,
										   url, is_error_page);
		}

		void OnFailLoadingFrame(WebView caller,
								long frame_id,
								bool is_main_frame,
								WebUrl url,
								int error_code,
								WebString error_desc)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnload;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnFailLoadingFrame(caller, frame_id, is_main_frame,
											 url, error_code, error_desc);
		}

		void OnFinishLoadingFrame(WebView caller,
								  long frame_id,
								  bool is_main_frame,
								  WebURL url)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnload;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnFinishLoadingFrame(caller, frame_id, is_main_frame, url);
		}

		void OnDocumentReady(WebView caller,
							 WebURL url)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnload;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnDocumentReady(caller, url);
		}
		
	} // class LoadLsn

	final class ProcLsn : WebViewListener.Process
	{
		cWebView_Process _cb;

		this()
		{
			_cb.responsive = &_onResponsive;
			_cb.unresponsive = &_onUnresponsive;
			_cb.crashed = &_onCrashed;

			_cb.userPointer = cast(void*)this;
		}

		///
		/// internal Process.OnResponsive handler which retransmit this callback
		static extern(C) void _onResponsive(cWebViewPtr_t caller, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ProcLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnResponsive(view);
			}
		}

		///
		/// internal Process.OnUnresponsive handler which retransmit this callback
		static extern(C) void _onUnresponsive(cWebViewPtr_t caller, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ProcLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnUnresponsive(view);
			}
		}

		///
		/// internal Process.OnCrashed handler which retransmit this callback
		static extern(C) void _onCrashed(cWebViewPtr_t caller, int status, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.ProcLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnCrashed(view,cast(TerminationStatus)status);
			}
		}

		void OnResponsive(WebView caller)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnproc;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnResponsive(caller);
		}

		void OnUnresponsive(WebView caller)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnproc;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnUnresponsive(caller);
		}

		void OnCrashed(WebView caller, TerminationStatus status)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnproc;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnCrashed(caller,status);
		}

	} // class ProcLsn

	final class MenuLsn : WebViewListener.Menu
	{
		cWebView_Menu _cb;

		this()
		{
			_cb.popup = &_onShowPopupMenu;
			_cb.context = &_onShowContextMenu;

			_cb.userPointer = cast(void*)this;
		}

		///
		/// internal Menu.OnShowPopupMenu handler which retransmit this callback
		static extern(C) void _onShowPopupMenu(cWebViewPtr_t caller, cWebPopupMenuInfo_t menu_info, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.MenuLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnShowPopupMenu(view, menu_info);
			}
		}

		///
		/// internal Menu.OnShowContextMenu handler which retransmit this callback
		static extern(C) void _onShowContextMenu(cWebViewPtr_t caller, cWebContextMenuInfo_t menu_info, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.MenuLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnShowContextMenu(view, menu_info);
			}
		}

		void OnShowPopupMenu(WebView caller, WebPopupMenuInfo menu_info)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnmenu;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnShowPopupMenu(caller, menu_info);
		}

		void OnShowContextMenu(WebView caller, WebContextMenuInfo menu_info)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnmenu;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnShowContextMenu(caller, menu_info);
		}

	} // class MenuLsn

	final class PrintLsn : WebViewListener.Print
	{
		cWebView_Print _cb;

		this()
		{
			_cb.fail = &_onFailPrint;
			_cb.finish = &_onFinishPrint;
			_cb.request = &_onRequestPrint;

			_cb.userPointer = cast(void*)this;
		}

		///
		/// internal Print.OnRequestPrint handler which retransmit this callback
		static extern(C) void _onRequestPrint(cWebViewPtr_t caller, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.PrintLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnRequestPrint(view);
			}
		}

		///
		/// internal Print.OnFinishPrint handler which retransmit this callback
		static extern(C) void _onFinishPrint(cWebViewPtr_t caller, int request_id, const cWebStringArrayPtr_t filelist, void* userPtr)
		{
			pragma (msg, "fix me: WebStringArray not implemented [file: " , __FILE__ , ", line:" , __LINE__ , "]" );
			// get pointer to object
			auto lst = cast(WebView.PrintLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnFinishPrint(view, request_id, cast(cWebStringArrayPtr_t)filelist);
			}
		}


		///
		/// internal Print.OnFailPrint handler which retransmit this callback
		static extern(C) void _onFailPrint(cWebViewPtr_t caller, int request_id, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.PrintLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnFailPrint(view, request_id);
			}
		}


		void OnRequestPrint(WebView caller)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnprint;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnRequestPrint(caller);
		}

		void OnFailPrint(WebView caller, int request_id)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnprint;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnFailPrint(caller, request_id);
		}

		void OnFinishPrint(WebView caller, int request_id, WebStringArray file_list)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnprint;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnFinishPrint(caller, request_id, file_list);
		}

	} // class PrintLsn

	final class DialogLsn : WebViewListener.Dialog
	{
		cWebView_Dialog _cb;

		this()
		{
			_cb.file = &_onShowFileChooser;
			_cb.login = &_onShowLoginDialog;

			_cb.userPointer = cast(void*)this;
		}

		///
		/// internal Dialog.OnShowFileChooser handler which retransmit this callback
		static extern(C) void _onShowFileChooser(cWebViewPtr_t caller, cWebFileChooserInfo_t chooser_info, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.DialogLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnShowFileChooser(view, chooser_info);
			}
		}

		///
		/// internal Dialog.OnShowLoginDialog handler which retransmit this callback
		static extern(C) void _onShowLoginDialog(cWebViewPtr_t caller, cWebLoginDialogInfo_t dialog_info, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.DialogLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnShowLoginDialog(view, dialog_info);
			}
		}

		void OnShowFileChooser(WebView caller,
							   WebFileChooserInfo chooser_info)
		{
			// get webview callback from caller if any
			auto listener = caller._lsndialog;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnShowFileChooser(caller, chooser_info);
		}

		void OnShowLoginDialog(WebView caller,
							   WebLoginDialogInfo dialog_info)
		{
			// get webview callback from caller if any
			auto listener = caller._lsndialog;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnShowLoginDialog(caller, dialog_info);
		}

	} // class DialogLsn


	final class DownloadLsn : WebViewListener.Download
	{
		cWebView_Download _cb;

		this()
		{
			_cb.request = &_onRequestDownload;
			_cb.update = &_onUpdateDownload;
			_cb.finish = &_onFinishDownload;

			_cb.userPointer = cast(void*)this;
		}

		///
		/// internal Download.OnRequestDownload handler which retransmit this callback
		static extern(C) void _onRequestDownload(cWebViewPtr_t caller, int download_id,
												 const cWebUrlPtr_t url,
												 const cWebStringPtr_t suggested_filename,
												 const cWebStringPtr_t mime_type,
												 void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.DownloadLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnRequestDownload(view, download_id, new WebUrl(cast(cWebUrlPtr_t)url), 
										  new WebString(suggested_filename), new WebString(mime_type));
			}
		}

		///
		/// internal Download.OnUpdateDownload handler which retransmit this callback
		static extern(C) void _onUpdateDownload(cWebViewPtr_t caller,
												int download_id,
												aint64 total_bytes,
												aint64 received_bytes,
												aint64 current_speed,
												void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.DownloadLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnUpdateDownload(view, download_id, total_bytes, received_bytes, current_speed);
			}
		}

		///
		/// internal Download.OnFinishDownload handler which retransmit this callback
		static extern(C) void _onFinishDownload(cWebViewPtr_t caller,
												int download_id,
												const (cWebUrlPtr_t) url,
												const (cWebStringPtr_t) saved_path,
												void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.DownloadLsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnFinishDownload(view, download_id, new WebUrl(cast(cWebUrlPtr_t)url), new WebString(saved_path));
			}
		}


		void OnRequestDownload(WebView caller,
							   int download_id,
							   WebURL url,
							   WebString suggested_filename,
							   WebString mime_type)
		{
			// get webview callback from caller if any
			auto listener = caller._lsndownload;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnRequestDownload(caller, download_id, url, suggested_filename, mime_type);
		}

		
		void OnUpdateDownload(WebView caller,
							  int download_id,
							  long total_bytes,
							  long received_bytes,
							  long current_speed)
		{
			// get webview callback from caller if any
			auto listener = caller._lsndownload;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnUpdateDownload(caller, download_id, total_bytes, received_bytes, current_speed);
		}

		void OnFinishDownload(WebView caller,
							  int download_id,
							  WebURL url,
							  WebString saved_path)
		{
			// get webview callback from caller if any
			auto listener = caller._lsndownload;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnFinishDownload(caller, download_id, url, saved_path);
		}

	} // class DownloadLsn


	final class IMELsn : WebViewListener.InputMethodEditor
	{
		cWebView_IME _cb;

		this()
		{
			_cb.cancel = &_onCancelIME;
			_cb.range = &_onChangeIMERange;
			_cb.update = &_onUpdateIME;

			_cb.userPointer = cast(void*)this;
		}

		///
		/// internal IME.OnUpdateIME handler which retransmit this callback
		static extern(C) void _onUpdateIME(cWebViewPtr_t caller, int type, int caret_x, int caret_y, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.IMELsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnUpdateIME(view, cast(TextInputType)type, caret_x, caret_y);
			}
		}

		///
		/// internal IME.OnCancelIME handler which retransmit this callback
		static extern(C) void _onCancelIME(cWebViewPtr_t caller, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.IMELsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnCancelIME(view);
			}
		}

		///
		/// internal IME.OnChangeIMERange handler which retransmit this callback
		static extern(C) void _onChangeIMERange(cWebViewPtr_t caller, uint start, uint end, void* userPtr)
		{
			// get pointer to object
			auto lst = cast(WebView.IMELsn)userPtr;

			// check if valid
			if ( lst !is null )
			{
				auto view = _webviews[caller];
				if ( view !is null )
					lst.OnChangeIMERange(view, start, end);
			}
		}

		void OnUpdateIME(WebView caller,
						 TextInputType type,
						 int caret_x,
						 int caret_y)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnime;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnUpdateIME(caller, type, caret_x, caret_y);
		}

		void OnCancelIME(WebView caller)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnime;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnCancelIME(caller);
		}

		void OnChangeIMERange(WebView caller,
							  uint start,
							  uint end)
		{
			// get webview callback from caller if any
			auto listener = caller._lsnime;

			// if callback attached call appropriate method
			if ( listener !is null )
				listener.OnChangeIMERange(caller, start, end);
		}

	} // class IMELsn

	static ViewLsn _view;
	static LoadLsn _load;
	static ProcLsn _proc;
	static MenuLsn _menu;
	static PrintLsn _print;
	static DialogLsn _dialog;
	static DownloadLsn _download;
	static IMELsn _ime;

	WebViewListener.View _lsnview;
	WebViewListener.Load _lsnload;
	WebViewListener.Process _lsnproc;
	WebViewListener.Menu _lsnmenu;
	WebViewListener.Print _lsnprint;
	WebViewListener.Dialog _lsndialog;
	WebViewListener.Download _lsndownload;
	WebViewListener.InputMethodEditor _lsnime;
}


/// formal interface for listeners
interface IWebViewListener {}

/// class containing all WebView event-listeners
final class WebViewListener
{
public:

	@disable this() {}

	///
	/// @brief  An interface that you can use to handle all View-related events
	///         for a certain WebView.
	///
	/// @note  See WebView.set_view_listener
	///
	interface View : IWebViewListener
	{
		/// This event occurs when the page title has changed.
		void OnChangeTitle(WebView caller, 
									string title);

		/// This event occurs when the page URL has changed.
		void OnChangeAddressBar(WebView caller,
										WebURL url);

		/// This event occurs when the tooltip text has changed. You
		/// should hide the tooltip when the text is empty.
		void OnChangeTooltip(WebView caller,
									 string tooltip);

		/// This event occurs when the target URL has changed. This
		/// is usually the result of hovering over a link on a page.
		void OnChangeTargetURL(WebView caller,
									   WebURL url);

		/// This event occurs when the cursor has changed. This is
		/// is usually the result of hovering over different content.
		void OnChangeCursor(WebView caller,
									Cursor cursor);

		/// This event occurs when the focused element changes on the page.
		/// This is usually the result of textbox being focused or some other
		/// user-interaction event.
		void OnChangeFocus(WebView caller,
								   FocusedElementType focused_type);

		/// This event occurs when a WebView creates a new child WebView
		/// (usually the result of window.open or an external link). It
		/// is your responsibility to display this child WebView in your
		/// application. You should call Resize on the child WebView
		/// immediately after this event to make it match your container
		/// size.
		///
		/// If this is a child of a Windowed WebView, you should call
		/// WebView.set_parent_window on the new view immediately within
		/// this event.
		///
		void OnShowCreatedWebView(WebView caller,
										  WebView new_view,
										  WebURL opener_url,
										  WebURL target_url,
										  Rect initial_pos,
										  bool is_popup);
	}



	///
	/// @brief  An interface that you can use to handle all page-loading
	///         events for a certain WebView.
	///
	/// @note: See WebView.SetLoadListener
	///
	interface Load : IWebViewListener 
	{
		/// This event occurs when the page begins loading a frame.
		void OnBeginLoadingFrame(WebView caller,
										 long frame_id,
										 bool is_main_frame,
										 WebUrl url,
										 bool is_error_page);

		/// This event occurs when a frame fails to load. See error_desc
		/// for additional information.
		void OnFailLoadingFrame(WebView caller,
										long frame_id,
										bool is_main_frame,
										WebUrl url,
										int error_code,
										WebString error_desc);

		/// This event occurs when the page finishes loading a frame.
		/// The main frame always finishes loading last for a given page load.
		void OnFinishLoadingFrame(WebView caller,
										  long frame_id,
										  bool is_main_frame,
										  WebURL url) ;

		/// This event occurs when the DOM has finished parsing and the
		/// window object is available for JavaScript execution.
		void OnDocumentReady(WebView caller,
									 WebURL url);
	}



	///
	/// @brief  An interface that you can use to handle all process-related
	///         events for a certain WebView.
	///
	/// Each WebView has an associated "render" process, you can use these events
	/// to recover from crashes or hangs).
	///
	/// @note  See WebView.set_process_listener
	///
	interface Process : IWebViewListener
	{
		/// This event occurs when the process hangs.
		void OnUnresponsive(WebView caller);

		/// This event occurs when the process becomes responsive after
		///	a hang.
		void OnResponsive(WebView caller);

		/// This event occurs when the process crashes.
		void OnCrashed(WebView caller,
						   TerminationStatus status);
	}

	///
	/// @brief  An interface that you can use to handle all menu-related events
	///         for a certain WebView.
	///
	/// @note  See WebView.set_menu_listener
	///
	interface Menu : IWebViewListener
	{
		///
		/// This event occurs when the page requests to display a dropdown
		/// (popup) menu. This is usually the result of a user clicking on
		/// a "select" HTML input element. It is your responsibility to
		/// display this menu in your application. This event is not modal.
		///
		/// @see WebView.DidSelectPopupMenuItem
		/// @see WebView.DidCancelPopupMenu
		///
		void OnShowPopupMenu(WebView caller,
									 WebPopupMenuInfo menu_info);

		///
		/// This event occurs when the page requests to display a context menu.
		/// This is usually the result of a user right-clicking somewhere on the
		/// page. It is your responsibility to display this menu in your
		/// application and perform the selected actions. This event is not modal.
		///
		void OnShowContextMenu(WebView caller,
									   WebContextMenuInfo menu_info);
	}



	///
	/// @brief  An interface that you can use to handle all dialog-related events
	///         for a certain WebView.
	///
	/// @see  WebView.set_dialog_listener
	///
	interface Dialog : IWebViewListener
	{
		///
		/// This event occurs when the page requests to display a file chooser
		/// dialog. This is usually the result of a user clicking on an HTML
		/// input element with `type='file`. It is your responsibility to display
		/// this menu in your application. This event is not modal.
		///
		/// @see WebView.DidChooseFiles
		///
		void OnShowFileChooser(WebView caller,
									   WebFileChooserInfo chooser_info);

		///
		/// This event occurs when the page needs authentication from the user (for
		/// example, Basic HTTP Auth, NTLM Auth, etc). It is your responsibility to
		/// display a dialog so that users can input their username and password.
		/// This event is not modal.
		///
		/// @see WebView.DidLogin
		/// @see WebView.DidCancelLogin
		///
		void OnShowLoginDialog(WebView caller,
									   WebLoginDialogInfo dialog_info);
	}


	///
	/// @brief  An interface that you can use to handle all print-related events
	///         for a certain WebView.
	///
	/// @see  WebView.set_print_listener
	///
	interface Print : IWebViewListener
	{
		///
		/// This event occurs when the page requests to print itself. (Usually
		/// the result of `window.print()` being called from JavaScript.) It is
		/// your responsiblity to print the WebView to a file and handle the
		/// actual device printing.
		///
		/// @see  WebView.PrintToFile
		///
		void OnRequestPrint(WebView caller);

		///
		/// This event occurs when WebView.PrintToFile fails. Typically because of
		/// bad printer configuration or invalid output path (it must be writable).
		///
		/// @param  request_id  The unique request ID (returned from
		///                     WebView.PrintToFile earlier).
		///
		void OnFailPrint(WebView caller,
								 int request_id);

		///
		/// This event occurs when WebView.PrintToFile succeeds.
		///
		/// @param  request_id  The unique request ID (returned from
		///                     WebView.PrintToFile earlier).
		///
		/// @param  file_list  The list of file-paths written. There may be multiple
		///                    files written if split_pages_into_multiple_files was
		///                    set to true in PrintConfig.
		///
		void OnFinishPrint(WebView caller,
								   int request_id,
								   WebStringArray file_list);
	}

	///
	/// @brief  An interface that you can use to handle all download-related events
	///         for a certain WebView.
	///
	/// @see  WebView.set_download_listener
	///
	interface Download : IWebViewListener
	{
		///
		/// This event occurs when the page requests to begin downloading a certain
		/// file. It is your responsiblity to call WebView.DidChooseDownloadPath or
		/// WebView.DidCancelDownload as a result of this event.
		///
		/// @param  download_id  The unique ID of the download.
		///
		/// @param  url  The URL that initiated the download.
		///
		/// @param  suggested_filename  The suggested name for the file.
		///
		/// @param  mime_type  The mime type of the file.
		///
		void OnRequestDownload(WebView caller,
									   int download_id,
									   WebURL url,
									   WebString suggested_filename,
									   WebString mime_type);

		///
		/// This event occurs when the progress of the download is updated.
		///
		/// @param  download_id  The unique ID of the download.
		///
		/// @param  total_bytes  The total number of bytes (may be 0 if unknown).
		///
		/// @param  received_bytes  The number of bytes received so far.
		///
		/// @param  current_speed  The current speed in bytes per second.
		///
		void OnUpdateDownload(WebView caller,
									  int download_id,
									  long total_bytes,
									  long received_bytes,
									  long current_speed);

		///
		/// This event occurs when the download is finished.
		///
		/// @param  download_id  The unique ID of the download.
		///
		/// @param  url  The URL that initiated the download.
		///
		/// @param  saved_path  The path that the download was saved to.
		///
		void OnFinishDownload(WebView caller,
									  int download_id,
									  WebURL url,
									  WebString saved_path);
	}

	///
	/// @brief  An interface that you can use to handle all IME-related events
	///         for a certain WebView.
	///
	/// @see  WebView.set_input_method_editor_listener
	///
	interface InputMethodEditor : IWebViewListener
	{
		///
		/// You should handle this message if you are displaying your
		/// own IME (input method editor) widget.
		///
		/// This event is fired whenever the user does something that may change
		/// the position, visiblity, or type of the IME Widget. This event is only
		/// active when IME is active (please see WebView::ActivateIME).
		///
		/// @param  caller  The WebView that fired this event.
		///
		/// @param  type  The type of IME widget that should be displayed (if any).
		///
		/// @param  caret_x  The x-position of the caret (relative to the View).
		/// @param  caret_y  The y-position of the caret (relative to the View).
		///
		void OnUpdateIME(WebView caller,
								 TextInputType type,
								 int caret_x,
								 int caret_y);

		///
		/// This event is fired when the page cancels the IME composition.
		///
		void OnCancelIME(WebView caller);

		///
		/// This event is fired when the page changes the displayed range
		/// of the IME composition.
		///
		void OnChangeIMERange(WebView caller,
									  uint start,
									  uint end);
	}

} // interface WebViewListener



// this is the part of webview config so let it be here for now
struct WebPreferences {

///
/// Whether or not JavaScript should be enabled. (Default: true)
///
bool enable_javascript = true;

///
/// Whether or not Dart (experimental) should be enabled. (Default: true)
///
bool enable_dart = true;

///
/// Whether or not plugins (Flash, Silverlight) should be enabled.
/// (Default: true)
///
bool enable_plugins = true;

///
/// Whether or not HTML5 Local Storage should be enabled. (Default: true)
///
bool enable_local_storage = true;

///
/// Whether or not HTML5 Databases should be enabled. (Default: false)
///
bool enable_databases = false;

///
/// Whether or not HTML5 App Cache should be enabled. (Default: true)
///
bool enable_app_cache = true;

///
/// Whether or not HTML5 WebAudio should be enabled. (Default: true)
///
bool enable_web_audio = true;

///
/// Whether or not HTML5 WebGL (experimental) should be enabled.
/// (Default: false)
///
bool enable_web_gl = false;

///
/// Whether or not web security should be enabled (prevents cross-domain
/// requests, for example). (Default: true)
///
bool enable_web_security = true;

///
/// Whether or not remote fonts should be enabled. (Default: true)
///
bool enable_remote_fonts = true;

///
/// Whether or not smooth scrolling should be enabled. (Default: false)
///
bool enable_smooth_scrolling = false;

///
/// Whether or not GPU accelerated compositing (experimental) should be
/// enabled. This is only compatible with windowed WebViews at this time.
/// (Default: false)
///
bool enable_gpu_acceleration = false;

///
/// User-defined CSS to be applied to all web-pages. This is useful for
/// overriding default styles. (Default: empty)
///
string user_stylesheet;

///
/// Proxy configuration string.
///
/// @note  Can either be: "auto" (use the OS proxy config), "none" (ignore
///        proxy settings), or you can specify a hardcoded proxy config
///        string, for example: "myproxyserver.com:80". (Default: "auto")
///
string proxy_config = "auto";

///
/// The accept-language for the browser (Default: "en-us,en")
///
string accept_language = "en-us,en";

///
/// The accept-charset for the browser (Default: "iso-8859-1,*,utf-8")
///
string accept_charset = "iso-8859-1,*,utf-8";

///
/// The default encoding for the browser (Default: "iso-8859-1")
///
string default_encoding = "iso-8859-1";

///
/// Whether or not standalone images should be shrunk to fit the view.
/// (Default: true)
///
bool shrink_standalone_images_to_fit = true;

///
/// Whether or not images should be loaded automatically on the page.
/// (Default: true)
///
bool load_images_automatically = true;

///
/// Whether or not scripts are allowed to open windows. (Default: true)
///
bool allow_scripts_to_open_windows = true;

///
/// Whether or not scripts are allowed to close windows. (Default: true)
///
bool allow_scripts_to_close_windows = true;

///
/// Whether or not scripts are allowed to access the clipboard.
/// (Default: false)
///
bool allow_scripts_to_access_clipboard = false;

///
/// Whether or not local files can access other local files. (Default: false)
///
bool allow_universal_access_from_file_url = false;

///
/// Whether or not scripts are allowed to open windows. (Default: false)
///
bool allow_file_access_from_file_url = false;

///
/// Whether or not insecure content is displayed and/or run. (Default: true)
///
bool allow_running_insecure_content = true;
};