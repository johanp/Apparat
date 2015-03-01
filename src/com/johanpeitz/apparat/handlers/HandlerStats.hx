package com.johanpeitz.apparat.handlers;


/**
 * Holds statistics for a handler.
 * @author Johan Peitz
 */
class HandlerStats {

	/**
	 * Creats a new stat.
	 */
	public function new( ) {
		reset();
	}

	/**
	 * Resets any stats recorded.
	 */
	public function reset() : Void {

	}

	/**
	 * Returns a readable interpretation of the stats.
	 * @return	String of stats.
	 */
	public function toString() : String {
		return "";
	}

}
