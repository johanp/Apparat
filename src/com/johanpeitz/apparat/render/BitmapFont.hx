package com.johanpeitz.apparat.render;


import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.johanpeitz.apparat.utils.Log;
import haxe.Json;


	typedef _GlyphData = {
		ch:String,
		x:Int, y:Int, w:Int, h:Int, kx:Int, ky:Int, kw:Int, kh:Int    
	};
	
	typedef _GlyphPack = {
		letters:Array< _GlyphData >
	};

	
/**
 * Holds information and bitmap glpyhs for a bitmap font.
 * @author Johan Peitz
 */
class BitmapFont extends Atlas {
	
	private var _glyphs : String;
	private var _maxHeight : Int = 0;
	private var _glyphKerning : Array< Rectangle >;
	private var _rectangles : Array< Rectangle >;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 * @param	pBitmapData	The bitmap data to copy letters from.
	 * @param	pLetters	String of letters available in the bitmap data.
	 * @param	pRectangles	List of rectangles for the letters.
	 */
	public function new( pBitmapData : BitmapData, pGlyphs : String, pRectangles : Array< Rectangle >, pKerning : Array< Rectangle > ) {
		super( pBitmapData, pRectangles );
		
		_glyphs = pGlyphs;
		
		_glyphKerning = pKerning;
		
		_rectangles = pRectangles;
		
		// get the highest glyph
		for ( i in 0 ... _glyphKerning.length ) {
			if ( _glyphKerning[ i ].height > _maxHeight ) {
				_maxHeight = Std.int( _glyphKerning[ i ].height );
			}
		}
	}

	/**
	 * Clears all resources used by the font.
	 */
	override public function dispose() : Void {
		_glyphKerning = null;
		_rectangles = null;
		super.dispose();
		
	}

	/**
	 * Creates a clone of the font. Can be used to add outlines and shadows.
	 * 
	 * @param	pOutlineMode	0 = no outline, 1 = thin outline, 2 = total outline
	 * @param	pShadow			adds drop shadow if true
	 * @return	clone of the font
	 */
	public function clone( pOutlineMode : Int = 0, pShadow : Bool = false ) : BitmapFont {
		var rects : Array< Rectangle > = new Array< Rectangle >();
		var kerns : Array< Rectangle > = new Array< Rectangle >();
		var bd : BitmapData = new BitmapData( _bitmapData.width + 2, _bitmapData.height + 2, true, Apparat.COLOR_MAGIC_PINK );
		var matrix : Matrix = new Matrix();
		
		// outlines
		var black : ColorTransform = new ColorTransform( 0, 0, 0 );
		
		if ( pOutlineMode > 0 ) {
			matrix.identity();
			matrix.translate( 1, 0 );
			bd.draw( _bitmapData, matrix, black );
			matrix.identity();
			matrix.translate( 0, 1 );
			bd.draw( _bitmapData, matrix, black );
			matrix.identity();
			matrix.translate( 1, 2 );
			bd.draw( _bitmapData, matrix, black );
			matrix.identity();
			matrix.translate( 2, 1 );
			bd.draw( _bitmapData, matrix, black );
		}	
		
		if ( pOutlineMode > 1 ) {
			matrix.identity();
			matrix.translate( 0, 0 );
			bd.draw( _bitmapData, matrix, black );
			matrix.identity();
			matrix.translate( 0, 2 );
			bd.draw( _bitmapData, matrix, black );
			matrix.identity();
			matrix.translate( 2, 0 );
			bd.draw( _bitmapData, matrix, black );
			matrix.identity();
		}
		if ( pOutlineMode > 1 || pShadow ) {
			matrix.translate( 2, 2 );
			bd.draw( _bitmapData, matrix, black );
		}

		// original
		matrix.identity();
		matrix.translate( 1, 1 );
		bd.draw( _bitmapData, matrix );
		
		for ( i in 0 ... _rectangles.length ) {
			rects.push( new Rectangle( _rectangles[i].x, _rectangles[i].y, _rectangles[i].width + 2, _rectangles[i].height + 2 ) );
			kerns.push( new Rectangle( _glyphKerning[i].x, _glyphKerning[i].y, _glyphKerning[i].width, _glyphKerning[i].height ) );
		}
		
		return new BitmapFont( bd, _glyphs, rects, kerns );
	}
	
	/**
	 * Returns string of available letters in the font.
	 * @return	string of letters
	 */
	public function getGlyphs() : String {
		return _glyphs;
	}
	
	/**
	 * Returns the tile ID of a character.
	 * @param	pCharacter	which character to look up
	 * @return	tile ID of character
	 */
	public function getTileID( pCharacter : String ) : Int {
		return _glyphs.indexOf( pCharacter );
	}

	/**
	 * Returns the kerning data for a specific tile
	 * @param	pTileID	tile to look up
	 * @return	kerning data
	 */
	public function charKerning( pTileID : Int ) : Rectangle {
		return _glyphKerning[ pTileID ];
	}
	

	/**
	 * Returns the width of a certain test string.
	 * @param	pText	String to measure.
	 * @return	Width in pixels.
	 */
	public function getTextWidth( pText : String ) : Int {
		var w : Float = 0;
 
		for ( i in 0...( pText.length ) ) {
			w += _glyphKerning[ getTileID( pText.charAt( i ) ) ].width - _glyphKerning[ getTileID( pText.charAt( i ) ) ].x;
		}

		return Std.int( w );
	}

	/**
	 * Returns height of font in pixels.
	 * @return Height of font in pixels.
	 */
	public var fontHeight( get_fontHeight, null ) : Int;
	private function get_fontHeight() : Int {
		return _maxHeight;
	}


	/**
	 * Creates a new BitmapFont from bitmap data and font data in json
	 * @param	pBitmapData	image to use
	 * @param	pJSON	font data in json string
	 * @return	created font
	 */
	public static function createBitmapFont( pBitmapData : BitmapData, pJSON : String ) : BitmapFont {
        var letters : String = "";
        var rectangles : Array< Rectangle > = new Array< Rectangle >();
		var kerning : Array< Rectangle > = new Array< Rectangle >();
	
		var glyphs : _GlyphPack = Json.parse( pJSON );		
		for ( g in glyphs.letters ) {
            letters += g.ch;
            rectangles.push( new Rectangle( g.x, g.y, g.w, g.h ) );
            kerning.push( new Rectangle( g.kx, g.ky, g.kw, g.kh ) );
		}
        
        return new BitmapFont( pBitmapData, letters, rectangles, kerning );
	}
	
}


