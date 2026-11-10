#!/usr/bin/env python3
"""Export a segmented 2D character SVG into aligned limb layers and a rig manifest."""
import argparse, json
from pathlib import Path
import xml.etree.ElementTree as ET

NS_URI = "http://www.w3.org/2000/svg"
ET.register_namespace("", NS_URI)
# Pivots are canvas-space starter estimates for a 1024x1536 character.
# Each SVG group must be a top-level <g id="..."> and contain artwork for that segment.
PARTS = [
    ("shadow","root",(512,1460),0),
    ("hair_back","root",(512,300),10),
    ("torso","root",(512,650),30),
    ("robe_back","torso",(512,650),20),
    ("thigh_L","torso",(455,930),35), ("shin_L","thigh_L",(455,1150),36), ("foot_L","shin_L",(455,1320),37),
    ("thigh_R","torso",(570,930),38), ("shin_R","thigh_R",(570,1150),39), ("foot_R","shin_R",(570,1320),40),
    ("upper_arm_L","torso",(390,690),50), ("forearm_L","upper_arm_L",(330,850),51), ("hand_L","forearm_L",(300,970),52),
    ("upper_arm_R","torso",(640,690),53), ("forearm_R","upper_arm_R",(700,850),54), ("hand_R","forearm_R",(730,970),55),
    ("neck","torso",(512,470),60), ("head","neck",(512,350),70),
    ("hair_front","head",(512,300),80),
    ("robe_front","torso",(512,680),90),
    ("weapon","hand_R",(760,950),100),
]
def local(tag): return tag.rsplit("}",1)[-1]
def main():
    p=argparse.ArgumentParser()
    p.add_argument("svg",type=Path); p.add_argument("--out",type=Path,required=True)
    p.add_argument("--width",type=int,default=1024); p.add_argument("--height",type=int,default=1536)
    a=p.parse_args()
    raw=a.svg.read_text(encoding="utf-8")
    if "<!DOCTYPE" in raw.upper() or "<!ENTITY" in raw.upper():
        raise SystemExit("Unsafe SVG: DTD/entity declarations are not accepted")
    root=ET.fromstring(raw)
    if local(root.tag)!="svg": raise SystemExit("Input root is not SVG")
    groups={e.attrib["id"]:e for e in list(root) if local(e.tag)=="g" and e.attrib.get("id")}
    missing=[x[0] for x in PARTS if x[0] not in groups]
    if missing: raise SystemExit("Missing segmented groups: "+", ".join(missing))
    defs=[e for e in list(root) if local(e.tag)=="defs"]
    a.out.mkdir(parents=True,exist_ok=True)
    parts={}
    for name,parent,pivot,z in PARTS:
        layer=ET.Element(root.tag,dict(root.attrib))
        for d in defs: layer.append(ET.fromstring(ET.tostring(d,encoding="unicode")))
        layer.append(ET.fromstring(ET.tostring(groups[name],encoding="unicode")))
        ET.ElementTree(layer).write(a.out/(name+".svg"),encoding="utf-8",xml_declaration=True)
        parts[name]={"parent":parent,"pivot":{"x":pivot[0],"y":pivot[1]},"z_index":z,"texture":name+".svg","pivot_review_required":True}
    manifest={"schema_version":2,"source":str(a.svg),"viewBox":root.attrib.get("viewBox",f"0 0 {a.width} {a.height}"),"canvas":{"width":a.width,"height":a.height},"parts":parts,"required_art_groups":[x[0] for x in PARTS],"notes":["All pivots are canvas-space estimates and require visual adjustment.","Each segment needs hidden overlap artwork at joints to avoid gaps.","Keep all SVG layers on the same viewBox for registration."]}
    (a.out/"full_body_rig.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
    print(f"Exported {len(PARTS)} segmented layers to {a.out}")
if __name__=="__main__": main()
