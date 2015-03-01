package com.johanpeitz.apparat.utils;

import openfl.utils.ByteArray;
import com.johanpeitz.apparat.components.collision.BoxColliderComponent;

/**
 * Holds and input state, like up, down, jump, etc.
 * @author Johan Peitz
 */
class InputPost {
	public var left : Bool = false;
	public var right : Bool = false;
	public var up : Bool = false;
	public var down : Bool = false;
	public var jump : Bool = false;
	public var action : Bool = false;

	public var duration : Int = 0;

	public function new( ) {

	}

	/**
	 * Checks if this input post is equal to another input post.
	 * @param	pIP InputPost to check with.
	 * @return	True if equal.
	 */
	public function equals( pIP : InputPost ) : Bool {
		if ( pIP.left != left )
			return false;
		if ( pIP.right != right )
			return false;
		if ( pIP.up != up )
			return false;
		if ( pIP.down != down )
			return false;
		if ( pIP.action != action )
			return false;
		if ( pIP.jump != jump )
			return false;

		return true;
	}

	/**
	 * Returns this input post as a string.
	 * @return String representation of inpit post.
	 */
	public function toString() : String {
		return "" + ( left ? "L" : "" ) + ( right ? "R" : "" ) + ( up ? "U" : "" ) + ( down ? "D" : "" ) + ( jump ? "J" : "" ) + ( action ? "A" : "" ) + ";" + duration + "";
	}

	/**
	 * Populates the input post from string data generated from toString().
	 * @param	pData String with population data.
	 * @return True is all went well.
	 */
	public function fromString( pData : String ) : Bool {
		var parts : Array<String> = pData.split( ";" );

		if ( parts.length != 2 ) return false;

		duration = Std.parseInt( parts[ 1 ] );

		left = parts[ 0 ].indexOf( "L" ) != -1;
		right = parts[ 0 ].indexOf( "R" ) != -1;
		up = parts[ 0 ].indexOf( "U" ) != -1;
		down = parts[ 0 ].indexOf( "D" ) != -1;
		jump = parts[ 0 ].indexOf( "J" ) != -1;
		action = parts[ 0 ].indexOf( "A" ) != -1;

		return true;
	}

}
