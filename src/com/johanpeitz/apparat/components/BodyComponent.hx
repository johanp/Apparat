package com.johanpeitz.apparat.components;
import openfl.geom.Point;
import com.johanpeitz.apparat.Apparat;

/**
 * Allows an entity to respond to gravity, have velocity.
 */
class BodyComponent extends Component {
	/**
	 * Denotes that the body is on ground.
	 */
	public static inline var ON_GROUND : Int = 0;
	/**
	 * Denotes that the body is in the air.
	 */
	public static inline var IN_AIR : Int = 1;

	/**
	 * Current velocity of this body.
	 */
	public var velocity : Point;
	/**
	 * Mass of this body.
	 */
	public var mass : Float = 1;


	private var _gravity : Point;

	/**
	 * Creates a new body component.
	 * @param	pMass	Mass of this body.
	 */
	public function new( pMass : Float = 1 ) {
		super( );
		mass = pMass;

		velocity = Apparat.pointPool.fetch();
		velocity.x = velocity.y = 0;

		_gravity = Apparat.pointPool.fetch();
		_gravity.x = 0;
		_gravity.y = 1;
	}

	/**
	 * Clears all resources used.
	 */
	override public function dispose() : Void {
		super.dispose();

		Apparat.pointPool.recycle( velocity );
		Apparat.pointPool.recycle( _gravity );

		velocity = null;
		_gravity = null;
	}

	/**
	 * Updates the entity with the velocity in the body.
	 * @param	pDT	Time step.
	 */
	override public function update( pDT : Float ) : Void {
		super.update( pDT );


		velocity.x += _gravity.x * mass;
		velocity.y += _gravity.y * mass;


		// move in y
		entity.transform.position.y += velocity.y;

		// move in x
		entity.transform.position.x += velocity.x;
	}


	/**
	 * Sets the gravity for this body.
	 * @param	pX	Gravity along X.
	 * @param	pY	Gravity along Y.
	 */
	public function setGravity( pX : Float, pY : Float ) : Void {
		_gravity.x = pX;
		_gravity.y = pY;
	}

	/**
	 * Sets the velocity for this body.
	 * @param	pVelX	X velocity.
	 * @param	pVelY	Y velocity.
	 */
	public function setVelocity( pVelX : Float, pVelY : Float ) : Void {
		velocity.x = pVelX;
		velocity.y = pVelY;
	}

}
