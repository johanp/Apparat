package com.johanpeitz.apparat.components.render;

import com.johanpeitz.apparat.utils.MathUtil;
import openfl.geom.Point;
import com.johanpeitz.apparat.components.Component;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.render.Animation;

/**
 * Handles animation of a blit render component using sprite sheets.
 * @author Johan Peitz
 */
class AnimationComponent extends Component {
	private var _renderComponentRef : RenderComponent = null;
	private var _currentAnimation : Animation = null;
	private var _currentAnimationFrame : Int;
	private var _currentAtlasTileID : Int;
	private var _animationPlaying : Bool = false;
	private var _frameTimer : Float;
	private var _frameDuration : Float = 0.1;

	private var _currentAnimationLabel : String;
	private var _renderComponentNeedsUpdate : Bool = false;
	
	private var _animationCompleteCallbacks : Array<Dynamic>;

	/**
	 * Creates a new component.
	 * @param	pSpriteSheet	Sprite sheet to use.
	 */
	public function new( ) {
		super( );
		_animationCompleteCallbacks = new Array<Dynamic>();
	}

	/**
	 * Clears all resources used by component.
	 */
	override public function dispose() : Void {
		super.dispose();
		_renderComponentRef = null;
		_animationCompleteCallbacks = null;
	}

	/**
	 * Invoked when added to an entity. Acquires link to entitie's render component.
	 * @param	pEntity	Entity added to.
	 */
	override public function onAddedToEntity( pEntity : Entity ) : Void {
		super.onAddedToEntity( pEntity );
		_renderComponentRef = cast( entity.getComponentByClass( RenderComponent ), RenderComponent );
	}

	/**
	 * Stops any playing animation.
	 */
	public function stop() : Void {
		_animationPlaying = false;
	}

	/**
	 * Sets a specific frame and stops.
	 * @param	pFrame
	 */
	public function gotoAndStop( pFrame : Int ) : Void {
		_animationPlaying = false;
		_currentAtlasTileID = pFrame;
		_renderComponentNeedsUpdate = true;
	}

	/**
	 * Starts an animation.
	 * @param	pLabel	Animation to start.
	 * @param	pRestart	Specifies whether to restart the animation if it is already playing.
	 * @param	pRandomStartFrame	Specifies whether to start the animation on a random frame.
	 */
	public function gotoAndPlay( pLabel : String, pRestart : Bool = true, pRandomStartFrame : Bool = false ) : Void {
		if ( !pRestart && _currentAnimationLabel == pLabel )
			return;


		_currentAnimation = _renderComponentRef.atlas.getAnimation( pLabel );
		if ( _currentAnimation != null ) {
			_currentAnimationLabel = pLabel;

			_currentAnimationFrame = 0;
			if ( pRandomStartFrame ) {
				_currentAnimationFrame = MathUtil.randomInt( 0, _currentAnimation.frames.length );
			}
			_animationPlaying = true;
			_frameTimer = 0;
			_frameDuration = 1 / _currentAnimation.fps;

			// show first frame
			_currentAtlasTileID = _currentAnimation.frames[ _currentAnimationFrame ];
			_renderComponentNeedsUpdate = true;
		}

	}

	/**
	 * Updates which frame to show depending on animation data.
	 * Invoked regularly by the entity.
	 * @param	pDT	Time step.
	 */
	override public function update( pDT : Float ) : Void {
		super.update( pDT );
		
		if ( _animationPlaying ) {
			_frameTimer += pDT;

			if ( _frameTimer > _frameDuration ) {
				_frameTimer -= _frameDuration;
				_currentAnimationFrame++;
				if ( _currentAnimationFrame >= _currentAnimation.frames.length ) {
					switch ( _currentAnimation.onComplete ) {
					case Animation.ANIM_LOOP:
						_currentAnimationFrame = 0;

					case Animation.ANIM_STOP:
						_animationPlaying = false;
						_currentAnimationFrame--;         // stay on last frame
						
						// notify listeners
						for ( f in _animationCompleteCallbacks ) {
							f( _currentAnimation );
						}

					case Animation.ANIM_GOTO:
						gotoAndPlay( _currentAnimation.gotoLabel );
					}
				}

				_currentAtlasTileID = _currentAnimation.frames[ _currentAnimationFrame ];
				_renderComponentNeedsUpdate = true;

			}
		}

		if ( _renderComponentNeedsUpdate ) {
			updateRenderComponent();
		}

	}

	/**
	 * Sets callback called when an animation is complete.
	 */
	public function addAnimationCompleteCallback( pFunction : Dynamic ) : Void {
		_animationCompleteCallbacks.push( pFunction );
	}


	private function updateRenderComponent() : Void {
		if ( _renderComponentRef != null ) {
			_renderComponentRef.tileID = _currentAtlasTileID;
		}
	}

	/**
	 * Returns the label of the current animation.
	 * @return Current animation label.
	 */
	public var currentLabel( get_currentLabel, null ) : String;
	private function get_currentLabel() : String {
		return _currentAnimationLabel;
	}

}
