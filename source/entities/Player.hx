package entities;

import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Player extends FlxSprite {
	var speed:Float = 30;
	var playerNum = 0;

	public function new(color:FlxColor = FlxColor.BLUE) {
		super();
		makeGraphic(20, 20, FlxColor.WHITE);
		this.color = color;
	}

	override public function update(delta:Float) {
		super.update(delta);

		var inputDir = InputCalcuator.getInputCardinal(playerNum);
		if (inputDir != NONE) {
			inputDir.asVector(velocity).scale(speed);
		} else {
			velocity.set();
		}

		if (SimpleController.just_pressed(Button.A, playerNum)) {
			color = color ^ 0xFFFFFF;
		}
	}
}
