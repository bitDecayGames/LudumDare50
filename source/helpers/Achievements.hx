package helpers;

import com.bitdecay.analytics.Bitlytics;
import helpers.Global.saveAchievement;
import helpers.Global.isAchievementSaved;
import entities.AchievementToast;

class Achievements {
	public static var HEIGHT:AchievementDef;
	public static var FIRST_TABLE:AchievementDef;
	public static var ITEM_COUNT:AchievementDef;
	public static var FIVE_TABLES:AchievementDef;
	public static var ONE_MINUTE:AchievementDef;
	public static var FIVE_MINUTES:AchievementDef;
	public static var SPEEDY:AchievementDef;
	public static var SLOW:AchievementDef;
	public static var MINIMALIST:AchievementDef;
	public static var HOARDER:AchievementDef;
	public static var HARD_MODE:AchievementDef;
	public static var TOUCH_FOOD:AchievementDef;
	public static var SHOT_GLASS_ON_WINE_BOTTLE:AchievementDef;
	public static var MAGICIAN:AchievementDef;
	public static var SECOND_SNEEZE:AchievementDef;
	public static var DIAMOND:AchievementDef;
	public static var ALL:Array<AchievementDef>;
	public static var ACHIEVEMENTS_DISPLAYED:Int = 0;

	public static function initAchievements() {
		trace("initted the acheeeevements");

		HEIGHT = new AchievementDef("achwin", "Sois Béni", "Win the game", 0);
		FIRST_TABLE = new AchievementDef("achfirsttable", "My First Table", "Bus your first table", 1, 1);
		ITEM_COUNT = new AchievementDef("achtenitems", "That Looks Heavy", "Hold ten items", 2, 10);
		FIVE_TABLES = new AchievementDef("achfivetables", "Workaholic", "Bus five tables", 3, 5);
		ONE_MINUTE = new AchievementDef("achoneminute", "Break Time?", "Work for one minute", 4, 60);
		FIVE_MINUTES = new AchievementDef("achfiveminutes", "Overtime", "Work for five minutes", 5, 300);
		SPEEDY = new AchievementDef("achspeedy", "The Hare", "Finished in under 2 min", 6, 120);
		SLOW = new AchievementDef("achslow", "The Tortoise", "Finished in over 10 min", 7, 600);
		MINIMALIST = new AchievementDef("achminimalist", "Minimalist", "Finished with less than 5 items", 8, 5);
		HOARDER = new AchievementDef("achhoarder", "Hoarder", "Finished with more than 50 items", 9, 50);
		HARD_MODE = new AchievementDef("achhardmode", "Masochist", "Win with hard objects", 10);
		SHOT_GLASS_ON_WINE_BOTTLE = new AchievementDef("achshotglasscork", "Improvisor", "Use a glass cork", 11);
		TOUCH_FOOD = new AchievementDef("achstickyfingers", "Sticky Fingers", "Pick up food", 12);
		SECOND_SNEEZE = new AchievementDef("achsecondsneeze", "Circus Act", "Get two sneezes", 13);
		DIAMOND = new AchievementDef("achdiamond", "Diamond", "Create a glass diamond", 14);
		MAGICIAN = new AchievementDef("achmagician", "Magician", "Fit a tray inside a glass", 15);

		// @formatter:off
		ALL = [
			HEIGHT,
			FIRST_TABLE,
			ITEM_COUNT,
			FIVE_TABLES,
			ONE_MINUTE,
			FIVE_MINUTES,
			SPEEDY,
			SLOW,
			MINIMALIST,
			HOARDER,
			HARD_MODE,
			TOUCH_FOOD,
			SHOT_GLASS_ON_WINE_BOTTLE,
			SECOND_SNEEZE,
			MAGICIAN,
			DIAMOND,
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

		this.achieved = isAchievementSaved(key);
	}

	public function toToast(show:Bool, force:Bool = false):AchievementToast {
		var a = new AchievementToast(this);
		if (show) {
			if (!achieved || force) {
				Achievements.ACHIEVEMENTS_DISPLAYED++;
				a.show(Achievements.ACHIEVEMENTS_DISPLAYED);
				Analytics.reportAchievement(this.key);
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
