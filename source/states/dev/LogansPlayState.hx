package states.dev;

import flixel.addons.nape.FlxNapeSpace;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.phys.Body;
import nape.geom.Vec2;
import nape.geom.GeomPoly;
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

		var poly = new GeomPoly();
		poly.push(Vec2.weak(0, 0));
		poly.push(Vec2.weak(3, 0));
		poly.push(Vec2.weak(34, 47));
		poly.push(Vec2.weak(37, 47));
		poly.push(Vec2.weak(69, 0));
		poly.push(Vec2.weak(71, 0));
		poly.push(Vec2.weak(37, 54));
		poly.push(Vec2.weak(37, 105));
		poly.push(Vec2.weak(58, 108));
		poly.push(Vec2.weak(13, 108));
		poly.push(Vec2.weak(34, 105));
		poly.push(Vec2.weak(34, 54));

		var resultPolys = poly.convexDecomposition(true);
		trace('polys: ${resultPolys}');

		var body = new Body(BodyType.STATIC, Vec2.get(FlxG.width / 2, FlxG.height / 2));

		for (poly in resultPolys) {
			var bodyPoly = new Polygon(poly);
			body.shapes.add(bodyPoly);
		}

		body.space = FlxNapeSpace.space;
		camera.zoom = 2.5;
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
