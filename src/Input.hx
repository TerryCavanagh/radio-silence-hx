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
		var keycode:Array<Int> = getkeycodesfromaction(action);
		
		for(k in keycode){
			if (keydownlist.indexOf(k) > -1){
				return true;
			}
		}
		
		return false;
	}
	
	static function getkeycodesfromaction(action:InputActions):Array<Int>{
		switch(action){
			case MOVE_UP: return [Keyboard.W, Keyboard.UP];
			case MOVE_LEFT: return [Keyboard.A, Keyboard.LEFT];
			case MOVE_DOWN: return [Keyboard.S, Keyboard.DOWN];
			case MOVE_RIGHT: return [Keyboard.D, Keyboard.RIGHT];
			case JUMP: return [Keyboard.SPACE, Keyboard.Z, Keyboard.X];
			case QUIT: return [Keyboard.ESCAPE];
		}
	}
	
	static function onKeyDown(event:KeyboardEvent):Void {
		if (keydownlist.indexOf(event.keyCode) == -1) keydownlist.push(event.keyCode);
	}
	
	static function onKeyUp(event:KeyboardEvent):Void {
		if (keydownlist.indexOf(event.keyCode) > -1) keydownlist.remove(event.keyCode);
	}
}