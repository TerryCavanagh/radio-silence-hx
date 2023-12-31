package radiosilence;

import openfl.geom.Vector3D;
import away3d.cameras.Camera3D;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import oimo.dynamics.rigidbody.RigidBody;
import oimo.dynamics.callback.RayCastClosest;
import oimo.dynamics.rigidbody.RigidBodyConfig;
import oimo.dynamics.rigidbody.RigidBodyType;
import oimo.dynamics.rigidbody.Shape;
import oimo.dynamics.rigidbody.ShapeConfig;
import oimo.common.Vec3;
import oimo.common.Mat3;
import oimo.common.Quat;
import oimo.dynamics.World;

@:access(OimoUtils)
@:access(radiosilence.Level)
class PlayerFPSController{
	public var position:Vector3D;
	public var playercamera:Camera3D;
	public var mouselock:Bool;
	
	final linearSpeed:Float = 1;
	final capsuleheight:Float = 2;
	final capsuleradius:Float = 0.4;
	final maxcoyoteframes:Int = 6;
	final maxjumpbuffer:Int = 3;
	final jumpstrength:Float = 2.5;
	
	var applyjump:Bool = false;
	var coyoteframes:Int = 0;
	var jumpbuffer:Int = 0;
	var ismoving:Bool = false;
	
	var lookat:Vector3D;
	var direction:Vec3;
	var forward:Vec3;
	var zero:Vec3;
	var perpendicular:Vec3;
	var impulse:Vec3;
	var tempvec3:Vec3; 
	
	var headtilt:Float;
	var mousesensitivity:Float;
	
	var level:Level;
	var player_rigidbody:RigidBody;
	
	var raycast:RayCastClosest;
	var raycastbegin:Vec3;
	var raycastend:Vec3;
	var floordistance:Array<Float>;
	final raycastlength:Float = 0.5;
	
	var footsteps:AudioID = null;
	var footstepsplaying:Bool = false;
	var footstepdelay:Int = 0;
	final footstepspeed:Int = 156; //2.6 seconds * 60 frames
	
  public function new(pos:Vector3D, _camera:Camera3D, _level:Level){
		playercamera = _camera;
		level = _level;
		
		position = new Vector3D(pos.x, pos.y, pos.z);
		lookat = new Vector3D(0, 0, 0);
		forward = new Vec3(0, 0, -1);
		direction = new Vec3(0, 0, -1);
		zero = new Vec3(0, 0, 0);
		perpendicular = new Vec3(0, 0, 0);
		impulse = new Vec3(0, 0, 0);
		raycastbegin = new Vec3(0, 0, 0);
		raycastend = new Vec3(0, 0, 0);
		tempvec3 = new Vec3(0, 0, 0);
		
		headtilt = -26;
		mousesensitivity = 0.3;
		ismoving = false;
		
		mouselock = false;
		applyjump = false;
		coyoteframes = 0;
		jumpbuffer = 0;
		
		var rigidbodyconfig:RigidBodyConfig = new RigidBodyConfig();
		rigidbodyconfig.type = RigidBodyType.DYNAMIC;
		rigidbodyconfig.position = new Vec3(pos.x, pos.y, pos.z);
		
		player_rigidbody = new RigidBody(rigidbodyconfig);
		player_rigidbody.setOrientation(new Quat(0, 0, 0, 1));
		
		var shapeconfig:ShapeConfig = new ShapeConfig();
		shapeconfig.geometry = new oimo.collision.geometry.CapsuleGeometry(capsuleradius, capsuleheight / 2);
		shapeconfig.friction = 0.5;
		shapeconfig.restitution = 0.0; //No bouncing!
		
		var playershape = new Shape(shapeconfig);
		player_rigidbody.addShape(playershape);
		player_rigidbody.setRotationFactor(new Vec3(0, 1, 0));
		player_rigidbody.setAngularDamping(10);
		level.oimoworld.addRigidBody(player_rigidbody);
		
		raycast = new RayCastClosest();
		floordistance = [0, 0, 0, 0, 0, 0, 0, 0];
  }
	
	public function update(){
		checkraycast();
		player_rigidbody.setRotationFactor(zero);
		
		if (onground()){
			//if (physicsobject.rigidbody.getShapeList().getFriction() == 0) trace("Friction ON");
			player_rigidbody.getShapeList().setFriction(1.0);
		}else{
			//if (physicsobject.rigidbody.getShapeList().getFriction() == 1.0) trace("Friction OFF");
			player_rigidbody.getShapeList().setFriction(0.0);
		}
		
		if(mouselock){
			headtilt += Mouse.deltay * mousesensitivity;
			if (headtilt < -65) headtilt = -65;
			if (headtilt > 65) headtilt = 65;
		}
		
		if(Mouse.deltax != 0 && mouselock){
			var newrotation:Mat3 = player_rigidbody.getRotation().appendRotation((Math.PI / 180) * (Mouse.deltax * mousesensitivity), 0, 1, 0);
			player_rigidbody.setRotation(newrotation);
		}
		
		direction = transformQuat(forward, player_rigidbody.getOrientation());
		perpendicular.x = direction.z;
		perpendicular.z = -direction.x;
		
		var vy:Float = player_rigidbody.getLinearVelocity().y;
		impulse.x = 0; impulse.y = vy; impulse.z = 0;
		ismoving = false;
		if (Input.action_pressed(InputActions.MOVE_UP)){
			ismoving = true;
			impulse.x += direction.x;
			impulse.z += direction.z;
		}
		
		if (Input.action_pressed(InputActions.MOVE_DOWN)){
			ismoving = true;
			impulse.x += -direction.x;
			impulse.z += -direction.z;
		}
		
		if (Input.action_pressed(InputActions.MOVE_LEFT)){
			ismoving = true;
			impulse.x += -perpendicular.x;
			impulse.z += -perpendicular.z;
		}
		
		if (Input.action_pressed(InputActions.MOVE_RIGHT)){
			ismoving = true;
			impulse.x += perpendicular.x;
			impulse.z += perpendicular.z;
		}
		
		if (ismoving && !onground()) ismoving = false;
		if (ismoving && position.y <= 1) ismoving = false;
		
		if (ismoving){
			if (!footstepsplaying){
				footsteps = AudioManager.play(SoundAssets.footsteps);
				footstepsplaying = true;
				footstepdelay = footstepspeed;
			}
		}else{
			if (footstepsplaying){
				footsteps.stop();
				footstepsplaying = false;
			}
		}
		
		if (footstepsplaying){
			footstepdelay--;
			if (footstepdelay <= 0){
				footstepdelay = footstepspeed;
				footsteps.stop();
				footsteps = AudioManager.play(SoundAssets.footsteps);
			}
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
		
		player_rigidbody.setLinearVelocity(impulse);
	}
	
	public function stop(){
		player_rigidbody.setLinearVelocity(zero);
		
		if (footstepsplaying){
			footsteps.stop();
			footstepsplaying = false;
		}
	}
	
	public function updatecamera(camera:Camera3D){
		playercamera = camera;
		//Set the camera position to the top of the RigidBody
		tempvec3 = player_rigidbody.getPosition();
		position.setTo(tempvec3.x, tempvec3.y, tempvec3.z);
		
		camera.x = tempvec3.x;
		camera.y = tempvec3.y + (capsuleheight / 2);
		camera.z = tempvec3.z;
		
		lookat.setTo(tempvec3.x + direction.x, tempvec3.y + direction.y + (capsuleheight / 3), tempvec3.z + direction.z);
		camera.lookAt(lookat);
		camera.rotate(Vector3D.X_AXIS, headtilt);
	}
	
	function checkraycast(){
		for(i in 0 ... 8){
			raycast.clear();
			raycastbegin.copyFrom(player_rigidbody.getPosition());
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
		}
		
		if (onground_canjump()){
			coyoteframes = maxcoyoteframes;
		}else{
			coyoteframes--;
			if (coyoteframes < 0) coyoteframes = 0;
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
			if(onground_canjump() || coyoteframes > 0){
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
	
	public function onground_canjump():Bool{
		numtouches = 0;
		for (i in 0 ... 8){
			if (floordistance[i] < raycastlength){
				numtouches++;
			}
		}
		if (numtouches >= 1) return true;
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
	
	public function cleanup() {
		
	}
}