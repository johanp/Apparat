package com.johanpeitz.apparat.sound;

import openfl.events.Event;
import openfl.geom.Point;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import com.johanpeitz.apparat.components.Component;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.utils.Log;

/**
 * Entity that plays a sound.
 * @author Johan Peitz
 */
class SoundComponent extends Component {
	private var _sound : Sound;
	private var _soundTransform : SoundTransform;
	private var _soundChannel : SoundChannel = null;

	private var _isLooping : Bool;

	private var _isAmbient : Bool;

	private var _paused : Bool;

	private var _pausePosition : Float;

	private var _onCompleteCallback : Dynamic;

	/**
	 * Constructs a new component with specified sound.
	 * @param	pSound	Sound to play.
	 * @param	pPosition	Position to play sound at. Pass null for ambient sound.
	 * @param	pLoop	Whether too loop sound or not.
	 */
	public function new( pSound : Sound, pAmbient : Bool = false, pLoop : Bool = false ) {
		super( );

		_sound = pSound;
		_isLooping = pLoop;
		_paused = true;
		_isAmbient = pAmbient;
	}

	/**
	 * Disposes entity and stops sound.
	 */
	override public function dispose() : Void {
		if ( _soundChannel != null ) {
			_soundChannel.removeEventListener( Event.SOUND_COMPLETE, onSoundComplete );
			_soundChannel.stop();
			_soundChannel = null;
		}

		_sound = null;
		_soundTransform = null;

		super.dispose();
	}

	/**
	 * Invoked when sound's entity is added to scene.
	 * Automatically adds the sound to the scene's sound handler.
	 * @param	pScene	Scene entity was added to.
	 */
	override public function onEntityAddedToScene( pScene : Scene ) : Void {
		entity.scene.soundHandler.addSound( this );

		if ( _isAmbient ) {
			_soundTransform = new SoundTransform( entity.scene.soundHandler.volume * Apparat.globalVolume );
		} else {
			_soundTransform = new SoundTransform( 0, 0 );
		}

		// play the sound
		play();
	}

	/**
	 * Invoked when sound's entity is removed from scene.
	 * Automatically removes the sound from the scene's sound handlermanager.
	 * @param	pScene	Scene entity was removed from.
	 */
	override public function onEntityRemovedFromScene() : Void {
		entity.scene.soundHandler.removeSound( this );
	}

	private function play( pPosition : Float = 0 ) : Void {
		_paused = false;
		_soundChannel = _sound.play( pPosition, 0, _soundTransform );
		if ( _soundChannel != null ) {
			_soundChannel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
		} else {
			Log.log( "out of sound channels, skipping sound '" + _sound + "'", this, Log.WARNING );
		}

	}

	/**
	 * Updates the sound and changes it's sound transform depending on position.
	 * @param	pDT
	 */
	override public function update( pDT : Float ) : Void {
		if ( entity.parent != null && !_isAmbient ) {
			if ( _soundChannel != null ) {
				updateSoundTransform( entity.transform.positionOnScene );
				_soundChannel.soundTransform = _soundTransform;
			}
		}
		if ( _isAmbient ) {
			if ( _soundChannel != null ) {
				_soundTransform.pan = 0;
				_soundTransform.volume = entity.scene.soundHandler.volume * Apparat.globalVolume;
				_soundChannel.soundTransform = _soundTransform;
			}
		}

		super.update( pDT );
	}

	/**
	 * Pauses the sound.
	 */
	public function pause() : Void {
		if ( _paused )
			return;
		if ( _soundChannel != null ) {
			_paused = true;
			_pausePosition = _soundChannel.position;
			_soundChannel.removeEventListener( Event.SOUND_COMPLETE, onSoundComplete );
			_soundChannel.stop();
			_soundChannel = null;
		}

	}

	/**
	 * Resumes the sound.
	 */
	public function unpause() : Void {
		if ( !_paused )
			return;
		_paused = false;
		play( _pausePosition );
	}

	/**
	 * Stops the sound.
	 */
	public function stop() : Void {
		if ( _paused )
			return;
		if ( _soundChannel != null ) {
			_soundChannel.stop();
		}
	}

	private function updateSoundTransform( pScenePosition : Point ) : Void {
		var camCenter : Point = entity.scene.camera.center;
		var volDistToCam : Float = Point.distance( pScenePosition, camCenter );

		var vol : Float = 1;
		if ( volDistToCam > entity.scene.soundHandler.volumeRange.x + entity.scene.soundHandler.volumeRange.y ) {
			vol = 0;
		} else if ( volDistToCam > entity.scene.soundHandler.volumeRange.x ) {
			vol = 1 - ( volDistToCam - entity.scene.soundHandler.volumeRange.x ) / ( entity.scene.soundHandler.volumeRange.y );
		}

		_soundTransform.volume = vol * entity.scene.soundHandler.volume * Apparat.globalVolume;

		var panDistToCam : Float = Math.abs( pScenePosition.x - camCenter.x );
		var pan : Float = 0;

		if ( panDistToCam > entity.scene.soundHandler.panRange.x + entity.scene.soundHandler.panRange.y ) {
			pan = 1;
		} else if ( panDistToCam > entity.scene.soundHandler.panRange.x ) {
			pan = Math.abs( panDistToCam - entity.scene.soundHandler.panRange.x ) / ( entity.scene.soundHandler.panRange.y );
		}

		if ( pScenePosition.x < camCenter.x ) {
			pan = -pan;
		}

		_soundTransform.pan = pan;

	}

	private function onSoundComplete( pEvent : Event ) : Void {
		_soundChannel.removeEventListener( Event.SOUND_COMPLETE, onSoundComplete );
		if ( _isLooping ) {
			play();
		} else {
			if ( _onCompleteCallback != null ) {
				_onCompleteCallback( this );
			}
		}
	}

	/**
	 * Returns the sound channel for this sound.
	 */
	public var soundChannel( get_soundChannel, null ) : SoundChannel;
	private function get_soundChannel() : SoundChannel {
		return _soundChannel;
	}

	public var onCompleteCallback( null, set_onCompleteCallback ) : Dynamic;
	public function set_onCompleteCallback(pCallback : Dynamic) : Dynamic
	{
		_onCompleteCallback = pCallback;
		return _onCompleteCallback;
	}

}

