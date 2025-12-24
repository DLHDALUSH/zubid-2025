import glob
import sys
import traceback
try:
    import yaml
except Exception:
    print('PyYAML is not installed in this Python. Install with `pip install pyyaml` or run in your venv.')
    sys.exit(3)

files = glob.glob('**/*.yml', recursive=True) + glob.glob('**/*.yaml', recursive=True)
if not files:
    print('No YAML files found in repo.')
    sys.exit(0)

errors = False
for f in sorted(files):
    try:
        with open(f, 'r', encoding='utf-8') as fh:
            yaml.safe_load(fh)
    except Exception as e:
        print(f'YAML parse error in {f}: {e}')
        traceback.print_exc()
        errors = True

if errors:
    sys.exit(2)

print('No YAML parse errors found.')
