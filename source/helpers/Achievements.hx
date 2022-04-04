package helpers;

import helpers.Global.saveAchievement;
import helpers.Global.isAchievementSaved;
import entities.AchievementToast;

class Achievements {
	public static var HEIGHT:AchievementDef;
	public static var ITEM_COUNT:AchievementDef;
	public static var FIRST_TABLE:AchievementDef;
	public static var FIVE_TABLES:AchievementDef;
	public static var ONE_MINUTE:AchievementDef;
	public static var TEN_MINUTE:AchievementDef;
	public static var SPEEDY:AchievementDef;
	public static var SLOW:AchievementDef;
	public static var MINIMALIST:AchievementDef;
	public static var HOARDER:AchievementDef;
	public static var SHOT_GLASS_ON_WINE_BOTTLE:AchievementDef;
	public static var ALL:Array<AchievementDef>;

	public static function initAchievements() {
		trace("initted the acheeeevements");
		HEIGHT = new AchievementDef("achwin", "4ft Tall", "Reached the pinnacle of bus-boymanship", 0);
		ITEM_COUNT = new AchievementDef("achtenitems", 'Hold At Least 10 Items', "Have you been working out?", 2, 10);
		FIRST_TABLE = new AchievementDef("achfirsttable", "My First Table", "They grow up so fast.", 1, 1);
		FIVE_TABLES = new AchievementDef("achfivetables", "Clear 5 Tables", "Mean lean, cleaning machine", 1, 5);
		ONE_MINUTE = new AchievementDef("achoneminute", "Played for 1 Minute", "They'll call you the minute man", 0, 60);
		TEN_MINUTE = new AchievementDef("achtenminutes", "Played for 5 Minutes", "We love you too", 0, 300);
		SPEEDY = new AchievementDef("achspeedy", "The Hare", "Finished in under 2 min", 0, 120);
		SLOW = new AchievementDef("achslow", "The Tortoise", "Finished in over 10 min", 0, 600);
		MINIMALIST = new AchievementDef("achminimalist", "Minimalist", "Finished with less than 15 items", 0, 15);
		HOARDER = new AchievementDef("achhoarder", "Hoarder", "Finished with more than 50 items", 0, 50);
		SHOT_GLASS_ON_WINE_BOTTLE = new AchievementDef("achshotglasscork", "Shot Glass Cork", "In case you lost the cork", 0);

		// @formatter:off
		ALL = [
			HEIGHT,
			ITEM_COUNT,
			FIRST_TABLE,
			FIVE_TABLES,
			ONE_MINUTE,
			TEN_MINUTE,
			SPEEDY,
			SLOW,
			MINIMALIST,
			HOARDER,
		];
		// @formatter:on
	}

	public static function clearAchievements() {
		for (ach in ALL) {
			ach.achieved = false;
		}
	}
}

class AchievementDef {
	public var key:String;
	public var title:String;
	public var description:String;
	public var iconIndex:Int;
	public var count:Int;
	public var hidden:Bool;
	public var achieved:Bool;

	public function new(key:String, title:String, description:String, iconIndex:Int, count:Int = 0, hidden:Bool = false) {
		this.key = key;
		this.title = title;
		this.description = description;
		this.iconIndex = iconIndex;
		this.count = count;
		this.hidden = hidden;

		if (isAchievementSaved(key)) {
			this.achieved = true;
		} else {
			this.achieved = false;
		}
	}

	public function toToast(show:Bool):AchievementToast {
		var a = new AchievementToast(title, description, iconIndex);
		if (show) {
			if (!achieved) {
				a.show();
				// TODO: analytics
				saveAchievement(key);
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
