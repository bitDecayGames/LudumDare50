package entities;

import helpers.Achievements;
import nape.phys.Body;
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
	private static var FUZZY_CLICK_RADIUS = 10.0;

	private var joint:PivotJoint;
	private var isGrabbing = false;

	public function new() {
		super();
		loadGraphic(AssetPaths.handAnimation__png, true, 148, 99);
		animation.add('open', [2, 1, 0], false);
		animation.add('close', [0, 1, 2], false);
		animation.play('open');

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
		animation.play('close');
		isGrabbing = true;
		var found:Bool = false;

		// the Nap way of trying to click an object
		var pos = Vec2.get(x, y);
		_grabAtPoint(pos);
		pos.dispose();
	}

	private function _grabAtPoint(pos:Vec2) {
		for (body in FlxNapeSpace.space.bodiesInCircle(pos, FUZZY_CLICK_RADIUS)) {
			if (!body.isDynamic() || body.isCompound()) {
				continue;
			}
			joint.anchor1.set(pos);
			joint.anchor2.set(body.worldPointToLocal(pos, true));
			joint.body2 = body;
			joint.active = true;
			if (Std.isOfType(body.userData.data, PhysicsThing)) {
				cast(body.userData.data, PhysicsThing).inTow = true;
			} else if (!Achievements.TOUCH_FOOD.achieved && Std.isOfType(body.userData.data, SoftBody)) {
				FlxG.state.add(Achievements.TOUCH_FOOD.toToast(true));
			}
			return;
		}
	}

	private function endGrab() {
		animation.play('open');
		isGrabbing = false;
		joint.active = false;
		if (joint.body2 != null) {
			if (Std.isOfType(joint.body2.userData.data, PhysicsThing)) {
				cast(joint.body2.userData.data, PhysicsThing).inTow = false;
			}
		}
	}
}
