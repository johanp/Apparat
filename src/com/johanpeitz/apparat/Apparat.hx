package com.johanpeitz.apparat;

import com.johanpeitz.apparat.render.Atlas;
import com.johanpeitz.apparat.render.BitmapFont;
import com.johanpeitz.apparat.render.HWRenderHandler;
import com.johanpeitz.apparat.render.RenderHandler;
import com.johanpeitz.apparat.utils.ImageUtil;
import com.johanpeitz.apparat.utils.Repository;

import openfl.display.StageScaleMode;
import openfl.display.Stage;
import openfl.display.StageQuality;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.system.System;
import openfl.Assets;

#if flash
import flash.net.LocalConnection;
#end

import com.johanpeitz.apparat.utils.Log;
import com.johanpeitz.apparat.utils.ObjectPool;

/**
 * Omnipotent class that can be used to take various short cuts. Also holds various useful things.
 */
class Apparat {
	public static inline var MAJOR_VERSION : Int = 0;
	public static inline var MINOR_VERSION : Int = 6;
	public static inline var INTERNAL_VERSION : Int = 0;

	public static inline var COLOR_RED : Int = 0xFF5D5D;
	public static inline var COLOR_GREEN : Int = 0x5DFC5D;
	public static inline var COLOR_BLUE : Int = 0x5CBCFC;
	public static inline var COLOR_YELLOW : Int = 0xFFFC5C;
	public static inline var COLOR_WHITE : Int = 0xFFFFFF;
	public static inline var COLOR_BLACK : Int = 0x000000;
	public static inline var COLOR_LIGHT_GRAY : Int = 0xE6E6E6;
	public static inline var COLOR_GRAY : Int = 0xAAAAAA;
	public static inline var COLOR_DARK_GRAY : Int = 0x808080;
	public static inline var COLOR_MAGIC_PINK : Int = 0xFF00FF;

	public static inline var FONT_DEFAULT : String = "_apparat-font-default";
	public static inline var BOX_16X16_WHITE : String = "_box-16x16-white";

	public static inline var LEFT : Int = 1;
	public static inline var RIGHT : Int = 2;
	public static inline var CENTER : Int = 3;

	
	static public inline var SOLID_TOP : Int = 1;
	static public inline var SOLID_LEFT : Int = 2;
	static public inline var SOLID_BOTTOM : Int = 4;
	static public inline var SOLID_RIGHT : Int = 8;
	static public inline var SOLID : Int = 15;

	static public inline var COLLISION_LAYER_GRID : Int = 0;

	/**
	 * Object pool for points.
	 * Fetch and recycle Points here for added performance.
	 */
	public static var matrixPool : ObjectPool;
	public static var pointPool : ObjectPool;
	public static var ZERO_POINT : Point;

	/**
	 * Reference to the engine.
	 */
	public static var engine : Engine;
	/**
	 * Reference to the stage.
	 */
	public static var stage : Stage;

	/**
	 * Global volume. 0-1.
	 */
	static public var globalVolume : Float = 1;

	private static var _isInitialized : Bool = false;

	private static var _renderHandlerClass : Class<RenderHandler> = HWRenderHandler;


	/**
	 * Initializes Apparat. Is done automatically when inheriting Engine.
	 *
	 * @param	pEngine	Engine which initializes Apparat.
	 * @param	pStage	Reference to Flash's stage.
	 */
	static public function onEngineAddedToStage( pEngine : Engine, pStage : Stage ) : Void {
		if ( _isInitialized ) {
			Log.log( "Apparat already initialized.", "[o Apparat]", Log.WARNING );
			return;
		}
		Log.log( "", "[o Apparat]", Log.INFO );
		Log.log( "*** APPARAT v " + MAJOR_VERSION + "." + MINOR_VERSION + "." + INTERNAL_VERSION + " ***", "[o Apparat]", Log.INFO );
		Log.log( "", "[o Apparat]", Log.INFO );

		engine = pEngine;
		stage = pStage;

		matrixPool = new ObjectPool( Matrix );
		pointPool = new ObjectPool( Point );
		ZERO_POINT = pointPool.fetch();
		ZERO_POINT.x = ZERO_POINT.y = 0;
		
		// create fonts
		var font : BitmapFont = BitmapFont.createBitmapFont( Assets.getBitmapData("apparat-assets/font-default.png"), Assets.getText("apparat-assets/font-default.json") );
		Repository.store( FONT_DEFAULT, font );
		
		// create overall assets
		Repository.store( "_apparat-logo-atlas", new Atlas( Assets.getBitmapData( "apparat-assets/apparat-logo.png" ) ) );
		Repository.store( BOX_16X16_WHITE, new Atlas( ImageUtil.createRect( 16, 16, Apparat.COLOR_WHITE ) ) );
		
		// stage stuff
		stage.stageFocusRect = false;
		stage.quality = StageQuality.LOW;
		stage.scaleMode = StageScaleMode.NO_SCALE;

		_isInitialized = true;
	}

	/**
	 * Tries to run the garbage collector in all possible ways. May still not work, but most of the time it does.
	 */
	public static function garbageCollect() : Void {
		System.gc();
		#if flash
		try {
			new LocalConnection().connect( 'foo' );
			new LocalConnection().connect( 'foo' );
		} catch ( e : Dynamic ) {
		}
		#end
	}

	/**
	 * Checks whether the swf is loaded from an allowed domain.
	 * Use this to site lock your game.
	 * @param	pDomains	Array of allowed hosts.
	 * @return	True if swf is loaded from any of the allowed domains.
	 */
	public static function isAllowedDomain( pDomains : Array<String> ) : Bool {
		var url : String = Apparat.stage.loaderInfo.url;

		var startCheck : Int = url.indexOf( '://' ) + 3;

		if ( url.substr( 0, startCheck ) == 'file://' ) {
			return true;
		}

		var len : Int = url.indexOf( '/', startCheck ) - startCheck;
		var host : String = url.substr( startCheck, len );

		for ( domain in pDomains ) {
			if ( host.substr( -domain.length, domain.length ) == domain ) {
				return true;
			}
		}

		return false;
	}

	static public function getRenderHandlerClass() : Class < RenderHandler >
	{
		return _renderHandlerClass;
	}

	static public function setRenderHandlerClass( pClass :  Class<RenderHandler> ) : Void
	{
		_renderHandlerClass = pClass;
	}

}
