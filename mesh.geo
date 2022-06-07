SetFactory("OpenCASCADE");

// *************************** PARAMETERS DEFINES **********************

DefineConstant [
mea_ring_inner_radius = {0.9, Name "Parameters/Mea ring inner radius"} ,
mea_ring_thickness = {0.1, Name "Parameters/Mea ring thickness"} ,
mea_base_thickness =  {0.1, Name "Parameters/Mea base thickness"} ,
mea_ring_height = {0.5, Name "Parameters/Mea ring height"},
mea_base_side_length = {5.0, Name "Parameters/Mea base side length"},
mea_water_height = {0.3, Name "Parameters/Mea water height"}
];

mea_ring_outer_radius = mea_ring_inner_radius + mea_ring_thickness;

// ***************************** GEOMETRY ******************************

origin = newp; Point(origin) = {0, 0, 0};

innerp1 = newp; Point(innerp1) = {-mea_ring_inner_radius, 0, 0};    
innerp2 = newp; Point(innerp2) = {0, mea_ring_inner_radius, 0};    
innerp3 = newp; Point(innerp3) = {mea_ring_inner_radius, 0, 0};    
innerp4 = newp; Point(innerp4) = {0, -mea_ring_inner_radius, 0}; 

innerc1 = newl; Circle(innerc1) = {innerp1, origin, innerp2};                        
innerc2 = newl; Circle(innerc2) = {innerp2, origin, innerp3};                        
innerc3 = newl; Circle(innerc3) = {innerp3, origin, innerp4};                        
innerc4 = newl; Circle(innerc4) = {innerp4, origin, innerp1};                        

innerc = newll; Curve Loop(innerc) = {innerc1, innerc2, innerc3, innerc4};                      

outerp1 = newp; Point(outerp1) = {-mea_ring_outer_radius, 0, 0};    
outerp2 = newp; Point(outerp2) = {0, mea_ring_outer_radius, 0};    
outerp3 = newp; Point(outerp3) = {mea_ring_outer_radius, 0, 0};    
outerp4 = newp; Point(outerp4) = {0, -mea_ring_outer_radius, 0};    

outerc1 = newl; Circle(outerc1) = {outerp1, origin, outerp2};                      
outerc2 = newl; Circle(outerc2) = {outerp2, origin, outerp3};                     
outerc3 = newl; Circle(outerc3) = {outerp3, origin, outerp4};                      
outerc4 = newl; Circle(outerc4) = {outerp4, origin, outerp1};                     

outerc = newl; Curve Loop(outerc) = {outerc1, outerc2, outerc3, outerc4};                       
rings = news; Plane Surface(rings) = {outerc, innerc};

basep1 = newp; Point(basep1) = {-mea_base_side_length/2, mea_base_side_length/2, 0};
basep2 = newp; Point(basep2) = {mea_base_side_length/2, mea_base_side_length/2, 0};
basep3 = newp; Point(basep3) = {mea_base_side_length/2, -mea_base_side_length/2, 0};
basep4 = newp; Point(basep4) = {-mea_base_side_length/2, -mea_base_side_length/2, 0};

basec1 = newl; Line(basec1) = {basep1, basep2};
basec2 = newl; Line(basec2) = {basep2, basep3};
basec3 = newl; Line(basec3) = {basep3, basep4};
basec4 = newl; Line(basec4) = {basep4, basep1};

basec = newll; Curve Loop(basec) = {basec1, basec2, basec3, basec4};

bases = news; Plane Surface(bases) = {basec};

waters = news; Plane Surface(waters) = {innerc};

// RING


ring_entities[] = Extrude {0, 0, mea_ring_height} {
  Surface{rings}; Layers {5}; Recombine;
};

Physical Surface(1) = {rings, ring_entities[0], ring_entities[2],
                       ring_entities[3], ring_entities[4], ring_entities[5],
                       ring_entities[6], ring_entities[7], ring_entities[8],
                       ring_entities[9]};

ringvs = newsl; Surface Loop (ringvs) = {rings, ring_entities[0], ring_entities[2],
                       ring_entities[3], ring_entities[4], ring_entities[5],
                       ring_entities[6], ring_entities[7], ring_entities[8],
                       ring_entities[9]};

ringv = newv; Volume (ringv) = {ringvs};
Physical Volume (2) = {ringv};


// BASE

base_entities[] = Extrude {0, 0, -mea_base_thickness} {
  Surface{bases}; Layers {5}; Recombine;
};

Physical Surface(3) = {bases, base_entities[0], base_entities[2],
                       base_entities[3], base_entities[4], base_entities[5]};

basevs = newsl; Surface Loop (basevs) = {bases, base_entities[0], base_entities[2],
                       base_entities[3], base_entities[4], base_entities[5]};

basev = newv; Volume (basev) = {basevs};
Physical Volume (4) = {basev};

// WATER

water_entities[] = Extrude {0, 0, mea_water_height} {
  Surface{waters}; Layers {5}; Recombine;
};

Physical Surface(5) = {waters, water_entities[0], water_entities[2],
                      water_entities[4], water_entities[4], water_entities[5]};

watervs = newsl; Surface Loop (watervs) = {waters, water_entities[0], water_entities[2],
                      water_entities[3], water_entities[4], water_entities[5]};

waterv = newv; Volume (waterv) = {watervs};
Physical Volume (6) = {waterv};

// ***************************** MESH **********************************

Mesh.Algorithm = 8;                   // Frontal-Delunay (all quads)
Mesh.SubdivisionAlgorith = 2;         // all hexahedra
Mesh.RecombineAll = 1;
Mesh.SaveParametric = 0;
Mesh.SaveAll = 1;
// Mesh.Color.Hexahedra = {r, g, b};
