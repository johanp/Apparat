package com.johanpeitz.apparat.render;

import com.johanpeitz.apparat.utils.Log;
import openfl.geom.Rectangle;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Tilesheet;

	

/**
 * ...
 * @author Johan Peitz
 */
class Atlas {

	private var _tilesheet : Tilesheet;	
	private var _bitmapData : BitmapData;
	private var _animations : Map<String, Animation>;
	
	/**
	 * Name of Atlas, can be used for debug.
	 */
	public var name : String = "unnamed";
	
	/**
	 * Creates a new Atlas.
	 * @param	pBitmapData		Image to pull tiles from.
	 * @param	pRectangles		Array of rectangles specifying which tiles to pull from. Set to null to use entire image.
	 * @param	pRepeatFirst	If true, only the first rectangle in pRectangles will be used, and only the width and height parameters too. That data will then be used to cut out as many tiles as possible from the image. Suitable for tile maps.
	 */
	public function new( pBitmapData : BitmapData, pRectangles : Array<Rectangle> = null, pRepeatFirst : Bool = false ) {
		_bitmapData = pBitmapData;
		name = "unnamed";
				
		_tilesheet = new Tilesheet( _bitmapData );
		if ( pRectangles == null ) {
			_tilesheet.addTileRect( new Rectangle( 0, 0, _bitmapData.width, _bitmapData.height ) );
		}
		else {
			if ( pRepeatFirst ) {
				var tw : Int = Std.int( pRectangles[0].width );
				var th : Int = Std.int( pRectangles[0].height );
				var cols : Int = Std.int( _bitmapData.width / tw );
				var rows : Int = Std.int( _bitmapData.height / th );
			
				for ( y in 0 ... rows ) {
					for ( x in 0 ... cols ) {
						_tilesheet.addTileRect( new Rectangle( x * tw, y * th, tw, th ) );
					}
				}
			}
			else {
				for ( i in 0 ... pRectangles.length ) {
					_tilesheet.addTileRect( pRectangles[ i ] );
				}
			}
		}

		_animations = new Map<String, Animation>();
	}
	
	/**
	 * Disposes all resources used by the atlas.
	 */
	public function dispose() : Void {
		_bitmapData.dispose();
		_bitmapData = null;
		_animations = null;
		_tilesheet = null;
	}
	
	/**
	 * Draws tiles from the Atlas on to specified graphics.
	 * @param	pGraphics	graphics to draw on
	 * @param	pTileData	tile data to use
	 */
	public function draw( pGraphics : Graphics, pTileData : Array<Float> ) : Void {
		//_tilesheet.drawTiles( pGraphics, pTileData, false, Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA );
		//_tilesheet.drawTiles( pGraphics, pTileData, false, Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RGB );
		_tilesheet.drawTiles( pGraphics, pTileData, false, Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_RGB );
	}
	
	/**
	 * Returns the width of a specific tile in pixels.
	 * @param	pTileID	tile to look up width for
	 * @return	width in pixels
	 */
	public function tileWidth( pTileID : Int = 0) : Int {
		return Std.int( _tilesheet.getTileRect( pTileID ).width );
	}
	
	
	/**
	 * Returns the height of a specific tile in pixels.
	 * @param	pTileID	tile to look up height for
	 * @return	height in pixels
	 */
	public function tileHeight( pTileID : Int = 0) : Int {
		return Std.int( _tilesheet.getTileRect( pTileID ).height );
	}
	
	/**
	 * Adds an animation to this atlas.
	 * @param	pAnimation Animation to store.
	 */
	public function addAnimation( pAnimation : Animation ) : Void {
		_animations.set( pAnimation.label, pAnimation );
	}
	
	/**
	 * Returns a specific animation.
	 * @param	pLabel	Label of animation to return.
	 * @return	Found animation, or null.
	 */
	public function getAnimation( pLabel : String ) : Animation {
		if ( _animations.get( pLabel ) == null ) {
			Log.log( "no such label '" + pLabel + "'", this, Log.WARNING );
		}
		return _animations.get( pLabel );
	}
	
}

