package com.johanpeitz.apparat.render;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.handlers.Handler;
import com.johanpeitz.apparat.handlers.HandlerStats;
import com.johanpeitz.apparat.utils.RenderStats;
import openfl.display.DisplayObject;
import openfl.Lib;

/**
 * ...
 * @author Johan Peitz
 */
class RenderHandler extends Handler {

	private var _renderStats : RenderStats;

	public function new( pScene : Scene, pPriority : Int = 0, pTransparent : Bool = false ) {
		super( pScene, pPriority );

		_stats = _renderStats = new RenderStats();
	}

	/**
	 * Clears all used resources.
	 */
	override public function dispose() : Void {
		_renderStats = null;

		super.dispose();
	}


	/**
	 * Invoked before rendering starts. Clears stats and locks bitmap.
	 */
	override public function beforeRender() : Void {
		_stats.reset();
		_renderStats.renderTime = Lib.getTimer();
	}



	override public function afterRender() : Void {
		_renderStats.renderTime = Lib.getTimer() - _renderStats.renderTime;
	}


	/**
	 *
	 */
	public function getDisplayObject() : DisplayObject {
		return null;
	}

	




}

