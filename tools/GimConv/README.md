[GimConv](https://www.psdevwiki.com/ps3/GimConv) is a proprietary image conversion tool for Windows developed by Sony. It was officially released as freeware included with the [PS3 Theme Creation Pack](https://web.archive.org/web/20130928235656/https://uk.playstation.com/ps3/support/settings/detail/linked235336/item85346/Download-PlayStation-3-Custom-Theme-Guidelines/).

GIM is a image format used in many PlayStation 3 and PlayStation Portable software. GimConv allows users to convert between universal image formats such as PNG, and GIM formats used in PlayStation software.

This project uses the GimConv distribution from [RCOMage](https://github.com/kakaroto/RCOMage/releases/tag/1.1.1), including its configuration file. see [GimConv.cfg](GimConv.cfg) for more details.

# Basic usage
```
:: convert png to gim
gimconv image.png -o image.gim
:: convert gim to png
gimconv image.gim -o image.png
```

# Note about image conversion
Modified GIM images should have the same width, height and file size as the original GIM file, or else they will cause issues when inserting into the game. It is recommended to pass images through pngquant before converting them to GIM to make sure they are encoded correctly. You may need to use the -bpp option for some textures outside the GUI folder.