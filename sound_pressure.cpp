#define USE(X) (void)(X);

#include <deal.II/dofs/dof_handler.h>
#include <deal.II/dofs/dof_renumbering.h>
#include <deal.II/dofs/dof_tools.h>
#include <deal.II/grid/grid_generator.h>
#include <deal.II/grid/grid_in.h>
#include <deal.II/grid/grid_out.h>
#include <deal.II/grid/tria.h>

#include <fstream>
#include <iostream>

using namespace dealii;
using std::cout, std::endl;

class SoundPressure {
 public:
  SoundPressure();
  void run();

 private:
  /**
   * @brief         Create the mesh structure.
   * @param gmsh:   load extern mesh [default false]
   * @param path:   path of the extern mesh
   *
   * @return void
   */
  void make_grid(bool gmsh = false, std::string path = "sound_pressure.msh");
  void setup_system();

  Triangulation<3> triangulation;

  /* Mesh parameters
   * UNITS:
   * length - cm
   *
   */
  float mea_base_side_length = 5;
  float mea_base_thickness = 0.1;
  float mea_ring_outer_radius = 2.2;
};

SoundPressure::SoundPressure() {}

void SoundPressure::make_grid(bool gmsh, std::string path) {
  if (gmsh) {
    std::ifstream mesh(path);
    GridIn<3> grid_in(triangulation);
    grid_in.read_msh(mesh);
  } else {
    /*
     * the following approach is to generate the mesh by extruding a 2d sketch
     * all by dealii script commands.
     */

    // TEMPORARY 2D SKETCH

    // BASE
    Point<3> corner1 = {-mea_base_side_length / 2, mea_base_side_length / 2, 0};
    Point<3> corner2 = {mea_base_side_length / 2, -mea_base_side_length / 2,
                        mea_base_thickness};
    Triangulation<2> sketch;
    GridGenerator::plate_with_a_hole(sketch, mea_ring_outer_radius,
                                     mea_base_side_length);
    GridGenerator::extrude_triangulation(sketch, {0, 0, 1}, triangulation);
    triangulation.refine_global(5);
  }
  GridOut grid_out;
  std::ofstream out("sound_pressure.vtu");
  grid_out.write_vtu(triangulation, out);
}

void SoundPressure::setup_system() {}

void SoundPressure::run() { make_grid(); }

int main(int argc, char **argv) {
  USE(argc)
  USE(argv)

  try {
    SoundPressure sound_pressure;
    sound_pressure.run();
  } catch (std::exception &exc) {
    cout << "Abort!" << endl
         << "--------------------------------------------------" << endl
         << "Exception occurred." << endl
         << exc.what() << endl
         << "--------------------------------------------------" << endl;
    return -1;
  }

  return 0;
}
