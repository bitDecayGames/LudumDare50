package states.dev;

import entities.PhysicsThing;
import flixel.addons.transition.FlxTransitionableState;
import entities.TrayHand;

using extensions.FlxStateExt;

class JakesPlayState extends FlxTransitionableState {
	override public function create() {
		super.create();
		PlayState.InitState();
		// Lifecycle.startup.dispatch();

		// FlxG.camera.pixelPerfectRender = true;

		var trayHand = new TrayHand(250, 200);
		add(trayHand);

		var bowl = new PhysicsThing(175, 100, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png);
		add(bowl);

		var smallBowl = new PhysicsThing(325, 100, AssetPaths.SBowl__png, AssetPaths.SBowlBody__png);
		add(smallBowl);
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
