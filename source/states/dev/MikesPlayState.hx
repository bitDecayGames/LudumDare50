package states.dev;

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

class MikesPlayState extends FlxTransitionableState {
	var player:FlxSprite;

	override public function create() {
		super.create();
		PlayState.InitState();

		add(new PhysicsThing(300, 0, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.KINEMATIC, true));
		add(new PhysicsThing(150, 100, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.KINEMATIC, true));
		add(new PhysicsThing(300, 200, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.KINEMATIC, true));
		add(new PhysicsThing(150, 300, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.KINEMATIC, true));

		add(new PickingHand());

		var platter = new PhysicsThing(200, 500, AssetPaths.trayHand__png, AssetPaths.trayHandBody__png, 20, 5, BodyType.KINEMATIC);
		add(platter);
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
}
