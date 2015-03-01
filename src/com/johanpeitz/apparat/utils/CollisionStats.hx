package com.johanpeitz.apparat.utils;

import com.johanpeitz.apparat.handlers.HandlerStats;

/**
 * Holder for stats collected during the collision phase.
 * @author Johan Peitz
 */
class CollisionStats extends HandlerStats {
	/**
	 * Amount of collider objects there are.
	 */
	public var colliderObjects : Int;
	/**
	 * Amount of tests where started.
	 */
	public var collisionTests : Int;
	/**
	 * Amount of tests which passed the mask test.
	 */
	public var collisionMasks : Int;
	/**
	 * Amount of tests which detected a collision.
	 */
	public var collisionHits : Int;

	/**
	 * Resets the stats for a new round of testing.
	 */
	override public function reset() : Void {
		colliderObjects = 0;
		collisionTests = 0;
		collisionMasks = 0;
		collisionHits = 0;
	}

	/**
	 * Returns stats as readable string.
	 * @return	Stats as readable string.
	 */
	override public function toString() : String {
		var s : String = "";
		s += "Colliders: " + colliderObjects + "\n";
		s += "Collisions: " + collisionTests + ">" + collisionMasks + ">" + collisionHits;
		return s;

	}
}

