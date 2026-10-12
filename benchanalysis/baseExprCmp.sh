#!/bin/bash
# Compare per-benchmark cvc5 timings between two result directories, by
# default the baseline (benchresult/) and the optimized build (benchresultExpr/).
#
#   benchanalysis/baseExprCmp.sh              # CSV to stdout
#   benchanalysis/baseExprCmp.sh out.csv      # CSV to a file
#   BASE_RES=benchresultBase benchanalysis/baseExprCmp.sh out.csv
#
# Joins $BASE_RES/<stem>.cvc5.stats with $EXPR_RES/<stem>.cvc5.stats. For each
# side the columns are:
#   result    sat, unsat, unknown, or TO (no verdict, i.e. killed by the timeout)
#   total_ms  global::totalTime
#   arith_ms  theory::arith::checkTime
#   dio_ms    theory::arith::dio::conflictTimer + theory::arith::dio::cutTimer
# Times are integer ms. A missing statistic counts as 0, because cvc5 omits
# zero-valued statistics; e.g. dio_ms is 0 when the DIO solver never ran.
# A benchmark missing from EXPR_RES gets NA and result MISSING.
#
# Note: benchresult/ was produced by cvc5 1.3.5.dev+arith-workdocs@c17c93b09a-
# modified, not by the current build/ binary (9f8c5a3389). For an exact
# baseline, regenerate it with
#   BIN=build/bin/cvc5 RES=benchresultBase benchanalysis/runbench.sh
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
BASE_RES=${BASE_RES:-$ROOT/benchresult}
EXPR_RES=${EXPR_RES:-$ROOT/benchresultExpr}

val() { local x; x=$(grep -m1 -F "$2 = " "$1" | sed 's/.*= //; s/ms$//'); [ -z "$x" ] && x=0; echo "$x"; }
res() { grep -m1 -xE 'sat|unsat|unknown' "$1" || echo TO; }
cols() {  # result,total,arith,dio for one stats file
  local f=$1
  printf '%s,%s,%s,%s' "$(res "$f")" "$(val "$f" 'global::totalTime')" \
    "$(val "$f" 'theory::arith::checkTime')" \
    "$(( $(val "$f" 'theory::arith::dio::conflictTimer') + $(val "$f" 'theory::arith::dio::cutTimer') ))"
}

shopt -s nullglob
files=("$BASE_RES"/*.cvc5.stats)
[ ${#files[@]} -eq 0 ] && { echo "no *.cvc5.stats in $BASE_RES" >&2; exit 1; }

emit() {
  echo 'benchmark,base_result,base_total_ms,base_arith_ms,base_dio_ms,expr_result,expr_total_ms,expr_arith_ms,expr_dio_ms'
  for bf in "${files[@]}"; do
    b=$(basename "$bf" .cvc5.stats)
    ef="$EXPR_RES/$b.cvc5.stats"
    printf '%s,%s,' "$b" "$(cols "$bf")"
    if [ -f "$ef" ]; then cols "$ef"; else printf 'MISSING,NA,NA,NA'; fi
    printf '\n'
  done
}

if [ $# -ge 1 ]; then emit > "$1"; echo "wrote $1 (${#files[@]} rows)" >&2; else emit; fi
