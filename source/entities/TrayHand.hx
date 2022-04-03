package entities;

import flixel.math.FlxPoint;
import flixel.FlxG;
import nape.geom.Vec2;
import nape.phys.BodyType;
import helpers.Materials;

class TrayHand extends PhysicsThing {
	// +/- max position tray hand can move from start
	var MAX_POSITION:Float = 10;
	var MOVE_DISTANCE:Float = 1;
	var MOVE_TIME:Float = 0.0625;
	var OCELLATE_GRAVITY:FlxPoint = FlxPoint.get(.1, .2);
	var OCELLATE_MAGNITUDE:Float = 10.0;

	var initPosition:Float = 0;

	private var ocellateCenter:FlxPoint;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y, AssetPaths.trayHand__png, BodyType.KINEMATIC, jakeTanium());

		initPosition = body.position.x;
		ocellateCenter = FlxPoint.get(body.position.x + OCELLATE_MAGNITUDE, body.position.y + OCELLATE_MAGNITUDE);
	}

	override public function update(delta:Float) {
		super.update(delta);

		ocellate();
		// var moveDistance = 0.0;

		// if (FlxG.keys.anyPressed([LEFT, A])) {
		// 	moveDistance = -MOVE_DISTANCE;
		// } else if (FlxG.keys.anyPressed([RIGHT, D])) {
		// 	moveDistance = MOVE_DISTANCE;
		// }

		// if (moveDistance != 0.0) {
		// 	var targetPosition = new Vec2();
		// 	targetPosition.y = body.position.y;
		// 	targetPosition.x = moveDistance + body.position.x;

		// 	if (targetPosition.x - initPosition > MAX_POSITION) {
		// 		targetPosition.x = initPosition + MAX_POSITION;
		// 	} else if (targetPosition.x - initPosition < -MAX_POSITION) {
		// 		targetPosition.x = initPosition - MAX_POSITION;
		// 	}

		// 	body.setVelocityFromTarget(targetPosition, 0, MOVE_TIME);
		// } else {
		// 	body.velocity.set(new Vec2(0, 0));
		// }
	}

	private function ocellate() {
		var x = body.position.x;
		var y = body.position.y;

		var velX = body.velocity.x;
		var velY = body.velocity.y;

		if (x > ocellateCenter.x) {
			velX -= OCELLATE_GRAVITY.x;
		} else {
			velX += OCELLATE_GRAVITY.x;
		}
		if (y > ocellateCenter.y) {
			velY -= OCELLATE_GRAVITY.y;
		} else {
			velY += OCELLATE_GRAVITY.y;
		}
		body.velocity.set(Vec2.get(velX, velY));
	}
}
