#!/bin/sh

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

if [ ! -f ./tools/bpar ]; then
  echo "bpar is missing (needed to read/write to the game's DATA.BP file)."
  echo "If you have bpar.c you can build it as a Linux program using 'cc bpar.c -O0 -g -o bpar'."
  echo " "
  error=1
fi

if [ ! -f ./tools/GimConv/GimConv.exe ]; then
  mkdir ./tools/GimConv
  echo "GimConv.exe is missing (needed for image conversion). Please download it and place in tools/GimConv/ folder."
  echo " "
  error=1
fi

if [ ! -f ./tools/abcde/abcde.pl ]; then
  echo "abcde is missing (needed for in-game text replacement)."
  echo "Get it from https://www.romhacking.net/forum/index.php?topic=25968.0"
  echo " "
  error=1
fi

if [ ! -f ./build/PSP_GAME/USRDIR/data/DATA.BP ]; then
  echo "Game files are missing from the 'build' folder or are not from Doko Demo Issyo."
  echo "Please extract your game ISO and place the PSP_GAME folder and UMD_DATA.BIN inside the 'build' folder."
  echo "You can use PeaZip, 7-Zip, Windows Explorer and many other programs to open or extract an ISO."
  echo "Note that some Linux software extracts the game with lowercase file names which will not work."
  echo " "
  error=1
fi

# https://stackoverflow.com/a/7522866
if ! type "wine" > /dev/null; then
  echo "Wine was not found. It is needed to run GimConv."
  echo "Please install it using 'sudo apt install wine' or your package manager."
  echo " "
  error=1
fi

if ! type "perl" > /dev/null; then
  echo "Perl was not found. It is needed to run abcde."
  echo "Please install it using 'sudo apt install perl' or your package manager."
  echo " "
  error=1
fi

# Exit the script if error variable is set.
if [ $error == 1 ] ; then exit 1; fi

echo All checks passed successfully.
echo " "

# Replace GimConv config file with Rcomage version to fix PSP image conversion issues.
cp -f ./GimConv.cfg ./tools/GimConv/

echo Replacing game icon...
cp -f ICON0.png build/PSP_GAME/ICON0.PNG

echo Writing patches/param.txt to build/PSP_GAME/PARAM.SFO...
perl tools/abcde/abcde.pl --artificial-end-token "<END>" -cm abcde::Atlas build/PSP_GAME/PARAM.SFO patches/param.txt

echo Writing patches/boot.txt to build/PSP_GAME/SYSDIR/BOOT.BIN...
perl tools/abcde/abcde.pl --artificial-end-token "<END>" -cm abcde::Atlas build/PSP_GAME/SYSDIR/BOOT.BIN patches/boot.txt

# Delete EBOOT.BIN (encrypted boot) to make the game launch our modified BOOT.BIN.
rm build/PSP_GAME/SYSDIR/EBOOT.BIN

if [ ! -f ./insert/NEKO.KSC ]; then
  cd extract
  echo Extracting original game files from DATA.BP, this will take a minute
  # Hide output while bpar spams "magic number" warnings for unknown files
  ../tools/bpar -x ../build/PSP_GAME/USRDIR/data/DATA.BP > /dev/null 2>&1

  # Delete font files because's thousands and they take forever to extract
  echo Skipping font textures
  # https://superuser.com/questions/392872/delete-files-with-regular-expression
  ls | grep -P "^F[0-9]{3}.BPM$" | xargs -d"\n" rm

  echo Extracting BPM archives in the current directory
  # Use ./KS*.BPM to only extract KSC/DIC archives or ./*.BPM to extract everything
  for file in ./KS*.BPM; do
    ../tools/bpar -x "$file" 
  done

  echo Cleaning up BPM archives
  rm *.BPM

  cd ..
fi

# Copy original KSC files to insert folder
cp -f ./extract/*.KSC ./insert

# Patch KSC files in insert folder
echo Writing patches/toro_messages.txt to insert/NEKO.KSC...
perl tools/abcde/abcde.pl --artificial-end-token "<END>" -cm abcde::Atlas insert/NEKO.KSC patches/toro_messages.txt
echo Writing patches/toro_dialogue.txt to insert/NEKO.KSC...
perl tools/abcde/abcde.pl --artificial-end-token "<END>" -cm abcde::Atlas insert/NEKO.KSC patches/toro_dialogue.txt
echo Writing insert/NEKO.KSC to build/PSP_GAME/USRDIR/data/DATA.BP...
./tools/bpar id build/PSP_GAME/USRDIR/data/DATA.BP insert/NEKO.KSC

echo Patching patches/jun_messages.txt to insert/USAGI.KSC...
perl tools/abcde/abcde.pl --artificial-end-token "<END>" -cm abcde::Atlas insert/USAGI.KSC patches/jun_messages.txt
echo Inserting insert/USAGI.KSC to build/PSP_GAME/USRDIR/data/DATA.BP...
./tools/bpar id build/PSP_GAME/USRDIR/data/DATA.BP insert/USAGI.KSC

cd textures

for file in $(find . -type f -name '*.png')
do
    echo Converting png image $file to GIM...
    wine ../tools/GimConv/GimConv.exe $file -o "${file%.png}.GIM"
done

for file in $(find . -type f -name '*.GIM')
do
    echo "Inserting GIM image $file..."
    ../tools/bpar id ../build/PSP_GAME/USRDIR/data/DATA.BP "$file" # %> /dev/null # Hide bpar debug text
done

cd ..

echo All done! Check for any errors above, then find your patched Doko Demo Issyo game files in the build folder.
