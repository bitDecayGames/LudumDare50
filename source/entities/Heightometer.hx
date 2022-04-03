package entities;

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
	private static var PIXELS_PER_INCH:Float = 10.0;
	private static var COLOR:FlxColor = FlxColor.GRAY;

	private var text:FlxText;
	private var line:FlxTiledSprite;
	private var tray:FlxObject;

	public function new(tray:FlxObject) {
		super(0, tray.y);
		this.tray = tray;
		text = new FlxText(x + TEXT_OFFSET_X, y);
		text.color = COLOR;
		text.size = 20;
		FlxG.state.add(text);
		line = new FlxTiledSprite(AssetPaths.dashedLine__png, 14, 5);
		line.replaceColor(FlxColor.WHITE, COLOR);
		line.x = x;
		line.y = y;
		line.width = FlxG.width;
		FlxG.state.add(line);
		snapToPosition();
	}

	override public function update(delta:Float) {
		super.update(delta);
		snapToPosition();
		calculateHeightText();
	}

	private function snapToPosition() {
		text.y = y + TEXT_OFFSET_Y;
		line.y = y;
	}

	private function calculateHeightText() {
		var diff = tray.y - y;
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
		text.text = str;
	}
}
