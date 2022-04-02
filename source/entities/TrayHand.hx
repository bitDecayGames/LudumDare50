package entities;

import js.html.Console;
import flixel.FlxG;
import nape.geom.Vec2;
import nape.phys.BodyType;
import helpers.Materials;

class TrayHand extends PhysicsThing {
	// +/- max position tray hand can move from start
	var MAX_POSITION:Float = 10;
	var MOVE_DISTANCE:Float = 1;
	var MOVE_TIME:Float = 0.0625;

	var initPosition:Float = 0;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y, AssetPaths.trayHand__png, AssetPaths.trayHandBody__png, 20, 5, BodyType.KINEMATIC, false, jakeTanium());

		initPosition = body.position.x;
	}

	override public function update(delta:Float) {
		super.update(delta);

		var moveDistance = 0.0;

		if (FlxG.keys.anyPressed([LEFT, A])) {
			moveDistance = -MOVE_DISTANCE;
		} else if (FlxG.keys.anyPressed([RIGHT, D])) {
			moveDistance = MOVE_DISTANCE;
		}

		if (moveDistance != 0.0) {
			var targetPosition = new Vec2();
			targetPosition.y = body.position.y;
			targetPosition.x = moveDistance + body.position.x;

			if (targetPosition.x - initPosition > MAX_POSITION) {
				targetPosition.x = initPosition + MAX_POSITION;
			} else if (targetPosition.x - initPosition < -MAX_POSITION) {
				targetPosition.x = initPosition - MAX_POSITION;
			}

			Console.log("init pos: ", initPosition);
			Console.log("body x: ", body.position.x);
			Console.log("body y: ", body.position.y);
			Console.log("target position: ", targetPosition.x);
			body.setVelocityFromTarget(targetPosition, 0, MOVE_TIME);
		} else {
			body.velocity.set(new Vec2(0, 0));
		}
	}
}
