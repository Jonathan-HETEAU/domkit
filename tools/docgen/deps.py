#!/usr/bin/env python3
"""
Static dependency analyzer for the DomKit sources (no Haxe compiler needed).

Produces:
  docs/deps/DEPENDENCIES.md   human/AI readable overview (packages, cycles, doc order)
  docs/deps/modules/<pkg>.md  one page per package: every module, its types, deps, reverse deps
  docs/deps/deps.json         machine readable graph (for further tooling / AI agents)

Resolution is heuristic (regex based, comments and strings stripped):
  - explicit imports / usings (incl. `in` / `as` aliases and wildcards)
  - fully qualified paths  (h3d.mat.Texture, hxd.res.Image.ImageFormat)
  - unqualified names resolved against the current module, its package and parent packages
  - extends / implements are recorded separately
Usage: python3 tools/docgen/deps.py [repo_root]
"""
import json, os, re, sys
from collections import defaultdict

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", ".."))
SRC_DIRS = ["domkit"]
OUT = os.path.join(ROOT, "docs", "deps")

RE_COMMENT = re.compile(r'/\*.*?\*/|//[^\n]*', re.S)
RE_STRING = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', re.S)
RE_PACKAGE = re.compile(r'^\s*package\s+([\w.]*)\s*;', re.M)
RE_IMPORT = re.compile(r'^\s*(import|using)\s+([\w.]+(?:\.\*)?)(?:\s+(?:in|as)\s+(\w+))?\s*;', re.M)
RE_TYPE = re.compile(r'^\s*(?:@:[^\n]*?\s)?(?:(?:private|extern|final|abstract|@:\w+(?:\([^)]*\))?)\s+)*'
                     r'(class|interface|enum\s+abstract|enum|abstract|typedef)\s+([A-Z]\w*)', re.M)
RE_EXTENDS = re.compile(r'\b(class|interface)\s+([A-Z]\w*)(?:<[^{]*?>)?\s+((?:(?:extends|implements)\s+[\w.]+(?:<[^{]*?>)?\s*,?\s*)+)')
RE_HERIT = re.compile(r'(extends|implements)\s+([\w.]+)')
RE_PATH = re.compile(r'\b((?:[a-z_]\w*\.)*[A-Z]\w*(?:\.[A-Z]\w*)?)')
RE_DOC = re.compile(r'/\*\*.*?\*\*/|/\*\*.*?\*/', re.S)


def strip(code):
    code = RE_COMMENT.sub(lambda m: "\n" * m.group(0).count("\n"), code)
    return RE_STRING.sub('""', code)


# ---------------------------------------------------------------- parse
modules = {}  # "h3d.mat.Texture" -> info
for d in SRC_DIRS:
    for dp, _, fs in os.walk(os.path.join(ROOT, d)):
        for f in sorted(fs):
            if not f.endswith(".hx"):
                continue
            path = os.path.join(dp, f)
            raw = open(path, encoding="utf-8", errors="replace").read()
            code = strip(raw)
            m = RE_PACKAGE.search(code)
            pkg = m.group(1) if m else ""
            name = f[:-3]
            mod = (pkg + "." if pkg else "") + name
            types = [(k.replace("enum ", "enum_"), n) for k, n in RE_TYPE.findall(code)]
            heritage = []
            for _, tname, rest in RE_EXTENDS.findall(code):
                for kind, target in RE_HERIT.findall(rest):
                    heritage.append((tname, kind, target))
            modules[mod] = dict(
                module=mod, package=pkg, file=os.path.relpath(path, ROOT), code=code,
                lines=raw.count("\n") + 1, types=types, heritage=heritage,
                imports=[(k, p, a) for k, p, a in RE_IMPORT.findall(code)],
                doc_blocks=len(RE_DOC.findall(raw)),
                has_cond="#if" in raw,
            )

# index: fully qualified type path -> module
type_index = {}
for mod, info in modules.items():
    type_index[mod] = mod
    for _, t in info["types"]:
        type_index[(info["package"] + "." if info["package"] else "") + t] = mod if t == mod.split(".")[-1] else mod
        type_index[mod + "." + t] = mod
packages = sorted({i["package"] for i in modules.values()})
pkg_modules = defaultdict(list)
for mod, info in modules.items():
    pkg_modules[info["package"]].append(mod)


def resolve_qualified(path):
    """Longest prefix of a dotted path that is a known type."""
    parts = path.split(".")
    for i in range(len(parts), 0, -1):
        p = ".".join(parts[:i])
        if p in type_index:
            return type_index[p]
    return None


# ---------------------------------------------------------------- resolve
edges = defaultdict(lambda: defaultdict(set))  # src -> dst -> {kinds}
for mod, info in modules.items():
    local = {}  # unqualified name -> module
    pkg = info["package"]
    # parent packages first (lowest priority), then own package, own subtypes, imports
    chain = pkg.split(".") if pkg else []
    for i in range(0, len(chain) + 1):
        p = ".".join(chain[:i])
        for m in pkg_modules.get(p, []):
            local[m.split(".")[-1]] = m
    for _, t in info["types"]:
        local[t] = mod
    for kind, p, alias in info["imports"]:
        if p.endswith(".*"):
            base = p[:-2]
            for m in pkg_modules.get(base, []):
                local[m.split(".")[-1]] = m
                edges[mod][m]  # wildcard import does not imply real use
            tgt = type_index.get(base)  # import Module.* (statics / subtypes)
            if tgt:
                edges[mod][tgt].add(kind)
                for k2, t in modules[tgt]["types"]:
                    local[t] = tgt
            continue
        tgt = resolve_qualified(p)
        if tgt:
            edges[mod][tgt].add(kind)
            local[alias or p.split(".")[-1]] = tgt
            if tgt == p and modules.get(tgt):  # importing a module brings its subtypes
                for _, t in modules[tgt]["types"]:
                    local.setdefault(t, tgt)
    body = RE_IMPORT.sub("", info["code"])
    for path in set(RE_PATH.findall(body)):
        if "." in path and path[0].islower():
            tgt = resolve_qualified(path)
        else:
            tgt = local.get(path.split(".")[0])
        if tgt:
            edges[mod][tgt].add("use")
    for tname, kind, target in info["heritage"]:
        tgt = resolve_qualified(target) if "." in target else local.get(target)
        if tgt:
            edges[mod][tgt].add(kind)
# cleanup: drop self edges and wildcard-only placeholders
for src in list(edges):
    edges[src].pop(src, None)
    for dst in [d for d, k in edges[src].items() if not k]:
        del edges[src][dst]
rev = defaultdict(set)
for s, ds in edges.items():
    for d in ds:
        rev[d].add(s)


def top_pkg(p):  # h3d.scene.pbr -> h3d.scene ; keep 2 levels for overview
    return ".".join(p.split(".")[:2])


# ---------------------------------------------------------------- analysis
def tarjan(nodes, succ):
    idx, low, st, on, out, n = {}, {}, [], set(), [], [0]
    sys.setrecursionlimit(10000)

    def v(x):
        idx[x] = low[x] = n[0]; n[0] += 1; st.append(x); on.add(x)
        for y in succ(x):
            if y not in idx:
                v(y); low[x] = min(low[x], low[y])
            elif y in on:
                low[x] = min(low[x], idx[y])
        if low[x] == idx[x]:
            c = []
            while True:
                y = st.pop(); on.discard(y); c.append(y)
                if y == x: break
            out.append(sorted(c))
    for x in nodes:
        if x not in idx:
            v(x)
    return out  # reverse topological order (dependencies first)


mod_sccs = tarjan(sorted(modules), lambda x: sorted(edges[x]))
pkg_edges = defaultdict(lambda: defaultdict(int))
for s, ds in edges.items():
    for d in ds:
        a, b = top_pkg(modules[s]["package"]), top_pkg(modules[d]["package"])
        if a != b:
            pkg_edges[a][b] += 1
groups = sorted({top_pkg(p) for p in packages})
pkg_sccs = tarjan(groups, lambda x: sorted(pkg_edges[x]))

# ---------------------------------------------------------------- output
os.makedirs(os.path.join(OUT, "modules"), exist_ok=True)


def link(m):
    return f"[`{m}`](modules/{modules[m]['package'] or '_root'}.md#{m.replace('.', '').lower()})"


L = []
w = L.append
total_lines = sum(i["lines"] for i in modules.values())
w("# DomKit — carte des dépendances\n")
w("> Généré par `tools/docgen/deps.py` (analyse statique, sans compilateur Haxe). Ne pas éditer à la main.\n")
w(f"- Modules (fichiers `.hx`) : **{len(modules)}** — lignes : **{total_lines}** — packages : **{len(packages)}**")
w(f"- Dépendances module→module : **{sum(len(d) for d in edges.values())}**")
w(f"- Cycles de modules (SCC > 1) : **{sum(1 for c in mod_sccs if len(c) > 1)}**\n")
w("Légende des types d'arêtes : `import`, `using`, `extends`, `implements`, `use` (référence dans le code).\n")

w("## Packages\n")
w("| Package | Modules | Lignes | Blocs doc `/** */` | Dépend de (packages) | Utilisé par |")
w("|---|---:|---:|---:|---|---|")
for p in packages:
    ms = pkg_modules[p]
    out_p = sorted({modules[d]["package"] for m in ms for d in edges[m]} - {p})
    in_p = sorted({modules[s]["package"] for m in ms for s in rev[m]} - {p})
    w(f"| [`{p or '(racine)'}`](modules/{p or '_root'}.md) | {len(ms)} | {sum(modules[m]['lines'] for m in ms)} | "
      f"{sum(modules[m]['doc_blocks'] for m in ms)} | {', '.join(out_p) or '—'} | {len(in_p)} |")

w("\n## Graphe des packages (niveau 2)\n")
w("```mermaid\nflowchart LR")
for a in groups:
    for b, n in sorted(pkg_edges[a].items()):
        w(f"  {a.replace('.', '_')}[{a}] -->|{n}| {b.replace('.', '_')}[{b}]")
w("```\n")

w("## Cycles entre packages\n")
cyc = [c for c in pkg_sccs if len(c) > 1]
w("\n".join(f"- {' ⇄ '.join(c)}" for c in cyc) if cyc else "Aucun.")

w("\n## Ordre de documentation suggéré\n")
w("Ordre topologique (les dépendances d'abord). Les modules entre crochets forment un cycle et doivent être documentés ensemble.\n")
for i, c in enumerate(mod_sccs, 1):
    w(f"{i}. " + (link(c[0]) if len(c) == 1 else "[" + ", ".join(link(m) for m in c) + "]"))

w("\n## Modules les plus centraux (les plus utilisés)\n")
w("| Module | Utilisé par | Dépend de | Lignes |\n|---|---:|---:|---:|")
for m in sorted(modules, key=lambda m: -len(rev[m]))[:40]:
    w(f"| {link(m)} | {len(rev[m])} | {len(edges[m])} | {modules[m]['lines']} |")
open(os.path.join(OUT, "DEPENDENCIES.md"), "w").write("\n".join(L) + "\n")

for p in packages:
    L = []
    w = L.append
    w(f"# Package `{p or '(racine)'}`\n\n[← retour](../DEPENDENCIES.md)\n")
    for m in sorted(pkg_modules[p]):
        i = modules[m]
        w(f"## {m}\n")
        w(f"- Fichier : `{i['file']}` — {i['lines']} lignes — {i['doc_blocks']} blocs doc" + (" — contient du `#if`" if i["has_cond"] else ""))
        if i["types"]:
            w("- Types : " + ", ".join(f"`{k} {t}`" for k, t in i["types"]))
        if i["heritage"]:
            w("- Héritage : " + ", ".join(f"`{t}` {k} `{x}`" for t, k, x in i["heritage"]))
        deps = sorted(edges[m])
        if deps:
            w("- Dépend de : " + ", ".join(f"`{d}`" + ("" if edges[m][d] == {"use"} else f" ({'/'.join(sorted(edges[m][d]))})") for d in deps))
        if rev[m]:
            w("- Utilisé par : " + ", ".join(f"`{s}`" for s in sorted(rev[m])))
        w("")
    open(os.path.join(OUT, "modules", (p or "_root") + ".md"), "w").write("\n".join(L))

json.dump({
    "modules": {m: dict(file=i["file"], package=i["package"], lines=i["lines"], doc_blocks=i["doc_blocks"],
                        types=[f"{k} {t}" for k, t in i["types"]],
                        heritage=[list(h) for h in i["heritage"]],
                        deps={d: sorted(k) for d, k in sorted(edges[m].items())},
                        used_by=sorted(rev[m])) for m, i in sorted(modules.items())},
    "doc_order": mod_sccs,
    "package_edges": {a: dict(sorted(b.items())) for a, b in sorted(pkg_edges.items())},
}, open(os.path.join(OUT, "deps.json"), "w"), indent=1, ensure_ascii=False)

print(f"modules={len(modules)} edges={sum(len(d) for d in edges.values())} "
      f"cycles={sum(1 for c in mod_sccs if len(c) > 1)} biggest_cycle={max(len(c) for c in mod_sccs)} "
      f"isolated={sum(1 for m in modules if not edges[m] and not rev[m])} pkg_cycles={len(cyc)}")
