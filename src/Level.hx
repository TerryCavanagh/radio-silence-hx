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
	
	public function add(meshname:String, px:Float, py:Float, pz:Float, rx:Float, ry:Float, rz:Float, sx:Float, sy:Float, sz:Float):Mesh{
		var newmesh:Mesh = MeshLibrary.getmesh(meshname).clone();
		
		newmesh.material = new ColorMaterial(ambientlight);
		newmesh.material.lightPicker = lightpicker;
		
		newmesh.position = new Vector3D(px, py, pz);
		newmesh.rotationX = rx;
		newmesh.rotationY = ry;
		newmesh.rotationZ = rz;
		
		meshlist.push(newmesh);
		view.scene.addChild(newmesh);
		
		return newmesh;
	}
	
	public function cleanup(){
		
	}
}