/* Simple input class that should be easy to swap out */

import openfl.display.Stage;
import openfl.events.*;
import openfl.ui.*;

class Input{
	static var keydownlist:Array<Int>;
	
	public static function init(stage:Stage){
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		keydownlist = [];
	}
	
	public static function action_pressed(action:InputActions):Bool{
		var keycode:Int = getkeycodefromaction(action);
		
		if (keydownlist.indexOf(keycode) > -1){
			return true;
		}
		
		return false;
	}
	
	static function getkeycodefromaction(action:InputActions):Int{
		switch(action){
			case MOVE_CAMERA_UP: return Keyboard.W;
			case MOVE_CAMERA_LEFT: return Keyboard.A;
			case MOVE_CAMERA_DOWN: return Keyboard.S;
			case MOVE_CAMERA_RIGHT: return Keyboard.D;
			case MOVE_UP: return Keyboard.UP;
			case MOVE_LEFT: return Keyboard.LEFT;
			case MOVE_DOWN: return Keyboard.DOWN;
			case MOVE_RIGHT: return Keyboard.RIGHT;
			case JUMP: return Keyboard.SPACE;
		}
	}
	
	static function onKeyDown(event:KeyboardEvent):Void {
		if (keydownlist.indexOf(event.keyCode) == -1) keydownlist.push(event.keyCode);
	}
	
	static function onKeyUp(event:KeyboardEvent):Void {
		if (keydownlist.indexOf(event.keyCode) > -1) keydownlist.remove(event.keyCode);
	}
}