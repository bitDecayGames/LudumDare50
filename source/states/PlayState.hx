package states;

import helpers.Achievements;
import entities.AchievementToast;
import flixel.util.FlxSort;
import sort.ItemSorter.sortItems;
import flixel.math.FlxMath;
import helpers.Global.PRACTICE;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.math.FlxPoint;
import entities.SoftBody;
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
import sort.ItemSorter;

using extensions.FlxStateExt;

class PlayState extends FlxTransitionableState {
	public static var VICTORY_Y = 170;

	private var tableSpawner:TableSpawner;
	private var heightometer:Heightometer;
	private var heightGoal:Heightometer;
	private var heightGoalSuccess:Heightometer;
	private var trayHand:TrayHand;

	private var foregroundGroup:FlxGroup = new FlxGroup();
	private var items:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	private var misc:FlxGroup = new FlxGroup();

	public var timer:Float = 0;
	public var timerDisplay:FlxText;

	static var CLINK_THRESHOLD = 100;
	static var MAX_VOLUME_CLINK = 400;

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
		FlxG.mouse.visible = false;
	}

	private var allThings:Array<PhysicsThing> = [];

	override public function create() {
		super.create();

		InitState();

		var bg = new FlxSprite(AssetPaths.background__png);
		add(bg);

		add(misc);
		add(items);
		add(foregroundGroup);

		trayHand = new TrayHand(250, 700);
		misc.add(trayHand);

		tableSpawner = new TableSpawner(800, 700, 1600, 700, items, allThings.push, misc);
		misc.add(tableSpawner);

		heightometer = new Heightometer(trayHand);
		foregroundGroup.add(heightometer);
		heightGoal = new Heightometer(trayHand, FlxColor.RED, false, false);
		foregroundGroup.add(heightGoal);
		heightGoal.x = 0;
		if (PRACTICE) {
			heightGoal.setVisible(false);
		}
		FlxTween.linearMotion(heightGoal, 0, -400, 0, VICTORY_Y, 6);
		heightGoalSuccess = new Heightometer(trayHand, FlxColor.LIME, false, false);
		heightGoalSuccess.setVisible(false);
		foregroundGroup.add(heightGoalSuccess);
		heightGoalSuccess.x = 0;
		FlxTween.linearMotion(heightGoalSuccess, 0, -400, 0, VICTORY_Y, 6);

		foregroundGroup.add(new PickingHand());

		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbTypes.CB_ITEM, CbTypes.CB_ITEM,
			itemCollideCallback));
		FlxNapeSpace.space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, CbTypes.CB_ITEM, CbTypes.CB_ITEM,
			itemCollideCallback));

		timerDisplay = new FlxText(FlxG.width - 150, 5);
		timerDisplay.size = 20;
		foregroundGroup.add(timerDisplay);
	}

	var clinkSFX = FlxG.sound.cache(AssetPaths.glass_clink1__wav);

	public function itemCollideCallback(cb:nape.callbacks.InteractionCallback) {
		var item1 = cast(cb.int1.castBody.userData.data, PhysicsThing);
		var item2 = cast(cb.int2.castBody.userData.data, PhysicsThing);
		// trace('COLLISION: item1 is ${item1.originalAsset} and item2 is ${item2.originalAsset}');

		if (cb.event == CbEvent.BEGIN) {
			#if !nosound
			// TODO: These are delayed on Ubuntu for some stupid reason... why
			// clinkSFX.play();
			// if (cb.arbiters.at(0).collisionArbiter.totalImpulse)
			var impulse = cb.arbiters.at(0).collisionArbiter.totalImpulse(true).length;
			// trace('total impulse: ${impulse}');
			if (impulse > CLINK_THRESHOLD) {
				// The idea is softer hits make softer sounds
				var volume = FlxMath.lerp(0, 1, Math.min(impulse / MAX_VOLUME_CLINK, 1));
				// trace('      volume: ${volume}');

				FlxG.sound.play(AssetPaths.glass_clink1__wav, volume);
			}
			#end

			item1.inContactWith.set(item2, true);
			item2.inContactWith.set(item1, true);
		} else if (cb.event == CbEvent.END) {
			item1.inContactWith.remove(item2);
			item2.inContactWith.remove(item1);
		}
	}

	var maxY = 10000.0;

	var endStarted = false;

	override public function update(elapsed:Float) {
		super.update(elapsed);

		timer += elapsed;

		KillThingsOutsideBoundary();
		// MW This doesn't seem to be used anymore
		// heightometer.y = CalculateHeighestObject(allThings);

		#if debug
		var mousePos = FlxG.mouse.getWorldPosition();
		if (FlxG.keys.justPressed.ONE) {
			add(SoftBody.NewDollupOfMashedPotatoes(mousePos.x, mousePos.y));
		}
		if (FlxG.keys.justPressed.TWO) {
			add(SoftBody.NewDumpling(mousePos.x, mousePos.y));
		}
		if (FlxG.keys.justPressed.THREE) {
			add(SoftBody.NewFrenchOmlette(mousePos.x, mousePos.y));
		}
		if (FlxG.keys.justPressed.FOUR) {
			add(SoftBody.NewSteak(mousePos.x, mousePos.y));
		}
		if (FlxG.keys.justPressed.SPACE) {
			add(Achievements.NewHeightAchievement());
		}
		#end

		var stackInfo = trayHand.findCurrentHighest();
		if (stackInfo.heightItem != null && stackInfo.heightItem.y < maxY) {
			maxY = stackInfo.heightItem.body.bounds.min.y;
		}

		heightometer.y = maxY;
		heightometer.itemCount = stackInfo.itemCount;
		if (!Achievements._itemCountAchievement && stackInfo.itemCount >= Achievements._itemCountAchievementCount) {
			add(Achievements.NewItemCountAchievement());
		}

		var withMS = heightometer.lastRatio >= 0.8;
		timerDisplay.text = FlxStringUtil.formatTime(timer, withMS);

		if (FlxG.keys.justPressed.E || (maxY <= VICTORY_Y && !endStarted && !PRACTICE)) {
			// TODO: Sneeze sfx
			add(Achievements.NewHeightAchievement());
			endStarted = true;
			trayHand.sneeze();
			heightGoalSuccess.setVisible(true);
			heightGoal.setVisible(false);
			heightometer.setVisible(false);
		}

		items.sort(sortItems, FlxSort.DESCENDING);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}

	public function KillThingsOutsideBoundary() {
		for (thing in items) {
			if (thing.active) {
				if (Std.isOfType(thing, SoftBody)) {
					var obj = cast(thing, SoftBody);
					var pos = obj.avgPos;
					if (pos.y > FlxG.height + 100 || pos.y < -500 || pos.x < -500 || pos.x > FlxG.width + 2000) {
						obj.kill();
						obj.active = false;
						obj.destroy();
					}
				} else if (Std.isOfType(thing, FlxObject)) {
					var obj = cast(thing, FlxObject);
					if (obj.y > FlxG.height + 100 || obj.y < -500 || obj.x < -500 || obj.x > FlxG.width + 2000) {
						obj.kill();
						obj.active = false;

						if (!PRACTICE) {
							if (endStarted) {
								FmodFlxUtilities.TransitionToState(new VictoryState());
							} else {
								FmodFlxUtilities.TransitionToState(new LoseState());
							}
						}
					}
				}
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
