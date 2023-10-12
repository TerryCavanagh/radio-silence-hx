import away3d.materials.methods.*;
import away3d.primitives.CubeGeometry;
import away3d.primitives.CapsuleGeometry;
import away3d.primitives.CylinderGeometry;
import oimo.collision.geometry.ConvexHullGeometry;
import oimo.collision.geometry.SphereGeometry;
import oimo.common.Quat;
import oimo.dynamics.rigidbody.RigidBody;
import oimo.dynamics.rigidbody.RigidBodyConfig;
import oimo.dynamics.rigidbody.RigidBodyType;
import away3d.containers.View3D;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import away3d.materials.lightpickers.StaticLightPicker;
import oimo.dynamics.rigidbody.Shape;
import oimo.dynamics.rigidbody.ShapeConfig;
import openfl.geom.ColorTransform;
import openfl.geom.Vector3D;
import oimo.common.Vec3;
import oimo.dynamics.World;

class Level {
	var view:View3D;
	var meshlist:Array<Mesh>;
	var ambientlight:Int;
	var lightpicker:StaticLightPicker;
	var levelmaterial:ColorMaterial;
	var fogmethod:FogMethod;
	var oimoworld:World;
	var center:Vec3;

	public function new(_view:View3D, _oimoworld:World, _ambientlight:Int, _lightpicker:StaticLightPicker) {
		view = _view;
		oimoworld = _oimoworld;
		ambientlight = _ambientlight;
		lightpicker = _lightpicker;
		meshlist = [];
		
		fogmethod = new FogMethod(0, 125, 0x000000);
		levelmaterial = new ColorMaterial(ambientlight);
		levelmaterial.ambientColor = 0x404040;
		levelmaterial.ambient = 1.0;
		levelmaterial.lightPicker = lightpicker;
		levelmaterial.addMethod(fogmethod);
		
		center = new Vec3(0, 0, 0);
	}
	
	/* Basically just for physics testing */
	public function addcube(pos:Vector3D, size:Vector3D, color:Int, anchored:Bool = true):PhysicsObject{
		var cubematerial:ColorMaterial = new ColorMaterial(color);
		cubematerial.lightPicker = lightpicker;
		cubematerial.addMethod(fogmethod);
		
		var newcube:Mesh = new Mesh(new CubeGeometry(size.x, size.y, size.z), cubematerial);
		newcube.position = pos;
		
		var rb:RigidBody = OimoUtils.addPhysics(newcube, anchored?RigidBodyType.STATIC:RigidBodyType.DYNAMIC, [pos.x, pos.y, pos.z]);
		rb.getShapeList().setFriction(1);
		
		meshlist.push(newcube);
		view.scene.addChild(newcube);
		
		return new PhysicsObject(newcube, rb);
	}

	public function addmodel(meshname:String, pos:Vector3D, angle:Float = 0.0, sx:Float = 1.0, sy:Float = 1.0, sz:Float = 1.0):Mesh {
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
				convexgeometry.push(new Vec3(vertex[(13 * i)], vertex[(13 * i) + 1], vertex[(13 * i) + 2])); 
			}
		}
		
		var geom:ConvexHullGeometry = new ConvexHullGeometry(convexgeometry);
		
		var rb:RigidBody = OimoUtils.addRigidBody(oimoworld, new Vec3(pos.x, pos.y, pos.z), geom, RigidBodyType.STATIC);
		rb.getShapeList().setFriction(1);
		rb.getShapeList().setRestitution(0);
		rb.setRotationXyz(new Vec3(0, ((180 + angle) % 360) * Math.PI / 180, 0));
		
		meshlist.push(newmesh);
		view.scene.addChild(newmesh);

		return newmesh;
	}
	
	public function addradio(pos:Vector3D, rx:Float, ry:Float, rz:Float):Mesh {
		var radio:Mesh = MeshLibrary.getmesh("radio").clone();
		radio.material = levelmaterial;
		
		radio.position = pos;
		radio.rotationX = rx;
		radio.rotationY = ry;
		radio.rotationZ = rz;
		
		meshlist.push(radio);
		view.scene.addChild(radio);
		
		return radio;
	}

	public function cleanup() {}
}
