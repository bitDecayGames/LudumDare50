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

	// public static var picklist = [
	// 	new ThingDef(AssetPaths.SBowl__png),
	// 	new ThingDef(AssetPaths.MBowl__png),
	// 	new ThingDef(AssetPaths.LBowl__png),
	// 	new ThingDef(AssetPaths.SPlate__png),
	// 	new ThingDef(AssetPaths.MPlate__png),
	// 	new ThingDef(AssetPaths.LPlate__png),
	// 	new ThingDef(AssetPaths.fork__png),
	// 	new ThingDef(AssetPaths.knife__png),
	// 	new ThingDef(AssetPaths.spoon__png),
	// 	new ThingDef(AssetPaths.Martini__png),
	// 	new ThingDef(AssetPaths.Pint__png),
	// 	new ThingDef(AssetPaths.RoundMug__png),
	// 	new ThingDef(AssetPaths.Shot__png),
	// 	new ThingDef(AssetPaths.SquareMug__png),
	// 	new ThingDef(AssetPaths.Stein__png),
	// 	new ThingDef(AssetPaths.Tall__png)
	// 	new ThingDef(AssetPaths.Wine__png),
	// 	new ThingDef(AssetPaths.wineGlass__png)
	// ];
	private var removed:Bool = false;
	private var removePosition = new Vec2(1500, 0);
	private var deleteBuffer:Float = 10;

	public function new(x:Float, y:Float) {
		super(x, y, AssetPaths.table__png, BodyType.KINEMATIC);
		removePosition.y = y;
		spawnThings();
	}

	override public function update(delta:Float) {
		super.update(delta);

		// output item nums
		for (i in 0...items.length) {
			if (i >= 0) {
				var absolutePos = new Vec2(items[i].body.position.x - body.position.x, items[i].body.position.y - (body.position.y - 85));
				FlxG.watch.addQuick('item#${i}', absolutePos);
			}
		}

		if (numItems > 0) {
			numItems = 0;
			for (i in items) {
				if (i.x >= body.position.x - (body.bounds.width / 2)
					&& i.x <= body.position.x + (body.bounds.width / 2)
					&& i.y <= body.position.y - (body.bounds.height / 2)
					&& i.active) {
					numItems++;
				}
			}
		} else if (!removed) {
			removed = true;
			removeTable();
		} else {
			if (body.position.x >= removePosition.x - deleteBuffer) {
				kill();
				destroy();
				active = false;
			}
		}
	}

	function removeTable() {
		body.setVelocityFromTarget(removePosition, 0, 0.5);
	}

	private function spawnThings() {
		var configuration = getRandomConfiguration();

		for (thingDef in configuration.things) {
			var thing = thingDef.toPhysicsThing(body.position.x, body.position.y - 85);
			items.push(thing);

			// Turn items off initially because table spawns and then moves. Thigns are turned on later.
			thing.body.allowMovement = false;
			thing.body.allowRotation = false;
			numItems++;
		}
	}

	private function getRandomConfiguration():TableConfiguration {
		return tableConfigurations[FlxG.random.int(0, tableConfigurations.length - 1)];
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

	public function moveMeAndMyPets(targetPosition:Vec2, targetRotation:Float, deltaTime:Float) {
		body.setVelocityFromTarget(targetPosition, targetRotation, deltaTime);
		for (pet in items) {
			if (pet.body != null) {
				var petTarget:Vec2 = new Vec2(targetPosition.x + (pet.body.position.x - body.position.x), pet.body.position.y);
				pet.body.setVelocityFromTarget(petTarget, targetRotation, deltaTime);
			}
		}
	}

	public function reactivateMeAndMyPets() {
		body.velocity.set(new Vec2());
		for (pet in items) {
			if (pet.body != null) {
				pet.body.velocity.set(new Vec2());
				pet.body.allowMovement = true;
				pet.body.allowRotation = true;
				pet.body.disableCCD = false;
			}
		}
	}

	private var tableConfigurations = [
		new TableConfiguration([
			new ThingDef(-140, 0, AssetPaths.SBowl__png),
			new ThingDef(-10, 0, AssetPaths.MBowl__png),
			new ThingDef(155, 0, AssetPaths.LBowl__png),
			new ThingDef(-85, -33, AssetPaths.Martini__png),
			new ThingDef(62, -33, AssetPaths.Martini__png),
			new ThingDef(-53, -105, AssetPaths.fork__png),
			new ThingDef(176, -33, AssetPaths.knife__png),
			new ThingDef(107, -105, AssetPaths.spoon__png),
		]),
		new TableConfiguration([
			new ThingDef(148, 16, AssetPaths.MPlate__png),
			new ThingDef(-2, 16, AssetPaths.MPlate__png),
			new ThingDef(-137, 16, AssetPaths.MPlate__png),
			new ThingDef(-134, -26, AssetPaths.RoundMug__png),
			new ThingDef(10, -25, AssetPaths.RoundMug__png),
			new ThingDef(165, -57, AssetPaths.Stein__png),
			new ThingDef(-65, -69, AssetPaths.LPlate__png),
			new ThingDef(-120, -97, AssetPaths.Shot__png),
			new ThingDef(-66, -97, AssetPaths.Shot__png),
			new ThingDef(-7, -96, AssetPaths.Shot__png),
			new ThingDef(-65, -129, AssetPaths.fork__png),
			new ThingDef(133, -137, AssetPaths.fork__png)
		]) // new TableConfiguration([])
	];
}

class TableConfiguration {
	public var things:Array<ThingDef>;

	public function new(things:Array<ThingDef>) {
		this.things = things;
	}
}

class ThingDef {
	public var x:Float;
	public var y:Float;
	public var img:FlxGraphicAsset;
	public var material:Null<Material>;

	public function new(x:Float, y:Float, img:FlxGraphicAsset, ?material:Material) {
		this.x = x;
		this.y = y;
		this.img = img;
		this.material = material;
	}

	public function toPhysicsThing(offsetX:Float, offsetY:Float):PhysicsThing {
		return new PhysicsThing(x + offsetX, y + offsetY, img, BodyType.DYNAMIC, material);
	}
}
