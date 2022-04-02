package states;

import config.Configure;
import constants.CbTypes;
import entities.PhysicsThing;
import entities.PickingHand;
import entities.Table;
import entities.TrayHand;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.phys.BodyType;
import signals.Lifecycle;

using extensions.FlxStateExt;

class PlayState extends FlxTransitionableState {
	private var table:Table;

	public static function InitState() {
		FlxG.mouse.visible = false;

		Lifecycle.startup.dispatch();

		// Units: Pixels/sec/sec
		var gravity:Vec2 = Vec2.get().setxy(0, 400);

		FlxG.camera.pixelPerfectRender = true;

		CbTypes.initTypes();
		FlxNapeSpace.init();
		#if debug
		FlxNapeSpace.drawDebug = true;
		#end
		FlxNapeSpace.space.gravity.set(gravity);

		// this also gets updated on focus (but even this doesn't really work)
		FlxG.mouse.visible = Configure.config.mouse.cursorVisible;
		FlxG.mouse.useSystemCursor = Configure.config.mouse.useSystemCursor;
	}

	private var allThings:Array<PhysicsThing> = [];

	override public function create() {
		super.create();

		InitState();

		var trayHand = new TrayHand(250, 700);
		add(trayHand);

		table = new Table(800, 700, 4);
		add(table);

		for (thing in table.items) {
			add(thing);
			allThings.push(thing);
		}

		add(new PickingHand());
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		for (thing in allThings) {
			if (thing.y > FlxG.height + 100 || thing.x > FlxG.width || thing.x < 0) {
				// TODO: This is bad! Loser!
				thing.destroy();
			}
		}

		if (FlxG.keys.justPressed.T) {
			for (thing in table.spawnThings(3)) {
				add(thing);
			}
		}
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
