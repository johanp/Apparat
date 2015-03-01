package com.johanpeitz.apparat.utils;

import com.johanpeitz.apparat.handlers.HandlerStats;

/**
 * Holder class for info about the latest logic update.
 * @author Johan Peitz
 */
class LogicStats extends HandlerStats {
	/**
	 * Current frame rate.
	 */
	public var fps : Int;
	/**
	 * Time spent doing logic.
	 */
	public var logicTime : Int;

	/**
	 * Minimum amount of memory used in mega bytes.
	 */
	public var minMemory : Int = -1;
	/**
	 * Maximum amount of memory used in mega bytes.
	 */
	public var maxMemory : Int = -1;
	/**
	 * Current amount of memory used in mega bytes.
	 */
	public var currentMemory : Int = -1;

	/**
	 * Returns stats as readable string.
	 * @return	Stats as readable string.
	 */
	override public function toString() : String {
		var text : String = "";
		text += "FPS: " + fps + "\n";
		text += "Logic: " + logicTime + " ms" + "\n";
		text += "Memory: " + minMemory + "/" + currentMemory + "/" + maxMemory + " MB";
		return text;
	}
}
