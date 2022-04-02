package states.dev;

import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Table;
import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class LogansPlayState extends FlxTransitionableState {
	var player:FlxSprite;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		PlayState.InitState();

		FlxG.camera.pixelPerfectRender = true;

		var table = new Table(4);
		add(table);

		for (thing in table.items) {
			add(thing);
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
