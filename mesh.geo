SetFactory("OpenCASCADE");

// *************************** PARAMETERS DEFINES **********************

DefineConstant [
mea_ring_inner_radius = {1.3, Name "Parameters/Mea inner radius"} ,
mea_ring_outer_radius = {1.5, Name "Parameters/Mea outer radius"} ,
mea_base_thickness =  {1.0, Name "Parameters/Mea base thickness"} ,
mea_ring_height = {3.0, Name "Parameters/Mea ring height"},
mea_base_side_length = {5.0, Name "Parameters/Mea base side length"},
mea_water_height = {1.0, Name "Parameters/Mea water height"}
];

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

ring_entities[] = Extrude {0, 0, mea_ring_height} {
  Surface{rings}; Layers {5}; Recombine;
};

Physical Surface(1) = {rings, ring_entities[0], ring_entities[2],
                       ring_entities[3], ring_entities[4], ring_entities[5]};

ringvs = newsl; Surface Loop (ringvs) = {rings, ring_entities[0], ring_entities[2],
                       ring_entities[3], ring_entities[4], ring_entities[5]};

ringv = newv; Volume (ringv) = {ringvs};
Physical Volume (1) = {ringv};

Color Green {Physical Volume {1};}

base_entities[] = Extrude {0, 0, -mea_base_thickness} {
  Surface{bases}; Layers {5}; Recombine;
};

Physical Surface(2) = {bases, base_entities[0], base_entities[2],
                       base_entities[3], base_entities[4], base_entities[5]};

basevs = newsl; Surface Loop (basevs) = {bases, base_entities[0], base_entities[2],
                       base_entities[3], base_entities[4], base_entities[5]};

basev = newv; Volume (basev) = {basevs};
Physical Volume (2) = {basev};

Color Red {Physical Volume {2};}

water_entities[] = Extrude {0, 0, mea_water_height} {
  Surface{waters}; Layers {5}; Recombine;
};

Physical Surface(3) = {waters, water_entities[0], water_entities[1],
                      water_entities[2]};

watervs = newsl; Surface Loop (watervs) = {waters, water_entities[0], water_entities[1],
                      water_entities[2]};

waterv = newv; Volume (waterv) = {watervs};
Physical Volume (3) = {waterv};
Color Blue {Physical Volume {3};}                      



// ***************************** MESH **********************************

Mesh.Algorithm = 8;
Mesh.RecombineAll = 1;
Mesh.SaveParametric = 0;
Mesh.SaveAll = 1;
