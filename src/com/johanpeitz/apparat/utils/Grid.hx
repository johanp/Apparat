package com.johanpeitz.apparat.utils;

/**
 * Representation of a 2D grid. Each grid can hold any Int value.
 */
class Grid {
	private var _grid : Array<Int>;
	private var _gridWidth : Int;
	private var _gridHeight : Int;

	/**
	 * Creates a new grid.
	 * @param	pWidth	Width of grid.
	 * @param	pHeight	Height of grid.
	 * @param	pDefaultValue	Default value for each cell to hold.
	 */
	public function new( pWidth : Int, pHeight : Int, pDefaultValue : Int = 0 ) : Void {

		_gridWidth = pWidth;
		_gridHeight = pHeight;

		_grid = new Array<Int>();

		for ( i in 0...( _gridWidth * _gridHeight ) ) {
			_grid.push( pDefaultValue );
		}
	}

	/**
	 * Clears all resources used by this grid.
	 */
	public function dispose() : Void {
		_grid = null;
	}

	/**
	 * Sets the value of a cell.
	 * @param	pX	X position of cell.
	 * @param	pY	Y position of cell.
	 * @param	pCellID	value of cell.
	 */
	public function setCell( pX : Int, pY : Int, pCellID : Int ) : Void {
		_grid[ pX + pY * _gridWidth ] = pCellID;
	}

	/**
	 * Returns the value of a cell.
	 * @param	pX	X position of cell.
	 * @param	pY	Y position of cell.
	 * @return	Value of cell at X,Y location.
	 */
	public function getCell( pX : Int, pY : Int ) : Int {
		if ( pX < 0 || pX >= _gridWidth || pY < 0 || pY >= _gridHeight ) {
			return 0;
		}
		return _grid[ pX + pY * _gridWidth ];
	}

	/**
	 * Returns width of grid.
	 * @return Width of grid.
	 */
	public var gridWidth( get_gridWidth, null ) : Int;
	public function get_gridWidth() : Int {
		return _gridWidth;
	}

	/**
	 * Returns height of grid.
	 * @return Height of grid.
	 */
	public var gridHeight( get_gridHeight, null ) : Int;
	public function get_gridHeight() : Int {
		return _gridHeight;
	}

	/**
	 * Populates the grid using a bit string. ("1101010010101...").
	 * Very convenient to use together with for instance the OGMO editor.
	 * If the string is bigger than the grid size, it is likely to crash.
	 * @param	pBitString	Source string to use for population.
	 * @param	pValue	Value to store for each "1".
	 * @param	pZerosOverwriteValues	Specifies whether a "0" should overwrite a previous value in the grid or not.
	 */
	public function populateFromBitString( pBitString : String, pValue : Int = 1, pZerosOverwriteValues : Bool = true ) : Void {
		var tx : Int = 0;
		var ty : Int = 0;
		for ( i in 0...pBitString.length ) {
			var c : String = pBitString.substr( i, 1 );
			if ( c == "1" || c == "0" ) {
				if ( c == "1" ) {
					setCell( tx, ty, pValue );
				} else if ( c == "0" && pZerosOverwriteValues ) {
					setCell( tx, ty, 0 );
				}
				tx++;
			}
		}
	}
	
	public function populateFromString( pString : String ) : Void {
		var tx : Int = 0;
		var ty : Int = 0;
		for ( i in 0...pString.length ) {
			var c : String = pString.substr( i, 1 );
			setCell( tx, ty, Std.parseInt( c ) );
			tx++;
		}
	}
	
	
	/**
	 * Sets all cells in the grid to a specific value.
	 * @param	pValue Value for each cell.
	 */
	public function fill(pValue : Int ) {
		for ( i in 0...( _gridWidth * _gridHeight ) ) {
			_grid[ i ] = pValue;
		}
		
	}
	
	public function clone() : Grid
	{
		var newGrid : Grid = new Grid( _gridWidth, _gridHeight );
		
		for ( ty in 0 ... _gridHeight ) {
			for ( tx in 0 ... _gridWidth ) {
				newGrid.setCell( tx, ty, getCell( tx, ty ) );
			}
		}
		
		return newGrid;
	}

}
