package entities;

import js.html.Float32Array;
import nape.phys.Material;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.BodyType;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import nape.geom.Vec2;

class Table extends PhysicsThing {
	public var items:Array<PhysicsThing> = [];
	public var numItems:Int = 0;

	public static var picklist = [
		new ThingDef(AssetPaths.SBowl__png, AssetPaths.SBowlBody__png, 24, 8, true),
		new ThingDef(AssetPaths.MBowl__png, AssetPaths.MBowlBody__png, 24, 8, true),
		new ThingDef(AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 24, 8, true),
		new ThingDef(AssetPaths.SPlate__png, AssetPaths.SPlateBody__png, false),
		new ThingDef(AssetPaths.MPlate__png, AssetPaths.MPlateBody__png, false),
		new ThingDef(AssetPaths.LPlate__png, AssetPaths.LPlateBody__png, false),
		new ThingDef(AssetPaths.fork__png, AssetPaths.forkBody__png, false),
		new ThingDef(AssetPaths.knife__png, AssetPaths.knifeBody__png, false),
		new ThingDef(AssetPaths.spoon__png, AssetPaths.spoonBody__png, false),
		new ThingDef(AssetPaths.Martini__png, AssetPaths.MartiniBody__png, true),
		new ThingDef(AssetPaths.Pint__png, AssetPaths.PintBody__png, 24, 8, true),
		new ThingDef(AssetPaths.RoundMug__png, AssetPaths.RoundMugBody__png, true),
		new ThingDef(AssetPaths.Shot__png, AssetPaths.ShotBody__png, true),
		new ThingDef(AssetPaths.SquareMug__png, AssetPaths.SquareMugBody__png, true),
		new ThingDef(AssetPaths.Stein__png, AssetPaths.SteinBody__png, 24, 8, true),
		new ThingDef(AssetPaths.Tall__png, AssetPaths.TallBody__png, 24, 8, true)
	];

	private var removed:Bool = false;
	private var removePosition = new Vec2(1500, 0);
	private var deleteBuffer:Float = 10;

	public function new(x:Float, y:Float, thingCount:Int) {
		super(x, y, AssetPaths.table__png, AssetPaths.tableBody__png, BodyType.KINEMATIC);
		removePosition.y = y;
		spawnThings(thingCount);
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (numItems > 0) {
			numItems = 0;
			for (i in items) {
				if (i.x >= body.position.x - (body.bounds.width / 2) && i.x <= body.position.x + (body.bounds.width / 2)) {
					numItems++;
				}
			}
		} else if (!removed) {
			removed = true;
			removeTable();
		} else {
			if (body.position.x >= removePosition.x - deleteBuffer) {
				destroy();
			}
		}
	}

	function removeTable() {
		body.setVelocityFromTarget(removePosition, 0, 0.5);
	}

	public function spawnThings(thingCount:Int):Array<PhysicsThing> {
		var madeThings:Array<PhysicsThing> = [];
		var boundingBoxes:Array<AABB> = [];
		for (i in 0...thingCount) {
			var assets = getRandomThing();
			// trace('spawning a ${assets.img}');
			var iX = FlxG.random.float(x - width / 2, x + width / 2);
			var iY = FlxG.random.float(y - height / 2 - 100, y - height / 2 - 50);
			var thing = assets.toPhysicsThing(iX, iY, BodyType.DYNAMIC);
			var aabb = thing.body.bounds;

			// Would rather use Int.max sort of thing here
			var minY = 100000.0;
			var minX = 100000.0;
			for (box in boundingBoxes) {
				// trace('checking our aabb (${aabb}) against other box (${box})');
				if (aabbsOverlap(aabb, box)) {
					// trace('overlap detected');
					minY = Math.min(minY, aabb.y);
					minX = Math.min(minX, aabb.x);

					// trace('new minX: ${minX}, new minY: ${minY}');
				}
			}

			// add our aabb for the other items
			boundingBoxes.push(aabb);

			if (minY != 100000.0 || minX != 100000.0) {
				if (aabb.y - minY < aabb.x - minX) {
					// trace('moving ${assets.img} up ${thing.y - (minY - aabb.height)}');
					thing.body.position.y = minY - aabb.height;
				} else {
					// trace('moving ${assets.img} left ${thing.x - (minX - aabb.width)}');
					thing.body.position.x = minX - aabb.width;
				}
			}

			items.push(thing);
			madeThings.push(thing);
			numItems++;
		}
		return madeThings;
	}

	private function getRandomThing():ThingDef {
		return picklist[FlxG.random.int(0, picklist.length - 1)];
	}

	private function aabbsOverlap(a:AABB, b:AABB):Bool {
		// If one rectangle is on left side of other
		if (a.x >= b.x + b.width || b.x >= a.x + a.width) {
			return false;
		}

		// If one rectangle is above other
		if (a.y >= b.y + b.height || b.y >= a.y + a.height) {
			return false;
		}

		return true;
	}
}

class ThingDef {
	public var img:FlxGraphicAsset;
	public var collisions:FlxGraphicAsset;
	public var cellSize:Float;
	public var subSize:Float;
	public var includeAssetBodyPhysicsShape:Bool;
	public var material:Null<Material>;

	public function new(img:FlxGraphicAsset, collisions:FlxGraphicAsset, cellSize:Float = 10, subSize:Float = 2, includeAssetBodyPhysicsShape:Bool,
			?material:Material) {
		this.img = img;
		this.collisions = collisions;
		this.cellSize = cellSize;
		this.subSize = subSize;
		this.includeAssetBodyPhysicsShape = includeAssetBodyPhysicsShape;
		this.material = material;
	}

	public function toPhysicsThing(x:Float, y:Float, bodyType:BodyType):PhysicsThing {
		return new PhysicsThing(x, y, img, collisions, cellSize, subSize, bodyType, includeAssetBodyPhysicsShape, material);
	}
}
