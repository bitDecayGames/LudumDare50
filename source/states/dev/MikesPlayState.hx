package states.dev;

import entities.PickingHand;
import entities.TrayHand;
import flixel.addons.transition.FlxTransitionableState;

using extensions.FlxStateExt;

class MikesPlayState extends FlxTransitionableState {
	override public function create() {
		super.create();
		PlayState.InitState();

		// add(new PhysicsThing(300, 0, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));
		// add(new PhysicsThing(150, 100, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));
		// add(new PhysicsThing(300, 200, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));
		// add(new PhysicsThing(150, 300, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png, 20, 5, BodyType.DYNAMIC, true));

		var tray = new TrayHand(200, 600);
		add(tray);
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
