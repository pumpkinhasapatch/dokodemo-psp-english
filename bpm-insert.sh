echo Replace files in DATA.BP
# This is slow because bpar scans the entire archive from
# the beginning to find each file's location one at a time.
# It also shifts other files around to fit the new textures

# If there are Segmentation Fault memory errors, an emulator or
# some other program may be accessing DATA.BP at the same time
# TODO: Ask user to close any conflicting programs and try again

echo Inserting NEKO.KSC...
./tools/bpar id build/PSP_GAME/USRDIR/data/DATA.BP insert/NEKO.KSC

cd textures

echo Textures to insert:
tree -P *.GIM --prune

for file in $(find . -type f -name '*.GIM')
do
    echo Inserting $file...
    # write to null to hide Debug output when shifting other files
    ../tools/bpar id ../build/PSP_GAME/USRDIR/data/DATA.BP "$file"> /dev/null 2>&1
done;

cd ..
