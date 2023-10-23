package radiosilence;

import away3d.containers.*;
import away3d.entities.*;
import away3d.primitives.*;
import away3d.utils.*;
import away3d.library.Asset3DLibrary;
import away3d.loaders.parsers.AWDParser;
import away3d.events.Asset3DEvent;
import away3d.library.assets.IAsset;
import away3d.library.assets.Asset3DType;
import openfl.Assets;
import openfl.geom.Vector3D;
import away3d.tools.commands.Explode;
import haxe.Constraints.Function;

class MeshLibrary{
	static var meshlist:Map<String, Mesh>;
	static var explode:Explode;
	static var oncomplete:Function;
	
	public static function load(list:Array<String>, _oncomplete:Function){
		oncomplete = _oncomplete;
		explode = new Explode();
		
		meshlist = new Map<String, Mesh>();
		
		Asset3DLibrary.enableParser(AWDParser);
		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
		for (m in list){
			meshlist.set(m, null);
			Asset3DLibrary.loadData(Assets.getBytes("data/models/" + m + ".awd"));
		}
	}
	
	public static function getmesh(meshname:String):Mesh{
		return meshlist.get(meshname);
	}
	
	public static function onAssetComplete(event:Asset3DEvent){
		var asset:IAsset = event.asset;
		
		switch (asset.assetType){
			case Asset3DType.MESH :
				var mesh:Mesh = cast(asset, Mesh);
				explode.apply(mesh.geometry, false);
				meshlist.set(event.assetPrevName, mesh);
				checkifcomplete();
			case Asset3DType.MATERIAL:
				//var material:TextureMaterial = cast(asset, TextureMaterial);
		}
	}
	
	static function checkifcomplete(){
		for (k in meshlist.keys()){
			if (meshlist.get(k) == null) return;
		}
		
		oncomplete();
	}
}