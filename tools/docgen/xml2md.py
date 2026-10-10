#!/usr/bin/env python3
"""
Converts the Haxe rtti XML dumps (docs/api/domkit_*.xml) into Markdown API reference.

Output:
  docs/api/md/README.md               package index
  docs/api/md/<pkg>/README.md         types of a package with one-line summaries
  docs/api/md/<pkg>/<Type>.md         one page per public type (all platforms merged)
  docs/llms.txt                       compact index for LLMs (llmstxt.org format)

Only the public API is documented: private types/fields, @:noCompletion and @:dox(hide) are skipped.
Usage: python3 tools/docgen/xml2md.py [repo_root]
"""
import os, re, sys, shutil, textwrap
import xml.etree.ElementTree as ET
from collections import defaultdict, OrderedDict

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", ".."))
API = os.path.join(ROOT, "docs", "api")
OUT = os.path.join(API, "md")
PLATFORMS = ["domkit_js", "domkit_hl"]
PLATFORM_NAMES = {"domkit_js": "js", "domkit_hl": "hl"}
INCLUDE = re.compile(r"^domkit(\.|$)")
NON_TYPE = {"haxe_doc", "meta", "overloads", "extends", "implements", "this", "from", "to", "impl"}
KIND = {"class": "class", "enum": "enum", "typedef": "typedef", "abstract": "abstract"}

# ------------------------------------------------------------------ load & merge platforms
types = OrderedDict()  # path -> {platform: element}
for p in PLATFORMS:
    f = os.path.join(API, p + ".xml")
    if not os.path.exists(f):
        continue
    for e in ET.parse(f).getroot():
        path = e.get("path")
        if not INCLUDE.match(path) or e.get("private") == "1" or "_Impl_" in path:
            continue
        types.setdefault(path, OrderedDict())[p] = e
used_platforms = [p for p in PLATFORMS if any(p in v for v in types.values())]


def meta_names(e):
    m = e.find("meta")
    return set() if m is None else {x.get("n") for x in m.findall("m")}


def hidden(e):
    ms = meta_names(e)
    if ":noCompletion" in ms or ":dox" in ms and "hide" in ET.tostring(e.find("meta"), encoding="unicode"):
        return True
    return False


types = OrderedDict((k, v) for k, v in types.items() if not hidden(next(iter(v.values()))))
type_set = set(types)


def main_elem(path):
    return next(iter(types[path].values()))


# ------------------------------------------------------------------ helpers
def md_path(path):
    return path.replace(".", "/") + ".md"


def rel_link(from_path, to_path):
    return os.path.relpath(md_path(to_path), os.path.dirname(md_path(from_path)) or ".")


def pkg_of(path):
    return path.rsplit(".", 1)[0] if "." in path else ""


def short(path, ctx):
    """Short name inside signatures: same package or std -> last segment, else full path."""
    if path not in type_set or pkg_of(path) == pkg_of(ctx):
        return path.rsplit(".", 1)[-1] if path.startswith(("haxe.", "StdTypes")) or "." not in path or pkg_of(path) == pkg_of(ctx) else path
    return path


def tstr(t, ctx):
    """Render a type element as Haxe syntax."""
    if t is None:
        return "Dynamic"
    tag = t.tag
    if tag in ("c", "e", "t", "x"):
        name = short(t.get("path"), ctx)
        params = [tstr(c, ctx) for c in t if c.tag not in NON_TYPE]
        return name + ("<" + ", ".join(params) + ">" if params else "")
    if tag == "f":
        kids = [c for c in t if c.tag not in NON_TYPE]
        names = t.get("a", "").split(":") if t.get("a") else []
        args = [tstr(c, ctx) for c in kids[:-1]]
        ret = tstr(kids[-1], ctx) if kids else "Void"
        if not args:
            return "() -> " + ret
        parts = [(n.lstrip("?") + ":" if n.lstrip("?") else "") + a for n, a in zip(names, args)]
        return "(" + ", ".join(parts) + ") -> " + ret
    if tag == "a":
        fs = []
        for c in t:
            if c.tag in NON_TYPE:
                continue
            opt = "?" if ":optional" in meta_names(c) else ""
            fs.append(f"{opt}{c.tag}:{tstr(first_type(c), ctx)}")
        return "{ " + ", ".join(fs) + " }"
    if tag == "d":
        kids = [c for c in t if c.tag not in NON_TYPE]
        return "Dynamic" + ("<" + tstr(kids[0], ctx) + ">" if kids else "")
    return "Dynamic"


def first_type(e):
    for c in e:
        if c.tag not in NON_TYPE:
            return c
    return None


def doc_of(e):
    d = e.find("haxe_doc")
    if d is None or not (d.text or "").strip():
        return ""
    lines = d.text.replace("\r", "").split("\n")
    first, rest = lines[0].strip(), textwrap.dedent("\n".join(lines[1:]).expandtabs(4))
    text = (first + "\n" + rest).strip()
    # javadoc tags -> markdown
    out = []
    for line in text.split("\n"):
        m = re.match(r"\s*@(param|return|returns|throws|see|deprecated)\s*(.*)", line)
        if m:
            tag, rest = m.groups()
            if tag == "param":
                n, _, desc = rest.partition(" ")
                out.append(f"- **param** `{n}` {desc}".rstrip())
            elif tag in ("return", "returns"):
                out.append(f"- **returns** {rest}")
            else:
                out.append(f"- **{tag}** {rest}")
        else:
            out.append(line)
    return "\n".join(out).strip()


def summary(e):
    d = doc_of(e)
    if not d:
        return ""
    s = re.split(r"(?<=[.!?])\s|\n\n", d.strip(), maxsplit=1)[0].replace("\n", " ").strip()
    return s if len(s) < 220 else s[:217] + "..."


def platforms_note(ps, all_ps):
    if set(ps) == set(all_ps):
        return ""
    return " _(" + ", ".join(PLATFORM_NAMES[p] for p in PLATFORMS if p in ps) + " only)_"


def fn_sig(name, f, ctx, drop_first=False, prefix="function "):
    kids = [c for c in f if c.tag not in NON_TYPE]
    names = f.get("a", "").split(":") if f.get("a") else []
    vals = f.get("v", "").split(":") if f.get("v") else []
    args = []
    for i, c in enumerate(kids[:-1]):
        n = names[i] if i < len(names) else f"a{i}"
        if drop_first and i == 0:
            continue
        a = f"{n}:{tstr(c, ctx)}"
        if i < len(vals) and vals[i] not in ("", "null"):
            a += " = " + vals[i]
        args.append(a)
    ret = tstr(kids[-1], ctx) if kids else "Void"
    return f"{prefix}{name}({', '.join(args)}):{ret}"


def var_sig(fe, ctx, is_static):
    get, set_ = fe.get("get"), fe.get("set")
    t = tstr(first_type(fe), ctx)
    st = "static " if is_static else ""
    if get == "inline":
        val = fe.get("expr")
        return f"{st}inline var {fe.tag}:{t}" + (f" = {val}" if val else "")
    if fe.get("final") == "1":
        return f"{st}final {fe.tag}:{t}"
    acc_g = {"accessor": "get", "null": "null", "dynamic": "dynamic", "never": "never"}.get(get, "default")
    acc_s = {"accessor": "set", "null": "null", "dynamic": "dynamic", "never": "never", "method": "default"}.get(set_, "default")
    access = "" if (acc_g, acc_s) == ("default", "default") else f"({acc_g}, {acc_s})"
    return f"{st}var {fe.tag}{access}:{t}"


def is_abstract_instance(fe):
    """Abstract instance members are static functions of the impl class taking `this` first."""
    t = first_type(fe)
    if ":impl" in meta_names(fe):
        return True
    return t is not None and t.tag == "f" and (t.get("a") or "").split(":")[0] == "this"


def is_method(fe):
    t = first_type(fe)
    if t is None or t.tag != "f":
        return False
    # regular/dynamic methods, or inline functions (get="inline" set="null" without an initial value)
    return fe.get("set") in ("method", "dynamic") or (fe.get("get") == "inline" and "expr" not in fe.attrib)


# ------------------------------------------------------------------ class-like members
def collect_fields(elems_by_platform, ctx, abstract_impl=False):
    """Union of public fields across platforms -> list of (fieldElem, platforms, static)."""
    out = OrderedDict()
    for p, e in elems_by_platform.items():
        for fe in e:
            if fe.tag in NON_TYPE or fe.get("public") != "1" or hidden(fe):
                continue
            static = fe.get("static") == "1"
            key = (fe.tag, static)
            if key in out:
                out[key][1].append(p)
            else:
                out[key] = [fe, [p], static]
    return list(out.values())


def render_member(L, fe, plats, all_plats, ctx, abstract_impl=False):
    static = fe.get("static") == "1"
    is_impl = abstract_impl and is_abstract_instance(fe)
    name = "new" if fe.tag == "_new" else fe.tag
    if is_method(fe):
        prefix = ("static " if static and not is_impl else "") + ("override " if fe.get("override") == "1" else "") \
            + ("inline " if fe.get("get") == "inline" else "") + ("dynamic " if fe.get("set") == "dynamic" else "") + "function "
        sig = fn_sig(name, first_type(fe), ctx, drop_first=is_impl and name != "new", prefix=prefix)
        ov = fe.find("overloads")
        sigs = [sig] + ([fn_sig(name, first_type(o), ctx, prefix=prefix) for o in ov if first_type(o) is not None] if ov is not None else [])
    else:
        sigs = [var_sig(fe, ctx, static and not is_impl)]
    L.append(f"### {name}{platforms_note(plats, all_plats)}\n")
    L.append("```haxe\n" + "\n".join(sigs) + "\n```\n")
    d = doc_of(fe)
    if d:
        L.append(d + "\n")


def split_members(fields):
    groups = OrderedDict([("Constructor", []), ("Static variables", []), ("Static methods", []), ("Variables", []), ("Methods", [])])
    for fe, plats, static in fields:
        if fe.tag in ("new", "_new"):
            groups["Constructor"].append((fe, plats))
        elif static and not is_abstract_instance(fe):
            groups["Static methods" if is_method(fe) else "Static variables"].append((fe, plats))
        else:
            groups["Methods" if is_method(fe) else "Variables"].append((fe, plats))
    return groups


# ------------------------------------------------------------------ inheritance indexes
def super_of(path):
    e = main_elem(path)
    x = e.find("extends")
    return x.get("path") if x is not None else None


subclasses, implementors = defaultdict(list), defaultdict(list)
for path, ebp in types.items():
    e = next(iter(ebp.values()))
    if e.tag != "class":
        continue
    s = super_of(path)
    if s:
        subclasses[s].append(path)
    for i in e.findall("implements"):
        implementors[i.get("path")].append(path)


def link(path, ctx, label=None):
    label = label or path
    return f"[`{label}`]({rel_link(ctx, path)})" if path in type_set else f"`{label}`"


# ------------------------------------------------------------------ render one type
def render(path):
    ebp = types[path]
    e = next(iter(ebp.values()))
    kind = e.tag
    all_plats = list(ebp)
    L = []
    w = L.append
    if kind == "class" and e.get("interface") == "1":
        kind_label = "interface"
    elif kind == "abstract" and ":enum" in meta_names(e):
        kind_label = "enum abstract"
    else:
        kind_label = kind
    w(f"# {path}\n")
    info = [f"**{kind_label}**", f"package [`{pkg_of(path)}`]({os.path.relpath(pkg_of(path).replace('.', '/') + '/README.md', os.path.dirname(md_path(path)))})"]
    if e.get("module") and e.get("module") != path:
        info.append(f"module `{e.get('module')}`")
    src = os.path.relpath(e.get("file", ""), ROOT) if e.get("file") else None
    if src and not src.startswith(".."):
        info.append(f"source [`{src}`]({os.path.relpath(os.path.join(ROOT, src), os.path.join(OUT, os.path.dirname(md_path(path))))})")
    if len(all_plats) < len(used_platforms):
        info.append("available on " + ", ".join(PLATFORM_NAMES[p] for p in all_plats))
    w(" · ".join(info) + "\n")
    if e.get("params"):
        w(f"Type parameters: `<{e.get('params').replace(':', ', ')}>`\n")

    # heritage
    if kind == "class":
        chain, s = [], super_of(path)
        while s:
            chain.append(s)
            s = super_of(s) if s in type_set else None
        if chain:
            w("Extends: " + " → ".join(link(c, path) for c in chain) + "\n")
        impls = [i.get("path") for i in e.findall("implements")]
        if impls:
            w("Implements: " + ", ".join(link(i, path) for i in impls) + "\n")
        if subclasses.get(path):
            w("Subclasses: " + ", ".join(link(c, path) for c in sorted(subclasses[path])) + "\n")
        if implementors.get(path):
            w("Implemented by: " + ", ".join(link(c, path) for c in sorted(implementors[path])) + "\n")
    d = doc_of(e)
    if d:
        w(d + "\n")

    if kind == "class":
        fields = collect_fields(ebp, path)
        for title, items in split_members(fields).items():
            if items:
                w(f"## {title}\n")
                for fe, plats in items:
                    render_member(L, fe, plats, all_plats, path)
        # inherited members (names only)
        s = super_of(path)
        inh = []
        while s and s in type_set:
            names = [fe.tag for fe in main_elem(s) if fe.tag not in NON_TYPE and fe.get("public") == "1"
                     and fe.get("static") != "1" and fe.tag != "new" and not hidden(fe)]
            if names:
                inh.append(f"- from {link(s, path)}: " + ", ".join(f"`{n}`" for n in names))
            s = super_of(s)
        if inh:
            w("## Inherited members\n")
            w("\n".join(inh) + "\n")

    elif kind == "enum":
        w("## Constructors\n")
        ctors = OrderedDict()
        for p, el in ebp.items():
            for c in el:
                if c.tag in NON_TYPE:
                    continue
                ctors.setdefault(c.tag, [c, []])[1].append(p)
        for name, (c, plats) in ctors.items():
            args = ""
            if c.get("a") is not None:
                names = c.get("a").split(":")
                ts = [x for x in c if x.tag not in NON_TYPE]
                args = "(" + ", ".join(f"{n}:{tstr(t, path)}" for n, t in zip(names, ts)) + ")"
            w(f"### {name}{platforms_note(plats, all_plats)}\n")
            w(f"```haxe\n{name}{args}\n```\n")
            dd = doc_of(c)
            if dd:
                w(dd + "\n")

    elif kind == "typedef":
        variants = OrderedDict()
        for p, el in ebp.items():
            t = first_type(el)
            k = ET.tostring(t, encoding="unicode") if t is not None else ""
            variants.setdefault(re.sub(r"\s+", "", k), [t, []])[1].append(p)
        for t, plats in variants.values():
            if len(variants) > 1:
                w(f"## On {', '.join(PLATFORM_NAMES[p] for p in plats)}\n")
            if t is not None and t.tag == "a":
                w("## Fields\n" if len(variants) == 1 else "")
                for fe in t:
                    if fe.tag in NON_TYPE:
                        continue
                    opt = "?" if ":optional" in meta_names(fe) else ""
                    w(f"### {fe.tag}\n")
                    w(f"```haxe\nvar {opt}{fe.tag}:{tstr(first_type(fe), path)}\n```\n")
                    dd = doc_of(fe)
                    if dd:
                        w(dd + "\n")
            else:
                w(f"Alias for: `{tstr(t, path)}`\n")

    elif kind == "abstract":
        th = e.find("this")
        if th is not None:
            under = first_type(th)
            under_path = under.get("path") if under is not None else None
            w("Underlying type: " + (link(under_path, path) if under_path in type_set else f"`{tstr(under, path)}`") + "\n")
            if ":forward" in meta_names(e) and under_path in type_set:
                w(f"Members of {link(under_path, path)} are forwarded (`@:forward`): they are usable directly on this type.\n")
        for tag, label in (("from", "Implicit casts from"), ("to", "Implicit casts to")):
            x = e.find(tag)
            if x is not None and len(x):
                w(f"{label}: " + ", ".join(f"`{tstr(first_type(i), path)}`" for i in x) + "\n")
        impls = OrderedDict((p, el.find("impl/class")) for p, el in ebp.items() if el.find("impl/class") is not None)
        if impls:
            fields = collect_fields(impls, path, abstract_impl=True)
            if kind_label == "enum abstract":
                values = [(fe, pl) for fe, pl, st in fields if ":enum" in meta_names(fe) and ":value" in meta_names(fe)]
                if values:
                    w("## Values\n")
                    w("| Name | Value | Description |\n|---|---|---|")
                    for fe, pl in values:
                        w(f"| `{fe.tag}`{platforms_note(pl, all_plats)} | `{fe.get('expr', '').replace('cast ', '')}` | {summary(fe).replace('|', '\\|')} |")
                    w("")
                fields = [f for f in fields if not (":enum" in meta_names(f[0]) and ":value" in meta_names(f[0]))]
            for title, items in split_members(fields).items():
                if items:
                    w(f"## {title}\n")
                    for fe, plats in items:
                        render_member(L, fe, plats, all_plats, path, abstract_impl=True)
    return "\n".join(L).rstrip() + "\n"


# ------------------------------------------------------------------ write
if os.path.isdir(OUT):
    shutil.rmtree(OUT)
by_pkg = defaultdict(list)
for path in types:
    by_pkg[pkg_of(path)].append(path)
    f = os.path.join(OUT, md_path(path))
    os.makedirs(os.path.dirname(f), exist_ok=True)
    open(f, "w", encoding="utf-8").write(render(path))


def kind_label(path):
    e = main_elem(path)
    if e.tag == "class" and e.get("interface") == "1":
        return "interface"
    if e.tag == "abstract" and ":enum" in meta_names(e):
        return "enum abstract"
    return e.tag


for pkg, paths in by_pkg.items():
    L = [f"# Package `{pkg}`\n", f"[← API index]({os.path.relpath('README.md', pkg.replace('.', '/'))})\n"]
    subs = sorted(p for p in by_pkg if pkg_of(p) == pkg and p != pkg) if "." in pkg or True else []
    subs = sorted(p for p in by_pkg if p.startswith(pkg + ".") and p.count(".") == pkg.count(".") + 1)
    if subs:
        L.append("Sub-packages: " + ", ".join(f"[`{s}`]({s.rsplit('.', 1)[-1]}/README.md)" for s in subs) + "\n")
    L.append("| Type | Kind | Summary |\n|---|---|---|")
    for p in sorted(paths):
        L.append(f"| [`{p.rsplit('.', 1)[-1]}`]({p.rsplit('.', 1)[-1]}.md) | {kind_label(p)} | {summary(main_elem(p)).replace('|', '\\|')} |")
    open(os.path.join(OUT, pkg.replace(".", "/"), "README.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")

L = ["# DomKit API reference\n",
     "> Generated from the Haxe compiler XML (`docs/api/domkit_*.xml`) by `tools/docgen/xml2md.py`. Do not edit by hand.\n",
     f"{len(types)} public types in {len(by_pkg)} packages, merged across platforms: " + ", ".join(PLATFORM_NAMES[p] for p in used_platforms) + ".\n",
     "| Package | Types | Documented types |\n|---|---:|---:|"]
for pkg in sorted(by_pkg):
    n = len(by_pkg[pkg])
    documented = sum(1 for p in by_pkg[pkg] if doc_of(main_elem(p)))
    L.append(f"| [`{pkg}`]({pkg.replace('.', '/')}/README.md) | {n} | {documented} |")
open(os.path.join(OUT, "README.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")

# llms.txt (https://llmstxt.org): H1, blockquote, then sections of links
L = ["# DomKit", "",
     "> DomKit is a strictly typed UI framework for Haxe based on components and CSS: components are declared with an XML-like markup (`static var SRC = <comp>...</comp>`) compiled by macros, "
     "and styled with CSS properties checked at compile time. It is used by Heaps (`h2d.domkit`): see https://heaps.io/documentation/domkit.html.",
     "",
     "Each link points to a Markdown page with the full public API of a type: signatures, documentation, inheritance and platform availability. "
     "File dependency map: [deps/DEPENDENCIES.md](deps/DEPENDENCIES.md).", ""]
for top in ["domkit"]:
    L.append(f"## {top}\n")
    for pkg in sorted(p for p in by_pkg if p == top or p.startswith(top + ".")):
        for p in sorted(by_pkg[pkg]):
            s = summary(main_elem(p))
            L.append(f"- [{p}](api/md/{md_path(p)})" + (f": {s}" if s else ""))
    L.append("")
open(os.path.join(ROOT, "docs", "llms.txt"), "w", encoding="utf-8").write("\n".join(L))

nodoc = sum(1 for p in types if not doc_of(main_elem(p)))
print(f"types={len(types)} packages={len(by_pkg)} undocumented_types={nodoc} platforms={used_platforms}")
