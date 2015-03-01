package com.johanpeitz.apparat.prefabs;


import openfl.events.Event;
import openfl.geom.Point;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.sound.SoundComponent;
import com.johanpeitz.apparat.utils.Log;

/**
 * Entity that plays a sound.
 * @author Johan Peitz
 */
class SoundEntity extends Entity {
	private var _soundComp : SoundComponent;

	/**
	 * Constructs a new entity with specified sound.
	 * @param	pSound	Sound to play.
	 * @param	pPosition	Position to play sound at. Pass null for ambient sound.
	 * @param	pLoop	Whether too loop sound or not.
	 */
	public function new( pSound : Sound, pPosition : Point, pLoop : Bool = false, pDestroyOnComplete : Bool = true ) {
		super( );

		if ( pPosition != null ) {
			transform.position.x = pPosition.x;
			transform.position.y = pPosition.y;
		}


		_soundComp = new SoundComponent( pSound, pPosition == null, pLoop );

		if ( pDestroyOnComplete ) {
			_soundComp.onCompleteCallback = onSoundComplete;
		}

		addComponent( _soundComp );
	}


	/**
	 * Disposes entity and stops sound.
	 */
	override public function dispose() : Void {
		_soundComp = null;

		super.dispose();
	}


	private function onSoundComplete( pSoundComponent : SoundComponent ) : Void
	{
		removeIn( 0 );
	}

	/**
	 * Pauses the sound.
	 */
	public function pause() : Void {
		_soundComp.pause();
	}

	/**
	 * Resumes the sound.
	 */
	public function unpause() : Void {
		_soundComp.unpause();
	}


}

