# TF2 Zombie Riot

You fight against AI enemies/Zombies with allies and try to win/suvive as long as possible, You buy weapons and or upgrade them from previous ones. Stay together and beat them

## Information

THIS CODE IS COMPRISED OF MULTIPLE CODERS JUST ADDING THEIR THINGS!
SO HOW THIS CODE WORKS CAN HEAVILY VARY FROM FILE TO FILE!!!

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

Sub Servers that also host the gamemode:

(Chinese)
1.12.64.247:27015 ( steam://connect/1.12.64.247:27015 ) 
 
## cvar's

"zr_infinitecash" = "0" ( def. "0" )
 - Money is infinite and always set to 999999
  
"zr_noroundstart" = "0" ( def. "0" )
 - Makes it so waves refuse to start
 
"zr_nospecial" = "1" ( def. "1" )
 - No Panzer will spawn or anything alike
 
"zr_privateplugins" = "0" ( def. "0" )
 - Enable private plugins, set this to zero.
 
"zr_maxbotsforkillfeed" = "6" ( def. "6" )
 - The maximum amount of blue bots allowed for the killfeed
 
## Commands

"sm_give_cash" "PLAYER" "YOUR AMMOUNT"
 - Give money or remove money from said person or group

"zr_setwave" 
- Will set the wave to the number given +1

"sm_spawn_npc" 
- Any id will spawn the specific npc on where you look, check code to see which number equals which npc

## Installation

### Dependencies

Sourcemod 1.11
1.11 Compiler

WINDOWS SERVER IS A MUST DUE TO PATHFOLLOWER!!

The SourceMod plugins / extensions listed below are required for TF2 Zombie Riot to run:

- [Nosoop's TF2Attribute fork](https://github.com/nosoop/tf2attributes)
- [TF2Items](https://github.com/asherkin/TF2Items)
- [CollisionHookFIX](https://github.com/SlidyBat/CollisionHook) THIS IS A GAMEDATA FIX FOR...
- [CollisionHook](https://github.com/Adrianilloo/Collisionhook)
- [TFEconData](https://github.com/nosoop/SM-TFEconData)
- [PathFollower](https://github.com/Pelipoika/PathFollower)
- [lambda](https://github.com/Batfoxkid/lambda)
- [Timescale Windows Fix](https://forums.alliedmods.net/showthread.php?t=324264)

### Supported

The SourceMod plugins / extensions listed below are not necessary for TF2 Zombie Riot to run but are supported nevertheless:

- [Text-Store](https://github.com/Batfoxkid/Text-Store)
- [Minecraft-TF2](https://github.com/Batfoxkid/Minecraft-TF2/tree/logic)

## Credits

Current coders that in anyway actively helped, in order of how much:

- [Artvin](https://github.com/artvin01)
- [Batfoxkid](https://github.com/Batfoxkid)
- [Mikusch](https://github.com/Mikusch) (Gamedata assistance and more, a savior.)
- [Suza](https://github.com/Zabaniya001/)
- [Alex](https://github.com/JustAlex14)
- [Spookmaster](https://github.com/SupremeSpookmaster)
- [Kenzzer](https://github.com/Kenzzer) (Got gamedata and make an extention edit for us)
- [Pelipoika](https://github.com/Pelipoika) (Npc base code that we heavily edited, thank you SO much for publishing it all.)
- [backwards] (backwards#8236) on discord. (Helped with sdkcall lag compensation.)

IF YOU WISH TO USE THE MODELS THAT ARENT IN THE SOURCECODE, CONTACT THIS PERSON FOR PERMISSION, OTHERWISE PLEASE HAVE THIS CVAR (zr_nospecial) ON 1
USING THESE MODELS WITHOUT PERMISSION WILL ANGER US. thanks.

- [Crusty](https://steamcommunity.com/profiles/76561198097667312/) (Modeler)

Alot of code is borrowed/just takes from other plugins i or friends made, often with permission,
rarely without cus i couldnt contact the person or it was just open sourcecode, credited anyways when i did that.

IF YOU HAVE ANY QUESTIONS, CONTACT ME. My things are in my Bio.
