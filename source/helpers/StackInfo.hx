package helpers;

import entities.PhysicsThing;

class StackInfo {
	public var heightItem:PhysicsThing;
	public var itemCount:Int;

	public function new(h:PhysicsThing, count:Int) {
		heightItem = h;
		itemCount = count;
	}
}
