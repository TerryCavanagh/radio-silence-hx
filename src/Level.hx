import away3d.containers.View3D;
import away3d.entities.Mesh;
import away3d.materials.lightpickers.StaticLightPicker;
import openfl.geom.Vector3D;

class Level{
	var view:View3D;
	var meshlist:Array<Mesh>;
	
	public function new(_view:View3D){
		view = _view;
		meshlist = [];
	}
	
	public function add(meshname:String, pos:Vector3D):Mesh{
		var newmesh:Mesh = MeshLibrary.getmesh(meshname).clone();
		newmesh.position = pos;
		meshlist.push(newmesh);
		view.scene.addChild(newmesh);
		
		return newmesh;
	}
	
	public function applylight(l:StaticLightPicker){
		for (m in meshlist){
			m.material.lightPicker = l;
		}
	}
	
	public function cleanup(){
		
	}
}