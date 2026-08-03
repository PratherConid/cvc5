**From Entry Point to Theory Solver Invocation**
* Stage 1
  * `main/main.cpp/main`
  * `main/driver_unified.cpp/runCvc5`
  * `main/interactive_shell.cpp/InteractiveShell::readAndExecCommands`
  * `main/command_executor.cpp/CommandExecutor::doCommand`
  * `main/command_executor.cpp/CommandExecutor::doCommandSingleton`
  * `main/command_executor.cpp/CommandExecutor::solverInvoke`
  * `parser/commands.cpp/invokeAndPrintResult`
  * `parser/commands.h/class Cmd/virtual void invoke(cvc5::Solver* solver, parser::SymManager* sm)`, which involves both concrete classes that inherit `class Cmd` and instances of ``cvc5::Solver``
* Stage 2
  * `parser/commands.h/class CheckSatCommand/invoke`
  * `parser/commands.cpp/CheckSatCommand::invoke`
  * `api/cpp/cvc5.cpp/Solver::checkSat`
  * `smt/solver_engine.cpp/SolverEngine::checkSat`
  * `smt/solver_engine.cpp/SolverEngine::checkSatInternal`
  * `smt/smt_driver.cpp/SmtDriver::checkSat`
  * `smt/smt_driver.cpp/SmtDriverSingleCall::checkSatNext` or `smt/smt_driver_deep_restarts.cpp/SmtDriverDeepRestarts::checkSatNext`
  * `smt/smt_solver.cpp/SmtSolver::checkSatInternal`
  * `prop/prop_engine.cpp/PropEngine::checkSat`
  * `prop/sat_solver.h/SatSolver::solve`. There are four descendents of the `SatSolver` class: `CryptoMinisatSolver, KissatSolver, CDCLTSatSolver, FakeSatSolver`. The default seems to be `CDCLTSatSolver`
  * There are two descendents of the `CDCLTSatSolver` class: `CadicalSolver, MinisatSatSolver`. The default seems to be `CadicalSolver`
* Stage 3/CadicalSolver (IPASIR-UP)
  * `prop/cadical.h/class CadicalSolver/solver`
  * `prop/cadical.cpp/CadicalSolver::solve`
  * `prop/cadical.cpp/CadicalSolver::_solve` executes `res = toSatValue(d_solver->solve());`
  * `build/deps/src/CaDiCaL-EP/src/solver.cpp/Solver::solve`
  * `build/deps/src/CaDiCaL-EP/src/solver.cpp/Solver::call_external_solve_and_check_results`
  * `build/deps/src/CaDiCaL-EP/src/external.cpp/External::solve`
  * `build/deps/src/CaDiCaL-EP/src/internal.cpp/Internal::solve`
  * `build/deps/src/CaDiCaL-EP/src/internal.cpp/Internal::cdcl_loop_with_inprocessing`
  * `build/deps/src/CaDiCaL-EP/src/internal.cpp/Internal::external_propagate`
* Stage 3/MinisatSatSolver
  * `prop/minisat/minisat.cpp/MinisatSatSolver::solve`
  * `prop/minisat/simp/SimpSolver.h/SimpSolver::solve`
  * `prop/minisat/simp/SimpSolver.cc/SimpSolver::solve_`
  * `prop/minisat/core/Solver.cc/Solver::solve_`
  * `prop/minisat/core/Solver.cc/Solver::search`
  * `prop/minisat/core/Solver.cc/Solver::propagate`
  * `prop/minisat/core/Solver.cc/Solver::theoryCheck` and `prop/minisat/core/Solver.cc/Solver::propagateTheory`
  * `prop/theory_proxy.cpp/TheoryProxy::theoryCheck` and `prop/theory_proxy.cpp/TheoryProxy::theoryPropagate`
* Stage 4
  * `prop/theory_proxy.cpp/TheoryProxy::theoryCheck`
  * `theory/theory_engine.cpp/TheoryEngine::check`
    * Macro `theory/theory_engine.cpp/#define CVC5_FOR_EACH_THEORY`
  * `theory/theory.cpp/Theory::check`
    * `theory/theory.cpp/Theory::preNotifyFact`, `theory/uf/equality_engine.cpp/EqualityEngine::assertEquality`, `theory/uf/equality_engine.cpp/EqualityEngine::assertPredicate`, `theory/theory.cpp/Theory::notifyFact`

**Inspection**
* If `x : expr::NodeValue`, use `print x.toString()`
* If `x : TNode`, use `print x.d_nv->toString()`
* Use `--stats-internal` in a `cvc5` invocation, or `(set-option :stats-internal true)` in an input file to get execution time spent on different modules