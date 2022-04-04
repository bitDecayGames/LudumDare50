package helpers;

import com.bitdecay.metrics.Tag;
import com.bitdecay.analytics.Bitlytics;

class Analytics {
	private static var ACHIEVEMENT_METRIC = "achievement";
	private static var TAG_ACHIEVEMENT_NAME = "name_key";

	public static function reportAchievement(key:String) {
		Bitlytics.Instance().Queue(ACHIEVEMENT_METRIC, 1, [new Tag(TAG_ACHIEVEMENT_NAME, key)]);
	}
}
