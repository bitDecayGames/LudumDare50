package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.UiHelpers;
import misc.FlxTextFactory;

using extensions.FlxStateExt;

class TutorialState extends FlxUIState {
	var _btnDone:FlxButton;

	override public function create():Void {
		super.create();
		bgColor = FlxColor.TRANSPARENT;

		var img = new FlxSprite(AssetPaths.instructions2__png);
		add(img);

		_btnDone = UiHelpers.createMenuButton("Clock In", clickPlay);
		_btnDone.setPosition(FlxG.width / 2 - _btnDone.width / 2, FlxG.height - _btnDone.height - 40);
		_btnDone.updateHitbox();
		add(_btnDone);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();
	}

	function clickPlay():Void {
		FmodFlxUtilities.TransitionToState(new PlayState());
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
