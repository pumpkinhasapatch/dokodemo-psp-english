#!/usr/bin/env python3
"""
Extract Shift-JIS strings from NEKO.KSC

Special codes:
  - [WORDn] = 16 14 n 00 16 (5 bytes total)
  - [VARn] = 14 n 00 (another type of variable, only when NOT part of 16 14 XX 00 16)
  - [NYA] = 17 17 00 (Pokepi catchphrase: "meow", "woof", "beep", "squeak")
  - [KERO] = 17 1A 00 (similar to [NYA], used by Ricky/KAERU.KSC only)
  - [LR] = 0A (line return)
  - [HEART] = 85 40 (heart symbol)

Strings start after byte 0x48 or 0x8E and end at null byte 0x00.
BUT: Must verify 0x48/0x8E are not part of valid Shift-JIS sequences:
  - 0x48: Check previous byte is NOT a valid SJIS lead (0x81-0x9F, 0xE0-0xFC)
  - 0x8E: Check next byte is NOT 0xA1-0xDF (half-width katakana)

Output:
  - neko_strings.csv: CSV format (Offset, Length, Text, RawHex)
  - neko_strings.txt: Human-readable format
"""

import sys


def is_sjis_lead(b):
    """Check if byte is a Shift-JIS lead byte."""
    return 0x81 <= b <= 0x9F or 0xE0 <= b <= 0xFC


def is_sjis_trail(b):
    """Check if byte is a Shift-JIS trail byte."""
    return 0x40 <= b <= 0x7E or 0x80 <= b <= 0xFC


def is_hw_katakana(b):
    """Check if byte is half-width katakana range (0xA1-0xDF)."""
    return 0xA1 <= b <= 0xDF


def is_valid_marker(data, pos):
    """
    Check if byte at pos is a valid string start marker (0x48 or 0x8E).
    Returns True only if the byte is NOT part of a valid Shift-JIS sequence.
    """
    if pos >= len(data):
        return False
    
    b = data[pos]
    
    if b == 0x48:
        # Check if previous byte is a valid SJIS lead (which would make this a trail byte)
        if pos > 0 and is_sjis_lead(data[pos - 1]):
            return False
        return True
    
    elif b == 0x8E:
        # Check if previous byte is a valid SJIS lead (which would make this a trail byte)
        # 0x8E is in the valid SJIS trail byte range (0x40-0x7E, 0x80-0xFC)
        if pos > 0 and is_sjis_lead(data[pos - 1]):
            return False
        # Check if next byte is half-width katakana (0xA1-0xDF)
        if pos + 1 < len(data) and is_hw_katakana(data[pos + 1]):
            return False
        return True
    
    return False


def extract_strings(filepath):
    """Extract Shift-JIS strings from binary file."""
    with open(filepath, 'rb') as f:
        data = f.read()
    
    strings = []
    i = 0
    
    while i < len(data) - 1:
        # Check for valid start marker (48 or 8E), ensuring it's not part of SJIS
        if is_valid_marker(data, i):
            start = i + 1
            text_bytes = bytearray()
            j = start
            
            while j < len(data):
                b = data[j]
                
                # Check for null terminator (ends the string)
                if b == 0x00:
                    break
                
                # Check for heart symbol: 85 40
                if b == 0x85 and j + 1 < len(data) and data[j+1] == 0x40:
                    text_bytes.extend(b'[HEART]')
                    j += 2
                    continue
                
                # Check for NYA code: 17 17 00
                if b == 0x17 and j + 2 < len(data) and data[j+1] == 0x17 and data[j+2] == 0x00:
                    text_bytes.extend(b'[NYA]')
                    j += 3
                    continue

                # Check for KERO code: 17 1A 00
                if b == 0x17 and j + 2 < len(data) and data[j+1] == 0x1A and data[j+2] == 0x00:
                    text_bytes.extend(b'[KERO]')
                    j += 3
                    continue
                
                # Check for WORD code: 16 14 XX 00 16 (5 bytes)
                if b == 0x16 and j + 4 < len(data) and data[j+1] == 0x14 and data[j+3] == 0x00 and data[j+4] == 0x16:
                    var_val = data[j+2]
                    text_bytes.extend(f'[WORD{var_val}]'.encode('ascii'))
                    j += 5
                    continue
                
                # Check for VAR code: 14 XX 00
                if b == 0x14 and j + 2 < len(data) and data[j+2] == 0x00:
                    prev_b = text_bytes[-1] if text_bytes else None
                    if prev_b != 0x16:
                        var_val = data[j+1]
                        text_bytes.extend(f'[VAR{var_val}]'.encode('ascii'))
                        j += 3
                        continue
                
                # Check for half-width katakana: 8E XX where XX is A1-DF
                if b == 0x8E and j + 1 < len(data) and is_hw_katakana(data[j+1]):
                    text_bytes.extend([b, data[j+1]])
                    j += 2
                    continue
                
                # Valid Shift-JIS two-byte character
                if is_sjis_lead(b):
                    if j + 1 < len(data):
                        trail = data[j+1]
                        if is_sjis_trail(trail):
                            text_bytes.extend([b, trail])
                            j += 2
                            continue
                    break
                
                # ASCII printable
                elif 0x20 <= b <= 0x7E:
                    text_bytes.append(b)
                    j += 1
                    continue
                
                # Line return (0x0A) - replace with [LR]
                elif b == 0x0A:
                    text_bytes.extend(b'[LR]')
                    j += 1
                    continue
                
                # Control bytes - skip them
                elif b in (0x11, 0x12, 0x13, 0x15, 0x80, 0x81, 0x82, 0x83, 0x84, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F):
                    j += 1
                    continue
                
                # Other byte - end string
                else:
                    break
            
            # Minimum string length
            if j - start >= 6:
                try:
                    # Validate the extracted string
                    text = text_bytes.decode('shift_jis', errors='strict')
                    
                    # Check for invalid control characters
                    has_invalid = any(ord(c) < 32 and c not in '\n\r\t' for c in text)
                    
                    if not has_invalid:
                        # Must have meaningful content
                        has_real_content = any(
                            '\u3040' <= c <= '\u309F' or  # Hiragana
                            '\u30A0' <= c <= '\u30FF' or  # Katakana
                            '\u4E00' <= c <= '\u9FFF' or  # Kanji
                            '\uFF00' <= c <= '\uFFEF' or  # Fullwidth
                            (c.isalpha() and ord(c) < 127) or  # ASCII letters
                            c.isdigit()  # Digits
                            for c in text
                        )
                        
                        # Check if string is only markers
                        is_only_markers = all(
                            c in '[]0123456789ABCDEFWORDVARNYALRHEART' or c.isspace()
                            for c in text
                        )
                        
                        if has_real_content and not is_only_markers:
                            strings.append({
                                'offset': f"{start:X}",
                                'length': j - start,
                                'text': text
                            })
                except UnicodeDecodeError:
                    pass
        
        i += 1
    
    return strings


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <input_file> [output_prefix]")
        print(f"Example: {sys.argv[0]} NEKO.KSC neko_strings")
        sys.exit(1)
    
    filepath = sys.argv[1]
    output_prefix = sys.argv[2] if len(sys.argv) > 2 else "neko_strings"
    
    print(f"Extracting Shift-JIS strings from: {filepath}")
    strings = extract_strings(filepath)
    
    # Write CSV
    csv_file = f"{output_prefix}.csv"
    with open(csv_file, 'w', encoding='utf-8') as f:
        f.write("Offset,Length,Text\n")
        for s in strings:
            text_escaped = s['text'].replace('"', '""').replace('\n', '\\n').replace('\r', '\\r')
            f.write(f"{s['offset']},{s['length']},\"{text_escaped}\"\n")
    
    # Write readable format
    txt_file = f"{output_prefix}.txt"
    with open(txt_file, 'w', encoding='utf-8') as f:
        f.write(f"# Extracted Shift-JIS strings from {filepath}\n")
        f.write(f"# Total strings: {len(strings)}\n")
        f.write(f"# Special codes: [WORDn] = 16 14 n 00 16, [VARn] = 14 n 00, [NYA] = 17 17 00, [KERO] = 17 1A 00, [LR] = 0A, [HEART] = 85 40\n")
        f.write("="*100 + "\n\n")
        
        for s in strings:
            f.write(f"Offset: {s['offset']} | Length: {s['length']:4d} | Text: {s['text']}\n")
    
    print(f"\nExtracted {len(strings)} strings")
    print(f"\nOutput files:")
    print(f"  - {csv_file}")
    print(f"  - {txt_file}")
    
    # Show statistics
    word_count = sum(1 for s in strings if '[WORD' in s['text'])
    var_count = sum(1 for s in strings if any(f'[VAR' in s['text'] for i in range(256)))
    meow_count = sum(1 for s in strings if '[NYA]' in s['text'])
    kero_count = sum(1 for s in strings if '[KERO]' in s['text'])
    heart_count = sum(1 for s in strings if '[HEART]' in s['text'])
    
    print(f"\nStatistics:")
    print(f"  Strings with [WORDn]: {word_count}")
    print(f"  Strings with [VARn]: {var_count}")
    print(f"  Strings with [NYA]: {meow_count}")
    print(f"  Strings with [KERO]: {kero_count}")
    print(f"  Strings with [HEART]: {heart_count}")


if __name__ == '__main__':
    main()
