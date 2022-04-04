package screenshot;

import flixel.FlxG;
import flixel.FlxSprite;

class Screenshotter {
	static public var runHistory:Array<FlxSprite> = [];

	static public function reset() {
		// for (sprite in runHistory) {
		// 	sprite.destroy();
		// 	sprite.kill();
		// }
		runHistory = [];
	}

	static public function capture() {
		var cap = new FlxSprite();
		cap.makeGraphic(FlxG.width, FlxG.height, true);
		cap.pixels.draw(FlxG.stage, null);
		runHistory.push(cap);
	}
}
