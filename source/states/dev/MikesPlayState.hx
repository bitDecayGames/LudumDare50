package states.dev;

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

		var bowlSprite = new PhysicsThing(0, 0, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png);
		add(bowlSprite);

		add(new PickingHand());
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
