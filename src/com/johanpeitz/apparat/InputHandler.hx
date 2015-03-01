package com.johanpeitz.apparat;

import openfl.display.Stage;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import com.johanpeitz.apparat.handlers.Handler;
import com.johanpeitz.apparat.utils.Log;

/**
 * Manages keyboard and mouse input.
 * @author Johan Peitz
 */
class InputHandler extends Handler {
	private var _stage : Stage;
	private var _keysDown : Array<Int>;

	/**
	 * Specifies whether the mouse button is down.
	 */
	public var mouseDown : Bool = false;
	/**
	 * Specifies whether the mouse button was just pressed.
	 */
	public var mousePressed : Bool = false;

	/**
	 * Specifies whether the mouse button is up.
	 */
	public var mouseUp : Bool = true;
	/**
	 * Specifies whether the mouse button was just released.
	 */
	public var mouseReleased : Bool = false;
	/**
	 * Position of the mouse.
	 */
	public var mousePosition : Point;

	/**
	 * Specifies how much the mouse wheel changed.
	 */
	public var mouseDelta : Int = 0;


	/**
	 * Initializes the input handler.
	 * @param	pScene	Scene on which to operate.
	 * @param	pPriority	When to be invoked in relation to other sytems.
	 */
	public function new( pScene : Scene, pPriority : Int = 0 ) : Void {
		super( pScene, pPriority );

		_stage = Apparat.stage;

		_keysDown = new Array<Int>();


		_stage.addEventListener( KeyboardEvent.KEY_DOWN, keyPressed );
		_stage.addEventListener( KeyboardEvent.KEY_UP, keyReleased );
		_stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		_stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		_stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );

		mousePosition = new Point();

		for ( i in 0...256 ) {
			_keysDown.push( 0 );
		}

	}

	/**
	 * Disposes of all resources used by the input manager.
	 */
	override public function dispose() : Void {
		_stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyPressed );
		_stage.removeEventListener( KeyboardEvent.KEY_UP, keyReleased );
		_stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		_stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		_stage.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
		_keysDown = null;
	}

	/**
	 * Returns the mouse's X position.
	 * @return	The mouse's X position.
	 */
	public var mouseX( get_mouseX, null ) : Int;
	private function get_mouseX() : Int {
		return Std.int( mousePosition.x );
	}

	/**
	 * Returns the mouse's Y position.
	 * @return	The mouse's Y position.
	 */
	public var mouseY( get_mouseY, null ) : Int;
	private function get_mouseY() : Int {
		return Std.int( mousePosition.y );
	}

	/**
	 * Resets the status of the mouse button.
	 */
	public function resetMouseButton() : Void {
		mouseDown = false;
		mousePressed = false;
		mouseUp = true;
		mouseReleased = false;
	}

	private function onMouseDown( e : MouseEvent ) : Void {
		if ( !mouseDown ) {
			mouseDown = true;
			mouseUp = false;
			mousePressed = true;
			mouseReleased = false;
		}
	}

	private function onMouseUp( e : MouseEvent ) : Void {
		mouseDown = false;
		mouseUp = true;
		mousePressed = false;
		mouseReleased = true;
	}

	private function onMouseWheel( e : MouseEvent ) : Void {
		mouseDelta += e.delta;
	}

	/**
	 * Resets all input.
	 */
	public function reset() : Void {
		resetMouseButton();
		var pos : Int = _keysDown.length;
		while ( --pos >= 0 ) {
			_keysDown[ pos ] = 0;
		}
	}

	/**
	 * Invoked by the engine at regular intervals. Synchronizes internal data with Flash's.
	 * @param	pDT	Time step in seconds.
	 */
	override public function update( pDT : Float ) : Void {
		mousePosition.x = _stage.mouseX / Apparat.engine.engineScale;
		mousePosition.y = _stage.mouseY / Apparat.engine.engineScale;
	}

	/**
	 * Invoked by the engine after each logic cycle. Cleans up what needs to be cleaned up.
	 */
	override public function afterUpdate() : Void {
		if ( mousePressed )
			mousePressed = false;
		if ( mouseReleased )
			mouseReleased = false;

		mouseDelta = 0;
	}

	/**
	 * Checks wether a certain key is up or not.
	 * @param	keyCode	The key code of the desired key.
	 * @return	True if the key is up.
	 */
	public function isUp( keyCode : Int ) : Bool {
		return _keysDown[ keyCode ] <= 0;
	}

	/**
	 * Checks wether a certain key is down or not.
	 * @param	keyCode	The key code of the desired key.
	 * @return	True if the key is down.
	 */
	public function isDown( keyCode : Int ) : Bool {
		return _keysDown[ keyCode ] > 0;
	}

	/**
	 * Checks wether a certain key was just pressed.
	 * @param	keyCode	The key code of the desired key.
	 * @return	True if the key was just pressed.
	 */
	public function isPressed( keyCode : Int ) : Bool {
		var p : Bool = _keysDown[ keyCode ] == 1;
		if ( p )
			_keysDown[ keyCode ] = 2;
		return p;
	}

	public function isReleased( keyCode : Int ) : Bool {
		var p : Bool = _keysDown[ keyCode ] == -1;
		if ( p )
			_keysDown[ keyCode ] = -2;
		return p;
	}

	/**
	 * Fakes a key press of a certain key.
	 * @param	keyCode	The key code of the desired key.
	 */
	public function fakeKeyPress( keyCode : Int ) : Void {
		_keysDown[ keyCode ]++;
	}

	private function keyPressed( evt : KeyboardEvent ) : Void {
		if ( _keysDown[ evt.keyCode ] <= 0 ) {
			_keysDown[ evt.keyCode ] = 1;
		}
	}

	private function keyReleased( evt : KeyboardEvent ) : Void {
		_keysDown[ evt.keyCode ] = -1;
	}

	public static inline var KEY_BACKSPACE : Int = 8;
	public static inline var KEY_ENTER : Int = 13;

	public static inline var KEY_SHIFT : Int = 16;
	public static inline var KEY_CONTROL : Int = 17;

	public static inline var KEY_ESC : Int = 27;

	public static inline var KEY_SPACE : Int = 32;
	public static inline var KEY_PGUP : Int = 33;
	public static inline var KEY_PGDN : Int = 34;
	public static inline var KEY_END : Int = 35;
	public static inline var KEY_HOME : Int = 36;
	public static inline var KEY_LEFT : Int = 37;
	public static inline var KEY_UP : Int = 38;
	public static inline var KEY_RIGHT : Int = 39;
	public static inline var KEY_DOWN : Int = 40;

	public static inline var KEY_DELETE : Int = 46;
	public static inline var KEY_INSERT : Int = 45;

	public static inline var KEY_0 : Int = 48;
	public static inline var KEY_1 : Int = 49;
	public static inline var KEY_2 : Int = 50;
	public static inline var KEY_3 : Int = 51;
	public static inline var KEY_4 : Int = 52;
	public static inline var KEY_5 : Int = 53;
	public static inline var KEY_6 : Int = 54;
	public static inline var KEY_7 : Int = 55;
	public static inline var KEY_8 : Int = 56;
	public static inline var KEY_9 : Int = 57;

	public static inline var KEY_A : Int = 65;
	public static inline var KEY_B : Int = 66;
	public static inline var KEY_C : Int = 67;
	public static inline var KEY_D : Int = 68;
	public static inline var KEY_E : Int = 69;
	public static inline var KEY_F : Int = 70;
	public static inline var KEY_G : Int = 71;
	public static inline var KEY_H : Int = 72;
	public static inline var KEY_I : Int = 73;
	public static inline var KEY_J : Int = 74;
	public static inline var KEY_K : Int = 75;
	public static inline var KEY_L : Int = 76;
	public static inline var KEY_M : Int = 77;
	public static inline var KEY_N : Int = 78;
	public static inline var KEY_O : Int = 79;
	public static inline var KEY_P : Int = 80;
	public static inline var KEY_Q : Int = 81;
	public static inline var KEY_R : Int = 82;
	public static inline var KEY_S : Int = 83;
	public static inline var KEY_T : Int = 84;
	public static inline var KEY_U : Int = 85;
	public static inline var KEY_V : Int = 86;
	public static inline var KEY_W : Int = 87;
	public static inline var KEY_X : Int = 88;
	public static inline var KEY_Y : Int = 89;
	public static inline var KEY_Z : Int = 90;

	public static inline var KEY_F1 : Int = 112;
	public static inline var KEY_F2 : Int = 113;
	public static inline var KEY_F3 : Int = 114;
	public static inline var KEY_F4 : Int = 115;
	public static inline var KEY_F5 : Int = 116;
	public static inline var KEY_F6 : Int = 117;
	public static inline var KEY_F7 : Int = 118;
	public static inline var KEY_F8 : Int = 119;

}
