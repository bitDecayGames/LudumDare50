package states;

import flixel.system.FlxSound;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import helpers.TableSpawner;
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
	// private var table:Table;
	private var tableSpawner:TableSpawner;

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

		var trayHand = new TrayHand(250, 400);
		add(trayHand);

		tableSpawner = new TableSpawner(800, 400, 1600, 700, add, allThings.push);
		add(tableSpawner);

		add(new PickingHand());

		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbTypes.CB_ITEM, CbTypes.CB_ITEM,
			itemCollideCallback));
		// FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, CbTypes.CB_ITEM, CbTypes.CB_ITEM,
		// 	itemCollideCallback));
	}

	var clinkSFX = FlxG.sound.cache(AssetPaths.glass_clink1__wav);

	public function itemCollideCallback(cb:nape.callbacks.InteractionCallback) {
		var item1 = cast(cb.int1.castBody.userData.data, PhysicsThing);
		var item2 = cast(cb.int2.castBody.userData.data, PhysicsThing);
		trace('COLLISION: item1 is ${item1.originalAsset} and item2 is ${item2.originalAsset}');

		// TODO: These are delayed for some stupid reason... why
		// clinkSFX.play();
		// FlxG.sound.play(AssetPaths.glass_clink1__wav);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		for (thing in allThings) {
			// Not removing items from the right cause thats where the table comes from
			if (thing.y > FlxG.height + 100 || thing.y < 0 || thing.x < 0) {
				// TODO: This is bad! Loser!
				thing.kill();
				thing.active = false;
			}
		}

		// if (FlxG.keys.justPressed.T) {
		// 	for (thing in table.spawnThings(3)) {
		// 		add(thing);
		// 	}
		// }
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
