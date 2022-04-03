package states;

import flixel.group.FlxGroup;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.system.FlxSound;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import entities.Heightometer;
import flixel.FlxObject;
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
	private var tableSpawner:TableSpawner;
	private var heightometer:Heightometer;
	private var trayHand:TrayHand;

	private var foregroundGroup:FlxGroup = new FlxGroup();
	private var other:FlxGroup = new FlxGroup();

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

		var bg = new FlxSprite(AssetPaths.background__png);
		add(bg);

		add(other);
		add(foregroundGroup);

		trayHand = new TrayHand(250, 700);
		other.add(trayHand);

		tableSpawner = new TableSpawner(800, 700, 1600, 700, other.add, allThings.push);
		other.add(tableSpawner);

		heightometer = new Heightometer(trayHand);
		foregroundGroup.add(heightometer);

		foregroundGroup.add(new PickingHand());

		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbTypes.CB_ITEM, CbTypes.CB_ITEM,
			itemCollideCallback));
		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, CbTypes.CB_ITEM, CbTypes.CB_ITEM,
			itemCollideCallback));
	}

	var clinkSFX = FlxG.sound.cache(AssetPaths.glass_clink1__wav);

	public function itemCollideCallback(cb:nape.callbacks.InteractionCallback) {
		var item1 = cast(cb.int1.castBody.userData.data, PhysicsThing);
		var item2 = cast(cb.int2.castBody.userData.data, PhysicsThing);
		trace('COLLISION: item1 is ${item1.originalAsset} and item2 is ${item2.originalAsset}');

		if (cb.event == CbEvent.BEGIN) {
			// TODO: These are delayed for some stupid reason... why
			// clinkSFX.play();
			// FlxG.sound.play(AssetPaths.glass_clink1__wav);

			item1.inContactWith.set(item2, true);
			item2.inContactWith.set(item1, true);
		} else if (cb.event == CbEvent.END) {
			item1.inContactWith.remove(item2);
			item2.inContactWith.remove(item1);
		}
	}

	var maxY = 10000.0;
	var victoryY = 5;
	var endStarted = false;

	override public function update(elapsed:Float) {
		super.update(elapsed);

		KillThingsOutsideBoundary(allThings);
		heightometer.y = CalculateHeighestObject(allThings);

		var stackInfo = trayHand.findCurrentHighest();
		if (stackInfo.heightItem != null && stackInfo.heightItem.y < maxY) {
			maxY = stackInfo.heightItem.body.bounds.min.y;
		}

		heightometer.y = maxY;
		heightometer.itemCount = stackInfo.itemCount;

		if (FlxG.keys.justPressed.E || (maxY <= victoryY && !endStarted)) {
			// TODO: Sneeze sfx
			endStarted = true;
			trayHand.sneeze();
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

	public static function KillThingsOutsideBoundary(things:Array<PhysicsThing>) {
		for (thing in things) {
			// Not removing items from the right cause thats where the table comes from
			if (thing.y > FlxG.height + 100 || thing.y < -500 || thing.x < -500 || thing.x > FlxG.width + 2000) {
				// TODO: This is bad! Loser!
				thing.kill();
				thing.active = false;
				FmodFlxUtilities.TransitionToState(new LoseState());
			}
		}
	}

	public static function CalculateHeighestObject(things:Array<PhysicsThing>):Float {
		var heighest = 100000.0;
		for (thing in things) {
			var y = thing.y - 2;
			if (thing.active && y < heighest) {
				heighest = y;
			}
		}
		return heighest;
	}
}
