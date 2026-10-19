#!/usr/bin/env python3
"""Package the built device application. Requires subsequent personal signing."""
import pathlib, plistlib, subprocess, sys, zipfile
app, output = map(pathlib.Path, sys.argv[1:])
info = plistlib.loads((app / 'Info.plist').read_bytes())
binary = app / info['CFBundleExecutable']
load = subprocess.check_output(['xcrun', 'vtool', '-show-build', str(binary)], text=True)
if 'platform IOS\n' not in load:
    raise SystemExit('Refusing to package a non-device executable:\n' + load)
for file in app.rglob('*'):
    if file.suffix in ('.dylib', '.so') or (file.is_file() and file.parent.suffix == '.framework' and file.name == file.parent.stem):
        data = subprocess.check_output(['xcrun', 'vtool', '-show-build', str(file)], text=True)
        if 'platform IOS\n' not in data:
            raise SystemExit('Non-iOS library: ' + str(file))
output.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(output, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for file in sorted(app.rglob('*')):
        if file.is_file():
            z.write(file, pathlib.Path('Payload') / app.name / file.relative_to(app))
with zipfile.ZipFile(output) as z:
    assert z.testzip() is None
print(output)
print(load)
