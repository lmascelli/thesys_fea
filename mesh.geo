radius = 1.0;

Point(1) = {0, 0, 0};
Point(2) = {radius, 0, 0};
Point(3) = {-radius, 0, 0};
Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 2};

Curve Loop (1) = {1, 2};

Physical Curve (0) = {1};

Plane Surface (1) = {1};
Physical Surface(1) = {1};

Mesh.Algorithm = 8;
Mesh.RecombineAll = 1;
Mesh.SaveParametric = 0;
Mesh.SaveAll = 1;
