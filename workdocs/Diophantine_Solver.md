# Tracing the Diophantine Solver

`DioSolver` (`src/theory/arith/linear/dio_solver.{h,cpp}`) decides systems of
linear Diophantine equations — integer equalities such as `3x + 6y = 4`. It is
the complete-but-restricted piece of integer reasoning that sits between simplex
and branch and bound.

Reference: Alberto Griggio, *A Practical Approach to Satisfiability Modulo Linear
Integer Arithmetic*, JSAT 8, pp. 1-27, 2012 (doi 10.3233/SAT190086). The source
comments refer to that paper's abstract state machine as "Alberto's rule (7)/(8)/(9)":
`scaleEqAtIndex`, `combineEqAtIndexes`, `decomposeIndex` respectively. Note the
paper is *not* in `docs/references.bib`; the only in-tree citation is the help
text of `--dio-solver`.

Relevant options: `--dio-solver` (default **true**), `--dio-turns=N` (default 10)
and `--rr-turns=N` (default 3) which round-robin between the Diophantine solver
and branch and bound. Pin these before comparing the two mechanisms.

## 0. The constraint queues

Nine fields in `DioSolver` (plus one upstream, in `TheoryArithPrivate`) look like
queues. **Only one of them is a per-call worklist**; the rest are cumulative,
context-dependent stores. Confusing them is the main source of wrong conclusions
when reading traces.

| field | type | scope | role |
|---|---|---|---|
| `d_constantIntegerVariables` *(in `TheoryArithPrivate`)* | `CDQueue<ArithVar>` | context | upstream feed: integer vars whose bounds became equal |
| `d_inputConstraints` | `CDList<InputConstraint>` | context, cumulative | every equation ever pushed, with its blame term |
| `d_nextInputConstraintToEnqueue` | `CDO<size_t>` | context | high-water mark into the above |
| `d_trail` | `CDList<Constraint>` | context, append-only | backing store: every equation + proof ever derived |
| `d_currentF` | `std::deque<TrailIndex>` | **per call** | the actual worklist |
| `d_savedQueue` / `d_savedQueueIndex` | `CDList<TrailIndex>` / `CDO<size_t>` | context | parking lot for a stalled run (currently unreachable, see below) |
| `d_subs` | `CDList<Substitution>` | context | equations already solved, stored as substitutions |
| `d_decompositionLemmaQueue` | `CDQueue<TrailIndex>` | context | fresh-variable definitions exported as lemmas (opt-in) |
| `d_proofVariablePool` / `d_lastUsedProofVariable` | `std::vector<Variable>` / `CDO<size_t>` | mixed | recycled `intvar` proof variables |

### Upstream: `d_constantIntegerVariables`

Not part of the solver. A `CDQueue<ArithVar>` in `TheoryArithPrivate`
(`theory_arith_private.h:251`), pushed at `:533`, `:704` and `:878` — every point
where an integer variable's lower and upper bounds become **equal**. Drained by
`callDioSolver` (`:1654-1657`), which turns each variable into an equation via
`mkIntegerEqualityFromAssignment` and pushes it in.

**The Diophantine solver never sees anything else.** Bounds that merely tighten,
or inequalities in general, never reach it. An empty run is usually explained
here rather than inside the solver.

### `d_inputConstraints` — cumulative, one entry per push

A `CDList<InputConstraint>` where `InputConstraint = {d_reason, d_trailPos}`:
the blame `Node` and the position of the equation in the trail.
`pushInputConstraint` (`:123`) appends to *both* this list and `d_trail`.

It is **never cleared between calls** — it only unwinds on SAT backtracking. So
`d_inputConstraints.size()` is not "the number of constraints this call was
given".

### `d_nextInputConstraintToEnqueue` — the high-water mark

`enqueueInputConstraints` (`:250`) walks only
`[d_nextInputConstraintToEnqueue, d_inputConstraints.size())`, advancing the
index as it goes. It is monotone within a context, so:

```
constraints new to this call  =  d_inputConstraints.size() - d_nextInputConstraintToEnqueue   (on entry)
```

That difference — not the size — is the per-call count. See section 7 for the gdb
recipe that prints both.

### `d_trail` — the backing store, not a queue

`CDList<Constraint>` with `Constraint = {d_eq: SumPair, d_proof: Polynomial,
d_minimalMonomial}`. Every application of rule (7)/(8)/(9) **appends a new
element** rather than mutating an existing one, so:

* `TrailIndex` values are stable for the lifetime of the context;
* superseded equations remain readable, which is exactly what lets `d_subs` and
  `d_savedQueue` hold bare indices;
* the trail only ever grows within a context — there is no compaction.

Every other structure here is a collection of `TrailIndex` values pointing into
it. "Rewriting a queue entry" always means *pointing at a different trail
element*, never editing one in place.

### `d_currentF` — the only real worklist

A plain `std::deque<TrailIndex>`. **Not** context-dependent, and cleared at the
end of every `processEquations` (`:530`), so it is genuinely per-call. Its full
set of mutations:

| operation | site | effect |
|---|---|---|
| `enqueueInputConstraints` | `:246`, `:277` | appends saved entries, then newly reduced inputs |
| `moveMinimumByAbsToQueueFront` | `:290` | **swaps** the smallest-minimal-monomial entry to the front; size unchanged |
| `pop_front` | `:486`, `:501` | removes the front equation as `solveIndex` / `decomposeIndex` consumes it |
| `subAndReduceCurrentFByIndex` | `:907` | read/write compaction: replaces entries with reduced descendants, **drops** trivially-sat and over-long ones, then `resize` |
| `clear` | `:530` | empties it at the end of the call |

Two notes. The `impliedGcdOfOne` branch does **not** pop — it solves a different
equation (the Bézout combination) and leaves the front one in place, which is why
`processEquations` tracks `reduceIndex` separately from `minimum`. And on the
conflict path in `subAndReduceCurrentFByIndex` the trailing `resize` is skipped,
so the deque is briefly left half-rewritten; harmless, because `clear()` follows,
but worth knowing if you inspect it from gdb after a conflict.

### `d_savedQueue` / `d_savedQueueIndex` — the parking lot (currently dead)

The design: when `processEquations(false)` cannot progress without introducing a
fresh variable, `saveQueue()` (`:360`) copies all of `d_currentF` here and breaks
(`:505-510`); `enqueueInputConstraints` then drains it *before* new inputs, so the
work resumes on the next call.

**In the current tree this never happens.** Both entry points —
`processEquationsForConflict` (`:540`) and `processEquationsForCut` (`:557`) —
pass `allowDecomposition = true`, so the `saveQueue()` branch is unreachable and
`d_savedQueue` stays empty. The gdb probe in section 7 confirms this: `savedQueue=0`
on every call. Treat a non-zero value as a signal that something has changed
upstream.

Note also that `saveQueue` *copies*; the `clear()` at `:530` still runs.

### `d_subs` — solved equations, kept as substitutions

`CDList<Substitution>` with `{d_fresh, d_eliminated, d_constraint}`, written by
`solveIndex` (`:730`) and `decomposeIndex`. The eliminated variable is normalized
to coefficient `-1` in the referenced trail element, and `d_fresh` is non-null
only for decomposition-introduced variables.

This is the mechanism by which **old equations keep participating without being
re-enqueued**: `enqueueInputConstraints` runs each new constraint through
`applyAllSubstitutionsToIndex` (`:671`), which applies *every* accumulated
substitution. `applySubstitution` (`:817`) is implemented as rule (8) —
`combineEqAtIndexes(ti, 1, subIndex, coeff)` — so a substitution being applied
looks identical in the trace to an ordinary Euclidean combination.

Cost consequence: each newly pushed constraint is combined against
`d_subs.size()` substitutions on the way in.

### `d_decompositionLemmaQueue` — opt-in export

`CDQueue<TrailIndex>`, pushed by `addTrailElementAsLemma` (`:948`) from
`decomposeIndex` (`:796`), but **only if `--dio-decomps` is set** (default
**false**, help: "let skolem variables for integer divisibility constraints leak
from the dio solver"). Consumed by `TheoryArithPrivate` at `:4013-4017`, which
turns each entry into a lemma via `trailIndexToEquality`.

By default this queue is always empty, so decomposition's fresh variables stay
internal to the solver.

### `d_proofVariablePool` / `d_lastUsedProofVariable` — a recycling pool

A plain `std::vector<Variable>` that grows monotonically and is **never
shrunk**, paired with a context-dependent index. `allocateProofVariable` (`:77`)
hands out `d_proofVariablePool[d_lastUsedProofVariable++]`, minting a new `intvar`
skolem only when the pool is exhausted. On backtracking the index rewinds and the
same `intvar` nodes are handed out again — deliberate reuse, which keeps the node
manager from filling with dead skolems.

`d_varToInputConstraintMap` maps a proof variable's `Node` to the index of the
input constraint it stands for, so `proofVariableToReason` (`:77`) can turn a
proof term back into blame literals. **It is a plain `unordered_map`, not
context-dependent** — combined with proof-variable recycling this means entries
are overwritten rather than removed on backtracking. Fine in practice, since a
recycled variable is always reassigned before use, but it is the one structure
here whose lifetime does not follow the context.

### Vestigial fields

Worth knowing so you do not chase them:

* `d_lastPureSubstitution` is initialized to `0` and **never assigned**, so
  `hasMorePureSubstitutions()` (`d_pureSubstitionIter < d_lastPureSubstitution`)
  is always false and `nextPureSubstitution()` is unreachable. Nothing outside the
  solver calls either. The "pure substitution" export API is dead in this tree.
* `d_usedDecomposeIndex` is set to `true` in `decomposeIndex` (`:749`) and never
  read anywhere.
* `d_maxInputCoefficientLength`, by contrast, **is** live: updated by
  `pushInputConstraint` (`:133`) and read by `anyCoefficientExceedsMaximum`
  (`:226`).

## 1. Statistics first: did it run, and did it achieve anything?

```bash
./build/bin/cvc5 --stats --stats-internal <file>.smt 2>&1 | grep 'arith::dio'
```
As with all arith internals: `--stats-internal` is required, output goes to
**stderr**, and zero-valued statistics are omitted unless `--stats-all`.

```
theory::arith::dio::conflictCalls = 2      theory::arith::dio::conflicts = (absent, i.e. 0)
theory::arith::dio::cutCalls     = 1      theory::arith::dio::cuts     = 1
theory::arith::dio::conflictTimer = 0ms   theory::arith::dio::cutTimer = 0ms
```
Read the **calls-versus-successes ratio**. Above, the solver was asked for a
conflict twice and found none, then asked for a cut once and found one. If both
call counters are zero it never ran: check `--dio-solver` and the guard at
`theory_arith_private.cpp:3904`, which needs `!emmittedConflictOrSplit &&
fullEffort && !hasIntegerModel()` — the same guard as branch and bound (see the
`integer?  conf/split C fulleffort F` line under `-t arith`).

## 2. What was it actually given?

**Use `-t dio::pushInputConstraint`.** One line per real push, with the trail
position:
```
pushInputConstraint @ 0 (= x 1) (and (not (>= x 2)) (>= x 1))
pushInputConstraint @ 2 (= (* 2 x) (+ 1 (* (- 3) y))) (= (* 2 x) (+ 1 (* (- 3) y)))
```
Format is `@ <trailPos> <equation> <reason>`. The reason is the blame term used
if this equation ends up in a conflict.

`-t dio::push` also works but **must be filtered** — the tag has five sites
meaning two different things:

* `dio::push <v>` (bare), `theory_arith_private.cpp:534/705/879` — an integer
  variable's bounds just became **equal**, so it is queued onto
  `d_constantIntegerVariables`. A *candidate*, not yet given to the solver.
* `dio::push <v> <eq> with reason <lits>`, `theory_arith_private.cpp:1697` — the
  actual `pushInputConstraint` from `callDioSolver`.
* `dio::push <v> <eq>` (no reason), `theory_arith_private.cpp:1582` — a
  *speculative* equality pushed by `dioCutting`.

So `grep -c 'with reason'` counts only the `callDioSolver` pushes, which is
usually not what you want. Prefer the dedicated tag.

Key fact: the solver only ever sees variables whose lower and upper bounds have
become equal. **If nothing is pushed, that is a property of the benchmark, not a
misconfiguration** — there is nothing for it to work on.

## 3. The elimination log: `-t arith::dio`

The main tag (25 call sites). Read it as the `processEquations` worklist:

| trace line | meaning |
|---|---|
| `processEquations i : <eq>` | equation picked off the front (smallest \|coefficient\| monomial) |
| `reduceByGCD <p>` then `gcd(p)=g c` | divide by `g`; **`g` not dividing `c` is the infeasibility test** |
| `scaleEqAtIndex(i,g)` | rule (7) — scale an equation |
| `combineEqAtIndexes(i,q,j,r)` with `d_facts[i]`/`d_facts[j]` | rule (8) — form `q*eq_i + r*eq_j` |
| `before`/`after solveIndex(...) for v` | a unit coefficient was available; `v` eliminated into a substitution |
| `next round`, `extendedReduction :`, `... combine`/`... drop` | `impliedGcdOfOne` running extended Euclid to *manufacture* a unit coefficient |
| `before decomposeIndex(...)` | rule (9) — no unit coefficient; a fresh variable is introduced |
| `dioCutting found the plane:` / `resulting in the cut:` | the cut handed back to arithmetic |

Two things to look for:

* **`extendedReduction` lines are the good path.** They mean `impliedGcdOfOne`
  found a column whose coefficient gcd is 1 and reached a unit coefficient by
  combining existing equations. No fresh variables.
* **`before decomposeIndex` is the expensive fallback**, invoked only when no
  column has gcd 1. It mints a fresh `intvar`, which grows the problem.

## 4. Read the proof column

Every `derived` line carries `with proof <linear combination>`:
```
derived (+ (* 3 y) 1) with proof (+ (* (- 2) intvar_1) intvar_2)
```
This is the Diophantine analogue of a Farkas certificate: the derived equation is
`eq_2 - 2*eq_1` over the input equations. `proveIndex` reads it to blame the
original literals, so this is where to look if a conflict explanation looks wrong.

**Gotcha:** `makeIntegerVariable` (`dio_solver.cpp:30`) mints skolems named
`intvar` for **both** proof variables (`allocateProofVariable`) *and*
`decomposeIndex`'s fresh variables. They are indistinguishable by name — only
position tells them apart: inside `with proof (...)` it is a proof variable,
inside the equation itself it is a real fresh variable.

## 5. `-t arith::dio::max` — silent information loss

Three sites, all in `anyCoefficientExceedsMaximum` (`:220`). The exact test is

```cpp
nmonos >= 2 && length > d_maxInputCoefficientLength + MAX_GROWTH_RATE
```

where `length` is a **bit** length — `Constant::length()` bottoms out in
`Integer::length()`, i.e. `mpz_sizeinbase(_, 2)`, the smallest `n` with
`2^(n-1) <= |x| < 2^n`. `MAX_GROWTH_RATE` is 3, so an equation is dropped once
its largest coefficient is more than **three bits longer** than the longest
coefficient of any input pushed so far — roughly a factor of 8 in magnitude, not
a factor of 3. Two details follow from the formula:

* Single-monomial equations (`nmonos < 2`) are **never** dropped, however large
  their coefficient.
* The budget is a moving target: `d_maxInputCoefficientLength` is context-dependent
  and raised by `pushInputConstraint` (`:133`), so pushing an input with large
  coefficients widens the allowance for every later derivation.

Equations that trip the test are **dropped outright** — not solved, not saved.
This is the deliberate incompleteness in the implementation, and this tag is the
only way to observe it. When the trace fires it prints both the equation and its
proof:

```
about to drop:
d_trail[j].d_eq = ...
d_trail[j].d_proof = ...
```

Reach for it when the solver visibly runs but fails to refute something you
believe it should. Two places drop entries:
`enqueueInputConstraints` (on the way in) and `subAndReduceCurrentFByIndex`
(during substitution compaction).

## 6. Tags to mostly avoid

`-t queueConditions` (5 sites) is the internal invariant checker; only useful if
you suspect a queue-invariant violation. `printQueue()` dumps the whole worklist
into the `arith::dio` stream, which is what makes that tag verbose on real
benchmarks.

## 7. gdb: queue lengths and per-call sizes

The traces have no per-call delimiter, so counting what each call received needs
the debugger. `d_inputConstraints` is a `context::CDList` that **accumulates
across calls** and is never cleared per call, so its size is not the per-call
count — the difference against `d_nextInputConstraintToEnqueue` is.

```gdb
# diocount.gdb  --  run: gdb --batch -x diocount.gdb --args ./build/bin/cvc5 <file>.smt
set breakpoint pending on
set confirm off
set pagination off
break cvc5::internal::theory::arith::linear::DioSolver::processEquations
commands
silent
printf "--- processEquations: inputConstraints=%lu nextToEnqueue=%lu savedQueue=%lu\n", this->d_inputConstraints.size(), this->d_nextInputConstraintToEnqueue.get(), this->d_savedQueue.size()
continue
end
run
```
On the worked example below this prints:
```
--- processEquations: inputConstraints=0 nextToEnqueue=0 savedQueue=0
--- processEquations: inputConstraints=1 nextToEnqueue=0 savedQueue=0
--- processEquations: inputConstraints=2 nextToEnqueue=1 savedQueue=0
```
Three calls (matching `conflictCalls=2 + cutCalls=1`); the list grows `0 -> 1 -> 2`
with `nextToEnqueue` trailing one behind, so each call after the first received
exactly one new equation — and **the first call received none at all**. An empty
call is normal.

Mechanics: `d_nextInputConstraintToEnqueue` is a `context::CDO<size_t>`, so it
needs `.get()`. Breaking on the private `processEquations` rather than the two
public entry points catches both the conflict and cut paths at once. The
`commands`/`silent`/`continue` block requires a script file — it does not survive
being passed as `-ex`.

Other useful breakpoints: `DioSolver::decomposeIndex` (fresh-variable
introduction), `DioSolver::reduceByGCD` (where infeasibility is detected),
`DioSolver::impliedGcdOfOne` (the extended-Euclid path). Per `GDB.md`: set
breakpoints pending, and use `call x.toString()` rather than `print x` on
`Node`/`SumPair`/`Rational` values.

## 8. Worked example

```
(set-logic QF_LIA)
(declare-const x Int)
(declare-const y Int)
(assert (>= (+ (* 2 x) (* 3 y)) 1))
(check-sat)
```
`./build/bin/cvc5 -t dio::push -t arith::dio <file>.smt`, annotated:
```
dio::push 0                                       x's bounds became equal -> candidate
callDioSolver 0
dio::push 0 (= x 1) with reason (and (not (>= x 2)) (>= x 1))
reduceByGCD x
gcd(x)=1 -1                                       gcd 1 divides -1, no conflict
processEquations 0 : (+ x (- 1))
before solveIndex(0:(+ x (- 1)))
scaleEqAtIndex(0,-1)                              rule (7)
derived (+ (* (- 1) x) 1) with proof (* (- 1) intvar_1)
after solveIndex (+ (* (- 1) x) 1) for x          substitution recorded in d_subs
dio::push 2 (= (* 2 x) (+ 1 (* (- 3) y)))         speculative push from dioCutting
combineEqAtIndexes(2,1,1,2)                       rule (8): the substitution being applied
d_facts[i] = (+ (+ (* 2 x) (* 3 y)) (- 1))          the new equation
d_facts[j] = (+ (* (- 1) x) 1)                      trail index 1, from the PREVIOUS call
derived (+ (* 3 y) 1) with proof (+ (* (- 2) intvar_1) intvar_2)
reduceByGCD (* 3 y)
gcd((* 3 y))=3 1                                  3 does not divide 1 -> integer-infeasible
dioCutting found the plane: (+ (* 3 y) 1)
resulting in the cut: (or (not (>= y 0)) (>= y 0))
```
The `combineEqAtIndexes(2,1,1,2)` line is worth dwelling on: `applySubstitution`
is *implemented as* rule (8) (`combineEqAtIndexes(ti, 1, subIndex, coeff)`), so
this is the substitution `x := 1` — derived on the previous call, trail index 1 —
being applied to the freshly pushed equation, with multiplier 2 because `x`'s
coefficient there is 2. Old equations are never re-enqueued; they persist in
solved form as substitutions in `d_subs`.

## Gotchas checklist

* [ ] `--stats-internal` and `2>&1`, or the statistics are invisible.
* [ ] Prefer `-t dio::pushInputConstraint` over `-t dio::push` for inputs; the
      latter mixes candidates, real pushes and speculative pushes.
* [ ] Nothing pushed means no variable had equal bounds — not a broken setup.
* [ ] `intvar_N` is ambiguous between proof variables and decomposition
      variables; disambiguate by position.
* [ ] `d_inputConstraints.size()` is cumulative, not per-call; subtract
      `d_nextInputConstraintToEnqueue`.
* [ ] A small `d_currentF` says nothing about how much the solver knows — the
      history lives in `d_subs` and `d_trail`.
* [ ] Unexplained failure to refute? Check `-t arith::dio::max` for dropped
      equations before suspecting a bug.
* [ ] `dioCutting` runs under a `context::Context::ScopedPush`, so its
      speculative pushes and any substitutions derived from them are unwound
      afterwards.
* [ ] The coefficient cap is additive in **bit** length (`+3` bits, so ~8x in
      magnitude), and single-monomial equations are exempt.
* [ ] `d_savedQueue` is expected to be empty: both entry points pass
      `allowDecomposition = true`, so `saveQueue()` is unreachable.
* [ ] Do not chase `nextPureSubstitution` / `d_usedDecomposeIndex` — both are
      vestigial (see section 0).
