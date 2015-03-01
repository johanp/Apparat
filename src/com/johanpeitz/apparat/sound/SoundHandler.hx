package com.johanpeitz.apparat.sound;

import com.johanpeitz.apparat.utils.ArrayUtil;
import openfl.geom.Point;
import openfl.media.Sound;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.prefabs.SoundEntity;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.handlers.Handler;
import com.johanpeitz.apparat.utils.Log;

/**
 * Handler that handles all sound in a scene.
 * @author Johan Peitz
 */
class SoundHandler extends Handler {
	private var _sounds : Array<SoundComponent>;

	/**
	 * Sets the distance of where panning starts to occur and for how long until 100% on one end.
	 */
	public var panRange : Point;
	/**
	 * Sets the distance of where volume starts to drop off how long until 0 left.
	 */
	public var volumeRange : Point;

	private var _volume : Float;
	private var _volumeBeforeMute : Float;

	/**
	 * Initializes the sound handler.
	 */
	public function new( pScene : Scene, pPriority : Int = 0 ) : Void {
		super( pScene, pPriority );

		_sounds = new Array<SoundComponent>();

		panRange = new Point( Apparat.engine.engineWidth * 0.75 / 2, Apparat.engine.engineWidth * 0.75 / 2 );
		volumeRange = new Point( Apparat.engine.engineWidth / 2, Apparat.engine.engineWidth / 2 );
		_volume = 1;
	}

	/**
	 * Clears all resources used by this handler.
	 */
	override public function dispose() : Void {
		var pos : Int = _sounds.length;
		while ( --pos >= 0 ) {
			_sounds[ pos ].stop();
		}
		_sounds = null;
		super.dispose();
	}

	/**
	 * Adds a collider to the handler. The collider will now be check for collision against other colliders.
	 * @param	pCollider	Collider to add.
	 */
	public function addSound( pSound : SoundComponent ) : Void {
		_sounds.push( pSound );
	}

	/**
	 * Removes a collider from the handler. It will no longer collide with other colliders.
	 * @param	pCollider	Collider to remove.
	 */
	public function removeSound( pSound : SoundComponent ) : Void {
		_sounds.splice( ArrayUtil.indexOf( _sounds, pSound ), 1 );
	}

	/**
	 * Pauses all sounds.
	 */
	public function pause() : Void {
		var pos : Int = _sounds.length;
		while ( --pos >= 0 ) {
			_sounds[ pos ].pause();
		}
	}

	/**
	 * Resumes all paused sounds.
	 */
	public function unpause() : Void {
		var pos : Int = _sounds.length;
		while ( --pos >= 0 ) {
			_sounds[ pos ].unpause();
		}
	}

	/**
	 * Mutes all current and future sounds.
	 */
	public function mute() : Void {
		if ( _volume > 0 ) {
			_volumeBeforeMute = _volume;
			_volume = 0;

			updateAllSoundEntites();
		}
	}

	/**
	 * Unmutes all current and future sounds.
	 */
	public function unmute() : Void {
		if ( _volume == 0 ) {
			_volume = _volumeBeforeMute;

			updateAllSoundEntites();
		}
	}

	private function updateAllSoundEntites() : Void {
		var pos : Int = _sounds.length;
		while ( --pos >= 0 ) {
			_sounds[ pos ].update( 0 );
		}
	}

	/**
	 * Returns true if sounds are muted.
	 * @return	True if sounds are muted.
	 */
	public function isMuted() : Bool {
		return _volume == 0;
	}

	/**
	 * Shortcut for quickly playing a sound.
	 * @param	pSound	Sound to play.
	 * @param	pPosition	Where to play it. Pass null for ambient sounds.
	 * @param	pLoop	Whether to loop the sound or not.
	 */
	public function play( pSound : Sound, pPosition : Point = null, pLoop : Bool = false ) : Void {
		var soundEntity : SoundEntity = new SoundEntity( pSound, pPosition, pLoop );
		Apparat.engine.currentScene.addEntity( soundEntity );
	}

	/**
	 * Returns the current volume for this handler.
	 */
	public var volume(get_volume, null ) : Float;
	private function get_volume() : Float {
		return _volume;
	}

}

