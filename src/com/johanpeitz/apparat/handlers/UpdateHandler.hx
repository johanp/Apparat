package com.johanpeitz.apparat.handlers;


import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.Scene;
import com.johanpeitz.apparat.utils.MathUtil;
import com.johanpeitz.apparat.utils.UpdateStats;

/**
 * The update handler updates all entities in a scene.
 * @author Johan Peitz
 */
class UpdateHandler extends Handler {
	private var _updateStats : UpdateStats;

	/**
	 * Creates a new update handler.
	 * @param	pScene	Scene on which to operate.
	 * @param	pPriority	When to be invoked in relation to other sytems.
	 */
	public function new( pScene : Scene, pPriority : Int = 0 ) {
		super( pScene, pPriority );
		_stats = _updateStats = new UpdateStats();
	}

	/**
	 * Resets update sats. Invoked automatically.
	 */
	override public function beforeUpdate() : Void {
		_updateStats.reset();
	}

	/**
	 * Updates all entities.
	 * @param	pDT	Time passed.
	 */
	override public function update( pDT : Float ) : Void {
		updateEntityTree( scene.entityRoot, pDT );
	}

	private function updateEntityTree( pEntity : Entity, pDT : Float ) : Void {
		_updateStats.entitiesUpdated++;

		pEntity.update( pDT );

		for ( e in pEntity.entities ) {
			e.transform.rotationOnScene = pEntity.transform.rotationOnScene + e.transform.rotation;

			e.transform.scaleXOnScene = pEntity.transform.scaleXOnScene * e.transform.scaleX;
			e.transform.scaleYOnScene = pEntity.transform.scaleYOnScene * e.transform.scaleY;

			e.transform.positionOnScene.x = pEntity.transform.positionOnScene.x;
			e.transform.positionOnScene.y = pEntity.transform.positionOnScene.y;

			if ( e.transform.rotationOnScene == 0 ) {
				e.transform.positionOnScene.x += e.transform.position.x * pEntity.transform.scaleXOnScene;
				e.transform.positionOnScene.y += e.transform.position.y * pEntity.transform.scaleXOnScene;
			} else {
				var d : Float = Math.sqrt( e.transform.position.x * e.transform.position.x + e.transform.position.y * e.transform.position.y );
				var a : Float = Math.atan2( e.transform.position.y, e.transform.position.x ) + pEntity.transform.rotationOnScene;
				e.transform.positionOnScene.x += d * Math.cos( a ) * pEntity.transform.scaleXOnScene;
				e.transform.positionOnScene.y += d * Math.sin( a ) * pEntity.transform.scaleYOnScene;
			}

			updateEntityTree( e, pDT );
		}

		if ( pEntity.removeNow ) {
			pEntity.parent.removeEntity( pEntity );
		}
	}

}
