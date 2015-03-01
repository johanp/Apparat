package com.johanpeitz.apparat.components.render;


import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.render.Atlas;
import com.johanpeitz.apparat.Scene;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.johanpeitz.apparat.components.Component;
import com.johanpeitz.apparat.utils.RenderStats;

/**
 * Allows for graphical output using the blit renderer.
 * Can be animated using animation components.
 */
class RenderComponent extends Component {
	
	/**
	 * Alpha value for this component. 0 for fully transparent, 1 for fully visible.
	 */
	public var alpha : Float;
	/**
	 * Red value for this component. 1 for regular output, 0 for no red.
	 */
	public var r : Float;
	/**
	 * Green value for this component. 1 for regular output, 0 for no green.
	 */
	public var g: Float;
	/**
	 * Blue value for this component. 1 for regular output, 0 for no blue.
	 */
	public var b: Float;
	
	/**
	 * Atlas used by component to render images.
	 */
	public var atlas : Atlas;

	private var _tileID : Int;
	
	
	/**
	 * Offsets the bitmap data from the entities postion.
	 */
	public var offset : Point;
	/**
	 * Specifies whether this bitmap data should render at all.
	 */
	public var visible : Bool;
	
	/**
	 * Tile data used by render handler.
	 */
	public var drawData : Array<Float>;
	
	/**
	 * Center point for tile.
	 */
	public var tileCenter : Point;
	
	/**
	 * Construcs a new blit render component.
	 * @param	pAtlas 		Atlas to use.
	 * @param	pOffset	Initial offset.
	 */
	public function new( pAtlas : Atlas, pTileID : Int = 0, pOffset : Point = null ) : Void {
		super( );

		visible = true;
		alpha = r = g = b = 1;
		_tileID = pTileID;
		
		drawData = new Array<Float>();
		drawData.push( 0 ); // x
		drawData.push( 0 ); // y
		drawData.push( 0 ); // tileID
		drawData.push( 0 ); // mx a
		drawData.push( 0 ); // mx b
		drawData.push( 0 ); // mx c
		drawData.push( 0 ); // mx d
		drawData.push( 0 ); // r
		drawData.push( 0 ); // g
		drawData.push( 0 ); // b
		drawData.push( 0 ); // alpha

		atlas = pAtlas;

		offset = Apparat.pointPool.fetch();
		offset.x = offset.y = 0;
		if ( pOffset != null ) {
			offset.x = pOffset.x;
			offset.y = pOffset.y;
		}

		tileCenter = Apparat.pointPool.fetch();
		tileCenter.x = getWidth() / 2;
		tileCenter.y = getHeight() / 2;
	}

	/**
	 * Clears all resources used.
	 */
	override public function dispose() : Void {
		atlas = null;
		drawData = null;
	
		Apparat.pointPool.recycle( offset );

		offset = null;

		super.dispose();
	}


	public var tileID( get_tileID, set_tileID ) : Int;
	private function set_tileID( pTileID : Int ) : Int {
		_tileID = pTileID;
		tileCenter.x = getWidth() / 2;
		tileCenter.y = getHeight() / 2;
		return _tileID;
	}
	private function get_tileID() : Int {
		return _tileID;
	}
	
	public function setColor( pColor : Int ) {
		r = (pColor >> 16) / 255;
		g = (pColor >> 8 & 0xff) / 255;
		b = (pColor & 0xff) / 255;
	}
	
	/**
	 * Updates the offset's position.
	 * @param	pX	X position.
	 * @param	pY	Y position.
	 */
	public function setOffset( pX : Int, pY : Int ) : Void {
		offset.x = pX;
		offset.y = pY;
	}
	
	public function getWidth() : Int {
		return atlas.tileWidth( _tileID );
	}
	
	public function getHeight() : Int {
		return atlas.tileHeight( _tileID );
	}
	
	

}
