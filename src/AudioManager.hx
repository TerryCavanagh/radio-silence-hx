//Can just be deleted
//
//Mirrors the api from Terry Collection version
import openfl.Assets;
import openfl.media.Sound;

class AudioManager{
	static var splash:Sound = null;
	static var radiooff:Sound = null;
	static var footsteps:Sound = null;
	
	public static function play(soundasset:SoundAssets):AudioID{
		switch(soundasset){
			case SoundAssets.splash:
				if (splash == null) splash = Assets.getSound("audio/sounds/splash." + #if html5 "mp3" #else "ogg" #end );
				splash.play();
			case SoundAssets.radiooff:
				if (radiooff == null) radiooff = Assets.getSound("audio/sounds/radiooff." + #if html5 "mp3" #else "ogg" #end );
				radiooff.play();
			case SoundAssets.footsteps:
				if (footsteps == null) footsteps = Assets.getSound("audio/sounds/footsteps." + #if html5 "mp3" #else "ogg" #end );
				return new AudioID(footsteps);
			default:
				//Don't need to bother with most of the soundassets here
		}
		
		return null;
	}
}