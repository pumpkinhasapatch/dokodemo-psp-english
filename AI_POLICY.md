# AI Policy

How the Doko Demo Issyo PSP English Translation Project uses AI tools.

This project is a hobby fan translation made by people who care about Doko Demo Issyo.
We use automation as part of our workflow and we would rather be upfront about exactly 
how, because "is this just AI?" is a fair question to ask about any project.

## The short answer

- **Automation is the first pass, not the final answer.** Every line is
  reviewed by a human before it reaches players.
- **A human is always responsible.** If you submit it, you are vouching for it.
- **Artwork is not AI-generated.** See [Artwork](#artwork) below.

## How we translate

This project uses machine translation as a deliberate, structured step.
It is not something contributors do on the side; it is how the pipeline works:

1. Text is **extracted from the game files** using custom scripts and tooling.
   Some of it is published on GitHub, including
   [ddi-tools](https://github.com/pumpkinhasapatch/ddi-tools) and the helper scripts in [`scripts/`](./scripts).
2. The extracted Japanese is **run through machine translation** to produce a first pass.
3. The results are **carefully reviewed and corrected by humans** before they go anywhere near a release.

The working text lives in a [public Google spreadsheet](https://docs.google.com/spreadsheets/d/1eM4XHKByXav0P1vemQgKbA8GmEHsp4smZ-cXVcdBuAc/edit?usp=sharing) that anyone can view.
People with the **Translator role** can edit it and contribute translations. Ask
in the [Discord server](https://pumpkin.moe/discord) if you would like access.

Because the spreadsheet is the source of truth, some Atlas scripts in `patches/`
are **generated from it** and say so in their header. Do not hand-edit a file
that says it was automatically generated; your changes will be overwritten the
next time it is exported. Edit the spreadsheet instead. See
`scripts/excel_to_atlas.py` and `scripts/atlas_to_excel.py` for the round trip.

### Human review is the part that matters

Machine translation gets us coverage. It does not get us a good translation. The
review step is where the actual work happens, and it is not optional.

Assume the machine output is wrong until it has been checked. In particular:

- It invents plausible text for lines it cannot actually read, which is
  especially likely with this game's compressed, context-free message fragments.
- It drops or mangles the game's control codes. Codes like `[WORDn]`, `[VARn]`,
  `[NYA]`, `[KERO]`, `[LR]` and `[HEART]` are not decoration; the game will
  misbehave or crash if they are altered. See `scripts/extract_ksc_strings.py`.
- It loses character voice. Toro, Suzuki, Jun, Pierre and Ricky do not sound
  alike, and a model with no context will flatten them into the same voice.
- It guesses at honorifics, name readings and series terminology that this
  project has already made deliberate decisions about.
- It ignores the byte budget. English text has to fit within the original
  Japanese string's length, and a model does not know or care about that.

If nobody available can verify a line, it is better to leave it untranslated
than to ship a guess. Untranslated text is an honest to-do; a wrong translation
looks finished and tends to stay wrong.

[Jisho.org](https://jisho.org), [Yomitan](https://github.com/themoeway/yomitan)
and the [JMdict](https://www.edrdg.org/wiki/index.php/JMdict-EDICT_Dictionary_Project)
and [KANJIDIC](https://www.edrdg.org/wiki/index.php/KANJIDIC_Project) databases
are the project's usual references when checking a tricky line. They tell you
what a word can mean and let you decide, instead of deciding for you.

### Submitting translations outside the spreadsheet

If you send translated text through a pull request rather than the spreadsheet,
say where it came from and how it was checked. A reviewer who knows a line is an
unreviewed machine pass can prioritise it properly. A reviewer who was not told
cannot.

## Code and build scripts

AI coding assistants are fine for `build.cmd`, `build.sh`, the Python helpers in
`scripts/` and the Atlas scripts in `patches/`, with the same conditions: you
read it, you understand it, you tested it.

Specifically, before submitting AI-assisted code:

- **Run it.** `./build.sh` on Linux or `.\build.cmd` on Windows should complete
  against a real copy of the game.
- **Check the result in-game.** A build that completes without errors can still
  produce a game that does not boot or has corrupted text.
- **Do not let a model invent dependencies.** This project deliberately uses a
  small, fixed set of tools (Atlas, bpar, GimConv, pngquant, 7-Zip, Wine). Do
  not add new ones to make a suggestion work.
- **Watch the file formats.** GIM images must keep the same width, height and
  file size as the original or the DATA.BP archive can be corrupted, and bpar
  has known bugs when resizing files. See `tools/bpar/README.md` and
  `tools/GimConv/README.md`.
- **Keep the line endings.** Files in `patches/` and `shiftjis.tbl` must stay
  CRLF, and `*.sh` must stay LF, as set in `.gitattributes`. Older Atlas
  versions require LF line endings.

Disclosing AI-assisted code in a pull request is appreciated but not required.
The code either works or it does not, and it gets tested either way.

## Documentation

AI assistance is fine for README text, wiki pages and comments. Check that it is
actually true for this project. Models confidently describe how a *typical* PSP
romhack works, which is not always how this one works.

## Artwork

**We do not use AI for artwork.** Most of it is already finished.

The game textures in `textures/` and the XMB artwork in `xmb/` are recreations of
the original aesthetic drawn as clean vector graphics in [Affinity Studio](https://affinity.studio), then
exported to the PNG files in this repository. The vector source files are private
for now.

If you need more artwork for the game, **including artwork for other languages**,
ask pumpkinhasapatch in the [Discord server](https://pumpkin.moe/discord) rather
than generating or redrawing it yourself. It is much easier to export a new
version from the existing vector sources than to match the style from scratch.

Generated images would not work here anyway: these textures have to match the
game's existing style exactly and fit strict size and palette limits, and GIM
images must keep the same width, height and file size as the originals.

## Forks and other languages

This policy covers [this project](https://github.com/pumpkinhasapatch/dokodemo-psp-english) only.

Forked versions of the translation, including translations into languages other
than English, are **not managed by pumpkinhasapatch**. They have their own
maintainers, their own workflows and their own approach to AI. Please ask the
maintainer of that project directly about how their version is made; we cannot
answer for it.

## Reporting a problem

If you find text that looks like it has not been reviewed, please
[open an issue](https://github.com/pumpkinhasapatch/dokodemo-psp-english/issues/new)
or mention it in the [Discord server](https://pumpkin.moe/discord). Point at the
specific line if you can. It will be re-checked, not taken personally.

Reporting a bad line is genuinely useful. With thousands of messages in the game
and a machine pass behind many of them, players spotting mistakes is part of how
the translation gets better.

## A note on why

The project's credits point at the
[Mother 3 Fan Translation](https://mother3.fobby.net) and
[Legends of Localization](https://legendsoflocalization.com/) as the standard
this project wants to reach. That standard is about care: understanding what the
original says, what it is doing, and how to make it land for an English player.

AI can genuinely help you get there faster. It cannot do the caring for you.
That is the whole job, and it is why this is worth doing at all.
