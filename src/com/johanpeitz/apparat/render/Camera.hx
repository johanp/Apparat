package com.johanpeitz.apparat.render;


import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.Entity;

/**
 * The camera decides what part and size of the scene will be rendered.
 * @author Johan Peitz
 */
class Camera {
	public var view : Rectangle;

	private var _bounds : Rectangle;
	private var _lookAt : Point;
	private var _lookOffset : Point;
	private var _targetEntity : Entity;


	/**
	 * Current center of camera.
	 */
	public var center : Point;

	/**
	 * Creates a new camera.
	 * @param	pWidth	Width of view.
	 * @param	pHeight	Height of view.
	 * @param	pOffsetX	Amount to offset the camera along th X axis.
	 * @param	pOffsetY	Amount to offset the camera along th Y axis.
	 */
	public function new( pWidth : Int = 0, pHeight : Int = 0, pOffsetX : Int = 0, pOffsetY : Int = 0 ) {
		if ( pWidth == 0 || pHeight == 0 ) {
			pWidth = Apparat.engine.engineWidth;
			pHeight = Apparat.engine.engineHeight;
		}
		view = new Rectangle( 0, 0, pWidth, pHeight );
		_bounds = null;
		_lookAt = new Point();
		_lookOffset = new Point( pOffsetX, pOffsetY );
		center = new Point();
	}

	/**
	 * Clears all resources used by the camera.
	 */
	public function dispose() : Void {
		view = null;
		_bounds = null;
		_lookAt = null;
		_targetEntity = null;
		center = null;
	}

	/**
	 * Sets the bounding rectangle for the camera. The camera will not be able to move outside the bounds.
	 * @param	pTopLeft	Top left corner of restricting rectangle.
	 * @param	pBottomRight	Bottom right corner of restricting rectangle.
	 */
	public function setBounds( pTopLeft : Point, pBottomRight : Point ) : Void {
		_bounds = new Rectangle( pTopLeft.x, pTopLeft.y, pBottomRight.x - pTopLeft.x, pBottomRight.y - pTopLeft.y );
	}

	/**
	 * Sets the camera to track a certain entity.
	 * @param	pEntity
	 */
	public function track( pEntity : Entity ) : Void {
		_targetEntity = pEntity;
	}

	/**
	 * Invoked regularly by the scene the camera belogns to. Updates camera postion.
	 * @param	pDT
	 */
	public function update( pDT : Float ) : Void {
		if ( _targetEntity != null ) {
			_lookAt.x = Math.round( _targetEntity.transform.position.x );
			_lookAt.y = Math.round( _targetEntity.transform.position.y );
			lookAt( _lookAt );
		}

		center.x = view.x - _lookOffset.x;
		center.y = view.y - _lookOffset.y;
	}

	/**
	 * Sets the camera to look at a specific position.
	 * @param	pPos	Position to look at.
	 */
	public function lookAt( pPos : Point ) : Void {
		view.x = Std.int( pPos.x + _lookOffset.x );
		view.y = Std.int( pPos.y + _lookOffset.y );

		if ( _bounds != null ) {
			if ( view.x < _bounds.x )
				view.x = _bounds.x;
			if ( view.right > _bounds.right )
				view.x = _bounds.right - view.width;

			if ( view.y < _bounds.y )
				view.y = _bounds.y;
			if ( view.bottom > _bounds.bottom )
				view.y = _bounds.bottom - view.height;
		}
	}


}
