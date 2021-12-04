# WCXLV-potato
For Winter Camp XLV, the Hot Potato Lunch (https://www.wintercamp.com/reference/theguide/item.php?pk_ewc=959) is scheduled, but with COVID, passing of a potato between persons while eating is frowned upon. This TRS-80 program provides a digital alternative.

At the beginning of the game, each player enters their name into the computer. Then, the computer will randomly select a name to show on the screen, and a random time range for the name to be up, as well as time between the next name is selected. As names are picked, they are eliminated from the list, until the entire list is empty, at which point it will reset with all names.

The program consists of 2 parts. The main program, which collects, randomizes and selects names is in Level 2 BASIC, since working with strings and arrays is easy using it. The second part is an assembly program reads a string, and prints in in large letters using the TRS-80 graphic characters. An 8x8 font is used, and I include a 32 character font that I use with my TRS-80 clone.

The machine language portion is intergrated into the BASIC program with DATA keywords, and POKEs the code into memory at it's target location. This isn't the quickest way to put a program into memory, but it does make it a little more streamlined since all you have to do is load one BASIC program. To make this easier, I wrote a C++ program (DT.cpp) to generate a basic program with DATA and POKE, load the binary, and set up basic to use the USR() command with it.
