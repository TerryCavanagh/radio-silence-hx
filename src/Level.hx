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
import openfl.geom.Vector3D;
import oimo.common.Vec3;
import oimo.dynamics.World;

class Level {
	var view:View3D;
	var meshlist:Array<Mesh>;
	var ambientlight:Int;
	var lightpicker:StaticLightPicker;
	var oimoworld:World;
	var center:Vec3;

	public function new(_view:View3D, _oimoworld:World, _ambientlight:Int, _lightpicker:StaticLightPicker) {
		view = _view;
		oimoworld = _oimoworld;
		ambientlight = _ambientlight;
		lightpicker = _lightpicker;
		meshlist = [];
		
		center = new Vec3(0, 0, 0);
	}
	
	/* Basically just for physics testing */
	public function addcube(pos:Vector3D, size:Vector3D, color:Int, anchored:Bool = true):PhysicsObject{
		var cubematerial:ColorMaterial = new ColorMaterial(color);
		cubematerial.lightPicker = lightpicker;
		
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

		newmesh.material = new ColorMaterial(ambientlight);
		newmesh.material.lightPicker = lightpicker;

		newmesh.position = pos;
		newmesh.rotationX = 0;
		//newmesh.rotationY = (180 + angle) % 360; // Matches Unity coordinates
		newmesh.rotationZ = 0;
		newmesh.scaleX = sx;
		newmesh.scaleY = sy;
		newmesh.scaleZ = sz;
		
		/**
	 * Updates the vertex data. All vertex properties are contained in a single Vector, and the order is as follows:
	 * 0 - 2: vertex position X, Y, Z
	 * 3 - 5: normal X, Y, Z
	 * 6 - 8: tangent X, Y, Z
	 * 9 - 10: U V
	 * 11 - 12: Secondary U V
	 */
		var convexgeometry:Array<Vec3> = [];
		for (v in newmesh.geometry.subGeometries){
			var vertex:openfl.Vector<Float> = v.vertexData;
			for (i in 0 ... v.numVertices){
				convexgeometry.push(new Vec3(vertex[(13 * i)], vertex[(13 * i) + 1], vertex[(13 * i) + 2])); 
			}
			trace(v.numVertices);
			trace(v.vertexData);
		}
		
		var geom:ConvexHullGeometry = new ConvexHullGeometry(convexgeometry);
		/*var geom:ConvexHullGeometry = new ConvexHullGeometry([
		  new Vec3(3.677618, 3.022507, 2.331949),
			new Vec3(3.599429, -0.000001, 4.092279),
			new Vec3(1.047955, 3.022506, 3.736754),
			new Vec3(-0.413632, 3.022507, 2.851745),
			new Vec3(1.323258, 0.0, 3.010870),
			new Vec3(-1.608052, 3.022507, 2.877942),
			new Vec3(-1.099877, 0.0, 3.161024),
			new Vec3(-3.662777, 3.022507, 1.077899),
			new Vec3(2.374307, 3.022508, -2.386338),
			new Vec3(3.720232, 0.0, 0.015368),
			new Vec3(4.612177, 0.0, 1.960627),
			new Vec3(3.940414, 3.022507, -0.806799),
			new Vec3(2.828287, 0.0, -1.929892),
			new Vec3(-2.977680, 0.0, 1.572598),
			new Vec3(-2.412147, 3.022507, -0.474309),
			new Vec3(-1.931661, 3.022507, -1.070660),
			new Vec3(-0.474747, 3.022507, -2.109221),
			new Vec3(0.933918, 0.0, -0.787101)]
		);*/
		
		var rb:RigidBody = OimoUtils.addRigidBody(oimoworld, new Vec3(pos.x, pos.y, pos.z), geom, RigidBodyType.STATIC);
		rb.getShapeList().setFriction(1);
		//rb.setRotationXyz(new Vec3(0, Math.PI, 0));
		
		meshlist.push(newmesh);
		view.scene.addChild(newmesh);

		return newmesh;
	}

	public function cleanup() {}
}
