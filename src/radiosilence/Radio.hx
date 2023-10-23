package radiosilence;

import away3d.audio.Sound3D;
import away3d.entities.Mesh;
import openfl.geom.Vector3D;
import openfl.media.Sound;
import openfl.events.Event;
import openfl.Assets;

class Radio{
	public var isOn:Bool;
	var pos:Vector3D;
	var model:Array<Mesh>;
	var radioscreen:Mesh;
	var radiosound:SoundAssets;
	var player:PlayerFPSController;
	
	var sound3d:Sound3D;
	var soundvol:Float;
	var fadein:Int;
	
	final volumescale:Float = 0.1;
	final maxfadein:Int = 300;
	
  public function new(_player:PlayerFPSController, sound:SoundAssets, radiomesh:Array<Mesh>){
		model = radiomesh;
		radiosound = sound;
		player = _player;
		pos = radiomesh[0].position.clone();
		isOn = true;
		
		fadein = maxfadein;
		soundvol = 1;
		
		var soundobj:Sound = null;
		var soundscale:Float = 100;
		
		switch(sound){
			case SoundAssets.radio1: 
				soundobj = Assets.getSound("audio/sounds/radio1." + #if html5 "mp3" #else "ogg" #end );
				soundvol = 2;
			case SoundAssets.radio2: 
				soundobj = Assets.getSound("audio/sounds/radio2." + #if html5 "mp3" #else "ogg" #end );
				soundvol = 2;
			case SoundAssets.radio3: soundobj = Assets.getSound("audio/sounds/radio3." + #if html5 "mp3" #else "ogg" #end );
			case SoundAssets.radio4: soundobj = Assets.getSound("audio/sounds/radio4." + #if html5 "mp3" #else "ogg" #end );
			case SoundAssets.radio5: soundobj = Assets.getSound("audio/sounds/radio5." + #if html5 "mp3" #else "ogg" #end );
			case SoundAssets.radio6: soundobj = Assets.getSound("audio/sounds/radio6." + #if html5 "mp3" #else "ogg" #end );
			case SoundAssets.radio7: soundobj = Assets.getSound("audio/sounds/radio7." + #if html5 "mp3" #else "ogg" #end );
			case SoundAssets.radio8: 
				soundobj = Assets.getSound("audio/sounds/radio8." + #if html5 "mp3" #else "ogg" #end );
				soundvol = 2;
			case SoundAssets.water: 
				soundobj = Assets.getSound("audio/sounds/water." + #if html5 "mp3" #else "ogg" #end );
				soundvol = 2;
				soundscale = 250;
			default:
				//do nothing
		}
		
		if (soundobj != null){
			sound3d = new Sound3D(soundobj, player.playercamera, null, 0, soundscale);
			sound3d.position = radiomesh[0].position;
			sound3d.addEventListener(Event.SOUND_COMPLETE, soundcomplete);
			
			sound3d.play();
		}
  }
	
	function soundcomplete(e:Event){
		sound3d.play();
	}
	
	public function update(){
		if (isOn){
			var dist:Float = player.position.subtract(pos).lengthSquared;
			
			if (dist < 10){
				sound3d.stop();
				AudioManager.play(SoundAssets.radiooff);
				model[0].visible = false;
				model[1].visible = false;
				
				isOn = false;
			}else{
				if (fadein > 0){
					if (fadein == 1){
						sound3d.volume = (soundvol * volumescale);
					}else{
						sound3d.volume = (soundvol * volumescale) * ((maxfadein - fadein) / maxfadein);
					}
					fadein--;
				}
			}
		}
	}
}