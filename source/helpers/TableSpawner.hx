package helpers;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxG;
import entities.PhysicsThing;
import nape.geom.Vec2;
import entities.Table;
import flixel.FlxObject;

class TableSpawner extends FlxObject {
	private var tableJustSpawned:Bool = false;
	private var table:Table;
	private var spawnLocation:Vec2;
	private var items:FlxTypedGroup<FlxSprite>;
	private var addToAllThings:(PhysicsThing) -> Int;

	public function new(x:Float, y:Float, spawnX:Float, spawnY:Float, items:FlxTypedGroup<FlxSprite>, _addToAllThings:(PhysicsThing) -> Int) {
		super(x, y);
		this.items = items;
		addToAllThings = _addToAllThings;
		spawnLocation = new Vec2(x + 1000, y);
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
		table = new Table(spawnLocation.x, spawnLocation.y, items);
		items.add(table);
		for (thing in table.myItems) {
			items.add(thing);
			addToAllThings(thing);
		}
		for (softy in table.softies) {
			trace("Add softy");
			items.add(softy);
		}
		tableJustSpawned = true;
	}

	private function tableAtSpawner():Bool {
		var bufferDistance:Float = 2;
		return (table.body.position.x >= (this.x - bufferDistance) && table.body.position.x <= (this.x + bufferDistance));
	}
}
