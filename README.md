
 [<img align="right" src="https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/instagram.svg" width="50" height="50" />](http://www.instagram.com/gajjartejas)
 [<img align="right" src="https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/twitter.svg" width="50" height="50" />](http://www.twitter.com/gajjartejas)
 [<img align="right" src="https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/reddit.svg" width="50" height="50" />](http://www.reddit.com/u/gajjartejas)

# EFIC-EmptyFileCreator
EFIC (Empty File Creator) is a small and reliable application that create file in various size and Pattern. EFIC use two method to create file. First is instant writing and second is Pattern Writing. EFIC is use Windows API and RAM Buffer to create file using various pattern. Pattern range is 0x00 to 0xFF are used to create file.Example: If we use 0x41 pattern for writing the all sector will be filled with 41 41 41 41 etc. when you open this file in notepad you can see equivalent ASCII char AAAA. So it also can be used to secure overwriting file Disc.

**EFIC create empty or blanck file.It uses below methods:**

**Instant File Creating** - EFIC Create instant file like 5, 10, 50 GB in second without writing data or pattern.To create instant blank file open EFIC Choose Location (Default Location is Desktop Dir) now Choose File size to create and choose Do Not Fill(Faster) (Default).And Then Click on Create Button.

- Tested on Windows 10, Windows 7, and Windows XP
- Easy to use Interface.

## Screenshot
![Add new file dialog](screenshot.png)

## Contribute
For cloning and building this project yourself, make sure
to install the
[AutoIt](https://www.autoitscript.com/site/autoit/) 
and
[AutoIt Script Editor](https://www.autoitscript.com/site/autoit-script-editor/downloads/)
For windows.

To compile this project Right click on  [EFIC.au3](EFIC.au3) and select Compile with Options.
This action opens a new dialog box. Hit compile button to compile, a compiled binary will generate on same folder.

## License
*GNU GENERAL PUBLIC LICENSE version 3* by [Free Software Foundation, Inc.](http://fsf.org/) converted to Markdown.
Read the [original GPL v3](http://www.gnu.org/licenses/).
