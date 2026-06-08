<h1 align="center">
  <br>
  <img src="textures/GUI/TITLE/TITLE.png" alt="Doko Demo Issyo PSP English Translation Project">
  <br>
</h1>

<h4 align="center">A work-in-progress <a href="https://en.wikipedia.org/wiki/Fan_translation_of_video_games">English translation</a> <a href="https://en.wikipedia.org/wiki/Patch_(computing)">patch</a> for <a href="https://www.ign.com/games/doko-demo-issyo-psp">Doko Demo Issyo</a> on the PlayStation Portable.</h4>

<p align="center">
  <a href="#installation">Installation</a> -
  <a href="#building">Building</a> -
  <a href="#contributing">Contributing</a> -
  <a href="#credits">Credits</a> -
  <a href="#license">License</a>
  <br>
  Game help and development information has moved to the <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki">Project Wiki</a>.
</p>

<p align="center">
  <a href="https://pumpkin.moe/discord"><img src="https://img.shields.io/discord/1454051443559497822?logo=discord&logoColor=white&color=5865F2&label=Fan%20Translation%20chat" alt="Discord"></a>
  <a href="https://discord.gg/3EYqGKpqNG"><img src="https://img.shields.io/discord/824319065773441045?logo=discord&logoColor=white&color=5865F2&label=Toro's%20Friend%20Dungeon" alt="Discord"></a><br>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/releases"><img src="https://img.shields.io/github/downloads/pumpkinhasapatch/dokodemo-psp-english/total" alt="Releases"></a>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/issues"><img src="https://img.shields.io/github/issues/pumpkinhasapatch/dokodemo-psp-english" alt="Issues"></a>
  <a href="https://github.com/pumpkinhasapatch/dokodemo-psp-english/commits/dev"><img src="https://img.shields.io/github/last-commit/pumpkinhasapatch/DokoDemo-PSP-Patcher" alt="Commits"></a>
  <a href="https://ko-fi.com/pumpkinhasapatch"><img src="https://img.shields.io/badge/support_me_on-ko_fi-red?logo=ko-fi" alt="Ko-Fi"></a>
</p>

<a href="#screenshots">
<div align="center">
  <img src="https://github.com/user-attachments/assets/fbbbe89f-6f7c-42e3-9df7-bc4bd4d1acdf" width=49%>
  <img src="https://github.com/user-attachments/assets/75d22216-744a-4f1c-b305-76a6cebd77cb" width=49%>
</div>
</a>

## Installation

> This project is still in early development. A lot of the game's text is still untranslated and will appear in Japanese. See the [Contributing](#contributing) section if you would like to help out. We hope to add more translations in the future through updates on the [Releases page](https://github.com/pumpkinhasapatch/dokodemo-psp-english/releases), and the current state of the game does not reflect the final planned project.

To play the translation, you will need an original Japanese copy of Doko Demo Issyo Portable dumped as an .iso file. It should match [these checksums](http://redump.org/disc/39834) on Redump. **Make sure you have the PlayStation Portable  version from 2004**, not other games like the original PS1 disc or Rettsu Gakkou which are incompatible.

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
The English translation is shared through xdelta patches. xdelta is a binary file containing the minimal amount of changes needed to convert an original copy of Doko Demo Issyo Portable into our modified (translated) game.

You can get the latest xdelta patch from the translation project [Releases page](https://github.com/pumpkinhasapatch/dokodemo-psp-english), and apply them to your game using xdelta patching software like the ones below.

This is the easiest way to play Doko Demo Issyo in English, but it is difficult to make changes to the .xdelta files before applying them to your game without the use of extra software. If you would like to help edit translations or improve the code, see the [Building](#building) section below.

<img src="https://www.romhacking.net/utilities/screenshots/598screenshot1.png" align=right width=35%>

- [Online xdelta patcher](https://kotcrab.github.io/xdelta-wasm/) (Web Browser)
- [Xdelta UI](https://www.romhacking.net/utilities/598/) (Windows)
- [Delta Patcher](https://github.com/marco-calautti/DeltaPatcher) (Windows, Mac, Linux)

Choose one of these xdelta patching tools compatible with your device and download the latest .xdelta patch file from our [Releases page](https://pumpkinhasapatch/dokodemo-psp-english/releases). In the patcher set your original .iso of Doko Demo Issyo Portable as the Source File the .xdelta file you downloaded as the Patch. Click the "Apply Patch" button to combine both files and save a copy of the translated game.

If using Delta Patcher, make sure to click the settings icon and check "Backup original file", or your original game ISO will be overwritten. Keep a copy of your original game ISO for future patch releases.

You can also use other tools to apply .xdelta patches, however most of them are more difficult to use than the above options or have not been updated in years. We cannot guarantee support for every patching tool out there.

### Playing the translation
Once you have applied the English translation patch, you can run the output file in the [PPSSPP emulator](https://www.ppsspp.org) on most modern devices, or copy it back onto your modded PSP to play the translated Doko Demo Issyo game. If you are using PPSSPP go to the Files tab, then find your translated game ISO file or the project `build` folder to start playing. If the game doesn't work, please [contact us](https://pumpkin.moe/discord) or you can attempt a custom build using the guide below.

#### Controls
- Circle (X on keyboard): select/talk
- Cross (Z on keyboard): cancel
- Arrow keys: select letter/option
- Right arrow (when idle): open menu

See the [instruction booklet](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki/Official-game-manual) for a full guide on how to play Doko Demo Issyo PSP.

## Building

The translation project uses a custom build system that modifies an original copy of Doko Demo Issyo PSP by reading the original game files and inserting our custom text and images into them. You will need an original copy of the game and our Windows/Linux scripts to build the game.

### Windows

**Requirements:** Windows 10/11, [Python 3](https://www.python.org/downloads) installed to PATH.

**Optional:** [PPSSPP emulator](https://ppsspp.org), UMDGen (to make iso), Delta Patcher (to make xdelta).

1. Download the translation source code from this page or run `git clone https://github.com/pumpkinhasapatch/dokodemo-psp-english.git`.
2. Place your original unmodified game iso in the project folder. 
3. In Command Prompt or PowerShell, run `.\build.cmd`.
4. The game files will be extracted to the `build` folder and modified, and if it all works, you can launch the game directly from this folder in [PPSSPP](https://ppsspp.org) when finished.

### Linux

**Requirements:** [Wine](https://winehq.org), Perl.


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

### MacOS

The build script has not been tested on MacOS. You may be able to run the Windows or Linux script on MacOS with some changes or compatibility layers. If you are a Mac user and would like to improve compatibility please create a pull request or join our [Discord server](https://pumpkin.moe/discord).

### Creating iso/xdelta files
For how to convert your patched game folder into a disc image or .xdelta file, please read the [Build instructions](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki/Build-instructions) on the project wiki.

## Contributing

Doko Demo Issyo is a text-focused game with thousands of Japanese messages that need to be translated for this project to work. We could really use your help in searching for new data in the game's files and providing accurate Japanese-English translations.

If you are a skilled programmer or Japanese reader, Join our [Discord server](https://pumpkin.moe) to talk with the translation team and learn more.

On GitHub, documentation is provided on [our wiki](https://github.com/pumpkinhasapatch/dokodemo-psp-english/wiki), and you can [create an issue](https://github.com/pumpkinhasapatch/dokodemo-psp-english/issues/new) if you find any bugs or problems with translated text, or fork and open a [pull request](https://github.com/pumpkinhasapatch/dokodemo-psp-english/pulls/new) if you have edited the code in this repository with new fixes or translations.

You can also provide financial support to pumpkinhasapatch. I spend a lot of time working on this game and writing documentation, and this allows me to keep going. Supporters get a special role in our Discord server, access to exclusive content and a personal thank you message.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/G2G21RWPXP)

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

Please contact the repository owner if you have helped out and would like to be added to the credits or have your credit changed.

## License

The code, text and images in this repository (except contents of the `tools` folder) are available under the [GNU General Public License](./LICENSE-GPL.txt) version 3 or later.

### Disclaimer
This translation patch is a hobby project created from many hours of work by English-speaking fans of the Doko Demo Issyo series. It is not an official product developed by, associated with, approved, nor endorsed by Sony Interactive Entertainment or BeXide, Inc.

**We do not endorse piracy** - it hurts legitimate developers and puts us at risk of developing the translation project. If official Doko Demo Issyo games or merchandise are ever made available in your country, please support the original creators of the series by purchasing them.
