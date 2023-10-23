package radiosilence;

import openfl.geom.Vector3D;
import away3d.containers.View3D;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.materials.methods.FogMethod;
import oimo.common.Vec3;
import oimo.dynamics.World;
import oimo.dynamics.rigidbody.RigidBody;
import oimo.dynamics.rigidbody.RigidBodyType;
import oimo.collision.geometry.ConvexHullGeometry;

@:access(OimoUtils)
class Level {
	var view:View3D;
	var meshlist:Array<Mesh>;
	var ambientlight:Int;
	var lightpicker:StaticLightPicker;
	
	var levelmaterial:ColorMaterial;
	var blackmaterial:ColorMaterial;
	
	var fogmethod:FogMethod;
	var oimoworld:World;
	var center:Vec3;

	public function new(_view:View3D, _oimoworld:World, _ambientlight:Int, _lightpicker:StaticLightPicker) {
		view = _view;
		oimoworld = _oimoworld;
		ambientlight = _ambientlight;
		lightpicker = _lightpicker;
		meshlist = [];
		
		fogmethod = new FogMethod(0, 150, 0x000000);
		levelmaterial = new ColorMaterial(ambientlight);
		levelmaterial.ambientColor = 0x606060;
		levelmaterial.ambient = 1.0;
		levelmaterial.lightPicker = lightpicker;
		levelmaterial.addMethod(fogmethod);
		blackmaterial = new ColorMaterial(0x000000);
		blackmaterial.lightPicker = lightpicker;
		blackmaterial.addMethod(fogmethod);
		
		center = new Vec3(0, 0, 0);
	}
	
	public function changefog(fogdistance:Float){
		fogmethod.maxDistance = fogdistance;
	}
	
	public function getfog():Float{
		return fogmethod.maxDistance;
	}
	
	public function addplane(height:Float, size:Float, collidable:Bool = true){
		var newplane:Mesh = new Mesh(new away3d.primitives.PlaneGeometry(size, size, 1, 1), blackmaterial);
		newplane.position = new Vector3D(0, height, 0);
		
		if(collidable){
			var rb:RigidBody = OimoUtils.addRigidBody(oimoworld, new Vec3(0, height, 0), new oimo.collision.geometry.BoxGeometry(new Vec3(size / 2, 0.005, size / 2)), RigidBodyType.STATIC);
			rb.getShapeList().setFriction(1);
			
			OimoUtils.oimoStaticBodies.push(rb);
			OimoUtils.awayStaticBodies.push(newplane);
		}
		
		meshlist.push(newplane);
		view.scene.addChild(newplane);
	}
	
	public function addmodelgroup(meshname:String, count:Int, pos:Vector3D, angle:Float = 0.0, sx:Float = 1.0, sy:Float = 1.0, sz:Float = 1.0) {
		for (i in 1 ... (count + 1)){
			addmodel(meshname + "_" + i, pos, angle, sx, sy, sz);
		}
		addmodel(meshname, pos, angle, sx, sy, sz);
	}
	
	public function addmodel(meshname:String, pos:Vector3D, angle:Float = 0.0, sx:Float = 1.0, sy:Float = 1.0, sz:Float = 1.0) {
		var newmesh:Mesh = MeshLibrary.getmesh(meshname).clone();
		newmesh.material = levelmaterial;
		
		newmesh.position = pos;
		newmesh.rotationX = 0;
		newmesh.rotationY = (180 + angle) % 360; // Matches Unity coordinates
		newmesh.rotationZ = 0;
		newmesh.scaleX = sx;
		newmesh.scaleY = sy;
		newmesh.scaleZ = sz;
		
		//We can create collision geometry from the mesh data by reading in the
		//vertexdata from the away3d geometry. Each Away3d vertex has 13 floats
		//with normals/UVs etc, we just need the first 3 for position.
		//This only works if the mesh is a convex hull, so you gotta break up the
		//big models manually
		var convexgeometry:Array<Vec3> = [];
		for (v in newmesh.geometry.subGeometries){
			var vertex:openfl.Vector<Float> = v.vertexData;
			for (i in 0 ... v.numVertices){
				convexgeometry.push(new Vec3(vertex[(13 * i)] * sx, vertex[(13 * i) + 1] * sy, vertex[(13 * i) + 2] * sz)); 
			}
		}
		
		var geom:ConvexHullGeometry = new ConvexHullGeometry(convexgeometry);
		
		var rb:RigidBody = OimoUtils.addRigidBody(oimoworld, new Vec3(pos.x, pos.y, pos.z), geom, RigidBodyType.STATIC);
		rb.getShapeList().setFriction(1);
		rb.getShapeList().setRestitution(0);
		rb.setRotationXyz(new Vec3(0, ((180 + angle) % 360) * Math.PI / 180, 0));
		
		meshlist.push(newmesh);
		view.scene.addChild(newmesh);
	}
	
	public function addradio(pos:Vector3D, rx:Float, ry:Float, rz:Float):Array<Mesh> {
		var radio:Mesh = MeshLibrary.getmesh("radio").clone();
		radio.material = levelmaterial;
		
		radio.position = pos;
		radio.rotationX = rx;
		radio.rotationY = ry;
		radio.rotationZ = rz;
		
		meshlist.push(radio);
		
		var radioscreen:Mesh = MeshLibrary.getmesh("radioscreen").clone();
		radioscreen.material = blackmaterial;
		
		radioscreen.position = pos;
		radioscreen.rotationX = rx;
		radioscreen.rotationY = ry;
		radioscreen.rotationZ = rz;
		
		meshlist.push(radioscreen);
		
		view.scene.addChild(radio);
		view.scene.addChild(radioscreen);
		
		return [radio, radioscreen];
	}

	public function cleanup() {
		for (i in 0 ... meshlist.length){
			meshlist[i].dispose();
			meshlist[i] = null;
		}
		
		meshlist = [];
		
		oimoworld.removeRigidBody(oimoworld.getRigidBodyList());
	}
}
