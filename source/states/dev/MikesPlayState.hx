package states.dev;

import entities.TrayHand;
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

		add(new PhysicsThing(300, 0, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));
		add(new PhysicsThing(150, 100, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));
		// add(new PhysicsThing(300, 200, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));
		// add(new PhysicsThing(150, 300, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));

		add(new PickingHand());

		add(new TrayHand(200, 200));
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
