package helpers;

import flixel.FlxObject;
import entities.AchievementToast;

class Achievements {
	public static var ICON_EIFLE_TOWER = 1;
	public static var _heightAchievement:Bool = false;

	public static function NewHeightAchievement(show:Bool = true):FlxObject {
		// TODO: MW ANALYTICS
		if (!_heightAchievement) {
			_heightAchievement = true;
			var a = new AchievementToast("4ft Tall", "Reached the pinnacle of bus-boymanship.", ICON_EIFLE_TOWER);
			if (show)
				a.show();
			return a;
		}
		return new FlxObject();
	}

	public static var ICON_CUP_STACK = 2;
	public static var _itemCountAchievementCount:Int = 10;
	public static var _itemCountAchievement:Bool = false;

	public static function NewItemCountAchievement(show:Bool = true):FlxObject {
		// TODO: MW ANALYTICS
		if (!_itemCountAchievement) {
			_itemCountAchievement = true;
			var a = new AchievementToast('Hold At Least ${_itemCountAchievementCount} Items', "Have you been working out?", ICON_CUP_STACK);
			if (show)
				a.show();
			return a;
		}
		return new FlxObject();
	}

	public static var ICON_TABLE = 1;
	public static var _firstTableAchievement:Bool = false;

	public static function NewFirstTableAchievement(show:Bool = true):FlxObject {
		// TODO: MW ANALYTICS
		if (!_firstTableAchievement) {
			_firstTableAchievement = true;
			var a = new AchievementToast("My First Table", "They grow up so fast.", ICON_TABLE);
			if (show)
				a.show();
			return a;
		}
		return new FlxObject();
	}

	public static var _shotGlassOnWineAchievement:Bool = false;

	public static function NewShotGlassOnWineBottle(show:Bool = true):FlxObject {
		// TODO: MW ANALYTICS
		if (!_shotGlassOnWineAchievement) {
			_shotGlassOnWineAchievement = true;
			var a = new AchievementToast("Shot Glass on Wine Bottle", "In case you need just a tiny sip.", ICON_EIFLE_TOWER);
			if (show)
				a.show();
			return a;
		}
		return new FlxObject();
	}
}
