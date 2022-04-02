package entities;

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
	private static var HAND_OFFSET_X = 90.0;
	private static var HAND_OFFSET_Y = 115.0;

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

		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;
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
		x = pos.x;
		y = pos.y;
		if (joint.active) {
			joint.anchor1.setxy(x, y);
		}
	}

	private function startGrab() {
		loadGraphic(AssetPaths.handClosed__png);
		isGrabbing = true;

		var pos = Vec2.get(x, y);
		for (body in FlxNapeSpace.space.bodiesUnderPoint(pos)) {
			if (!body.isDynamic()) {
				continue;
			}

			// Configure hand joint to drag this body.
			//   We initialise the anchor point on this body so that
			//   constraint is satisfied.
			//
			//   The second argument of worldPointToLocal means we get back
			//   a 'weak' Vec2 which will be automatically sent back to object
			//   pool when setting the handJoint's anchor2 property.
			joint.body2 = body;
			joint.anchor2.set(body.worldPointToLocal(pos, true));

			// Enable hand joint!
			joint.active = true;
		}
		pos.dispose();
	}

	private function endGrab() {
		loadGraphic(AssetPaths.handOpen__png);
		isGrabbing = false;
		joint.active = false;
	}
}
