package states;

import screenshot.Screenshotter;
import helpers.StackInfo;
import helpers.Global.HARD_OBJECTS;
import helpers.Global.HEIGHT;
import helpers.Global.ITEM_COUNT;
import helpers.Global.saveItemCount;
import helpers.Global.saveHeight;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.math.FlxMath;
import constants.CbTypes;
import entities.Heightometer;
import entities.PhysicsThing;
import entities.PickingHand;
import entities.SoftBody;
import entities.TrayHand;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.Achievements;
import helpers.Global.PRACTICE;
import helpers.TableSpawner;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import signals.Lifecycle;
import sort.ItemSorter.sortItems;

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
	private var clothGroup:FlxGroup = new FlxGroup();
	private var misc:FlxGroup = new FlxGroup();

	private var highScore:FlxText;

	public var timer:Float = 0;
	public var timerDisplay:FlxText;
	public var secondSneeze:Float = 7;
	public var afterSecondSneezeTimer:Float = 5;

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
		Screenshotter.reset();

		var bg = new FlxSprite(AssetPaths.background__png);
		add(bg);

		add(misc);
		add(items);
		add(clothGroup);
		add(foregroundGroup);

		trayHand = new TrayHand(250, 700);
		misc.add(trayHand);

		tableSpawner = new TableSpawner(800, 700, 1600, 700, items, allThings.push, clothGroup);
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

		timerDisplay = new FlxText(FlxG.width - 75, 5);
		timerDisplay.size = 20;
		foregroundGroup.add(timerDisplay);

		makeHighScoreArea(FlxG.width - 450, timerDisplay.y + timerDisplay.height);
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
			if (cb.arbiters != null) {
				var arbiter = cb.arbiters.at(0).collisionArbiter;
				if (arbiter != null) {
					var impulse = arbiter.totalImpulse(true).length;
					// trace('total impulse: ${impulse}');
					if (impulse > CLINK_THRESHOLD) {
						// The idea is softer hits make softer sounds
						var volume = FlxMath.lerp(0, 1, Math.min(impulse / MAX_VOLUME_CLINK, 1));
						// trace('      volume: ${volume}');

						FlxG.sound.play(AssetPaths.glass_clink1__wav, volume);
					}
				}
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
		debugLogic();
		#end

		var stackInfo = trayHand.findCurrentHighest();
		if (stackInfo.heightItem != null && stackInfo.heightItem.y < maxY) {
			maxY = stackInfo.heightItem.body.bounds.min.y;
		}

		heightometer.y = maxY;
		heightometer.itemCount = stackInfo.itemCount;

		if (!PRACTICE) {
			saveHeight(trayHand.y - maxY);
			saveItemCount(stackInfo.itemCount);
		}

		if (!Achievements.ITEM_COUNT.achieved && stackInfo.itemCount >= Achievements.ITEM_COUNT.count) {
			add(Achievements.ITEM_COUNT.toToast(true));
		}

		var withMS = heightometer.lastRatio >= 0.8;
		timerDisplay.text = FlxStringUtil.formatTime(timer, withMS);
		highScore.text = Heightometer.getHeightText(HEIGHT, ITEM_COUNT);

		items.sort(sortItems, FlxSort.DESCENDING);

		if (!Achievements.ONE_MINUTE.achieved && timer > Achievements.ONE_MINUTE.count) {
			add(Achievements.ONE_MINUTE.toToast(true));
		} else if (!Achievements.FIVE_MINUTES.achieved && timer > Achievements.FIVE_MINUTES.count) {
			add(Achievements.FIVE_MINUTES.toToast(true));
		}

		if (isWin()) {
			triggerWin(stackInfo);
		}
		if (endStarted) {
			if (secondSneeze > 0) {
				secondSneeze -= elapsed;
				if (secondSneeze < 0) {
					secondSneezeWin();
				}
			} else {
				afterSecondSneezeTimer -= elapsed;
				if (afterSecondSneezeTimer < 0) {
					goToVictoryScreen();
				}
			}
		}
	}

	public function debugLogic() {
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
		if (FlxG.keys.justPressed.P) {
			add(Achievements.HEIGHT.toToast(true, true));
		}
	}

	public function isWin():Bool {
		return #if debug FlxG.keys.justPressed.E || #end (maxY <= VICTORY_Y && !endStarted && !PRACTICE);
	}

	public function goToVictoryScreen() {
		FmodFlxUtilities.TransitionToState(new VictoryState());
	}

	public function goToLoseScreen() {
		FmodFlxUtilities.TransitionToState(new LoseState());
	}

	public function triggerWin(stackInfo:StackInfo) {
		// TODO: Sneeze sfx
		if (!Achievements.HEIGHT.achieved) {
			add(Achievements.HEIGHT.toToast(true));
		}
		endStarted = true;
		trayHand.sneeze();
		heightGoalSuccess.setVisible(true);
		heightGoal.setVisible(false);
		heightometer.setVisible(false);
		heightGoalSuccess.y = heightometer.y;

		if (!Achievements.SPEEDY.achieved && timer <= Achievements.SPEEDY.count) {
			add(Achievements.SPEEDY.toToast(true));
		}
		if (!Achievements.SLOW.achieved && timer >= Achievements.SLOW.count) {
			add(Achievements.SLOW.toToast(true));
		}
		if (!Achievements.MINIMALIST.achieved && stackInfo.itemCount <= Achievements.MINIMALIST.count) {
			add(Achievements.MINIMALIST.toToast(true));
		}
		if (!Achievements.HOARDER.achieved && stackInfo.itemCount >= Achievements.HOARDER.count) {
			add(Achievements.HOARDER.toToast(true));
		}
		if (!Achievements.HARD_MODE.achieved && HARD_OBJECTS) {
			add(Achievements.HARD_MODE.toToast(true));
		}
	}

	public function secondSneezeWin() {
		if (!Achievements.SECOND_SNEEZE.achieved) {
			add(Achievements.SECOND_SNEEZE.toToast(true));
		}
		trayHand.sneeze();
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
								goToVictoryScreen();
							} else {
								goToLoseScreen();
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

	function makeHighScoreArea(x:Float, y:Float) {
		var highScoreText = new FlxText(x, y, 200, "HIGH SCORES:", 24);
		foregroundGroup.add(highScoreText);

		highScore = new FlxText(x + highScoreText.width, highScoreText.y, 300, Heightometer.getHeightText(HEIGHT, ITEM_COUNT), 24);
		foregroundGroup.add(highScore);
	}
}
