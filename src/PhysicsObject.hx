import away3d.entities.Mesh;
import oimo.common.Vec3;
import oimo.dynamics.rigidbody.RigidBody;

/* Simple class to contain both Away3D mesh and Oimo physics body in one place */
class PhysicsObject{
	public var mesh:Mesh;
	public var rigidbody:RigidBody;
	
	var vector:Vec3;
	var zero:Vec3;
	
	public function new(_away3dmesh:Mesh, _oimophysics:RigidBody){
		mesh = _away3dmesh;
		rigidbody = _oimophysics;
		
		vector = new Vec3(0, 0, 0);
		zero = new Vec3(0, 0, 0);
	}
	
	//OimoUtils updates the mesh position of Dynamic Rigid Bodies; if you change
	//the position or rotation of a static one, you need to update it yourself
	public function updatemeshposition(){
		var tmpVec3_0:Vec3 = new Vec3();
		tmpVec3_0 = rigidbody.getTransform().getRotation().toEulerXyz();
		mesh.moveTo(rigidbody.getPosition().x, rigidbody.getPosition().y, rigidbody.getPosition().z);
		//RadToDeg = 57.295
		mesh.transform.appendRotation(tmpVec3_0.x * 57.295, mesh.rightVector, mesh.position);
		mesh.transform.appendRotation(tmpVec3_0.y * 57.295, mesh.upVector, mesh.position);
		mesh.transform.appendRotation(tmpVec3_0.z * 57.295, mesh.forwardVector, mesh.position);
	}
	
	public function move(xforce:Float, yforce:Float, zforce:Float){
		vector.x = xforce;
		vector.y = yforce;
		vector.z = zforce;
		
		rigidbody.setLinearVelocity(vector);
		rigidbody.setAngularVelocity(zero);
	}
	
	public function stop(){
		vector.x = 0;
		vector.y = 0;
		vector.z = 0;
		
		rigidbody.setLinearVelocity(zero);
		rigidbody.setAngularVelocity(zero);
	}
}