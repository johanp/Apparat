package com.johanpeitz.apparat.prefabs.gui;

import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.Entity;
import com.johanpeitz.apparat.render.BitmapFont;
import com.johanpeitz.apparat.utils.Log;
import com.johanpeitz.apparat.utils.Repository;
import openfl.geom.Point;

/**
 * An entity containing a text field component only.
 * Useful for quickly displaying text.
 * @author Johan Peitz
 */
class TextEntity extends Entity {

	private var _font : BitmapFont;

	private var _glyphEntity : Entity;
	private var _textColor : Int;
	
	private var _textWidth : Int;
	private var _textHeight : Int;
	
	private var _text : String;
	
	private var _alignment : Int;
	private var _fieldWidth : Int;
	private var _multiLine : Bool;

	private var _alpha : Float;
	
	/**
	 * Creates a new entity with a text field component.
	 * @param	pText	Initial text to show.
	 * @param	pColor	Color of text.
	 */
	public function new( pText : String, pFont : BitmapFont, pColor : Int = 0xFFFFFF ) {
		super( );

		_text = pText;
		_textColor = pColor;
		_font = pFont;
		_alpha = 1;
		_fieldWidth = 1;
		_multiLine = false;

		
		_glyphEntity = addEntity( new Entity() );
		
		updateTextComponents();
	}
	
	/**
	 * Clears all resources used by entity.
	 */
	override public function dispose() : Void {
		_font = null;
		super.dispose();
		_glyphEntity = null;
	}

	
	/**
	 * Sets which text to display.
	 * @param pText	Text to display.
	 */
	public var text( null, set_text ) : String;
	public function set_text( pText : String ) : String {
		_text = pText;
		updateTextComponents();
		return _text;
	}

	

	/**
	 * Sets the color of the text.
	 * @param pColor	color to set, 0x000000 - 0xFFFFFF
	 */
	public var color( null, set_color ) : Int;
	public function set_color( pColor : Int ) : Int {
		_textColor = pColor;
		updateTextComponents();
		
		return _textColor;
	}
	
	/**
	 * Sets the alpha level of the text.
	 * @param value	alpha level to set (0-1)
	 */
	public var alpha( get_alpha, set_alpha ) : Float;
	public function set_alpha( value : Float ) : Float {
		_alpha = value;
		updateTextComponents();
		
		return _alpha;
	}
	public function get_alpha( ) : Float {
		return _alpha;
	}
	

	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	public var width( null, set_width) : Int;
	public function set_width( pWidth : Int ) : Int {
		_fieldWidth = pWidth;
		if ( _fieldWidth < 1 ) {
			_fieldWidth = 1;
		}
		updateTextComponents();

		return _fieldWidth;
	}

	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	public var alignment( null, set_alignment) : Int;
	public function set_alignment( pAlignment : Int ) : Int {
		_alignment = pAlignment;
		updateTextComponents();
		return _alignment;
	}

	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	public var multiLine( null, set_multiLine) : Bool;
	public function set_multiLine( pMultiLine : Bool ) : Bool {
		_multiLine = pMultiLine;
		updateTextComponents();
		return _multiLine;
	}
	
	/**
	 * Returns the width of the text entity in pixels.
	 * @return	width of text
	 */
	public function getWidth() : Int {
		return _textWidth;
	}

	/**
	 * Returns the height of the text entity in pixels.
	 * @return	height of text
	 */
	public function getHeight() : Int {
		return _textHeight;
	}

	
	private function updateTextComponents( ) : Void {
		_text = _text.split( "\\n" ).join( "\n" );

		// remove any old components
		removeEntity( _glyphEntity );
		_glyphEntity = addEntity( new Entity() );
		
		_textWidth = 0;
		_textHeight = 0;
		
		// cut text into pices
		var calcFieldWidth : Int = _fieldWidth;
		var rows : Array<String> = [];
		var fontHeight : Int = _font.fontHeight;
		var lineComplete : Bool;

		// get words
		var lines : Array<String> = _text.split( "\n" );
		var i : Int = -1;
		while ( ++i < lines.length ) {
			lineComplete = false;
			var words : Array<String> = lines[ i ].split( " " );
			if ( words.length > 0 ) {
				var wordPos : Int = 0;
				var txt : String = "";
				while ( !lineComplete ) {
					var changed : Bool = false;

					var currentRow : String = txt + words[ wordPos ] + " ";

					if ( _multiLine ) {
						if ( _font.getTextWidth( currentRow ) > _fieldWidth ) {
							rows.push( txt.substring( 0, txt.length - 1 ) );
							txt = "";
							changed = true;
						}
					}

					txt += words[ wordPos ] + " ";
					wordPos ++;

					if ( wordPos >= words.length ) {
						var subText : String = txt.substring( 0, txt.length - 1 );
						calcFieldWidth = Std.int( Math.max( calcFieldWidth, _font.getTextWidth( subText) ) );
						rows.push( subText );
						lineComplete = true;
					}
				}
			}
		}

		
		
		var p : Point = Apparat.pointPool.fetch();
		var pt : Point = Apparat.pointPool.fetch();
		
		// render text
		var row : Int = 0;
		for ( t in rows ) {
			var ox : Int = 0; // LEFT
			var oy : Int = 0;
			if ( _alignment == Apparat.CENTER ) {
				ox = Std.int( ( _fieldWidth - _font.getTextWidth( t ) / 2 ) - _fieldWidth / 2 );
			}
			if ( _alignment == Apparat.RIGHT ) {
				ox = Std.int( _fieldWidth - _font.getTextWidth( t ) );
			}
			
			// add new components
			p.x = ox;
			p.y = oy + row * fontHeight;
			for ( i in 0 ... t.length ) {
				var tileID : Int = _font.getTileID( t.charAt( i ) );
				if ( tileID != -1 ) {
					pt.x = p.x + _font.tileWidth( tileID ) / 2;
					pt.y = p.y + _font.tileHeight( tileID ) / 2;
					
					_glyphEntity.addComponent( new RenderComponent( _font, tileID, pt ) );
					
					p.x += _font.charKerning( tileID ).width - _font.charKerning( tileID ).x;
					if ( p.x > _textWidth ) {
						_textWidth = Std.int( p.x );
					}
				
				}
				else {
					Log.log( "no glyph for letter '" + _text.charAt( i ) + "'", this, Log.WARNING );
				}
			}
			row++;
		}
		
		Apparat.pointPool.recycle( p );
		Apparat.pointPool.recycle( pt );
		
		_textHeight = _font.fontHeight * row;
		
		// set color
		for ( g in _glyphEntity.getComponentsByClass( RenderComponent ) ) {
			cast( g, RenderComponent ).setColor( _textColor );
			cast( g, RenderComponent ).alpha = _alpha;
		}
		
	}
	
}
