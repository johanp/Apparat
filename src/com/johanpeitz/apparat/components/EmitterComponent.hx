package com.johanpeitz.apparat.components;

import openfl.geom.Point;
import com.johanpeitz.apparat.IEntityContainer;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.utils.MathUtil;

/**
 * Easy way to emit other entities.
 * @author Johan Peitz
 */
class EmitterComponent extends Component {
	private var _emittedEntityClass : Class<Entity>;

	private var _numSimulEntities : Int = 1;
	private var _numTotalEntities : Int = -1;

	private var _emitDelay : Point;
	private var _emitForce : Point;
	private var _emitAngle : Point;
	private var _emitLife : Point;

	private var _emitDelayTarget : Float = 0;
	private var _emitDelayProgress : Float = 0;
	private var _totalEntitiesEmitted : Int = 0;

	private var _numEntitiesEmitted : Int = 0;

	private var _emitTo : IEntityContainer;

	/**
	 * Constructs a new component.
	 * @param	pEntityClassToEmit	Entity to emit.
	 * @param	pEmitTo	Where the emitted entities should be added. If null they will be emitted added to the component's entity.
	 */
	public function new( pEntityClassToEmit : Class < Entity >, pEmitTo : IEntityContainer = null ) {
		super( );

		_emitDelay = new Point( 1, 1 );
		_emitForce = new Point();
		_emitAngle = new Point();
		_emitLife = new Point();

		_emitTo = pEmitTo;
		_emittedEntityClass = pEntityClassToEmit;
		_emitDelayTarget = MathUtil.randomFloat( _emitDelay.x, _emitDelay.y );

	}

	/**
	 * Clears resources used.
	 */
	public override function dispose() : Void {
		_emitTo = null;
		super.dispose();
	}

	/**
	 * Updates the emitter. Emits new entity if needed.
	 * @param	pDT
	 */
	public override function update( pDT : Float ) : Void {
		_emitDelayProgress += pDT;

		if ( _emitDelayProgress > _emitDelayTarget ) {
			_emitDelayProgress -= _emitDelayTarget;
			_emitDelayTarget = MathUtil.randomFloat( _emitDelay.x, _emitDelay.y );

			if ( _totalEntitiesEmitted < _numTotalEntities || _numTotalEntities == -1 ) {
				if ( _numEntitiesEmitted < _numSimulEntities || _numSimulEntities == -1 ) {
					// emit!
					var entityToEmit : Entity = Type.createInstance( _emittedEntityClass, [] );
					if ( _emitTo != null && _emitTo != entity ) {
						entityToEmit.transform.position.x = entity.transform.position.x;
						entityToEmit.transform.position.y = entity.transform.position.y;
					}

					var body : BodyComponent = cast( entityToEmit.getComponentByClass( BodyComponent ), BodyComponent );
					if ( body != null ) {
						var a : Float = MathUtil.randomFloat( _emitAngle.x, _emitAngle.y );
						var f : Float = MathUtil.randomFloat( _emitForce.x, _emitForce.y );
						var vel : Point = new Point( f * Math.cos( a ), f * Math.sin( a ) );

						body.velocity.x += vel.x;
						body.velocity.y += vel.y;
					}

					if ( _emitLife.y > 0 ) {
						entityToEmit.removeIn( MathUtil.randomFloat( _emitLife.x, _emitLife.y ) );
					}

					if ( _emitTo == null ) {
						entity.addEntity( entityToEmit );
					} else {
						_emitTo.addEntity( entityToEmit );
					}

					entityToEmit.addOnRemovedCallback( onEmittedEntityRemovedFromScene );

					_numEntitiesEmitted++;
					_totalEntitiesEmitted++;
				}

				super.update( pDT );
			}
		}

	}

	/**
	 * Keeps track of number of emitted entites.
	 * Invoked when an emitted entity is removed.
	 * @param	pEntity
	 */
	private function onEmittedEntityRemovedFromScene( pEntity : Entity ) : Void {
		_numEntitiesEmitted--;
	}

	/**
	 * Sets the number of emitted entities that can exists at the same time.
	 * If this number is reached, one of the entities must be removed before a new one is emitted.
	 * @param	value	Float of entites that can exists at the same time.
	 */
	public function setNumSimulEntities( value : Int ) : Void {
		_numSimulEntities = value;
	}

	/**
	 * Total number of entities this emitter will emit.
	 * When this number is reached, no more entities will be emitted.
	 * @param	value	Total number of entities.
	 */
	public function setNumTotalEntities( value : Int ) : Void {
		_numTotalEntities = value;
	}

	/**
	 * Sets the range of the delay between each emitted entity.
	 * @param	pMin	Minimum time to wait. (Seconds.)
	 * @param	pMax	Maximum time to wait. (Seconds.)
	 */
	public function setEmitDelayRange( pMin : Float, pMax : Float ) : Void {
		_emitDelay.x = pMin;
		_emitDelay.y = pMax;

		_emitDelayProgress = 0;
		_emitDelayTarget = MathUtil.randomFloat( _emitDelay.x, _emitDelay.y );
	}

	/**
	 * Sets the range of the force that emitted entities are given.
	 * This only applies if emitted entity has a body component.
	 * @param	pMin	Minimum emit force.
	 * @param	pMax	Maximum emit force.
	 */
	public function setEmitForceRange( pMin : Float, pMax : Float ) : Void {
		_emitForce.x = pMin;
		_emitForce.y = pMax;
	}

	/**
	 * Controls the angles that emitted entities will have. Only applies if there is also an emit force.
	 * @param	pMin	Minimum angle in radians.
	 * @param	pMax	Maximum angle in radians.
	 */
	public function setEmitAngleRange( pMin : Float, pMax : Float ) : Void {
		_emitAngle.x = pMin;
		_emitAngle.y = pMax;
	}

	/**
	 * Sets the life time range of emitted entities.
	 * @param	pMin	Minimum life time in seconds.
	 * @param	pMax	Maximum life time in seconds.
	 */
	public function setEmitLifeRange( pMin : Float, pMax : Float ) : Void {
		_emitLife.x = pMin;
		_emitLife.y = pMax;
	}

}

