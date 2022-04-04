package entities;

import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.addons.display.FlxTiledSprite;
import openfl.geom.Rectangle;
import flixel.FlxObject;
import flixel.addons.plugin.taskManager.FlxTask;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.text.FlxText;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.nape.FlxNapeSprite;
import openfl.ui.Mouse;
import nape.geom.Vec2;
import nape.constraint.PivotJoint;
import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class AchievementToast extends FlxTypedSpriteGroup<FlxSprite> {
	private static var TIME_TO_TRANSITION:Float = 1;
	private static var TIME_TO_VIEW:Float = 5;

	private static var TITLE_TEXT_SIZE:Int = 15;
	private static var DESCRIPTION_TEXT_SIZE:Int = 10;
	private static var PADDING:Float = 20;

	private var title:FlxText;
	private var description:FlxText;
	private var background:FlxSprite;
	private var icon:FlxSprite;
	private var TOAST_X:Float;
	private var TOAST_Y:Float;
	private var TOAST_HEIGHT_FROM_BOTTOM:Float;

	public function new(title:String, description:String, icon:flixel.system.FlxAssets.FlxGraphicAsset) {
		super();
		TOAST_X = FlxG.width / 2.0;
		TOAST_Y = FlxG.height + 300;
		TOAST_HEIGHT_FROM_BOTTOM = FlxG.height - 300;

		background = new FlxSprite(0, 0, AssetPaths.Bread__png);
		add(background);
		background.setPosition(0, 0);

		this.icon = new FlxSprite(0, 0, icon);
		add(this.icon);
		this.icon.setPosition(PADDING, PADDING);

		this.title = new FlxText(0, 0, background.width, title, TITLE_TEXT_SIZE);
		add(this.title);
		this.title.setPosition(PADDING * 2 + this.icon.width, PADDING);

		this.description = new FlxText(0, 0, background.width, description, DESCRIPTION_TEXT_SIZE);
		add(this.description);
		this.description.setPosition(PADDING * 2 + this.icon.width, this.title.height + PADDING);

		x = TOAST_X;
		y = TOAST_Y;
	}

	public function show():AchievementToast {
		var _in = FlxTween.linearMotion(this, TOAST_X, TOAST_Y, TOAST_X, TOAST_HEIGHT_FROM_BOTTOM, TIME_TO_TRANSITION);
		_in.onComplete = waitThenClose;
		return this;
	}

	private function waitThenClose(_:FlxTween) {
		var _wait = FlxTween.linearMotion(this, TOAST_X, TOAST_HEIGHT_FROM_BOTTOM, TOAST_X, TOAST_HEIGHT_FROM_BOTTOM, TIME_TO_VIEW);
		_wait.onComplete = (_) -> {
			FlxTween.linearMotion(this, TOAST_X, TOAST_HEIGHT_FROM_BOTTOM, TOAST_X, TOAST_Y, TIME_TO_TRANSITION);
		};
	}

	public static function NewSneezeAchievement():AchievementToast {
		return new AchievementToast("Sneeze Away", "Reached the pinnacle of bus-boymanship.", AssetPaths.Bone__png).show();
	}
}
