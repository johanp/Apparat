package com.johanpeitz.apparat.physics;

import openfl.geom.Point;
import com.johanpeitz.apparat.components.collision.BoxColliderComponent;
import com.johanpeitz.apparat.components.collision.GridColliderComponent;
import com.johanpeitz.apparat.components.BodyComponent;
import com.johanpeitz.apparat.Apparat;

/**
 * Helper class to solve collisions detected by the collision manager.
 */
class CollisionSolver {

	/**
	 * Constant defining horizontal collision checks.
	 */
	public static inline var HORIZONTAL : Int = 1;
	/**
	 * Constant defining vertical collision checks.
	 */
	public static inline var VERTICAL : Int = 2;

	private static var _pt : Point = new Point();

	/**
	 * Calculates the overlap between a box and a grid collider. If any.
	 * @param	pBox	Box to check.
	 * @param	pGrid	Grid to check.
	 * @param	pAlignment	Specifies whether to check for vertical or horizontal overlap.
	 * @return	Points containing the overlap.  (0,0) if no overlap.
	 */
	public static function boxGridOverlap( pBox : BoxColliderComponent, pGrid : GridColliderComponent, pAlignment : Int ) : Point {

		var cell : Int;

		var tx1 : Int;
		var ty1 : Int;
		var tx2 : Int;
		var ty2 : Int;

		var curPos : Point = Apparat.pointPool.fetch();
		curPos.x = pBox.entity.transform.position.x;
		curPos.y = pBox.entity.transform.position.y;

		var x : Int;
		var y : Int;

		// tile half size
		var ths : Float = pGrid.cellSize / 2;

		var dx : Float;
		var dy : Float;
		var tcx : Float;
		var tcy : Float;
		
		var bodyComp : BodyComponent = cast( pBox.entity.getComponentByClass( BodyComponent ), BodyComponent );
								
		// modify box position to adapt to grid position
		// will be set back to normal later
		pBox.entity.transform.position.x -= pGrid.entity.transform.position.x;
		pBox.entity.transform.position.y -= pGrid.entity.transform.position.y;
		pBox.entity.transform.lastPosition.x -= pGrid.entity.transform.position.x;
		pBox.entity.transform.lastPosition.y -= pGrid.entity.transform.position.y;
		
		// box centre
		var bcx : Float = pBox.entity.transform.position.x + pBox.collisionBox.offsetX;
		var bcy : Float = pBox.entity.transform.position.y + pBox.collisionBox.offsetY;

		// calc which tiles we might intersect with
		tx1 = Math.floor( ( bcx - pBox.collisionBox.halfWidth ) / pGrid.cellSize );
		ty1 = Math.floor( ( bcy - pBox.collisionBox.halfHeight ) / pGrid.cellSize );
		tx2 = Math.ceil( ( bcx + pBox.collisionBox.halfWidth ) / pGrid.cellSize );
		ty2 = Math.ceil( ( bcy + pBox.collisionBox.halfHeight ) / pGrid.cellSize );


		// using _pt as projection
		for ( y in ty1...ty2 ) {
			for ( x in tx1...tx2 ) {
				cell = pGrid.getCell( x, y );
				if ( cell > 0 ) {
					_pt.x = _pt.y = 0;

					// tile center point
					tcx = x * pGrid.cellSize + ths;
					tcy = y * pGrid.cellSize + ths;

					// box center point
					bcx = pBox.entity.transform.position.x + pBox.collisionBox.offsetX;
					bcy = pBox.entity.transform.position.y + pBox.collisionBox.offsetY;

					// distance between center points
					dx = Math.abs( tcx - bcx );
					dy = Math.abs( tcy - bcy );

					// calculate overlap
					if ( dx < ths + pBox.collisionBox.halfWidth ) {
						_pt.x = ths + pBox.collisionBox.halfWidth - dx;
					}
					if ( dy < ths + pBox.collisionBox.halfHeight ) {
						_pt.y = ths + pBox.collisionBox.halfHeight - dy;
					}

					if ( cell == Apparat.SOLID ) { // SOLID
						// inside a solid tile, push out
						if ( _pt.x > 0 && _pt.y > 0 ) {
							if ( pAlignment == CollisionSolver.HORIZONTAL ) {
								if ( tcx < bcx ) {
									pBox.entity.transform.position.x += _pt.x;
								} else {
									pBox.entity.transform.position.x -= _pt.x;
								}
							} else {
								if ( tcy < bcy ) {
									pBox.entity.transform.position.y += _pt.y;
								} else {
									pBox.entity.transform.position.y -= _pt.y;
								}
							}
						}
					} 
					else if ( cell == Apparat.SOLID_TOP ) { // SOLID FROM ABOVE
						if ( _pt.x > 0 && _pt.y > 0 ) {
							if ( pAlignment == CollisionSolver.VERTICAL ) {
								if ( bodyComp != null ) {
									if ( bodyComp.velocity.y >= 0 ) {
										if ( tcy >= bcy ) {
											var lastTY : Int = Math.floor( ( pBox.entity.transform.lastPosition.y + pBox.collisionBox.offsetY + pBox.collisionBox.halfHeight - 1 ) / pGrid.cellSize );
											if ( lastTY < y ) {
												pBox.entity.transform.position.y -= _pt.y;
											}
										}
									}
								}
							}
						}
					}
					else if ( cell == Apparat.SOLID_LEFT ) { // SOLID FROM LEFT
						if ( _pt.x > 0 && _pt.y > 0 ) {
							if ( pAlignment == CollisionSolver.HORIZONTAL ) {
								if ( bodyComp != null ) {
									if ( bodyComp.velocity.x >= 0 ) {
										if ( tcx >= bcx ) {
											var lastTX : Int = Math.floor( ( pBox.entity.transform.lastPosition.x + pBox.collisionBox.offsetX + pBox.collisionBox.halfWidth - 1 ) / pGrid.cellSize );
											if ( lastTX < x ) {
												pBox.entity.transform.position.x -= _pt.x;
											}
										}
									}
								}
							}
						}
					}
					else if ( cell == Apparat.SOLID_BOTTOM ) { // SOLID FROM BELOW
						if ( _pt.x > 0 && _pt.y > 0 ) {
							if ( pAlignment == CollisionSolver.VERTICAL ) {
								if ( bodyComp != null ) {
									if ( bodyComp.velocity.y <= 0 ) {
										if ( tcy <= bcy ) {
											var lastTY : Int = Math.floor( ( pBox.entity.transform.lastPosition.y + pBox.collisionBox.offsetY - pBox.collisionBox.halfHeight + 1 ) / pGrid.cellSize );
											if ( lastTY > y ) {
												pBox.entity.transform.position.y += _pt.y;
											}
										}
									}
								}
							}
						}
					}
					else if ( cell == Apparat.SOLID_RIGHT ) { // SOLID FROM RIGHT
						if ( _pt.x > 0 && _pt.y > 0 ) {
							if ( pAlignment == CollisionSolver.HORIZONTAL ) {
								if ( bodyComp != null ) {
									if ( bodyComp.velocity.x <= 0 ) {
										if ( tcx <= bcx ) {
											var lastTX : Int = Math.floor( ( pBox.entity.transform.lastPosition.x + pBox.collisionBox.offsetX - pBox.collisionBox.halfWidth + 1 ) / pGrid.cellSize );
											if ( lastTX > x ) {
												pBox.entity.transform.position.x += _pt.x;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		// remove adaptation to grid position
		pBox.entity.transform.position.x += pGrid.entity.transform.position.x;
		pBox.entity.transform.position.y += pGrid.entity.transform.position.y;
		pBox.entity.transform.lastPosition.x += pGrid.entity.transform.position.x;
		pBox.entity.transform.lastPosition.y += pGrid.entity.transform.position.y;
			
		// calc collision response
		_pt.x = pBox.entity.transform.position.x - curPos.x;
		_pt.y = pBox.entity.transform.position.y - curPos.y;
		if ( Math.abs( _pt.x ) < 0.00000001 ) {
			_pt.x = 0;
		}
		if ( Math.abs( _pt.y ) < 0.00000001 ) {
			_pt.y = 0;
		}

		// reset box to original position
		pBox.entity.transform.position.x = curPos.x;
		pBox.entity.transform.position.y = curPos.y;

		Apparat.pointPool.recycle( curPos );
		return _pt;

	}

	/**
	 * Calculates the overlap between two box colliders. If any.
	 * @param	a	The first box.
	 * @param	b	The other box.
	 * @return	Point containing overlap. (0,0) if no overlap.
	 */
	public static function boxBoxOverlap( a : BoxColliderComponent, b : BoxColliderComponent ) : Point {
		_pt.x = _pt.y = 0;

		// distance between center points
		var dx : Float = Math.abs( ( a.entity.transform.position.x + a.collisionBox.offsetX ) - ( b.entity.transform.position.x + b.collisionBox.offsetX ) );
		var dy : Float = Math.abs( ( a.entity.transform.position.y + a.collisionBox.offsetY ) - ( b.entity.transform.position.y + b.collisionBox.offsetY ) );

		// calculate overlap
		if ( dx < a.collisionBox.halfWidth + b.collisionBox.halfWidth ) {
			_pt.x = Math.abs( dx - ( a.collisionBox.halfWidth + b.collisionBox.halfWidth ) );
		}
		if ( dy < a.collisionBox.halfHeight + b.collisionBox.halfHeight ) {
			_pt.y = Math.abs( dy - ( a.collisionBox.halfHeight + b.collisionBox.halfHeight ) );
		}

		if ( _pt.x == 0 || _pt.y == 0 ) {
			// no collision (only overlap on one axis)
			_pt.x = _pt.y = 0;
		} else {
			if ( a.entity.transform.position.x + a.collisionBox.offsetX > b.entity.transform.position.x + b.collisionBox.offsetX ) {
				_pt.x = -_pt.x;
			}
			if ( a.entity.transform.position.y + a.collisionBox.offsetY > b.entity.transform.position.y + b.collisionBox.offsetY ) {
				_pt.y = -_pt.y;
			}
		}

		return _pt;
	}
}
