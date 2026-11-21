**Running Benchmarks**
* Always pass `--stats --stats-internal` to get per-module statistics; note they
  are written to **stderr**, so capture with `2>&1`.
* Use the option set `--enum-inst --user-pat=strict --no-cbqi --sat-solver=cadical`.
* For comparison with z3, use the options `auto_config=false smt.mbqi=false smt.qi.eager_threshold=100.0 smt.delay_units=true smt.arith.nl=false`
* Zero-valued statistics are omitted; add `--stats-all` to print them explicitly.

**Attempted Optimizations**
* Node-free DIO arithmetic (branch `dio-optimize`, build `buildDioLinear`):
  `DioSolver` uses a new `DioLinearForm`, a sorted vector of (variable id,
  coefficient) pairs, instead of `Polynomial`/`SumPair`; proofs are forms over
  input-constraint indices. Without the `getCoefficient` changes below.
  `make check` and `make regress` pass. On the 107 benchmarks vs. upstream main
  (`build/`): 72 → 79 solved, none lost; on the 72 solved by both, −24% total
  time and −97% DIO solver time.
* Skip non-overlapping substitutions in `dio_solver.cpp`: where an equation is
  reduced by every substitution in `d_subs`, skip those whose variables do not
  overlap the equation's. No significant change in total or DIO solver time.
* Binary search in `Polynomial::getCoefficient` (`normal_form.cpp`, build
  `buildExpr`): `make check` passes; potential minor speedup on the 107
  benchmarks (−1.6% total time, −10% DIO solver time); DIO polynomials have
  ≤ 9 monomials.
* No `parseMonomial` in the `getCoefficient` binary search: probes read only
  the child's VarList via new `Monomial::parseVarListOf`; the coefficient is
  built once, on a match. `make check` passes; vs. the binary search alone,
  −14% total time and −40% DIO solver time

**Potential Optimizations**
* Report DIO substitutions to the main solver. Today `d_subs` never leaves the
  DIO solver, and the intended `nextPureSubstitution` API has been a stub
  since 2012. Substitutions generally cannot be applied as rewrites mid-search,
  because the eliminated "variables" are normal-form leaves: on 10 Mariposa
  benchmarks, 85% were UF/selector applications, 12% 0-ary constants and 3%
  nonlinear products. Instead, export them as entailed equalities, explained by
  `proveIndex`, through `ArithCongruenceManager::assertLitToEqualityEngine`.
  Over Z, a consistent system implies the same linear equalities as over Q, so
  the payoff is for the equality engine and theory combination (fewer
  combination splits), not simplex. Caveats:
  * substitutions that restate a single input are redundant (the equality
    engine already gets them via `equalsConstant`), so only those combining
    ≥ 2 inputs add information
  * never export from `dioCutting`, whose speculative inputs are self-justified
  * skip solved forms containing fresh variables (rare: 2 decompositions in 10
    benchmarks)

  Start with `t = c` and `t = u` forms after back-substitution, which create no
  new terms.

**Finding Optimization Targets**

The workflow that found the DIO optimization, for any component of cvc5:
1. Rank components across benchmarks. Run the benchmark list with
   `benchanalysis/runbench.sh` and divide each component's timer by
   `global::totalTime`, as in the triage spreadsheet (e.g.
   `theory::<theory>::checkTime`, `theory::QuantifiersEngine::time_ematching`,
   `prop::CnfStream::cnfConversionTime`,
   `smt::SolverEngine::processAssertionsTime`). Timers nest and leave gaps:
   `theory::arith::checkTime` contains the DIO timers, and work done outside a
   timer's scope (e.g. building the DIO solver's inputs) is not counted.
2. Pick a benchmark where the component takes a large share and that runs for
   5–15 s, plus one where its share is near zero for contrast.
3. Profile both with `perf` (`workdocs/Profiling.md`). Start from the
   component's entry point and use `stacks.py` to descend to the functions
   that dominate. Leaders in self time tell you whether the cost is the
   algorithm or the data representation: for DIO it was `Node` reference
   counting, GMP copies and `getType` lookups, not the elimination itself.
4. Estimate the payoff before writing code: the component's share of total
   time times the reduction you expect. Profile first; the `getCoefficient`
   binary search was written before profiling and gained little.
5. Implement on a separate branch and build directory, then run `make check`
   and `make regress`.
6. Measure against a fresh baseline built from the same base commit, with the
   same benchmark list and options and nothing else running on the machine.
   Compare solved counts, then total and component time on the benchmarks
   both solve. Benchmarks that never use the component are the noise control:
   their work counters (pivots, propagations, conflicts) should be identical.
   A change that creates fewer `Node`s shifts node ids, which can change the
   search elsewhere even when the component behaves identically.

`baseExprCmp.sh` extracts the arithmetic and DIO timers only; for another
component, change the statistic names it reads.