package states;

import nape.phys.BodyType;
import flixel.addons.nape.FlxNapeSprite;
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

	var bowl:PhysicsThing;
	var platter:PhysicsThing;

	override public function create() {
		super.create();

		InitState();

		bowl = new PhysicsThing(100, 100, AssetPaths.LBowl__png, AssetPaths.LBowlBody__png);
		add(bowl);

		var smallBowl = new PhysicsThing(150, 50, AssetPaths.SBowl__png, AssetPaths.SBowlBody__png);
		add(smallBowl);

		platter = new PhysicsThing(100, 500, AssetPaths.trayHand__png, AssetPaths.trayHandBody__png, BodyType.KINEMATIC);
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
