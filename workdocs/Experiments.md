**Running Benchmarks**
* Always pass `--stats --stats-internal` to get per-module statistics; note they
  are written to **stderr**, so capture with `2>&1`.
* Use the option set `--enum-inst --user-pat=strict --no-cbqi --sat-solver=cadical`.
* For comparison with z3, use the options `auto_config=false smt.mbqi=false smt.qi.eager_threshold=100.0 smt.delay_units=true smt.arith.nl=false`
* Zero-valued statistics are omitted; add `--stats-all` to print them explicitly.
