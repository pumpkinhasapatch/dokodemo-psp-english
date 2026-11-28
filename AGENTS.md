# AGENTS.md

Instructions for AI coding agents working in this repository.

Read [AI_POLICY.md](./AI_POLICY.md) as well. It explains how the project uses
machine translation, where the translated text actually lives, and why the
artwork is not AI-generated. This file covers the technical details of working
in the codebase.

## What this project is

A fan translation patch for **Doko Demo Issyo** on the PlayStation Portable
(PSP, 2004, Japan-only). It does not contain the game. It is a build system that
takes an original Japanese game ISO the user already owns, extracts it, patches
English text and images into the original game files, and writes the result to a
`build/` folder.

This means **the build cannot be run or verified without a copy of the game.**
Do not assume you can test end-to-end. See "Testing" below.

## Repository layout

| Path | What it is |
|------|-----------|
| `build.cmd` | Windows build script (batch). The reference implementation. |
| `build.sh` | Linux build script (POSIX `sh`). Should match `build.cmd` in behaviour. |
| `patches/` | Atlas text scripts. `boot.txt` and per-character message files. |
| `textures/GUI/` | English UI textures as `.png`, in per-menu folders. Exported from private vector sources, not edited in place. |
| `xmb/` | Game icon and background shown in the XMB / PPSSPP menu. |
| `scripts/` | Python and batch helpers for translators. Not part of the build. |
| `tools/` | Third-party programs. Vendored, licensed separately, do not modify. |
| `shiftjis.tbl` | Shift-JIS character table used by Atlas for text encoding. |
| `build/`, `extract/`, `insert/` | Generated at build time. Gitignored. |

`textures/GUI/README.txt` maps the cryptic folder names to the menus they belong
to (`ENIKKI` = Diary, `SOFTKEY` = on-screen keyboard, and so on).

## Hard rules

These cause real breakage. Check them before changing anything.

1. **Line endings are load-bearing.** `.gitattributes` enforces CRLF for
   `patches/*.txt`, `*.cmd`, `*.bat`, `*.cfg` and `shiftjis.tbl`, and LF for
   `*.sh`. Atlas versions before 1.12 hang on LF table files. If you generate a
   file in `patches/`, write `\r\n`.

2. **Filenames inside `build/` are case-sensitive on Linux.** The game files are
   uppercase (`PSP_GAME/SYSDIR/BOOT.BIN`, `ICON0.PNG`). Note that `xmb/ICON0.png`
   is lowercase in the repo and becomes `ICON0.PNG` when copied. Do not
   "normalise" these.

3. **GIM images must keep the original width, height and file size.** The game
   and the `bpar` archiver both assume this. `bpar` has known bugs that corrupt
   DATA.BP when a replacement file changes size. See `tools/bpar/README.md`.

4. **Do not modify anything in `tools/`.** It is vendored third-party code under
   separate licenses, marked `linguist-vendored`. GimConv in particular is
   proprietary Sony freeware.

5. **Do not add new dependencies.** The toolchain is fixed: Atlas, bpar, GimConv,
   pngquant, 7-Zip and Wine. If a change seems to need something else, that is a
   signal the approach is wrong.

6. **Never commit game data.** No ISOs, no `.KSC`/`.DIC`/`.GIM` files, no
   `build/`, `extract/` or `insert/` contents. `.gitignore` covers these; do not
   weaken it. The game is copyrighted and the project does not distribute it.

## The two build scripts must stay in sync

`build.cmd` (Windows) and `build.sh` (Linux) do the same job. `build.cmd` is the
reference. If you change one, check whether the other needs the same change, and
say so if you deliberately leave them different.

Both scripts, in order:

1. Verify the ISO's MD5 against `a7d8ff8050ac0d1fd6b0d5970eecbd8d`.
2. Clear `build/` and extract the ISO into it with 7-Zip.
3. Copy the three `xmb/` files over the game's icon and background.
4. Apply `patches/boot.txt` to `BOOT.BIN` with Atlas.
5. Generate `patches/param.txt` with the build date and apply it to `PARAM.SFO`.
6. Make the game load the modified boot file. Windows copies `BOOT.BIN` over
   `EBOOT.BIN`; Linux deletes `EBOOT.BIN`.
7. Extract the `.KSC`/`.DIC` text files from `DATA.BP` with bpar, into `extract/`.
8. Copy them to `insert/`, apply the per-character Atlas patches, write them back.
9. Convert `textures/**/*.png` to `.GIM`: pngquant to 8-bit alpha PNG first, then
   GimConv with `-bpp4 -N`, then insert with bpar and delete the temporary files.
10. Launch the `build/` folder in PPSSPP if it is installed.

### Character name mapping

The game's internal filenames are the animal in Japanese; the patch files use
the character's English name. Both scripts hardcode this mapping:

| Patch file prefix | Game file | Character |
|---|---|---|
| `toro` | `NEKO.KSC` | Toro (cat) |
| `suzuki` | `ROBO.KSC` | Suzuki (robot) |
| `jun` | `USAGI.KSC` | Jun (rabbit) |
| `pierre` | `INU.KSC` | Pierre (dog) |
| `ricky` | `KAERU.KSC` | Ricky (frog) |

`toro_dictionary.txt` is special: it patches `NEKO.DIC`, not `NEKO.KSC`.

## Shell script conventions (`build.sh`)

- **POSIX `sh`, not bash.** The shebang is `#!/bin/sh`. No arrays, no `[[ ]]`,
  no `local`, no `${var,,}`, no `source`. Validate with both
  `sh -n build.sh` and `dash -n build.sh`.
- `set -e` is on. Commands that may fail need explicit handling.
- Check for missing programs with `command -v`, accumulate into `error=1`, and
  exit before touching `build/` so the user gets one complete list.
- Quote all paths. Game folders and ISO filenames can contain spaces.
- Use `printf` rather than `echo` for anything with escapes or variables.
- `find ... -exec sh -c '...' sh {} +` is the established pattern for batch work.
  Variables used inside those subshells must be `export`ed.

## Atlas script conventions (`patches/*.txt`)

Atlas is a text insertion tool with its own scripting language. A patch file
looks like:

```
#SETTARGETFILE("build/PSP_GAME/SYSDIR/BOOT.BIN")
#VAR(Table, TABLE)
#ADDTBL("shiftjis.tbl", Table)
#ACTIVETBL(Table)

// Comment describing the menu this text appears in
#JMP($D8194)
#FIXEDLENGTH(3,0)
Text goes here<END>
```

- `#JMP($hex)` is the byte offset in the target file. Getting it wrong writes
  over unrelated game data.
- `#FIXEDLENGTH(n,0)` is the space available in bytes. **English text must fit
  the original Japanese text's byte length.** Japanese characters are two bytes
  in Shift-JIS, so there is often less room than it looks.
- `<END>` terminates a string. `[LR]` is a line return.
- Keep the `//` comment with the original Japanese where it exists. It is how
  reviewers check the translation.
- `patches/param.txt` is **generated by the build scripts on every run** and is
  gitignored. Do not edit it or commit it.

### Generated patch files

Some patch files are exported from the project's translation spreadsheet and
start with a header saying so:

```
//This file was automatically generated.
//Do not edit this file as changes will be lost.
```

`patches/toro_excel.txt` and `patches/pierre_excel.txt` are currently like this.
**Do not hand-edit any file carrying that header**, and do not "fix" translated
text in them; the next export will overwrite it. The spreadsheet is the source
of truth. `scripts/atlas_to_excel.py` and `scripts/excel_to_atlas.py` convert
between the two formats.

Files without that header, such as `patches/boot.txt` and
`patches/toro_messages.txt`, are maintained by hand and can be edited directly.

## Text formatting for in-game display

The PSP screen is narrow and the font is proportional. `scripts/char_widths.txt`
has per-character pixel widths and `scripts/word_wrap.py` wraps text to fit.
Control codes that appear in extracted text (`[WORDn]`, `[VARn]`, `[NYA]`,
`[KERO]`, `[LR]`, `[HEART]`) must be preserved exactly; they are byte sequences
the game interprets, not literal text. `scripts/extract_ksc_strings.py`
documents them.

## Testing

**You probably cannot run a full build.** It needs a copy of the game, plus Wine
with 32-bit support for Atlas and GimConv. State clearly what you did and did
not verify rather than implying a change is tested.

What you can always do:

```sh
sh -n build.sh && dash -n build.sh    # POSIX syntax check
```

What you can do without the game: exercise the script's logic in a temporary
directory with stub executables on `PATH` in place of `wine`, `bpar` and `7zz`.
This verifies control flow, error handling and cleanup. It does **not** verify
that the resulting game works.

`pngquant` can be tested for real against the repo's own textures, since they
are committed:

```sh
pngquant --force 16 -o /tmp/out.png textures/GUI/MAIN_MENU/MENU1.png
file /tmp/out.png     # expect a paletted PNG
```

Clean up any temporary directories you create.

## Pull requests

- Keep changes focused. Build system, translations and textures are separate
  concerns and separate PRs.
- Say what you tested and what you could not test.
- Translations normally come from the project's spreadsheet, not from pull
  requests. If you are submitting text directly, see
  [AI_POLICY.md](./AI_POLICY.md).
- Do not add yourself to the README credits in the same PR as a code change;
  ask the repository owner.

## Tone

This is a hobby project about a game where a cat asks you how your day was. The
README and comments are friendly and plain-spoken. Match that. Explain things
the way you would to a contributor who is good at Japanese but new to romhacking,
or good at C but new to Japanese, because both show up here.
