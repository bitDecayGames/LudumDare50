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
	public static function InitState() {
		Lifecycle.startup.dispatch();

		// Units: Pixels/sec/sec
		var gravity:Vec2 = Vec2.get().setxy(0, 50);

		FlxG.camera.pixelPerfectRender = true;

		CbTypes.initTypes();
		FlxNapeSpace.init();
		#if debug
		FlxNapeSpace.drawDebug = true;
		#end
		FlxNapeSpace.space.gravity.set(gravity);
	}

	var player:FlxSprite;

	override public function create() {
		super.create();

		InitState();

		var bowlSprite = new PhysicsThing(100, 0, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png);
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
