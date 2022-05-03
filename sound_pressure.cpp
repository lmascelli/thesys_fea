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

template <int dim>
class SoundPressure {
 public:
  SoundPressure();
  void run();

 private:
  void make_grid();
  void setup_system();

  Triangulation<dim> triangulation;
};

template <int dim>
SoundPressure<dim>::SoundPressure() {}

template <int dim>
void SoundPressure<dim>::make_grid() {
  std::ifstream mesh("sound_pressure.msh");
  GridIn<dim> grid_in(triangulation);
  grid_in.read_msh(mesh);

  GridOut grid_out;
  std::ofstream out("sound_pressure.vtu");
  grid_out.write_vtu(triangulation, out);
}

template <int dim>
void SoundPressure<dim>::setup_system() {}

template <int dim>
void SoundPressure<dim>::run() {
  make_grid();
}

int main(int argc, char **argv) {
  USE(argc)
  USE(argv)

  try {
    SoundPressure<2> sound_pressure;
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
