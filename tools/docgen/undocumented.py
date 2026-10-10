#!/usr/bin/env python3
"""
Lists public declarations without a /** */ doc comment.
Usage: python3 tools/docgen/undocumented.py <file.hx | dir> [...]
Prints `file:line  declaration` for each undocumented type or public member,
then a per-file summary (documented / total).
"""
import os, re, sys

DECL = re.compile(r'^\s*(?:@:[\w.]+(?:\([^)]*\))?\s+)*'
                  r'((?:(?:public|private|static|override|inline|dynamic|final|extern|abstract|macro|enum)\s+)*)'
                  r'(class|interface|enum\s+abstract|enum|abstract|typedef|var|final|function)\s+(\w+)')


private_ctx = [False]


def scan(path):
    lines = open(path, encoding="utf-8", errors="replace").read().split("\n")
    out, total, depth, in_doc, last_doc_end, in_comment = [], 0, 0, False, -10, False
    type_depth = None
    for i, line in enumerate(lines):
        s = line.strip()
        if in_comment:
            if "*/" in s:
                if in_comment != "plain":
                    last_doc_end = i
                in_comment = False
            continue
        if s.startswith("/*") and not s.startswith("/**"):
            # plain comment block (possibly commented-out code): skip it entirely
            if "*/" not in s[2:]:
                in_comment = "plain"
            continue
        if s.startswith("/**"):
            if "*/" not in s[3:]:
                in_comment = True
            else:
                last_doc_end = i
            continue
        if s.startswith("//") or s.startswith("@:") and not DECL.match(line) or s.startswith("#"):
            if s.startswith("@:") or s.startswith("#"):
                pass  # metadata / conditionals between doc and decl are fine
            continue
        m = DECL.match(line)
        if m:
            mods, kind, name = m.groups()
            is_type = kind not in ("var", "final", "function")
            # members only at class body level (depth 1), types at depth 0
            relevant = (is_type and depth == 0 and "private" not in mods) or \
                       (not is_type and depth == 1 and ("public" in mods or interface_ctx))
            k = i - 1
            prev_meta = ""
            while k >= 0 and lines[k].strip().startswith(("@:", "#")) and not DECL.match(lines[k]):
                prev_meta += lines[k]
                k -= 1
            if "override" in mods or any(x in line + prev_meta for x in ("@:noCompletion", "@:dox(hide)")):
                relevant = False
            if relevant and not name.startswith("get_") and not name.startswith("set_"):
                total += 1
                # doc must end on a previous line, only metadata/blank/conditionals in between
                j = i - 1
                while j >= 0 and (not lines[j].strip() or lines[j].strip().startswith(("@:", "#"))) and not DECL.match(lines[j]):
                    j -= 1
                if j != last_doc_end:
                    out.append((i + 1, s[:110]))
            if is_type and depth == 0:
                interface_ctx_set(kind == "interface" or (kind == "typedef"))
                private_ctx[0] = "private" in mods or any(x in line + prev_meta for x in ("@:noCompletion", "@:dox(hide)"))
            if not is_type and private_ctx[0] and relevant:
                total -= 1
                if out and out[-1][0] == i + 1:
                    out.pop()
        clean = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//.*', "", line)
        depth += clean.count("{") - clean.count("}")
        if depth < 0:
            depth = 0
    return out, total


interface_ctx = False


def interface_ctx_set(v):
    global interface_ctx
    interface_ctx = v


files = []
for a in sys.argv[1:]:
    if os.path.isdir(a):
        for dp, _, fs in os.walk(a):
            files += [os.path.join(dp, f) for f in sorted(fs) if f.endswith(".hx")]
    else:
        files.append(a)
summary = []
for f in files:
    interface_ctx_set(False)
    missing, total = scan(f)
    for ln, s in missing:
        print(f"{f}:{ln}  {s}")
    summary.append((f, total - len(missing), total))
print()
for f, d, t in summary:
    print(f"{d:4}/{t:<4} {f}")
