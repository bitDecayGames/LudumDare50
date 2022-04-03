package states.dev;

import entities.SoftBody;
import nape.shape.Edge;
import nape.geom.Vec2;
import flixel.addons.nape.FlxNapeSpace;
import nape.constraint.PivotJoint;
import nape.shape.Polygon;
import nape.phys.Body;
import entities.Heightometer;
import entities.TrayHand;
import nape.phys.BodyType;
import nape.phys.Compound;
import entities.PhysicsThing;
import entities.PickingHand;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import nape.geom.GeomPoly;

using extensions.FlxStateExt;

class SoftBodyState extends FlxTransitionableState {
	override public function create() {
		super.create();
		PlayState.InitState();

		var bg = new FlxSprite(AssetPaths.background__png);
		add(bg);

		init();
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

	function init() {
		var w = FlxG.width;
		var h = FlxG.height;
		var space = FlxNapeSpace.space;
		// Set debug draw to disable angle indicators and constraints
		var staticBody = new Body(BodyType.STATIC);
		// Add a water level at bottom
		var water = new Polygon(Polygon.rect(0, h, w, -150));
		water.fluidEnabled = true;
		water.fluidProperties.density = 3;
		water.fluidProperties.viscosity = 5;
		water.body = staticBody;
		// Add middle platform
		var platform = new Polygon(Polygon.rect(200, h - 3.5 * 60, w - 400, 1));
		platform.body = staticBody;
		staticBody.space = space;
		add(SoftBody.NewFrenchOmlette(400, h - 500));
		add(SoftBody.NewDollupOfMashedPotatoes(500, h - 500));
		add(SoftBody.NewDumpling(600, h - 500));
		add(SoftBody.NewSteak(700, h - 500));
	}
}
