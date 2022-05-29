SetFactory("OpenCASCADE");

// *************************** PARAMETERS DEFINES **********************

DefineConstant [
mea_inner_radius = {1.0, Name "Parameters/Mea inner radius"},
mea_outer_radius = {1.3, Name "Parameters/Mea outer radius"} ,
mea_base_thickness =  {1.0, Name "Parameters/Mea base thickness"}
mea_ring_height = {3.0, Name "Parameters/Mea ring height"}
];

// **************************** NAMES DEFINES **************************

// POINTS_NAMES
DefineConstant [
BASE_BOTTOM_POINT_CENTER = {1},
BASE_BOTTOM_POINT_1 = {2},
BASE_BOTTOM_POINT_2 = {3},
BASE_TOP_POINT_CENTER = {4},
BASE_TOP_POINT_1 = {5},
BASE_TOP_POINT_2 = {6},
RING_INNER_POINT_1 = {7},
RING_INNER_POINT_2 = {8}
];

// CURVE_NAMES
DefineConstant [
BASE_BOTTOM_CURVE = {1},
BASE_TOP_CURVE = {2}
RING_INNER_CURVE = {3}
];

// SURFACE_NAMES
DefineConstant [
BASE_BOTTOM_SURF = {1},
BASE_TOP_SURF = {2},
RING_BASE_SURF = {3},
BASE_CYLINDER_SURF = {4}
];

// VOLUME_NAMES
DefineConstant [
BASE_VOLUME = {1}
];

// **************************** BASE ***********************************

// BOTTOM
Point(BASE_BOTTOM_POINT_CENTER) = {0, 0, -mea_base_thickness};
Point(BASE_BOTTOM_POINT_1) = {mea_outer_radius, 0, -mea_base_thickness};
Point(BASE_BOTTOM_POINT_2) = {-mea_outer_radius, 0, -mea_base_thickness};

Circle(1) = {BASE_BOTTOM_POINT_1, BASE_BOTTOM_POINT_CENTER, BASE_BOTTOM_POINT_2};
Circle(2) = {BASE_BOTTOM_POINT_2, BASE_BOTTOM_POINT_CENTER, BASE_BOTTOM_POINT_1};

Curve Loop (BASE_BOTTOM_CURVE) = {1, 2};
Physical Curve (BASE_BOTTOM_CURVE) = {BASE_BOTTOM_CURVE};

Plane Surface (BASE_BOTTOM_SURF) = {BASE_BOTTOM_CURVE};
Physical Surface (BASE_BOTTOM_SURF) = {BASE_BOTTOM_SURF};

// TOP
Point(BASE_TOP_POINT_CENTER) = {0, 0, 0};
Point(BASE_TOP_POINT_1) = {mea_outer_radius, 0, 0};
Point(BASE_TOP_POINT_2) = {-mea_outer_radius, 0, 0};
Circle(3) = {BASE_TOP_POINT_1, BASE_TOP_POINT_CENTER, BASE_TOP_POINT_2};
Circle(4) = {BASE_TOP_POINT_2, BASE_TOP_POINT_CENTER, BASE_TOP_POINT_1};

Curve Loop (BASE_TOP_CURVE) = {3, 4};

Physical Curve (BASE_TOP_CURVE) = {BASE_TOP_CURVE};

Plane Surface (BASE_TOP_SURF) = {BASE_TOP_CURVE};
Physical Surface (BASE_TOP_SURF) = {BASE_TOP_SURF};

// RING

Point(RING_INNER_POINT_1) = {mea_inner_radius, 0, 0};
Point(RING_INNER_POINT_2) = {-mea_inner_radius, 0, 0};

Circle(5) = {RING_INNER_POINT_1, BASE_TOP_POINT_CENTER, RING_INNER_POINT_2};
Circle(6) = {RING_INNER_POINT_2, BASE_TOP_POINT_CENTER, RING_INNER_POINT_1};
Curve Loop (RING_INNER_CURVE) = {5, 6};

Plane Surface (RING_BASE_SURF) = {BASE_TOP_CURVE,
                                  RING_INNER_CURVE};

Physical Surface (RING_BASE_SURF) = {RING_BASE_SURF};


// CYLINDER
Cylinder (BASE_CYLINDER_SURF) = {0, 0, 0, 0, 0, -mea_base_thickness, mea_outer_radius};
Physical Surface(BASE_CYLINDER_SURF) = {BASE_CYLINDER_SURF};

Surface Loop (2) = {BASE_BOTTOM_SURF, BASE_CYLINDER_SURF, BASE_TOP_SURF};
Volume (BASE_VOLUME) = {2};

// ***************************** MESH **********************************

Mesh.Algorithm = 8;
Mesh.RecombineAll = 1;
Mesh.SaveParametric = 0;
Mesh.SaveAll = 1;
