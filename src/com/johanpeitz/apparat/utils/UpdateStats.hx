package com.johanpeitz.apparat.utils;

import com.johanpeitz.apparat.handlers.HandlerStats;

/**
 * Holder class for info about the latest logic update.
 * @author Johan Peitz
 */
class UpdateStats extends HandlerStats {
	/**
	 * Float of entities updated during logic update.
	 */
	public var entitiesUpdated : Int;

	/**
	 * Resets data making it ready for the next update.
	 */
	override public function reset() : Void {
		entitiesUpdated = 0;
	}

	/**
	 * Returns stats as readable string.
	 * @return	Stats as readable string.
	 */
	override public function toString() : String {
		return "Entities: " + entitiesUpdated;
	}

}
