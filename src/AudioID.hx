//Can just be deleted
//
//Mirrors the api from Terry Collection version
import openfl.media.Sound;
import openfl.media.SoundChannel;

class AudioID{
	var sound:Sound;
	var channel:SoundChannel;
	
	public function new(_sound:Sound){
		sound = _sound;
		channel = sound.play();
	}
	
	public function stop(){
		channel.stop();
		
		channel = null;
		sound = null;
	}
}