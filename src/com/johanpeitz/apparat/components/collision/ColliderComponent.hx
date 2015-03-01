package com.johanpeitz.apparat.components.collision;

import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.utils.ArrayUtil;
import com.johanpeitz.apparat.physics.CollisionData;

import com.johanpeitz.apparat.components.Component;

/**
 * The collider component acts as base class for all types of collisions.
 * Each collider can belong to any number of collision layers. This is handled by
 * a bit mask. By changing the collider's mask or the mask which controls which
 * layers the collider collides with, various useful effects can be achieved.
 *
 * @author Johan Peitz
 */
class ColliderComponent extends Component {
	/**
	 * Returns bitmask for which collision layers this collider belongs to.
	 * Use addCollisionLayer(...) and removeCollisionLayer(...) to modify.
	 */
	public var collisionLayer : Int = 0;
	/**
	 * Returns bitmask for which collision layer masks this collider belongs to.
	 * Use addCollisionLayerMask(...) and removeCollisionLayerMask(...) to modify.
	 */
	public var collisionLayerMask : Int = 0;

	/**
	 * Specifies whether this collider is solid or just a trigger.
	 */
	public var solid : Bool = true;

	/**
	 * Callback invoked when a collision starts.
	 */
	private var _onCollisionStartCallback : Dynamic = null;
	/**
	 * Callback invoked every frame the collision lasts (except the first).
	 */
	private var _onCollisionOngoingCallback : Dynamic = null;
	/**
	 * Callback invoked when a collision ends.
	 */
	private var _onCollisionEndCallback : Dynamic = null;

	private var _currentColliders : Array<ColliderComponent>;

	/**
	 * Constructs a new collider.
	 * @param	pSolid	Specifies whether collider should be solid.
	 */
	public function new( pSolid : Bool = true ) {
		super( );

		_currentColliders = new Array<ColliderComponent>();

		solid = pSolid;

		priority = 1;
	}

	/**
	 * Clears all resources used by collider.
	 */
	override public function dispose() : Void {
		_currentColliders = null;
		_onCollisionStartCallback = _onCollisionOngoingCallback = _onCollisionEndCallback = null;
	}

	/**
	 * Invoked when collider's entity is added to scene.
	 * Automatically adds the collider to the scene's collision manager.
	 * @param	pScene	Scene entity was added to.
	 */
	override public function onEntityAddedToScene( pScene : Scene ) : Void {
		entity.scene.collisionHandler.addCollider( this );
	}

	/**
	 * Invoked when collider's entity is removed from scene.
	 * Automatically removed the collider from the scene's collision manager.
	 * @param	pScene	Scene entity was removed from.
	 */
	override public function onEntityRemovedFromScene() : Void {
		entity.scene.collisionHandler.removeCollider( this );
	}

	/**
	 * Adds a collider to the current list of active collisions.
	 * Invoked by the collision manager.
	 * @param	pCollider	Collider to add.
	 */
	public function addCollidingCollider( pCollider : ColliderComponent ) : Void {
		_currentColliders.push( pCollider );
	}

	/**
	 * Remove a collider from the current list of active collisions.
	 * Invoked by the collision manager.
	 * @param	pCollider	Collider to remove.
	 */
	public function removeCollidingCollider( pCollider : ColliderComponent ) : Void {
		_currentColliders.splice( ArrayUtil.indexOf(_currentColliders, pCollider ), 1 );
	}

	/**
	 * Checks whether a collider is already in this collider's collider list.
	 * @param	pCollider	Collider to look for.
	 * @return	True if collider was found.
	 */
	public function hasCollidingCollider( pCollider : ColliderComponent ) : Bool {
		return ArrayUtil.indexOf(_currentColliders, pCollider ) != -1;
	}

	/**
	 * Allows an entity to get callbacks when ever this collider updates it's collision status.
	 * @param	pOnCollisionStartCallback	Function called on first contact.
	 * @param	pOnCollisionOngoingCallback	Function called on repeated contact.
	 * @param	pOnCollisionEndCallback		Function called on lost contact.
	 */
	public function registerCallbacks( pOnCollisionStartCallback : Dynamic = null, pOnCollisionOngoingCallback : Dynamic = null, pOnCollisionEndCallback : Dynamic = null ) : Void {
		_onCollisionStartCallback = pOnCollisionStartCallback;
		_onCollisionOngoingCallback = pOnCollisionOngoingCallback;
		_onCollisionEndCallback = pOnCollisionEndCallback;
	}

	/**
	 * Invoked by collision manager when a new collision occurs.
	 * @param	pCollisionData	Data containing collision info.
	 */
	public function onCollisionStart( pCollisionData : CollisionData ) : Void {
		if ( _onCollisionStartCallback != null ) {
			_onCollisionStartCallback( pCollisionData );
		}
	}

	/**
	 * Invoked by collision manager every frame as long a collision keeps happning.
	 * @param	pCollisionData	Data containing collision info.
	 */
	public function onCollisionOngoing( pCollisionData : CollisionData ) : Void {
		if ( _onCollisionOngoingCallback != null ) {
			_onCollisionOngoingCallback( pCollisionData );
		}
	}

	/**
	 * Invoked by collision manager when a collision ends.
	 * @param	pCollisionData	Data containing collision info.
	 */
	public function onCollisionEnd( pCollisionData : CollisionData ) : Void {
		if ( _onCollisionEndCallback != null ) {
			_onCollisionEndCallback( pCollisionData );
		}
	}

	/**
	 * Adds collider to a collision layer.
	 * @param	pLayerID        Which layer to add collider to.
	 */
	public function addToCollisionLayer( pLayerID : Int ) : Void {
		collisionLayer |= ( 1 << pLayerID );
	}

	/**
	 * Removes a collider from a collision layer.
	 * @param	pLayerID	Which layer to remove from.
	 */
	public function removeFromCollisionLayer( pLayerID : Int ) : Void {
		collisionLayer &= ( ~( 1 << pLayerID ) );
	}


	/**
	 * Adds a collision layer to collide with.
	 * @param	pLayerID        Which layer to add.
	 */
	public function enableCollisionWithCollisionLayer( pLayerID : Int ) : Void {
		collisionLayerMask |= ( 1 << pLayerID );
	}

	/**
	 * Removes a collision layer to no longer collide with.
	 * @param	pLayerID	Which layer to remove.
	 */
	public function disableCollisionWithCollisionLayer( pLayerID : Int ) : Void {
		collisionLayerMask &= ( ~( 1 << pLayerID ) );
	}



}
