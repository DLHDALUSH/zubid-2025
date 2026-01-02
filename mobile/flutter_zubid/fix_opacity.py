import os
import re

def fix_with_opacity():
    count = 0
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
                    
                    if new_content != content:
                        with open(path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f'Updated {path}')
                        count += 1
                except Exception as e:
                    print(f'Error processing {path}: {e}')
    print(f'Total files updated: {count}')

if __name__ == "__main__":
    fix_with_opacity()
