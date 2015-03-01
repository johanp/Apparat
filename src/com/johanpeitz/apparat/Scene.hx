package com.johanpeitz.apparat;

import com.johanpeitz.apparat.render.RenderHandler;
import com.johanpeitz.apparat.sound.SoundHandler;
import com.johanpeitz.apparat.IEntityContainer;
import com.johanpeitz.apparat.physics.CollisionHandler;
import com.johanpeitz.apparat.render.HWRenderHandler;
import com.johanpeitz.apparat.utils.ArrayUtil;
import com.johanpeitz.apparat.render.Camera;
import com.johanpeitz.apparat.handlers.Handler;
import com.johanpeitz.apparat.handlers.UpdateHandler;
import com.johanpeitz.apparat.utils.MathUtil;
import openfl.display.Sprite;

/**
 * The scene holds and manages all entities. Scenes are updated by the engine.
 *
 * @author Johan Peitz
 */
class Scene implements IEntityContainer {
	private var _entityRoot : Entity;

	/**
	 * Handlers running on current scene.
	 */
	private var _handlers : Array<Handler>;
	private var _renderHandler : RenderHandler;
	private var _collisionHandler : CollisionHandler;
	private var _soundHandler : SoundHandler;
	private var _inputHandler : InputHandler;

	private var _mainCamera : Camera;

	public var framesPassed  : Int;
	public var secondsPassed : Float;

	
	/**
	 * Engine scene is added to.
	 */
	public var engine : Engine = null;

	/**
	 * Constructs a new scene.
	 */
	public function new( ) {
		_entityRoot = new Entity();
		_entityRoot.scene = this;

		_handlers = [];
		addHandler( new UpdateHandler( this, 150 ) );
		_renderHandler = cast( addHandler( Type.createInstance( Apparat.getRenderHandlerClass(), [ this, 1000 ] ) ), RenderHandler );
		_inputHandler = cast( addHandler( new InputHandler( this, 100 ) ), InputHandler );
		_collisionHandler = cast( addHandler( new CollisionHandler( this, 200 ) ), CollisionHandler );
		_soundHandler = cast( addHandler( new SoundHandler( this, 300 ) ), SoundHandler );

		_mainCamera = new Camera( Apparat.engine.engineWidth, Apparat.engine.engineHeight, Std.int( -Apparat.engine.engineWidth / 2 ), Std.int( -Apparat.engine.engineHeight / 2 ) );

		framesPassed = 0;
		secondsPassed = 0;
	}

	/**
	 * Cleans up all resources used by the scene, including any added entities which will also be disposed.
	 */
	public function dispose() : Void {

		_entityRoot.dispose();
		_entityRoot = null;

		_mainCamera.dispose();
		_mainCamera = null;

		for ( s in _handlers ) {
			s.dispose();
		}
		_handlers = null;

		engine = null;
	}

	/**
	 * Invoked when the scene is added to the engine.
	 * @param	pEngine	The engine the scene is added to.
	 */
	public function onAddedToEngine( pEngine : Engine ) : Void {
		engine = pEngine;
	}

	/**
	 * Invoked when the scene is remove from an engine. Disposes the scene.
	 */
	public function onRemovedFromEngine() : Void {
		engine = null;
		dispose();
	}
	
	/**
	 * Called when returning from paused mode.
	 */
	public function onActivated() : Void
	{
		_soundHandler.unpause();
		_inputHandler.reset();
	}

	/**
	 * Called when paused.
	 */
	public function onDeactivated() : Void
	{
		_soundHandler.pause();
	}


	/**
	 * Invoked regularly by the engine. Updates all entities and subhandlers.
	 * @param	pDT	Time step in number of seconds.
	 */
	public function update( pDT : Float ) : Void {
		var s : Handler;
		// update all handlers
		for ( s in _handlers ) {
			s.beforeUpdate( );
		}

		for ( s in _handlers ) {
			s.update( pDT );
		}

		if ( _mainCamera != null ) {
			_mainCamera.update( pDT );
		}

		for ( s in _handlers ) {
			s.afterUpdate( );
		}

		secondsPassed += pDT;
		framesPassed++;

	}

	
	/**
	 * Renders the scene.
	 */
	public function render() : Void {
		var s : Handler;
		for ( s in _handlers ) {
			s.beforeRender( );
		}

		for ( s in _handlers ) {
			s.render( );
		}

		for ( s in _handlers ) {
			s.afterRender( );
		}

	}


	/**
	 * Returns the camera for this scene.
	 */
	public var camera( get_camera, null) : Camera;
	private function get_camera() : Camera {
		return _mainCamera;
	}

	/**
	 * Returns the root entity to which all other entities are added.
	 * @return      The root entity.
	 */
	public var entityRoot(get_entityRoot, null) : Entity;
	private function get_entityRoot() : Entity {
		return _entityRoot;
	}


	public var collisionHandler(get_collisionHandler, null) : CollisionHandler;
	private function get_collisionHandler() : CollisionHandler{
		return _collisionHandler;
	}
	public var soundHandler(get_soundHandler, null) : SoundHandler;
	private function get_soundHandler() : SoundHandler{
		return _soundHandler;
	}

	public var inputHandler(get_inputHandler, null) : InputHandler;
	private function get_inputHandler() : InputHandler
	{
		return _inputHandler;
	}
	public var renderHandler(get_renderHandler, null) : RenderHandler;
	private function get_renderHandler() : RenderHandler
	{
		return _renderHandler;
	}

	/**
	 * Adds and entity to the scene.
	 * @param	pEntity The entity to add.
	 * @return	The entity parameter passed as argument.
	 */
	public function addEntity( pEntity : Entity, pHandle : String = "" ) : Entity {
		return _entityRoot.addEntity( pEntity, pHandle );
	}

	/**
	 * Removes an entity from the scene. The entity will be disposed.
	 * @param	pEntity	The entity to remove.
	 * @return	The entity parameter passed as argument.
	 */
	public function removeEntity( pEntity : Entity ) : Entity {
		return _entityRoot.removeEntity( pEntity );
	}

	/**
	 * Adds entities of the desired class to the specified vector.
	 * @param	pRootEntity		Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pEntityClass	The entity class to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitesByClass( pRootEntity : Entity, pEntityClass : Class<Dynamic>, pEntityVector : Array<Entity> ) : Void {
		return _entityRoot.getEntitesByClass( pRootEntity, pEntityClass, pEntityVector );
	}

	/**
	 * Adds entities with the specified handle to the specified vector.
	 * @param	pRootEntity	Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pHandle	Handle to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitiesByHandle( pRootEntity : Entity, pHandle : String, pEntityVector : Array<Entity> ) : Void {
		return _entityRoot.getEntitiesByHandle( pRootEntity, pHandle, pEntityVector );
	}

	public function forEachEntity( pEntityRoot : Entity, pFunction : Dynamic ) : Void {
		pFunction( pEntityRoot );
		for ( e in pEntityRoot.entities ) {
			forEachEntity( e, pFunction );
		}
	}

	public function removeHandler( pHandler : Handler ) : Handler {
		_handlers.splice( ArrayUtil.indexOf( _handlers, pHandler ), 1 );
		return pHandler;
	}

	public function addHandler( pHandler : Handler ) : Handler {
		_handlers.push( pHandler );
		_handlers.sort( Handler.sortOnPriority );
		return pHandler;
	}

	public function getHandlers() : Array<Handler>
	{
		return _handlers;
	}



}
