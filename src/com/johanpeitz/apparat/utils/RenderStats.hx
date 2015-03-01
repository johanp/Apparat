package com.johanpeitz.apparat.utils;

import com.johanpeitz.apparat.handlers.HandlerStats;

/**
 * Holder for stats collected during the rendering.
 * @author Johan Peitz
 */
class RenderStats extends HandlerStats {
	/**
	 * Amount of objects actually rendered.
	 */
	public var renderedObjects : Int;
	/**
	 * Total amount of objects.
	 */
	public var totalObjects : Int;

	/**
	 * Number of calls to atlas.draw.
	 */
	public var drawCalls : Int;
	
	/**
	 * Render time in seconds.
	 */
	public var renderTime : Int;

	/**
	 * Resets the render stats before each run.
	 */
	override public function reset() : Void {
		renderedObjects = 0;
		totalObjects = 0;
		renderTime = 0;
		drawCalls = 0;
	}

	/**
	 * Returns stats as readable string.
	 * @return	Stats as readable string.
	 */
	override public function toString() : String {
		var s : String = "";
		s += "DrawCalls: " + drawCalls + "\n";
		s += "Render: " + renderTime + " ms" + "\n";
		s += "RendObjs: " + renderedObjects + "/" + totalObjects;
		return s;
	}

}
