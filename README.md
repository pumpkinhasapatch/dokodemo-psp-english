<h1 align="center">
  <br>
  <img src="textures/GUI/TITLE/TITLE.png" alt="Doko Demo Issyo PSP English Translation Project">
  <br>
</h1>

<h4 align="center">A work-in-progress <a href="https://en.wikipedia.org/wiki/Fan_translation_of_video_games">English translation</a> <a href="https://en.wikipedia.org/wiki/Patch_(computing)">patch</a> for <a href="https://www.ign.com/games/doko-demo-issyo-psp">Doko Demo Issyo</a> on the PlayStation Portable.</h4>

<p align="center">
  <a href="#installation">Installation</a> -
  <a href="#building">Building</a> -
  <a href="#progress">Progress</a> -
  <a href="#screenshots">Screenshots</a> -
  <a href="#support">Support</a> -
  <a href="#contributing">Contributing</a> -
  <a href="#credits">Credits</a> -
  <a href="#license">License</a>
  <br>
  Game help and development information has moved to the <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki">Project Wiki</a>.
</p>

<p align="center">
  <a href="https://discord.gg/3EYqGKpqNG"><img src="https://img.shields.io/discord/824319065773441045?logo=discord&logoColor=white&color=5865F2&label=%23translation-proj-chat" alt="Discord"></a>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/releases"><img src="https://img.shields.io/github/downloads/pumpkinhasapatch/dokodemo-psp-english/total" alt="Releases"></a>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/issues"><img src="https://img.shields.io/github/issues/pumpkinhasapatch/dokodemo-psp-english" alt="Issues"></a>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/commits/dev"><img src="https://img.shields.io/github/last-commit/pumpkinhasapatch/DokoDemo-PSP-Patcher" alt="Commits"></a>
</p>

<a href="#screenshots">
<div align="center">
  <img src="https://github.com/user-attachments/assets/fbbbe89f-6f7c-42e3-9df7-bc4bd4d1acdf" width=49%>
  <img src="https://github.com/user-attachments/assets/75d22216-744a-4f1c-b305-76a6cebd77cb" width=49%>
</div>
</a>



## Overview
This project aims to make the Japanese video game "Doko Demo Issyo" (どこでもいっしょ) playable in the English language, through [fan translation](https://en.wikipedia.org/wiki/Fan_translation_of_video_games) and modding efforts. It was created for the many English-speaking fans of the Doko Demo Issyo series who can't read Japanese, as most games in the series were only released in Japan and never given an official release or localization in other countries.

[Doko Demo Issyo](https://dokodemo.fandom.com/wiki/Doko_Demo_Issyo) is a life simulation game starring cute animal (and robot) characters called [Pokepi](https://dokodemo.fandom.com/wiki/Category:Characters), who want to learn all about the human world. The game lets you choose one to live with in your virtual home, check in on them every day and teach them new words that will be repeated back to you in various conversations. It was a huge success in Japan, leading to [many sequels](https://en.wikipedia.org/wiki/Doko_Demo_Issyo#Games) and the main character [Toro Inoue](https://dokodemo.fandom.com/wiki/Toro_Inoue) becoming a [PlayStation mascot](https://www.youtube.com/watch?v=0x8Tgm9s068) and [internet meme](https://knowyourmeme.com/memes/toro-inoue-sony-cat).

Being a Japanese communication game, there is a lot of text that needs to be translated, and the game uses several proprietary [file formats](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki/File-formats) that have little documentation and are hard to modify. You can help us investigate this game and provide more Japanese-English translations by reading the [project wiki](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki) and [contributing](#contributing). All translation work is freely licensed under the [GNU General Public License v3](#license) and everyone who helped make this possible has been [credited](#credits) at the end of this page.

## Installation

> This project is still in early development. A lot of the game's text is still untranslated and will appear in Japanese. See [Progress](#progress) for parts of the game that are available in English, or [Contributing](#contributing) if you would like to help out. We hope to add more translations in the future through updates on the [Releases page](https://github.com/pumpkinhasapatch/dokodemo-psp-english/releases), and the current state of the game does not reflect the final planned project.

To play the translation, you will need an original Japanese copy of Doko Demo Issyo Portable dumped as an .iso file. It should match [these details](http://redump.org/disc/39834) on Redump. **Make sure you have the PlayStation Portable  version from 2004**, not the original PS1 version or other games like Rettsu Gakkou or Mainichi Issho (see table below). These games vary in contents and are not compatible with the translation project.

| Game title | Doko Demo Issyo / Doko Demo Issho Portable (PSP, 2004) |
|------------|--------------------------------------------------------|
| Original box art | <img alt="どこでもいっしょ「PSP」" src="https://static.wikia.nocookie.net/dokodemo/images/d/d5/5052001-01.jpg" width="200px"><img width="200px" alt="dokodemo-umd-disc-hq" src="https://github.com/user-attachments/assets/8ea73365-10c3-4528-9087-1934d9d9d95a" /> |
| Serial | UCJS 10002, UCJS 18002 |
| Version | 1.01 |
| Edition | Original, PSP the Best |
| MD5 checksum |  a7d8ff8050ac0d1fd6b0d5970eecbd8d |
| SHA256 checksum | c78d0974f660cd92c1b10a1466ac278625d38e4dd93bfb48f66f090ff7a4c119 |

If you have a real PSP console or original UMD disc, you can use Custom Firmware to dump your UMD disc to .iso, apply the translation patch on your computer, then play it directly on your PSP for the most authentic experience. See the [ConsoleMods PSP wiki](https://consolemods.org/wiki/PSP:PSP_Mods_Wiki) for more information. PSVita owners should visit https://vita.hacks.guide/ or the [Vita Mods Wiki](https://consolemods.org/wiki/Vita:Vita_Mods_Wiki). If your copy of the game does not work with the xdelta patch, try using a different copy, dumping tool or create a [manual build](#building).

### Applying xdelta patch
The English translation is shared through an xdelta patch that can be applied on top of an original copy of the game. xdelta is a binary file containing the minimal amount of changes needed to convert an original copy of Doko Demo Issyo Portable into our modified (translated) game.

You can get a stable xdelta patch from the translation project [Releases page](https://github.com/pumpkinhasapatch/dokodemo-psp-english), and apply them to your game using [xdelta patching software](#xdelta-wasm-online-patcher) like the ones below.

This is the easiest way to play Doko Demo Issyo in English, but it is difficult to make changes to the .xdelta files before applying them to your game without the use of extra software. If you would like to help edit translations or improve the code, see the [Building](#building) section below.

<img src="https://www.romhacking.net/utilities/screenshots/598screenshot1.png" align=right width=35%>

- [Online xdelta patcher](https://kotcrab.github.io/xdelta-wasm/) (Web Browser)
- [Xdelta UI](https://www.romhacking.net/utilities/598/) (Windows)
- [Delta Patcher](https://github.com/marco-calautti/DeltaPatcher) (Windows, Mac, Linux)

Choose one of these xdelta patching tools compatible with your device and download the latest .xdelta patch file from our [Releases page](https://pumpkinhasapatch/dokodemo-psp-english/releases). In the patcher set your original .iso of Doko Demo Issyo Portable as the Source File the .xdelta file you downloaded as the Patch. Click the "Apply Patch" button to combine both files and save a copy of the translated game.

If using Delta Patcher, make sure to click the settings icon and check "Backup original file".

You can also use other tools to apply .xdelta patches, however most of them are more difficult to use than the above options or have not been updated in years. We cannot guarantee support for every patching tool out there.

### Playing the translation
Once you have applied the English translation patch, you can run the output file in the [PPSSPP emulator](https://www.ppsspp.org) on most modern devices, or copy it back onto your modded PSP to play the translated Doko Demo Issyo game. If you are using PPSSPP go to the Files tab, then find your translated game ISO file or the project `build` folder to start playing. If the game doesn't work, please [contact us](#support) or you can attempt a custom build using the guide below.

## Building

The translation project uses a custom build system that modifies an original copy of Doko Demo Issyo Portable by reading the original game files and inserting our custom text and images into them. You will need an original copy of the game and a few specific Windows and Linux programs (called `tools`) to build it.

### Install dependencies

The translation project can be built on Windows 10/11 systems with [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) set up to run the Linux tool [bpar](#credits) (run `wsl --install`), and on Linux systems with `wine` and `perl` (preferably installed from your package manager).

Both build scripts also require a copy of [GimConv](https://www.psdevwiki.com/ps3/GimConv), an image conversion tool developed by Sony, to convert textures from .png to the .GIM format used by the game. It is best compatible with the version included with [RCOMage](https://github.com/kakaroto/RCOMage/releases/tag/1.1.1) that has a custom GimConv.cfg file and a couple .dll's from [Microsoft Visual C++ 2003](https://stackoverflow.com/questions/1596167/where-to-download-microsoft-visual-c-2003-redistributable). Simply download RCOMage and copy its `GimConv` folder over to `tools/GimConv/GimConv.exe` along with other files.

### Running the build script
Run `build.cmd` on Windows or `build.sh` in a supported Linux environment to apply the current translation changes to the game. The `build` folder containing the original game files will be overwritten and if it all works, you can launch the game directly from this folder in [PPSSPP](https://ppsspp.org) when finished.

#### Linux commands
```sh
# Download the translation project source code from GitHub
git clone https://github.com/pumpkinhasapatch/dokodemo-psp-english

cd dokodemo-psp-english

# Allow files like build.sh and tools/bpar to run as programs
sudo chmod -R a+xX ./*

# Install some dependencies (replace 'apt' with your package manager)
sudo apt install wine perl -y

# Attempt to patch the game based on current source files.
# Should tell you if any files are missing.
./build.sh
```

More details including how to convert your patched game folder into a disc image or .xdelta file have been moved to the [Build instructions](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki/Build-instructions) page on the project wiki.

## Progress

Not everything is complete yet, and we have focused on important parts of menus and Pokepi text. Here is a list of translated features so far:

| Feature | Progress | Notes |
|---|---|---|
| Menus | Playable | Title Screen, Player Data and In-Game Menus are mostly translated to English. [Redditor baalzeebul](https://www.reddit.com/r/PSP/comments/17op7f2/doko_demo_issho_psp_english_guide_pdf_part_1/) has made an [English PDF "guide"](https://drive.google.com/file/d/11tnhqBiwtvxKE70fE0nE1FH5B8ftfa2k/view) with some more menus translated that need to be added. |
| Keyboard | Playable | Hacked English letters into the in-game Japanese keyboard, allowing you to type 4-letter long English names on the Player Data screen. Hiragana/katakana characters may still display on the keypad buttons.
| Toro Inoue | Introduction / other | Toro's first block of text said when you start a new game has been translated, and some other bits I found in the game's files. |
| R. Suzuki | None | cms7_ has already translated a bit of the game. Need to find Hex addresses and add text from https://suzukistation.neocities.org/suzpsp and https://suzukistation.neocities.org/suzdiary |
| Jun Mihara | Introduction | Done the first block of text when you start a new game. There is more at https://suzukistation.neocities.org/junpsp |

Text not marked as "translated" is not modified by the translation patch yet and will show the original Japanese messages in-game.

## Screenshots
<div align="center">
  <img src="https://github.com/user-attachments/assets/8b4e6cc0-469d-441b-aa70-ce21587970f6" width=49% title="Patched game title screen showing the custom logo 'Doko Demo Issyo Fan Translation' and Pokepi characters running left across the screen.">
  <img src="https://github.com/user-attachments/assets/78142180-3b86-414c-a67a-3e6f98dbdaad" width=49% title="An example of the 'Enter Player Data' screen with all information filled in. The game asks for the Pokepi's name and the player's name, gender, birthday and other details used for personalization, then asks for final confirmation before starting a New Game.">
  <img src="https://github.com/user-attachments/assets/63193f1a-d314-471d-9e93-bd8daf3ca536" width=49% title="In-game screenshot showing how the Translation Project can change a Pokepi's various dialogue. Jun the rabbit is standing in the player's virtual living room saying a translated message, 'If that's okay, I'll always be here to look out for you!'">
  <img src="https://github.com/user-attachments/assets/45f62a5d-1495-4ebd-84ba-0c236a3fc86d" width=49%>
</div>

## Support

If you need help patching the game or using the build scripts, please [read the project wiki](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki) or join the [Toro's Friend Dungeon](https://discord.gg/3EYqGKpqNG) Discord server and ask us for help in the **#translation-proj-chat** channel. You will need to verify yourself to enter the chat by writing a short introduction and possibly [connect another account to Discord](https://discord.com/blog/connected-accounts-functionality-boost-linked-roles).

If you are trying to dump an original Doko Demo Issyo game disc with your PSP console for use with this project, refer to the Custom Firmware guides at [ConsoleMods.org](https://consolemods.org/wiki/PSP:PSP_Mods_Wiki), [PSPunk](https://www.pspunk.com/) or ask somewhere like the [PSP Homebrew Community](https://discord.gg/bePrj9W) Discord server.

If you have any feedback or would like to report a bug, you can contact pumpkinhasapatch through the Toro's Friend Dungeon Discord or this project's [GitHub Issues](https://github.com/pumpkinhasapatch/dokodemo-psp-english/issues) or [Discussions](https://github.com/pumpkinhasapatch/dokodemo-psp-english/discussions) page (GitHub account required).

## Contributing

Doko Demo Issyo is a text-focused game with thousands of Japanese messages that need to be translated for this project to work. We could really use your help in searching for new data in the game's files and providing accurate Japanese-English translations.

Documentation about the game is provided on [our wiki](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki), and you can [create an issue](https://github.com/pumpkinhasapatch/dokodemo-psp-english/issues/new) if you find any bugs or problems with translated text, or open a [pull request](https://github.com/pumpkinhasapatch/dokodemo-psp-english/pulls/new) if you have edited the code in this repository with new fixes or translations.

## Credits

- **[pumpkinhasapatch](https://github.com/pumpkinhasapatch)** - Build script and Atlas script programming, project documentation, Toro's messages and dialogue, quality assurance.
- **cms7_** - Creator of the [Suzuki Station website](https://suzukistation.neocities.org) and translator of some of Suzuki and Jun's messages and diary entries from the game.
- **[swagtoy](https://swag.toys)** - Developed the [ddi-tools](https://github.com/pumpkinhasapatch/ddi-tools) set of scripts including the **bpar** archiving tool for the game's DATA.BP file, which made it possible to read and modify most of the game's data.

### Dependency programs used by build scripts:
The following programs are included in the `tools` folder or required for the `build.cmd` and `build.sh` scripts to work. They are used under a different license not covered by the GPL. These programs are also open to changes (except GimConv) and the source code can be found on the linked webpages:

- [Atlas v1.12 by Steve Monaco "Klarth"](https://github.com/stevemonaco/Atlas) (older versions at [Romhacking.net](https://www.romhacking.net/utilities/224)) - A text patching tool and scripting language to insert new text over the Doko Demo Issyo game data.
- [abcde by abw](https://www.romhacking.net/utilities/1392/) - A cross-platform alternative to Atlas with more features and better error reporting, written in Perl script.
- bpar by swagtoys - https://code.neko.rehab/ddi-tools/file (dead link, [archived](https://github.com/pumpkinhasapatch/ddi-tools)) - To extract and insert files from the game's proprietary DATA.BP archive.
- Sony's GimConv - A freeware/proprietary program for Windows developed by Sony for converting PNG images to the GIM format the game uses. GimConv is not included with the Patcher due to copyright reasons, and you may need to add it to the `tools` folder yourself.

### Other people who indirectly helped:
- [Suzuki Log](https://suzukilog.jimdofree.com/) for transcribing some of Suzuki's text from the game into Japanese.
- [Jisho.org](https://jisho.org/about) and [Yomitan](https://github.com/themoeway/yomitan) developers for creating simple interfaces to browse digital Japanese-English dictionaries, used to look up tricky words and sentences when translating the game.
- [JMdict](https://www.edrdg.org/wiki/index.php/JMdict-EDICT_Dictionary_Project), [KANJIDIC](https://www.edrdg.org/wiki/index.php/KANJIDIC_Project) and others for providing the large databases of information on Japanese words powering software like Jisho and Yomitan.
- Clyde Mandelin "Tomato" for giving the world the [Mother 3 Fan Translation](https://mother3.fobby.net) and [Legends of Localization website](https://legendsoflocalization.com/), which laid the foundation of what good fan translation should be like.
- [RikuKH3](https://gbatemp.net/threads/steins-gate-anyone-familiar-with-this-game-engine.346275/page-2#post-5065600) for the [Stein's Gate PSP Translation](https://github.com/BASLQC/steins-gate-psp-patch/blob/master/data/shiftjis.tbl) which gave inspiration and the shiftjis.tbl file used by Atlas/abcde for text encoding. Some changes were made to it in our project to work with abcde and Doko Demo Issyo Portable.
- [baalzeebul on Reddit](https://www.reddit.com/r/PSP/comments/17op7f2/doko_demo_issho_psp_english_guide_pdf_part_1/) for some translations in their "Doko Demo Issho English Translation Guide" (mainly for the "Teach word" menus).
- Amit Merchant for the README.md header/template from their project, [Markdownify](https://github.com/amitmerchant1990/electron-markdownify). Retrieved from the [GitHub README Templates](https://www.readme-templates.com) website.

### Fonts
These are the fonts used for custom images in the `textures` folder:
- DokoitsuFontv3 - Official Doko Demo Issyo font used in many menu textures.
- Montserrat - `GUI/TITLE/BEXIDELOGO.png`
- Montserrat Bold - `GUI/TITLE/SCELOGO.png`
- Stanberry 14pt - `GUI/TITLE/NAVI_WORD*.png`
- [Dashness](https://www.fontspace.com/dashness-font-f15326) 22pt - `GUI/TITLE/SETCH_TITLE_*.png` - Freeware, Non-Commercial font license.

Please contact the repository owner if you have helped out and would like to be added to the credits or have your credit changed.

## License

The code, text and images in this repository (except contents of the `tools` folder and copyrighted images from the game) are available under version 3 or later of the [GNU General Public License](./LICENSE-GPL.txt) ("the GPL"). You can freely use and edit any source code included in this repository including build scripts and content of the `patches` and `textures` folders, but if you make changes and release your own version, in binary or source form, you must always share the modified source code, keep your code under a GPL-compatible license and follow all other terms of the GPL.

You can apply our patch to the game for private use if you own the original UMD game disc, but Sony's copyright still applies to the original game files even when using our Copyleft translation patches, and a full copy of the game including our patches should never be shared with other people as it would break Sony's "All Rights Reserved" copyright and the GPL license's rules against [inclusion in a proprietary system](https://www.gnu.org/licenses/gpl-faq.en.html#GPLInProprietarySystem). You can contact pumpkinhasapatch if you need to make an exception to the GPL to use our project.

If you have made any changes to the translation project and share a binary copy made with it such as an [xdelta patch](#applying-xdelta-patches), you must also share your build scripts and .txt and .png files used to create it. This makes sure other users can continue to improve the the translation project and make their own versions of it.

### Disclaimer
This translation patch is a hobby project created from many hours of work by English-speaking fans of the Doko Demo Issyo series. It is not an official product developed by, associated with, approved, nor endorsed by Sony Interactive Entertainment or BeXide, Inc.. PumpkinhasaPatch is not responsible for any related content shared outside of the [upstream GitHub repository](https://github.com/pumpkinhasapatch/dokodemo-psp-english) or PumpkinhasaPatch accounts, and any questions or concerns should be directed to the uploader of the content.

**We do not endorse piracy** - it puts us at risk of developing the translation project and hurts the original developers at BeXide. If any new Doko Demo Issyo games or merchandise are ever made available in your country, please support the original creators of the series by purchasing them. Buying secondhand or unofficial products does not support creators, and all your money is probably going to some random online seller.
