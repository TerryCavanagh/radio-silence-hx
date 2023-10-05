import away3d.containers.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.utils.*;
import away3d.library.Asset3DLibrary;
import away3d.lights.DirectionalLight;
import away3d.loaders.parsers.AWDParser;
import away3d.events.Asset3DEvent;
import away3d.library.assets.IAsset;
import away3d.library.assets.Asset3DType;
import away3d.materials.lightpickers.StaticLightPicker;
import openfl.Assets;
import openfl.geom.Vector3D;
import away3d.tools.commands.Explode;

class GameState{
	var view:View3D;
	var light:DirectionalLight;
	var lightPicker:StaticLightPicker;
	var plane:Mesh;
	
	var explode:Explode;
	
	var island1:Mesh = null;
	
	public function new(_view:View3D){
		view = _view;
		
		Asset3DLibrary.enableParser(AWDParser);
		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
		Asset3DLibrary.loadData(Assets.getBytes('data/models/island1.awd'));
		
		//setup the scene
		plane = new Mesh(new PlaneGeometry(700, 700), new TextureMaterial(Cast.bitmapTexture("data/floor_diffuse.jpg")));
		//view.scene.addChild(plane);
		
		light = new DirectionalLight();
		light.position = new Vector3D( -46.10107, 41.36791, -44.0853);
		light.direction = new Vector3D(34.01631, 5.832711, 357.2608);
		light.color = 0xFFFFFF;
		light.ambient = 0.4149853;
		view.scene.addChild(light);
		
		explode = new Explode();
		lightPicker = new StaticLightPicker([this.light]);
	}
	
	private function onAssetComplete(event:Asset3DEvent){
		var asset:IAsset = event.asset;
		
		switch (asset.assetType){
			case Asset3DType.MESH :
				var mesh:Mesh = cast(asset, Mesh);
				explode.apply(mesh.geometry, false);
				
				mesh.scale(20);
				mesh.material = new ColorMaterial(0xCCCCCC);
				mesh.material.lightPicker = lightPicker;
				
				island1 = mesh;
				view.scene.addChild(mesh);
			case Asset3DType.MATERIAL:
				//var material:TextureMaterial = cast(asset, TextureMaterial);
		}
	}
	
	public function update(){
		
	}
	
	public function cleanup(){
		
	}
}