**Building**
* Base build:
  ```bash
  ./configure.sh --auto-download
  cd <build_dir>   # default is ./build
  make             # use -jN for parallel build with N threads
  make check       # to run default set of tests
  make install     # to install into the prefix specified above
  ```
* Build type is the optional first argument; the default is `production`
  (optimized, assertions and tracing **disabled**). For a debug build:
  ```bash
  ./configure.sh debug --auto-download
  ```
  which is unoptimized (`-Og -fno-inline -ggdb3`) with assertions and tracing
  enabled. Other types: `testing` (optimized debug build), `competition`,
  `safe-mode`, `stable-mode`.
* **Tracing is orthogonal to build type** — `--tracing` / `--no-tracing` can be
  combined with any of them, as can `--assertions` and `--statistics`. So an
  optimized build that still supports `-t <tag>`:
  ```bash
  ./configure.sh production --tracing --auto-download
  ```
  Without tracing, `-t` fails with
  `trace tags not available in non-tracing builds`.
  Mechanism: build types set defaults via `cvc5_set_option`
  (`cmake/Helpers.cmake:193`), which only assigns when the option is still
  `IGNORE`, so an explicit `--tracing` always wins over
  `ConfigProduction.cmake`'s `ENABLE_TRACING OFF`. `ENABLE_TRACING` gates
  `-DCVC5_TRACING` at `CMakeLists.txt:555`.
* Use `--name=STR` to build into `build-STR` instead of `build`, so several
  configurations can coexist. Reconfiguring an existing `build/` in place leaves
  stale artifacts behind (an old `Makefile` when switching to `--ninja`, an
  orphaned `libcvc5.so` when switching link mode), which is a source of
  confusing failures.
* `configure.sh` uses Makefiles by default; pass `--ninja` for Ninja.
* Gotcha: `cmake --build build --target cvc5` builds the **library**
  (`libcvc5.a`/`.so`), not the binary — `cvc5` is the library target and
  `cvc5-bin` is the executable target (with `OUTPUT_NAME cvc5`). Use
  `make` with no target, `cmake --build build`, or `--target cvc5-bin`.

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
  * There are two descendents of the `CDCLTSatSolver` class: `CadicalSolver, MinisatSatSolver`. The default is `MinisatSatSolver`: `--sat-solver` defaults to `MINISAT` (`options/prop_options.toml`), and `--sat-solver=cadical` selects `CadicalSolver`. To check which one ran, look at `--stats --stats-internal` output: MiniSat reports `sat::*` statistics and CaDiCaL reports `cadical::*`. `theory::bv::BVSolverBitblast::cadical::*` belongs to the bit-vector bit-blaster's own CaDiCaL instance, not the main solver
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