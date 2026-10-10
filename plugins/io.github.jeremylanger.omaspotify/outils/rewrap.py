import re, glob, sys
d = sys.argv[1]
import os; os.chdir(d)
src = open('I18n.js').read()
keys = re.findall(r'^\s*"((?:[^"\\]|\\.)*)":', src, re.M)
skip = {"MMMM d", "dddd, MMMM d", "ddd, MMM d · ", "d MMM yyyy"}
keys = sorted([k for k in keys if k not in skip], key=len, reverse=True)
total = 0
for f in sorted(glob.glob('*.qml') + glob.glob('*.js')):
    if f in ('I18n.js', 'FontScale.js'): continue
    s = open(f).read(); n0 = 0
    for k in keys:
        lit = '"' + k + '"'
        if lit not in s: continue
        pat = re.compile(r'(?<!I18n\.t\()(?<![=!]== )(?<!case )' + re.escape(lit) + r'(?!\s*(?:===|!==))(?!:)')
        s, n = pat.subn('I18n.t(' + lit + ')', s); n0 += n
    if n0:
        if 'I18n.js' not in s:
            if f.endswith('.js'):
                s = s.replace('.pragma library', '.pragma library\n.import "I18n.js" as I18n', 1) if '.pragma library' in s else '.import "I18n.js" as I18n\n' + s
            else:
                im = list(re.finditer(r'^import .*$', s, re.M)); s = s[:im[-1].end()] + '\nimport "I18n.js" as I18n' + s[im[-1].end():]
        # never translate key names inside shortcut definitions
        lines = s.split('\n')
        for i, l in enumerate(lines):
            if re.search(r'sequences?\s*:|Shortcut\s*\{|StandardKey|matches\(', l):
                lines[i] = re.sub(r'I18n\.t\(("(?:Space|Esc|Escape|Up|Down|Left|Right|Return|Enter|Tab)")\)', r'\1', l)
        s = '\n'.join(lines)
        open(f, 'w').write(s); total += n0; print(f, n0)
print('total', total)
