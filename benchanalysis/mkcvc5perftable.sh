#!/bin/bash
# Extract raw statistics from benchresult/*.cvc5.stats into a TSV table.
#
# Emits data only -- no formatting.  Pipe or redirect it; render elsewhere.
#   ignore/mkperftable.sh                 # TSV to stdout
#   ignore/mkperftable.sh out.tsv         # TSV to a file
#
# Columns: benchmark, one per key in KEYS below, then the solver result.
# Times are whatever the statistic reports (ms), with the trailing "ms" stripped.
# A missing key yields 0: cvc5 omits zero-valued statistics unless --stats-all.
set -u

RES=${RES:-/home/indprinciples/Research/cvc5/benchresult}
SUFFIX=${SUFFIX:-.cvc5.stats}

# statistic key -> column name
KEYS=(
  "global::totalTime|total"
  "theory::arith::checkTime|arith_checkTime"
  "theory::QuantifiersEngine::time|QE_time"
  "theory::quantifiers::checkTime|quant_checkTime"
  "theory::arith::dio::conflictTimer|dio_conflictTimer"
)

shopt -s nullglob
files=("$RES"/*"$SUFFIX")
if [ ${#files[@]} -eq 0 ]; then
  echo "no *$SUFFIX files in $RES" >&2; exit 1
fi

emit() {
  # header
  printf 'benchmark'
  for kv in "${KEYS[@]}"; do printf '\t%s' "${kv#*|}"; done
  printf '\tresult\n'
  # rows
  for f in "${files[@]}"; do
    printf '%s' "$(basename "$f" "$SUFFIX")"
    for kv in "${KEYS[@]}"; do
      key=${kv%%|*}
      v=$(grep -m1 -F "$key = " "$f" | sed 's/.*= //; s/ms$//')
      [ -z "$v" ] && v=0
      printf '\t%s' "$v"
    done
    printf '\t%s\n' "$(grep -m1 -xE 'sat|unsat|unknown' "$f" || echo TO)"
  done
}

if [ $# -ge 1 ]; then
  emit > "$1"
  echo "wrote $1 (${#files[@]} rows)" >&2
else
  emit
fi
