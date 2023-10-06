import away3d.containers.View3D;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import away3d.materials.lightpickers.StaticLightPicker;
import openfl.geom.Vector3D;

class Level{
	var view:View3D;
	var meshlist:Array<Mesh>;
	var ambientlight:Int;
	var lightpicker:StaticLightPicker;
	
	public function new(_view:View3D, _ambientlight:Int, _lightpicker:StaticLightPicker){
		view = _view;
		ambientlight = _ambientlight;
		lightpicker = _lightpicker;
		meshlist = [];
	}
	
	public function add(meshname:String, pos:Vector3D, angle:Float = 0.0, sx:Float = 1.0, sy:Float = 1.0, sz:Float = 1.0):Mesh{
		var newmesh:Mesh = MeshLibrary.getmesh(meshname).clone();
		
		newmesh.material = new ColorMaterial(ambientlight);
		newmesh.material.lightPicker = lightpicker;
		
		newmesh.position = pos;
		newmesh.rotationX = 0;
		newmesh.rotationY = (180 + angle) % 360; //Matches Unity coordinates
		newmesh.rotationZ = 0;
		newmesh.scaleX = sx;
		newmesh.scaleY = sy;
		newmesh.scaleZ = sz;
		
		meshlist.push(newmesh);
		view.scene.addChild(newmesh);
		
		return newmesh;
	}
	
	public function cleanup(){
		
	}
}