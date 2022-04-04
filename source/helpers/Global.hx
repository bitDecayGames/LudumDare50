package helpers;

import flixel.FlxG;
import flixel.util.FlxSave;

// Settings
var PRACTICE:Bool = false;
var HARD_OBJECTS:Bool = false;
var EASY_TRAY:Bool = false;

// High Scores
var ITEM_COUNT:Int;
var HEIGHT:Float;
var ACHIEVEMENTS:Array<String>;

// Saving
private var _gameSave:FlxSave;

function loadData():Void {
	_gameSave = new FlxSave(); // initialize
	_gameSave.bind("Save"); // bind to the named save slot

	var initSave = false;
	if (_gameSave.data.itemCount == null) {
		_gameSave.data.itemCount = 0;
		initSave = true;
	}
	if (_gameSave.data.height == null) {
		_gameSave.data.height = 0;
		initSave = true;
	}
	if (_gameSave.data.achievements == null) {
		_gameSave.data.achievements = new Array<String>();
		initSave = true;
	}
	if (initSave) {
		_gameSave.flush();
	}

	ITEM_COUNT = _gameSave.data.itemCount;
	HEIGHT = _gameSave.data.height;
	ACHIEVEMENTS = _gameSave.data.achievements;
}

function deleteData():Void {
	_gameSave.erase();
	ITEM_COUNT = 0;
	HEIGHT = 0;
	ACHIEVEMENTS = new Array<String>();
	Achievements.clearAchievements();
}

function saveHeight(newHeight:Float):Void {
	if (newHeight > HEIGHT) {
		HEIGHT = newHeight;
		_gameSave.data.height = HEIGHT;
		_gameSave.flush();
	}
}

function saveItemCount(newItemCount:Int):Void {
	if (newItemCount > ITEM_COUNT) {
		ITEM_COUNT = newItemCount;
		_gameSave.data.itemCount = ITEM_COUNT;
		_gameSave.flush();
	}
}

function saveAchievement(achievementKey:String):Void {
	if (!ACHIEVEMENTS.contains(achievementKey)) {
		ACHIEVEMENTS.push(achievementKey);
		_gameSave.data.achievements = ACHIEVEMENTS;
		_gameSave.flush();
	}
}

function isAchievementSaved(achievementKey:String):Bool {
	var achievementSaved = false;
	if (ACHIEVEMENTS != null) {
		achievementSaved = ACHIEVEMENTS.contains(achievementKey);
	}
	return achievementSaved;
}
