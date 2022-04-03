package constants;

import nape.callbacks.CbType;

// Callback types
class CbTypes {
	public static var CB_ITEM:CbType;

	public static function initTypes() {
		CB_ITEM = new CbType();
		trace("CB_ITEM is " + CB_ITEM);
	}
}
