package entities;

import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Player extends FlxSprite {
	// +/- max position tray hand can move from start
	var MAX_POSITION = 50;
	var initPosition:Float = 0;
	var curPosition:Float = 0;
	var speed:Float = 250;

	public function new(color:FlxColor = FlxColor.BLUE, x:Float = 0, y:Float = 0) {
		super();
		makeGraphic(20, 20, FlxColor.WHITE);
		this.x = x;
		this.y = y;
		initPosition = this.x;
		this.color = color;
	}

	override public function update(delta:Float) {
		super.update(delta);

		curPosition = this.x - initPosition;

		var inputDir = InputCalcuator.getInputCardinal();
		if (inputDir != NONE) {
			inputDir.asVector(velocity).scale(speed);
		} else {
			velocity.set();
		}

		if (curPosition > MAX_POSITION) {
			this.x = initPosition + MAX_POSITION;
		}
		if (curPosition < -MAX_POSITION) {
			this.x = initPosition - MAX_POSITION;
		}
	}
}
