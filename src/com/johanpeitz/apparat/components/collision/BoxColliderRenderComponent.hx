package com.johanpeitz.apparat.components.collision;

import openfl.display.BitmapData;
import com.johanpeitz.apparat.components.collision.BoxColliderComponent;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.utils.Log;

/**
 * Renders a box collider. Add this component to an entity to have it's box collider render automatically.
 * @author Johan Peitz
 */
class BoxColliderRenderComponent extends RenderComponent
{
	private var _boxColliderComp : BoxColliderComponent = null;

	/**
	 * Constructs a new BoxColliderRenderComponent.
	 */
	public function new( ) : Void {
		super( );
		alpha = 0.25;
	}

	/**
	 * Disposes all resources used by component.
	 */
	override public function dispose() : Void {
		_boxColliderComp = null;
		super.dispose();
	}

	/**
	 * Updates the component.
	 * @param	pDT	Time step in seconds.
	 */
	override public function update( pDT : Float ) : Void {
		// get collider info
		if ( _boxColliderComp == null ) {
			_boxColliderComp = cast( entity.getComponentByClass( BoxColliderComponent ), BoxColliderComponent );
		}

		// use collider info
		if ( _boxColliderComp != null ) {
			if ( bitmapData != null ) {
				bitmapData.dispose();
			}
			bitmapData = new BitmapData( Std.int( _boxColliderComp.collisionBox.halfWidth * 2 ), Std.int( _boxColliderComp.collisionBox.halfHeight * 2 ), false, 0xFF00FF );
			setOffset( Std.int( _boxColliderComp.collisionBox.halfWidth - _boxColliderComp.collisionBox.offsetX ), Std.int( _boxColliderComp.collisionBox.halfHeight - _boxColliderComp.collisionBox.offsetY ) );
		}

		// keep calm and carry on
		super.update( pDT );
	}

}

