package states;

import flixel.FlxG;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.Achievements;
import helpers.Global;
import helpers.UiHelpers;

using extensions.FlxStateExt;

class SettingsState extends FlxUIState {
	var _btnDone:FlxButton;

	var _txtTitle:FlxText;

	var _practiceBox:FlxUICheckBox;
	var _hardObjectsBox:FlxUICheckBox;
	var _easyTrayBox:FlxUICheckBox;

	override public function create():Void {
		super.create();
		bgColor = FlxColor.TRANSPARENT;

		_txtTitle = new FlxText();
		_txtTitle.setPosition(FlxG.width / 2, FlxG.height / 4);
		_txtTitle.size = 40;
		_txtTitle.alignment = FlxTextAlign.CENTER;
		_txtTitle.text = "Settings";
		add(_txtTitle);

		addSettingsButtons();

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
		PRACTICE = _practiceBox.checked;
		HARD_OBJECTS = _hardObjectsBox.checked;
		EASY_TRAY = _easyTrayBox.checked;
	}

	function clickMainMenu():Void {
		FmodFlxUtilities.TransitionToState(new MainMenuState());
	}

	function addSettingsButtons() {
		var yOffset = 0.0;
		_practiceBox = new FlxUICheckBox(FlxG.width / 2, FlxG.height / 2, null, null, "Practice");
		_practiceBox.checked = PRACTICE;
		add(_practiceBox);
		yOffset += _practiceBox.height;

		_hardObjectsBox = new FlxUICheckBox(FlxG.width / 2, (FlxG.height / 2) + yOffset, null, null, "Hard Objects");
		_hardObjectsBox.checked = HARD_OBJECTS;
		add(_hardObjectsBox);
		yOffset += _hardObjectsBox.height;

		_easyTrayBox = new FlxUICheckBox(FlxG.width / 2, (FlxG.height / 2) + yOffset, null, null, "Easy Tray");
		_easyTrayBox.checked = EASY_TRAY;
		add(_easyTrayBox);
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
