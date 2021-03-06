package helpers;

import entities.SoftBody;
import flixel.addons.nape.FlxNapeSprite;
import entities.PhysicsThing;
import entities.Table;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import nape.geom.Vec2;

class TableSpawner extends FlxObject {
	private static var TABLE_X_OFFSET:Float = 100;

	private var tableJustSpawned:Bool = false;
	private var table:Table;
	private var spawnLocation:Vec2;
	private var items:FlxTypedGroup<FlxNapeSprite>;
	private var solidFood:FlxTypedGroup<FlxNapeSprite>;
	private var softies:FlxTypedGroup<SoftBody>;
	private var addToAllThings:(PhysicsThing) -> Int;
	private var totalClearedTableCount:Int = -1;
	private var clothGroup:FlxGroup;

	public function new(x:Float, y:Float, spawnX:Float, spawnY:Float, items:FlxTypedGroup<FlxNapeSprite>, solidFood:FlxTypedGroup<FlxNapeSprite>,
			_addToAllThings:(PhysicsThing) -> Int, clothGroup:FlxGroup, softies:FlxTypedGroup<SoftBody>) {
		super(x, y);
		this.items = items;
		this.clothGroup = clothGroup;
		this.softies = softies;
		this.solidFood = solidFood;
		addToAllThings = _addToAllThings;
		spawnLocation = new Vec2(x + TABLE_X_OFFSET, y);
		spawnTable();
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (tableJustSpawned) {
			if (!tableAtSpawner()) {
				var moveTo = new Vec2(this.x, this.y);
				table.moveMeAndMyPets(moveTo, 0, 0.25);
			} else {
				table.reactivateMeAndMyPets();
				tableJustSpawned = false;
			}
		} else if (!table.alive) {
			spawnTable();
		}
	}

	private function spawnTable() {
		tableJustSpawned = true;
		table = new Table(spawnLocation.x, spawnLocation.y, items);
		tableJustSpawned = true;
		clothGroup.add(table);
		clothGroup.add(table.leftCloth);
		clothGroup.add(table.tablecloth);
		clothGroup.add(table.rightCloth);
		for (thing in table.myItems) {
			if (thing.isFood) {
				solidFood.add(thing);
			} else {
				items.add(thing);
				addToAllThings(thing);
			}
		}
		for (softy in table.softies) {
			softies.add(softy);
		}
		totalClearedTableCount++;
		if (totalClearedTableCount == Achievements.FIRST_TABLE.count) {
			FlxG.state.add(Achievements.FIRST_TABLE.toToast(true));
		} else if (totalClearedTableCount == Achievements.FIVE_TABLES.count) {
			FlxG.state.add(Achievements.FIVE_TABLES.toToast(true));
		}
	}

	private function tableAtSpawner():Bool {
		var bufferDistance:Float = 2;
		return (table.body.position.x >= (this.x - bufferDistance) && table.body.position.x <= (this.x + bufferDistance));
	}
}
