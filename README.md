<h1 align="center">
  <br>
  <img src="textures/GUI/TITLE/TITLE.png" alt="Doko Demo Issyo PSP English Translation Project">
  <br>
</h1>

<h4 align="center">A work-in-progress <a href="https://en.wikibooks.org/wiki/PSP/Translation_Projects">English translation</a> <a href="https://en.wikipedia.org/wiki/Patch_(computing)">patch</a> for <a href="https://www.ign.com/games/doko-demo-issyo-psp">Doko Demo Issyo</a> on the PlayStation Portable.</h4>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#installation">Installation</a> •
  <a href="#manual-build">Manual build</a> •
  <a href="#features">Features</a> •
  <a href="#support">Support</a> •
  <a href="#development">Development</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <a href="https://discord.com/invite/AnTzMftu"><img src="https://img.shields.io/discord/824319065773441045?logo=discord&logoColor=white&color=5865F2&label=%23translation-proj-chat" alt="Discord"></a>
  <a href="https://github.com/pumpkinhasapatch/DokoDemo-PSP-Patcher/releases"><img src="https://img.shields.io/github/downloads/pumpkinhasapatch/DokoDemo-PSP-Patcher/total" alt="Releases"></a>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/issues"><img src="https://img.shields.io/github/issues/pumpkinhasapatch/DokoDemo-PSP-Patcher" alt="Issues"></a>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/commits/main"><img src="https://img.shields.io/github/last-commit/pumpkinhasapatch/DokoDemo-PSP-Patcher" alt="Commits"></a>
</p>

## Overview

Doko Demo Issyo (Hiragana: どこでもいっしょ) is a Japanese video game about talking creatures called Pokepi or "Pocket People" (see below). The gameplay is like a mix of [Tamagotchi](https://en.wikipedia.org/wiki/Tamagotchi) and [Animal Crossing](https://en.wikipedia.org/wiki/Animal_Crossing) or a life and pet simulator - Teach Pokepi words that will appear around the game and have conversations as they learn more each day and become closer friends with you. This game was released on the original PlayStation in 1999 and later remade for PlayStation Portable in 2004.

<div align=center><img src="https://gmedia.playstation.com/is/image/SIEPDC/dokodemoissyo-character-all-02-ja-01mar22?$1600px--t$" height=200></div>

The game was successful in Japan and had many sequels, merchandise and even a TV [series](https://dokodemo.fandom.com/wiki/Travel_with_Toro). However, most Doko Demo Issyo content was only released in Japanese and was never officially made available in other countries or languages. Information about the games spread to English-speaking countries over the internet and many fans became disappointed that they could not experience the games in their native language, only being able to import products from Japan and use image machine translation to make sense of all the game's Japanese language.

I started this project in February 2024 as an attempt to translate the Doko Demo Issyo PSP remake into English. It works by providing a set of unofficial translation patches that replace Japanese text and graphics inside the game with our custom English versions, which can be applied to an original copy of the game from any computer to create a translated English copy. This method has been used for localizing many other video games and has been requested for DDI by [many](https://www.reddit.com/r/PSP/comments/1dp1ary/wanna_learn_japanese_to_play_doko_demo_issyo/), [many](https://www.reddit.com/r/PSP/comments/1c4d4vq/is_there_really_no_way_to_play_doko_demo_issyo_in/), [MANY](https://www.reddit.com/r/psx/comments/163ynup/are_there_any_doko_demo_issyo_english/) English-speaking fans over recent years.

If you would like to learn more about Doko Demo Issyo, you can visit the [Fandom Wiki](https://dokodemo.fandom.com/wiki/Doko_Demo_Issyo_(Series)) or watch [dodgykebaab's YouTube video](https://www.youtube.com/watch?v=0x8Tgm9s068) showing footage of each game and explaining the series' history, or Hilltop's [What it takes to fan-translate a video game](https://www.youtube.com/watch?v=0tUxVSms4Q4) for the more technical concepts behind fan translation projects like this.

## Installation

> The translation project is still in early development, and a lot of the game's text is still untranslated from Japanese. See [Features](#features) for parts of the game that are available in English, or [Contributing](#contributing) if you would like to help out. We hope to add more translations in the future through updates on the [Releases page](https://github.com/pumpkinhasapatch/dokodemo-psp-patcher/releases), and the current state of the game may not reflect the final planned project.

### Dumping the original game

<img src="https://static.wikia.nocookie.net/dokodemo/images/d/d5/5052001-01.jpg" width=200 align=right>

The translation project is built around "Doko Demo Issyo Portable", which is a remake of the first Doko Demo Issyo game for PSP consoles and was released in Japan, in 2004. The correct box art for the game looks like the image on the right.

You will need an original copy of the game disc dumped as a .iso file to apply our English translations and play it. If you have a real PSP with a UMD drive (any model/region except Go or Vita), you can install [Custom Firmware](https://consolemods.org/wiki/PSP:Installing_ARK-4_CFW) and follow [these instructions](https://consolemods.org/wiki/PSP:Creating_Game_Backups) to dump the original UMD disc to your computer for the private use of this project. See [here](#support) for more help with dumping.

**Do not use the original PS1 game disc or [other PSP game](https://dokodemo.fandom.com/wiki/Doko_Demo_Issyo:_Let%27s_Go_to_School!) with box art showing a pink logo and Pokepi characters running toward the screen. These games are very different and are not supported by our translation project.**

Your copy of the game should be an .iso file that matches the details below, verified by [Redump](http://redump.org/disc/39834):
```
Serial Number: UCJS-10002 or UCJS-18002
Version: 1.01

CRC-32: 44b8dce6
MD5: a7d8ff8050ac0d1fd6b0d5970eecbd8d
SHA1: d5561bfb9362a47357aa070d8665ea22fdc83084
```

If your copy of the game matches this, you can follow the xdelta patcher instructions below to apply our translations to the game. If the hashes do not match, try using a different program to dump the game or [contact us](#support) on the Toro's Friend Dungeon Discord. You may also attempt a [manual build](#building) of the game if you're comfortable using Linux or the Command Prompt.

### Applying xdelta patches
This is the easiest way to play Doko Demo Issyo in English if you don't care about making changes to the translation. If you want to edit translations or help improve the code, see the [Custom build](#building) section below.

#### You will need:
- [Original game ISO](#dumping-the-original-game) of Doko Demo Issyo Portable matching the checksums above.
- [xdelta UI](https://www.romhacking.net/utilities/598/) - A graphical patching tool that lets you apply .xdelta patch files to a game.
- [Translation patch](https://github.com/pumpkinhasapatch/dokodemo-psp-patcher/releases) - Download the latest .xdelta patch file from our Releases page. This contains all the changes needed to convert an original Japanese copy of Doko Demo Issyo Portable into our fan translation.

#### Instructions:
1. Download [xdelta UI](https://www.romhacking.net/utilities/598/) and the latest .xdelta Patch File from the [Releases page](https://github.com/pumpkinhasapatch/dokodemo-psp-patcher/releases). The Patch File contains the minimum changes needed to convert an original Japanese copy of the game into our fan translation.
<img src="https://www.romhacking.net/utilities/screenshots/598screenshot1.png" align=right>
2. Start xdeltaUI.exe and make sure you are on the "Apply Patch" tab. Click the "Open" button next to Patch at the top-right, and select the .xdelta Patch File you downloaded in Step 1. Open your Doko Demo Issyo UMD .iso backup as the Source File.
3. Set the Output File to somewhere memorable on your computer, and click the "Patch" button to merge the two other files into the new translated game.
4. You can now run the Output File in the [PPSSPP emulator](https://www.ppsspp.org) on most modern devices, or copy it back onto your modded PSP to play the translated Doko Demo Issyo game. If this didn't work, contact [Support](#support) or keep reading the Custom build guide below.

You can also use the other tools to apply .xdelta patches including command line utilities, however most of them are difficult to use or have not been updated in years. It's difficult to find a good alternative that is as user-friendly as xdelta UI, and we cannot provide or guarantee support for every patching tool out there.

### Playing the translation
Once you have applied the English translation, you can play it on a modded PSP console or use the [PPSSPP emulator](https://ppsspp.org) on computers and most modern devices. Launch PPSSPP and go to the Files tab, then find your translated game file or the `build` folder to start playing.

## Manual build

This is a more advanced setup that works with some dumps of Doko Demo Issyo Portable that do not exactly match the file hashes above, and allows you to make changes to text and images before inserting them into the game.

Start by grabbing a copy of the translation project code. Either use the green `<> Code` button at the top of this page and click "Download .zip", get the source code from the Releases page or clone the repository if you know how to use a Git client.

You will also need to extract the original game into a folder called `build`, which is where the translations will be applied on top of. You can use PeaZip, 7-Zip or Windows Explorer to get the `PSP_GAME` folder and `UMD_DATA.BIN`. Note that some Linux software extracts these with lower-case file names which will not work.

### Windows

Launch `build.cmd` from the File Explorer or Command Prompt. It should download a few needed tools from the internet and try to apply the game patches.

If you get an "Atlas.exe - System Error" saying that "MSVCP140.dll was not found", this just means you need to install the [Microsoft Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170) to use the [Atlas](#credits) patcher.

> The Windows build script is known to be buggy and may be replaced by the Linux script below in future. You can install [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) on most Windows 10 and 11 systems to run the Linux script on your computer inside of Windows.

### Linux

```bash
# Install packages needed to run GimConv and abcde tools.
# Replace 'apt' with your package manager: 'dnf', 'pacman -S', etc.
sudo apt install wine perl -y

# Download the source code. You could also get a .zip archive from GitHub.
git clone https://github.com/pumpkinhasapatch/dokodemo-psp-english.git

# Navigate into project folder.
cd dokodemo-psp-english

# Allow build script and bpar to run as programs.
sudo chmod +x build.sh
sudo chmod +x tools/bpar

# Attempt to patch the game in the build folder. Should tell you if any files are missing.
./build.sh
```

### Creating patch files

#### You will need:
- Original game ISO and modified `build` folder from a manual build.
- [UMDGen](https://www.romhacking.net/utilities/1218) program to make changes to PSP UMD disc files.
- [xdelta UI](https://www.romhacking.net/utilities/598/) to create .xdelta patch out of the original and modified game.
- Windows computer, or Unix system with [Wine](https://winehq.org) or another way of running Windows programs on it.

#### Instructions:
1. Start [UMDGen](https://www.romhacking.net/utilities/1218/) on your computer.
2. Choose "File -> Open Disk Image" and select the original game .iso file to load it. The .iso file should be a completely unmodified 1.01 game and match the hash information [here](#how-to-play).
3. Import the files from your modified `build` folder with the translation changes. (See Build instructions)
4. Save the files from UMDGen as an Uncompressed ISO (Ctrl+S) and close UMDGen.
5. Start xdelta UI and go to the "Create Patch" tab. Choose the original game ISO and the modified ISO you just made, then it should save a .xdelta file ~2mb at the Patch Destination.

## Features

Not everything is complete yet, and we have focused on important parts of menus and Pokepi text. Here is a list of translated features so far:

| Feature | Progress | Notes |
|---|---|---|
| Menus | Playable | Title Screen, Player Data and In-Game Menus are mostly translated to English. [Redditor baalzeebul](https://www.reddit.com/r/PSP/comments/17op7f2/doko_demo_issho_psp_english_guide_pdf_part_1/) has made an [English PDF "guide"](https://drive.google.com/file/d/11tnhqBiwtvxKE70fE0nE1FH5B8ftfa2k/view) with some more menus translated that need to be added. |
| Keyboard | Playable | Hacked English letters into the in-game Japanese keyboard, allowing you to type 4-letter long English names on the Player Data screen. Hiragana/katakana characters may still display on the keypad buttons.
| Toro Inoue | Introduction / other | Toro's first block of text said when you start a new game has been translated, and some other bits I found in the game's files. |
| R. Suzuki | None | Some kind person has already translated a bit of the game. Need to find Hex addresses and add text from https://suzukistation.neocities.org/suzpsp and https://suzukistation.neocities.org/suzdiary |
| Jun Mihara | Introduction | Done the first block of text when you start a new game. There is more at https://suzukistation.neocities.org/junpsp |
| Other Pokepi | None | All other Pokepi will use their original Japanese dialogue.

## Support

If you need help patching the game or using the build scripts, please join the [Toro's Friend Dungeon](https://discord.gg/3EYqGKpqNG) Discord server and ask for support in the #translation-proj-chat channel.

If you are trying to dump an original game disc with your PSP console using Custom Firmware tools, refer to the guides at [ConsoleMods.org](https://consolemods.org/wiki/PSP:PSP_Mods_Wiki), [PSPunk](https://www.pspunk.com/) or ask on the [PSP Homebrew Community](https://discord.gg/bePrj9W) Discord server.

If you have any feedback or would like to report a bug, you can contact pumpkinhasapatch through the Toro's Friend Dungeon Discord or this project's [GitHub Issues](https://github.com/pumpkinhasapatch/dokodemo-psp-patcher/issues) page.

## Development

Doko Demo Issyo is a text-focused game with hundreds of Japanese messages that need to be translated for this project to work. We could use your help in searching for new data in the game's files and providing accurate Japanese-English translations.

Most of the game's files are stored in proprietary formats such as .GIM, .BPM and .KSC. You can get most of them from this by running `./bpm-extract.sh` or `./tools/bpar`

Most development is done using the [Hexinator](https://hexinator.com) editor set to Shift-JIS encoding to search for Japanese text in the game's files, and bpar and GimConv to convert different file types.

By taking apart and searching the game files in a Hex Editor, I was able to locate most of the Japanese text, copy it into Google Translate one string at a time, fix any mistakes with my fluent English skills and write some code that can put it back into a working game. I will probably write a better guide on this in the future.

## Credits

[PumpkinhasaPatch](https://github.com/pumpkinhasapatch) - batch script programming, project founder, translation checking

### Dependency programs used by build scripts:
The following programs are used under a different license. These programs are also open to changes and the source code can be found on the linked page:

- Atlas V1.11 8/10/2010 - https://www.romhacking.net/utilities/224 - A text patching tool and scripting language to insert new data over the Doko Demo Issyo Pokepi's speech among other things.
- [abcde by abw](https://www.romhacking.net/utilities/1392/) - A cross-platform alternative to Atlas with more features and better error reporting, written in Perl script.
- bpar by nekobit - https://code.neko.rehab/ddi-tools/file - To extract and insert files from the game's proprietary DATA.BP archive.
- Sony's GimConv - A freeware/proprietary program for Windows developed by Sony for converting PNG images to the GIM format the game uses. GimConv is not included with the Patcher due to copyright reasons, and you may need to add it to the `tools` folder yourself.

### Other people who indirectly helped:
- shiftjis.tbl file based on the one from the [Stein's Gate PSP Translation](https://github.com/BASLQC/steins-gate-psp-patch/blob/master/data/shiftjis.tbl), with some changes to work with abcde and Doko Demo Issyo Portable.
- https://suzukistation.neocities.org/ for some R. Suzuki and Jun text translations.
- [baalzeebul on Reddit](https://www.reddit.com/r/PSP/comments/17op7f2/doko_demo_issho_psp_english_guide_pdf_part_1/) for some translations (mainly in the "Teach word" menus).
- README.md header/template from [Markdownify](https://github.com/amitmerchant1990/electron-markdownify) by Amit Merchant. Retrieved from the [GitHub README Templates](https://www.readme-templates.com) website.

## License

Doko Demo Issyo PSP English Translation Project © pumpkinhasapatch 2024 <https://github.com/pumpkinhasapatch/dokodemo-psp-english>

The Translation Project content and .xdelta patch files are licensed under version 3 or later of the [GNU General Public License](./LICENSE-GPL.txt) (GPL). You can use and edit any source code included in this repository including build scripts and content of the `patches` and `textures` folders. If you make any changes to this code and release your own version, you must always share your source code and follow all other terms of the GPL.

When the translation files are added to the original game, this creates a "Combined Work" with a mix of our Free Software patches and Sony's "All Rights Reserved" content. You can still use this Combined Work for private use if you have applied the patch to the game yourself, but any form of the game containing Sony/BeXide's original copyrighted content must not be shared nor distributed to other people.

If you have made any changes to the translation project, you can instead share the repository code an [.xdelta patch file](#applying-xdelta-patches) with other people, as long as it doesn't contain any other copyright-infringing content. Users must always provide their own copy of the original game to apply and play the translation. If you are not following these terms correctly, I may send you a friendly notice suggesting how to fix it or remove your content.

This translation patch is a hobby project created from hours of work by English players of Doko Demo Issyo and is not an official product developed by, associated with, approved, nor endorsed by Sony Interactive Entertainment or BeXide, Inc.. pumpkinhasapatch is not responsible for any game content shared outside of this GitHub page or the pumpkinhasapatch Discord account, and any questions or concerns should be sent to the uploader of the content.
