# Profiling with perf

Verified on WSL2 (kernel 6.18, `linux-tools` 5.15) with a production
`--tracing` build. No `-g` is needed: function names come from the unstripped
shared library, and inlined functions are charged to their callers.

## 1. Find a working perf binary

```bash
ls /usr/lib/linux-tools/*/perf
```
On WSL, `/usr/bin/perf` is a wrapper that looks for a binary matching the
running kernel. It fails with "You may also want to install
linux-tools-standard-WSL2". Call the versioned binary directly. Its version
changes when the package is upgraded, so use a glob rather than a fixed path:
```bash
P=$(ls /usr/lib/linux-tools/*/perf | tail -1)
```

```bash
cat /proc/sys/kernel/perf_event_paranoid
```
At `2` (the default) you can profile your own processes in user space, which
is all that is needed here.

## 2. Record

```bash
$P record -F 999 --call-graph dwarf,16384 -o perf.data <program> <args>
```
* `-F 999` takes about 1000 samples per second.
* `--call-graph dwarf,16384` records call stacks by unwinding with DWARF info,
  copying 16 KB of stack per sample. The build is compiled without frame
  pointers, so `-g` (frame-pointer unwinding) is likely to give truncated
  stacks; I didn't test it.
* `-o perf.data` sets the output file. A 5 s run produced about 75 MB.

## 3. Inclusive time per function

```bash
$P report -i perf.data --children --sort symbol --stdio --no-header -g none --percent-limit 0.8
```
* The first column (`Children`) is inclusive time: the function plus
  everything it calls. The second (`Self`) is time in the function itself.
* `-g none` hides the call trees, so you get one line per function.
* `--percent-limit 0.8` drops functions below 0.8%.

## 4. Who calls what

`perf report` can't easily answer "what inside function F is expensive", so
dump every sample's stack and aggregate it yourself:
```bash
$P script -i perf.data -F comm,ip,sym --no-inline > perf.txt
```
* `-F comm,ip,sym` prints, for each sample, the process name and then one line
  per stack frame (address and symbol), from the leaf up to `main`.
  `-F comm,sym` without `ip` silently drops the stacks.
* `--no-inline` skips resolving inlined frames, which can be very slow.

Then run `python3 stacks.py perf.txt 'Polynomial::getCoefficient'`. It prints
the function's share of samples, then its immediate callees and its callers:
```python
# stacks.py: usage: python3 stacks.py perf.txt 'Func::name'
import sys, re, collections
def name(s):  # drop namespaces and argument lists
    s = re.sub(r'cvc5::internal::|theory::arith::linear::', '', s)
    while re.search(r'\([^()]*\)', s): s = re.sub(r'\([^()]*\)', '', s)
    return s.replace(' const', '').strip()
stacks, cur = [], None
for line in open(sys.argv[1], errors='replace'):
    if not line.strip(): cur = None
    elif not line[0].isspace(): cur = []; stacks.append(cur)
    elif cur is not None and len(line.split(None, 1)) == 2: cur.append(name(line.split(None, 1)[1]))
N, f = len(stacks), sys.argv[2]
callees, callers, hit = collections.Counter(), collections.Counter(), 0
for st in stacks:  # st[0] is the leaf
    idx = [i for i, g in enumerate(st) if g == f]
    if not idx: continue
    hit += 1
    callees[st[max(idx) - 1] if max(idx) > 0 else '<self>'] += 1
    callers[st[min(idx) + 1] if min(idx) + 1 < len(st) else '<root>'] += 1
print(f'{f}: {100*hit/N:.1f}% of {N} samples')
for title, c in (('callees', callees), ('callers', callers)):
    print(f'  {title}:'); [print(f'    {100*v/N:5.1f}%  {k[:90]}') for k, v in c.most_common(6)]
```
Percentages are of all samples, so they add up across calls. A recursive
function is counted once per sample. Names are matched after namespaces,
argument lists and `const` are stripped, e.g. `DioSolver::applySubstitution`.
