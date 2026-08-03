**Notes:**
* SMT-LIB Benchmarks 2025: https://zenodo.org/records/16740866
* Simplex Algorithm in CVC5 repo: `src/theory/arith/linear`
* Search `Trace("` in the codebase, run `cvc5` with `-t <trace_name>`. You need to build `cvc5` with tracing enabled.
* Decision Strategy, Decision Engine
* Simplex Solver, GLPK, Incremental Solving, Work with quantifier instantiation: Propagating equalities

**Ideas**
* Transform the problem so that each basic variable only depends on at most two/three non-basic variables
* Use sum of squares of infeasibilities + gradient descent

**Tracing**

*Trace tags.* Enabled with `-t <tag>` (see Notes above for finding them). The
arith tags that actually earned their keep:
* `arith` — variable setup, `AssertLower`/`AssertUpper`, nonbasic updates, and
  the `integer?  conf/split N fulleffort N` line at the end of a check.
* `arith::weak` — inside `minimallyWeakConflict`: which bound was picked for each
  row entry, and whether it was *weakened*. The leading `0`/`1` on a `weak :`
  line is the weakening flag.
* `arith::conflict` — the finished `ConstraintRule` with its Farkas antecedents,
  plus the conflict node actually handed to the SAT solver.
* `arith::pf::tree` — proof tree of the conflict constraint and its negation.

*Trace gotchas.*
* `AssertUpper` prints **twice per call**: `theory_arith_private.cpp:674` and
  `:680` hold the same `Trace` statement straddling an `Assert`. One event, not
  two. `AssertLower` prints once.
* `-t arith::pivot` is accepted but **never prints anything**. Its only emission
  site is `debugPivot`, guarded at `linear_equality.cpp:301` by
  `TraceIsOn("arith::simplex:row")` — and that tag is not registered
  (`no trace tag matching arith::simplex:row was found`). Its only other
  occurrence in the tree is a `didyoumean` unit test. Dead code; use statistics
  or a breakpoint instead.

*Statistics.* `--stats` alone does not show arith internals. Three things to know:
* `--stats-internal` is required for `theory::arith::pivots`, `::updates`,
  `::weakening::*`.
* Statistics print to **stderr** — `2>&1` is mandatory, and `2>/dev/null`
  silently yields nothing.
* Zero-valued statistics are **omitted entirely**; absence of a line means zero.
  `--stats-all` prints them explicitly as `= 0`.

*Testing whether a problem triggers pivoting.*
  ```bash
  ./build/bin/cvc5 --stats --stats-internal <file>.smt 2>&1 | grep 'arith::pivots'
  ```
  Measured: `basic_conflict.smt` → no `pivots` line (i.e. 0), `updates = 2`,
  `weakening::total = 1`. The example below → `pivots = 1`, `updates = 1`.

  A pivot is needed when a basic variable violates a bound **but the nonbasics in
  its row still have slack**. If they are already pinned at the bound that would
  fix it, the conflict is immediate and nothing pivots — that is exactly why
  `basic_conflict.smt` never pivots. Rule of thumb: sat problems with a
  nontrivial feasible region pivot; conflicts refutable straight from bounds
  do not.
  ```
  (set-logic QF_LRA)
  (declare-const x Real)
  (declare-const y Real)
  (assert (>= (+ x y) 5))
  (assert (<= x 10))
  (assert (<= y 10))
  (check-sat)
  ```
  Row `s = x + y` starts at 0, below its lower bound of 5, while `x` and `y` sit
  at 0 with upper bounds of 10 — so there is room, and dual simplex pivots.

  For a definitive per-problem check that also names the variables, break on
  `LinearEqualityModule::pivotAndUpdate`: `x_i` is the leaving basic variable,
  `x_j` the entering nonbasic. On the example above, `x_i = 2` (`(+ x y)`) and
  `x_j = 0` (`x`).

  Further depth: `theory::arith::pivots::{sat,unsat,unknown}` are per-call
  histograms, and `--collect-pivot-stats` (EXPERTS only) records pivot history.

**Following a Simple Example**
* CVC5: CVC5 debug build built from source, commit `1a010c72cf64ee0c4469eb770f54a689d4820d3f`
  ```bash
  ./configure.sh debug --auto-download
  cd <build_dir>   # default is ./build
  make             # use -jN for parallel build with N threads
  make check       # to run default set of tests
  make install     # to install into the prefix specified above
  ```
* SMT input file (`smt_files/basic_conflict.smt`):
  ```
  (set-logic QF_LIA)
  (declare-const x Int)
  (declare-const y Int)
  (assert (<= (+ x y) 6))
  (assert (>= x 4))
  (assert (>= y 4))
  (check-sat)
  ```  
* Rather than stepping, break on the innermost function of interest and read the
  whole call chain off the stack in one shot:
  ```bash
  gdb --batch \
    -ex "set breakpoint pending on" -ex "set confirm off" \
    -ex "break cvc5::internal::theory::arith::linear::SimplexDecisionProcedure::checkBasicForConflict" \
    -ex "run" -ex "bt 30" \
    --args ./build/bin/cvc5 workdocs/smt_files/basic_conflict.smt
  ```
* The resulting stack, outermost first (line numbers as of `e8c0387ca`):
  ```
  Solver::search                            prop/minisat/core/Solver.cc:1491
  Solver::propagate                         prop/minisat/core/Solver.cc:1186
  Solver::theoryCheck                       prop/minisat/core/Solver.cc:1271
  TheoryProxy::theoryCheck                  prop/theory_proxy.cpp:271
  TheoryEngine::check                       theory/theory_engine.cpp:468
  Theory::check                             theory/theory.cpp:600
  TheoryArith::postCheck                    theory/arith/theory_arith.cpp:255
  LinearSolver::postCheck                   theory/arith/linear/linear_solver.cpp:79
  TheoryArithPrivate::postCheck             theory/arith/linear/theory_arith_private.cpp:3670
  TheoryArithPrivate::solveRealRelaxation   theory/arith/linear/theory_arith_private.cpp:3460
  DualSimplexDecisionProcedure::findModel   theory/arith/linear/dual_simplex.h:73
  DualSimplexDecisionProcedure::dualFindModel        theory/arith/linear/dual_simplex.cpp:72
  DualSimplexDecisionProcedure::processSignals       theory/arith/linear/dual_simplex.h:98
  SimplexDecisionProcedure::standardProcessSignals   theory/arith/linear/simplex.cpp:77
  SimplexDecisionProcedure::checkBasicForConflict    theory/arith/linear/simplex.cpp:149
  ```
  `processSignals` is a one-line inline wrapper in the header, which is why
  stepping blows past it. Every frame carries `EFFORT_STANDARD`; full effort is
  never needed for this input. The breakpoint reports `basic=2`, the auxiliary
  variable for `(+ x y)`.
* `Theory::check` runs once per theory. To confirm which one, `print d_id` — the
  arithmetic pass is `cvc5::internal::theory::THEORY_ARITH`.
* **Question:** What is `d_out->spendResource(Resource::TheoryCheckStep)`? Does it do anything?
* **Question:** What is `ValueCollection`

**How CVC5 Produced UNSAT for the Simple Example**

Short version: cvc5 answers `unsat` **without pivoting, without branching, and
without any integer reasoning**. The two lower bounds mechanically drive the row
variable to 8; the row is then found to exceed its upper bound *while every
nonbasic is pinned at the bound that would be needed to reduce it*, which is a
syntactic certificate of infeasibility over ℚ. A Farkas combination turns that
into a conflict clause that is already false at decision level 0, so the SAT
solver returns immediately.

*1. What the theory actually receives.*
`(<= (+ x y) 6)` never reaches arithmetic in that form. Since `x, y : Int` it is
normalized to the SAT literal `(>= (+ x y) 7)` asserted **false** — at
`preNotifyFact`, `call fact.toString()` gives `(not (>= (+ x y) 7))`. The sum
gets auxiliary variable `2` and a tableau row `2 = x + y`, with `2` basic and
`0 = x`, `1 = y` nonbasic.
Note `¬(x+y ≥ 7)` is natively `x + y ≤ 7 − δ`, i.e. `(7,-1)`; cvc5
integer-tightens it to `x + y ≤ 6`, i.e. `(6,0)`, and asserts *that*. The
tightened constraint is derived, so it carries **no SAT literal of its own**
(`hasLiteral()` is `false` on it). Both forms coexist in the constraint database.

*2. Bounds are applied with no search.* `x` and `y` are nonbasic, so each
violated lower bound is repaired by moving the variable straight to its bound
and propagating the delta down its tableau column. Two such updates push
`ArithVar 2` from 0 to 8, against an upper bound of 6. The error set signals it.

*3. The conflict test.* At `simplex.cpp:149`, measured state:
  ```
  basic                       = 2         ("(+ x y)")
  getAssignment(2)            = (8,0)
  getUpperBound(2)            = (6,0)
  cmpAssignmentUpperBound(2)  = 1     → above its upper bound
  nonbasicsAtLowerBounds(2)   = true  → the side condition
  ```
  The **second** condition is what makes this a refutation rather than merely a
  violated bound: every nonbasic in row 2 with a positive coefficient is already
  at its *lower* bound, so `x + y` cannot be decreased and **no pivot can repair
  the row**. That is the CAV06 §4.2 criterion. Confirmed: `d_pivots = 0` at
  `reportConflict` — cvc5 never pivots on this problem.

*4. The Farkas certificate.* `reportConflict` →
`generateConflictAboveUpperBound` → `minimallyWeakConflict`, which walks row 2
with `surplus = 8 − 6 = 2` and asks `weakestExplanation` for the weakest bound
per entry that still covers the surplus (`-t arith::weak`):
  ```
  weak : 1 1 (8,0) 2 <= (7,-1) (node (not (>= (+ x y) 7)))
  weak : 0 1 (4,0) 1 >= (4,0)  (node (>= y 4))
  weak : 0 1 (4,0) 0 >= (4,0)  (node (>= x 4))
  ```
  The leading `1` means the basic variable's bound **was weakened** — from the
  derived `(6,0)` back to `(7,-1)`, the originally asserted literal. This is
  essential: the derived `x+y ≤ 6` has no SAT literal, so a conflict phrased in
  terms of it would be meaningless to MiniSat.
  The proof object (`-t arith::conflict`):
  ```
  {ConstraintRule, 2 >= (7,0) (node (>= (+ x y) 7))
   d_proofType = FarkasAP,  d_antecedentEnd = 4
   _ * (0 >= (4,0) (node (>= x 4)))
   _ * (1 >= (4,0) (node (>= y 4)))
   _ * (2 <= (7,-1) (node (not (>= (+ x y) 7)))) [not d_constraint]
  }
  ```
  Unit Farkas coefficients: `x ≥ 4` and `y ≥ 4` derive `x + y ≥ 7`, whose
  negation is exactly the asserted third literal — a constraint and its negation
  both holding a proof is cvc5's definition of `inConflict`. It derives `≥ 7`,
  not the tighter `≥ 8`: "minimally weak" means deriving only enough to
  contradict, which yields a more general conflict clause.

*5. Why that ends the search.* `outputConflicts` calls
`externalExplainConflict()`, giving
`(and (>= x 4) (>= y 4) (not (>= (+ x y) 7)))`. Measured in MiniSat's `search`
the moment it arrives: `decisionLevel() = 0`, `trail_lim.size() = 0`,
`trail.size() = 5` — all three assertions are unit, so everything is at decision
level 0. `Solver.cc:1499` takes the early branch and returns `l_False`: no
clause learning, no backjump, no restart. `--stats` confirms the whole run with
`ARITH_CONF_SIMPLEX: 1`.

**Findings from the Simple Example**

Supplements the walkthrough above — how to decode what the trace and the stack
actually print. See `GDB.md` for the debugger recipes these came from.

* Decoding `-t arith`: `setupVariable(2)` is the slack variable for `(+ x y)`
  being created. `ArithVar` ids map back to terms with `asNode`: `0 = x`,
  `1 = y`, `2 = (+ x y)`.
* `update 0: (0,0)|-> (4,0)` is `LinearEqualityModule::update{Untracked,Tracked}`
  (`linear_equality.cpp:202` / `:240`) — nonbasic `x` moved straight to its bound,
  with the delta propagated down its tableau column.
* The **assertion** path, distinct from the `postCheck` stack listed further up:
  ```
  Theory::check (EFFORT_STANDARD)               theory.cpp:574
    TheoryArith::preNotifyFact                  theory_arith.cpp:320
      LinearSolver::preNotifyFact               linear_solver.cpp:76
        TheoryArithPrivate::preNotifyFact       theory_arith_private.cpp:3605
          TheoryArithPrivate::assertionCases    theory_arith_private.cpp:1838
            TheoryArithPrivate::AssertUpper     theory_arith_private.cpp:664
  ```
* The integer machinery **never runs**. The guard at
  `theory_arith_private.cpp:3901` requires
  `!emmittedConflictOrSplit && fullEffort && !hasIntegerModel()`; the trace line
  `integer?  conf/split 1 fulleffort 0` shows the first two already fail. No
  branch-and-bound, no cuts, no Diophantine solver — the conflict is found by plain simplex over ℚ.

**An Example That Requires Pivoting**

`smt_files/pivot_min.smt`:
```
(set-logic QF_LRA)
(declare-const x Real)
(declare-const y Real)
(assert (>= (- x y) 5))
(assert (<= x 1))
(assert (>= y 0))
(check-sat)
```
Measured: `unsat`, with `theory::arith::pivots = 1`, `theory::arith::updates = 1`
and `ARITH_CONF_SIMPLEX: 1`.

*Why it pivots, where the simple example does not.* Row `s = x - y` is basic and
starts at 0, below its lower bound of 5. Raising `s` means raising `x` (positive
coefficient) or lowering `y` (negative coefficient), and `x` at 0 is **not** yet
at its upper bound of 1 — so the row still looks repairable,
`checkBasicForConflict` returns false, and dual simplex has to pivot rather than
report a conflict. Only once `x` is driven up to 1 does `s` reach 1 — still short
of 5, and now with every nonbasic pinned at its bound. That is the conflict. It
is the mirror image of `basic_conflict.smt`, where the nonbasics were already
pinned on arrival, so the conflict was immediate and nothing pivoted.

*How the pivot count was tuned down to one.* The number of pivots is the number
of nonbasics in the row that are **not already sitting at the bound needed to
repair it**. Every variable starts at 0, so "already at that bound" just means
that bound is exactly 0. The sign of a coefficient does not change the count —
it only decides *which* bound is the relevant one: positive coefficient means the
variable must rise, so its **upper** bound pins it; negative coefficient means it
must fall, so its **lower** bound pins it. Here `y >= 0` puts `y` at its lower
bound from the outset, so `y` never needs a pivot and only `x` has room. Making
both bounds non-zero (e.g. `x <= 1`, `y >= -1`) gives 2 pivots; making both zero
(`x <= 0`, `y >= 0`) pins everything on arrival and gives 0 pivots, degenerating
back to the `basic_conflict.smt` case.

*Why it is minimal.* Both bounds are tight, and each was checked against a
counterexample:
* **Two variables are required.** A single variable never creates a tableau row,
  so there is no basic variable to pivot out: both `(>= (+ x x) 5)` and
  `(>= (* 2 x) 5)` normalize to a single monomial and give `pivots = 0`.
* **Three assertions are required.** Any two mutually infeasible constraints over
  two free reals must normalize to the same row — one is a positive multiple of
  the other — which cvc5 catches as a unate bound conflict in
  `AssertUpper`/`AssertLower` before simplex runs. Confirmed with
  `(>= (+ x y) 5)` plus `(<= (+ x y) 2)`: `unsat` with `pivots = 0`. Bounding `x`
  and `y` separately is what forces the solver through the tableau.
