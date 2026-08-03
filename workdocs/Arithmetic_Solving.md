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

*Tracing pivots in detail.* The statistic only gives a count; `-t arith::dual`
prints one line per iteration of the dual simplex loop
(`dual_simplex.cpp:searchForFeasibleSolution`), which is enough to reconstruct
the whole walk:
  ```
  #1 c0 d-1 f0 h0 2->0
  ```
| field | meaning |
|---|---|
| `#N` | running pivot count (`d_pivots`) |
| `cN` | whether `processSignals()` found a conflict right after this pivot — `c1` is always the last line |
| `dN` | `prevErrorSize - currErrorSize`, i.e. how much the error set shrank; **negative means the pivot broke more rows than it fixed** |
| `fN` | whether the entering variable is itself now in error |
| `hN` | whether the entering variable is a conflict variable |
| `x_i->x_j` | leaving **basic** variable → entering **nonbasic** variable |

  Three companion tags complete the picture:
  * `-t arith::update::select` prints `selectSmallestInconsistentVar()=N` — which
    violated basic variable was chosen for repair, before the pivot happens.
  * `-t arith` prints `update <x_j>: old |-> new`. Careful: `pivotAndUpdate`
    computes `theta = (bound - beta(x_i)) / a_ij` and applies it to `x_j`, so this
    line reports the new value of the **entering** variable, not of the row being
    repaired. The repaired row is simply moved to the bound it violated.
  * `-t arith::weak` and `-t arith::conflict` then show the Farkas certificate
    built once the walk ends.

  Putting it together — the walk in `pivot_4.smt` was read off with:
  ```bash
  ./build/bin/cvc5 -t arith -t arith::dual -t arith::update::select \
    workdocs/smt_files/pivot_4.smt 2>&1 | grep -vE '^weak|^Linear'
  ```
  Everything is reported in `ArithVar` ids; `setupVariable(N)` lines give the
  creation order, and `GDB.md` has the `asNode` recipe for turning an id back
  into a term.

*Tracing branch and bound.* Integer reasoning runs only when the guard at
`theory_arith_private.cpp:3901` passes, and plain `-t arith` reports that guard
on every check:
  ```
  integer?  conf/split C fulleffort F
  ```
  Branching is attempted only when `C = 0` (nothing conflicting or split yet) and
  `F = 1` (full effort). A run whose lines all read `conf/split 1` or
  `fulleffort 0` did no integer reasoning at all — that is the case for
  `basic_conflict.smt`, and `conf/split 0 fulleffort 1` is what
  `branch_bound.smt` shows instead. This line is the fastest way to tell whether
  a problem even reaches the integer machinery.

  Once the guard passes:
* `-t arith-round-robin` follows the loop that hands out branch lemmas:
  ```
  Round robin branch...
  ...consider 1 lemmas
  ..success lemma
  ```
  `..failed lemma` means the output channel rejected that lemma and the next
  candidate is tried; `..already failed lemma` is the loop's termination check.
* `-t arith::lemma` prints the split itself, as a trichotomy on one variable
  built by `BranchAndBound::branchIntegerVariable`:
  ```
  rrbranch lemma  (or (and (not (>= y 1)) (>= y 0)) (or (not (>= y 0)) (>= y 1)))
  ```
  which reads `y <= -1` or `y = 0` or `y >= 1`.
* `-t arith` shows both the fractional assignment that provoked the split
  (`update 1: (0,0)|-> (1/3,0)`) and, afterwards, the branch bound being asserted
  (`AssertUpper(1 (0,0))`) as the first case is explored.

  On the statistics side, `theory::arith::externalBranchAndBounds` counts branch
  rounds, and the `inferencesLemma` histogram distinguishes *which* integer
  mechanism fired — `ARITH_BB_LEMMA` (branch and bound), `ARITH_DIO_CUT`
  (Diophantine solver), `ARITH_SPLIT_DEQ` (disequality split). That distinction
  matters: a problem can be integer-infeasible and still show `bb = 0` because
  bound tightening or the rewriter disposed of it first.

  In gdb, break on
  `cvc5::internal::theory::arith::BranchAndBound::branchIntegerVariable` for the
  split construction, or
  `cvc5::internal::theory::arith::linear::TheoryArithPrivate::roundRobinBranch`
  for the caller that picks which variable to branch on.

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

**An example that requires 4 pivots**

`smt_files/pivot_4.smt` — `unsat` with `theory::arith::pivots = 4`, using only
**two** variables:
```
(set-logic QF_LRA)
(declare-const x Real)
(declare-const y Real)
(assert (>= (+ x (* 4 y)) 20))
(assert (<= (+ x (* 2 y)) 10))
(assert (<= (+ x y) 2))
(assert (>= (+ x (* 5 y)) 30))
(assert (<= (+ x (* 6 y)) 35))
(check-sat)
```
Unsatisfiability is easy to see by hand: subtracting row 3 from row 1 gives
`3y >= 18`, so `y >= 6`; subtracting row 4 from row 5 gives `y <= 5`.

*Rows are normalized monic in `x`.* Every constraint above becomes a row
`s_g = x + g*y` carrying a single bound. Writing `s_g` for the row with
`y`-coefficient `g`:

| ArithVar | row | bound |
|---|---|---|
| 0 | `x` | — |
| 1 | `y` | — |
| 2 | `s_4 = x + 4y` | lower 20 |
| 3 | `s_2 = x + 2y` | upper 10 |
| 4 | `s_1 = x + y`  | upper 2 |
| 5 | `s_5 = x + 5y` | lower 30 |
| 6 | `s_6 = x + 6y` | upper 35 |

*The tableau coefficients.* With two variables the nonbasic set always has size
2. Once two rows `s_a` and `s_b` are the nonbasics, every other row is a fixed
affine combination of them, obtained by solving `s_a = x + a*y`, `s_b = x + b*y`
for `x` and `y`:
```
s_g = ((g-b)/(a-b)) * s_a + ((a-g)/(a-b)) * s_b        [coefficients sum to 1]
```
This is what governs whether a violated row can be repaired. A nonbasic sitting
at its **lower** bound may only increase; one at its **upper** bound may only
decrease. Reading off the signs, with `s_a` at a lower bound and `s_b` at an
upper bound (`a > b`):

> a row **below** its lower bound is repairable iff `g > b`;
> a row **above** its upper bound is repairable iff `g < a`.

So `(b, a)` acts as a **window**, and each pivot replaces one endpoint. Designs
that keep *shrinking* the window run out of repairable rows after 3 pivots — that
is why simply adding more constraints, more polygon edges, or more rows never got
past 3. This instance is built so the window *widens*.

*The walk* (`-t arith::dual`, `#n cCONFLICT dERRORDELTA x_i->x_j`):
```
#1 c0 d-1 2->0     repair s_4 -> lb 20, x enters
#2 c0 d1  3->1     repair s_2 -> ub 10, y enters
#3 c0 d1  4->2     repair s_1 -> ub 2,  s_4 enters
#4 c1 d0  6->3     repair s_6 -> ub 35, s_2 enters, then conflict
```
Step by step, with the assignment after each pivot:

* **Start** `x=0, y=0`, so every row is 0. Violated: `s_4` (0 < 20) and `s_5`
  (0 < 30) — 2 errors.
* **Pivot 1** repairs `s_4`, the smallest-indexed violated variable. Both `x` and
  `y` are unbounded, so either may enter; `x` is chosen and set to 20. Now every
  row equals 20, so `s_2` (> 10), `s_1` (> 2) and `s_5` (< 30) are all violated —
  3 errors, hence `d-1`.
* **Pivot 2** repairs `s_2`. With `s_4` nonbasic, `s_2 = s_4 - 2y = 20 - 2y`;
  driving it to its bound 10 gives `y = 5`, and `x = s_4 - 4y = 0`.
  Rows are now `s_g = 5g`: `s_1 = 5 > 2` and `s_5 = 25 < 30` are violated.
* **Pivot 3** repairs `s_1`. Nonbasics are `s_4` (lower, 20) and `s_2` (upper,
  10), so `a = 4`, `b = 2` and
  `s_1 = ((1-2)/2) s_4 + ((4-1)/2) s_2 = -0.5*s_4 + 1.5*s_2 = -10 + 15 = 5`.
  It must fall to 2. The `-0.5` coefficient on `s_4` means *raising* `s_4` lowers
  `s_1`, and `s_4` sits at a lower bound so it is free to rise: `s_4` goes to 26
  (`-0.5*26 + 15 = 2`). Solving `x + 2y = 10`, `x + y = 2` gives `x = -6, y = 8`.
  Now `s_5 = 34` is satisfied but `s_6 = 42 > 35` is violated.
* **Pivot 4** repairs `s_6`. Both nonbasics are now at *upper* bounds — `s_2` (10)
  and `s_1` (2) — so both may only decrease. With `a = 2`, `b = 1`:
  `s_6 = ((6-1)/1) s_2 + ((2-6)/1) s_1 = 5*s_2 - 4*s_1 = 50 - 8 = 42`.
  The `+5` coefficient on `s_2` lets a decrease of `s_2` pull `s_6` down, so `s_2`
  drops to `43/5 = 8.6` and `s_6` lands on 35.
* **Conflict.** Nonbasics are now `s_6` (upper, 35) and `s_1` (upper, 2), giving
  `x + 6y = 35`, `x + y = 2`, so `y = 33/5` and `x = -23/5`. Then
  `s_5 = ((5-1)/5) s_6 + ((6-5)/5) s_1 = 0.8*s_6 + 0.2*s_1 = 28 + 0.4 = 28.4`,
  below its lower bound of 30. To raise `s_5` we would have to raise `s_6`
  (coefficient `+0.8`, but it is at its *upper* bound) or raise `s_1`
  (coefficient `+0.2`, also at its *upper* bound). Both are blocked, so
  `checkBasicForConflict` succeeds and the run ends.

The Farkas certificate is that last identity cleared of fractions:
`4*(x + 6y) + 1*(x + y) = 5*(x + 5y)`, so
`5*(x + 5y) <= 4*35 + 2 = 142`, i.e. `x + 5y <= 28.4`, contradicting
`x + 5y >= 30`.

**Findings on the 4 pivot example**

*Which function performs a pivot.* All four pivots go through a single function,
`LinearEqualityModule::pivotAndUpdate` (`linear_equality.cpp:287`). Captured with:
```bash
gdb --batch \
  -ex "set breakpoint pending on" -ex "set confirm off" \
  -ex "break cvc5::internal::theory::arith::linear::LinearEqualityModule::pivotAndUpdate" \
  -ex "run" -ex "bt" \
  --args ./build/bin/cvc5 workdocs/smt_files/pivot_4.smt
```

*Call stack at the first pivot* (`x_i=2 -> x_j=0`), outermost first (line numbers
as of `e8c0387ca`):
```
main                                        main/main.cpp:37
runCvc5                                     main/driver_unified.cpp:243
PortfolioDriver::solve                      main/portfolio_driver.cpp:564
ExecutionContext::solveContinuous           main/portfolio_driver.cpp:66
CommandExecutor::doCommand                  main/command_executor.cpp:118
CommandExecutor::doCommandSingleton         main/command_executor.cpp:129
CommandExecutor::solverInvoke               main/command_executor.cpp:239
Cmd::invokeAndPrintResult                   parser/commands.cpp:133
CheckSatCommand::invoke                     parser/commands.cpp:369
Solver::checkSat                            api/cpp/cvc5.cpp:7299
SolverEngine::checkSat                      smt/solver_engine.cpp:785
SolverEngine::checkSatInternal              smt/solver_engine.cpp:822
SmtDriver::checkSat                         smt/smt_driver.cpp:79
SmtDriverSingleCall::checkSatNext           smt/smt_driver.cpp:171
SmtSolver::checkSatInternal                 smt/smt_solver.cpp:134
PropEngine::checkSat                        prop/prop_engine.cpp:490
MinisatSatSolver::solve                     prop/minisat/minisat.cpp:223
SimpSolver::solve                           prop/minisat/simp/SimpSolver.h:275
SimpSolver::solve_                          prop/minisat/simp/SimpSolver.cc:151
Solver::solve_                              prop/minisat/core/Solver.cc:1756
Solver::search                              prop/minisat/core/Solver.cc:1491
Solver::propagate                           prop/minisat/core/Solver.cc:1186
Solver::theoryCheck                         prop/minisat/core/Solver.cc:1271
TheoryProxy::theoryCheck                    prop/theory_proxy.cpp:271
TheoryEngine::check                         theory/theory_engine.cpp:468
Theory::check                               theory/theory.cpp:600
TheoryArith::postCheck                      theory/arith/theory_arith.cpp:255
LinearSolver::postCheck                     theory/arith/linear/linear_solver.cpp:79
TheoryArithPrivate::postCheck               theory/arith/linear/theory_arith_private.cpp:3670
TheoryArithPrivate::solveRealRelaxation     theory/arith/linear/theory_arith_private.cpp:3460
DualSimplexDecisionProcedure::findModel     theory/arith/linear/dual_simplex.h:73
DualSimplexDecisionProcedure::dualFindModel theory/arith/linear/dual_simplex.cpp:125
DualSimplexDecisionProcedure::searchForFeasibleSolution   theory/arith/linear/dual_simplex.cpp:213
LinearEqualityModule::pivotAndUpdate        theory/arith/linear/linear_equality.cpp:290
```
Note that two distinct classes shorten to `Solver::` here — the public API
`cvc5::Solver` (`api/cpp/cvc5.cpp`) and MiniSat's `cvc5::internal::Minisat::Solver`
(`prop/minisat/core/Solver.cc`). The file column disambiguates them.
Every frame from `Theory::check` down carries `EFFORT_STANDARD`, and
`Solver::propagate` is entered with `CHECK_WITH_THEORY`.

The stack is identical to `basic_conflict.smt` from `findModel` outwards, but
**diverges inside `dualFindModel`**: here it reaches
`searchForFeasibleSolution` (`dual_simplex.cpp:125`), whereas the zero-pivot case
conflicts earlier inside `processSignals` (`dual_simplex.cpp:72`) and never enters
the pivot loop at all. That fork is the difference between a run that pivots and
one that does not.

*Two call sites, one per violation direction.* `searchForFeasibleSolution` calls
`pivotAndUpdate` from two branches, selected by which bound the basic variable
violates:

| pivot | `x_i -> x_j` | row, violation | call site | entering-variable selector |
|---|---|---|---|---|
| #1 | `2 -> 0` | `s_4`, below **lower** bound | `dual_simplex.cpp:213` | `selectSlackUpperBound` |
| #2 | `3 -> 1` | `s_2`, above **upper** bound | `dual_simplex.cpp:233` | `selectSlackLowerBound` |
| #3 | `4 -> 2` | `s_1`, above upper bound | `dual_simplex.cpp:233` | `selectSlackLowerBound` |
| #4 | `6 -> 3` | `s_6`, above upper bound | `dual_simplex.cpp:233` | `selectSlackLowerBound` |

Only `s_4 >= 20` is a lower-bounded row, which is why the lower branch is taken
exactly once.

*Inside `pivotAndUpdate`.* Three distinct pieces of work:
```
theta = (x_i_value - beta(x_i)) / a_ij
updateTracked(x_j, assignment(x_j) + theta)   linear_equality.cpp:315  -> emits the `update` trace
++d_statistics.d_statPivots                   linear_equality.cpp:324  -> the theory::arith::pivots stat
d_tableau.pivot(x_i, x_j, d_trackCallback)    linear_equality.cpp:325  -> the actual basis swap
```
The repaired row `x_i` is simply moved to the bound it violated; `theta` is the
compensating change applied to the *entering* variable `x_j`.

*Two separate pivot counters.* `d_statPivots` (the statistic) is incremented in
`pivotAndUpdate`, while the loop counter `d_pivots` — the `#N` printed by
`-t arith::dual` — is incremented in `searchForFeasibleSolution` after
`processSignals()`. They agree here, but they are not the same variable.

*Iteration budget.* The backtrace shows `remainingIterations` counting down
`199, 198, 197, 196` across the four pivots, so this call started with a budget of
200. That is the cap that would truncate a longer walk.

**A minimal example that requires branch and bound**

`smt_files/branch_bound.smt` — two variables, four assertions:
```
(set-logic QF_LIA)
(declare-const x Int)
(declare-const y Int)
(assert (>= (+ (* 2 x) (* 3 y)) 1))
(assert (<= (+ (* 2 x) (* 3 y)) 2))
(assert (>= x 0))
(assert (<= x 0))
(check-sat)
```
Measured: `unsat`, with `theory::arith::externalBranchAndBounds = 1`,
`inferencesLemma = { ARITH_BB_LEMMA: 1, ARITH_UNATE: 2 }` and
`inferencesConflict = { ARITH_CONF_SIMPLEX: 2 }` — one branch lemma, and the two
branches it creates each refuted by simplex. No Diophantine cut is involved, so
the branching is genuinely doing the work.

*Geometric picture.* The strip `1 <= 2x + 3y <= 2` cut by the line `x = 0` is the
segment `y` in `[1/3, 2/3]`. That segment is nonempty over the reals and empty
over the integers, which is exactly the situation branch and bound exists for:
the relaxation is satisfiable, so no amount of reasoning over the rationals can
refute the problem.

*What the solver does* (`-t arith -t arith::lemma`):
```
AssertLower(2 (1,0))            row 2 = 2x + 3y, lower bound 1
AssertUpper(2 (2,0))            ... and upper bound 2
AssertLower(0 (0,0))            x pinned: lower bound 0
AssertUpper(0 (0,0))            ... and upper bound 0
update 1: (0,0)|-> (1/3,0)      y := 1/3
integer?  conf/split 0 fulleffort 1
rrbranch lemma  (or (and (not (>= y 1)) (>= y 0)) (or (not (>= y 0)) (>= y 1)))
```
With `x` pinned at 0 the row reduces to `3y in [1,2]`, so simplex assigns
`y = 1/3`. That is a perfectly good *rational* model, so no conflict is raised —
but `hasIntegerModel()` is false. This is the one place in these notes where the
guard at `theory_arith_private.cpp:3901` actually passes: the trace line reads
`conf/split 0 fulleffort 1`, against `conf/split 1 fulleffort 0` in
`basic_conflict.smt`, where the integer machinery never ran. `roundRobinBranch()`
then emits a trichotomy split on `y` at 0 — `y <= -1` or `y = 0` or `y >= 1` —
and each branch conflicts with the strip.

*Why it is minimal.* Each ingredient was checked against a counterexample; `bb`
is `externalBranchAndBounds`:

| variant | result | bb | why it does not work |
|---|---|---|---|
| `(>= (* 2 x) 1)` — one variable | sat | 0 | the row `2x` is integral, so the fractional bound is rounded to `2x >= 2` and the model is integral immediately |
| `(>= (+ (* 2 x) (* 2 y)) 1)` | sat | 0 | `gcd(2,2) = 2` divides the row, which is therefore integral; bound tightened to `>= 2` |
| `(>= (- (* 3 y) (* 3 x)) 1)` plus `(<= ... 2)` | unsat | 0 | same — integral row, tightened straight into a conflict, no branching needed |
| `(= (+ (* 4 x) (* 6 y)) 1)` | unsat | 0 | the rewriter's gcd test folds it to `false`; there are **no `setupVariable` lines at all**, so the theory never runs |
| replacing the two `x` bounds with `(= x 0)` | unsat | 0 | preprocessing substitutes `x` away, collapsing the problem to one variable |
| the strip plus **one** bound — `(>= x 0)`, `(<= x 0)` or `(>= y 0)` | sat | 1 | branches, but is satisfiable (`x=1,y=0` and `x=-1,y=1` both lie in the strip) |

So the requirements are: **two integer variables**, **coefficients sharing no
common factor**, **`x` pinned by two inequalities rather than an equality**, and
**both sides pinned** — with only one side bounded the strip still contains an
integer point. That gives four assertions; every three-assertion variant tried
came back `sat`.

*The underlying reason, and a difference from `QF_LRA`.* In the real-arithmetic
examples above, rows are normalized monic — `2x + 3y <= 15` becomes the row
`x + 1.5y <= 15/2`. In `QF_LIA` they are **not**: the trace above shows
`AssertLower(2 (1,0))` / `AssertUpper(2 (2,0))`, so the row keeps its integer
coefficients. A row with integer coefficients over integer variables always takes
integer values, so cvc5 rounds any fractional bound on it away — which is exactly
what defeats the single-variable and common-factor cases above. Branching
therefore requires the fractionality to land on an **individual variable** rather
than on a row, and pinning `x` is what forces that.

*A one-constraint variant that branches but is satisfiable:* dropping everything
except `(assert (>= (+ (* 2 x) (* 3 y)) 1))` gives `sat` with `bb = 1` — simplex
parks `x` at `1/2` and splits `x <= 0` / `x = 1` / `x >= 2`. Useful as the
smallest possible trigger, but branching is not load-bearing there since the
problem is satisfiable.

**Findings on the branch and bound example**

*Which function performs a branch.* The split is built by
`BranchAndBound::branchIntegerVariable` (`branch_and_bound.cpp:41`), reached
through `TheoryArithPrivate::roundRobinBranch`. Note the two live in **different
namespaces** — `theory::arith` for `BranchAndBound`, `theory::arith::linear` for
`TheoryArithPrivate`. Captured with:
```bash
gdb --batch \
  -ex "set breakpoint pending on" -ex "set confirm off" \
  -ex "break cvc5::internal::theory::arith::BranchAndBound::branchIntegerVariable" \
  -ex "run" -ex "bt" \
  --args ./build/bin/cvc5 workdocs/smt_files/branch_bound.smt
```

*Call stack at the branch,* outermost first (line numbers as of `e8c0387ca`):
```
main                                        main/main.cpp:37
runCvc5                                     main/driver_unified.cpp:243
PortfolioDriver::solve                      main/portfolio_driver.cpp:564
ExecutionContext::solveContinuous           main/portfolio_driver.cpp:66
CommandExecutor::doCommand                  main/command_executor.cpp:118
CommandExecutor::doCommandSingleton         main/command_executor.cpp:129
CommandExecutor::solverInvoke               main/command_executor.cpp:239
Cmd::invokeAndPrintResult                   parser/commands.cpp:133
CheckSatCommand::invoke                     parser/commands.cpp:369
Solver::checkSat                            api/cpp/cvc5.cpp:7299
SolverEngine::checkSat                      smt/solver_engine.cpp:785
SolverEngine::checkSatInternal              smt/solver_engine.cpp:822
SmtDriver::checkSat                         smt/smt_driver.cpp:79
SmtDriverSingleCall::checkSatNext           smt/smt_driver.cpp:171
SmtSolver::checkSatInternal                 smt/smt_solver.cpp:134
PropEngine::checkSat                        prop/prop_engine.cpp:490
MinisatSatSolver::solve                     prop/minisat/minisat.cpp:223
SimpSolver::solve                           prop/minisat/simp/SimpSolver.h:275
SimpSolver::solve_                          prop/minisat/simp/SimpSolver.cc:151
Solver::solve_                              prop/minisat/core/Solver.cc:1756
Solver::search                              prop/minisat/core/Solver.cc:1491
Solver::propagate                           prop/minisat/core/Solver.cc:1163
Solver::theoryCheck                         prop/minisat/core/Solver.cc:1271
TheoryProxy::theoryCheck                    prop/theory_proxy.cpp:271
TheoryEngine::check                         theory/theory_engine.cpp:468
Theory::check                               theory/theory.cpp:600
TheoryArith::postCheck                      theory/arith/theory_arith.cpp:255
LinearSolver::postCheck                     theory/arith/linear/linear_solver.cpp:79
TheoryArithPrivate::postCheck               theory/arith/linear/theory_arith_private.cpp:3969
TheoryArithPrivate::roundRobinBranch        theory/arith/linear/theory_arith_private.cpp:4130
TheoryArithPrivate::branchIntegerVariable   theory/arith/linear/theory_arith_private.cpp:4065
BranchAndBound::branchIntegerVariable       theory/arith/branch_and_bound.cpp:43
```

*Three differences from the pivot stack,* all of which explain when integer
reasoning is reachable at all:

| | pivot run | branch run |
|---|---|---|
| effort level | `EFFORT_STANDARD` | **`EFFORT_FULL`** |
| `Solver::propagate` type | `CHECK_WITH_THEORY` (`Solver.cc:1186`) | **`CHECK_FINAL`** (`Solver.cc:1163`) |
| divergence inside `postCheck` | `:3670` -> `solveRealRelaxation` | `:3969` -> `roundRobinBranch` |

The first two are the same fact seen from two sides: MiniSat only asks for a
full-effort theory check once propagation has saturated, and full effort is
precisely what the `fulleffort 1` half of the guard requires. So branch and bound
is not reachable on the propagation path at all — it lives on the final check.
The third shows that both mechanisms hang off the *same* `postCheck` frame, just
at different call sites: simplex earlier in the function, branching later, after
the guard.

*Inside `branchIntegerVariable`.* It receives the variable and its fractional
value (`y` and `1/3` here) and computes `floor`, `ceiling`, and the `nearest` of
the two. With `brabTest` enabled it builds a three-way split around `nearest`:
```
ub    = rewrite(var <= nearest - 1)
lb    = rewrite(var >= nearest + 1)
right = (or ub lb)
eq    = rewrite(var = nearest)
lemma = (or eq right)
```
which is the trichotomy printed by `-t arith::lemma`. The equality disjunct is
tried first — the comment in the source calls this "prioritize trying a simple
rounding of the real solution" — with plain branch and bound as the fallback.

*Counters.* `roundRobinBranch` is called from a `do`/`while` loop in `postCheck`
that retries lemmas until one is accepted by the output channel;
`d_externalBranchAndBounds` is incremented once per round of that loop, not once
per lemma. `d_cutCount` is bumped alongside it. The per-lemma outcome is visible
only through `-t arith-round-robin` (`..success lemma` / `..failed lemma`).

*Observing branch and bound:*
```bash
./build/bin/cvc5 --stats --stats-internal <file>.smt 2>&1 | grep -E 'externalBranchAndBounds|inferencesLemma'
./build/bin/cvc5 -t arith-round-robin -t arith::lemma <file>.smt   # the split itself
```
