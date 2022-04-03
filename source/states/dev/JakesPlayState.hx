package states.dev;

import entities.PickingHand;
import flixel.FlxG;
import helpers.TableSpawner;
import entities.PhysicsThing;
import flixel.addons.transition.FlxTransitionableState;
import entities.TrayHand;

using extensions.FlxStateExt;

class JakesPlayState extends FlxTransitionableState {
	private var tableSpawner:TableSpawner;

	private var allThings:Array<PhysicsThing> = [];

	override public function create() {
		super.create();
		PlayState.InitState();

		// var trayHand = new TrayHand(250, 400);
		// add(trayHand);

		tableSpawner = new TableSpawner(400, 600, 1600, 700, add, allThings.push);
		add(tableSpawner);

		add(new PickingHand());
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		for (thing in allThings) {
			// Not removing items from the right cause thats where the table comes from
			if (thing.y > FlxG.height + 100 || thing.y < 0 || thing.x < 0) {
				// TODO: This is bad! Loser!
				thing.kill();
				thing.active = false;
			}
		}
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
