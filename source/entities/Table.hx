package entities;

import flixel.FlxObject;
import flixel.addons.effects.FlxClothSprite;
import helpers.Global.HARD_OBJECTS;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import js.html.Float32Array;
import nape.phys.Material;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.BodyType;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import nape.geom.Vec2;

class Table extends PhysicsThing {
	static private var lastConfigs:Array<Int> = [];

	public var allItems:FlxTypedGroup<FlxSprite>;
	public var myItems:Array<PhysicsThing> = [];
	public var softies:Array<SoftBody> = [];

	private var reactivated:Bool = false;
	private var removed:Bool = false;
	private var spawnLocation:Vec2;
	private var deleteBuffer:Float = 10;

	public var tablecloth:FlxClothSprite;

	public function new(x:Float, y:Float, allItems:FlxTypedGroup<FlxSprite>) {
		super(x, y, AssetPaths.table__png, BodyType.KINEMATIC);
		this.allItems = allItems;
		spawnLocation = new Vec2(x, y);
		spawnThings();

		// This show how to set mesh scale, custom pinned points and set iterations
		tablecloth = new FlxClothSprite(FlxG.width / 2 - 105, 10, AssetPaths.flag__png);

		tablecloth.pinnedSide = FlxObject.UP;
		tablecloth.meshScale.set(1, 1);
		tablecloth.setMesh(10, 10);
		tablecloth.iterations = 8;
		tablecloth.maxVelocity.set(200, 200);
		tablecloth.meshVelocity.y = 40;
	}

	override public function update(delta:Float) {
		super.update(delta);

		// output item nums
		// for (i in 0...myItems.length) {
		// 	if (i >= 5) {
		// 		var absolutePos = new Vec2(myItems[i].body.position.x - body.position.x, myItems[i].body.position.y - (body.position.y - 85));
		// 		FlxG.watch.addQuick('item#${i}', absolutePos);
		// 	}
		// }
		for (i in 0...softies.length) {
			if (i >= 5) {
				var absolutePos = new Vec2(softies[i].avgPos.x - body.position.x, softies[i].avgPos.y - (body.position.y - 85));
				FlxG.watch.addQuick('softy#${i}', absolutePos);
			}
		}

		if (reactivated) {
			var haveItemsAbove = false;
			allItems.forEach((item) -> {
				if (item.x >= body.position.x - (body.bounds.width / 2)
					&& item.x <= body.position.x + (body.bounds.width / 2)
					&& item.y <= body.position.y - (body.bounds.height / 2)
					&& item.exists) {
					haveItemsAbove = true;
				}
			});

			if (!haveItemsAbove) {
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
			var isHardObject = thingDef.isHardObject();
			if ((isHardObject && HARD_OBJECTS) || !isHardObject) {
				var thing = thingDef.toPhysicsThing(body.position.x, body.position.y - 85);
				myItems.push(thing);

				// Turn myItems off initially because table spawns and then moves. Thigns are turned on later.
				thing.body.allowMovement = false;
				thing.body.allowRotation = false;
			}
		}
		for (softy in configuration.softies) {
			var softBody = softy.body(softy.x + body.position.x, softy.y + body.position.y - 85);
			softBody.temporarilyDisable();
			softies.push(softBody);
		}
	}

	private function getRandomConfiguration():TableConfiguration {
		var nextRandomConfNum = FlxG.random.int(0, tableConfigurations.length - 1, lastConfigs);
		lastConfigs.push(nextRandomConfNum);
		if (lastConfigs.length >= 3) {
			lastConfigs.remove(lastConfigs[0]);
		}
		return tableConfigurations[nextRandomConfNum];
	}

	public function moveMeAndMyPets(targetPosition:Vec2, targetRotation:Float, deltaTime:Float) {
		if (targetPosition.x > x) {
			tablecloth.meshVelocity.x = -50;
		}
		if (targetPosition.x < x) {
			tablecloth.meshVelocity.x = 50;
		}

		body.setVelocityFromTarget(targetPosition, targetRotation, deltaTime);
		for (pet in myItems) {
			if (pet.body != null) {
				var petTarget:Vec2 = new Vec2(targetPosition.x + (pet.body.position.x - body.position.x), pet.body.position.y);
				pet.body.setVelocityFromTarget(petTarget, targetRotation, deltaTime);
			}
		}
		for (pet in softies) {
			var com = pet.centerOfMass();
			var petTarget:Vec2 = new Vec2(targetPosition.x + (com.x - body.position.x), com.y);
			pet.setVelocityFromTarget(petTarget, targetRotation, deltaTime);
		}
	}

	public function reactivateMeAndMyPets() {
		tablecloth.meshVelocity.x = 0;

		body.velocity.set(new Vec2());
		for (pet in myItems) {
			if (pet.body != null) {
				pet.body.velocity.set(new Vec2());
				pet.body.allowMovement = true;
				pet.body.allowRotation = true;
				pet.body.disableCCD = false;
			}
		}
		for (pet in softies) {
			trace("Re-enable softie");
			pet.reEnable();
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
		], [new SoftBodyDef(-140, -15, SoftBody.NewDumpling),]),
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
		], [
			new SoftBodyDef(-140, -15, SoftBody.NewFrenchOmlette),
			new SoftBodyDef(122, -15, SoftBody.NewSteak),
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
			new ThingDef(116, -19, AssetPaths.fork__png),
			new ThingDef(47, -115, AssetPaths.spoon__png),
		], [
			new SoftBodyDef(121, -5, SoftBody.NewFrenchOmlette),
			new SoftBodyDef(-120, -60, SoftBody.NewDollupOfMashedPotatoes),
			new SoftBodyDef(-80, -10, SoftBody.NewDollupOfMashedPotatoes),
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
		new TableConfiguration([
			new ThingDef(98, -57, AssetPaths.Shot__png),
			new ThingDef(-95, -57, AssetPaths.Shot__png),
			new ThingDef(95, -7, AssetPaths.RoundMug__png),
			new ThingDef(-78, -7, AssetPaths.RoundMug__png),
			new ThingDef(-49, -141, AssetPaths.Wine__png),
			new ThingDef(51, -141, AssetPaths.Wine__png),
		]),
		new TableConfiguration([
			new ThingDef(-158, -25, AssetPaths.Pint__png),
			new ThingDef(-158, -96, AssetPaths.Pint__png),
			new ThingDef(-96, -25, AssetPaths.Pint__png),
			new ThingDef(-96, -96, AssetPaths.Pint__png),
			new ThingDef(-129, -155, AssetPaths.LPlate__png),
			new ThingDef(33, -34, AssetPaths.LPlate__png),
			new ThingDef(51, -102, AssetPaths.LPlate__png),
			new ThingDef(7, -134, AssetPaths.SquareMug__png),
			new ThingDef(81, -135, AssetPaths.SquareMug__png),
			new ThingDef(77, -1, AssetPaths.SquareMug__png),
			new ThingDef(16, -1, AssetPaths.SquareMug__png),
			new ThingDef(43, -76, AssetPaths.fork__png),
			new ThingDef(-51, -202, AssetPaths.spoon__png),
			new ThingDef(-51, -179, AssetPaths.fork__png),
			new ThingDef(43, -55, AssetPaths.spoon__png),
			new ThingDef(-160, -221, AssetPaths.Martini__png),
		], [
			new SoftBodyDef(-158, -25, SoftBody.NewDollupOfMashedPotatoes),
			new SoftBodyDef(-158, -96, SoftBody.NewDollupOfMashedPotatoes),
			new SoftBodyDef(-96, -25, SoftBody.NewDollupOfMashedPotatoes),
			new SoftBodyDef(-96, -96, SoftBody.NewDollupOfMashedPotatoes),
		])
	];
}

// List of all object paths. Useful for creating new Table configurations
// 	AssetPaths.SBowl__png
// 	AssetPaths.MBowl__png
// 	AssetPaths.LBowl__png
// 	AssetPaths.SPlate__png
// 	AssetPaths.MPlate__png
// 	AssetPaths.LPlate__png
// 	AssetPaths.fork__png
// 	AssetPaths.knife__png
// 	AssetPaths.spoon__png
// 	AssetPaths.Martini__png
// 	AssetPaths.Pint__png
// 	AssetPaths.RoundMug__png
// 	AssetPaths.Shot__png
// 	AssetPaths.SquareMug__png
// 	AssetPaths.Stein__png
// 	AssetPaths.Tall__png
// 	AssetPaths.Wine__png
// 	AssetPaths.wineGlass__png
// new ThingDef(),
//
// -300, -100,
// -200, -100,
// -100, -100,
// 0, -100,
// 100, -100,
// 200, -100,
// -300, -200,
// -200, -200,
// -100, -200,
// 0, -200,
// 100, -200,
// 200, -200,
// -300, -300,
// -200, -300,
// -100, -300,
// 0, -300,
// 100, -300,
// 200, -300,
// 300, -300,
class TableConfiguration {
	public var things:Array<ThingDef>;
	public var softies:Array<SoftBodyDef>;

	public function new(things:Array<ThingDef>, ?softies:Array<SoftBodyDef>) {
		this.things = things;
		if (softies == null) {
			this.softies = [];
		} else {
			this.softies = softies;
		}
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

	public function isHardObject():Bool {
		return (img == AssetPaths.fork__png || img == AssetPaths.spoon__png || img == AssetPaths.knife__png || img == AssetPaths.Martini__png
			|| img == AssetPaths.RoundMug__png);
	}
}

class SoftBodyDef {
	public var x:Float;
	public var y:Float;
	public var body:Float->Float->SoftBody;

	public function new(x:Float, y:Float, body:Float->Float->SoftBody) {
		this.x = x;
		this.y = y;
		this.body = body;
	}
}
