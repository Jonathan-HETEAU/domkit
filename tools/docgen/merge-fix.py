#!/usr/bin/env python3
"""Copy the per-platform XMLs into a dox input dir, dropping types whose
definition differs between platforms (dox cannot merge them; the JS version is kept)."""
import re, sys, os, shutil
src, dst, drops = sys.argv[1], sys.argv[2], sys.argv[3:]
os.makedirs(dst, exist_ok=True)
for f in sorted(os.listdir(src)):
    if not f.endswith(".xml"): continue
    data = open(os.path.join(src, f), encoding="utf-8").read()
    if "_js" not in f:
        for path in drops:
            data, n = re.subn(r'\n?<(typedef|enum|class|abstract) path="%s"[^>]*>.*?</\1>' % re.escape(path), "", data, flags=re.S)
            print(f, path, "removed", n)
    open(os.path.join(dst, f), "w", encoding="utf-8").write(data)
