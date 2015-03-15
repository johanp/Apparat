package com.johanpeitz.apparat.components.collision;

import com.johanpeitz.apparat.physics.AABB;

/**
 * Collider consiting of a simple box.
 */
class BoxColliderComponent extends ColliderComponent {
	/**
	 * Axis Aligned Bounding Box for this collider.
	 */
	public var collisionBox : AABB = null;

	/**
	 * Constructs a new box collider.
	 * @param	pWidth	Width of box.
	 * @param	pHeight	Height of box.
	 * @param	pSolid	Specifies whether collider should be solid or not.
	 * @param	pFixed	Specifies whether collider will move at all on collision with other colliders.
	 */
	public function new( pWidth : Float, pHeight : Float, pSolid : Bool = true, pFixed : Bool = false ) {
		super( pSolid, pFixed );
		collisionBox = new AABB( pWidth, pHeight, pWidth / 2, pHeight / 2 );
	}

	/**
	 * Clears all resources used by collider.
	 */
	override public function dispose() : Void {
		collisionBox = null;

		super.dispose();
	}

	/**
	 * Sets the size of the collision box.
	 * @param	pWidth	Width of box.
	 * @param	pHeight	Height of box.
	 */
	public function setSize( pWidth : Float, pHeight : Float ) : Void {
		collisionBox.halfWidth = pWidth / 2;
		collisionBox.halfHeight = pHeight / 2;
		collisionBox.offsetX = pWidth / 2;
		collisionBox.offsetY = pHeight / 2;

	}

}
