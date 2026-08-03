# Debugging cvc5 with GDB

Environment these notes were verified against: GDB 12.1, `./configure.sh debug`
build at commit `e8c0387ca`, example input `workdocs/smt_files/basic_conflict.smt`.

## 0. Build facts that matter

* Build is `CMAKE_BUILD_TYPE=Debug`, `-g`, unstripped, with `debug_info`.
* **The solver code is not in the executable.** `build/bin/cvc5` is only a ~2 MB
  launcher; everything interesting lives in `build/src/libcvc5.so.1.3.5`
  (~294 MB of debug info), with the parser in `libcvc5parser.so.1`.
  This single fact causes most of the friction below.

## 1. Breakpoints must be pending

Because `TheoryArithPrivate` &co. live in a shared library that is not loaded
when GDB starts, **any** breakpoint set before `run` fails:

```
Function "cvc5::internal::theory::arith::linear::TheoryArithPrivate::AssertUpper" not defined.
```

Same for line breakpoints (`No source file named theory_arith_private.cpp.`).
The fix is to allow pending breakpoints; they resolve once the library loads:

```gdb
set breakpoint pending on
set confirm off          # required in batch mode, else the y/n prompt auto-answers N
```

Corollary: `info functions <regex>` returns nothing at startup. Run `start`
first (temporary breakpoint on `main`, which loads the libraries), then symbol
lookup works normally:

```gdb
start
info functions TheoryArithPrivate::AssertUpper
# 664: bool cvc5::internal::theory::arith::linear::TheoryArithPrivate::AssertUpper(...);
```

## 2. Prefer breakpoints over counting `n` presses

Sequences like "press `n` 34 times until `postCheck(level)`" are precise but
break on any edit to the file. Named/line breakpoints survive edits and are
reproducible. Namespaces are:

* `cvc5::internal::theory::arith::TheoryArith` — `src/theory/arith/`
* `cvc5::internal::theory::arith::linear::*` — `src/theory/arith/linear/`
  (`TheoryArithPrivate`, `LinearSolver`, `LinearEqualityModule`,
  `SimplexDecisionProcedure`, `DualSimplexDecisionProcedure`)

Whole runs can be scripted non-interactively, which makes an experiment a
single re-runnable command:

```bash
gdb --batch \
  -ex "set breakpoint pending on" -ex "set confirm off" \
  -ex "break cvc5::internal::theory::arith::linear::TheoryArithPrivate::AssertUpper" \
  -ex "run" -ex "bt 8" \
  --args ./build/bin/cvc5 workdocs/smt_files/basic_conflict.smt
```

Put repeated setup in a file and use `gdb -x setup.gdb` rather than a long
`-ex` chain.

## 3. Breaking on a *function name* lands before the locals exist

A `break <function>` binds at the opening brace, i.e. inside the prologue and
before the local declarations have run. Locals then read as garbage:

```gdb
break ...::AssertUpper
run
print x_i          # $1 = <optimized out>      <-- not a real optimization problem
```

This is not caused by `-O`; it is just that `x_i` is not live yet. **Break on a
line after the assignment instead.** Good anchor points:

| Location | Line | What is live |
|---|---|---|
| `theory_arith_private.cpp` | 507 | `AssertLower`: `x_i`, `c_i` |
| `theory_arith_private.cpp` | 678 | `AssertUpper`: `x_i`, `c_i` |

This bites hardest with **conditional** breakpoints, where it is not merely
inconvenient but silently defeats the condition:

```gdb
# BROKEN: condition can never be evaluated, breakpoint fires every time
break ...::TheoryArithPrivate::AssertLower if x_i == 1
#   Error in testing breakpoint condition:
#   value has been optimized out

# WORKS:
break theory_arith_private.cpp:507 if x_i == 1
```

## 4. Printing cvc5 values: call methods, do not `print`

Nearly every interesting cvc5 type prints as useless internals, because
`Rational`/`Integer` wrap GMP and `Node` is a pointer to a `NodeValue`.
GDB *can* call member functions in the inferior, including nested calls, and
that is the way to read these values.

```gdb
print c_i
# $2 = (const DeltaRational &) @0x...: {c = {d_value = {mp = {{_mp_num = {_mp_alloc = 1,
#       _mp_size = 1, _mp_d = 0x...}, _mp_den = ...}}}}, k = {...}}     <-- useless

print fact
# $2 = {static s_null = {...}, d_nv = 0x5555558c7750}                   <-- useless
```

Useful equivalents:

| Want | Command | Result on the example |
|---|---|---|
| A `Node` as a term | `call fact.toString()` | `"(not (>= (+ x y) 7))"` |
| A `DeltaRational` | `call c_i.toString()` | `"(6,0)"` |
| Just the rational part | `call c_i.getNoninfinitesimalPart().toString(10)` | `"6"` |
| Constraint kind | `call constraint->getType()` | `...::UpperBound` |
| **A whole `Constraint`** | `call constraint->getProofLiteral().toString()` | `"(<= (+ x y) 6)"` |
| **`ArithVar` → term** | `call this->d_partialModel.asNode(x_i).toString()` | `"(+ x y)"` |
| Is it mapped? | `call this->d_partialModel.hasNode(x_i)` | `true` |

The `ArithVar → Node` lookup is the single most valuable one: traces and the
tableau speak only in integer `ArithVar` ids, and `asNode` is what turns them
back into readable terms. Guard it with `hasNode` — auxiliary variables need not
have one.

`DeltaRational::toString()` prints the pair `(c, k)` denoting `c + k·δ`, where
δ is the infinitesimal encoding strict inequalities. `k = 0` means non-strict.

### 4a. Printing a `Constraint`

`Constraint` has **no** `toString()`. Three routes, in order of usefulness:

**1. `getProofLiteral()` — the readable form.** Reconstructs the term from the
variable and value, so it works even when no literal is attached:

```gdb
call constraint->getProofLiteral().toString()      # "(<= (+ x y) 6)"
```

**2. `operator<<` — the internal form.** `Constraint` defines `operator<<` but
not `toString()`, so it must be called by its qualified name and given a stream.
The output goes to the *inferior's* buffered `std::cout`, so **nothing appears
until you flush** — the missing flush makes the call look like it silently did
nothing:

```gdb
call cvc5::internal::theory::arith::linear::operator<<(std::cout, constraint)
call (int) fflush(0)
# 2 <= (6,0)
```

This prints `<ArithVar> <type> <DeltaRational>` — closer to what the tableau
actually holds. Handy on the negation, which shows the δ complement:

```gdb
call cvc5::internal::theory::arith::linear::operator<<(std::cout, constraint->getNegation())
call (int) fflush(0)
# 2 >= (6,1)          i.e. x + y ≥ 6 + δ
```

**3. `print *constraint` — no inferior call at all.** Safe, and the only option
if the process is in a state where calls are unsafe. Verbose, but `d_variable`,
`d_type`, `d_canBePropagated`, `d_assertionOrder` and the embedded
`ValueCollection` in `d_variablePosition` are all readable; only the
`DeltaRational` fields are GMP noise.

### 4b. `call` can kill the inferior

Assertions are live in a debug build, so **calling a method whose precondition
fails aborts the process**, not just the command. `getLiteral()` is the trap —
it asserts `hasLiteral()`, and at `AssertUpper` the constraint has no literal:

```gdb
call constraint->getLiteral().toString()
# Fatal failure within ...::Constraint::getLiteral() const at constraint.h:438
# Check failure    hasLiteral()
# Program received signal SIGABRT, Aborted.
```

How to avoid it:

* Check the guard first — `call constraint->hasLiteral()` returned `false` here.
  Prefer `getProofLiteral()`, whose preconditions (`d_database != nullptr`,
  `hasNode(d_variable)`) hold wherever the variable is set up.
* `set unwindonsignal on` — without it GDB is left stranded in the signal frame
  and the rest of a `-x` script is abandoned.

## 5. Traces are the cheap first pass; GDB is the second

`-t arith` gives the shape of a run with no stepping at all. Locate any line by
grepping the tag string, then set a breakpoint there:

```bash
grep -rn '"AssertUpper("' src/theory/arith/    # -> theory_arith_private.cpp:674, 680
```

Beware: `AssertUpper` prints **twice** per call — lines 674 and 680 contain the
same `Trace` statement straddling an `Assert`. That is a duplicated line in the
source, not two assertions. Do not read it as two events.

The findings this produced on the example are recorded under "Findings from the
Simple Example" in `Arithmetic_Solving.md`.

## Gotchas checklist

* [ ] `set breakpoint pending on` + `set confirm off` before any breakpoint.
* [ ] `start` before `info functions` / `info line`.
* [ ] Break on a **line**, not a function name, whenever locals are needed —
      mandatory for conditional breakpoints.
* [ ] `call x.toString()`, never `print x`, for `Node` / `Rational` / `DeltaRational`.
* [ ] For a `Constraint`, `call c->getProofLiteral().toString()` — there is no
      `toString()`, and `getLiteral()` aborts when no literal is attached.
* [ ] `set unwindonsignal on`, so an assertion failure inside a `call` does not
      strand GDB in the signal frame.
* [ ] Anything printed via `operator<<` needs `call (int) fflush(0)` afterwards,
      or the inferior's buffered output never appears.
* [ ] `<optimized out>` at a function's opening brace means "not live yet",
      not "rebuild without optimization".
* [ ] Loading 294 MB of debug info makes GDB startup slow; allow generous
      timeouts on scripted runs.
