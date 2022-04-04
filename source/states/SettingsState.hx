package states;

import flixel.addons.ui.FlxUIText;
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
		addAchievementToasts();

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
		var xOffset = -80.0;
		var yOffset = 0.0;
		_practiceBox = makeNewCheckbox(xOffset, yOffset, "Practice", PRACTICE);

		add(_practiceBox);
		yOffset += (_practiceBox.box.height * 2) + 10;

		_hardObjectsBox = makeNewCheckbox(xOffset, yOffset, "Hard Objects", HARD_OBJECTS);
		add(_hardObjectsBox);
		yOffset += (_hardObjectsBox.box.height * 2) + 10;

		_easyTrayBox = makeNewCheckbox(xOffset, yOffset, "Easy Tray", EASY_TRAY);
		add(_easyTrayBox);
	}

	function makeNewCheckbox(xOffset:Float, yOffset:Float, label:String, checked:Bool):FlxUICheckBox {
		var checkbox = new FlxUICheckBox((FlxG.width / 2) + xOffset, (FlxG.height / 2) + yOffset, null, null, "", 200);
		checkbox.scale.set(2, 2);
		checkbox.setLabel(new FlxUIText(0, 0, 200, label, 20));
		checkbox.button.setAllLabelOffsets(checkbox.box.width * 2, -(checkbox.box.height / 2));
		checkbox.checked = checked;
		return checkbox;
	}

	function addAchievementToasts() {
		var x = 20;
		var y = 20;
		for (def in Achievements.ALL) {
			var a = def.toToast(false);
			add(a);
			a.setPosition(x, y);
			y += 100;
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
}
