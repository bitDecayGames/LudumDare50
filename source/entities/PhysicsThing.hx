package entities;

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

class PhysicsThing extends FlxNapeSprite {
	public var bitmapShell:BitmapData;
	public var bitmapFiller:BitmapData;
	public var visuals:FlxSprite;

	var cellSize:Float;
	var subSize:Float;

	var calcWidth:Int;
	var calcHeight:Int;

	var isoBounds:AABB;

	public var isoGranularity:Vec2;
	public var isoQuality:Int = 8;

	public var type:BodyType;

	private var includeAssetBodyPhysicsShape:Bool = false;

	public function new(x:Float, y:Float, asset:FlxGraphicAsset, bodyAsset:FlxGraphicAsset, ?type:BodyType, includeAssetBodyPhysicsShape:Bool = false,
			?material:Material) {
		super(x, y, asset);
		if (type == null) {
			type = BodyType.DYNAMIC;
		}

		this.type = type;

		this.cellSize = 10;
		this.subSize = 2;

		this.includeAssetBodyPhysicsShape = includeAssetBodyPhysicsShape;
		if (includeAssetBodyPhysicsShape) {
			FlxG.bitmap.add(asset, true, asset);
			bitmapFiller = FlxG.bitmap.get(asset).bitmap;
		}

		FlxG.bitmap.add(bodyAsset, true, bodyAsset);
		bitmapShell = FlxG.bitmap.get(bodyAsset).bitmap;

		calcWidth = Math.ceil(bitmapShell.width / cellSize);
		calcHeight = Math.ceil(bitmapShell.height / cellSize);

		isoBounds = new AABB(0, 0, cellSize, cellSize);
		isoGranularity = Vec2.get(subSize, subSize);
		setup(material);
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	private function setup(?material:Material) {
		body.type = type;
		body.shapes.clear();
		if (includeAssetBodyPhysicsShape) {
			// TODO: MW this interaction filter is most likely wrong, ugh
			buildBody(bitmapFiller, new InteractionFilter(CGroups.FILLER));
		}
		buildBody(bitmapShell, new InteractionFilter());
		body.setShapeMaterials(material != null ? material : Material.glass());
		body.space = FlxNapeSpace.space;
		body.userData.data = this;
	}

	/**
	 * Construct a polygon given a sprite's bitmap data, then add the shape to the main body with the given collision filter
	 * @param bitmap
	 * @param collisionFilter
	 */
	private function buildBody(bitmap:BitmapData, collisionFilter:InteractionFilter) {
		var space = FlxNapeSpace.space;
		var region = new AABB(0, 0, bitmapShell.width, bitmapShell.height);
		// compute effected cells.
		var x0 = Std.int(region.min.x / cellSize);
		if (x0 < 0)
			x0 = 0;
		var y0 = Std.int(region.min.y / cellSize);
		if (y0 < 0)
			y0 = 0;
		var x1 = Std.int(region.max.x / cellSize);
		if (x1 >= calcWidth)
			x1 = calcWidth - 1;
		var y1 = Std.int(region.max.y / cellSize);
		if (y1 >= calcHeight)
			y1 = calcHeight - 1;

		for (y in y0...(y1 + 1)) {
			for (x in x0...(x1 + 1)) {
				isoBounds.x = x * cellSize;
				isoBounds.y = y * cellSize;
				var polys = MarchingSquares.run(iso(bitmap), isoBounds, isoGranularity, isoQuality);
				if (polys.empty())
					continue;

				for (p in polys) {
					var qolys = p.convexDecomposition(true);
					for (q in qolys) {
						var bodyPoly = new Polygon(q);
						bodyPoly.filter = collisionFilter;

						// NOTE: This is to try to align the body with the sprite better
						for (vert in bodyPoly.localVerts) {
							vert.x -= width / 2;
							vert.y -= height / 2;
						}

						bodyPoly.filter;

						// trace(bodyPolyelocalVerts);
						body.shapes.add(bodyPoly);

						// Recycle GeomPoly and its vertices
						q.dispose();
					}

					// Recycle list nodes
					qolys.clear();

					// Recycle GeomPoly and its vertices
					p.dispose();
				}

				// Recycle list nodes
				polys.clear();
			}
		}
	}

	// iso-function for terrain, computed as a linearly-interpolated
	// alpha threshold from bitmap.
	public static function iso(bitmap:BitmapData):Float->Float->Float {
		return (x:Float, y:Float) -> {
			var ix = Std.int(x);
			if (ix < 0)
				ix = 0;
			else if (ix >= bitmap.width)
				ix = bitmap.width - 1;
			var iy = Std.int(y);
			if (iy < 0)
				iy = 0;
			else if (iy >= bitmap.height)
				iy = bitmap.height - 1;
			var fx = x - ix;
			if (fx < 0)
				fx = 0;
			else if (fx > 1)
				fx = 1;
			var fy = y - iy;
			if (fy < 0)
				fy = 0;
			else if (fy > 1)
				fy = 1;
			var gx = 1 - fx;
			var gy = 1 - fy;

			var a00 = bitmap.getPixel32(ix, iy) >>> 24;
			var a01 = bitmap.getPixel32(ix, iy + 1) >>> 24;
			var a10 = bitmap.getPixel32(ix + 1, iy) >>> 24;
			var a11 = bitmap.getPixel32(ix + 1, iy + 1) >>> 24;

			var ret = gx * gy * a00 + fx * gy * a10 + gx * fy * a01 + fx * fy * a11;
			return 0x80 - ret;
		};
	}
}
