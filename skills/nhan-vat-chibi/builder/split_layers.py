#!/usr/bin/env python3
"""Split semantic top-level SVG groups into aligned SVG layer files."""
import argparse, json, re
from pathlib import Path
import xml.etree.ElementTree as ET

NS = {"svg": "http://www.w3.org/2000/svg"}
ET.register_namespace("", NS["svg"])
PARTS = [
    ("shadow", "root", [512, 1450]),
    ("hair_back", "root", [512, 360]),
    ("body", "root", [512, 700]),
    ("robe_back", "body", [512, 700]),
    ("legs", "body", [512, 1050]),
    ("arms_back", "body", [512, 690]),
    ("head", "root", [512, 300]),
    ("hair_front", "head", [512, 300]),
    ("arms_front", "body", [512, 690]),
    ("robe_front", "body", [512, 700]),
    ("weapon", "root", [760, 760]),
]
def local(tag): return tag.rsplit("}", 1)[-1]
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("svg", type=Path)
    ap.add_argument("--out", type=Path, required=True)
    args=ap.parse_args()
    tree=ET.parse(args.svg); root=tree.getroot()
    if local(root.tag)!="svg": raise SystemExit("Input root is not SVG")
    vb=root.attrib.get("viewBox","0 0 1024 1536")
    defs=[e for e in list(root) if local(e.tag)=="defs"]
    groups={}
    for child in list(root):
        if local(child.tag)=="g" and child.attrib.get("id"):
            groups[child.attrib["id"]]=child
    missing=[name for name,_,_ in PARTS if name not in groups]
    if missing: raise SystemExit("Missing required semantic groups: "+", ".join(missing))
    args.out.mkdir(parents=True,exist_ok=True)
    pivots={}
    for name,parent,pivot in PARTS:
        new=ET.Element(root.tag,dict(root.attrib))
        for d in defs: new.append(ET.fromstring(ET.tostring(d,encoding="unicode")))
        new.append(ET.fromstring(ET.tostring(groups[name],encoding="unicode")))
        ET.ElementTree(new).write(args.out/(name+".svg"),encoding="utf-8",xml_declaration=True)
        pivots[name]={"parent":parent,"pivot":{"x":pivot[0],"y":pivot[1]},"pivot_review_required":True,"texture":name+".svg"}
    manifest={"source":str(args.svg),"viewBox":vb,"canvas":{"width":1024,"height":1536},"parts":pivots,"notes":["Pivot coordinates are starter estimates; adjust them in pivots.json before production.","Layers remain aligned because every exported SVG retains the same viewBox.","This splitter exports semantic groups only; nested SVG references should be visually reviewed."]}
    (args.out/"pivots.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
    print("Exported",len(PARTS),"aligned SVG layers to",args.out)
if __name__=="__main__": main()
