# Atlas
A text script insertion utility designed for the translation of retro videogames.

## Text Table Support
* Encodes standard text arbitrary, custom encodings typical of early videogames

## Domain Specific Language
* In-built commands allow proper script insertion of deeply complex structures
* Over 45 commands and overloads

## Flexible Pointer Features
* Extensive range of pointer calculation methods
* Embedded Pointers
* Pointer Tables
* Pointer Lists

## Reporting
* Detailed statistics for individual text blocks and overall totals
* Concise error messages for syntax errors, table errors

## Sample Script (See documentation for more)
```
// script.txt
#VAR(dialogue, TABLE)
#ADDTBL(“game.tbl”, dialogue)
#ACTIVETBL(dialogue)
#VAR(Ptr, CUSTOMPOINTER)
#CREATEPTR(Ptr, “LOROM00”, $0, 24)
#HDR($200)
#JMP($40200)
#WRITE(Ptr, $50200)
Now that our script is all setup…<LINE>
We can begin inserting the script!<END>
#WRITE(Ptr, $50203)
And just as nice, Atlas is<LINE>
updating the pointers too!<END>
#WRITE(Ptr, $50206)
And here is the end of the sample.<END>
```
