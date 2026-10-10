#!/usr/bin/env python3
import sys
import re
from openpyxl import Workbook

# Usage: python3 atlas_to_excel.py input.txt output.xlsx

JMP_RE = re.compile(r'#JMP\(\s*\$([0-9A-Fa-f]+)\s*\)')
FIXED_RE = re.compile(r'#FIXEDLENGTH\(\s*(\d+)\s*,\s*0\s*\)')
ORIG_RE = re.compile(r'//(.*)')
END_MARKER = '<END>'

def parse_blocks(text):
    lines = text.splitlines()
    addr = length = original = None
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i].rstrip()

        # Capture Original if present
        m = ORIG_RE.match(line)
        if m:
            original = m.group(1).strip()
            i += 1
            continue

        # Capture Length if present
        m = FIXED_RE.search(line)
        if m:
            length = m.group(1)
            i += 1
            continue

        # Capture Address if present (store hex without leading $)
        m = JMP_RE.search(line)
        if m:
            addr = m.group(1).upper()
            i += 1
            continue

        # If line is the start of English (not starting with // or # and not empty),
        # collect English until <END> and yield a record using the last-seen addr/length/original.
        stripped = line.lstrip()
        if stripped and not stripped.startswith('//') and not stripped.startswith('#'):
            eng_lines = []
            while i < n:
                cur = lines[i].rstrip()
                if END_MARKER in cur:
                    part = cur.split(END_MARKER)[0]
                    eng_lines.append(part)
                    i += 1
                    break
                else:
                    eng_lines.append(cur)
                    i += 1
            english = '\n'.join(ln for ln in eng_lines).strip()
            yield {
                "Address": addr or "",
                "Length": length or "",
                "Original": original or "",
                "English": english
            }
            # reset for next block
            addr = length = original = None
            continue

        # otherwise skip line
        i += 1

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 atlas_to_excel.py input.txt output.xlsx")
        sys.exit(1)
    infile, outfile = sys.argv[1], sys.argv[2]
    with open(infile, "r", encoding="utf-8") as f:
        text = f.read()

    rows = list(parse_blocks(text))

    wb = Workbook()
    ws = wb.active
    ws.append(["Address", "Length", "Original", "English"])
    for r in rows:
        ws.append([r.get("Address", ""), r.get("Length", ""), r.get("Original", ""), r.get("English", "")])
    wb.save(outfile)

if __name__ == "__main__":
    main()