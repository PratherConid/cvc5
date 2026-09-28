#!/bin/bash
# Merge the cvc5 and z3 statistics for each benchmark into one CSV.
#
#   benchanalysis/mkmergedtable.sh            # CSV to stdout
#   benchanalysis/mkmergedtable.sh out.csv    # CSV to a file
#
# Joins benchresult/<stem>.cvc5.stats with benchresult/<stem>.z3.stats.
# Columns are prefixed cvc5_ / z3_ because both solvers report a result and
# timings.  UNITS DIFFER: cvc5 times are integer ms, z3 times are float seconds.
# A 0 may mean genuinely zero or key absent -- both solvers omit untouched stats.
#
# cvc5_dio_calls is conflictCalls + cutCalls, the closest analogue of z3's
# :arith-dio-calls (cvc5 has no single combined counter).
set -u
RES=${RES:-/home/indprinciples/Research/cvc5/benchresult}

# cvc5: "statistic key|column"   (times in ms)
CVC5_KEYS=(
  "global::totalTime|cvc5_total_ms"
  "theory::arith::checkTime|cvc5_arith_checkTime_ms"
  "theory::QuantifiersEngine::time|cvc5_QE_time_ms"
  "theory::quantifiers::checkTime|cvc5_quant_checkTime_ms"
  "theory::arith::dio::conflictTimer|cvc5_dio_conflictTimer_ms"
  # paired with z3 counterparts (see comments on Z3_KEYS)
  "theory::arith::conflicts|cvc5_arith_conflicts"          # ~ z3 :arith-conflicts
  "theory::arith::pivots|cvc5_pivots"                      # ~ z3 :arith-make-feasible
  "theory::arith::updates|cvc5_updates"                    # ~ z3 :arith-make-feasible
  "theory::arith::initialTableauSize|cvc5_initialTableauSize"  # ~ z3 :arith-max-rows
  "Instantiate::Instantiations_Total|cvc5_quant_inst"       # ~ z3 :quant-instantiations
  "theory::arith::externalBranchAndBounds|cvc5_branch_and_bounds"
  "theory::arith::dio::cuts|cvc5_dio_cuts"
)
# z3: "statistic key (no colon)|column"   (times in seconds)
Z3_KEYS=(
  "total-time|z3_total_time_s"
  "time|z3_time_s"
  "quant-instantiations|z3_quant_inst"              # ~ cvc5 Instantiate::Instantiations_Total
  "arith-conflicts|z3_arith_conflicts"              # ~ cvc5 theory::arith::conflicts
  "arith-make-feasible|z3_arith_make_feasible"      # ~ cvc5 pivots + updates
  "arith-max-rows|z3_arith_max_rows"                # ~ cvc5 initialTableauSize
  "arith-dio-calls|z3_arith_dio_calls"
  "arith-dio-tighten-conflicts|z3_arith_dio_tighten_conflicts"
  "arith-gcd-calls|z3_arith_gcd_calls"
  "arith-gomory-cuts|z3_arith_gomory_cuts"
  "arith-branch|z3_arith_branch"
)

cvc5val() { local x; x=$(grep -m1 -F "$2 = " "$1" | sed 's/.*= //; s/ms$//'); [ -z "$x" ] && x=0; echo "$x"; }

shopt -s nullglob
files=("$RES"/*.cvc5.stats)
[ ${#files[@]} -eq 0 ] && { echo "no *.cvc5.stats in $RES" >&2; exit 1; }

emit() {
  # header
  printf 'benchmark'
  for kv in "${CVC5_KEYS[@]}"; do printf ',%s' "${kv#*|}"; done
  printf ',cvc5_dio_calls,cvc5_result'
  for kv in "${Z3_KEYS[@]}"; do printf ',%s' "${kv#*|}"; done
  printf ',z3_result\n'

  for cf in "${files[@]}"; do
    b=$(basename "$cf" .cvc5.stats)
    zf="$RES/$b.z3.stats"
    printf '%s' "$b"
    for kv in "${CVC5_KEYS[@]}"; do printf ',%s' "$(cvc5val "$cf" "${kv%%|*}")"; done
    # dio calls = conflictCalls + cutCalls
    cc=$(cvc5val "$cf" 'theory::arith::dio::conflictCalls')
    uc=$(cvc5val "$cf" 'theory::arith::dio::cutCalls')
    printf ',%s' "$((cc + uc))"
    printf ',%s' "$(grep -m1 -xE 'sat|unsat|unknown' "$cf" || echo TO)"

    if [ -f "$zf" ]; then
      norm=$(sed 's/^[( ]*//; s/)[[:space:]]*$//' "$zf" | awk '/^:/{print substr($1,2), $2}')
      for kv in "${Z3_KEYS[@]}"; do
        v=$(printf '%s\n' "$norm" | awk -v k="${kv%%|*}" '$1==k{print $2; exit}')
        [ -z "$v" ] && v=0
        printf ',%s' "$v"
      done
      printf ',%s\n' "$(grep -m1 -xE 'sat|unsat|unknown|timeout' "$zf" || echo NONE)"
    else
      for _ in "${Z3_KEYS[@]}"; do printf ',NA'; done
      printf ',MISSING\n'
    fi
  done
}

if [ $# -ge 1 ]; then emit > "$1"; echo "wrote $1 (${#files[@]} rows)" >&2; else emit; fi
