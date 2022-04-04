package states.dev;

import helpers.TableSpawner;
import entities.Table;
import nape.phys.BodyType;
import entities.PhysicsThing;
import entities.PickingHand;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class AllShapesState extends FlxTransitionableState {
	static var columns:Int = 6;
	static var spacing:Float = 150.0;

	override public function create() {
		super.create();
		PlayState.InitState();

		for (thing in spawnAllThings(75, 110)) {
			add(thing);
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}

	private function spawnAllThings(x:Float, y:Float):Array<PhysicsThing> {
		var things:Array<PhysicsThing> = [];
		var i:Int = 0;
		for (asset => _t in PhysicsThing.vertices) {
			things.push(new ThingDef(x + ((i % columns) * spacing), y + (Math.floor(i / columns) * spacing), asset).toPhysicsThing(0, 0, BodyType.KINEMATIC));
			i++;
		}
		return things;
	}
}
