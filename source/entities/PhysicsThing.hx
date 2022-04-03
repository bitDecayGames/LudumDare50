package entities;

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

class PhysicsThing extends FlxNapeSprite {
	public var bitmapShell:BitmapData;
	public var bitmapFiller:BitmapData;
	public var visuals:FlxSprite;

	// MW: we could maybe set these for each type of asset to account for small forks and whatnot
	var cellSize:Float;
	var subSize:Float;

	var calcWidth:Int;
	var calcHeight:Int;

	var isoBounds:AABB;

	public var isoGranularity:Vec2;
	public var isoQuality:Int = 2;

	public var type:BodyType;

	private var includeAssetBodyPhysicsShape:Bool = false;

	private var originalAsset:FlxGraphicAsset;

	private var vertices = [
		AssetPaths.Martini__png => [
			[
				Vec2.get(0, 0),
				Vec2.get(71, 0),
				Vec2.get(37, 54),
				Vec2.get(37, 105),
				Vec2.get(58, 108),
				Vec2.get(13, 108),
				Vec2.get(34, 105),
				Vec2.get(34, 54),
			],
			[
				Vec2.get(0, 0), Vec2.get(3, 0), Vec2.get(34, 47), Vec2.get(37, 47), Vec2.get(69, 0), Vec2.get(71, 0), Vec2.get(37, 54), Vec2.get(37, 105),
				Vec2.get(58, 108), Vec2.get(13, 108), Vec2.get(34, 105), Vec2.get(34, 54),
			]
		],
	];

	public function new(x:Float, y:Float, asset:FlxGraphicAsset, bodyAsset:FlxGraphicAsset, cellSize:Float = 20, subSize:Float = 5, ?type:BodyType,
			includeAssetBodyPhysicsShape:Bool = false, ?material:Material) {
		originalAsset = asset;
		super(x, y, asset);
		if (type == null) {
			type = BodyType.DYNAMIC;
		}

		this.cellSize = cellSize;
		this.subSize = subSize;

		this.type = type;

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
			if (vertices.exists(originalAsset)) {
				buildNewBody(vertices.get(originalAsset)[0], new InteractionFilter(CGroups.FILLER, ~(CGroups.SHELL | CGroups.FILLER)), air());
			} else {
				// TODO: MW this interaction filter is most likely wrong, ugh
				var count = buildBody(bitmapFiller, new InteractionFilter(CGroups.FILLER, ~(CGroups.SHELL | CGroups.FILLER)), cellSize * 2);
				trace('asset: ${originalAsset} had ${count} shapes for the click shapes');
			}
		}
		if (vertices.exists(originalAsset)) {
			buildNewBody(vertices.get(originalAsset)[1], new InteractionFilter(CGroups.SHELL, ~(CGroups.FILLER)),
				material != null ? material : Material.glass());
		} else {
			// TODO: MW this interaction filter is most likely wrong, ugh
			var count = buildBody(bitmapShell, new InteractionFilter(CGroups.SHELL, ~(CGroups.FILLER)), cellSize);
			trace('asset: ${originalAsset} had ${count} shapes for the physics shapes');
		}

		body.space = FlxNapeSpace.space;
		body.userData.data = this;
		body.isBullet = true;
	}

	private function buildNewBody(vertices:Array<Vec2>, collisionFilter:InteractionFilter, mat:Material) {
		var poly = new GeomPoly();
		for (v in vertices) {
			poly.push(v);
		}

		var resultPolys = poly.convexDecomposition(true);
		trace('asset "${originalAsset} adding ${resultPolys.length} to body');

		for (poly in resultPolys) {
			var bodyPoly = new Polygon(poly);
			// NOTE: This is to try to align the body with the sprite better
			for (vert in bodyPoly.localVerts) {
				vert.x -= width / 2;
				vert.y -= height / 2;
			}
			bodyPoly.filter = collisionFilter;
			bodyPoly.material = mat;
			body.shapes.add(bodyPoly);
		}
	}

	/**
	 * Construct a polygon given a sprite's bitmap data, then add the shape to the main body with the given collision filter
	 * @param bitmap
	 * @param collisionFilter
	 */
	private function buildBody(bitmap:BitmapData, collisionFilter:InteractionFilter, cellSize:Float):Int {
		var shapeCount = 0;

		isoBounds.width = cellSize;
		isoBounds.height = cellSize;

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
						shapeCount++;

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

		return shapeCount;
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
