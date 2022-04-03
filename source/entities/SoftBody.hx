package entities;

import flixel.math.FlxPoint;
import openfl.geom.Rectangle;
import openfl.display.Graphics;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxAngle;
import nape.constraint.PivotJoint;
import nape.shape.Edge;
import nape.phys.Compound;
import flixel.util.FlxColor;
import constants.CbTypes;
import nape.geom.GeomPoly;
import nape.dynamics.InteractionFilter;
import constants.CGroups;
import nape.phys.Material;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxSprite;
import nape.geom.AABB;
import nape.geom.IsoFunction.IsoFunctionDef;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import openfl.display.BitmapData;
import helpers.Materials;

class SoftBody extends FlxSprite {
	private var softBody:Compound;
	private var _color:FlxColor;

	public var avgPos:FlxPoint;

	/**
	 * NOTE: This doesn't work if the camera moves
	 * @param x
	 * @param y
	 * @param color
	 * @param polygon
	 * @param thickness
	 * @param discretisation
	 * @param frequency
	 * @param damping
	 */
	public function new(x:Float, y:Float, color:FlxColor, polygon:Array<Vec2>, thickness:Float, discretisation:Float, frequency:Float, damping:Float) {
		super(0, 0);
		_color = color;
		avgPos = FlxPoint.get(x, y);
		var poly = new GeomPoly(polygon);
		softBody = polygonalBody(Vec2.get(x, y), thickness, discretisation, frequency, damping, poly);
		softBody.space = FlxNapeSpace.space;
		makeGraphic(FlxG.width, FlxG.height, 0x0, true);
	}

	override public function update(delta:Float) {
		super.update(delta);

		var pressure = delta * (softBody.userData.area - polygonalArea(softBody));
		var refEdges:Array<Edge> = softBody.userData.refEdges;
		var totalPos:Vec2 = Vec2.get(0, 0);
		var rot:Float = 0;
		for (index => e in refEdges) {
			var b = e.polygon.body;
			// We pass 'true' for third argument since this pressure impulse is
			// dependent only on the positions of the segments in the soft body.
			// So that if the soft body is at rest, application of the impulse
			// does not need to wake up the body. This permits the soft body
			// to sleep.
			b.applyImpulse(e.worldNormal.mul(pressure, true), b.position, true);
			totalPos.addeq(b.position);
			if (index == 0) {
				rot = b.rotation;
			}
		}
		totalPos.muleq(1.0 / refEdges.length);
		avgPos.set(totalPos.x, totalPos.y);

		drawBody(refEdges);
	}

	function drawBody(edges:Array<Edge>) {
		if (edges == null || edges.length < 2) {
			return;
		}
		var gfx:Graphics = FlxSpriteUtil.flashGfxSprite.graphics;
		gfx.clear();
		gfx.beginFill(_color, 1);
		gfx.lineStyle(/* line thickness */ 1.0, _color, /* alpha */ 1);

		var startPos = edges[0].worldVertex1;
		gfx.moveTo(startPos.x, startPos.y);

		for (i in 1...edges.length) {
			var cur = edges[i].worldVertex1;
			gfx.lineTo(cur.x, cur.y);
		}
		gfx.lineTo(startPos.x, startPos.y);
		gfx.endFill();

		pixels.fillRect(new Rectangle(0, 0, FlxG.width, FlxG.height), 0x0);
		FlxSpriteUtil.updateSpriteGraphic(this);
	}

	override public function kill() {
		softBody.space = null;
		super.kill();
	}

	static function polygonalBody(position:Vec2, thickness:Float, discretisation:Float, frequency:Float, damping:Float, poly:GeomPoly):Compound {
		// We're going to collect all Bodies and Constraints into a SoftBody
		// for ease of use hereafter.
		var body = new Compound();
		// Lists of segments, and the outer and inner points for joint formations.
		var segments = [];
		var outerPoints = [];
		var innerPoints = [];
		// Set of Edge references to vertex of segments to be used in drawing bodies
		// and in determining area for gas forces.
		var refEdges:Array<Edge> = [];
		body.userData.refEdges = refEdges;
		// Deflate the input polygon for inner vertices
		var inner = poly.inflate(-thickness);
		// Create Bodies about the border of polygon.
		var start = poly.current();
		do {
			// Current and next vertex along polygon.
			var current = poly.current();
			poly.skipForward(1);
			var next = poly.current();
			// Current and next vertex along inner-polygon.
			var iCurrent = inner.current();
			inner.skipForward(1);
			var iNext = inner.current();
			var delta = next.sub(current);
			var iDelta = iNext.sub(iCurrent);
			var length = Math.max(delta.length, iDelta.length);
			var numSegments = Math.ceil(length / discretisation);
			var gap = (1 / numSegments);
			for (i in 0...numSegments) {
				// Create softBody segment.
				// We are careful to create weak Vec2 for the polygon
				// vertices so that all Vec2 are automatically released
				// to object pool.
				var segment = new Body();
				var outerPoint = current.addMul(delta, gap * i);
				var innerPoint = iCurrent.addMul(iDelta, gap * i);
				var polygon = new Polygon([
					outerPoint,
					current.addMul(delta, gap * (i + 1)),
					iCurrent.addMul(iDelta, gap * (i + 1)),
					innerPoint
				]);
				polygon.body = segment;
				segment.compound = body;
				segment.align();
				segments.push(segment);
				outerPoints.push(outerPoint);
				innerPoints.push(innerPoint);
				refEdges.push(polygon.edges.at(0));
				segment.setShapeFilters(CGroups.SHELL_FILTER);
			}
			// Release vectors to object pool.
			delta.dispose();
			iDelta.dispose();
		} while (poly.current() != start);
			// Create sets of PivotJoints to link segments together.
		for (i in 0...segments.length) {
			var leftSegment = segments[(i - 1 + segments.length) % segments.length];
			var rightSegment = segments[i];
			// We create a stiff PivotJoint for outer edge
			var current = outerPoints[i];
			var pivot = new PivotJoint(leftSegment, rightSegment, leftSegment.worldPointToLocal(current, true), rightSegment.worldPointToLocal(current, true));
			current.dispose();
			pivot.compound = body;
			// And an elastic one for inner edge
			current = innerPoints[i];
			pivot = new PivotJoint(leftSegment, rightSegment, leftSegment.worldPointToLocal(current, true), rightSegment.worldPointToLocal(current, true));
			current.dispose();
			pivot.compound = body;
			pivot.stiff = false;
			pivot.frequency = frequency;
			pivot.damping = damping;
			// And set one of them to have 'ignore = true' so that
			// adjacent segments do not interact.
			pivot.ignore = true;
		}
		// Release vertices of inner polygon to object pool.
		inner.clear();
		// Move segments by required offset
		for (s in segments) {
			s.position.addeq(position);
		}
		body.userData.area = polygonalArea(body);
		return body;
	}

	static var _areaPoly = new GeomPoly();

	static function polygonalArea(s:Compound) {
		// Computing the area of the soft body, we use the vertices of its edges
		// to populate a GeomPoly and use its area function.
		var refEdges:Array<Edge> = s.userData.refEdges;
		for (edge in refEdges) {
			_areaPoly.push(edge.worldVertex1);
		}
		var ret = _areaPoly.area();
		// We use the same GeomPoly object, and recycle the vertices
		// to avoid increasing memory.
		_areaPoly.clear();
		return ret;
	}

	public static function NewDumpling(x:Float, y:Float):SoftBody {
        // @formatter:off
		return new SoftBody(
            x,
            y,
            0xd6a146,
            Polygon.regular(
                /*xRadius*/30,
                /*yRadius*/30,
                /*segments*/30),
            /*thickness*/ 15,
            /*discretisation*/ 120,
            /*frequency*/ 0.1,
            /*damping*/ 270);
        // @formatter:on
	}

	public static function NewDollupOfMashedPotatoes(x:Float, y:Float):SoftBody {
        // @formatter:off
		return new SoftBody(
            x,
            y,
            0xf2e28c,
            Polygon.regular(
                /*xRadius*/20,
                /*yRadius*/20,
                /*segments*/20),
            /*thickness*/ 10,
            /*discretisation*/ 30,
            /*frequency*/ 1,
            /*damping*/ 100);
        // @formatter:on
	}

	public static function NewFrenchOmlette(x:Float, y:Float):SoftBody {
        // @formatter:off
		return new SoftBody(
            x,
            y,
            0xd8c563,
            Polygon.regular(
                /*xRadius*/40,
                /*yRadius*/10,
                /*segments*/20),
            /*thickness*/ 4,
            /*discretisation*/ 60,
            /*frequency*/ 1,
            /*damping*/ 200);
        // @formatter:on
	}

	public static function NewSteak(x:Float, y:Float):SoftBody {
        // @formatter:off
		return new SoftBody(
            x,
            y,
            0x512b04,
            Polygon.regular(
                /*xRadius*/20,
                /*yRadius*/40,
                /*segments*/10),
            /*thickness*/ 4,
            /*discretisation*/ 60,
            /*frequency*/ 1,
            /*damping*/ 200);
        // @formatter:on
	}
}
