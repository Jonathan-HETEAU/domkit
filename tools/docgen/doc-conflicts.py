#!/usr/bin/env python3
"""
Lists the doc comments that differ between the per-platform XML files
(docs/api/domkit_*.xml): dox can't merge a type whose doc differs, and lists a
field twice when its doc differs (a missing doc is merged with the other one). Prints `path [field]` with each variant.
Usage: python3 tools/docgen/doc-conflicts.py [docs/api]
"""
import os, sys, xml.etree.ElementTree as ET
d = sys.argv[1] if len(sys.argv) > 1 else "docs/api"
types = {}
for f in sorted(os.listdir(d)):
    if not (f.startswith("domkit_") and f.endswith(".xml")): continue
    plat = f[6:-4]
    for t in ET.parse(os.path.join(d, f)).getroot():
        path = t.get("path")
        if path is None: continue
        doc = (t.findtext("haxe_doc") or "").strip()
        fields = {}
        for c in t:
            if c.tag in ("haxe_doc", "meta", "impl"): continue
            fields[c.tag] = (c.findtext("haxe_doc") or "").strip()
        impl = t.find("impl")
        if impl is not None:
            for cl in impl:
                for c in cl:
                    if c.tag not in ("haxe_doc", "meta"):
                        fields[c.tag] = (c.findtext("haxe_doc") or "").strip()
        types.setdefault(path, {})[plat] = (doc, fields)
n = 0
for path, plats in sorted(types.items()):
    if len(plats) < 2: continue
    docs = {p: v[0] for p, v in plats.items()}
    if len(set(v for v in docs.values() if v)) > 1:
        n += 1
        print(path)
        for p, v in docs.items(): print("   ", p, ":", v[:100].replace("\n", " "))
    names = set()
    for v in plats.values(): names |= set(v[1])
    for name in sorted(names):
        fd = {p: v[1][name] for p, v in plats.items() if name in v[1]}
        if len(fd) > 1 and len(set(v for v in fd.values() if v)) > 1:
            n += 1
            print(path, name)
            for p, v in fd.items(): print("   ", p, ":", v[:100].replace("\n", " "))
print(n, "conflicts")
