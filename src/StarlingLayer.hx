import starling.display.Quad;
import starling.display.Sprite;

class StarlingLayer extends Sprite{
	private static var _instance:StarlingLayer;
	
	public static function getInstance():StarlingLayer{
		return _instance;
	}
	
	private var testquad:Quad;
	
	public function StarlingLayer(){
		_instance = this;
		
		testquad = new Quad(500, 500, 0xFF0000);
		addChild(testquad);
	}
	
	public function update(){
		//testquad.rotation += 0.005;
	}
}