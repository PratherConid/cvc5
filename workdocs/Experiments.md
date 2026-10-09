**Running Benchmarks**
* Always pass `--stats --stats-internal` to get per-module statistics; note they
  are written to **stderr**, so capture with `2>&1`.
* Use the option set `--enum-inst --user-pat=strict --no-cbqi --sat-solver=cadical`.
* For comparison with z3, use the options `auto_config=false smt.mbqi=false smt.qi.eager_threshold=100.0 smt.delay_units=true smt.arith.nl=false`
* Zero-valued statistics are omitted; add `--stats-all` to print them explicitly.

**Attempted Optimizations**
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