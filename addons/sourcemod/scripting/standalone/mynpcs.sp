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

#include "../zombie_riot/npc/expidonsa/npc_expidonsa_base.sp"
#include "npc/npc_sensal.sp"
#include "npc/npc_bob_the_first_last_savior.sp"
#include "npc/npc_donnerkrieg.sp"
#include "npc/npc_schwertkrieg.sp"
#include "npc/npc_chaos_kahmlstein.sp"