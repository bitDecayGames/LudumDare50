package helpers;

import entities.AchievementToast;

class Achievements {
	public static var HEIGHT:AchievementDef = new AchievementDef("4ft Tall", "Reached the pinnacle of bus-boymanship.", 0);
	public static var ITEM_COUNT:AchievementDef = new AchievementDef('Hold At Least 10 Items', "Have you been working out?", 2, 10);
	public static var FIRST_TABLE:AchievementDef = new AchievementDef("My First Table", "They grow up so fast.", 1, 1);
	public static var SHOT_GLASS_ON_WINE_BOTTLE:AchievementDef = new AchievementDef("Shot Glass Cork", "In case you lost the cork.", 0);
	public static var ALL:Array<AchievementDef> = [HEIGHT, ITEM_COUNT, FIRST_TABLE, SHOT_GLASS_ON_WINE_BOTTLE];
}

class AchievementDef {
	public var title:String;
	public var description:String;
	public var iconIndex:Int;
	public var count:Int;
	public var achieved:Bool;

	public function new(title:String, description:String, iconIndex:Int, count:Int = 0) {
		this.title = title;
		this.description = description;
		this.iconIndex = iconIndex;
		this.count = count;
		this.achieved = false;
	}

	public function toToast(show:Bool):AchievementToast {
		var a = new AchievementToast(title, description, iconIndex);
		if (show) {
			if (!achieved) {
				a.show();
				achieved = true;
			} else {
				a.active = false;
			}
		} else {
			if (!achieved) {
				a.dim();
			}
		}
		return a;
	}
}
