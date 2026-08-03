**Notes:**
* SMT-LIB Benchmarks 2025: https://zenodo.org/records/16740866
* Simplex Algorithm in CVC5 repo: `src/theory/arith/linear`
* Search `Trace("` in the codebase, run `cvc5` with `-t <trace_name>`. You need to build `cvc5` with tracing enabled.
* Decision Strategy, Decision Engine
* Simplex Solver, GLPK, Incremental Solving, Work with quantifier instantiation: Propagating equalities

**Ideas**
* Transform the problem so that each basic variable only depends on at most two/three non-basic variables
* Use sum of squares of infeasibilities + gradient descent

**Following a Simple Example**
* CVC5: CVC5 debug build built from source, commit `1a010c72cf64ee0c4469eb770f54a689d4820d3f`
  ```bash
  ./configure.sh debug --auto-download
  cd <build_dir>   # default is ./build
  make             # use -jN for parallel build with N threads
  make check       # to run default set of tests
  make install     # to install into the prefix specified above
  ```
* SMT input file:
  ```
  (declare-const x Int)
  (declare-const y Int)
  (assert (<= (+ x y) 6))
  (assert (>= x 4))
  (assert (>= y 4))
  (check-sat)
  ```  
* `prop/minisat/core/Solver.cc/Solver::search`: `nnnnns`
* `prop/minisat/core/Solver.cc/Solver::propagate`: `nnnnnnnns`
* `Solver::theoryCheck`: `ns`
* `TheoryProxy::theoryCheck`, finish the while loop, and reach the second but last line `d_theoryEngine->check(effort)`,then press `s`
* `TheoryEngine::check`, press `n` thirteen times until we reach `CVC5_FOR_EACH_THEORY`. Then, execute `b Theory::check`, and press `c`. Each time we reach `Theory::check`, use `print d_id` to find out which theory it is, until we have `cvc5::internal::theory::THEORY_ARITH`
  * Use `print d_id` to find out which theory it is
  * **Question:** What is `d_out->spendResource(Resource::TheoryCheckStep)`? Does it do anything?
* `Theory::check`: Press `n` 34 times until we reach `postCheck(level)`, then press `s`
* `TheoryArith::postCheck`: `nnnnns`
* `LinearSolver::postCheck`: `ns`
* `TheoryArithPrivate::postCheck`: `nnnnnnnns`
* `TheoryArithPrivate::solveRealRelaxation`
* `DualSimplexDecisionProcedure::findModel`
* `DualSimplexDecisionProcedure::dualFindModel`
* `SimplexDecisionProcedure::standardProcessSignals`
* `SimplexDecisionProcedure::checkBasicForConflict`
* **Question:** What is `ValueCollection`

**Findings from the Simple Example**

The input above (`x + y ≤ 6`, `x ≥ 4`, `y ≥ 4`, all `Int`) answers `unsat`.
See `GDB.md` for the debugger recipes these came from.

* The assertion reaches the theory already **integer-tightened**:
  `call fact.toString()` in `preNotifyFact` gives `(not (>= (+ x y) 7))`,
  not `x + y ≤ 6`.
* `ArithVar` numbering, via `asNode`: `0 = x`, `1 = y`, `2 = (+ x y)`.
  The `≤ 6` bound is asserted on the **auxiliary variable 2**, not on `x` or `y`
  — `setupVariable(2)` in the trace is that slack variable being created, with a
  tableau row `2 = x + y` in which `2` is basic and `0`, `1` are nonbasic.
* Assertion path (from `bt`):
  ```
  Theory::check (EFFORT_STANDARD)               theory.cpp:574
    TheoryArith::preNotifyFact                  theory_arith.cpp:320
      LinearSolver::preNotifyFact               linear_solver.cpp:76
        TheoryArithPrivate::preNotifyFact       theory_arith_private.cpp:3605
          TheoryArithPrivate::assertionCases    theory_arith_private.cpp:1838
            TheoryArithPrivate::AssertUpper     theory_arith_private.cpp:664
  ```
* `update 0: (0,0)|-> (4,0)` in the trace is `LinearEqualityModule::update{Untracked,Tracked}`
  (`linear_equality.cpp:202` / `:240`): `x` is **nonbasic**, so a violated bound is
  repaired by moving it straight to the bound and propagating the delta down its
  tableau column into every basic variable. Two such updates push `ArithVar 2`
  to 8 against an upper bound of 6.
* The integer machinery **never runs**. The guard at
  `theory_arith_private.cpp:3901` requires
  `!emmittedConflictOrSplit && fullEffort && !hasIntegerModel()`; the trace line
  `integer?  conf/split 1 fulleffort 0` shows the first two already fail. No
  branch-and-bound, no cuts, no Diophantine solver — the conflict is found by
  plain simplex over ℚ.

**TODO:**
* Turn on debug mode without debug macros