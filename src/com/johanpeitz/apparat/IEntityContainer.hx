package com.johanpeitz.apparat;

import com.johanpeitz.apparat.Entity;

/**
 * This interface is used to define objects that can be used to contain entities.
 * @author Johan Peitz
 */
interface IEntityContainer {
	/**
	 * Removes an entity from the container.
	 * @param	pEntity	Entity to remove.
	 * @return	Removed entity.
	 */
	function removeEntity( pEntity : Entity ) : Entity;

	/**
	 * Adds an entity to the container.
	 * @param	pEntity	Entity to add.
	 * @param	pHandle	String identifier of this entity.
	 * @return	Added entity.
	 */
	function addEntity( pEntity : Entity, pHandle : String = "" ) : Entity;
}

