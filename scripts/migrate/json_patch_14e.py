#!/usr/bin/env python3
import json, sys, datetime
up_path = "config/upgradepath.unified.json"
ud_path = "config/updatepath.unified.json"
v_from = "0.5.16-007_reviewfix14d"
v_to   = "0.5.16-007_reviewfix14e"
def load(p):
    with open(p, "r", encoding="utf-8") as f: return json.load(f)
def dump(p, data):
    data["generated"] = datetime.datetime.utcnow().isoformat()+"Z"
    with open(p, "w", encoding="utf-8") as f: json.dump(data, f, indent=2)
up = load(up_path)
if "versions" not in up: up["versions"] = []
if not any(v.get("version")==v_to for v in up["versions"]):
    up["versions"].append({"version": v_to, "parent": v_from, "archive": f"openwrt-ha-vrrp-{v_to}.tar.gz"})
dump(up_path, up)
ud = load(ud_path)
if "updates" not in ud: ud["updates"] = []
if not any(e.get("from")==v_from and e.get("to")==v_to for e in ud["updates"]):
    ud["updates"].append({"from": v_from, "to": v_to, "type": "inplace", "idempotent": True})
dump(ud_path, ud)
print("Patched upgrade/update paths with 14e.")
