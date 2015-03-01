package com.johanpeitz.apparat.render;

import com.johanpeitz.apparat.components.TransformComponent;
import com.johanpeitz.apparat.render.RenderHandler;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.Lib;
import com.johanpeitz.apparat.components.Component;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.handlers.Handler;
import com.johanpeitz.apparat.utils.MathUtil;
import com.johanpeitz.apparat.utils.RenderStats;
import openfl.utils.Dictionary;

/**
 * Rendering handler that uses blitting to position bitmap data onto a destination bitmap.
 * @author Johan Peitz
 */
class HWRenderHandler extends RenderHandler {
	private var _surface : Sprite;

	private var _view : Rectangle;

	private var _matrix : Matrix;

	private var _bufferTopLeft_ : Point;
	private var _globalTopLeft_ : Point;


	private var _tileOrderPerAtlas : Map< Atlas, Array< RenderComponent > >;
	private var _atlasOrder : Array< Atlas >;

	/**
	 * Creates a new blit rendering handler.
	 * @param	pScene	Scene to which the handler belongs.
	 * @param	pPriority	Priority towards other handlers.
	 */
	public function new( pScene : Scene, pPriority : Int = 0 ) {
		super( pScene, pPriority );

		_surface = new Sprite();
		_surface.scaleX = _surface.scaleY = Apparat.engine.engineScale;
		
		_matrix = Apparat.matrixPool.fetch();
		_bufferTopLeft_ = Apparat.pointPool.fetch();
		_globalTopLeft_ = Apparat.pointPool.fetch();


		_view = new Rectangle();
	}

	/**
	 * Clears all used resources.
	 */
	override public function dispose() : Void {
		if ( _surface.parent != null ) {
			_surface.parent.removeChild( _surface );
		}
		_surface = null;
		_view = null;

		Apparat.matrixPool.recycle( _matrix );
		_matrix = null;

		Apparat.pointPool.recycle( _bufferTopLeft_ );
		Apparat.pointPool.recycle( _globalTopLeft_ );
		_bufferTopLeft_ = null;
		_globalTopLeft_ = null;



		super.dispose();
	}

	/**
	 * Invoked before rendering starts. Clears stats and locks bitmap.
	 */
	override public function beforeRender() : Void {
		super.beforeRender();
	}



	/**
	 * Invoked before when rendering is completed.
	 */
	override public function afterRender() : Void {
		super.afterRender();
	}
	
	
	/**
	 * Renders a scene. The renderer will go through the entity tree in order and render
	 * any BitmapDataComponents found.
	 * @param	pScene	Scene to render.
	 */
	override public function render() : Void {
		_surface.graphics.clear();

		if ( scene.camera != null ) {
			_view.width = scene.camera.view.width;
			_view.height = scene.camera.view.height;

			_tileOrderPerAtlas = new Map< Atlas, Array<RenderComponent> >();
			_atlasOrder = new Array< Atlas >();
			
			prepareComponents( scene.entityRoot, scene, scene.entityRoot.transform.position, scene.entityRoot.transform.rotation, scene.entityRoot.transform.scaleX, scene.entityRoot.transform.scaleY, 1, 1 );

			var a : Int = 0;
			// trace( "-- render -----------------" );
			for ( atlas in _atlasOrder ) {
				var tileData : Array<Float> = new Array<Float>();
				for ( bdc in _tileOrderPerAtlas.get( atlas ) ) {	
					for ( i in 0 ... 11 ) {
						tileData.push( bdc.drawData[ i ] );
					}
				}
				
				atlas.draw( _surface.graphics, tileData );
				_renderStats.drawCalls ++;
				// trace( atlas.name );
			}
		}
	}

	
	
	private function prepareComponents( pEntity : Entity, pScene : Scene, pPosition : Point, pRotation : Float, pScaleX : Float, pScaleY : Float, pScrollFactorX : Float, pScrollFactorY : Float ) : Void {
		for ( e in pEntity.entities ) {
			var pos : Point = Apparat.pointPool.fetch();
			// adjust to scroll factor
			_view.x = pScene.camera.view.x * e.transform.scrollFactorX * pScrollFactorX;
			_view.y = pScene.camera.view.y * e.transform.scrollFactorY * pScrollFactorY;

			if ( pRotation != 0 ) {
				var d : Float = Math.sqrt( e.transform.position.x * e.transform.position.x + e.transform.position.y * e.transform.position.y );
				var a : Float = Math.atan2( e.transform.position.y, e.transform.position.x ) + pRotation;
				pos.x = pPosition.x + d * Math.cos( a ) * pScaleX;
				pos.y = pPosition.y + d * Math.sin( a ) * pScaleY;
			} else {
				pos.x = pPosition.x + e.transform.position.x * pScaleX;
				pos.y = pPosition.y + e.transform.position.y * pScaleY;
			}
		
			var renderableComponents : Array<Component> = e.getComponentsByClass( RenderComponent );
			var brc : RenderComponent;
			for ( renderableComponent in renderableComponents ) {
				brc = cast( renderableComponent, RenderComponent);
				if ( brc.visible ) {
					prepareComponent( brc, _view, pos, pRotation + e.transform.rotation, pScaleX * e.transform.scaleX, pScaleY * e.transform.scaleY );
				}
			}
			
			prepareComponents( e, pScene, pos, pRotation + e.transform.rotation, pScaleX * e.transform.scaleX, pScaleY * e.transform.scaleY, e.transform.scrollFactorX * pScrollFactorX, e.transform.scrollFactorY * pScrollFactorY );
			Apparat.pointPool.recycle( pos );
		}
	}
	
	

	private function prepareComponent( pRendComp : RenderComponent, pView : Rectangle, pPosition : Point, pRotation : Float, pScaleX : Float, pScaleY : Float ) : Void {
		_renderStats.totalObjects++;
				
		_globalTopLeft_.x = Math.round( pPosition.x ) - ( pRendComp.tileCenter.x );
		_globalTopLeft_.y = Math.round( pPosition.y ) - ( pRendComp.tileCenter.y );

		_bufferTopLeft_.x = _globalTopLeft_.x - pView.x;
		_bufferTopLeft_.y = _globalTopLeft_.y - pView.y;

		_matrix.identity();

		_matrix.scale( pScaleX, pScaleY );
		_matrix.rotate( pRotation );
		
		if ( pRotation != 0 || pScaleX != 1 || pScaleY != 1 ) {
			var p1 : Point = new Point( pRendComp.entity.transform.pivotOffset.x + pRendComp.tileCenter.x, pRendComp.entity.transform.pivotOffset.y + pRendComp.tileCenter.y); 
			var p2 : Point = _matrix.transformPoint( p1 );
			_bufferTopLeft_.x -= p2.x - pRendComp.entity.transform.pivotOffset.x;
			_bufferTopLeft_.y -= p2.y - pRendComp.entity.transform.pivotOffset.y;
		}
		else {
			_bufferTopLeft_.x -= pRendComp.tileCenter.x;
			_bufferTopLeft_.y -= pRendComp.tileCenter.y;
		}
		
		_matrix.translate( 	_bufferTopLeft_.x + pRendComp.tileCenter.x + pRendComp.offset.x, 
							_bufferTopLeft_.y + pRendComp.tileCenter.y + pRendComp.offset.y );
		
		pRendComp.drawData[ 0 ] = _matrix.tx;
		pRendComp.drawData[ 1 ] = _matrix.ty;
		pRendComp.drawData[ 2 ] = pRendComp.tileID;
		pRendComp.drawData[ 3 ] = _matrix.a;
		pRendComp.drawData[ 4 ] = _matrix.b;
		pRendComp.drawData[ 5 ] = _matrix.c;
		pRendComp.drawData[ 6 ] = _matrix.d;
		pRendComp.drawData[ 7 ] = pRendComp.r;
		pRendComp.drawData[ 8 ] = pRendComp.g;
		pRendComp.drawData[ 9 ] = pRendComp.b;
		pRendComp.drawData[ 10 ] = pRendComp.alpha;
		
		var array : Array< RenderComponent > = _tileOrderPerAtlas.get( pRendComp.atlas );
		if ( array == null ) {
			array = new Array< RenderComponent >();
			_tileOrderPerAtlas.set( pRendComp.atlas, array ); 
			_atlasOrder.push( pRendComp.atlas );
		}
		_tileOrderPerAtlas.get( pRendComp.atlas ).push( pRendComp );
		
		_renderStats.renderedObjects++;
	}
	


	/**
	 * Returns the display object for this renderer.
	 * @return Display object for this renderer.
	 */
	override public function getDisplayObject() : DisplayObject {
		return _surface;
	}

	

}

