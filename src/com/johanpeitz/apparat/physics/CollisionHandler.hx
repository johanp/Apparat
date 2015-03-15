package com.johanpeitz.apparat.physics;

import openfl.geom.Point;
import com.johanpeitz.apparat.components.collision.BoxColliderComponent;
import com.johanpeitz.apparat.components.collision.ColliderComponent;
import com.johanpeitz.apparat.components.collision.GridColliderComponent;
import com.johanpeitz.apparat.components.BodyComponent;
import com.johanpeitz.apparat.physics.CollisionData;
import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.handlers.Handler;
import com.johanpeitz.apparat.utils.CollisionStats;
import com.johanpeitz.apparat.utils.ArrayUtil;

/**
 * Manages collision between colliders of all types. Each scene has their own collision manager.
 * @author Johan Peitz
 */
class CollisionHandler extends Handler {

	private var _colliders : Array<ColliderComponent>;
	private var _overlap : Point;
	private var _collisionStats : CollisionStats;

	/**
	 * Creates a new collision handler.
	 */
	public function new( pScene : Scene, pPriority : Int = 0 ) : Void {
		super( pScene, pPriority );

		_overlap = new Point();
		_colliders = new Array<ColliderComponent>();

		_stats = _collisionStats = new CollisionStats();
	}

	/**
	 * Clears all resources used by this handler.
	 */
	override public function dispose() : Void {
		_colliders = null;
		_collisionStats = null;
		super.dispose();
	}


	/**
	 * Adds a collider to the handler. The collider will now be check for collision against other colliders.
	 * @param	pCollider	Collider to add.
	 */
	public function addCollider( pCollider : ColliderComponent ) : Void {
		_colliders.push( pCollider );
	}

	/**
	 * Removes a collider from the handler. It will no longer collide with other colliders.
	 * @param	pCollider	Collider to remove.
	 */
	public function removeCollider( pCollider : ColliderComponent ) : Void {
		_colliders.splice( ArrayUtil.indexOf( _colliders, pCollider ), 1 );
	}


	/**
	 * Invoked regularly by the scene. Detects and responds to all collisions between colliders.
	 * @param	pDT
	 */
	override public function update( pDT : Float ) : Void {
		var a : ColliderComponent;
		var b : ColliderComponent;
		var len : Int = _colliders.length;
		var collisionDataA : CollisionData = new CollisionData();
		var collisionDataB : CollisionData = new CollisionData();

		_collisionStats.reset();
		_collisionStats.colliderObjects = len;

		for ( i in 0...len ) {
			a = _colliders[ i ];
			for ( j in (i + 1)...len ) {
				b = _colliders[ j ];
				_collisionStats.collisionTests++;

				if ( ( a.collisionLayerMask & b.collisionLayer ) != 0 || ( a.collisionLayer & b.collisionLayerMask ) != 0 ) {
					_collisionStats.collisionMasks++;

					collisionDataA.myCollider = a;
					collisionDataA.otherCollider = b;
					collisionDataA.overlap = detectAndResolveCollision( a, b );

					collisionDataB.myCollider = b;
					collisionDataB.otherCollider = a;
					collisionDataB.overlap = collisionDataA.overlap;

					if ( collisionDataA.overlap != null ) {
						_collisionStats.collisionHits++;
						if ( a.hasCollidingCollider( b ) ) {
							a.onCollisionOngoing( collisionDataA );
							b.onCollisionOngoing( collisionDataB );
						} else {
							a.onCollisionStart( collisionDataA );
							b.onCollisionStart( collisionDataB );

							a.addCollidingCollider( b );
							b.addCollidingCollider( a );
						}
					} else {
						if ( a.hasCollidingCollider( b ) ) {
							a.onCollisionEnd( collisionDataA );
							b.onCollisionEnd( collisionDataB );

							a.removeCollidingCollider( b );
							b.removeCollidingCollider( a );
						}
					}
				}
			}
		}

		collisionDataA.dispose();
		collisionDataB.dispose();
	}

	private function detectAndResolveCollision( a : ColliderComponent, b : ColliderComponent ) : Point {
		var c : ColliderComponent;
		if ( Std.is( a, GridColliderComponent ) ) {
			c = a;
			a = b;
			b = c;
		}

		if ( Std.is( a, BoxColliderComponent ) ) {
			if ( Std.is( b, BoxColliderComponent ) ) {
				return boxToBox( cast( a, BoxColliderComponent ), cast( b, BoxColliderComponent ) );
			} else if ( Std.is( b, GridColliderComponent ) ) {
				return boxToGrid( cast( a, BoxColliderComponent ), cast( b, GridColliderComponent ) );
			}
		}

		return null;
	}

	private function boxToBox( a : BoxColliderComponent, b : BoxColliderComponent ) : Point {
		var _overlap : Point = CollisionSolver.boxBoxOverlap( a, b );
		if ( _overlap.x == 0 || _overlap.y == 0 ) {
			// overlaps only on one axis, no collision!
			return null;
		}

		// push in the smallest direction (if both boxes are solid)
		if ( a.solid && b.solid ) {
			var bca : BodyComponent = cast( a.entity.getComponentByClass( BodyComponent ), BodyComponent);
			var bcb : BodyComponent = cast( b.entity.getComponentByClass( BodyComponent ), BodyComponent);
			if ( !a.fixed && !b.fixed ) {
				if ( Math.abs( _overlap.x ) > Math.abs( _overlap.y ) ) {
					a.entity.transform.position.y -= _overlap.y / 2;
					b.entity.transform.position.y += _overlap.y / 2;
				} else {
					a.entity.transform.position.x -= _overlap.x / 2;
					b.entity.transform.position.x += _overlap.x / 2;
				}
			}
			else if ( a.fixed && !b.fixed ) {
				if ( Math.abs( _overlap.x ) > Math.abs( _overlap.y ) ) {
					b.entity.transform.position.y += _overlap.y;
					if ( bcb != null ) bcb.velocity.y = 0;
				} else {
					b.entity.transform.position.x += _overlap.x;
					if ( bcb != null ) bcb.velocity.x = 0;
				}
			}
			else if ( !a.fixed && b.fixed ) {
				if ( Math.abs( _overlap.x ) > Math.abs( _overlap.y ) ) {
					a.entity.transform.position.y -= _overlap.y;
					if ( bca != null ) bca.velocity.y = 0;
				} else {
					a.entity.transform.position.x -= _overlap.x;
					if ( bca != null ) bca.velocity.x = 0;
				}
			}
			// else both fixed, not much to do
		}
			

		return _overlap;
	}

	private function boxToGrid( a : BoxColliderComponent, b : GridColliderComponent ) : Point {
		var collision : Bool = false;
		var bodyComp : BodyComponent = cast( a.entity.getComponentByClass( BodyComponent ), BodyComponent);
			
		var overlap : Point;

		var nextPosition : Point = a.entity.transform.position.clone();

		var resolveCollision : Bool = a.solid && b.solid;

		if ( resolveCollision ) {
			a.entity.transform.position.x = a.entity.transform.lastPosition.x;
		}

		_overlap.x = _overlap.y = 0;

		// vertical test
		overlap = CollisionSolver.boxGridOverlap( a, b, CollisionSolver.VERTICAL );
		if ( overlap.y != 0 ) {
			collision = true;
			_overlap.y = overlap.y;
			if ( resolveCollision ) {
				a.entity.transform.position.y += overlap.y;
				if ( bodyComp != null ) {
					bodyComp.velocity.y = 0;
				}
			}
		}

		// horizontal test
		a.entity.transform.position.x = nextPosition.x;
		overlap = CollisionSolver.boxGridOverlap( a, b, CollisionSolver.HORIZONTAL );
		if ( overlap.x != 0 ) {
			collision = true;
			_overlap.x = overlap.x;

			if ( resolveCollision ) {
				a.entity.transform.position.x += overlap.x;
				if ( bodyComp != null ) {
					bodyComp.velocity.x = 0;
				}
			}
		}

		if ( collision ) {
			return _overlap;
		}

		return null;
	}
}

