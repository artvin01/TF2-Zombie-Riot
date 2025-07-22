If you wish to donate to support this project then concider subscribing to the patron, cus i like money.

[Patreon](https://www.patreon.com/user?u=95717000)

# WARNING! READ!

USE 32 BIT SERVER AS OF NOW!
this gamemode is ready for 64bit, but it is not possible yet as dhooks and address saving doesnt work for 64bit yet.

# TF2 Zombie Riot

You fight against AI enemies/Zombies with allies and try to win/suvive as long as possible, You buy weapons and or upgrade them from previous ones. Stay together and beat them
Compile zombie_riot.sp for this.

## Information

THIS CODE IS COMPRISED OF MULTIPLE CODERS JUST ADDING THEIR THINGS!
SO HOW THIS CODE WORKS CAN HEAVILY VARY FROM FILE TO FILE!!!
I overall try to keep a standart across them all without bothering them too much.

If you wish to use this plugin for your own server, please keep all the credits that are here or i WILL cry.
Do not go above 14 players(you can have 32 slots, i recommend 16+) but dont allow more inside the plugin itself (Inside queue.sp), as the server doesnt support that interms of performance, the npc's are limited at 32 for a reason.
The performance heavy things are Lagcompensation and pathfinder, but i tried to optimise those as much as i could.
Most of the code is made towards client prediction to make the best experience.


### Where can I see this gamemode in action?

IF you wish to see the plugin in action/or just are interrested in playing this gamemode rather then coding/messing with it, the main server for the plugin is this one hosted by disc.ff:

Main Servers:
(American)

74.91.119.154:27017 ( steam://connect/74.91.119.154:27017 )

74.91.113.50:27016 ( steam://connect/74.91.113.50:27016 )

(European)

145.239.70.42:27015 ( steam://connect/145.239.70.42:27015 )


 
## cvar's

Check the Cvar File.
shared/convars.sp
 
## Commands

"sm_give_cash" "PLAYER" "YOUR AMMOUNT"
 - Give money or remove money from said person or group

"zr_setwave" 
- Will set the wave to the number given +1

"sm_spawn_npc" 
- Any id will spawn the specific npc on where you look, check code to see which number equals which npc

## Installation

Go to Database.cfg inside your configs folder, and add

	"zr_local_1"
	{
		"driver"			"sqlite"
		"database"			"zr_local_database"
	}
	"zr_global"
	{
		"driver"			"sqlite"
		"database"			"zr_global_database"
	}
global zr can be a shared database across multiple servers, local one should stay sqlite.


### Dependencies

Sourcemod 1.13 Is a Must.
For both linux and Windows, not all linux gamedata might be here.
The SourceMod plugins / extensions listed below are required for TF2 Zombie Riot to run:

- [Flaming Sarge's TF2Attribute fork](https://github.com/FlaminSarge/tf2attributes)
- [TF2Items](https://builds.limetech.io/?project=tf2items)
- [SteamWorks](https://users.alliedmods.net/~kyles/builds/SteamWorks/)
- [TFEconData](https://github.com/nosoop/SM-TFEconData)
- [CBaseNpc](https://github.com/TF2-DMB/CBaseNPC)
- [Timescale Windows Fix](https://forums.alliedmods.net/showthread.php?t=324264) Not needed if you are on linux.
- [TF2Utils](https://github.com/nosoop/SM-TFUtils)
- [File Network](https://forums.alliedmods.net/showthread.php?t=341953)
- [CollisionHookFIX](https://github.com/voided/CollisionHook)
- [Source scramble](https://github.com/nosoop/SMExt-SourceScramble)
- [Load Soundscript](https://github.com/haxtonsale/LoadSoundScript)
- [Max speed unlocker/Edict Alloc](https://github.com/Mikusch/SourceScramble-Patches) (install both speed unlocker and Alloc)

If you want to compile, this include is needed!
- [More Colours](https://github.com/DoctorMcKay/sourcemod-plugins)


## Optional Things
If youre above 16 players, i recommend these plugins extra:
- [Any Tickrate modifier](https://github.com/Mikusch/SM-TickrateChanger)
This is an example for a LINUX one.
Any one will work.
## Credits

Current coders that in anyway actively helped, in order of how much:

- [Artvin](https://github.com/artvin01) (main dev, me)
- [Batfoxkid](https://github.com/Batfoxkid) (co dev)
- [JDeivid](https://github.com/jDaivid) (Co Dev)
- [Mikusch](https://github.com/Mikusch) (Gamedata assistance and more, a savior.)
- [Kenzzer](https://github.com/Kenzzer) (Got gamedata and make an extention edit for us, plus CBaseNpc!)
- [Spookmaster](https://github.com/SupremeSpookmaster) (general assitance and debugging too)
- [Mentrillum](https://github.com/Mentrillum) (Assitance in converting from Pathfollower to CBaseNpc!)
- [Suza](https://github.com/Zabaniya001/)(gamedata stuffs)
- [Alex](https://github.com/JustAlex14)(Weapons overall assistance)
- [Ficool2](https://github.com/ficool2) (helped with the mvm hud logic and some workarounds)
- [Pelipoika](https://github.com/Pelipoika) (Npc base code that we heavily edited, thank you SO much for publishing it all.)
- [backwards] (backwards#8236) on discord. (Helped with sdkcall lag compensation.)

Some Code is borrowed/just takes from other plugins i or friends made, often with permission,
rarely without because i couldnt contact the person or it was just open sourcecode, credited anyways when i did that inside the code.
All was under the GLP3.0 lisence.

IF YOU HAVE ANY QUESTIONS, CONTACT ME. My things are in my Bio.
