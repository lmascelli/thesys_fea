// That's just for avoiding some annoying unused variable warnings.
#define USE(X) (void)(X);

#include <deal.II/base/quadrature.h>
#include <deal.II/dofs/dof_handler.h>
#include <deal.II/dofs/dof_renumbering.h>
#include <deal.II/dofs/dof_tools.h>
#include <deal.II/fe/fe_q.h>
#include <deal.II/grid/grid_generator.h>
#include <deal.II/grid/grid_in.h>
#include <deal.II/grid/grid_out.h>
#include <deal.II/grid/grid_tools.h>
#include <deal.II/grid/tria.h>
#include <deal.II/lac/dynamic_sparsity_pattern.h>
#include <deal.II/lac/precondition.h>
#include <deal.II/lac/solver_cg.h>
#include <deal.II/lac/solver_control.h>
#include <deal.II/lac/sparse_matrix.h>
#include <deal.II/lac/sparsity_pattern.h>
#include <deal.II/numerics/data_out.h>
#include <deal.II/numerics/matrix_tools.h>
#include <deal.II/numerics/vector_tools.h>

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
  void assemble_system();

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
  bool refine_system();

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

  Triangulation<3> triangulation;  // mesh nodes representation in dealii
  DoFHandler<3> dof_handler;       // a manager class for all degrees of freedom

  FE_Q<3> fe_q;  // scalar Lagrange finite element
                 // interpolating function

  SparsityPattern sparsity_pattern;  // sparse matrix pattern manager
  SparseMatrix<double> system_matrix;
  Vector<double> system_rhs;
  Vector<double> solution;
  /****************************************************************************
   *
   *                          MESH PARAMETERS
   *
   */
};

/**
 * In the constructor it's being assigned the handler of the degrees of
 * freedom to the corresponding triangulation and as interpolating function
 * a polynomial function of degree 1; to have a higher polynomial degree
 * it's only needed to change this value
 */

#define POLY_DEGREE 1

SoundPressure::SoundPressure()
    : dof_handler(triangulation), fe_q(POLY_DEGREE) {}

void SoundPressure::make_grid(bool gmsh, std::string path) {
  // if gmsh just load the extern mesh script in the system triangulation.
  if (gmsh) {
    std::ifstream mesh(path);
    GridIn<3> grid_in(triangulation);
    grid_in.read_msh(mesh);
  }
  // else build it with deal.ii functions.
  else {
  }

  // Export the used triangulation for checking it's correct.
  {
    GridOut grid_out;
    std::ofstream out("../assets/sound_pressure.vtu");
    grid_out.write_vtu(triangulation, out);
  }
}

void SoundPressure::setup_system() {
  dof_handler.distribute_dofs(fe_q);
  DynamicSparsityPattern dsp(dof_handler.n_dofs());
  DoFTools::make_sparsity_pattern(dof_handler, dsp);
  sparsity_pattern.copy_from(dsp);
  system_matrix.reinit(sparsity_pattern);

  solution.reinit(dof_handler.n_dofs());
  system_rhs.reinit(dof_handler.n_dofs());
}

void SoundPressure::assemble_system() {
  const QGauss<3> quadrature_formula(fe_q.degree + 1);

  FEValues<3> fe_values(fe_q, quadrature_formula,
                        update_values | update_gradients |
                            update_quadrature_points | update_JxW_values);

  const unsigned int dofs_per_cell = fe_q.n_dofs_per_cell();

  FullMatrix<double> cell_matrix(dofs_per_cell, dofs_per_cell);
  Vector<double> cell_rhs(dofs_per_cell);

  std::vector<types::global_dof_index> local_dof_indices(dofs_per_cell);

  for (const auto &cell : dof_handler.active_cell_iterators()) {
    cell_matrix = 0;
    cell_rhs = 0;
    fe_values.reinit(cell);

    // cycle and fill the system_matrix HERE
    // at the moment i'll use simple Laplace equation just for test
    for (const unsigned int q_index : fe_values.quadrature_point_indices()) {
      for (const unsigned int i : fe_values.dof_indices()) {
        for (const unsigned int j : fe_values.dof_indices())
          cell_matrix(i, j) += fe_values.shape_grad(i, q_index) *
                               fe_values.shape_grad(j, q_index) *
                               fe_values.JxW(q_index);
        cell_rhs(i) +=
            (fe_values.shape_value(i, q_index) * fe_values.JxW(q_index));
      }
    }

    cell->get_dof_indices(local_dof_indices);

    for (const unsigned int i : fe_values.dof_indices()) {
      for (const unsigned int j : fe_values.dof_indices())
        system_matrix.add(local_dof_indices[i], local_dof_indices[j],
                          cell_matrix(i, j));
      system_rhs(local_dof_indices[i]) += cell_rhs(i);
    }
  }

  std::map<types::global_dof_index, double> boundary_values;
  VectorTools::interpolate_boundary_values(
      dof_handler, 1, Functions::ConstantFunction<3>(100.0), boundary_values);
  VectorTools::interpolate_boundary_values(
      dof_handler, 2, Functions::ConstantFunction<3>(2.0), boundary_values);
  VectorTools::interpolate_boundary_values(
      dof_handler, 5, Functions::ConstantFunction<3>(1.0) ,boundary_values);
  MatrixTools::apply_boundary_values(boundary_values, system_matrix, solution,
                                     system_rhs);
}

void SoundPressure::solve_system() {
  SolverControl solver_control(1000, 1e-12);
  SolverCG<Vector<double>> solver(solver_control);

  solver.solve(system_matrix, solution, system_rhs, PreconditionIdentity());
}

bool SoundPressure::refine_system() { return false; }

void SoundPressure::process_output() {
  DataOut<3> data_out;
  data_out.attach_dof_handler(dof_handler);
  data_out.add_data_vector(solution, "solution");
  data_out.build_patches();

  std::ofstream output("../assets/solution.vtk");
  data_out.write_vtk(output);
}

void SoundPressure::run() {
  do {
    make_grid(true, "../assets/mesh.msh");
    setup_system();
    assemble_system();
    solve_system();
  } while (refine_system());
  process_output();
}

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
