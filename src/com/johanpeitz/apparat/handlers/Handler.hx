package com.johanpeitz.apparat.handlers;


import com.johanpeitz.apparat.components.Component;
import com.johanpeitz.apparat.Scene;

/**
 * A handler lives in a scene and is updated every frame.
 * It can do pretty much anything from handling collisions to rendering stuff.
 * Change the priority on each handler to decide in which order they update. There are two main areas, update and render.
 * Update is called every frame, and render when time permits.
 * @author Johan Peitz
 */
class Handler {

	private var _priority : Int;
	private var _stats : HandlerStats;

	/**
	 * The scene on which the handler operates.
	 */
	public var scene : Scene;


	/**
	 * Creates a new handler.
	 * @param	pScene	The scene which the handler should operate on.
	 * @param	pPriority	When to update in relation to any other handlers.
	 */
	public function new( pScene : Scene, pPriority : Int = 0 ) {
		scene = pScene;
		_priority = pPriority;
	}

	/**
	 * Clears up any resources used by the handler.
	 */
	public function dispose() : Void {
		scene = null;
		_stats = null;
	}

	/**
	 * Invoked before this and any other handlers are updated.
	 */
	public function beforeUpdate( ) : Void {

	}
	/**
	 * Invoked once every frame.
	 * @param	pDT	Time to spend in this frame.
	 */
	public function update( pDT : Float ) : Void {

	}
	/**
	 * Invoked after this and any other handlers are updated.
	 */
	public function afterUpdate( ) : Void {

	}

	/**
	 * Invoked before this and any other handlers are rendered.
	 */
	public function beforeRender( ) : Void {

	}
	/**
	 * Invoked when it is rendering time.
	 */
	public function render( ) : Void {

	}
	/**
	 * Invoked after this and any other handlers are rendered.
	 */
	public function afterRender( ) : Void {

	}

	/**
	 * Returns the priority set to this handler.
	 */
	public var priority( get_priority, null ) : Int;
	private function get_priority() : Int {
		return _priority;
	}

	/**
	 * Returns any stats generated.
	 */
	public function getStats() : HandlerStats {
		return _stats;
	}

	/**
	 * Helper function to sort handlers by priority. Used internally.
	 * @param	pHandlerA
	 * @param	pHandlerB
	 * @return
	 */
	static public function sortOnPriority( pHandlerA : Handler, pHandlerB : Handler ) : Int {
		return pHandlerA.priority - pHandlerB.priority;
	}

}
