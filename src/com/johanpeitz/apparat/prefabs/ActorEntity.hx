package com.johanpeitz.apparat.prefabs;

import com.johanpeitz.apparat.components.collision.BoxColliderComponent;
import com.johanpeitz.apparat.components.BodyComponent;
import com.johanpeitz.apparat.components.render.AnimationComponent;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.render.Atlas;

/**
 * Pre populated entity with the usual components.
 * @author Johan Peitz
 */
class ActorEntity extends Entity {
	/**
	 * Render component makes sure something will be seen.
	 */
	public var renderComp : RenderComponent;
	/**
	 * Animation component animates the render component.
	 */
	public var animComp : AnimationComponent;
	/**
	 * Collider component handles all collision.
	 */
	public var boxColliderComp : BoxColliderComponent;
	/**
	 * Body component enables velocities and gravity.
	 */
	public var bodyComp : BodyComponent;

	/**
	 * Constrcuts a new actor entity.
	 */
	public function new( pAtlas : Atlas ) {
		super();
		renderComp = cast( addComponent( new RenderComponent( pAtlas ) ), RenderComponent );
		animComp = cast( addComponent( new AnimationComponent() ), AnimationComponent);
		boxColliderComp = cast( addComponent( new BoxColliderComponent( 16, 16 ) ), BoxColliderComponent);
		bodyComp = cast( addComponent( new BodyComponent() ), BodyComponent);
	}

	/**
	 * Clears all resources used by actor.
	 */
	override public function dispose() : Void {
		renderComp = null;
		animComp = null;
		boxColliderComp = null;
		bodyComp = null;

		super.dispose();
	}

}

