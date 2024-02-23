#pragma semicolon 1
#pragma newdecls required

#define MIN_FADE_DISTANCE	9999.9
#define MAX_FADE_DISTANCE	9999.9

#define NORMAL_ENEMY_MELEE_RANGE_FLOAT	130.0
#define NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED	16900.0

#define GIANT_ENEMY_MELEE_RANGE_FLOAT	160.0
#define GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED	25600.0

#include "standalone/convars.sp"
#include "standalone/dhooks.sp"
#include "standalone/npc.sp"

void NOG_PluginStart()
{
	LoadTranslations("standalone.unitnames.phrases");
}
