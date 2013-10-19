/*
This file is a part of aws_wrap library.
Read LICENSE.TXT and README.TXT provided 
within this package for more information.

Copyright (C) 2012 evilrat
*/

module awesomium.surface;

import awesomium.capi, awesomium.common,
	awesomium.util, awesomium.webview,
	awesomium.webstring;


///
/// @brief  This interface can be used to provide your own Surface
///         implementation to directly handle paint and pixel-scroll events
///         for all offscreen WebViews.
///
/// You should use this by defining your own SurfaceFactory that creates
/// your specific Surface implementation.
///
/// @note  See WebView::surface
///
interface Surface 
{
public:
  ///
  /// This event is called whenever the WebView wants to paint a certain section
  /// of the Surface with a block of pixels. It is your responsibility to copy
  /// src_buffer to the location in this Surface specified by dest_rect.
  ///
  /// @param src_buffer  A pointer to a block of pixels in 32-bit BGRA format.
  ///                    Size of the buffer is `src_row_span * src_rect.height`.
  ///                    Beware that src_buffer points to the beginning of the
  ///                    transport buffer, you should use src_rect to determine
  ///                    the offset to begin copying pixels from.
  ///
  /// @param src_row_span  The number of bytes of each row.
  ///                      (Usually `src_rect.width * 4`)
  ///
  /// @param src_rect  The dimensions of the region of src_buffer to copy from.
  ///                  May have a non-zero origin.
  ///
  /// @param dest_rect The location to copy src_buffer to. Always has same
  ///                  dimensions as src_rect but may have different origin
  ///                  (which specifies the offset of the section to copy to).
  ///
  void Paint(ubyte* src_buffer,
					int src_row_span,
					Rect src_rect,
					Rect dest_rect);

  ///
  /// This event is called whenever the WebView wants to 'scroll' an existing
  /// section of the Surface by a certain offset. It your responsibility to
  /// translate the pixels within the specified clipping rectangle by the
  /// specified offset.
  /// 
  /// @param dx  The amount of pixels to offset vertically.
  /// @param dy  The amount of pixels to offset vertically.
  /// 
  /// @param clip_rect  The rectangle that this operation should be clipped to.
  /// 
  void Scroll(int dx,
			    int dy,
				Rect clip_rect);

 package:
  ///
  /// return internal pointer which points to C++ object
  void* getInternalPointer();
}


/// 
/// @brief  This is the default Surface for WebView. It is a basic bitmap
///         that keeps track of whether or not it has changed since the
///         last time you called BitmapSurface::CopyTo.
///
class BitmapSurface : Surface 
{
public: 
	this(int width, int height)
	{
		_internal = aws_bitmapsurface_new(width, height);
	}
	
	~this()
	{
		if ( _owner )
			aws_bitmapsurface_delete(this);

		_internal = null;
	}
	
	/// A pointer to the raw pixel buffer (32-bit BGRA format, 4 bpp)
	@property const(ubyte)* buffer() { return aws_bitmapsurface_getBuffer(this); }
	
	/// Get the width of the bitmap (in pixels)
	@property int width() { return aws_bitmapsurface_getWidth(this); }
	
	/// Get the height of the bitmap (in pixels)
	@property int height() { return aws_bitmapsurface_getHeight(this); }

	/// The number of bytes per row (this is usually `width * 4`)
	@property int row_span() { return aws_bitmapsurface_getRowSpan(this); }

	///
	/// Manually set this bitmap as dirty (useful if you copied the
	/// bitmap buffer without the CopyTo method).
	///
	void set_is_dirty(bool is_dirty)
	{
		aws_bitmapsurface_setIsDirty(this, is_dirty);
	}

	///
	/// Whether or not the bitmap has changed since the last
	/// time CopyTo was called.
	///
	@property bool is_dirty() { return aws_bitmapsurface_isDirty(this); }
	
	///
	/// Copy this bitmap to a certain destination. Will also set the dirty
	/// bit to False.
	///
	/// @param  dest_buffer  A pointer to the destination pixel buffer.
	///
	/// @param  dest_row_span  The number of bytes per-row of the destination.
	///
	/// @param  dest_depth  The depth (number of bytes per pixel, is usually 4
	///                     for BGRA surfaces and 3 for BGR surfaces).
	///
	/// @param  convert_to_rgba  Whether or not we should convert BGRA to RGBA.
	///
	/// @param  flip_y  Whether or not we should invert the bitmap vertically.
	///
	void CopyTo(ubyte* dest_buffer,
		int dest_row_span,
		int dest_depth,
		bool convert_to_rgba,
		bool flip_y)
	{
		aws_bitmapsurface_copyTo(this, dest_buffer, dest_row_span, dest_depth, convert_to_rgba, flip_y);
	}
	
	///
	/// Save this bitmap to a PNG image on disk.
	///
	/// @param  file_path  The file path (should have filename ending in .png).
	///
	/// @param  preserve_transparency  Whether or not we should preserve the
	///                                alpha channel.
	///
	/// @return  Returns true if the operation succeeded.
	///
	bool SaveToPNG(string file_path,
                 bool preserve_transparency = false)
	{
		return aws_bitmapsurface_saveToPNG(this, new WebString(file_path), preserve_transparency);
	}
	
	///
	/// Save this bitmap to a JPEG image on disk.
	///
	/// @param  file_path  The file path (should have filename ending in .jpg).
	///
	/// @param  quality  The compression quality (1-100, with 100 being best
	///                  picture quality but highest file size).
	///
	/// @return  Returns true if the operation succeeded.
	///
	bool SaveToJPEG(string file_path, int quality = 90)
	{
		return aws_bitmapsurface_saveToJPEG(this, new WebString(file_path), quality);
	}
	
	/// Get the opacity (0-255) of a certain point (in pixels).
	ubyte GetAlphaAtPoint(int x, int y)
	{
		return aws_bitmapsurface_getAlphaAtPoint(this, x,y);
	}
	
	
	///
	/// This method is inherited from Surface, it is called by the WebView
	/// whenever a block of pixels needs to be painted to the bitmap.
	///
	void Paint(ubyte* src_buffer,
             int src_row_span,
             Rect src_rect,
             Rect dest_rect)
	{
		//aws_bitmapsurface_paint(this, src_buffer, src_row_span, src_rect.toCRect, dest_rect.toCRect);
	}
	
	
	///
	/// This method is inherited from Surface, it is called by the WebView
	/// whenever a block of pixels needs to be translated on the bitmap.
	///
	void Scroll(int dx, int dy, Rect clip_rect)
	{
	
	}

package:
	this() {};

	alias _internal this;
	cBitSurfacePtr_t _internal;

	void* getInternalPointer()
	{
		return _internal;
	}

	// is the current objects instance owner, used to prevent overreleasing
	bool _owner = true;
}