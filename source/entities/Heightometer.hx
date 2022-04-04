package entities;

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

class Heightometer extends FlxObject {
	private static var TEXT_OFFSET_Y:Float = -25.0;
	private static var TEXT_OFFSET_X:Float = 50.0;
	private static var MAX_TEXT_OFFSET_X:Float = 800;
	private static var PIXELS_PER_INCH:Float = 10.0;

	private static var MAX_HEIGHT = 10;

	private var text:FlxText;
	private var line:FlxTiledSprite;
	private var tray:FlxObject;
	private var showItemCount:Bool;
	private var shouldModifyTextPosition:Bool;

	public var itemCount = 0;
	public var lastRatio:Float = 0;

	public function new(tray:FlxObject, color:FlxColor = FlxColor.GRAY, showItemCount:Bool = true, shouldModifyTextPosition:Bool = true) {
		super(0, tray.y);
		this.tray = tray;
		this.showItemCount = showItemCount;
		this.shouldModifyTextPosition = shouldModifyTextPosition;
		text = new FlxText(x + TEXT_OFFSET_X, y);
		text.color = color;
		text.size = 20;
		FlxG.state.add(text);
		var tmpSpr = new FlxSprite(0, 0);
		tmpSpr.loadGraphic(AssetPaths.dashedLine__png, false, 14, 5, true);
		line = new FlxTiledSprite(tmpSpr.graphic, 14, 5);
		line.replaceColor(FlxColor.WHITE, color);
		line.x = x;
		line.y = y;
		line.width = FlxG.width;
		FlxG.state.add(line);
		snapToPosition();
	}

	override public function update(delta:Float) {
		super.update(delta);
		snapToPosition();

		var trayHeight = tray.y - y;
		text.text = getHeightText(tray.y - y, showItemCount ? itemCount : null);
	}

	public function setVisible(visible:Bool) {
		this.visible = visible;
		text.visible = visible;
		line.visible = visible;
	}

	private function snapToPosition() {
		var diffFromMax = y - MAX_HEIGHT;
		var totalDist = tray.y - MAX_HEIGHT;
		lastRatio = 1 - (diffFromMax / totalDist);

		if (shouldModifyTextPosition) {
			text.x = x + FlxMath.lerp(TEXT_OFFSET_X, MAX_TEXT_OFFSET_X, lastRatio);
			text.y = y;
			if (y < FlxG.height / 4) {
				text.y -= TEXT_OFFSET_Y;
			} else {
				text.y += TEXT_OFFSET_Y;
			}
		} else {
			text.x = x + TEXT_OFFSET_X;
			text.y = y + TEXT_OFFSET_Y;
		}
		line.y = y;
	}

	/**
	 * Get the height text for scoring purposes (just a string, because we are just going to print it to the screen anyways)
	 * @return String
	 */
	static public function getHeightText(diff:Float, ?itemCount:Int):String {
		// var diff = tray.y - y;
		var totalInches = diff / PIXELS_PER_INCH;
		var feet = Math.floor(totalInches / 12.0);
		var inches = Math.floor(totalInches % 12.0);
		var str = "";
		if (feet > 0) {
			str += feet + "ft";
			if (inches > 0) {
				str += " ";
			}
		}
		if (inches > 0) {
			str += inches + "in";
		}

		if (itemCount != null) {
			str += ' (${itemCount} items)';
		}
		return str;
	}
}
