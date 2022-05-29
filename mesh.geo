SetFactory("OpenCASCADE");

DefineConstant[
mea_inner_radius = {1.0, Name "Parameters/Mea inner radius"},
mea_outer_radius = {1.3, Name "Parameters/Mea outer radius"} ,
mea_base_thickness =  {1.0, Name "Parameters/Mea base thickness"}
];

// BASE BOTTOM
Point(1) = {0, 0, -mea_base_thickness};
Point(2) = {mea_outer_radius, 0, -mea_base_thickness};
Point(3) = {-mea_outer_radius, 0, -mea_base_thickness};
Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 2};

Curve Loop (1) = {1, 2};
Physical Curve (1) = {1};

Plane Surface (1) = {1};
Physical Surface (1) = {1};

// BASE TOP
Point(4) = {0, 0, 0};
Point(5) = {mea_inner_radius, 0, 0};
Point(6) = {-mea_inner_radius, 0, 0};
Point(7) = {mea_outer_radius, 0, 0};
Point(8) = {-mea_outer_radius, 0, 0};
Circle(3) = {5, 4, 6};
Circle(4) = {6, 4, 5};
Circle(5) = {7, 4, 8};
Circle(6) = {8, 4, 7};

Curve Loop (2) = {3, 4};
Curve Loop (3) = {5, 6};

Physical Curve (2) = {2};
Physical Curve (3) = {3};

Plane Surface (2) = {2, 3};
Plane Surface (3) = {3};

Physical Surface (2) = {2};
Physical Surface (3) = {3};

// BASE BORDERS
Cylinder (4) = {0, 0, 0, 0, 0, -mea_base_thickness, mea_outer_radius};
Physical Surface(4) = {4};

Surface Loop (2) = {1, 2, 3 ,4};
Volume (1) = {1};

Mesh.Algorithm = 8;
Mesh.RecombineAll = 1;
Mesh.SaveParametric = 0;
Mesh.SaveAll = 1;
