package helpers;

import entities.AchievementToast;

class Achievements {
	public static var HEIGHT:AchievementDef = new AchievementDef("achwin", "4ft Tall", "Reached the pinnacle of bus-boymanship", 0);
	public static var ITEM_COUNT:AchievementDef = new AchievementDef("achtenitems", 'Hold At Least 10 Items', "Have you been working out?", 2, 10);
	public static var FIRST_TABLE:AchievementDef = new AchievementDef("achfirsttable", "My First Table", "They grow up so fast.", 1, 1);
	public static var FIVE_TABLES:AchievementDef = new AchievementDef("achfivetables", "Clear 5 Tables", "Mean lean, cleaning machine", 1, 5);
	public static var ONE_MINUTE:AchievementDef = new AchievementDef("achoneminute", "Played for 1 Minute", "They'll call you the minute man", 0, 60);
	public static var TEN_MINUTE:AchievementDef = new AchievementDef("achtenminutes", "Played for 5 Minutes", "We love you too", 0, 300);
	public static var SPEEDY:AchievementDef = new AchievementDef("achspeedy", "The Hare", "Finished in under 2 min", 0, 120);
	public static var SLOW:AchievementDef = new AchievementDef("achslow", "The Tortoise", "Finished in over 10 min", 0, 600);
	public static var MINIMALIST:AchievementDef = new AchievementDef("achminimalist", "Minimalist", "Finished with less than 15 items", 0, 15);
	public static var HOARDER:AchievementDef = new AchievementDef("achhoarder", "Hoarder", "Finished with more than 50 items", 0, 50);
	public static var SHOT_GLASS_ON_WINE_BOTTLE:AchievementDef = new AchievementDef("achshotglasscork", "Shot Glass Cork", "In case you lost the cork", 0);
	// @formatter:off
	public static var ALL:Array<AchievementDef> = [
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
		this.achieved = false;

		// TODO: MW here is where we should check the key in localStorage to check if they have already achieved this thing
	}

	public function toToast(show:Bool):AchievementToast {
		var a = new AchievementToast(title, description, iconIndex);
		if (show) {
			if (!achieved) {
				a.show();
				// TODO: analytics
				// TODO: MW here is where we should track this achievement by the key in localStorage
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
