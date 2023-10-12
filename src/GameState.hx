import away3d.containers.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.utils.*;
import away3d.lights.*;
import away3d.loaders.parsers.AWDParser;
import away3d.events.Asset3DEvent;
import away3d.library.assets.IAsset;
import away3d.library.assets.Asset3DType;
import away3d.materials.lightpickers.StaticLightPicker;
import openfl.Assets;
import openfl.display.Scene;
import openfl.display.Stage;
import openfl.geom.Vector3D;
import oimo.common.Vec3;
import oimo.dynamics.World;

class GameState{
	var view:View3D;
	var ambient:DirectionalLight;
	var light:DirectionalLight;
	var lightPicker:StaticLightPicker;
	var radiosilence:Level;
	var oimoworld:World;
	
	var player:PlayerFPSController;
	
	var stage:Stage;
	
	public function new(_view:View3D, _oimoworld:World, _stage:Stage){
		stage = _stage;
		
		view = _view;
		oimoworld = _oimoworld;
		
		initlight();
		
		radiosilence = new Level(view, oimoworld, 0xFFFFFF, lightPicker);
		
		radiosilence.addcube(new Vector3D(0, 0, 0), new Vector3D(500, 1, 500), 0x202020);
		
		//Manually split the big islands into convex hulls in blender
		radiosilence.addmodel("island1", new Vector3D(0, 0, 0));
		radiosilence.addmodel("island1_1", new Vector3D(0, 0, 0));
		radiosilence.addmodel("island1_2", new Vector3D(0, 0, 0));
		radiosilence.addmodel("island1_3", new Vector3D(0, 0, 0));
		radiosilence.addmodel("island1_4", new Vector3D(0, 0, 0));
		radiosilence.addmodel("island1_5", new Vector3D(0, 0, 0));
		radiosilence.addmodel("island1_6", new Vector3D(0, 0, 0));
		radiosilence.addmodel("island1_7", new Vector3D(0, 0, 0));
		
		radiosilence.addmodel("island2", new Vector3D(100, 0, 10), 40);
		radiosilence.addmodel("island2_1", new Vector3D(100, 0, 10), 40);
		radiosilence.addmodel("island2_2", new Vector3D(100, 0, 10), 40);
		radiosilence.addmodel("island2_3", new Vector3D(100, 0, 10), 40);
		radiosilence.addmodel("island2_4", new Vector3D(100, 0, 10), 40);
		radiosilence.addmodel("island2_5", new Vector3D(100, 0, 10), 40);
		radiosilence.addmodel("island2_6", new Vector3D(100, 0, 10), 40);
		
		radiosilence.addmodel("island3", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_1", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_2", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_3", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_4", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_5", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_6", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_7", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_8", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_9", new Vector3D(20, 0, -85));
		radiosilence.addmodel("island3_10", new Vector3D(20, 0, -85));
		
		/* todo: the other 2
		radiosilence.addmodel("island4", new Vector3D(60, 0, 80), 45);
		radiosilence.addmodel("island5", new Vector3D( -130, 0, 10));
		*/
		
		radiosilence.addmodel("big1", new Vector3D( -4.854439, 0, -56.49567), 75);
		radiosilence.addmodel("big1", new Vector3D( -46.08296, 0, -97.01513), 20, 1.0, 0.75, 1.0);
		radiosilence.addmodel("big1", new Vector3D( 53.12647, 0, -6.426665), 75, 1.0, 0.5, 1.0);
		radiosilence.addmodel("big1", new Vector3D( -16.84418, 0, 92.27372), 75, 1.0, 0.5, 1.0);
		radiosilence.addmodel("big2", new Vector3D( 63.41546, 0, -13.25198));
		radiosilence.addmodel("big2", new Vector3D( -32.4323, 0, 91.78304));
		
		radiosilence.addmodel("small1", new Vector3D( -15.15427, 0, -106.7147), 25);
		radiosilence.addmodel("small1", new Vector3D( 5.120502, 0, -32.25725), 25);
		radiosilence.addmodel("small1", new Vector3D( -51.2622, 0, -72.3462), 25);
		radiosilence.addmodel("small1", new Vector3D( 32.37537, 0, 4.458617), 25, 0.5, 0.5, 0.5);
		radiosilence.addmodel("small1", new Vector3D( 75.12033, 0, 17.87098), 25, 0.5, 0.5, 0.5);
		radiosilence.addmodel("small1", new Vector3D( 70.2337, 0, 29.36496), 300, 0.5, 0.5, 0.5);
		radiosilence.addmodel("small1", new Vector3D( -2.622169, 0, 86.72875), 25, 0.5, 0.5, 0.5);
		radiosilence.addmodel("small1", new Vector3D( 67.30341, 0, 40.30682), 70, 0.5, 0.5, 0.5);
		radiosilence.addmodel("small1", new Vector3D( -61.98119, 0, 110.2147), 25, 0.5, 0.5, 0.5);
		radiosilence.addmodel("small1", new Vector3D( -84.93326, 0, 91.79323), 0, 0.5, 0.5, 0.5);
		radiosilence.addmodel("small1", new Vector3D( -93.22892, 0, 80.89188), 60, 0.625, 1.0, 0.5);
		radiosilence.addmodel("small1", new Vector3D( -91.43243, 0, 70.86296), 60, 0.5, 0.5, 0.375);
		radiosilence.addmodel("small1", new Vector3D( -92.50456, 0, 62.44536), 60, 0.25, 0.25, 0.25);
		
		radiosilence.addmodel("small2", new Vector3D( 7.544545, 0, -47.84687), 85, 1.0, 1.5, 1.0);
		radiosilence.addmodel("small2", new Vector3D( 43.38206, 0, 8.116565), 85, 1.0, 0.75, 1.0);
		radiosilence.addmodel("small2", new Vector3D( -70.79312, 0, 98.45782), 40, 1.0, 1.5, 1.0);
		
		radiosilence.addmodel("small3", new Vector3D( -28.70023, 0, -102.7967), 20);
		radiosilence.addmodel("small3", new Vector3D( -115.9278, 0, -117.4562), 20);
		radiosilence.addmodel("small3", new Vector3D( -64.87697, 0, -53.60156), 20);
		radiosilence.addmodel("small3", new Vector3D( 57.70886, 0, 46.51263), 20);
		radiosilence.addmodel("small3", new Vector3D( 61.35777, 0, 67.3923), 320);
		radiosilence.addmodel("small3", new Vector3D( -42.07666, 0, 114.5882), 20);
		
		player = new PlayerFPSController(new Vector3D(0, 5, 0), radiosilence);
	}
	
	function initlight(){
		ambient = new DirectionalLight();
		ambient.position = new Vector3D(0, 100 , 0);
		ambient.direction = new Vector3D(100, 0, 0);
		ambient.color = 0x880088;
		ambient.ambient = 0.2;
		ambient.diffuse = 1.0;
		ambient.specular = 0.0;
		view.scene.addChild(ambient);
		
		light = new DirectionalLight();
		light.position = new Vector3D( -46.10107, 41.36791, -44.0853);
		light.direction = new Vector3D(34.01631, 5.832711, 357.2608);
		light.color = 0x008800;
		//light.ambient = 0.4149853;
		light.ambient = 0.2;
		light.diffuse = 1.0;
		light.specular = 0.0;
		view.scene.addChild(light);
		
		lightPicker = new StaticLightPicker([this.ambient, this.light]);
		//lightPicker = new StaticLightPicker([this.ambient]);
		//lightPicker = new StaticLightPicker([this.light]);
	}
	
	public function update(){
		//Player Movement
		player.checkjump();
		player.update();
		player.updatecamera(view.camera);
		
		if (Mouse.leftclick() || Mouse.rightclick() || Mouse.middleclick()){
			if (player.mouselock){
				player.unlockmouse();
			}else{
				player.lockmouse();
			}
		}
		
		#if !html5
		if (Input.action_pressed(InputActions.QUIT)){
			Sys.exit(0);
		}
		#end
	}
	
	public function cleanup(){
		
	}
}