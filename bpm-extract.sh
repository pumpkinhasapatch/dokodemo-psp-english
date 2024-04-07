mkdir extract
cd extract

echo Extracting BPMs from DATA.BP, this will take a minute
# Hide output while bpar spams "magic number" warnings for unknown files
../tools/bpar -x ../build/PSP_GAME/USRDIR/data/DATA.BP > /dev/null 2>&1

# Delete font files because's thousands and they take forever to extract
echo Skipping font textures
# https://superuser.com/questions/392872/delete-files-with-regular-expression
ls | grep -P "^F[0-9]{3}.BPM$" | xargs -d"\n" rm

echo Extracting BPM archives in the current directory
# Use ./KS*.BPM to only extract KSC/DIC archives or ./*.BPM to extract everything
for file in ./*.BPM; do
    if [ -f "$file" ]; then
        ../tools/bpar -x "$file" 
    fi
done

echo Cleaning up BPM archives
rm *.BPM

cd ..
