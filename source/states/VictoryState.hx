package states;

import com.bitdecay.analytics.Bitlytics;
import haxe.Timer;
import flixel.math.FlxVector;
import flixel.math.FlxMath;
import flixel.system.macros.FlxMacroUtil;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import screenshot.Screenshotter;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.UiHelpers;

using extensions.FlxStateExt;
using extensions.FlxObjectExt;

class VictoryState extends FlxUIState {
	var _btnDone:FlxButton;

	var _txtTitle:FlxText;

	var picFadeTime = 3;

	override public function create():Void {
		super.create();

		// Just flush our metrics in case the user closes the page right after finishing the game
		Bitlytics.Instance().ForceFlush();

		bgColor = FlxColor.TRANSPARENT;

		_txtTitle = new FlxText();
		_txtTitle.color = FlxColor.GRAY;
		_txtTitle.setPosition(FlxG.width / 2, FlxG.height / 4);
		_txtTitle.size = 40;
		_txtTitle.alignment = FlxTextAlign.CENTER;
		_txtTitle.text = "Your shift was almost over anyways.";

		_btnDone = UiHelpers.createMenuButton("Main Menu", clickMainMenu);
		_btnDone.setPosition(FlxG.width / 2 - _btnDone.width / 2, FlxG.height - _btnDone.height - 40);
		_btnDone.updateHitbox();

		// restore mouse
		FlxG.mouse.visible = true;

		var picNum = 0;
		for (pic in Screenshotter.runHistory) {
			// uses the known width of the polaroid image file
			var pickedX = FlxG.random.int(10, Std.int(FlxG.width - 538 - 10));
			var pickedY = 50;

			// pickedX = 0;
			var rotation = FlxG.random.int(0, 60) - 30;

			var photoBack = new FlxSprite(AssetPaths.polaroid__png);
			photoBack.x = pickedX;
			photoBack.y = pickedY;

			var polaroidCenter = photoBack.getGraphicMidpoint();

			// magic numbers Erik gave me. get photo center into world coordinates
			var photoCenterPoint = FlxVector.get(0, -64).addPoint(polaroidCenter);

			// This is the vector from the center of the polaroid image to the center of the 'photo area'
			var centerOffset = FlxVector.get().copyFrom(polaroidCenter).subtractPoint(photoCenterPoint);

			centerOffset.rotateByDegrees(rotation);

			photoBack.angle = rotation;

			pic.alpha = 0;
			pic.scale.set(0.5, 0.5);
			pic.updateHitbox();
			pic.centerOffsets();
			pic.x = polaroidCenter.x - centerOffset.x - pic.width / 2;
			pic.y = polaroidCenter.y - centerOffset.y - pic.height / 2;
			pic.angle = rotation;

			Timer.delay(() -> {
				add(photoBack);
				add(pic);
				FlxTween.tween(pic, {alpha: 1}, picFadeTime);
			}, picNum * picFadeTime * 1000 + 500);
			picNum++;
		}

		Timer.delay(() -> {
			add(_txtTitle);
			add(_btnDone);
		}, (Screenshotter.runHistory.length + 1) * picFadeTime * 1000);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		_txtTitle.x = FlxG.width / 2 - _txtTitle.width / 2;
	}

	function clickMainMenu():Void {
		FmodFlxUtilities.TransitionToState(new MainMenuState());
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
