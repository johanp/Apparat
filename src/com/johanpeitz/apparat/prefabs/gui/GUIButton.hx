package com.johanpeitz.apparat.prefabs.gui;

import com.johanpeitz.apparat.components.collision.BoxColliderComponent;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.physics.CollisionData;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.utils.ImageUtil;
import com.johanpeitz.apparat.utils.Repository;

/**
 * Contains a simple button which can be clicked. A MouseEntity must be on the scene in order for
 * the clicking to work.
 * @author Johan Peitz
 */
class GUIButton extends Entity {
	private var _label : String;
	private var _onClickedFunction : Dynamic;
	private var _onMouseOverFunction : Dynamic;
	private var _onMouseOutFunction : Dynamic;

	private var _textField : TextEntity;
	private var _mouseIsOver : Bool;

	/**
	 * Creates a new button with the specified label and callback.
	 * @param	pLabel	Initial text of button.
	 * @param	pOnClickedFunction	Function to call when button is clicked.
	 */
	public function new( pLabel : String, pOnClickedFunction : Dynamic = null, pOnMouseOverFunction : Dynamic = null, pOnMouseOutFunction : Dynamic = null ) {
		super( );

		_label = pLabel;
		_onClickedFunction = pOnClickedFunction;
		_onMouseOverFunction = pOnMouseOverFunction;
		_onMouseOutFunction = pOnMouseOutFunction;

		_mouseIsOver = false;

		_textField = new TextEntity( _label, Repository.fetch( Apparat.FONT_DEFAULT ), Apparat.COLOR_BLACK );
		_textField.width = Repository.fetch( Apparat.FONT_DEFAULT ).getTextWidth( pLabel );
		addEntity( _textField );

	}

	/**
	 * Clears all resources used by button.
	 */
	override public function dispose() : Void {
		_textField = null;
		_onClickedFunction = null;
		_onMouseOutFunction = null; 
		_onMouseOverFunction = null;
		
		super.dispose();
	}

	/**
	 * Updates the entity.
	 * @param	pDT	Time step.
	 */
	override public function update( pDT : Float ) : Void {
		if ( scene.inputHandler.mouseX >= transform.position.x && scene.inputHandler.mouseX <= transform.position.x + _textField.getWidth() && scene.inputHandler.mouseY >= transform.position.y && scene.inputHandler.mouseY <= transform.position.y + _textField.getHeight() ) {
			if ( !_mouseIsOver ) {
				_mouseIsOver = true;
				_textField.color = Apparat.COLOR_GREEN;
				if ( _onMouseOverFunction != null ) {
					_onMouseOverFunction( this );
				}
			}
			if ( _mouseIsOver ) {
				if ( scene.inputHandler.mousePressed ) {
					_onClickedFunction( this );
				}
			}
		}
		else {
			if ( _mouseIsOver ) {
				_mouseIsOver = false;
				_textField.color = Apparat.COLOR_BLACK;
				if ( _onMouseOutFunction != null ) {
					_onMouseOutFunction( this );
				}
			}
		}
		
		super.update( pDT );
	}

	/**
	 * Set what text to show on the button.
	 * @param pLabel	Text to show.
	 */
	public var label( get_label, set_label ) : String;
	private function set_label( pLabel : String ) : String {
		_label = pLabel;
		_textField.text = _label;
		return _label;
	}

	/**
	 * Returns current label.
	 */
	private function get_label() : String {
		return _label;
	}


}

