#!/bin/bash
# Extract raw statistics from benchresult/*.z3.stats into a TSV table.
#
# Emits data only -- no formatting.  Pipe or redirect it; render elsewhere.
#   ignore/mkz3perftable.sh               # TSV to stdout
#   ignore/mkz3perftable.sh out.tsv       # TSV to a file
#
# z3 prints statistics as an s-expression on STDOUT, e.g.
#   (:arith-conflicts 285
#    :total-time      12.34)
# so keys are parsed per line after stripping the enclosing parens.
# Times (:time, :total-time) are SECONDS as floats -- cvc5 reports integer ms.
# A missing key yields 0: z3, like cvc5, omits statistics it never touched.
#
# The verdict is NOT always on line 1: benchmarks containing (get-info :version)
# print (:version "...") first, so we scan for the verdict anywhere in the file.
set -u

RES=${RES:-/home/indprinciples/Research/cvc5/benchresult}
SUFFIX=${SUFFIX:-.z3.stats}

# statistic key (without leading ':') -> column name.
# Coverage across the current 107-file set is noted in comments.
KEYS=(
  "total-time|total_time_s"              # 107/107
  "time|time_s"                          # 107/107
  "quant-instantiations|quant_inst"      # 107/107
  "arith-conflicts|arith_conflicts"      # 107/107
  "arith-make-feasible|arith_make_feasible"  # 107/107
  "arith-max-rows|arith_max_rows"        # 107/107
  "arith-dio-calls|arith_dio_calls"      #  32/107
  "arith-dio-tighten-conflicts|arith_dio_tighten_conflicts"  # 9/107
  "arith-gcd-calls|arith_gcd_calls"      #  29/107
  "arith-gomory-cuts|arith_gomory_cuts"  #  24/107
  "arith-branch|arith_branch"            #  26/107
)

shopt -s nullglob
files=("$RES"/*"$SUFFIX")
if [ ${#files[@]} -eq 0 ]; then
  echo "no *$SUFFIX files in $RES" >&2; exit 1
fi

emit() {
  printf 'benchmark'
  for kv in "${KEYS[@]}"; do printf '\t%s' "${kv#*|}"; done
  printf '\tresult\n'

  for f in "${files[@]}"; do
    # normalise the s-expression into "key value" lines once per file
    norm=$(sed 's/^[( ]*//; s/)[[:space:]]*$//' "$f" | awk '/^:/{print substr($1,2), $2}')
    printf '%s' "$(basename "$f" "$SUFFIX")"
    for kv in "${KEYS[@]}"; do
      key=${kv%%|*}
      v=$(printf '%s\n' "$norm" | awk -v k="$key" '$1==k{print $2; exit}')
      [ -z "$v" ] && v=0
      printf '\t%s' "$v"
    done
    printf '\t%s\n' "$(grep -m1 -xE 'sat|unsat|unknown|timeout' "$f" || echo NONE)"
  done
}

if [ $# -ge 1 ]; then
  emit > "$1"; echo "wrote $1 (${#files[@]} rows)" >&2
else
  emit
fi
