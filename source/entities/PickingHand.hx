package entities;

import flixel.addons.nape.FlxNapeSprite;
import openfl.ui.Mouse;
import nape.geom.Vec2;
import nape.constraint.PivotJoint;
import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class PickingHand extends FlxSprite {
	// the offset of the hand to the point at which the object is picked up
	private static var HAND_OFFSET_X = 75.0;
	private static var HAND_OFFSET_Y = 85.0;

	private var joint:PivotJoint;
	private var isGrabbing = false;

	public function new() {
		super();

		joint = new PivotJoint(FlxNapeSpace.space.world, null, Vec2.weak(), Vec2.weak());
		joint.space = FlxNapeSpace.space;
		joint.active = false;
		joint.stiff = false;

		endGrab();
		offset.set(HAND_OFFSET_X, HAND_OFFSET_Y);
	}

	override public function update(delta:Float) {
		super.update(delta);
		snapToMouse();
		if (FlxG.mouse.justPressed) {
			startGrab();
		} else if (FlxG.mouse.justReleased) {
			endGrab();
		}
	}

	private function snapToMouse() {
		var pos = FlxG.mouse.getWorldPosition();
		if (joint.active) {
			joint.anchor1.setxy(pos.x, pos.y);
			snapHandToJoint();
		} else {
			x = pos.x;
			y = pos.y;
		}
	}

	private function snapHandToJoint() {
		if (joint.active) {
			var anchor = joint.anchor2;
			var pos = joint.body2.localPointToWorld(anchor);
			x = pos.x;
			y = pos.y;
		}
	}

	private function startGrab() {
		loadGraphic(AssetPaths.handClosed__png);
		isGrabbing = true;

		// the flx-way of trying to click an object
		// var pnt = FlxPoint.get(x, y);
		// for (member in FlxG.state.members) {
		// 	if (Std.isOfType(member, FlxNapeSprite)) {
		// 		var spr = cast(member, FlxNapeSprite); // MW: safe cast will throw exceptions...
		// 		spr.updateHitbox();
		// 		if (spr != null && spr.body != null && spr.overlapsPoint(pnt)) {
		// 			var body = spr.body;
		// 			if (!body.isDynamic()) {
		// 				continue;
		// 			}
		// 			joint.anchor1.set(pos);
		// 			joint.anchor2.set(body.worldPointToLocal(pos, true));
		// 			joint.body2 = body;
		// 			joint.active = true;
		// 			break;
		// 		}
		// 	}
		// }

		// the Nap way of trying to click an object
		var pos = Vec2.get(x, y);
		for (body in FlxNapeSpace.space.bodiesUnderPoint(pos)) {
			if (!body.isDynamic()) {
				continue;
			}

			joint.anchor1.set(pos);
			joint.anchor2.set(body.worldPointToLocal(pos, true));
			joint.body2 = body;
			joint.active = true;
			cast(body.userData.data, PhysicsThing).inTow = true;
			break;
		}
		pos.dispose();
	}

	private function endGrab() {
		loadGraphic(AssetPaths.handOpen__png);
		isGrabbing = false;
		joint.active = false;
		if (joint.body2 != null) {
			cast(joint.body2.userData.data, PhysicsThing).inTow = false;
		}
	}
}
