import away3d.containers.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.utils.*;
import away3d.core.managers.Stage3DManager;
import away3d.core.managers.Stage3DProxy;
import away3d.events.Stage3DEvent;
import away3d.debug.AwayStats;

import openfl.display.*;
import openfl.events.*;
import openfl.geom.Vector3D;

import starling.core.*;

class Main extends Sprite {
	//engine variables
	private var stage3DManager:Stage3DManager;
	private var stage3DProxy:Stage3DProxy;
	private var away3dview:View3D;
	
	private var starlinglayer:Starling;
	
	//scene objects
	private var gamestate:GameState;
	
	public function new(){
		super();
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		initProxies();
	}
	
	private function initProxies() {
		// Define a new Stage3DManager for the Stage3D objects
		stage3DManager = Stage3DManager.getInstance(stage);
		
		// Create a new Stage3D proxy to contain the separate views
		stage3DProxy = stage3DManager.getFreeStage3DProxy();
		stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
	}
	
	private function onContextCreated(event:Stage3DEvent) {
		initAway3D();
		//initStarling();
		
		gamestate = new GameState(away3dview);
		
		//setup the render loop
		stage.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
	}
	
	private function initAway3D(){
		// Create the first Away3D view which holds the cube objects.
		away3dview = new View3D();
		away3dview.stage3DProxy = stage3DProxy;
		away3dview.shareContext = true;
		
		//setup the camera
		away3dview.camera.z = -600;
		away3dview.camera.y = 500;
		away3dview.camera.lookAt(new Vector3D());
		
		addChild(away3dview);
		addChild(new AwayStats(away3dview));
	}
	
	private function initStarling(){
		starlinglayer = new Starling(StarlingLayer, stage, stage3DProxy.viewPort, stage3DProxy.stage3D);
	}
	
	private function _onEnterFrame(e:Event) {
		stage3DProxy.clear();
		
		gamestate.update();
		away3dview.render();
		//starlinglayer.nextFrame();
		
		stage3DProxy.present();
	}
	
	
}