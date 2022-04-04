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

// Saving
private var _gameSave:FlxSave;

function loadData() {
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
	_gameSave.flush();
	ITEM_COUNT = _gameSave.data.itemCount;
	HEIGHT = _gameSave.data.height;
	trace("Item Count: ", ITEM_COUNT);
	trace("Height: ", HEIGHT);
}

function saveHeight(newHeight:Float) {
	FlxG.watch.addQuick("new height", newHeight);
	if (newHeight > HEIGHT) {
		trace('Old height: ${HEIGHT} New Height: ${newHeight}');
		HEIGHT = newHeight;
		_gameSave.data.height = HEIGHT;
		_gameSave.flush();
	}
}

function saveItemCount(newItemCount:Int) {
	if (newItemCount > ITEM_COUNT) {
		trace('Old Item Count: ${ITEM_COUNT} New ItemCount: ${newItemCount}');
		ITEM_COUNT = newItemCount;
		_gameSave.data.itemCount = ITEM_COUNT;
		_gameSave.flush();
	}
}
