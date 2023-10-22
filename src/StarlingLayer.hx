import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;
import openfl.Assets;

class StarlingLayer extends Sprite {
	var logo:Image;
	var logocountdown:Bool;
	var logotimer:Int;
	final maxlogotime:Int = 300; //60 frames * 5 seconds
	
	private static var _instance:StarlingLayer;

	public static function getInstance():StarlingLayer {
		return _instance;
	}

	public function new() {
		super();
		_instance = this;
		addEventListener(starling.events.Event.ADDED_TO_STAGE, onadded);
	}

	function onadded(_) {
		removeEventListener(starling.events.Event.ADDED_TO_STAGE, onadded);
		
		logocountdown = false;
		logotimer = maxlogotime;
		
		var logo_texture:Texture = Texture.fromBitmapData(Assets.getBitmapData("data/graphics/logo.png"));
		logo = new Image(logo_texture);
		logo.x = (1280 / 2) - (logo.width / 2);
		logo.y = (720 / 3) - (logo.height / 2);
		addChild(logo);
	}

	/* Once the player starts moving, remove the logo after five seconds. */
	public function update() {
		if(!logocountdown){
			if (Input.action_pressed(InputActions.MOVE_UP) ||
					Input.action_pressed(InputActions.MOVE_DOWN) ||
					Input.action_pressed(InputActions.MOVE_LEFT) ||
					Input.action_pressed(InputActions.MOVE_RIGHT)){
				logocountdown = true;
			}
		}else{
			if(logotimer > 0){
				logotimer--;
				if (logotimer <= 0){
					logo.visible = false;
				}
			}
		}
	}
}
