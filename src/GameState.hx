import away3d.containers.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.utils.*;
import away3d.library.Asset3DLibrary;
import away3d.lights.DirectionalLight;
import away3d.loaders.parsers.AWDParser;
import away3d.events.Asset3DEvent;
import away3d.library.assets.IAsset;
import away3d.library.assets.Asset3DType;
import away3d.materials.lightpickers.StaticLightPicker;
import openfl.Assets;
import openfl.display.Scene;
import openfl.geom.Vector3D;

class GameState{
	var view:View3D;
	var light:DirectionalLight;
	var lightPicker:StaticLightPicker;
	var radiosilence:Level;
	
	public function new(_view:View3D){
		view = _view;
		
		initlight();
		
		radiosilence = new Level(view);
		radiosilence.add("island1", new Vector3D(-50, 0, -50));
		radiosilence.add("island1", new Vector3D(0, 0, -50));
		radiosilence.add("island1", new Vector3D(50, 0, -50));
		
		radiosilence.add("island1", new Vector3D(-50, 0, 0));
		radiosilence.add("island1", new Vector3D(0, 0, 0));
		radiosilence.add("island1", new Vector3D(40, 0, 0));
		
		radiosilence.add("island1", new Vector3D(-50, 0, 50));
		radiosilence.add("island1", new Vector3D(0, 0, 50));
		radiosilence.add("island1", new Vector3D(50, 0, 50));
		
		radiosilence.applylight(lightPicker);
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
		
	}
	
	public function cleanup(){
		
	}
}