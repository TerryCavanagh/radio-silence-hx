import away3d.containers.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.utils.*;
import away3d.controllers.FirstPersonController;
import away3d.library.Asset3DLibrary;
import away3d.lights.DirectionalLight;
import away3d.loaders.parsers.AWDParser;
import away3d.events.Asset3DEvent;
import away3d.library.assets.IAsset;
import away3d.library.assets.Asset3DType;
import away3d.materials.lightpickers.StaticLightPicker;
import openfl.Assets;
import openfl.display.Scene;
import openfl.display.Stage;
import openfl.geom.Vector3D;

import openfl.events.*;
import openfl.ui.*;

class GameState{
	var view:View3D;
	var light:DirectionalLight;
	var lightPicker:StaticLightPicker;
	var radiosilence:Level;
	
	var stage:Stage;
	var controller:FirstPersonController;
	
	public function new(_view:View3D, _stage:Stage){
		stage = _stage;
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		view = _view;
		
		initlight();
		
		radiosilence = new Level(view, 0x808080, lightPicker);
		radiosilence.add("island4", 0, 0, 0, 0, 0, 0, 0, 0, 0);
		
		controller = new FirstPersonController(view.camera, 180, 0, -80, 80);
	}
	
	function initlight(){
		light = new DirectionalLight();
		light.position = new Vector3D( -46.10107, 41.36791, -44.0853);
		light.direction = new Vector3D(34.01631, 5.832711, 357.2608);
		light.color = 0xFFFFFF;
		light.ambient = 0.4149853;
		view.scene.addChild(light);
		
		lightPicker = new StaticLightPicker([this.light]);
	}
	
	public function update(){
		if (move) {
			controller.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
			controller.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
		}
		
		if (walkSpeed != 0 || walkAcceleration != 0) {
			walkSpeed = (walkSpeed + walkAcceleration)*drag;
			if (Math.abs(walkSpeed) < 0.01)
				walkSpeed = 0;
			controller.incrementWalk(walkSpeed);
		}
		
		if (strafeSpeed != 0 || strafeAcceleration != 0) {
			strafeSpeed = (strafeSpeed + strafeAcceleration)*drag;
			if (Math.abs(strafeSpeed) < 0.01)
				strafeSpeed = 0;
			controller.incrementStrafe(strafeSpeed);
		}
	}
	
	public function cleanup(){
		
	}
	
	//rotation variables
	private var move:Bool = false;
	private var lastPanAngle:Float;
	private var lastTiltAngle:Float;
	private var lastMouseX:Float;
	private var lastMouseY:Float;
	
	//movement variables
	private var drag:Float = 0.5;
	private var walkIncrement:Float = 2;
	private var strafeIncrement:Float = 2;
	private var walkSpeed:Float = 0;
	private var strafeSpeed:Float = 0;
	private var walkAcceleration:Float = 0;
	private var strafeAcceleration:Float = 0;
	
	/**
	 * Key down listener for camera control
	 */
	private function onKeyDown(event:KeyboardEvent):Void
	{
		switch (event.keyCode) {
			case Keyboard.UP, Keyboard.W:
				walkAcceleration = walkIncrement;
			case Keyboard.DOWN, Keyboard.S:
				walkAcceleration = -walkIncrement;
			case Keyboard.LEFT, Keyboard.A:
				strafeAcceleration = -strafeIncrement;
			case Keyboard.RIGHT, Keyboard.D:
				strafeAcceleration = strafeIncrement;
		}
	}
	
	/**
	 * Key up listener for camera control
	 */
	private function onKeyUp(event:KeyboardEvent):Void
	{
		switch (event.keyCode) {
			case Keyboard.UP, Keyboard.W, Keyboard.DOWN, Keyboard.S:
				walkAcceleration = 0;
			case Keyboard.LEFT, Keyboard.A, Keyboard.RIGHT, Keyboard.D:
				strafeAcceleration = 0;
		}
	}
	
	/**
	 * Mouse down listener for navigation
	 */
	private function onMouseDown(event:MouseEvent):Void
	{
		move = true;
		lastPanAngle = controller.panAngle;
		lastTiltAngle = controller.tiltAngle;
		lastMouseX = stage.mouseX;
		lastMouseY = stage.mouseY;
		stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	
	/**
	 * Mouse up listener for navigation
	 */
	private function onMouseUp(event:MouseEvent):Void
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	
	/**
	 * Mouse stage leave listener for navigation
	 */
	private function onStageMouseLeave(event:Event):Void
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
}