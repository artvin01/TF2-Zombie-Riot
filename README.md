# TF2 Zombie Riot

You fight against AI enemies/Zombies with allies and try to win/suvive as long as possible, You buy weapons and or upgrade them from previous ones. Stay together and beat them
Compile zombie_riot.sp for this.

# TF2 RPG Fortress

Still currently in development. Not recommended to use.
Compile rpg_fortress.sp for this.

We will also not support anyone using RPG fortress, or help with debugging.
Feel free to use this, but know what youre doing.

DO NOT HAVE BOTH ON THE SERVER.

## Information

THIS CODE IS COMPRISED OF MULTIPLE CODERS JUST ADDING THEIR THINGS!
SO HOW THIS CODE WORKS CAN HEAVILY VARY FROM FILE TO FILE!!!

**YOU MUST USE SOURCEMOD 1.12 FOR THIS PLUGIN!!!!!!!!!!!!!!!**

Use build 7031 or older, DO NOT USE NEWER.
It breaks float values for some god forsaken reason.

If you wish to use this plugin for your own server, please keep all the credits that are here or i WILL cry.
Do not go above 14 players(you can have 32 slots, i recommend 16+) but dont allow more inside the plugin itself (Inside queue.sp), as the server doesnt support that interms of performance, the npc's are limited at 32 for a reason.
The performance heavy things are Lagcompensation and pathfinder, but i tried to optimise those as much as i could.
Most of the code is made towards client prediction to make the best experience.

Also keep in mind that i (artvin) started coding here with only half a year of knowledege so you'll see a fuckton of shitcode.

There is also an escapemode Verison of this gamemode and more to come. If you need help, ask me questions, and i will awnser them and put a FAQ here too so i dont have to repeat myself.

### Where can I see this gamemode in action?

IF you wish to see the plugin in action/or just are interrested in playing this gamemode rather then coding/messing with it, the main server for the plugin is this one hosted by disc.ff:

Main Server:
(American)
74.91.119.154:27017 ( steam://connect/74.91.119.154:27017 )
 
## cvar's

"zr_infinitecash" = "0" ( def. "0" )
 - Money is infinite and always set to 999999
  
"zr_noroundstart" = "0" ( def. "0" )
 - Makes it so waves refuse to start
 
"zr_nospecial" = "0" ( def. "0" )
 - No Panzer will spawn or anything alike, good incase you hate this stuff
 
"zr_privateplugins" = "0" ( def. "0" )
 - Enable private plugins, set this to zero.
 
"zr_maxbotsforkillfeed" = "6" ( def. "6" )
 - The maximum amount of blue bots allowed for the killfeed
 
"zr_viewshakeonlowhealth" = "1" ( def. "1" )
 - Should the view shake when low on health?

"sv_visiblemaxplayers" = "24" ( def. "24" )
 - This is a default cvar from tf2, but i recomend setting it to 24 on a 32 player server.
 - it sets the max slots to 24 so players wont join, but bots can for killfeed reasons.

"zr_maxplayersplaying" = "14" ( def. "14" )
-Max players allowed to play at once, it should be set lower on linux due to performance drops on it
-You may set it to any value, but i recomment 14-20

 
 
 
 
## Commands

"sm_give_cash" "PLAYER" "YOUR AMMOUNT"
 - Give money or remove money from said person or group

"zr_setwave" 
- Will set the wave to the number given +1

"sm_spawn_npc" 
- Any id will spawn the specific npc on where you look, check code to see which number equals which npc

## Installation

Go to Database.cfg inside your configs folder, and add

	"zr_local"
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

Sourcemod 1.12 Is a Must.

For both linux and Windows, not all linux gamedata might be here.

The SourceMod plugins / extensions listed below are required for TF2 Zombie Riot to run:

- [Nosoop's TF2Attribute fork](https://github.com/nosoop/tf2attributes)
- [TF2Items](https://github.com/asherkin/TF2Items)
- [CollisionHookFIX](https://github.com/SlidyBat/CollisionHook) THIS IS A GAMEDATA FIX FOR...
- [CollisionHook](https://github.com/Adrianilloo/Collisionhook)
- [TFEconData](https://github.com/nosoop/SM-TFEconData)
- [CBaseNpc](https://github.com/TF2-DMB/CBaseNPC) 
~~- [lambda](https://github.com/Batfoxkid/lambda)~~ currently is kown to cause crashes. do not use. and its not used currently either.
- [Timescale Windows Fix](https://forums.alliedmods.net/showthread.php?t=324264) Not needed if you are on linux.
- [TF2Utils](https://github.com/nosoop/SM-TFUtils)
- [File Network](https://forums.alliedmods.net/showthread.php?t=341953)

### Supported

The SourceMod plugins / extensions listed below are not necessary for TF2 Zombie Riot to run but are supported nevertheless:

- [Text-Store](https://github.com/Batfoxkid/Text-Store)
- [Minecraft-TF2](https://github.com/Batfoxkid/Minecraft-TF2/tree/logic)

## Credits

Current coders that in anyway actively helped, in order of how much:

- [Artvin](https://github.com/artvin01)
- [Batfoxkid](https://github.com/Batfoxkid)
- [Mikusch](https://github.com/Mikusch) (Gamedata assistance and more, a savior.)
- [Kenzzer](https://github.com/Kenzzer) (Got gamedata and make an extention edit for us, plus CBaseNpc!)
- [Mentrillum](https://github.com/Mentrillum) (Assitance in converting from Pathfollower to CBaseNpc!)
- [Suza](https://github.com/Zabaniya001/)
- [Alex](https://github.com/JustAlex14)
- [Spookmaster](https://github.com/SupremeSpookmaster)
- [Pelipoika](https://github.com/Pelipoika) (Npc base code that we heavily edited, thank you SO much for publishing it all.)
- [backwards] (backwards#8236) on discord. (Helped with sdkcall lag compensation.)

Alot of code is borrowed/just takes from other plugins i or friends made, often with permission,
rarely without cus i couldnt contact the person or it was just open sourcecode, credited anyways when i did that.

IF YOU HAVE ANY QUESTIONS, CONTACT ME. My things are in my Bio.


Note:
Compile both listen.so and envnav.sp so you can edit the navmesh live on the server.

Credits go to - [Arthurdead](https://github.com/arthurdead) for the original plugin nav plugin
I just got windows gamedata.
To edit the nav live, do sm_nav_edit_mode 

BEWARE, THIS SETS sv_cheats TO 1, Do it again to disable, you must also run sm_rcon for any nav command
(Zr will hide that sv_cheats got set and other stuff, and will also hide it from players, i will in the future code an anti cheat in zr to prevent this)
The server WILL crashwhen editing, beware, no idea how to fix it, too lazy.

Just dont announce that youll do it.


If you wish to donate to support this project then concider subscribing to the patron

[Patreon](https://www.patreon.com/user?u=95717000)
