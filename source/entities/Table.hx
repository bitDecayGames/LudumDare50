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

	private var reactivated:Bool = false;
	private var removed:Bool = false;
	private var spawnLocation:Vec2;
	private var deleteBuffer:Float = 10;

	public function new(x:Float, y:Float) {
		super(x, y, AssetPaths.table__png, BodyType.KINEMATIC);
		spawnLocation = new Vec2(x, y);
		spawnThings();
	}

	override public function update(delta:Float) {
		super.update(delta);

		// // output item nums
		// for (i in 0...items.length) {
		// 	if (i >= 0) {
		// 		var absolutePos = new Vec2(items[i].body.position.x - body.position.x, items[i].body.position.y - (body.position.y - 85));
		// 		FlxG.watch.addQuick('item#${i}', absolutePos);
		// 	}
		// }

		// FlxG.watch.addQuick('num items', numItems);
		// FlxG.watch.addQuick('table position', body.position);
		// FlxG.watch.addQuick('table bounds', body.bounds);

		if (reactivated) {
			numItems = 0;
			for (i in 0...items.length) {
				// FlxG.watch.addQuick('Item#${i}', items[i].body.position);
				if (items[i].x >= body.position.x - (body.bounds.width / 2)
					&& items[i].x <= body.position.x + (body.bounds.width / 2)
					&& items[i].y <= body.position.y - (body.bounds.height / 2)
					&& items[i].exists) {
					numItems++;
				}
			}

			if (numItems == 0) {
				if (!removed) {
					removed = true;
					removeTable();
				} else {
					if (body.position.x >= spawnLocation.x - deleteBuffer) {
						kill();
						destroy();
						active = false;
					}
				}
			}
		}
	}

	function removeTable() {
		body.setVelocityFromTarget(spawnLocation, 0, 0.5);
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
		reactivated = true;
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
		]),
		new TableConfiguration([
			new ThingDef(142, 16, AssetPaths.SPlate__png),
			new ThingDef(-140, 17, AssetPaths.SPlate__png),
			new ThingDef(-50, -3, AssetPaths.SquareMug__png),
			new ThingDef(46, -4, AssetPaths.SquareMug__png),
			new ThingDef(-100, -38, AssetPaths.fork__png),
			new ThingDef(103, -49, AssetPaths.spoon__png),
		]),
		new TableConfiguration([
			new ThingDef(-20, -81, AssetPaths.Wine__png),
			new ThingDef(-88, -81, AssetPaths.Wine__png),
			new ThingDef(42, -80, AssetPaths.Wine__png),
			new ThingDef(-162, -37, AssetPaths.wineGlass__png),
			new ThingDef(140, 5, AssetPaths.Shot__png),
			new ThingDef(177, 5, AssetPaths.Shot__png),
			new ThingDef(177, -35, AssetPaths.Shot__png),
			new ThingDef(99, -35, AssetPaths.Shot__png),
			new ThingDef(140, -35, AssetPaths.Shot__png),
			new ThingDef(99, 5, AssetPaths.Shot__png),
		]),
		new TableConfiguration([
			new ThingDef(-1, -38, AssetPaths.Tall__png),
			new ThingDef(-120, -46, AssetPaths.Pint__png),
			new ThingDef(121, 18, AssetPaths.LPlate__png),
			new ThingDef(-116, 16, AssetPaths.LPlate__png),
			new ThingDef(116, -8, AssetPaths.fork__png),
			new ThingDef(47, -115, AssetPaths.spoon__png),
		]),
		new TableConfiguration([
			new ThingDef(-13, -264, AssetPaths.SquareMug__png),
			new ThingDef(-54, -68, AssetPaths.SquareMug__png),
			new ThingDef(-121, -1, AssetPaths.SquareMug__png),
			new ThingDef(-7, -1, AssetPaths.SquareMug__png),
			new ThingDef(101, -2, AssetPaths.SquareMug__png),
			new ThingDef(35, -68, AssetPaths.SquareMug__png),
			new ThingDef(78, -35, AssetPaths.LPlate__png),
			new ThingDef(-77, -35, AssetPaths.LPlate__png),
			new ThingDef(-7, -99, AssetPaths.LPlate__png),
			new ThingDef(10, -172, AssetPaths.Stein__png)
		]),
		// new TableConfiguration([
		// 	new ThingDef(98, -57, AssetPaths.Shot__png),
		// 	new ThingDef(-95, -57, AssetPaths.Shot__png),
		// 	new ThingDef(95, -7, AssetPaths.RoundMug__png),
		// 	new ThingDef(-78, -7, AssetPaths.RoundMug__png),
		// 	new ThingDef(-49, -141, AssetPaths.Wine__png),
		// 	new ThingDef(51, -141, AssetPaths.Wine__png),
		// ])
	];
}

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
// -300, -100,
// -200, -100,
// -100, -100,
// 0, -100,
// 100, -100,
// 200, -100,
// 300, -100,
// -300, -200,
// -200, -200,
// -100, -200,
// 0, -200,
// 100, -200,
// 200, -200,
// 300, -200,
// -300, -300,
// -200, -300,
// -100, -300,
// 0, -300,
// 100, -300,
// 200, -300,
// 300, -300,
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
