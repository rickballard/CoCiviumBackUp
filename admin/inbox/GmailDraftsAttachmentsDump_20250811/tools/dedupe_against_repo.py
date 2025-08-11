
#!/usr/bin/env python3
import argparse, os, csv, hashlib, pathlib
def sha256_file(path):
    h=hashlib.sha256()
    with open(path,"rb") as f:
        for ch in iter(lambda:f.read(1<<20),b""):
            h.update(ch)
    return h.hexdigest()
def scan_repo(root):
    root=pathlib.Path(root); m={}
    for r,ds,fs in os.walk(root):
        if ".git" in ds: ds.remove(".git")
        if "node_modules" in ds: ds.remove("node_modules")
        for fn in fs:
            p=pathlib.Path(r)/fn
            try: d=sha256_file(p)
            except: continue
            m.setdefault(d, []).append(p.as_posix())
    return m
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("inbox_root")
    ap.add_argument("--repo-root", default=".")
    ap.add_argument("--verify-only", action="store_true")
    a=ap.parse_args()
    inbox=pathlib.Path(a.inbox_root)
    manifest=inbox/"manifest"/"Civium_GmailDump_Manifest_20250811.csv"
    out=inbox/"manifest"/"Manifest_with_repo_matches.csv"
    rows=[]
    with open(manifest,newline="",encoding="utf-8") as f:
        rd=csv.DictReader(f)
        for r in rd: rows.append(r)
    # verify
    ok=True
    for r in rows:
        p=inbox / r["original_relpath"]
        try: d=sha256_file(p)
        except Exception as e:
            print(f"[WARN] {p}: {e}"); ok=False; continue
        if d!=r["sha256"]:
            print(f"[MISMATCH] {r['original_relpath']}"); ok=False
    if a.verify_only: raise SystemExit(0 if ok else 2)
    repo_map=scan_repo(a.repo_root)
    for r in rows:
        ms=repo_map.get(r["sha256"],[])
        r["matches_in_repo_count"]=len(ms)
        r["matches_in_repo_paths"]="; ".join(ms)
    with open(out,"w",newline="",encoding="utf-8") as f:
        w=csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader(); w.writerows(rows)
    print(f"[*] Wrote {out}")
if __name__=="__main__": main()
