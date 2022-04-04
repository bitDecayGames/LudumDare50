package states;

import flixel.addons.ui.FlxUIText;
import helpers.Global.PRACTICE;
import flixel.addons.ui.FlxUICheckBox;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.UiHelpers;

using extensions.FlxStateExt;

class SettingsState extends FlxUIState {
	var _btnDone:FlxButton;

	var _txtTitle:FlxText;

	var _freePlayBox:FlxUICheckBox;

	override public function create():Void {
		super.create();
		bgColor = FlxColor.TRANSPARENT;

		_txtTitle = new FlxText();
		_txtTitle.setPosition(FlxG.width / 2, FlxG.height / 4);
		_txtTitle.size = 40;
		_txtTitle.alignment = FlxTextAlign.CENTER;
		_txtTitle.text = "Settings";
		add(_txtTitle);

		_freePlayBox = new FlxUICheckBox(FlxG.width / 2, FlxG.height / 2, null, null, "Practice");
		_freePlayBox.checked = PRACTICE;
		add(_freePlayBox);

		_btnDone = UiHelpers.createMenuButton("Main Menu", clickMainMenu);
		_btnDone.setPosition(FlxG.width / 2 - _btnDone.width / 2, FlxG.height - _btnDone.height - 40);
		_btnDone.updateHitbox();
		add(_btnDone);
		// restore mouse
		FlxG.mouse.visible = true;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		_txtTitle.x = FlxG.width / 2 - _txtTitle.width / 2;
		PRACTICE = _freePlayBox.checked;
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