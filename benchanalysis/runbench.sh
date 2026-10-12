#!/bin/bash
# Run cvc5 or z3 on the benchmark list and write one stats file per benchmark.
#
#   benchanalysis/runbench.sh                                  # cvc5 -> benchresult/
#   BIN=buildExpr/bin/cvc5 RES=benchresultExpr benchanalysis/runbench.sh
#   SOLVER=z3 BIN=/path/to/z3 benchanalysis/runbench.sh        # z3 -> benchresult/
#
# Output: $RES/<stem>.<solver>.stats, holding stdout and stderr together, in the
# format benchanalysis/mk*.sh expect. The stem is the benchmark's basename
# without .smt2. The two benchmarks that share the basename
# bin_sizeslib!bin_sizes.div2._01 get their parent directory as a prefix
# (mimalloc__..., nia__...).
#
# Options are the ones in workdocs/Experiments.md. Each run is killed with
# SIGTERM after $TIMEOUT seconds; cvc5 then prints "cvc5 interrupted by
# SIGTERM" plus its statistics, which the analysis scripts count as a timeout.
#
# A full run takes about 35 minutes. Start it detached so that closing the
# terminal doesn't kill it:
#   setsid nohup benchanalysis/runbench.sh > runbench.log 2>&1 &
# If it is interrupted anyway, rerun with RESUME=1 to redo only the
# benchmarks that have no complete result.
#
# Settings (environment variables):
#   SOLVER   cvc5 (default) or z3
#   BIN      solver binary (default: buildExpr/bin/cvc5, or z3 on PATH)
#   RES      output directory (default: benchresult)
#   BASE     directory the benchmark paths are relative to
#   LIST     benchmark list: a .md file whose first ``` block lists the paths
#            (default benchanalysis/perftable.md), or a file of one path per line
#   JOBS     parallel solver instances (default 8)
#   TIMEOUT  seconds per benchmark (default 300)
#   RESUME   1 = skip benchmarks whose result is already complete
#   DRYRUN   1 = print the commands instead of running them
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SOLVER=${SOLVER:-cvc5}
RES=${RES:-$ROOT/benchresult}
BASE=${BASE:-/mnt/d/3_Tmp/Arith_Bench_Unpack}
LIST=${LIST:-$ROOT/benchanalysis/perftable.md}
JOBS=${JOBS:-8}
TIMEOUT=${TIMEOUT:-300}
RESUME=${RESUME:-0}
DRYRUN=${DRYRUN:-0}

case "$SOLVER" in
  cvc5)
    BIN=${BIN:-$ROOT/buildExpr/bin/cvc5}
    OPTS=(--stats --stats-internal
          --enum-inst --user-pat=strict --no-cbqi --sat-solver=cadical) ;;
  z3)
    BIN=${BIN:-z3}
    OPTS=(-st auto_config=false smt.mbqi=false smt.qi.eager_threshold=100.0
          smt.delay_units=true smt.arith.nl=false) ;;
  *) echo "SOLVER must be cvc5 or z3, not '$SOLVER'" >&2; exit 1 ;;
esac
command -v "$BIN" >/dev/null || [ -x "$BIN" ] || { echo "no solver binary: $BIN" >&2; exit 1; }

# Benchmark paths, relative to BASE.
if [[ "$LIST" == *.md ]]; then
  paths=$(awk '/^```/{c++; next} c==1' "$LIST")
else
  paths=$(grep -v '^\s*$' "$LIST")
fi

# "path|stem" per benchmark. The perftable paths still carry the old
# sundance/ prefix; UFDTLIA/ and UFDTNIA/ now live directly under BASE.
jobs=()
missing=0
while IFS= read -r p; do
  rel=${p#./}; rel=${rel#sundance/}
  stem=$(basename "$rel" .smt2)
  case "$stem" in
    'bin_sizeslib!bin_sizes.div2._01') stem="$(basename "$(dirname "$rel")")__$stem" ;;
  esac
  if [ ! -f "$BASE/$rel" ]; then echo "missing: $BASE/$rel" >&2; missing=1; fi
  jobs+=("$BASE/$rel|$stem")
done <<< "$paths"
[ "$missing" -eq 0 ] || { echo "aborting: benchmarks missing under $BASE" >&2; exit 1; }
dups=$(printf '%s\n' "${jobs[@]}" | cut -d'|' -f2 | sort | uniq -d)
[ -z "$dups" ] || { echo "aborting: duplicate stems: $dups" >&2; exit 1; }

# A result is complete if it has a verdict, or (cvc5) was stopped by the
# timeout rather than by something else.
complete() {
  local f=$1
  [ -s "$f" ] || return 1
  grep -qxE 'sat|unsat|unknown' "$f" && return 0
  if [ "$SOLVER" = cvc5 ] && grep -q 'interrupted by SIGTERM' "$f"; then
    local t
    t=$(grep -m1 'global::totalTime' "$f" | sed 's/.*= //; s/ms$//')
    [ -n "$t" ] && [ "$t" -ge $(( (TIMEOUT - 1) * 1000 )) ] && return 0
  fi
  return 1
}

run_one() {
  local file=${1%%|*} stem=${1#*|}
  local out="$RES/$stem.$SOLVER.stats"
  if [ "$RESUME" = 1 ] && complete "$out"; then return 0; fi
  if [ "$DRYRUN" = 1 ]; then
    printf 'timeout %s %q' "$TIMEOUT" "$BIN"; printf ' %q' "${OPTS[@]}" "$file"
    printf ' > %q 2>&1\n' "$out"
    return 0
  fi
  timeout "$TIMEOUT" "$BIN" "${OPTS[@]}" "$file" > "$out" 2>&1
}
export -f run_one complete
export SOLVER BIN RES TIMEOUT RESUME DRYRUN
export OPTS_STR="${OPTS[*]}"   # arrays don't export; rebuilt below

mkdir -p "$RES"
echo "solver: $("$BIN" --version 2>/dev/null | head -1)" >&2
echo "${#jobs[@]} benchmarks, $JOBS parallel, ${TIMEOUT}s each -> $RES" >&2
start=$(date +%s)
printf '%s\n' "${jobs[@]}" \
  | xargs -d '\n' -P "$JOBS" -I{} bash -c 'read -ra OPTS <<< "$OPTS_STR"; run_one "$1"' _ {}

[ "$DRYRUN" = 1 ] && exit 0
echo "done in $(( $(date +%s) - start ))s" >&2

# Summary.
n_unsat=0; n_sat=0; n_unknown=0; n_to=0; n_bad=0
for j in "${jobs[@]}"; do
  f="$RES/${j#*|}.$SOLVER.stats"
  v=$(grep -m1 -xE 'sat|unsat|unknown' "$f" 2>/dev/null)
  case "$v" in
    unsat) n_unsat=$((n_unsat + 1)) ;;
    sat) n_sat=$((n_sat + 1)) ;;
    unknown) n_unknown=$((n_unknown + 1)) ;;
    *) if complete "$f"; then n_to=$((n_to + 1)); else n_bad=$((n_bad + 1)); echo "incomplete: $f" >&2; fi ;;
  esac
done
echo "unsat $n_unsat, sat $n_sat, unknown $n_unknown, timeout $n_to, incomplete $n_bad" >&2
[ "$n_bad" -eq 0 ]
