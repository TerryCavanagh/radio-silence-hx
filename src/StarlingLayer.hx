import starling.display.Quad;
import starling.display.Sprite;

class StarlingLayer extends Sprite {
	private static var _instance:StarlingLayer;

	public static function getInstance():StarlingLayer {
		return _instance;
	}

	private var testquad:Quad;

	public function new() {
		super();
		_instance = this;
		addEventListener(starling.events.Event.ADDED_TO_STAGE, onadded);
	}

	function onadded(_) {
		removeEventListener(starling.events.Event.ADDED_TO_STAGE, onadded);
		testquad = new Quad(500, 500, 0xFFFF0000);
		//addChild(testquad);
		testquad.alignPivot();
		testquad.x = 1280/2;
		testquad.y = 720/2;
	}

	public function update() {
		if (testquad == null) {
			return;
		}
		testquad.rotation += 0.005;
	}
}
