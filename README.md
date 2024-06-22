# Doko Demo Issyo PSP Patcher & Fan Translation Project

A complete text translation tool for the Japan-only simulation game, Doko Demo Issyo Portable.

- [Introduction](#introduction)
- [Included goodies](#included-goodies)
- [What you will need](#what-you-will-need)
- [Patcher usage](#patcher-usage)
- [Screenshots](#screenshots)
- [Contributions](#contributions)
- [Licensing](#licensing)

## Introduction
### What is Doko Demo Issyo?
どこでもいっしょ (meaning "Together Everywhere") is a video game franchise made popular in Japan that started on the original PlayStation in 1999.

The first game in the series lets you control the life of Toro Inoue, a cute white cat with a clay-like body and his Pocket Pals (Pokepi), who want to learn how to be like a human. Interact with them each day and teach them new words that will appear around the game and be said back to you in bizarre conversations.

> (a screenshot or two to keep people reading)

If you want to learn more, you should watch [dodgykebaab's YouTube video](https://www.youtube.com/watch?v=0x8Tgm9s068) as he shows footage of each game and explains the series' history. (Skip to 23 minutes for the PSP remake.)

### Series Controversy
Doko Demo Issyo is a great series of games, but its creators have focused on a niche Japanese market and had trouble with or lack of interest in releasing the games in English.

Nearly all games have been locked to Japanese PlayStation consoles for over the last two decades, and none have ever been released in America, Europe or Australia.

This means we have to import stuff from Japan and do some hard work to play any Doko Demo game in most parts of the world, and even then they are only displayed in the Japanese language, which causes more headaches for overseas players.

The latest game in the series was a [mobile puzzle game](https://dokodemo.fandom.com/wiki/Toro_and_Friends:_Onsen_Town) that had its servers shut down in 2021, and no new games have been released for the currently selling PS4 or PS5 consoles, even in Japan. Who would want to see the series end like this?

![](https://gmedia.playstation.com/is/image/SIEPDC/dokodemoissyo-character-all-02-ja-01mar22?$1600px--t$)

### Partial solution (this project!)
Frustrated with Sony's ignorance, I started this project in February 2024 just before the series' 25th Anniversary as a love letter to the Doko Demo Issyo series.

DokoDemo-PSP-Patcher takes the PlayStation Portable remake of the first Doko Demo Issyo game, and lets us replace text strings in certain parts of the game files with anything we want!

> (pumpkin development screenshot)

By taking apart and searching the game files in a Hex Editor, I was able to locate most of the Japanese text, copy it into Google Translate one string at a time, fix any mistakes with my fluent English skills and write some code that can put it back into a working game. It is a tedious process but the results are impressive:

> (translated title screen save message)

The tools might not be enough to translate the entire game yet or solve all problems with the Japanese-English transition, but it is enough to give anyone interested in the series a refreshed Toro game to explore and tinker with.

## Included goodies
- Detailed English translation of most in-game text made by Doko Demo fans
- Guided graphical patcher window for new users and automated build scriptSeparate options to change Pokepi speech bubbles, menu text and keyboard
- Translation script editor - Improve existing text or add another language!

### Dependencies
The following versions of dependency applications are included for user convenience under a different license. These programs are also open to changes and the source code can be found on the linked page:

- Atlas V1.11 8/10/2010 - https://www.romhacking.net/utilities/224 - Insert new text data over the Doko Demo game script files.
- bpar by nekobit - https://code.neko.rehab/ddi-tools/file - To extract and insert files from the game's DATA.**BP ar**chive.
- GimConv
- zenity v0.10.11 win32 - https://github.com/ncruces/zenity - Go port of the popular [dialog box manager](https://help.gnome.org/users/zenity/stable/) to display pretty windows.


## What you will need
- A Windows 10/11 computer with [Windows Subsystem for Linux](https://www.howtogeek.com/744328/how-to-install-the-windows-subsystem-for-linux-on-windows-11/) enabled (to run bpar)

- A Japanese copy of [Doko Demo Issyo for PlayStation Portable](https://duckduckgo.com/?q=doko+demo+issyo+psp) (*NOT the PS1 release or other PSP game with a pink logo*). The correct box art looks like this:

![どこでもいっしょ PSP box art](https://i.ebayimg.com/images/g/BKIAAOSwG8tgMWiA/s-l960.jpg)

> Note: You may have an newer copy if you are dumping your rom, the SHA256 file hash of the .ISO ROM must be ``c78d0974f660cd92c1b10a1466ac278625d38e4dd93bfb48f66f090ff7a4c119`` in order for the patching process to work correctly. 

- Any model/region PSP console (except PSP Go) running [Custom Firmware](https://www.pspunk.com/psp-cfw), to copy files from the game disc onto your computer and apply the new language. You may also be able to play the translated game on your PSP after.

> You could buy an original copy of the game from an online seller for about $30 AUD, but any profit goes to the seller and does not support Sony or BeXide, the creators of this great series. I would also suggest buying official merch from the [PlayStation Japan store](https://www.playstation.com/ja-jp/local/official-products/character-goods/dokodemoissyo) to show your love and maybe get a new game developed for modern platforms. ([Translated site](https://www-playstation-com.translate.goog/ja-jp/local/official-products/character-goods/dokodemoissyo/?_x_tr_sl=auto&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=wapp), purchase links may not work.)

## Patcher usage
You must present a Japanese copy of Doko Demo Issyo Portable as an uncompressed folder or ISO file during the patching process to get a working game translation. The graphical patcher and internet search can help you do this.

The game files should be extracted from the disc and placed in the build folder, like below. You can also run the game from this directory when patching is complete.
```
DokoDemo-PSP-Patcher\build\
├───UMD_DATA.BIN
└───PSP_GAME
    ├───ICON0.PNG
    ├───SYSDIR
    │   └───BOOT.BIN
    └───USRDIR
        ├───data
        │   ├───DATA.BP
        │   └───sound
        │       ├───bgm
        │       └───se
        └───prx
```

### Guided graphical patcher
`patcher-gui.cmd` Work in progress

### Automated build script
`build.cmd` is a Windows Command Prompt script that prepares all patches and modifications you have made and automatically creates a translated copy of the game in the `build` folder without user input.

Command flags and file checking may be added to the program later to customize what gets patched and make repeated testing faster.

## Screenshots
### Patcher-GUI window


### English translated game


## Contributions
[PumpkinhasaPatch](https://github.com/pumpkinhasapatch) - batch script programming, project founder, translation checking

## Licensing
This project is covered by version 3 or later of the [GNU General Public License](./LICENSE-GPL.txt) and [GNU Lesser General Public License](./LICENSE-LGPL.txt). This means any source code and translation files included in this repository are free for anyone to use or edit, but modifications to them must be made available to other people when you create Patch Files or changes, to let other people learn from and improve on the project and create their own version of the game.

"Patch Files" are small, pre-built binary files with an extension like .bps or .xdelta that contain the minimal amount of changes needed to transform an original Japanese copy of Doko Demo Issyo Portable into an English-translated modification. These can be freely shared and distributed over the internet as long as they only contain code and assets from the Translation Project, without other copyrighted content from the original game. Patch Files must also be shared with the same patching tools and source code used to create them.

Full disc images or folders containing the original game files contain content copyrighed by Sony/Bexide, and are not covered by an open source license. These should NOT be shared with other people, as it may break laws and get you into legal trouble, and it is usually possible to create a Patch File from a modified version of the game. PumpkinhasaPatch is not responsible for Combined Works shared outside of [this GitHub page](https://github.com/pumpkinhasapatch/dokodemo-psp-patcher), and any complaints should be directed to the uploader of the Combined Work or site hosting it.

Please understand what you can do with this project carefully, you wouldn't want to make a pumpkin cry now...

### You can do these things
- Use any provided or generated Patch Files and documentation to modify your own copy of Doko Demo Issyo Portable for private personal use.
- Make changes to the Patcher source code or included game assets, and release your version of the code for others to improve on or patch their copy of Doko Demo Issyo Portable with.
- Create and share a minimal game patch or binary diff using a tool like [xdelta](https://github.com/jmacd/xdelta-gpl), along with the Patcher and any modifications made to it, for people to enjoy or make changes to.
- Tell other people about the translation project and share screenshots or gameplay footage.

### But don't do this
- **Do not include the `build`, `export`, `import` or `tools` directories when sharing copies of the Patcher.** These folders contain decompressed game files and software covered by different license terms that could get you into trouble.
- Do not share full copies of the game files or ISO, including a mix of our copyleft Translation patches and Sony/BeXide's copyrighted software or assets. All players will have to find an original Japanese copy of the game and apply any patches themselves.
- Do not release a binary patch file or diff **without** an easily accessible copy of the Patcher tool or other source files used to create it. Others should be able to create the same patch file using tools and instructions freely available on the internet.

> The use of trademarks, characters and protected works in this project are used for Research and study, Text and data mining, reference and identification or other purposes excepted by the [U.S. Fair Use doctrine](https://en.wikipedia.org/wiki/Fair_use#Fair_use_in_particular_areas), [Copyright law of Japan](https://en.wikipedia.org/wiki/Copyright_law_of_Japan#Limitations_and_exceptions) and [Australian fair dealing](https://en.wikipedia.org/wiki/Fair_dealing#Australia) jurisdiction.
