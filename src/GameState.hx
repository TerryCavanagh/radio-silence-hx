import away3d.containers.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.utils.*;
import away3d.library.Asset3DLibrary;
import away3d.loaders.parsers.AWDParser;
import away3d.events.Asset3DEvent;
import away3d.library.assets.IAsset;
import away3d.library.assets.Asset3DType;
import openfl.Assets;
import openfl.geom.Vector3D;

class GameState{
	var view:View3D;
	var plane:Mesh;
	
	var island1:Mesh = null;
	
	public function new(_view:View3D){
		view = _view;
		
		Asset3DLibrary.enableParser(AWDParser);
		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
		Asset3DLibrary.loadData(Assets.getBytes('data/models/island1.awd'));
		
		//setup the scene
		plane = new Mesh(new PlaneGeometry(700, 700), new TextureMaterial(Cast.bitmapTexture("data/floor_diffuse.jpg")));
		//view.scene.addChild(plane);
	}
	
	private function onAssetComplete(event:Asset3DEvent){
		var asset:IAsset = event.asset;
		
		switch (asset.assetType){
			case Asset3DType.MESH :
				var mesh:Mesh = cast(asset, Mesh);
				mesh.scale(20);
				mesh.material = new ColorMaterial(0xFFFFFF);
				
				island1 = mesh;
				view.scene.addChild(mesh);
			case Asset3DType.MATERIAL:
				//var material:TextureMaterial = cast(asset, TextureMaterial);
		}
	}
	
	public function update(){
		if(island1 != null){
			island1.rotationY += 1;
		}
	}
	
	public function cleanup(){
		
	}
}