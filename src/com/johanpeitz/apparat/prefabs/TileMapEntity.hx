package com.johanpeitz.apparat.prefabs;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.Apparat;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.render.Atlas;
import com.johanpeitz.apparat.utils.Grid;
import com.johanpeitz.apparat.utils.MathUtil;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Johan Peitz
 */

class TileMapEntity extends Entity
{
	private var _grid : Grid;
	private var _numTiles : Int = 0;
	
	private var _mapWidth : Int;
	private var _mapHeight : Int;

	private var _tileWidth : Int;
	private var _tileHeight : Int;

	private var	_tiles : Array<RenderComponent>;
	

	/**
	 * Creates a new entity with tilemap functionality.
	 * 
	 * @param	pMapWidth 	width of map in tiles
	 * @param	pMapHeight 	height of map in tiles
	 * @param	pTileWidth 	width of each tile in pixels
	 * @param	pTileHeight 	height of each tile in pixels
	 * @param	pAtlas	atlas to pull tiles from
	 */
	public function new( pMapWidth : Int, pMapHeight : Int, pTileWidth : Int, pTileHeight : Int,  pAtlas : Atlas ) {
		super( );
		
		_mapWidth  = pMapWidth;
		_mapHeight = pMapHeight;
		
		_tileWidth  = pTileWidth;
		_tileHeight = pTileHeight;

		_grid = new Grid( _mapWidth, _mapHeight, -1 );
		
		transform.position.x = pAtlas.tileWidth( )  / 2;
		transform.position.y = pAtlas.tileHeight( ) / 2;
		
		

		// set up bitmap data components
		_tiles = new Array<RenderComponent>( );
		for ( i in 0 ... ( _mapWidth * _mapHeight ) ) {
			var b : RenderComponent = new RenderComponent( pAtlas );
			b.offset.x = _tileWidth * ( i % _mapWidth );
			b.offset.y = _tileHeight * Std.int( i / _mapWidth );
			b.visible = false;
			_tiles.push( b );
			addComponent( b );
		}		
		
	}
	
	/**
	 * Disposes all resources used by the entity. 
	 */
	override public function dispose() : Void {
		_grid.dispose();
		_grid = null;
		_tiles = null;

		super.dispose();
	}
	
	
	/**
	 * Gets the tile ID at a specific point in the tile map.
	 * 
	 * @param	pTX column in tile space
	 * @param	pTY row in tile space
	 * @return tile id for tile at pTX, pTY
	 */
	public function getTile( pTX : Int, pTY : Int ) : Int {
		return _grid.getCell( pTX, pTY );
	}
	
	/**
	 * Gets the render component for a specific tile.
	 * 
	 * @param	pTX column in tile space
	 * @param	pTY	row in tile space
	 * @return	render component at pTX,pTY
	 */
	public function getRenderComponent( pTX : Int, pTY : Int ) : RenderComponent {
		var pos : Int = pTX + pTY * _grid.gridWidth;
		return _tiles[ pos ];
	}

	/**
	 * Sets a tile on the map to use a specific frame from the sprite sheet.
	 * @param	pTX	X position of tile.
	 * @param	pTY	Y position of tile.
	 * @param	pTileID	Frame to use.
	 */
	public function setTile( pTX : Int, pTY : Int, pTileID : Int ) : Void {
		// update model
		var prevTileID : Int = _grid.getCell( pTX, pTY );
		_grid.setCell( pTX, pTY, pTileID );

		if ( prevTileID > 0 ) {
			_numTiles += ( pTileID == 0 ? -1 : 0 );
		} else {
			_numTiles += ( pTileID == 0 ? 0 : 1 );
		}
		
		// update view
		var pos : Int = pTX + pTY * _grid.gridWidth;
		if ( pTileID == 0 ) {
			_tiles[ pos ].visible = false;
		}
		else {
			_tiles[ pos ].tileID = pTileID;
			_tiles[ pos ].visible = true;
		}
		
	}	
	
	/**
	 * Returns width of map in tiles.
	 */
	public var mapWidth( get_mapWidth, null ) : Int;
	private function get_mapWidth() : Int {
		return _mapWidth;
	}

	/**
	 * Returns height of map in tiles.
	 */
	public var mapHeight( get_mapHeight, null ) : Int;
	private function get_mapHeight() : Int {
		return _mapHeight;
	}

	/**
	 * Returns number of tiles in the map.
	 * @return Amount of tiles in map.
	 */
	public var numTiles( get_numTiles, null ) : Int;
	public function get_numTiles() : Int {
		return _numTiles;
	}
	
	
	/**
	 * Populates the map from XML. XML should look like this.
	 * <data>
	 * 		<tile x="12" y="23" id="2" />
	 * </data>
	 *
	 * @param	pXML XML to use.
	 */
	public function populateFromXML(pXML:Xml):Void 
	{
		for (node in pXML.elementsNamed("tile")) 
		{
			setTile(Std.parseInt(node.get("x")), Std.parseInt(node.get("y")), Std.parseInt(node.get("id")));
		}
	}	
	
	
	
}


