package com.johanpeitz.apparat;

import com.johanpeitz.apparat.components.Component;
import com.johanpeitz.apparat.components.TransformComponent;
import com.johanpeitz.apparat.IEntityContainer;
import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.utils.ArrayUtil;

/**
 * Base base class for all entities. Entites have to be added to scenes
 * in order to be updated. Entities can also be nested.
 *
 * @author Johan Peitz
 */
class Entity implements IEntityContainer {
	private var _removeInSeconds : Float = -1;
	private var _removeNow : Bool = false;

	private var _id : Int;
	private static var _idCounter : Int = 0;

	/**
	 * Scene this entity is added to.
	 */
	public var scene : Scene;

	/**
	 * Transform of this entity.
	 */
	public var transform : TransformComponent;

	/**
	 * Parent of entity in tree hierarchy.
	 */
	public var parent : IEntityContainer = null;
	/**
	 * Handle for quick access.
	 */
	public var handle : String;

	private var _components : Array<Component>;
	private var _entities : Array<Entity>;
	private var _entitiesToAdd : Array<Entity>;
	private var _entitiesToRemove : Array<Entity>;

	private var _onRemovedCallbacks : Array<Dynamic>;

	/**
	 * Creates a new entity at desired postion.
	 *
	 * @param	pX	X position of entity.
	 * @param	pY	Y position of entity.
	 */
	public function new( pX : Float = 0, pY : Float = 0 ) {
		_id = _idCounter + 1;

		_components = new Array<Component>();
		_entities = new Array<Entity>();
		_entitiesToAdd = new Array<Entity>();
		_entitiesToRemove = new Array<Entity>();

		_onRemovedCallbacks = new Array<Dynamic>();

		transform = new TransformComponent( pX, pY );
		addComponent( transform );
	}

	/**
	 * Disposes the entity and it's components. All nested entites are also disposed.
	 */
	public function dispose() : Void {

		removeEntitiesFromQueue();
		_entitiesToRemove = null;

		addEntitiesFromQueue();
		_entitiesToAdd = null;

		for ( e in _entities ) {
			e.dispose();
		}

		for ( c in _components ) {
			c.dispose();
		}
		_components = null;

		scene = null;

		_onRemovedCallbacks = null;

	}

	/**
	 * Invoked when entity is added to a scene.
	 *
	 * @param	pScene	Scene which the entity was just added to.
	 */
	public function onAddedToScene( pScene : Scene ) : Void {
		scene = pScene;
		for ( c in _components ) {
			c.onEntityAddedToScene( scene );
		}

		for ( e in _entities ) {
			e.onAddedToScene( scene );
		}

	}

	/**
	 * Invoked when entity is removed from a scene.
	 */
	public function onRemovedFromScene() : Void {
		for ( f in _onRemovedCallbacks ) {
			f( this );
		}
		_onRemovedCallbacks = new Array <Dynamic>();

		for ( c in _components ) {
			c.onEntityRemovedFromScene();
		}

		for ( e in _entities ) {
			e.onRemovedFromScene();
		}

		scene = null;
	}

	/**
	 * Tells the entity to be disposed in x of seconds.
	 *
	 * @param	pSeconds	Float of second until disposal.
	 */
	public function removeIn( pSeconds : Float ) : Void {
		if ( _removeInSeconds < 0 ) {
			_removeInSeconds = pSeconds;
		}
	}

	/**
	 * Adds a component to the entity.
	 *
	 * @param	pComponent	Component to add.
	 * @return	The component parameter passed as argument.
	 */
	public function addComponent( pComponent : Component ) : Component {
		_components.push( pComponent );
		_components.sort( sortOnPriority );
		pComponent.onAddedToEntity( this );

		if ( scene != null ) {
			pComponent.onEntityAddedToScene( scene );
		}

		return pComponent;
	}

	/**
	 * Removes a component from the entity. The component will NOT be disposed.
	 * @param	pComponent	Component to remove.
	 * @return	The component paramater passed as argument.
	 */
	public function removeComponent( pComponent : Component ) : Component {
		if ( scene != null ) {
			pComponent.onEntityRemovedFromScene();
		}

		_components.splice( ArrayUtil.indexOf( _components, pComponent ), 1 );
		pComponent.onRemovedFromEntity();

		return pComponent;
	}

	/**
	 * Removes all components from this entity.
	 */
	public function removeAllComponents() : Void {
		for ( c in _components ) {
			if ( scene != null ) {
				c.onEntityRemovedFromScene();
			}
			c.onRemovedFromEntity();
		}
		_components = new Array< Component >();
	}

	private function sortOnPriority( a : Component, b : Component ) : Int {
		return a.priority - b.priority;
	}

	/**
	 * Adds an entity to the entity, extending the entity tree hierarchy.
	 * @param	pEntity	Entity to add.
	 * @return	The entity parameter passed as argument.
	 */
	public function addEntity( pEntity : Entity, pHandle : String = "" ) : Entity {
		pEntity.handle = pHandle;
		_entitiesToAdd.push( pEntity );

		return pEntity;
	}

	/**
	 * Removes an entity from the entity.
	 * @param	pEntity Entity to remove. The entity will be disposed.
	 * @return	The entity parameter passed as argument.
	 */
	public function removeEntity( pEntity : Entity ) : Entity {
		_entitiesToRemove.push( pEntity );

		return pEntity;
	}

	/**
	 * Adds entities with the specified handle to the specified vector.
	 * @param	pRootEntity	Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pHandle	Handle to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitiesByHandle( pRootEntity : Entity, pHandle : String, pEntityVector : Array<Entity> ) : Void {
		if ( pRootEntity.handle == pHandle ) {
			pEntityVector.push( pRootEntity );
		}
		for ( e in pRootEntity.entities ) {
			getEntitiesByHandle( e, pHandle, pEntityVector );
		}
	}

	/**
	 * Adds entities of the desired class to the specified vector.
	 * @param	pRootEntity		Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pEntityClass	The entity class to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitesByClass( pRootEntity : Entity, pEntityClass : Class<Dynamic>, pEntityVector : Array<Entity> ) : Void {
		if ( Std.is( pRootEntity, pEntityClass ) ) {
			pEntityVector.push( pRootEntity );
		}
		for ( e in pRootEntity.entities ) {
			getEntitesByClass( e, pEntityClass, pEntityVector );
		}
	}

	/**
	 * Invoked regularly by the scene. Updates all components and nested entities in the entity.
	 * @param	pDT	Time step in number of seconds.
	 */
	public function update( pDT : Float ) : Void {
		var pos : Int;
		var c : Component;

		// add entities
		addEntitiesFromQueue();

		pos = _components.length;
		while ( --pos >= 0 ) {
			c = _components[ pos ];
			if ( c.enabled ) {
				c.update( pDT );
			}
		}
		
		// remove entities
		removeEntitiesFromQueue();

		// dispose entity?
		if ( _removeInSeconds >= 0 ) {
			_removeInSeconds -= pDT;
			if ( _removeInSeconds <= 0 ) {
				_removeNow = true;
			}
		}
	}

	private function addEntitiesFromQueue() : Void {
		var e : Entity;
		if ( _entitiesToAdd.length > 0 ) {
			for ( e in _entitiesToAdd ) {
				_entities.push( e );
				e.parent = this;
				if ( scene != null ) {
					e.onAddedToScene( scene );
				}
			}
			_entitiesToAdd = new Array<Entity>();
		}
	}

	private function removeEntitiesFromQueue() : Void {
		var pos : Int = _entitiesToRemove.length;
		var e : Entity;
		if ( pos > 0 ) {
			while ( --pos >= 0 ) {
				e = _entitiesToRemove[ pos ];
				_entities.splice( ArrayUtil.indexOf( _entities, e ), 1 );
				e.onRemovedFromScene();
				e.dispose();
			}
			_entitiesToRemove = new Array<Entity>();
		}
	}

	/**
	 * Tells wether the entity already has a component of a certain class.
	 * @param	pClass	Component class to check.
	 * @return	True if the entity has a component of this class. False otherwise.
	 */
	public function hasComponentByClass( pClass : Class<Dynamic> ) : Bool {
		for ( c in _components ) {
			if ( Std.is( c, pClass ) ) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Returns the first found (if any) component of a certain class.
	 * @param	pClass	Component class to look for.
	 * @return	First instance found of requested class. Or null if no such class found.
	 */
	public function getComponentByClass( pClass : Class<Dynamic> ) : Component {
		for ( c in _components ) {
			if ( Std.is( c, pClass ) ) {
				return c;
			}
		}

		return null;
	}

	/**
	 * Returns all components of a certain class.
	 * @param	pClass	Component class to look for.
	 * @return	Vector of components.
	 */
	public function getComponentsByClass( pClass : Class<Dynamic> ) : Array<Component> {
		var v : Array<Component> = new Array<Component>();
		for ( c in _components ) {
			if ( Std.is( c, pClass ) ) {
				v.push( c );
			}
		}

		return v;
	}

	/**
	 * Adds a function which will be called when this entity is removed from the scene.
	 * @param	pFunction	Function to call.
	 */
	public function addOnRemovedCallback( pFunction : Dynamic ) : Void {
		_onRemovedCallbacks.push( pFunction );
	}
	
	/**
	 * Returns all entities added to this entity.
	 * @return	Vector of entities.
	 */
	public var entities( get_entities, null ) : Array<Entity>;
	private function get_entities() : Array<Entity> {
		return _entities;
	}

	/**
	 * Checks if entity wants to be disposed.
	 * @return True if entity is listed to be disposed.
	 */
	public var removeNow( get_removeNow, null ) : Bool;
	private function get_removeNow() : Bool {
		return _removeNow;
	}


	public var id( get_id, null ) : Int;
	private function get_id() : Int {
		return _id;
	}
	
	
	
	
}

