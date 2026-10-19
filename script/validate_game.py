#!/usr/bin/env python3
"""Check original archives using the project's format readers and required package list."""
import hashlib, json, pathlib, re, sys
root=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root/'tools'))
from psarc import read_toc, read_entry
from qar import QarArchive
from pathcode import read_pathid_list
folder=pathlib.Path(sys.argv[1])
source=(root/'src/engine/fs/vfs.cpp').read_text()
required=re.findall(r'"([^"]+)"',source.split('constexpr const char* kCoreArchive[] = {',1)[1].split('};',1)[0])
report={'folder':str(folder),'core_packages':[],'files':{}}
with (folder/'chunk1.psarc').open('rb') as f:
    info,entries,blocks=read_toc(f)
    names=['']+read_entry(f,entries[0],blocks,info['block_size']).decode().splitlines()
    lookup=dict(zip(names,entries))
    for name in required:
        if name not in lookup: raise SystemExit('Missing core package: '+name)
        data=read_entry(f,lookup[name],blocks,info['block_size'])
        if len(data)!=lookup[name]['size'] or not data: raise SystemExit('Unreadable package: '+name)
        report['core_packages'].append({'name':name,'bytes':len(data)})
    report['psarc_entries']=len(entries)-1
q=QarArchive(folder/'texture.qar')
for code,(offset,length) in q.entries.items():
    if offset<0 or length<=0 or offset+length>len(q.map):raise SystemExit('Invalid texture bounds: '+str(code))
report['texture_entries']=len(q.entries);q.close()
report['path_names']=len(read_pathid_list(folder/'pathid_list_ps4.bin'))
for name in ('chunk1.psarc','texture.qar','pathid_list_ps4.bin'):
    p=folder/name;h=hashlib.sha256()
    with p.open('rb') as f:
        while chunk:=f.read(8<<20):h.update(chunk)
    report['files'][name]={'bytes':p.stat().st_size,'sha256':h.hexdigest()}
report['status']='archive validation passed; gameplay requires runtime testing'
print(json.dumps(report,indent=2))
