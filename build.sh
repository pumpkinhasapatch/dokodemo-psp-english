#!/bin/sh
# Stop when a command returns a non zero status
set -e

# Doko Demo Issyo PSP English Translation Project - Linux build script
# Copyright (C) 2024 PumpkinhasaPatch <https://github.com/pumpkinhasapatch>

# Change to the directory where this script is stored so every relative path
# below works no matter where the script was started from
baseDir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$baseDir"

# Optional ISO path. If omitted, look for an .iso in the project folder,
# otherwise use the game files already in build/.
iso=${1:-}

# MD5 hash from an original Doko Demo Issyo PSP ISO http://redump.org/disc/39834/
expectedhash=a7d8ff8050ac0d1fd6b0d5970eecbd8d

# Print the MD5 checksum of a file using whichever tool this system provides
file_md5() {
  if command -v md5sum > /dev/null 2>&1; then
    md5sum "$1" | cut -d ' ' -f 1
  elif command -v md5 > /dev/null 2>&1; then
    # BSD/MacOS
    md5 -q "$1"
  elif command -v openssl > /dev/null 2>&1; then
    openssl dgst -md5 "$1" | sed 's/.*= *//'
  else
    return 1
  fi
}

# Compare a game ISO against the checksum of an original, unmodified disc image.
# Returns 0 when the build may continue, 1 when the user wants to stop.
verify_iso() {
  printf 'Checking %s...\n' "$1"

  if ! filehash=$(file_md5 "$1"); then
    echo "No MD5 program was found (md5sum, md5 or openssl), skipping checksum verification."
    echo " "
    return 0
  fi

  echo "$filehash"

  if [ "$filehash" = "$expectedhash" ]; then
    echo "Checksum is correct"
    echo " "
    return 0
  fi

  echo "The ISO file was found but the checksum is incorrect."
  echo "You may have the wrong game or a modified ISO that was already run through the patcher."
  printf 'Make sure %s is an original, unmodified copy of Doko Demo Issyo for PSP.\n' "$1"
  echo "Other games like Doko Demo Issyo: Rettsu Gakkou or Doko Demo Issyo for PS1 are not supported."
  echo " "

  # Only ask when the script is run interactively, otherwise stop
  if [ -t 0 ]; then
    printf 'Continue anyway? (may cause errors) [y/n] '
    read -r yn
    echo " "
    case "$yn" in
      [Yy]*) return 0 ;;
    esac
  fi

  return 1
}

echo ========================================================
echo "     ~ Doko Demo Issyo PSP Patcher (Shell script) ~"
echo https://github.com/pumpkinhasapatch/dokodemo-psp-english
echo ========================================================
echo ""


if [ ! -d build ]; then mkdir build; fi
if [ ! -d extract ]; then mkdir extract; fi
if [ ! -d insert ]; then mkdir insert; fi
if [ ! -d patches ]; then mkdir patches; fi
if [ ! -d textures ]; then mkdir textures; fi
if [ ! -d tools ]; then mkdir tools; fi

error=0
echo Checking for required files/programs...

# Report a missing program and tell the user how to install it.
# Every check runs before the build folder is touched so the script can stop
# and list everything that is missing in one go.
missing_program() {
  printf '%s was not found. %s\n' "$1" "$2"
  echo " "
  error=1
}

# Download a file into the tools folder. Tools that can be fetched legally and
# without root are downloaded automatically, so most users only need to install
# Wine themselves. Returns non-zero when the download is not possible.
# Usage: fetch_tool <url> <output file> <description>
fetch_tool() {
  if ! command -v curl > /dev/null 2>&1; then
    return 1
  fi

  printf 'Downloading %s...\n' "$3"
  # -f fails on HTTP errors instead of saving an error page, -L follows
  # redirects, and the file is only moved into place once it is complete
  if curl -fL --retry 2 "$1" -o "$2.part"; then
    mv -f "$2.part" "$2"
    return 0
  fi

  rm -f "$2.part"
  printf 'Could not download %s.\n' "$3"
  return 1
}

# Wine runs the Windows tools this project depends on (Atlas and GimConv),
# so without it the build cannot do anything useful
if ! command -v wine > /dev/null 2>&1; then
  missing_program "Wine" "It is needed to run Atlas and GimConv. Install it using 'sudo apt install wine' or your package manager."
fi

# bpar reads and writes the game's DATA.BP archive. The source code is included
# in this repository, so it can be compiled automatically when a C compiler
# is available.
if [ ! -f ./tools/bpar/bpar ] && [ -f ./tools/bpar/bpar.c ]; then
  for compiler in cc gcc clang; do
    if command -v "$compiler" > /dev/null 2>&1; then
      echo Compiling tools/bpar/bpar.c...
      # bpar prints warnings while compiling that are safe to ignore
      if "$compiler" ./tools/bpar/bpar.c -O0 -g -o ./tools/bpar/bpar 2>/dev/null; then
        chmod +x ./tools/bpar/bpar
      fi
      break
    fi
  done
fi

if [ ! -f ./tools/bpar/bpar ]; then
  echo "bpar is missing (needed to read/write to the game's DATA.BP file)."
  echo "Its source code is included, so install a C compiler such as gcc and run"
  echo "this script again, or build it yourself with 'cc tools/bpar/bpar.c -O0 -g -o tools/bpar/bpar'."
  echo " "
  error=1
fi

# GimConv is proprietary Sony freeware that cannot be redistributed or
# downloaded automatically, so the user has to supply it themselves
if [ ! -f ./tools/GimConv/GimConv.exe ]; then
  mkdir -p ./tools/GimConv
  echo "GimConv.exe is missing (needed to convert the textures to the game's GIM format)."
  echo "It is proprietary Sony software, so this script cannot download it for you."
  echo "Get it from the RCOMage release at https://github.com/kakaroto/RCOMage/releases/tag/1.1.1"
  echo "and place GimConv.exe and its files in the tools/GimConv/ folder."
  echo "See tools/GimConv/README.md for more details."
  echo " "
  error=1
fi

# 7-Zip extracts the game ISO and the Atlas download below.
# It is downloaded first because the other tools need it.
if [ ! -f ./tools/7zip/7zz ]; then
  mkdir -p ./tools/7zip
  if fetch_tool "https://github.com/ip7z/7zip/releases/download/24.08/7z2408-linux-x64.tar.xz" \
       ./tools/7zip/7zip.tar.xz "7-Zip 24.08"; then
    if command -v tar > /dev/null 2>&1; then
      tar -xf ./tools/7zip/7zip.tar.xz -C ./tools/7zip
    fi
    rm -f ./tools/7zip/7zip.tar.xz
  fi
fi

if [ ! -f ./tools/7zip/7zz ]; then
  echo "7-Zip is missing (needed to extract the game ISO)."
  echo "Download the Linux version from https://www.7-zip.org/download.html"
  echo "and place the 7zz program in the tools/7zip/ folder."
  echo " "
  error=1
fi

# Use Atlas through Wine to apply the project's text patches.
# Atlas is free software, so it can be downloaded automatically.
if [ ! -f ./tools/Atlas/Atlas.exe ] && [ -f ./tools/7zip/7zz ]; then
  mkdir -p ./tools/Atlas
  if fetch_tool "https://github.com/stevemonaco/Atlas/releases/download/v1.12/Atlas.v1.12.zip" \
       ./tools/Atlas/atlas.zip "Atlas v1.12"; then
    # The zip stores the files in an Atlas/ folder, so extract and move them up
    ./tools/7zip/7zz x -y -o./tools/Atlas ./tools/Atlas/atlas.zip > /dev/null 2>&1
    if [ -f ./tools/Atlas/Atlas/Atlas.exe ]; then
      cp -f ./tools/Atlas/Atlas/Atlas.exe ./tools/Atlas/Atlas.exe
    fi
    rm -rf ./tools/Atlas/atlas.zip ./tools/Atlas/Atlas
  fi
fi

if [ ! -f ./tools/Atlas/Atlas.exe ]; then
  echo "Atlas.exe is missing (needed to insert the translated text)."
  echo "Download it from https://github.com/stevemonaco/Atlas/releases"
  echo "and place Atlas.exe in the tools/Atlas/ folder."
  echo " "
  error=1
fi

# pngquant reduces the textures to an indexed palette before GimConv converts
# them, which keeps the GIM files the same size as the originals.
# Prefer a native pngquant and fall back to the bundled Windows build via Wine.
# pngquant is free software with an official static Linux build, so download it
# when it is not installed. This avoids needing Wine for the image conversion.
if ! command -v pngquant > /dev/null 2>&1 &&
   [ ! -f ./tools/pngquant/pngquant ] &&
   [ ! -f ./tools/pngquant/pngquant.exe ]; then
  mkdir -p ./tools/pngquant
  if fetch_tool "https://pngquant.org/pngquant-linux.tar.bz2" \
       ./tools/pngquant/pngquant.tar.bz2 "pngquant for Linux"; then
    if command -v tar > /dev/null 2>&1; then
      # The program sits at the root of this archive
      tar -xf ./tools/pngquant/pngquant.tar.bz2 -C ./tools/pngquant
      if [ -f ./tools/pngquant/pngquant ]; then
        chmod +x ./tools/pngquant/pngquant
      fi
    fi
    rm -f ./tools/pngquant/pngquant.tar.bz2
  fi
fi

if command -v pngquant > /dev/null 2>&1; then
  pngquant_cmd="pngquant"
elif [ -x ./tools/pngquant/pngquant ]; then
  # Use an absolute path because the conversion runs from the textures folder
  pngquant_cmd="$baseDir/tools/pngquant/pngquant"
elif [ -f ./tools/pngquant/pngquant.exe ]; then
  pngquant_cmd="wine $baseDir/tools/pngquant/pngquant.exe"
else
  mkdir -p ./tools/pngquant
  echo "pngquant is missing (needed to reduce the texture palette before GIM conversion)."
  echo "Download it from https://pngquant.org and place the program in tools/pngquant/,"
  echo "or install it with your package manager (for example 'sudo apt install pngquant')."
  echo " "
  error=1
fi

# Standard utilities the script calls directly. These are normally installed
# on any Linux system, but check them so the user gets a clear message
# instead of a confusing failure in the middle of the build.
if ! command -v find > /dev/null 2>&1; then
  missing_program "find" "It is needed to locate the texture files. Install the 'findutils' package."
fi

if ! command -v date > /dev/null 2>&1; then
  missing_program "date" "It is needed to write the build date into the game title. Install the 'coreutils' package."
fi

# Stop before touching the build folder if any program or file is missing,
# so the user can install everything that was listed above in one go.
# Use a POSIX-compatible numeric comparison because this script runs with sh.
if [ "$error" -eq 1 ]; then
  echo "Some required programs or files are missing. Please install them and run the build script again."
  exit 1
fi

# Look for a game ISO in the project folder when none was passed in
if [ -z "$iso" ]; then
  for found_iso in ./*.iso; do
    [ -f "$found_iso" ] || continue
    iso=$found_iso
    break
  done
fi

if [ -z "$iso" ]; then
  echo Command argument is empty. Use a Dokodemo UMD .iso file with './build.sh path/to/ddipsp.iso' or extract it to the 'build' folder to apply game patches.
  echo " "

  if [ ! -f ./build/PSP_GAME/USRDIR/data/DATA.BP ]; then
    echo "Game files are missing from the 'build' folder or are not from Doko Demo Issyo."
    echo "Please extract your game ISO and place the PSP_GAME folder and UMD_DATA.BIN inside the 'build' folder."
    echo "You can use PeaZip, 7-Zip, Windows Explorer and many other programs to open or extract an ISO."
    echo "Note that some Linux software extracts the game with lowercase file names which will not work."
    echo " "
    exit 1
  else
    echo Patching on top of existing build folder. You should delete the build folder first if your game is corrupted.
  fi
elif [ -f "$iso" ]; then
  # Stop if the ISO is not an original, unmodified copy of the game
  if ! verify_iso "$iso"; then
    exit 1
  fi

  # Clear the folder from previous builds so old or corrupted game files
  # are never patched twice
  echo Clearing the build folder from previous builds
  rm -rf build
  mkdir build

  echo Trying to extract game into build folder
  # Extract from the project directory so both relative and absolute ISO paths work
  # Quote the path to preserve spaces in filenames
  ./tools/7zip/7zz x -y -obuild "$iso"
else
  printf 'ISO file not found: %s\n' "$iso" >&2
  exit 1
fi

# # Verify the expected game files before modifying the extracted build
for file in \
  build/PSP_GAME/USRDIR/data/DATA.BP \
  build/PSP_GAME/SYSDIR/BOOT.BIN \
  build/PSP_GAME/PARAM.SFO
do
  if [ ! -f "$file" ]; then
    printf 'Required game file is missing: %s\n' "$file" >&2
    exit 1
  fi
done

echo All checks passed successfully.
echo " "

# Replace game artwork that appears on the XMB/PPSSPP menu.
# -f overwrites the original files extracted from the game ISO.
echo Replacing game icon...
cp -f xmb/ICON0.png build/PSP_GAME/ICON0.PNG
cp -f xmb/PIC0.png build/PSP_GAME/PIC0.PNG
# Animated game icon made with PSMF Stream Composer Suite
cp -f xmb/ICON1.PMF build/PSP_GAME/ICON1.PMF

echo Writing patches/boot.txt to build/PSP_GAME/SYSDIR/BOOT.BIN...
wine tools/Atlas/Atlas.exe build/PSP_GAME/SYSDIR/BOOT.BIN patches/boot.txt

# Write the build date into the game title shown on the XMB/PPSSPP menu.
# patches/param.txt is generated on every run so it is not stored in git.
echo Writing build date to patches/param.txt...
builddate=$(date '+%Y-%m-%d %H:%M')

# Atlas scripts use CRLF line endings in this project, see .gitattributes
{
  printf '// Doko Demo Issyo PSP English Translation Project\r\n'
  printf '// PARAM.SFO Atlas script - (Game title shown on the XMB/PPSSPP menu)\r\n'
  printf '// This file is generated by the build script, your changes will be lost\r\n'
  printf '\r\n'
  printf '#SETTARGETFILE("build/PSP_GAME/PARAM.SFO")\r\n'
  printf '#VAR(Table, TABLE)\r\n'
  printf '#ADDTBL("shiftjis.tbl", Table)\r\n'
  printf '#ACTIVETBL(Table)\r\n'
  printf '\r\n'
  printf '// The game title field is 128 bytes long and starts at offset $158\r\n'
  printf '#FIXEDLENGTH(128,0)\r\n'
  printf '#JMP($158)\r\n'
  printf 'Doko Demo Issyo PSP English Fan Translation (build %s)<END>\r\n' "$builddate"
} > patches/param.txt

echo Writing patches/param.txt to build/PSP_GAME/PARAM.SFO...
wine tools/Atlas/Atlas.exe build/PSP_GAME/PARAM.SFO patches/param.txt

# Replace EBOOT.BIN (encrypted boot) to make the game launch our modified BOOT.BIN.
cp -f build/PSP_GAME/SYSDIR/BOOT.BIN build/PSP_GAME/SYSDIR/EBOOT.BIN

# Check the source files in /extract, since /insert contains working copies
# that are overwritten before applying the text patches
if [ ! -f ./extract/NEKO.KSC ] ||
   [ ! -f ./extract/ROBO.KSC ] ||
   [ ! -f ./extract/USAGI.KSC ] ||
   [ ! -f ./extract/INU.KSC ] ||
   [ ! -f ./extract/KAERU.KSC ]; then
  cd extract
  echo Extracting original game files from DATA.BP, this will take a minute
  # Hide output while bpar spams "magic number" warnings for unknown files
  ../tools/bpar/bpar -x ../build/PSP_GAME/USRDIR/data/DATA.BP > /dev/null 2>&1

  # Delete font files because there are thousands and they take forever to extract
  echo Skipping font textures
  # Find handles filenames directly and succeeds when there are no matches
  find . -maxdepth 1 -type f -name 'F[0-9][0-9][0-9].BPM' -delete

  echo Extracting BPM archives in the current directory
  # Use ./KS*.BPM to only extract KSC/DIC archives or ./*.BPM to extract everything
  for file in ./KS*.BPM; do
    ../tools/bpar/bpar -x "$file"
  done

  echo Cleaning up BPM archives
  rm *.BPM

  cd ..
fi

# Copy original KSC and DIC files to insert folder
cp -f ./extract/*.KSC ./insert
cp -f ./extract/*.DIC ./insert

# Patch KSC files in insert folder

for name in NEKO ROBO USAGI INU KAERU; do
  case "$name" in
    NEKO)   patch=toro ;;
    ROBO)   patch=suzuki ;;
    USAGI)  patch=jun ;;
    INU)    patch=pierre ;;
    KAERU)  patch=ricky ;;
  esac

  ksc_found=no
  dic_found=no

  for patch_file in "patches/$patch"*.txt; do
    [ -f "$patch_file" ] || continue
    # Dictionary patches (e.g. toro_dictionary.txt) write to the .DIC word list
    case "$patch_file" in
      "patches/${patch}_dictionary.txt") target="insert/$name.DIC"; dic_found=yes ;;
      *)                                 target="insert/$name.KSC"; ksc_found=yes ;;
    esac
    echo "Applying $patch_file to $target..."
    wine tools/Atlas/Atlas.exe "$target" "$patch_file" || exit 1
  done

  for ext in KSC DIC; do
    if [ "$ext" = KSC ]; then found=$ksc_found; else found=$dic_found; fi
    [ "$found" = yes ] || continue
    target="insert/$name.$ext"
    echo "Writing $target to build/PSP_GAME/USRDIR/data/DATA.BP..."
    ./tools/bpar/bpar id build/PSP_GAME/USRDIR/data/DATA.BP "$target" || exit 1
  done
done

# The conversion commands are used inside 'find -exec sh -c', so they have to
# be exported to reach those subshells
export pngquant_cmd

(
  cd textures

  # Delete converted image files from a previous run
  find . -type f -name '*.GIM' -delete
  find . -type f -name '*-fs8.png' -delete

  echo Converting .png textures to .GIM format
  # Skip any -fs8.png that pngquant creates while find is still running
  find . -type f -name '*.png' ! -name '*-fs8.png' -exec sh -c '
    for file do
      printf "Converting %s to GIM...\n" "$file"
      quantized="${file%.png}-fs8.png"

      # Convert every image to the 8-bit paletted PNG format with alpha that
      # GimConv expects. 16 colours keeps the palette within index4 range.
      # Pass the output path explicitly: pngquant otherwise picks the suffix
      # itself and writes -or8.png instead of -fs8.png when it does not use
      # Floyd-Steinberg dithering.
      # --force overwrites a leftover file instead of failing.
      $pngquant_cmd --force 16 -o "$quantized" "$file" || exit 1

      # Stop if pngquant did not produce an 8-bit alpha (colour type 3) PNG,
      # because GimConv would silently write a GIM the game cannot use
      if [ ! -f "$quantized" ]; then
        printf "pngquant did not write %s\n" "$quantized" >&2
        exit 1
      fi

      # Use -bpp4 -N to save all GIMs with image_format = index4
      # and pixel_order = normal
      wine ../tools/GimConv/GimConv.exe \
        "$quantized" -bpp4 -N -o "${file%.png}.GIM" || exit 1

      rm -f "$quantized"
    done
  ' sh {} +

  echo Inserting GIM textures...
  find . -type f -name '*.GIM' -exec sh -c '
    for file do
      printf "Inserting %s...\n" "$file"
      ../tools/bpar/bpar id \
        ../build/PSP_GAME/USRDIR/data/DATA.BP "$file" || exit 1
    done
  ' sh {} +

  # Delete converted image files
  find . -type f -name '*.GIM' -delete
  find . -type f -name '*-fs8.png' -delete
)

echo All done! Check for any errors above, then find your patched Doko Demo Issyo game files in the build folder.

# If PPSSPP is installed, try to start the patched game from the build folder
ppsspp=""
for emulator in PPSSPPSDL PPSSPPQt ppsspp ppsspp-sdl ppsspp-qt; do
  if command -v "$emulator" > /dev/null 2>&1; then
    ppsspp=$emulator
    break
  fi
done

if [ -n "$ppsspp" ]; then
  echo Starting the game in PPSSPP...
  "$ppsspp" "$baseDir/build" &
elif command -v flatpak > /dev/null 2>&1 &&
     flatpak info org.ppsspp.PPSSPP > /dev/null 2>&1; then
  echo Starting the game in PPSSPP...
  # Pass the build folder as a plain path and grant the sandbox access to it.
  # --file-forwarding cannot be used here because the document portal only
  # forwards single files and fails on a folder with "Invalid fd passed".
  # Hide the emulator log so it does not flood the build output.
  flatpak run --filesystem="$baseDir/build" org.ppsspp.PPSSPP \
    "$baseDir/build" > /dev/null 2>&1 &
fi
