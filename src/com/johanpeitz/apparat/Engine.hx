package com.johanpeitz.apparat;

import com.johanpeitz.apparat.prefabs.gui.TextEntity;
import com.johanpeitz.apparat.render.Atlas;
import com.johanpeitz.apparat.utils.Repository;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.system.System;
import openfl.Lib;
import openfl.text.TextField;
import openfl.utils.Timer;
import com.johanpeitz.apparat.components.render.RenderComponent;
import com.johanpeitz.apparat.prefabs.gui.TextEntity;
import com.johanpeitz.apparat.prefabs.LogoEntity;
import com.johanpeitz.apparat.utils.ImageUtil;
import com.johanpeitz.apparat.utils.LogicStats;
import com.johanpeitz.apparat.utils.Log;
import com.johanpeitz.apparat.utils.StringUtil;

/**
 * The engine manages and updates scenes. Inherit the engine with your document class to get rolling!
 * @author	Johan Peitz
 */
class Engine extends Sprite {
	private var _pauseOnFocusLost : Bool;

	private var _logicStats : LogicStats;

	private var _currentScene : Scene;
	private var _sceneStack : Array<Scene>;
	private var _sceneChanges : Array<Dynamic>;

	private var _renderClass : Class<Dynamic>;

	private var _internalScene : Scene;
	private var _performanceView : TextEntity;
	private var _logView : TextEntity;
	private var _logTexts : Array<String>;

	private var _targetFPS : Int;

	private var _frameCount : Int;
	private var _fpsTimer : Timer;
	private var _internalTimer : Timer;

	private var _timeStepS : Float;
	private var _timeStepMS : Float;
	private var _currentTimeMS : Float;
	private var _lastTimeMS : Float;
	private var _deltaTimeMS : Float;

	private var _width : Int;
	private var _height : Int;
	private var _scale : Int;
	private var _showingLogo : Bool;
	private var _hasFocus : Bool;
	private var _noFocusEntity : Entity;

	private var _sceneContainer : Sprite;

	/**
	 * Constructs a new engine. Automatically initializes Apparat. Sets the dimensions for the renderer.
	 * The size of the renderer and the scale should match the size of the application.
	 *
	 * @param	pWidth	Width of renderer.
	 * @param	pHeight	Height of renderer.
	 * @param	pScale	How much to scale the renderer.
	 * @param	pFPS	Target Frames Per Seconds.
	 * @param	pRendererClass	What renderer to use.
	 * @param       pShowLogo	Specifies whether to show Apparat logo at start or not.
	 */
	public function new( pWidth : Int, pHeight : Int, pScale : Int = 1, pFPS : Int = 30, pShowLogo : Bool = true ) {
		super( );

		_showingLogo = pShowLogo;
		_targetFPS = pFPS;
		_width = pWidth;
		_height = pHeight;
		_scale = pScale;

		_frameCount = 0;
		_logTexts = [];

		_timeStepS = 0;
		_timeStepMS = 0;
		_currentTimeMS = 0;
		_lastTimeMS = 0;
		_deltaTimeMS = 0;

		_hasFocus = true;
		_pauseOnFocusLost = true;

		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
	}

	private function onAddedToStage( pEvent : Event ) : Void {
		removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		Apparat.onEngineAddedToStage( this, stage );

		_sceneContainer = new Sprite();
		addChild( _sceneContainer );

		_logicStats = new LogicStats();

		_currentScene = null;
		_sceneStack = new Array<Scene>();
		_sceneChanges = [];

		_internalScene = new Scene(  );
		_internalScene.onAddedToEngine( this );
		addChild( _internalScene.renderHandler.getDisplayObject() );

		Log.addLogFunction( logListener );
		Log.log( "size set to " + _width + "x" + _height + ", " + _scale + "x", this, Log.INFO );

		if ( _showingLogo ) {
			_internalScene.addEntity( new LogoEntity( onLogoComplete ) );
		}

		_timeStepMS = 1000 / _targetFPS;
		_timeStepS = _timeStepMS / 1000;
		_lastTimeMS = _currentTimeMS = Lib.getTimer();

		_fpsTimer = new Timer( 1000 );
		_fpsTimer.addEventListener( TimerEvent.TIMER, onFpsTimer );
		_fpsTimer.start();

		_internalTimer = new Timer( 4 );
		_internalTimer.addEventListener( TimerEvent.TIMER, InternalUpdate );
		_internalTimer.start();

		stage.focus = this;
		//TODO make focus in/out work as intended
		//stage.addEventListener( Event.ACTIVATE, onFocusIn );
		//stage.addEventListener( Event.DEACTIVATE, onFocusOut );
	}

	/**
	 * Cleans up after the engine. Freeing resources.
	 */
	public function dispose() : Void {
		if ( _internalTimer != null ) {
			_internalTimer.stop();
			_internalTimer.addEventListener( TimerEvent.TIMER, InternalUpdate );
			_internalTimer = null;
		}

		if ( _internalTimer != null ) {
			_fpsTimer.stop();
			_fpsTimer.addEventListener( TimerEvent.TIMER, onFpsTimer );
			_fpsTimer = null;
		}

		stage.removeEventListener( FocusEvent.FOCUS_IN, onFocusIn );
		stage.removeEventListener( FocusEvent.FOCUS_OUT, onFocusOut );

	}

	private function logListener( pMessage : String ) : Void {
		_logTexts.push( Log.logCount + ": " + pMessage );

		if ( _logTexts.length > 3 ) {
			_logTexts.shift();
		}

		if ( _logView != null ) {
			_logView.text = getLogText();
		}

	}

	private function getLogText() : String {
		var s : String = "";
		for ( txt in _logTexts ) {
			s += StringUtil.trim( txt ) + "\n";
		}
		return s;
	}

	private function onFocusIn( evt : Event ) : Void {
		if ( !_pauseOnFocusLost )
			return;

		if ( _hasFocus )
			return;

		if ( !_internalTimer.running ) {
			_internalTimer.start();
			_lastTimeMS = Lib.getTimer();
			_hasFocus = true;
		}

		if ( _noFocusEntity != null ) {
			_internalScene.removeEntity( _noFocusEntity );
			_noFocusEntity = null;
		}

		_currentScene.onActivated();
	}

	private function onFocusOut( evt : Event ) : Void {
		if ( !_pauseOnFocusLost )
			return;

		if ( !_hasFocus )
			return;

		_hasFocus = false;

		_noFocusEntity = new Entity();
		_noFocusEntity.transform.setScale( 2 );
		var blockerAtlas : Atlas = new Atlas( ImageUtil.createRect( Std.int( _width / 2 ), Std.int( _height / 2 ), Apparat.COLOR_LIGHT_GRAY ) );
		var blocker : RenderComponent = new RenderComponent( blockerAtlas, 0, new Point() );
		blocker.alpha = 0.5;
		_noFocusEntity.addComponent( blocker );
		
		var message : TextEntity = new TextEntity( "*** PAUSED ***\n\nClick to resume.", Repository.fetch( Apparat.FONT_DEFAULT ), Apparat.COLOR_BLACK );
		message.alignment = Apparat.CENTER;
		message.width = Std.int( _width / 2 - 20 );

		_noFocusEntity.addEntity( message );
		_internalScene.addEntity( _noFocusEntity );

	}

	/**
	 * Resets the engine's timers.
	 * Should be called after time consuming algorithms so that the engine does not skip frames afterwards.
	 */
	public function resetTimers() : Void {
		_lastTimeMS = _currentTimeMS = Lib.getTimer();
	}

	/**
	 * Returns the stats for the logic speed.
	 * @return	logic stats
	 */
	public function getLogicStats() : LogicStats {
		return _logicStats;
	}

	private function onFpsTimer( evt : TimerEvent ) : Void {
		_logicStats.fps = _frameCount;
		_frameCount = 0;

		if ( _performanceView != null ) {
			_logicStats.currentMemory = Std.int( System.totalMemory / 1024 / 1024 );
			if ( _logicStats.maxMemory < _logicStats.currentMemory ) {
				_logicStats.maxMemory = _logicStats.currentMemory;
			}
			if ( _logicStats.minMemory == -1 || _logicStats.minMemory > _logicStats.currentMemory ) {
				_logicStats.minMemory = _logicStats.currentMemory;
			}
			var text : String = _logicStats.toString() + "\n";
			if ( _currentScene != null ) {
				for ( s in _currentScene.getHandlers() ) {	
					if ( s.getStats() != null ) {
						text += s.getStats().toString() + "\n";
					}
				}
			}
			else {
				text += "no active scene";
			}
			_performanceView.text = text.substr( 0, text.length - 1 ) ;
		}
	}

	private function InternalUpdate( evt : TimerEvent ) : Void {
		var logicTime : Int;

		_currentTimeMS = Lib.getTimer();
		_deltaTimeMS += _currentTimeMS - _lastTimeMS;
		_lastTimeMS = _currentTimeMS;

		if ( _deltaTimeMS >= _timeStepMS ) {
			// do logic
			while ( _deltaTimeMS >= _timeStepMS ) {
				_logicStats.reset();

				_deltaTimeMS -= _timeStepMS;

				// track logic performance
				logicTime = Lib.getTimer();

				// update current scene
				if ( _currentScene != null && _showingLogo == false ) {
					_currentScene.update( _timeStepS );
				}

				// update Internal scene
				_internalScene.update( _timeStepS );

				// calc logic time
				_logicStats.logicTime = Lib.getTimer() - logicTime;
			}

			// count fps
			_frameCount++;

			// render
			if ( _currentScene != null ) {
				_currentScene.render();
			}
			_internalScene.render();

			// make changes to scenes
			if ( _sceneChanges.length > 0 ) {
				for ( o in _sceneChanges ) {
					switch ( o.action ) {
						case "pop":
							InternalPopScene();
							
						case "push":
							InternalPushScene( o.scene );
					}
				}
				_sceneChanges = [];
			}

			// stop the Internal timer if we lost focus
			if ( !_hasFocus ) {
				_internalTimer.stop();
				_currentScene.onDeactivated();
			}

			// move on as fast as possible
			evt.updateAfterEvent();
		}
	}

	/**
	 * Adds a scene to the top of the scene stack. The added scene will now be the current scene.
	 * @param	pScene
	 */
	public function pushScene( pScene : Scene ) : Void {
		_sceneChanges.push({ action: "push", scene: pScene } );
	}

	private function InternalPushScene( pScene : Scene ) : Void {
		// Log.log( "pushing scene '" + pScene + "' on stack", this, Log.INFO );
		_sceneStack.push( pScene );

		// remove current scene from display tree (if any)
		if ( _currentScene != null ) {
			_currentScene.onDeactivated();
			_sceneContainer.removeChild( _currentScene.renderHandler.getDisplayObject() );
		}

		// add new scene
		_currentScene = pScene;
		_sceneContainer.addChild( _currentScene.renderHandler.getDisplayObject() );
		_currentScene.onAddedToEngine( this );
		
		Log.log( "scene (PUSH) = '" + _currentScene + "'", this, Log.INFO );
	}

	/**
	 * Removes to top most scene from the stack and sets the scene below to become the current scene.
	 * The popped scene will be disposed.
	 */
	public function popScene() : Void {
		_sceneChanges.push({ action: "pop", scene: null } );
	}

	private function InternalPopScene() : Void {
		// Log.log( "popping scene '" + _currentScene + "' from stack", this, Log.INFO );

		var lastScene : Scene = _sceneStack.pop();
		_sceneContainer.removeChild( lastScene.renderHandler.getDisplayObject() );
		lastScene.onRemovedFromEngine();

		if ( _sceneStack.length > 0 ) {
			_currentScene = _sceneStack[ _sceneStack.length - 1 ];
			_sceneContainer.addChild( _currentScene.renderHandler.getDisplayObject() );
			_currentScene.onActivated();
		} else {
			_currentScene = null;
		}

		Log.log( "scene (POP) = '" + _currentScene + "'", this, Log.INFO );
	}

	/**
	 * Returns whether the engine is showing the performance info or not.
	 * @return True is performance info is currently shown.
	 */
	public var showPerformance(null, set_showPerformance) : Bool;

	/**
	 * Specifies whether to show performance info or not.
	 */
	public function set_showPerformance( pShowPerformance : Bool ) : Bool {
		if ( _performanceView == null && pShowPerformance ) {
			Log.log( "turning performance view ON", "[o Apparat]", Log.DEBUG );
			_performanceView = new TextEntity( "", Repository.fetch( Apparat.FONT_DEFAULT ), Apparat.COLOR_BLACK );
			//_performaceView.textField.background = true;
			//_performaceView.textField.backgroundColor = Apparat.COLOR_LIGHT_GRAY;
			//_performaceView.textField.padding = 2;
			//_performaceView.textField.alpha = 0.8;
			_internalScene.entityRoot.addEntity( _performanceView );

			_logView = new TextEntity( "", Repository.fetch( Apparat.FONT_DEFAULT ), Apparat.COLOR_BLACK );
			//_logView.textField.background = true;
			//_logView.textField.backgroundColor = Apparat.COLOR_LIGHT_GRAY;
			//_logView.textField.padding = 2;
			//_logView.textField.alpha = 0.8;
			//_logView.textField.width = _width;
			_logView.transform.position.y = _height - 26;
			_logView.text = getLogText();
			_internalScene.entityRoot.addEntity( _logView );
		}


		if ( _performanceView != null && !pShowPerformance ) {
			Log.log( "turning performance view OFF", "[o Apparat]", Log.DEBUG );
			_internalScene.entityRoot.removeEntity( _performanceView );
			_performanceView.dispose();
			_performanceView = null;

			_internalScene.entityRoot.removeEntity( _logView );
			_logView.dispose();
			_logView = null;
		}

		return _performanceView != null;

	}

	private function onLogoComplete() : Void {
		_showingLogo = false;
	}
	
	
	/**
	 * Sets the background color of the stage.
	 * @param	pColor	color to set
	 */
	public function setBackgroundColor( pColor : Int ) : Void {
		Apparat.stage.color = pColor;
	}


	/**
	 * Returns the width of the engine.
	 * @return	Width of the engine.
	 */
	public var engineWidth(get_engineWidth, null) : Int;
	private function get_engineWidth() : Int
	{
		return _width;
	}

	/**
	 * Returns the height of the engine.
	 * @return	Height of the engine.
	 */
	public var engineHeight(get_engineHeight, null) : Int;
	private function get_engineHeight() : Int
	{
		return _height;
	}


	/**
	 * Sets the scale at which the engine renders graphics.
	 */
	public var engineScale(get_engineScale, null) : Int;
	private function get_engineScale() : Int {
		return _scale;
	}


	/**
	 * Returns the current scene.
	 * @return The current scene or null if there is none.
	 */
	public var currentScene( get_currentScene, null ) : Scene;
	private function get_currentScene() : Scene {
		return _currentScene;
	}

	/**
	 * Decides wether to pause the application if focus is lost.
	 */
	public function setPauseOnFocusLost( pPause : Bool) : Void {
		_pauseOnFocusLost = pPause;
	}



}
