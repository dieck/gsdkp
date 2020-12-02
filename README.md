# GoogleSheetDKP
GoogleSheetDKP - World of Warcraft Classic addon

Simple interface for using DKP with a google sheet, basically more like a library


# Google Sheet

The Google Sheet template used can be downloaded here: https://bit.ly/GoogleSheetDKP

Import from Current DKP Sheet to Addon, and Export from Addon to History Sheet, using tab separated values.

## Tab "History"

Header: 
ID \t Date \t Name \t Change \t Cause \t Reference

e.g.
122 \t 2020-02-20 \t 20:20 \t Someguy \t -20 \t Item \t [Sword of Unending Truth]


## Tab Current

Header:
Playername \t Main \t Current [$MAX(ROWID)] \t All Time Gain \t Items 

e.g.

Roguetwink \t Warriormain \t 120 \t 220 \t 50 

The "Current" header includes an import thing: the max rowid from the history tab.
Following entries will then continue from there, to avoid doublettes.

Currently, GoogleSheetDKP only supports DKP by character, the Main field is there for future enhancements. Enter same name as Character if not used.

# Current functionality:

## Usage

  /gsdkp 
Opens the overview 

  /gsdkp config 
Configuration options including Import, Export and Help

  /gsdkp change NAME VALUE CAUSE [COMMENT]
  /gsdkp raidchange VALUE CAUSE [COMMENT]
  /gsdkp item NAME VALUE ITEMLINK [Itemlink]

commits manual DKP changs, Item DKP changes or changes for the whole Raid.
For Items, please note value will *not* be negated! (use e.g. -10 for costs)

## Notification

The addon can notify Raid and/or players (by whisper) about changes, to be transparent while handling DKP.


## Whisper query

Users can whisper "dkp" to ask for their current standing.

## API

Google Sheet DKP can be used by other addons to manage DKP:

- GoogleSheetDKP:GetDKP(name)
- GoogleSheetDKP:Change(name, value, cause, comment)
- GoogleSheetDKP:RaidChange(value, cause, comment)
- GoogleSheetDKP:Item(name, value, itemLink)

