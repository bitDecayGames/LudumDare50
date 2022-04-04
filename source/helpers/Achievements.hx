package helpers;

import flixel.FlxObject;
import entities.AchievementToast;

class Achievements {
	public static var ICON_EIFLE_TOWER = 1;
	public static var _heightAchievement:Bool = false;

	public static function NewHeightAchievement():FlxObject {
		// TODO: MW ANALYTICS
		var a:FlxObject;
		if (!_heightAchievement) {
			a = new AchievementToast("4ft Tall", "Reached the pinnacle of bus-boymanship.", ICON_EIFLE_TOWER).show();
			_heightAchievement = true;
		} else {
			a = new FlxObject();
		}
		return a;
	}

	public static var ICON_CUP_STACK = 2;
	public static var _itemCountAchievementCount:Int = 10;
	public static var _itemCountAchievement:Bool = false;

	public static function NewItemCountAchievement():FlxObject {
		// TODO: MW ANALYTICS
		var a:FlxObject;
		if (!_itemCountAchievement) {
			a = new AchievementToast('Hold At Least ${_itemCountAchievementCount} Items', "Have you been working out?", ICON_CUP_STACK).show();
			_itemCountAchievement = true;
		} else {
			a = new FlxObject();
		}
		return a;
	}

	public static var ICON_TABLE = 1;
	public static var _firstTableAchievement:Bool = false;

	public static function NewFirstTableAchievement():FlxObject {
		// TODO: MW ANALYTICS
		var a:FlxObject;
		if (!_firstTableAchievement) {
			a = new AchievementToast("My First Table", "They grow up so fast.", ICON_TABLE).show();
			_firstTableAchievement = true;
		} else {
			a = new FlxObject();
		}
		return a;
	}

	public static var _shotGlassOnWineAchievement:Bool = false;

	public static function NewShotGlassOnWineBottle():FlxObject {
		// TODO: MW ANALYTICS
		var a:FlxObject;
		if (!_shotGlassOnWineAchievement) {
			a = new AchievementToast("Shot Glass on Wine Bottle", "In case you need just a tiny sip.", ICON_EIFLE_TOWER).show();
			_shotGlassOnWineAchievement = true;
		} else {
			a = new FlxObject();
		}
		return a;
	}
}
