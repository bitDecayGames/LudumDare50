package sort;

import flixel.FlxSprite;
import entities.PhysicsThing;

class ItemSorter {
	static var sortOrder = [
		AssetPaths.LBowl__png => 0,
		AssetPaths.MBowl__png => 1,
		AssetPaths.SBowl__png => 2,
		AssetPaths.Stein__png => 3,
		AssetPaths.RoundMug__png => 4,
		AssetPaths.SquareMug__png => 5,
		AssetPaths.Pint__png => 6,
		AssetPaths.Martini__png => 7,
		AssetPaths.Tall__png => 8,
		AssetPaths.wineGlass__png => 9,
		AssetPaths.Shot__png => 10,
		AssetPaths.LPlate__png => 11,
		AssetPaths.MPlate__png => 12,
		AssetPaths.SPlate__png => 13,
		AssetPaths.fork__png => 14,
		AssetPaths.knife__png => 15,
		AssetPaths.spoon__png => 16,
		AssetPaths.Wine__png => 17,
	];

	static public function sortItems(order:Int, a:FlxSprite, b:FlxSprite):Int {
		if (Std.isOfType(a, PhysicsThing) && Std.isOfType(b, PhysicsThing)) {
			if (sortOrder.get(cast(a, PhysicsThing).originalAsset) < sortOrder.get(cast(b, PhysicsThing).originalAsset)) {
				return order;
			} else if (sortOrder.get(cast(a, PhysicsThing).originalAsset) > sortOrder.get(cast(b, PhysicsThing).originalAsset)) {
				return -order;
			}
		} else if (Std.isOfType(a, PhysicsThing)) {
			return order;
		} else if (Std.isOfType(b, PhysicsThing)) {
			return -order;
		}
		return 0;
	}
}
