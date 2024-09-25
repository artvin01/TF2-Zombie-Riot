#pragma semicolon 1
#pragma newdecls required

void MyNPCs()
{
	Sensal_OnMapStart_NPC();
	RaidbossBobTheFirst_OnMapStart();
	Raidboss_Schwertkrieg_OnMapStart_NPC();
	Raidboss_Donnerkrieg_OnMapStart_NPC();
	ChaosKahmlstein_OnMapStart_NPC();
}

#include "zombie_riot/npc/expidonsa/npc_expidonsa_base.sp"
#include "standalone/npc/npc_sensal.sp"
#include "standalone/npc/npc_bob_the_first_last_savior.sp"
#include "standalone/npc/npc_donnerkrieg.sp"
#include "standalone/npc/npc_schwertkrieg.sp"
#include "standalone/npc/npc_chaos_kahmlstein.sp"