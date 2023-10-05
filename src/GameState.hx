import away3d.containers.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.utils.*;
import openfl.geom.Vector3D;

class GameState{
	var view:View3D;
	var plane:Mesh;
	
	public function new(_view:View3D){
		view = _view;
		
		//setup the scene
		plane = new Mesh(new PlaneGeometry(700, 700), new TextureMaterial(Cast.bitmapTexture("data/floor_diffuse.jpg")));
		view.scene.addChild(plane);
	}
	
	public function update(){
		plane.rotationY += 1;
	}
	
	public function cleanup(){
		
	}
}