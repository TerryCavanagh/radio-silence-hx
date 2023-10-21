//Can be deleted from Terry Collection version, just mirroring the api
import openfl.Assets;
import openfl.media.Sound;

class AudioManager{
	static var splash:Sound = null;
	
	public static function play(soundasset:SoundAssets){
		switch(soundasset){
			case SoundAssets.splash:
				if (splash == null) splash = Assets.getSound("audio/sounds/splash." + #if html5 "mp3" #else "ogg" #end );
				splash.play();
		}
	}
}