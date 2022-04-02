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
	var gravity:Vec2 = Vec2.get().setxy(0, 10);

	var player:FlxSprite;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		CbTypes.initTypes();
		FlxNapeSpace.init();
		FlxNapeSpace.drawDebug = true;
		FlxNapeSpace.space.gravity.set(gravity);

		var bg = new FlxSprite(0, 0, AssetPaths.HaxeFlixelLogo__png);
		add(bg);
		FlxG.bitmap.add(AssetPaths.HaxeFlixelLogo__png, true, "terrainTest");
		var gfx = FlxG.bitmap.get("terrainTest");

		var terrain = new PhysicsThing(gfx.bitmap, bg, 30, 5);
		terrain.invalidate(new AABB(0, 0, gfx.width, gfx.height), FlxNapeSpace.space);
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
