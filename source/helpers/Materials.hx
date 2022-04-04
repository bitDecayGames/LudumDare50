package helpers;

import nape.phys.Material;

/**
 * Construct a new Material object.
 *
 * elasticity The coeffecient of elasticity for material.
 *                   (default 0.0)
 * dynamicFriction The coeffecient of dynamic friction for
 *                        material. (default 1.0)
 * staticFriction The coeffecient of static friction for
 *                       material. (default 2.0)
 * density The density of the shape using this material in units
 *                of g/pixel/pixel. (default 1.0)
 * rollingFriction The coeffecient of rolling friction for material
 *                        used in circle friction computations. (default 0.001)
 * @return The constructed Material object.
 */
function jakeTanium() {
	return new Material(0.4, 0.95, 3.0, 8, 0.001);
}

function air() {
	return new Material(0, 0, 0, 0.001, 0.001);
}

var GLASS_MATERIAL_NAME = "glass";
var METAL_MATERIAL_NAME = "metal";
var FOOD_MATERIAL_NAME = "food";
