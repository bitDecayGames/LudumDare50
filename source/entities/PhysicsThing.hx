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

    // @formatter:off
	private var vertices = [
        AssetPaths.SBowl__png => [
            [
                Vec2.get(0,0),
                Vec2.get(92,0),
                Vec2.get(87,12),
                Vec2.get(78,20),
                Vec2.get(67,25),
                Vec2.get(60,27),
                Vec2.get(32,27),
                Vec2.get(25,25),
                Vec2.get(14,20),
                Vec2.get(5,12),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(2,0),
                Vec2.get(7,10),
                Vec2.get(16,18),
                Vec2.get(27,23),
                Vec2.get(33,25),
                Vec2.get(59,25),
                Vec2.get(65,23),
                Vec2.get(76,18),
                Vec2.get(85,10),
                Vec2.get(90,0),
                Vec2.get(92,0),
                Vec2.get(87,12),
                Vec2.get(78,20),
                Vec2.get(67,25),
                Vec2.get(60,27),
                Vec2.get(32,27),
                Vec2.get(25,25),
                Vec2.get(14,20),
                Vec2.get(5,12),
            ]
        ],
		AssetPaths.MBowl__png => [
            [
                Vec2.get(0,0),
                Vec2.get(120,0),
                Vec2.get(115,14),
                Vec2.get(108,22),
                Vec2.get(94,31),
                Vec2.get(80,36),
                Vec2.get(40,36),
                Vec2.get(26,31),
                Vec2.get(12,22),
                Vec2.get(5,14),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(2,0),
                Vec2.get(6,10),
                Vec2.get(16,21),
                Vec2.get(28,29),
                Vec2.get(40,34),
                Vec2.get(80,34),
                Vec2.get(92,29),
                Vec2.get(104,21),
                Vec2.get(114,10),
                Vec2.get(118,0),
                Vec2.get(120,0),
                Vec2.get(115,14),
                Vec2.get(108,22),
                Vec2.get(94,31),
                Vec2.get(80,36),
                Vec2.get(40,36),
                Vec2.get(26,31),
                Vec2.get(12,22),
                Vec2.get(5,14),
            ]
        ],
		AssetPaths.LBowl__png => [
            [
                Vec2.get(0,0),
                Vec2.get(159,0),
                Vec2.get(153,17),
                Vec2.get(138,32),
                Vec2.get(123,40),
                Vec2.get(108,45),
                Vec2.get(51,45),
                Vec2.get(36,40),
                Vec2.get(21,32),
                Vec2.get(6,17),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(3,0),
                Vec2.get(9,15),
                Vec2.get(22,27),
                Vec2.get(38,37),
                Vec2.get(53,42),
                Vec2.get(106,42),
                Vec2.get(121,37),
                Vec2.get(137,27),
                Vec2.get(150,15),
                Vec2.get(156,0),
                Vec2.get(159,0),
                Vec2.get(153,17),
                Vec2.get(138,32),
                Vec2.get(123,40),
                Vec2.get(108,45),
                Vec2.get(51,45),
                Vec2.get(36,40),
                Vec2.get(21,32),
                Vec2.get(6,17),
            ]
        ],
		AssetPaths.SPlate__png => [
            [
                Vec2.get(0,-3),
                Vec2.get(86,-3),
                Vec2.get(86,6),
                Vec2.get(0,6),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(13,1),
                Vec2.get(73,1),
                Vec2.get(86,0),
                Vec2.get(86,2),
                Vec2.get(72,3),
                Vec2.get(14,3),
                Vec2.get(0,2),
            ]
        ],
		AssetPaths.MPlate__png => [
            [
                Vec2.get(0,-3),
                Vec2.get(114,-3),
                Vec2.get(114,6),
                Vec2.get(0,6),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(13,1),
                Vec2.get(101,1),
                Vec2.get(114,0),
                Vec2.get(114,2),
                Vec2.get(100,3),
                Vec2.get(14,3),
                Vec2.get(0,2),
            ]
        ],
		AssetPaths.LPlate__png => [
            [
                Vec2.get(0,-3),
                Vec2.get(153,-3),
                Vec2.get(153,6),
                Vec2.get(0,6),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(13,1),
                Vec2.get(140,1),
                Vec2.get(153,0),
                Vec2.get(153,2),
                Vec2.get(139,3),
                Vec2.get(14,3),
                Vec2.get(0,2),
            ]
        ],
		AssetPaths.fork__png => [
            [
                Vec2.get(0,8),
                Vec2.get(39,15),
                Vec2.get(51,15),
                Vec2.get(61,7),
                Vec2.get(76,-3),
                Vec2.get(90,-3),
                Vec2.get(132,4),
                Vec2.get(153,4),
                Vec2.get(153,13),
                Vec2.get(132,13),
                Vec2.get(90,6),
                Vec2.get(76,6),
                Vec2.get(63,11),
                Vec2.get(51,18),
                Vec2.get(38,18),
            ],
            [
                Vec2.get(0,8),
                Vec2.get(39,15),
                Vec2.get(51,15),
                Vec2.get(61,7),
                Vec2.get(76,0),
                Vec2.get(90,0),
                Vec2.get(132,7),
                Vec2.get(153,7),
                Vec2.get(153,10),
                Vec2.get(132,10),
                Vec2.get(90,3),
                Vec2.get(76,3),
                Vec2.get(62,9),
                Vec2.get(51,18),
                Vec2.get(38,18),
            ]
        ],
		AssetPaths.knife__png => [
            [
                Vec2.get(0,0),
                Vec2.get(120,-3),
                Vec2.get(204,-3),
                Vec2.get(204,10),
                Vec2.get(120,10),
                Vec2.get(0,7),
            ],
            [
                Vec2.get(0,3),
                Vec2.get(29,2),
                Vec2.get(114,2),
                Vec2.get(120,0),
                Vec2.get(200,0),
                Vec2.get(204,2),
                Vec2.get(204,5),
                Vec2.get(200,7),
                Vec2.get(120,7),
                Vec2.get(114,5),
                Vec2.get(29,5),
                Vec2.get(0,4),
            ]
        ],
		AssetPaths.spoon__png => [
            [
                Vec2.get(0,9),
                Vec2.get(53,8),
                Vec2.get(70,-3),
                Vec2.get(84,-3),
                Vec2.get(126,4),
                Vec2.get(147,4),
                Vec2.get(147,13),
                Vec2.get(126,13),
                Vec2.get(84,6),
                Vec2.get(70,6),
                Vec2.get(55,12),
                Vec2.get(47,16),
                Vec2.get(34,21),
                Vec2.get(21,21),
                Vec2.get(9,18),
            ],
            [
                Vec2.get(0,9),
                Vec2.get(2,9),
                Vec2.get(10,16),
                Vec2.get(21,19),
                Vec2.get(34,19),
                Vec2.get(47,14),
                Vec2.get(53,8),
                Vec2.get(70,0),
                Vec2.get(84,0),
                Vec2.get(126,7),
                Vec2.get(147,7),
                Vec2.get(147,10),
                Vec2.get(126,10),
                Vec2.get(84,3),
                Vec2.get(70,3),
                Vec2.get(54,10),
                Vec2.get(47,16),
                Vec2.get(34,21),
                Vec2.get(21,21),
                Vec2.get(9,18),
            ]
        ],
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
                Vec2.get(0, 0),
                Vec2.get(3, 0),
                Vec2.get(34, 47),
                Vec2.get(37, 47),
                Vec2.get(69, 0),
                Vec2.get(71, 0),
                Vec2.get(37, 54),
                Vec2.get(37, 105),
                Vec2.get(58, 108),
                Vec2.get(13, 108),
                Vec2.get(34, 105),
                Vec2.get(34, 54),
            ],
        ],
		AssetPaths.Pint__png => [
            [
                Vec2.get(0, 0),
                Vec2.get(54, 0),
                Vec2.get(54, 31),
                Vec2.get(46, 95),
                Vec2.get(8, 95),
                Vec2.get(0, 31),
            ],
            [
                Vec2.get(0, 0),
                Vec2.get(2, 0),
                Vec2.get(10, 89),
                Vec2.get(44, 89),
                Vec2.get(52, 0),
                Vec2.get(54, 0),
                Vec2.get(54, 31),
                Vec2.get(46, 95),
                Vec2.get(8, 95),
                Vec2.get(0, 31),
            ]
        ],
		AssetPaths.RoundMug__png => [
            [
                Vec2.get(0,0),
                Vec2.get(55,0),
                Vec2.get(55,14),
                Vec2.get(63,16),
                Vec2.get(69,25),
                Vec2.get(69,34),
                Vec2.get(65,41),
                Vec2.get(56,45),
                Vec2.get(49,45),
                Vec2.get(45,52),
                Vec2.get(36,59),
                Vec2.get(19,59),
                Vec2.get(10,52),
                Vec2.get(4,42),
                Vec2.get(0,25),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(2,0),
                Vec2.get(2,23),
                Vec2.get(6,37),
                Vec2.get(12,49),
                Vec2.get(20,57),
                Vec2.get(34,57),
                Vec2.get(43,49),
                Vec2.get(49,37),
                Vec2.get(53,23),
                Vec2.get(53,0),
                Vec2.get(55,0),
                Vec2.get(55,14),
                Vec2.get(63,16),
                Vec2.get(69,25),
                Vec2.get(69,34),
                Vec2.get(65,41),
                Vec2.get(56,45),
                Vec2.get(49,45),
                Vec2.get(45,52),
                Vec2.get(36,59),
                Vec2.get(19,59),
                Vec2.get(10,52),
                Vec2.get(4,42),
                Vec2.get(0,25),
            ]
        ],
		AssetPaths.Shot__png => [
            [
                Vec2.get(0,0),
                Vec2.get(28,0),
                Vec2.get(24,32),
                Vec2.get(4,32),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(2,0),
                Vec2.get(6,25),
                Vec2.get(22,25),
                Vec2.get(26,0),
                Vec2.get(28,0),
                Vec2.get(24,32),
                Vec2.get(4,32),
            ]
        ],
		AssetPaths.SquareMug__png => [
            [
                Vec2.get(15,0),
                Vec2.get(53,0),
                Vec2.get(53,46),
                Vec2.get(15,46),
                Vec2.get(15,38),
                Vec2.get(11,34),
                Vec2.get(5,30),
                Vec2.get(0,23),
                Vec2.get(0,14),
                Vec2.get(6,6),
                Vec2.get(15,6),
            ],
            [
                Vec2.get(15,0),
                Vec2.get(17,0),
                Vec2.get(17,39),
                Vec2.get(51,39),
                Vec2.get(51,0),
                Vec2.get(53,0),
                Vec2.get(53,46),
                Vec2.get(15,46),
                Vec2.get(15,38),
                Vec2.get(11,34),
                Vec2.get(5,30),
                Vec2.get(0,23),
                Vec2.get(0,14),
                Vec2.get(6,6),
                Vec2.get(15,6),
            ]
        ],
		AssetPaths.Stein__png => [
            [
                Vec2.get(0,0),
                Vec2.get(89, 0),
                Vec2.get(89, 13),
                Vec2.get(105,18),
                Vec2.get(116,29),
                Vec2.get(120,40),
                Vec2.get(120,50),
                Vec2.get(116,61),
                Vec2.get(105,72),
                Vec2.get(89,77),
                Vec2.get(89,122),
                Vec2.get(86,126),
                Vec2.get(3,126),
                Vec2.get(0,122),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(2,0),
                Vec2.get(2,113),
                Vec2.get(6,118),
                Vec2.get(83,118),
                Vec2.get(87,113),
                Vec2.get(87, 0),
                Vec2.get(89, 0),
                Vec2.get(89, 13),
                Vec2.get(105,18),
                Vec2.get(116,29),
                Vec2.get(120,40),
                Vec2.get(120,50),
                Vec2.get(116,61),
                Vec2.get(105,72),
                Vec2.get(89,77),
                Vec2.get(89,122),
                Vec2.get(86,126),
                Vec2.get(3,126),
                Vec2.get(0,122),
            ]
        ],
		AssetPaths.Tall__png => [
            [
                Vec2.get(0,0),
                Vec2.get(48,0),
                Vec2.get(48,116),
                Vec2.get(0,116),
            ],
            [
                Vec2.get(0,0),
                Vec2.get(2,0),
                Vec2.get(2,109),
                Vec2.get(46,109),
                Vec2.get(46,0),
                Vec2.get(48,0),
                Vec2.get(48,116),
                Vec2.get(0,116),
            ]
        ],
        AssetPaths.trayHand__png => [
            [],
            [
                Vec2.get(0,0),
                Vec2.get(294,0),
                Vec2.get(294,4),
                Vec2.get(0,4),
            ],
        ]
	];
    // @formatter:on
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
				buildBody(bitmapFiller, new InteractionFilter(CGroups.FILLER, ~(CGroups.SHELL | CGroups.FILLER)), cellSize * 2);
			}
		}
		if (vertices.exists(originalAsset)) {
			buildNewBody(vertices.get(originalAsset)[1], new InteractionFilter(CGroups.SHELL, ~(CGroups.FILLER)),
				material != null ? material : Material.glass());
		} else {
			// TODO: MW this interaction filter is most likely wrong, ugh
			buildBody(bitmapShell, new InteractionFilter(CGroups.SHELL, ~(CGroups.FILLER)), cellSize);
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
