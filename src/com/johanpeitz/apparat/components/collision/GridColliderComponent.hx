package com.johanpeitz.apparat.components.collision;

import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.utils.Grid;

/**
 * A collider consiting of a number of cells in a grid. Each cell holds it's own collision data.
 * Useful for tilemap collisions.
 */
class GridColliderComponent extends ColliderComponent {
	private var _grid : Grid = null;
	private var _cellSize : Int = 16;

	private var _height : Int;
	private var _width : Int;

	/**
	 * Constructs a new grid collider.
	 * @param	pWidth	Float of cells across.
	 * @param	pHeight	Float of cells along.
	 * @param	pCellSize	Size of each cell.
	 */
	public function new( pWidth : Int, pHeight : Int, pCellSize : Int ) {
		super( );

		// act as a grid (by default)
		addToCollisionLayer( Apparat.COLLISION_LAYER_GRID );

		_cellSize = pCellSize;
		_width = pWidth;
		_height = pHeight;
		_grid = new Grid( _width, _height );
	}

	/**
	 * Returns the value of a specific cell.
	 * @param	pTX	X position of cell.
	 * @param	pTY	Y position of cell.
	 * @return	Calue of cell at location.
	 */
	public function getCell( pTX : Int, pTY : Int ) : Int {
		return _grid.getCell( pTX, pTY );
	}

	/**
	 * Sets the value of a specific cell.
	 * @param	pTX	X position of cell.
	 * @param	pTY	Y position of cell.
	 */
	public function setCell( pTX : Int, pTY : Int, pTileID : Int ) : Void {
		_grid.setCell( pTX, pTY, pTileID );
	}

	/**
	 * Returns the grid data used for this collider.
	 * @return Grid instance.
	 */
	public var grid( get_grid, null ) : Grid;
	private function get_grid() : Grid {
		return _grid;
	}

	/**
	 * Returns the size of each cell.
	 * @return Cell size.
	 */
	public var cellSize( get_cellSize, null ) : Int;
	private function get_cellSize() : Int {
		return _cellSize;
	}

	/**
	 * Returns the height of the grid in cells.
	 * @return Height in cells.
	 */
	public var height( get_height, null ) : Int;
	private function get_height() : Int {
		return _height;
	}

	/**
	 * Returns the width of the grid in cells.
	 * @return Width in cells.
	 */
	public var width( get_width, null ) : Int;
	private function get_width() : Int {
		return _width;
	}

}
