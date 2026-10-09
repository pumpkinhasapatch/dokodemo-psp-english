#!/bin/sh
# Stop when a command returns a non zero status
set -e

# Optional ISO path. If omitted, use the game files already in build/.
iso=${1:-}

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

if [ ! -f ./tools/bpar/bpar ]; then
  echo "bpar is missing (needed to read/write to the game's DATA.BP file)."
  echo "If you have bpar.c you can build it as a Linux program using 'cc bpar.c -O0 -g -o bpar'."
  echo " "
  error=1
fi

if [ ! -f ./tools/GimConv/GimConv.exe ]; then
  mkdir -p ./tools/GimConv
  echo "GimConv.exe is missing (needed for image conversion). Please download it and place in tools/GimConv/ folder."
  echo " "
  error=1
fi

# Use Atlas through Wine to apply the project's text patches
# The bundled abcde parser rejects the 00=<END> table entry
if [ ! -f ./tools/Atlas/Atlas.exe ]; then
  echo "Atlas.exe is missing. Place it in tools/Atlas/."
  echo " "
  error=1
fi

if [ ! -f ./tools/7zip/7zz ]; then
  echo tools/7zip/7zz was not found
  echo Attempting to download it from GitHub...
  cd tools
    # Follow redirects and fail on HTTP errors instead of saving an error page.
    curl -fL https://github.com/ip7z/7zip/releases/download/24.08/7z2408-linux-x64.tar.xz -o 7zip.tar.xz
    # Allow retrying after a previous download or extraction attempt.
    mkdir -p 7zip
    cd 7zip
      tar -xf ../7zip.tar.xz
    cd ..
  cd ..
fi

if [ ! -f ./tools/7zip/7zz ]; then
  echo 7zip is still not found, download/extraction failed!
  error=1
else
  if [ -z "$iso" ]; then
    echo Command argument is empty. Use a Dokodemo UMD .iso file with './build.sh path/to/ddipsp.iso' or extract it to the 'build' folder to apply game patches.
    echo " "

    if [ ! -f ./build/PSP_GAME/USRDIR/data/DATA.BP ]; then
      echo "Game files are missing from the 'build' folder or are not from Doko Demo Issyo."
      echo "Please extract your game ISO and place the PSP_GAME folder and UMD_DATA.BIN inside the 'build' folder."
      echo "You can use PeaZip, 7-Zip, Windows Explorer and many other programs to open or extract an ISO."
      echo "Note that some Linux software extracts the game with lowercase file names which will not work."
      echo " "
      error=1
    else
      echo Patching on top of existing build folder. You should delete the build folder first if your game is corrupted.
    fi
  else
    if [ -f "$iso" ]; then
      echo Trying to extract game into build folder
      # Extract from the project directory so both relative and absolute ISO paths work
      # Quote the path to preserve spaces in filenames
      ./tools/7zip/7zz x -y -obuild "$iso"
    else
      printf 'ISO file not found: %s\n' "$iso" >&2
      exit 1
    fi
  fi
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

# https://stackoverflow.com/a/7522866
if ! type "wine" > /dev/null; then
  echo "Wine was not found. It is needed to run Atlas and GimConv."
  echo "Please install it using 'sudo apt install wine' or your package manager."
  echo " "
  error=1
fi

# Exit the script if error variable is set.
# Use a POSIX-compatible numeric comparison because this script runs with sh.
if [ "$error" -eq 1 ] ; then exit 1; fi

echo All checks passed successfully.
echo " "

echo Replacing game icon...
cp -f ICON0.png build/PSP_GAME/ICON0.PNG
cp -f PIC0.png build/PSP_GAME/PIC0.PNG
cp -f ICON1.PMF build/PSP_GAME/ICON1.PMF

echo Writing patches/boot.txt to build/PSP_GAME/SYSDIR/BOOT.BIN...
wine tools/Atlas/Atlas.exe build/PSP_GAME/SYSDIR/BOOT.BIN patches/boot.txt

# Delete EBOOT.BIN (encrypted boot) to make the game launch our modified BOOT.BIN.
# Ignore an already missing EBOOT.BIN when reusing an existing build
rm -f build/PSP_GAME/SYSDIR/EBOOT.BIN

# Check the source files in /extract, since /insert contains working copies
# that are overwritten before applying the text patches
if [ ! -f ./extract/NEKO.KSC ] ||
   [ ! -f ./extract/ROBO.KSC ] ||
   [ ! -f ./extract/USAGI.KSC ]; then
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

# Copy original KSC files to insert folder
cp -f ./extract/*.KSC ./insert

# Patch KSC files in insert folder
echo Patching Toro messages...
wine tools/Atlas/Atlas.exe insert/NEKO.KSC patches/toro_messages.txt
if [ -f patches/toro_dialogue.txt ]; then
  echo Patching Toro dialogue...
  wine tools/Atlas/Atlas.exe insert/NEKO.KSC patches/toro_dialogue.txt
fi
if [ -f patches/toro_diary.txt ]; then
  echo Patching Toro diary...
  wine tools/Atlas/Atlas.exe insert/NEKO.KSC patches/toro_diary.txt
fi
echo Writing insert/NEKO.KSC to build/PSP_GAME/USRDIR/data/DATA.BP...
./tools/bpar/bpar id build/PSP_GAME/USRDIR/data/DATA.BP insert/NEKO.KSC


echo Patching patches/suzuki_messages.txt to insert/ROBO.KSC...
wine tools/Atlas/Atlas.exe insert/ROBO.KSC patches/suzuki_messages.txt
echo Inserting insert/ROBO.KSC to build/PSP_GAME/USRDIR/data/DATA.BP...
./tools/bpar/bpar id build/PSP_GAME/USRDIR/data/DATA.BP insert/ROBO.KSC

echo Patching patches/jun_messages.txt to insert/USAGI.KSC...
wine tools/Atlas/Atlas.exe insert/USAGI.KSC patches/jun_messages.txt
echo Inserting insert/USAGI.KSC to build/PSP_GAME/USRDIR/data/DATA.BP...
./tools/bpar/bpar id build/PSP_GAME/USRDIR/data/DATA.BP insert/USAGI.KSC

(
  cd textures

  find . -type f -name '*.GIM' -delete

  find . -type f -name '*.png' -exec sh -c '
    for file do
      printf "Converting %s to GIM...\n" "$file"
      wine ../tools/GimConv/GimConv.exe \
        "$file" -bpp4 -o "${file%.png}.GIM" || exit 1
    done
  ' sh {} +

  find . -type f -name '*.GIM' -exec sh -c '
    for file do
      printf "Inserting %s...\n" "$file"
      ../tools/bpar/bpar id \
        ../build/PSP_GAME/USRDIR/data/DATA.BP "$file" || exit 1
    done
  ' sh {} +
)

echo All done! Check for any errors above, then find your patched Doko Demo Issyo game files in the build folder.
