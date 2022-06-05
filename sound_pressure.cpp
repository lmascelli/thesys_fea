// That's just for avoiding some annoying unused variable warnings.
#define USE(X) (void)(X);

#include <deal.II/dofs/dof_handler.h>
#include <deal.II/dofs/dof_renumbering.h>
#include <deal.II/dofs/dof_tools.h>
#include <deal.II/grid/grid_generator.h>
#include <deal.II/grid/grid_in.h>
#include <deal.II/grid/grid_out.h>
#include <deal.II/grid/grid_tools.h>
#include <deal.II/grid/tria.h>

#include <fstream>
#include <iostream>

using namespace dealii;
using std::cout, std::endl;

class SoundPressure {
 public:
  /**
   * @brief SoundPressure class has the goal to encapsulate all the steps
   *        of the FEM for this problems keeping that separates.
   *        The only public method is run, which start the computation and
   *        returns the data collected.
   * @constructor
   */
  SoundPressure();

  /**
   * @brief     Run the finite element simulation.
   * @return    void
   */
  void run();

 private:
  /****************************************************************************
   *
   *                               METHODS
   *
   ***************************************************************************/
  /**
   * @brief         Create the system triangulation with deal.ii's internal
   *                functions or loading it from external GMSH "msh" file
   * @param gmsh:   load extern mesh [default false]
   * @param path:   path of the extern mesh
   *
   * @return void
   */
  void make_grid(bool gmsh = false, std::string path = "sound_pressure.msh");

  /**
   * @brief Creates the system's matrix, right hand side and the initial
   *        degrees of freedom associated to the triangulation enumerating
   *        them as near as possible to their neighbors such that the system
   *        matrix could be represented as a sparse matrix, saving memory
   *        if the computation must be very refined
   */
  void setup_system();

  /**
   * @brief Compute the various components of the system, that's to say the
   *        system matrix, the right hand side and the correction to those due
   *        to the boundary conditions.
   *        This is the point where the system equations play their role.
   */
  void build_system();

  /**
   * @brief For now it just solves the system to the required precision or
   *        until a maximum number of iterations. To speed up the processing
   *        some sort of preconditioning of the solution matrix can be done
   *        but as the present time i don't know what does it means.
   */
  void solve_system();

  /**
   * @brief That's a very interesting feature of deal.ii. The basic idea is to
   *        start looking for a solution with a as much as possible coarse mesh
   *        and estimate the magnitude of the error with the real solution cell
   *        by cell. With this information refine then the cells where the
   *        error is too large and maybe coarse those where the error is low.
   */
  void refine_system();

  /**
   * @brief Eventual post processing elaboration and selection of data to
   *        export must be done here.
   */
  void process_output();

  /****************************************************************************
   *
   *                               MEMBERS
   *
   ***************************************************************************/

  Triangulation<3> triangulation;

  /****************************************************************************
   *
   *                          MESH PARAMETERS
   *
   ***************************************************************************/
  /*
   * UNITS:
   * length - cm
   *
   */

  float mea_base_side_length = 5;
  float mea_base_thickness = 0.1;
  float mea_ring_outer_radius = 1.1;
  float mea_ring_thickness = 0.1;
  float mea_ring_heigth = 0.5;
  float mea_water_heigth = 0.3;
};

SoundPressure::SoundPressure() {}

void SoundPressure::make_grid(bool gmsh, std::string path) {
  // if gmsh just load the extern mesh script in the system triangulation.
  if (gmsh) {
    std::ifstream mesh(path);
    GridIn<3> grid_in(triangulation);
    grid_in.read_msh(mesh);
  }
  // else build it with deal.ii functions.
  else {
    /*
     * that's still under construction because i found the gmsh approach more
     * efficient but i'm keeping this second way open.
     * the following approach is to generate the mesh by extruding a 2d sketch
     * all by dealii script commands.
     */

    // TEMPORARY 2D SKETCH

    // BASE
    Triangulation<3> base;
    Point<3> corner1 = {-mea_base_side_length / 2, mea_base_side_length / 2, 0};
    Point<3> corner2 = {mea_base_side_length / 2, -mea_base_side_length / 2,
                        -mea_base_thickness};
    GridGenerator::hyper_rectangle(base, corner1, corner2);

    // RING
    Triangulation<3> ring;
    GridGenerator::cylinder_shell(ring, mea_ring_heigth,
                                  mea_ring_outer_radius - mea_ring_thickness,
                                  mea_ring_outer_radius);

    GridGenerator::merge_triangulations(base, ring, triangulation);

    // WATER
    Triangulation<3> water;
    GridGenerator::cylinder(water, mea_ring_outer_radius - mea_ring_thickness,
                            mea_water_heigth / 2);

    GridGenerator::merge_triangulations(triangulation, water, triangulation);
  }

  // Export the used triangulation for checking it's correct.
  {
    GridOut grid_out;
    std::ofstream out("sound_pressure.vtu");
    grid_out.write_vtu(triangulation, out);
  }
}

void SoundPressure::setup_system() {}

void SoundPressure::build_system() {}

void SoundPressure::solve_system() {}

void SoundPressure::refine_system() {}

void SoundPressure::run() { make_grid(true, "sound_pressure.msh"); }

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
