import away3d.containers.*;
import away3d.core.managers.Stage3DManager;
import away3d.core.managers.Stage3DProxy;
import away3d.debug.AwayStats;
import away3d.events.Stage3DEvent;
import oimo.common.Vec3;
import oimo.dynamics.World;
import openfl.display.*;
import openfl.events.*;
import openfl.geom.Vector3D;
import starling.core.*;

class Main extends Sprite {
	// engine variables
	private var stage3DManager:Stage3DManager;
	private var stage3DProxy:Stage3DProxy;
	private var away3dview:View3D;

	private var starlinglayer:Starling;

	// scene objects
	private var gamestate:GameState;

	private var oimoworld:World;

	public function new() {
		super();

		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		Input.init(stage);

		oimoworld = new World(new Vec3(0, -9.80665, 0));

		// first step, must do before anything else !!!
		OimoUtils.setWorld(oimoworld);

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
		// Create the first Away3D view
		away3dview = new View3D();
		away3dview.stage3DProxy = stage3DProxy;
		away3dview.shareContext = true;

		// setup the camera
		away3dview.camera.x = 30;
		away3dview.camera.z = 30;
		away3dview.camera.y = 20;
		away3dview.camera.lookAt(new Vector3D());

		MeshLibrary.load([
			"island1", "island2", "island3", "island4", "island5", "big1", "big2", "radio", "small1", "small2", "small3"
		], onloadcomplete);

		addChild(away3dview);
		addChild(new AwayStats(away3dview));

		initStarling();
	}

	private function onloadcomplete() {
		gamestate = new GameState(away3dview, oimoworld, stage);
		
		stage.addEventListener(Event.RESIZE, stageResizeHandler, false, 0, true);
		// setup the render loop
		stage3DProxy.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
	}

	private function initStarling() {
		starlinglayer = new Starling(StarlingLayer, stage, stage3DProxy.viewPort, stage3DProxy.stage3D);
		starlinglayer.shareContext = true;
	}

	private function _onEnterFrame(e:Event) {
		OimoUtils.updatePhysics();
		
		gamestate.update();
		away3dview.render();
		StarlingLayer.getInstance().update();
		starlinglayer.nextFrame();
	}
	
	private function stageResizeHandler(evt:Event) {
		starlinglayer.stage.stageWidth = stage3DProxy.width = stage.stageWidth;
		starlinglayer.stage.stageHeight = stage3DProxy.height = stage.stageHeight;
		
		away3dview.width = stage.stageWidth;
		away3dview.height = stage.stageHeight;
		
		//TODO: Resize the Starling Layer too
	}
}
