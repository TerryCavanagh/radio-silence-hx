//Can be deleted from Terry Collection version, just mirroring the api
import openfl.Assets;
import openfl.media.Sound;

class AudioManager{
	static var splash:Sound = null;
	static var radiooff:Sound = null;
	
	public static function play(soundasset:SoundAssets){
		switch(soundasset){
			case SoundAssets.splash:
				if (splash == null) splash = Assets.getSound("audio/sounds/splash." + #if html5 "mp3" #else "ogg" #end );
				splash.play();
			case SoundAssets.radiooff:
				if (radiooff == null) radiooff = Assets.getSound("audio/sounds/radiooff." + #if html5 "mp3" #else "ogg" #end );
				radiooff.play();
			default:
				//Don't need to bother with most of the soundassets here
		}
	}
}