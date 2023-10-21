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
import openfl.ui.Keyboard;

class GameState{
	var view:View3D;
	var light:DirectionalLight;
	var lightPicker:StaticLightPicker;
	var radiosilence:Level;
	var oimoworld:World;
	
	var radio:Array<Radio>;
	var player:PlayerFPSController;
	var inwater:Bool;
	
	var stage:Stage;
	
	public function new(_view:View3D, _oimoworld:World, _stage:Stage){
		stage = _stage;
		
		view = _view;
		oimoworld = _oimoworld;
		
		initlight();
		
		radiosilence = new Level(view, oimoworld, 0xFFFFFF, lightPicker);
		
		radiosilence.addplane(0, 1000, 0x000000, false);
		radiosilence.addplane(-2, 1000, 0x000000, true);
		
		radiosilence.addmodelgroup("island1", 13, new Vector3D(0, 0, 0));
		radiosilence.addmodelgroup("island2", 16, new Vector3D(100, 0, 10), 40);
		radiosilence.addmodelgroup("island3", 10, new Vector3D(20, 0, -85));
		radiosilence.addmodelgroup("island4", 8, new Vector3D(60, 0, 80), 45);
		radiosilence.addmodelgroup("island5", 13, new Vector3D( -130, 0, 10));
		
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
		
		player = new PlayerFPSController(new Vector3D( -1.061736, 5, 0), view.camera, radiosilence);
		
		radio = [];
		radio.push(new Radio(player, SoundAssets.radio4, radiosilence.addradio(new Vector3D( -133.4188, 5.0166802091133, 30.702270319893), 40, 180, 0)));
		radio.push(new Radio(player, SoundAssets.radio3, radiosilence.addradio(new Vector3D(114.0653, 1.16994856030492, 36.0713368628997), 65, 180, 0)));
		radio.push(new Radio(player, SoundAssets.radio2, radiosilence.addradio(new Vector3D(37.3694348674523, 4.139511, 92.3384911064313), 90, 185, 0)));
		radio.push(new Radio(player, SoundAssets.radio1, radiosilence.addradio(new Vector3D(21.5730602225837, 2.3690367885654, -93.2907867652821), 20, 285, 0)));
		radio.push(new Radio(player, SoundAssets.radio5, radiosilence.addradio(new Vector3D(71.07146, 1.246474, 29.6465), 90, 180, 0)));
		radio.push(new Radio(player, SoundAssets.radio6, radiosilence.addradio(new Vector3D(-32.3904016015446, 10.4923053976431, 89.3429549610537), 90, 215, 0)));
		radio.push(new Radio(player, SoundAssets.water, radiosilence.addradio(new Vector3D(-119.4835, 3.650509, -119.8437), 90, 50, 0)));
		radio.push(new Radio(player, SoundAssets.radio8, radiosilence.addradio(new Vector3D(10.9876076407625, 3.91578086042665, -5.24179292182197), 20, 320, 0)));
		
		inwater = false;
	}
	
	function initlight(){
		light = new DirectionalLight();
		light.position = new Vector3D(0, 100, 0);
		light.rotateTo(39.0688712061326, 15.4389766266883, 355);

		light.color = 0xBBBBBB;
		light.ambient = 0.4149853;
		light.diffuse = 1.0;
		light.specular = 0.0;
		view.scene.addChild(light);
		
		lightPicker = new StaticLightPicker([this.light]);
	}
	
	public function update(){
		if (player.ypos() < 1){
			if (!inwater)	AudioManager.play(SoundAssets.splash);
			inwater = true;
		}else{
			if (inwater)	AudioManager.play(SoundAssets.splash);
			inwater = false;
		}
		
		if (inwater){
			var fog:Float = radiosilence.getfog() - 7.5;
			if (fog < 4) fog = 4;
			radiosilence.changefog(fog);
		}else{
			var fog:Float = radiosilence.getfog() + 7.5;
			if (fog > 150) fog = 150;
			radiosilence.changefog(fog);
		}
		
		if (Input.key_justpressed(Keyboard.NUMBER_1)){
			light.rotationX = ((light.rotationX - 5) + 360) % 360;
			trace("light: rot(" + light.rotationX + ", " + light.rotationY + ", " + light.rotationZ + ")");
		}
		if (Input.key_justpressed(Keyboard.NUMBER_2)){
			light.rotationX = ((light.rotationX + 5) + 360) % 360;
			trace("light: rot(" + light.rotationX + ", " + light.rotationY + ", " + light.rotationZ + ")");
		}
		if (Input.key_justpressed(Keyboard.NUMBER_3)){
			light.rotationY = ((light.rotationY - 5) + 360) % 360;
			trace("light: rot(" + light.rotationX + ", " + light.rotationY + ", " + light.rotationZ + ")");
		}
		if (Input.key_justpressed(Keyboard.NUMBER_4)){
			light.rotationY = ((light.rotationY + 5) + 360) % 360;
			trace("light: rot(" + light.rotationX + ", " + light.rotationY + ", " + light.rotationZ + ")");
		}
		if (Input.key_justpressed(Keyboard.NUMBER_5)){
			light.rotationZ = ((light.rotationZ - 5) + 360) % 360;
			trace("light: rot(" + light.rotationX + ", " + light.rotationY + ", " + light.rotationZ + ")");
		}
		if (Input.key_justpressed(Keyboard.NUMBER_6)){
			light.rotationZ = ((light.rotationZ + 5) + 360) % 360;
			trace("light: rot(" + light.rotationX + ", " + light.rotationY + ", " + light.rotationZ + ")");
		}
		/*
		if (Input.key_pressed(Keyboard.SHIFT)){
			if (Input.key_justpressed(Keyboard.NUMBER_1)){
				radio.moveLeft(0.025);
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_2)){
				radio.moveRight(0.025);
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_3)){
				radio.moveUp(0.025);
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_4)){
				radio.moveDown(0.025);
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_5)){
				radio.moveBackward(0.025);
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_6)){
				radio.moveForward(0.025);
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
		}else{
			if (Input.key_justpressed(Keyboard.NUMBER_1)){
				radio.rotationX = ((radio.rotationX - 5) + 360) % 360;
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_2)){
				radio.rotationX = ((radio.rotationX + 5) + 360) % 360;
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_3)){
				radio.rotationY = ((radio.rotationY - 5) + 360) % 360;
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_4)){
				radio.rotationY = ((radio.rotationY + 5) + 360) % 360;
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_5)){
				radio.rotationZ = ((radio.rotationZ - 5) + 360) % 360;
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
			if (Input.key_justpressed(Keyboard.NUMBER_6)){
				radio.rotationZ = ((radio.rotationZ + 5) + 360) % 360;
				trace("radio: pos(" + radio.position + "), rot(" + radio.rotationX + ", " + radio.rotationY + ", " + radio.rotationZ + ")");
			}
		}*/
		//Player Movement
		player.checkjump();
		player.update();
		player.updatecamera(view.camera);
		
		//Update radios
		for (r in radio){
			r.update();
		}
		
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