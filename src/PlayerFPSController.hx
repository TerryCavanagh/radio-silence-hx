import away3d.cameras.Camera3D;
import away3d.primitives.CubeGeometry;
import away3d.primitives.CapsuleGeometry;
import away3d.primitives.CylinderGeometry;
import oimo.collision.geometry.SphereGeometry;
import oimo.common.Mat3;
import oimo.common.Quat;
import oimo.dynamics.callback.RayCastClosest;
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
	final linearSpeed:Float = 1;
	final capsuleheight:Float = 2;
	final capsuleradius:Float = 0.4;
	final maxcoyoteframes:Int = 6;
	final maxjumpbuffer:Int = 3;
	
	final jumpstrength:Float = 3;
	var applyjump:Bool = false;
	var coyoteframes:Int = 0;
	var jumpbuffer:Int = 0;
	
	public var mouselock:Bool;
	
	var direction:Vec3;
	var forward:Vec3;
	var zero:Vec3;
	var perpendicular:Vec3;
	var impulse:Vec3;
	
	var headtilt:Float;
	var mousesensitivity:Float;
	
	var level:Level;
	var physicsobject:PhysicsObject;
	
	var raycastvisual:Array<Mesh> = [];
	var raycast:RayCastClosest;
	var raycastbegin:Vec3;
	var raycastend:Vec3;
	var floordistance:Array<Float>;
	final raycastlength:Float = 0.5;
	var red:ColorMaterial;
	var green:ColorMaterial;
	
  public function new(pos:Vector3D, _level:Level){
		level = _level;
		
		forward = new Vec3(0, 0, -1);
		direction = new Vec3(0, 0, -1);
		zero = new Vec3(0, 0, 0);
		perpendicular = new Vec3(0, 0, 0);
		impulse = new Vec3(0, 0, 0);
		raycastbegin = new Vec3(0, 0, 0);
		raycastend = new Vec3(0, 0, 0);
		
		headtilt = 0;
		mousesensitivity = 0.3;
		
		mouselock = false;
		applyjump = false;
		coyoteframes = 0;
		jumpbuffer = 0;
		
		red = new ColorMaterial(0xFF0000);
		green = new ColorMaterial(0x00FF00);
		
		var rigidbodyconfig:RigidBodyConfig = new RigidBodyConfig();
		rigidbodyconfig.type = RigidBodyType.DYNAMIC;
		rigidbodyconfig.position = new Vec3(pos.x, pos.y, pos.z);
		
		var playerbody = new RigidBody(rigidbodyconfig);
		playerbody.setOrientation(new Quat(0, 0, 0, 1));
		
		var shapeconfig:ShapeConfig = new ShapeConfig();
		shapeconfig.geometry = new oimo.collision.geometry.CapsuleGeometry(capsuleradius, capsuleheight / 2);
		shapeconfig.friction = 0.5;
		shapeconfig.restitution = 0.0; //No bouncing!
		
		var playershape = new Shape(shapeconfig);
		playerbody.addShape(playershape);
		playerbody.setRotationFactor(new Vec3(0, 1, 0));
		playerbody.setAngularDamping(10);
		
		level.oimoworld.addRigidBody(playerbody);
		
		var capsulematerial:ColorMaterial = new ColorMaterial(0xFF0000);
		capsulematerial.lightPicker = level.lightpicker;
		
		var newcapsule:Mesh = new Mesh(new away3d.primitives.CapsuleGeometry(capsuleradius, capsuleheight), capsulematerial);
		newcapsule.position = pos;
		
		level.meshlist.push(newcapsule);
		level.view.scene.addChild(newcapsule);
		
		raycastvisual = [];
		for (i in 0 ... 8){
			var rc:Mesh = new Mesh(new away3d.primitives.CubeGeometry(0.05, raycastlength + (capsuleheight / 2), 0.05), new ColorMaterial(0xFFFF00));
			rc.position = new Vector3D(
				pos.x + (capsuleradius * Math.cos((Math.PI * 2 * i) / 8)),
				pos.y,
				pos.z + (capsuleradius * Math.sin((Math.PI * 2 * i) / 8)));
			level.meshlist.push(rc);
			level.view.scene.addChild(rc);
			
			raycastvisual.push(rc);
		}
		
		OimoUtils.oimoDynamicBodies.push(playerbody);
		OimoUtils.awayDynamicBodies.push(newcapsule);
		
		raycast = new RayCastClosest();
		floordistance = [0, 0, 0, 0, 0, 0, 0, 0];
		
		physicsobject = new PhysicsObject(newcapsule, playerbody);
  }
	
	public function update(){
		checkraycast();
		physicsobject.rigidbody.setRotationFactor(zero);
		
		if (onground()){
			//if (physicsobject.rigidbody.getShapeList().getFriction() == 0) trace("Friction ON");
			physicsobject.rigidbody.getShapeList().setFriction(1.0);
		}else{
			//if (physicsobject.rigidbody.getShapeList().getFriction() == 1.0) trace("Friction OFF");
			physicsobject.rigidbody.getShapeList().setFriction(0.0);
		}
		
		if(mouselock){
			headtilt += Mouse.deltay * mousesensitivity;
			if (headtilt < -70) headtilt = -70;
			if (headtilt > 70) headtilt = 70;
		}
		
		if(Mouse.deltax != 0 && mouselock){
			var newrotation:Mat3 = physicsobject.rigidbody.getRotation().appendRotation((Math.PI / 180) * (Mouse.deltax * mousesensitivity), 0, 1, 0);
			physicsobject.rigidbody.setRotation(newrotation);
		}
		
		direction = transformQuat(forward, physicsobject.rigidbody.getOrientation());
		perpendicular.x = direction.z;
		perpendicular.z = -direction.x;
		
		var vy:Float = physicsobject.rigidbody.getLinearVelocity().y;
		impulse.x = 0; impulse.y = vy; impulse.z = 0;
		if (Input.action_pressed(InputActions.MOVE_UP)){
			impulse.x += direction.x;
			impulse.z += direction.z;
		}
		
		if (Input.action_pressed(InputActions.MOVE_DOWN)){
			impulse.x += -direction.x;
			impulse.z += -direction.z;
		}
		
		if (Input.action_pressed(InputActions.MOVE_LEFT)){
			impulse.x += -perpendicular.x;
			impulse.z += -perpendicular.z;
		}
		
		if (Input.action_pressed(InputActions.MOVE_RIGHT)){
			impulse.x += perpendicular.x;
			impulse.z += perpendicular.z;
		}
		
		vy = impulse.y;
		impulse.y = 0; 
		impulse.normalize();
		impulse.x = impulse.x * linearSpeed;
		impulse.z = impulse.z * linearSpeed;
		impulse.y = vy;
		
		if (applyjump){
			impulse.y = jumpstrength;
			applyjump = false;
		}
		
		physicsobject.rigidbody.setLinearVelocity(impulse);
		
		//Update raycast visuals
		for (i in 0 ... 8){
			raycastvisual[i].moveTo(
				physicsobject.mesh.position.x  + (capsuleradius * Math.cos((Math.PI * 2 * i) / 8)),
				physicsobject.mesh.position.y - ((capsuleheight / 2) + (raycastlength / 2)),
				physicsobject.mesh.position.z + (capsuleradius * Math.sin((Math.PI * 2 * i) / 8))
			);
			
			if (floordistance[i] < raycastlength){
				raycastvisual[i].material = green;
			}else{
				raycastvisual[i].material = red;
			}
		}
	}
	
	public function updatecamera(camera:Camera3D){
		//Set the camera position to the top of the RigidBody
		var pos:Vec3 = physicsobject.rigidbody.getPosition();
		camera.x = pos.x;
		camera.y = pos.y + (capsuleheight / 2);
		camera.z = pos.z;
		
		var lookat:Vector3D = new Vector3D(pos.x + direction.x, pos.y + direction.y + (capsuleheight / 3), pos.z + direction.z);
		camera.lookAt(lookat);
		camera.rotate(Vector3D.X_AXIS, headtilt);
		
		camera.moveBackward(20);
		camera.moveUp(2);
	}
	
	function checkraycast(){
		for(i in 0 ... 8){
			raycast.clear();
			raycastbegin.copyFrom(physicsobject.rigidbody.getPosition());
			raycastbegin.x += capsuleradius * Math.cos((Math.PI * 2 * i) / 8);
			raycastbegin.y -= (capsuleheight / 2);
			raycastbegin.z += capsuleradius * Math.sin((Math.PI * 2 * i) / 8);
			
			raycastend.copyFrom(raycastbegin);
			raycastend.y -= raycastlength;
			
			level.oimoworld.rayCast(raycastbegin, raycastend, raycast);
			
			if (raycast.hit){
				floordistance[i] = raycastbegin.sub(raycast.position).y;
			}else{
				floordistance[i] = 100000;
			}
			
			if (onground()){
				coyoteframes = maxcoyoteframes;
			}else{
				coyoteframes--;
				if (coyoteframes < 0) coyoteframes = 0;
			}
		}
	}
	
	var pressedjump:Bool;
	public function checkjump(){
		pressedjump = false;
		if (Input.action_justpressed(InputActions.JUMP)) {
			jumpbuffer = maxjumpbuffer;
			pressedjump = true;
		}else{
			if (jumpbuffer > 0){
				jumpbuffer--;
				pressedjump = true;
			}
		}
		
		if (pressedjump){
			if(onground() || coyoteframes > 0){
				applyjump = true;
				jumpbuffer = 0;
			}
		}
	}
	
	var numtouches:Int;
	public function onground():Bool{
		numtouches = 0;
		for (i in 0 ... 8){
			if (floordistance[i] < raycastlength){
				numtouches++;
			}
		}
		if (numtouches >= 4) return true;
		return false;
	}
	
	public function lockmouse(){
		Mouse.hide(); Mouse.capturecursor = true;
		mouselock = true;
	}
	
	public function unlockmouse(){
		Mouse.show(); Mouse.capturecursor = false;
		mouselock = false;
	}
	
	//Found this function in glMatrix
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