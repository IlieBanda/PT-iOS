#!/usr/bin/env python3
"""Audit packaged Mach-O imports and load commands, not a proof of all runtime behaviour."""
import json, pathlib, plistlib, re, subprocess, sys
app = pathlib.Path(sys.argv[1])
plist = plistlib.loads((app/'Info.plist').read_bytes())
files = [app/plist['CFBundleExecutable']]
files += [p for p in app.rglob('*') if p.is_file() and (p.suffix in ('.dylib','.so') or (p.parent.suffix=='.framework' and p.name==p.parent.stem))]
report = {'scope':'CPU JIT and device architecture audit; gameplay unverified', 'binaries':[]}
for file in files:
    imports = subprocess.check_output(['xcrun','nm','-u',str(file)],text=True)
    forbidden = re.findall(r'\b_(?:pthread_jit\w*|vm_remap|mmap|mprotect)\b', imports)
    if forbidden:
        raise SystemExit(f'Executable memory related imports need manual review: {file}: {forbidden}')
    load = subprocess.check_output(['xcrun','vtool','-show-build',str(file)],text=True)
    if not re.search(r'platform IOS\s',load): raise SystemExit(f'Wrong platform: {file}')
    arch = subprocess.check_output(['xcrun','lipo','-archs',str(file)],text=True).strip()
    if arch != 'arm64': raise SystemExit(f'Wrong architecture: {file}: {arch}')
    commands = subprocess.check_output(['xcrun','otool','-l',str(file)],text=True)
    for segment in commands.split('Load command'):
        if 'LC_SEGMENT_64' in segment and re.search(r'initprot\s+0x00000007',segment):
            raise SystemExit('Writable executable segment: '+str(file))
    report['binaries'].append({'path':str(file.relative_to(app)),'arch':arch,'platform':'iOS','executable_memory_imports':forbidden})
print(json.dumps(report,indent=2))
