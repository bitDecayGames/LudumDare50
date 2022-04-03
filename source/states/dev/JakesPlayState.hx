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

		var trayHand = new TrayHand(250, 400);
		add(trayHand);

		tableSpawner = new TableSpawner(800, 600, 1600, 700, add, allThings.push);
		add(tableSpawner);

		add(new PickingHand());
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		PlayState.KillThingsOutsideBoundary(allThings);
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
