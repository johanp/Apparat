package com.johanpeitz.apparat.physics;

import openfl.geom.Point;
import com.johanpeitz.apparat.components.collision.ColliderComponent;

/**
 * Contains data generated when to colliders overlap.
 * @author Johan Peitz
 */
class CollisionData {
	/**
	 * Collided collider.
	 */
	public var myCollider : ColliderComponent;
	/**
	 * Collider collided with.
	 */
	public var otherCollider : ColliderComponent;
	/**
	 * Overlap between colliders.
	 */
	public var overlap : Point;

	/**
	 * Creates new collision data.
	 * @param	pMyCollider	Collided collider.
	 * @param	pOtherCollider	Collider collided with.
	 * @param	pOverlap	Overlap between colliders.
	 */
	public function new( pMyCollider : ColliderComponent = null, pOtherCollider : ColliderComponent = null, pOverlap : Point = null ) {
		myCollider = pMyCollider;
		otherCollider = pOtherCollider;
		overlap = pOverlap;
	}

	/**
	 * Clear all references this data uses.
	 */
	public function dispose() : Void {
		myCollider = otherCollider = null;
		overlap = null;
	}

}

