package com.johanpeitz.apparat.components;


import com.johanpeitz.apparat.Apparat;
import openfl.geom.Point;

/**
 * Holds each entites transform data such as position, rotation and scale.
 * Every entity has one of there by default.
 * @author Johan Peitz
 */
class TransformComponent extends Component {
	/**
	 * Local position in relation to the entitie's parent. (The scene, or another entity.(
	 */
	public var position : Point;
	/**
	 * Position on the scene.
	 */
	public var positionOnScene : Point;
	/**
	 * Local position from last frame.
	 */
	public var lastPosition : Point;
	/**
	 * The entity's rotation in radians.
	 */
	public var rotation : Float = 0;
	/**
	 * Rotation on the scene.
	 */
	public var rotationOnScene : Float = 0;
	/**
	 * What offset from offset to rotate the around.
	 */
	public var pivotOffset : Point = null;
	/**
	 * The entity's X scale.
	 */
	public var scaleX : Float = 1;
	/**
	 * The entity's Y scale.
	 */
	public var scaleY : Float = 1;

	/**
	 * X scale on the scene.
	 */
	public var scaleXOnScene : Float = 1;
	/**
	 * Y scale on the scene.
	 */
	public var scaleYOnScene : Float = 1;

	public var scrollFactorX : Float = 1;
	public var scrollFactorY : Float = 1;
	
	
	/**
	 * Constructs a new transform component and sets the postion.
	 * @param	pX	X position.
	 * @param	pY	Y position.
	 */
	public function new( pX : Float = 0, pY : Float = 0 ) {
		super( );
		
		priority = 9999;
		
		positionOnScene = Apparat.pointPool.fetch();
		positionOnScene.x = positionOnScene.y = 0;

		pivotOffset = Apparat.pointPool.fetch();
		pivotOffset.x = pivotOffset.y = 0;

		position = Apparat.pointPool.fetch();
		position.x = pX;
		position.y = pY;

		lastPosition = Apparat.pointPool.fetch();
		lastPosition.x = pX;
		lastPosition.y = pY;
	}

	/**
	 * Clears all resources used by this component.
	 */
	override public function dispose() : Void {
		Apparat.pointPool.recycle( positionOnScene );
		positionOnScene = null;

		Apparat.pointPool.recycle( lastPosition );
		lastPosition = null;

		Apparat.pointPool.recycle( position );
		position = null;

		Apparat.pointPool.recycle( pivotOffset );
		pivotOffset = null;

		super.dispose();
	}

	/**
	 * Sets the postion in the transform.
	 * @param	pX	X position.
	 * @param	pY	Y position.
	 */
	public function setPosition( pX : Float, pY : Float ) : Void {
		position.x = pX;
		position.y = pY;
	}

	/**
	 * Sets the scale for both X and Y.
	 */
	public function setScale( pScale : Float ) : Void {
		scaleX = scaleY = pScale;
	}
	
	override public function update( pDT : Float ) : Void {
		super.update( pDT );
		
		lastPosition.x = position.x;
		lastPosition.y = position.y;
	}

}
