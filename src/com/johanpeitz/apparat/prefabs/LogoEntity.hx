package com.johanpeitz.apparat.prefabs;

import com.johanpeitz.apparat.InputHandler;
import com.johanpeitz.apparat.components.render.AnimationComponent;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.prefabs.gui.TextEntity;
import com.johanpeitz.apparat.render.Atlas;
import com.johanpeitz.apparat.utils.ImageUtil;
import com.johanpeitz.apparat.utils.MathUtil;
import com.johanpeitz.apparat.utils.Repository;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.Assets;

/**
 * Entity displaying animated Apparat logo.
 * @author Johan Peitz
 */
class LogoEntity extends Entity {

	private var _timePassed : Float;
	private var _fadeOut : Bool;
	private var _bg : RenderComponent;
	private var _versionEntity : TextEntity;

	private var _onLogoComplete : Dynamic;
	private var _textLogo:RenderComponent;


	/**
	 * Creates a new Apparat logo entity. Only used interally.
	 * 
	 * @param	pOnCompleteCallback	function to all when logo is complete
	 */
	public function new( pOnCompleteCallback : Dynamic = null ) {
		super( );

		_fadeOut = false;
		_onLogoComplete = pOnCompleteCallback;
		
		transform.position.x = Apparat.engine.engineWidth / 2;
		transform.position.y = Apparat.engine.engineHeight / 2;

		var e : Entity;
				
		// logo 
		e = new Entity( );
		_textLogo = new RenderComponent( Repository.fetch( "_apparat-logo-atlas" ) );
		_textLogo.alpha = 0;
		e.addComponent( _textLogo );
		addEntity( e );
		
		
		// big white background
		_bg = new RenderComponent( new Atlas( ImageUtil.createRect( Apparat.engine.engineWidth, Apparat.engine.engineHeight, Apparat.COLOR_WHITE ) ) );
		addComponent( _bg );
		
		// version text
		_versionEntity = new TextEntity( "v" + Apparat.MAJOR_VERSION + "." + Apparat.MINOR_VERSION + "." + Apparat.INTERNAL_VERSION, Repository.fetch( Apparat.FONT_DEFAULT ), Apparat.COLOR_GRAY );
		_versionEntity.alpha = 0;
		_versionEntity.transform.setPosition( -Apparat.engine.engineWidth / 2 + 4, -Apparat.engine.engineHeight / 2 + 4 );
		addEntity( _versionEntity );

		_timePassed = 0;
		Apparat.engine.resetTimers();
	}

	/**
	 * Disposes all resources used by instance.
	 */
	override public function dispose() : Void {
		_bg = null;
		_textLogo = null;
		_versionEntity = null;
		super.dispose();
	}

	/**
	 * UPdates the logo and other various entities.
	 * 
	 * @param	pDT	time passed
	 */
	override public function update( pDT : Float ) : Void {
		_timePassed += pDT;

		if ( !_fadeOut ) {
			if ( _timePassed > 0.1 ) {
				if ( _textLogo.alpha < 1 ) {
					_textLogo.alpha += 1 * pDT;
					_versionEntity.alpha += 1 * pDT;
				}
			}
		}

		if ( _fadeOut ) {
			if ( _bg.alpha > 0 ) {
				_bg.alpha -= pDT * 2;
				//_versionEntity.textField.alpha -= pDT * 3;			
				_textLogo.alpha -= pDT * 3;			
			}
		} 
		else {
			if ( scene.inputHandler.isPressed( InputHandler.KEY_ESC ) || scene.inputHandler.mousePressed ) {
				_fadeOut = true;
				for ( e in entities ) {
					e.removeIn( 0 );
				}
				removeIn( 1 );
				if ( _onLogoComplete != null ) {
					_onLogoComplete();
				}
			} 
			else if ( _timePassed > 5 && !_fadeOut ) {
				_fadeOut = true;
				removeIn( 2 );
				if ( _onLogoComplete != null ) {
					_onLogoComplete();
				}
			}

		}

		super.update( pDT );

	}

}
