import away3d.cameras.Camera3D;
import away3d.primitives.CubeGeometry;
import away3d.primitives.CapsuleGeometry;
import away3d.primitives.CylinderGeometry;
import oimo.collision.geometry.SphereGeometry;
import oimo.common.Mat3;
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

@:access(OimoUtils)
@:access(Level)
class PlayerFPSController{
	final TANK_CONTROLS:Bool = true;
	
	final linearSpeed:Float = 6;
	final rotationspeed:Float = 3;
	final capsuleheight:Float = 7;
	
	final friction:Float = 0.5;
	
	var direction:Vec3;
	var forward:Vec3;
	var zero:Vec3;
	
	var level:Level;
	var physicsobject:PhysicsObject;
	
  public function new(pos:Vector3D, _level:Level){
		level = _level;
		
		forward = new Vec3(0, 0, -1);
		direction = new Vec3(0, 0, -1);
		zero = new Vec3(0, 0, 0);
		
		var rigidbodyconfig:RigidBodyConfig = new RigidBodyConfig();
		rigidbodyconfig.type = RigidBodyType.DYNAMIC;
		rigidbodyconfig.position = new Vec3(pos.x, pos.y, pos.z);
		
		var playerbody = new RigidBody(rigidbodyconfig);
		playerbody.setOrientation(new Quat(0, 0, 0, 1));
		
		var shapeconfig:ShapeConfig = new ShapeConfig();
		shapeconfig.geometry = new oimo.collision.geometry.CapsuleGeometry(3, capsuleheight / 2);
		shapeconfig.friction = friction;
		
		var playershape = new Shape(shapeconfig);
		playerbody.addShape(playershape);
		playerbody.setRotationFactor(new Vec3(0, 1, 0));
		playerbody.setAngularDamping(10);
		
		level.oimoworld.addRigidBody(playerbody);
		
		var capsulematerial:ColorMaterial = new ColorMaterial(0xFF0000);
		capsulematerial.lightPicker = level.lightpicker;
		
		var newcapsule:Mesh = new Mesh(new away3d.primitives.CapsuleGeometry(3, capsuleheight), capsulematerial);
		newcapsule.position = pos;
		
		level.meshlist.push(newcapsule);
		level.view.scene.addChild(newcapsule);
		
		OimoUtils.oimoDynamicBodies.push(playerbody);
		OimoUtils.awayDynamicBodies.push(newcapsule);
		
		physicsobject = new PhysicsObject(newcapsule, playerbody);
  }
	
	public function update(){
		physicsobject.rigidbody.setRotationFactor(zero);
		
		if (Input.action_pressed(InputActions.MOVE_UP)){
			var vy:Float = physicsobject.rigidbody.getLinearVelocity().y;
			var impulse:Vec3 = new Vec3(direction.x * linearSpeed, vy, direction.z * linearSpeed);
			physicsobject.rigidbody.setLinearVelocity(impulse);
		}else if (Input.action_pressed(InputActions.MOVE_DOWN)){
			var vy:Float = physicsobject.rigidbody.getLinearVelocity().y;
			var impulse:Vec3 = new Vec3(-direction.x * linearSpeed, vy, -direction.z * linearSpeed);
			physicsobject.rigidbody.setLinearVelocity(impulse);
		}
		
		if(TANK_CONTROLS){
			if (Input.action_pressed(InputActions.MOVE_LEFT)){
				var newrotation:Mat3 = physicsobject.rigidbody.getRotation().appendRotation((Math.PI / 180) * -rotationspeed, 0, 1, 0);
				physicsobject.rigidbody.setRotation(newrotation);
			}else if (Input.action_pressed(InputActions.MOVE_RIGHT)){
				var newrotation:Mat3 = physicsobject.rigidbody.getRotation().appendRotation((Math.PI / 180) * rotationspeed, 0, 1, 0);
				physicsobject.rigidbody.setRotation(newrotation);
			}
		}
		
		direction = transformQuat(forward, physicsobject.rigidbody.getOrientation());
	}
	
	public function updatecamera(camera:Camera3D){
		//Set the camera position to the top of the RigidBody
		var pos:Vec3 = physicsobject.rigidbody.getPosition();
		camera.x = pos.x;
		camera.y = pos.y + (capsuleheight / 3);
		camera.z = pos.z;
		
		var lookat:Vector3D = new Vector3D(pos.x + direction.x, pos.y + direction.y + (capsuleheight / 3), pos.z + direction.z);
		camera.lookAt(lookat);
	}
	
	//I found this function in glMatrix, couldn't figure out how to
	//do it with the built in Oimo math class, might remove it later
	static var qx:Float; static var qy:Float;	static var qz:Float;
	static var qw:Float; static var w2:Float;
	static var ax:Float; static var ay:Float; static var az:Float;
	static var uvx:Float; static var uvy:Float; static var uvz:Float;
	static var uuvx:Float; static var uuvy:Float; static var uuvz:Float;
	static function transformQuat(a:Vec3, q:Quat):Vec3{
		qx = q.x;	qy = q.y;	qz = q.z; qw = q.w;
		ax = a.x;	ay = a.y;	az = a.z;
		
		uvx = (qy * az) - (qz * ay);
		uvy = (qz * ax) - (qx * az);
		uvz = (qx * ay) - (qy * ax);
		
		uuvx = (qy * uvz) - (qz * uvy);
		uuvy = (qz * uvx) - (qx * uvz);
		uuvz = (qx * uvy) - (qy * uvx);
		
		w2 = qw * 2;
		uvx *= w2; uvy *= w2;	uvz *= w2;
		uuvx *= 2; uuvy *= 2;	uuvz *= 2;
		
		return new Vec3(ax + uvx + uuvx, ay + uvy + uuvy, az + uvz + uuvz);
	}
	
	public function cleanup() {}
}