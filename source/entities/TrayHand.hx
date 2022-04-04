package entities;

import haxe.Timer;
import helpers.StackInfo;
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
	var sneezing = false;

	private var ocellateCenter:FlxPoint;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y, AssetPaths.trayHandEasy__png, BodyType.KINEMATIC, jakeTanium());

		initPosition = body.position.x;
		ocellateCenter = FlxPoint.get(body.position.x + OCELLATE_MAGNITUDE, body.position.y + OCELLATE_MAGNITUDE);
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (!sneezing) {
			ocellate();
		}
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

	public function findCurrentHighest():StackInfo {
		var fringe:Array<PhysicsThing> = [this];
		var visitCount:Int = 0;
		var alreadyVisited:Map<PhysicsThing, Bool> = [];
		var highest:PhysicsThing = null;

		while (fringe.length > 0) {
			var current = fringe.pop();
			if (alreadyVisited.exists(current)) {
				// don't expand this thing's contacts if we've already done it
				continue;
			} else {
				// mark that we've looked at this thing so we don't do it again later
				alreadyVisited.set(current, true);
				visitCount++;
			}

			if (highest == null || current.body.position.y < highest.body.position.y) {
				if (!current.inTow) {
					// Only set this if the player isn't actively holding the object
					highest = current;
				}
			}

			for (thing => value in current.inContactWith) {
				fringe.push(thing);
			}
		}

		// sub one because tray doesn't count as an item on the pile
		return new StackInfo(highest, visitCount - 1);
	}

	public function sneeze() {
		if (!sneezing) {
			sneezing = true;
		}
		var firstTarget = body.position.copy().addeq(Vec2.weak(0, 5));
		var secondTarget = body.position.copy().addeq(Vec2.weak(0, -20));

		// Will need to tune these
		var windUpTimeMS = 800;
		var releaseTimeMS = 50;

		body.setVelocityFromTarget(firstTarget, body.rotation, windUpTimeMS / 1000);
		FlxG.sound.play(AssetPaths.male_sneeze1__mp3);
		Timer.delay(() -> {
			body.setVelocityFromTarget(secondTarget, body.rotation, releaseTimeMS / 1000);
			Timer.delay(() -> {
				body.velocity.setxy(0, 0);
			}, releaseTimeMS);
		}, windUpTimeMS);
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
