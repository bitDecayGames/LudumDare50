package entities;

import nape.phys.BodyType;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;

class Table extends PhysicsThing {
	public var items:Array<PhysicsThing> = [];

	private var picklist = [
		new ThingDef(AssetPaths.SBowl__png, AssetPaths.SBowlBody__png),
		new ThingDef(AssetPaths.MBowl__png, AssetPaths.MBowlBody__png),
		new ThingDef(AssetPaths.LBowl__png, AssetPaths.LBowlBody__png),
		new ThingDef(AssetPaths.SPlate__png, AssetPaths.SPlateBody__png),
		new ThingDef(AssetPaths.MPlate__png, AssetPaths.MPlateBody__png),
		new ThingDef(AssetPaths.LPlate__png, AssetPaths.LPlateBody__png),
		new ThingDef(AssetPaths.fork__png, AssetPaths.forkBody__png),
		new ThingDef(AssetPaths.knife__png, AssetPaths.knifeBody__png),
		new ThingDef(AssetPaths.spoon__png, AssetPaths.spoonBody__png),
		new ThingDef(AssetPaths.Martini__png, AssetPaths.MartiniBody__png),
		new ThingDef(AssetPaths.Pint__png, AssetPaths.PintBody__png),
		new ThingDef(AssetPaths.RoundMug__png, AssetPaths.RoundMugBody__png),
		new ThingDef(AssetPaths.Shot__png, AssetPaths.ShotBody__png),
		new ThingDef(AssetPaths.SquareMug__png, AssetPaths.SquareMugBody__png),
		new ThingDef(AssetPaths.Stein__png, AssetPaths.SteinBody__png),
		new ThingDef(AssetPaths.Tall__png, AssetPaths.TallBody__png)
	];

	public function new(thingCount:Int) {
		super(500, 500, AssetPaths.table__png, AssetPaths.tableBody__png, BodyType.KINEMATIC);

		for (i in 0...thingCount) {
			var assets = getRandomThing();
			var iX = FlxG.random.float(x - width / 2, x + width / 2);
			var iY = FlxG.random.float(y - height / 2 - 100, y - height / 2 - 50);
			items.push(new PhysicsThing(iX, iY, assets.img, assets.collisions));
		}
	}

	private function getRandomThing():ThingDef {
		return picklist[FlxG.random.int(0, picklist.length - 1)];
	}
}

class ThingDef {
	public var img:FlxGraphicAsset;
	public var collisions:FlxGraphicAsset;

	public function new(img:FlxGraphicAsset, collisions:FlxGraphicAsset) {
		this.img = img;
		this.collisions = collisions;
	}
}
