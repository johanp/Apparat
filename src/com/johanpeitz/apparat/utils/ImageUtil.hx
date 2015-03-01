package com.johanpeitz.apparat.utils;

import com.johanpeitz.apparat.render.BitmapFont;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
	


/**
 * Utility class for quick creation of atlases.
 */
class ImageUtil {

	/**
	 * Creates a filled rectangle of the desired size and color.
	 * @param	pWidth	Width of rectangle.
	 * @param	pHeight	Height of rectangle.
	 * @param	pColor	Color of rectangle. Will be random if left out.
	 * @return	BitmapData containing a filled rectangle.
	 */
	public static function createRect( pWidth : Float, pHeight : Float, pColor : Int = -1 ) : BitmapData {
		if ( pColor == -1 ) {
			pColor = Std.int( Math.random() * 0xFFFFFF );
		}

		return new BitmapData( Std.int( pWidth ), Std.int( pHeight ), false, pColor );
	}

	/**
	 * Creates a filled circle of the desired size and color.
	 * @param	pRadius	Radius of circle.
	 * @param	pColor	Color of circle. Will be random if left out.
	 * @return	BitmapData containing a filled rectangle.
	 */
	public static function createCircle( pRadius : Float, pColor : Int = -1 ) : BitmapData {
		if ( pColor == -1 ) {
			pColor = Std.int( Math.random() * 0xFFFFFF );
		}

		var bd : BitmapData = new BitmapData( Std.int( pRadius * 2 ), Std.int( pRadius * 2 ), true, pColor );

		var s : Sprite = new Sprite();
		s.graphics.lineStyle( 0, 0, 0 );
		s.graphics.beginFill( pColor );
		s.graphics.drawCircle( pRadius, pRadius, pRadius );
		s.graphics.endFill();
		bd.draw( s );

		return bd;
	}
    

}
