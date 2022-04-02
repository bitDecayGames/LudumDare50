package states;

import nape.geom.AABB;
import entities.PhysicsThing;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import flixel.FlxSprite;
import constants.CbTypes;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Vec2;

using extensions.FlxStateExt;

class PlayState extends FlxTransitionableState {

	// Units: Pixels/sec/sec
	var gravity:Vec2 = Vec2.get().setxy(0, 50);

	var player:FlxSprite;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		CbTypes.initTypes();
		FlxNapeSpace.init();
		FlxNapeSpace.drawDebug = true;
		FlxNapeSpace.space.gravity.set(gravity);

		var bowlSprite = new PhysicsThing(0, 0, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png);
		add(bowlSprite);
		// FlxG.bitmap.add(AssetPaths.LBowlBody__png, true, "LBowl");
		// var gfx = FlxG.bitmap.get("LBowl");

		// var bowl = new PhysicsThing(gfx.bitmap, bowlSprite, 5, 2);
		// bowl.invalidate(new AABB(0, 0, gfx.width, gfx.height), FlxNapeSpace.space);
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
