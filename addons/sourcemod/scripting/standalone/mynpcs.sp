#pragma semicolon 1
#pragma newdecls required

void MyNPCs()
{
	Sensal_OnMapStart_NPC();
	RaidbossBobTheFirst_OnMapStart();
//	Raidboss_Schwertkrieg_OnMapStart_NPC();
//	Raidboss_Donnerkrieg_OnMapStart_NPC();
	ChaosKahmlstein_OnMapStart_NPC();
	PeaShooter_Precache();
	SunFlower_Precache();
	PotatoMine_Precache();
	MelonPult_Precache();
	CobCannon_Precache();
}

#include "zombie_riot/npc/expidonsa/npc_expidonsa_base.sp"
#include "standalone/npc/npc_sensal.sp"
#include "standalone/npc/npc_bob_the_first_last_savior.sp"
//#include "standalone/npc/npc_donnerkrieg.sp"
//#include "standalone/npc/npc_schwertkrieg.sp"
#include "standalone/npc/npc_chaos_kahmlstein.sp"
#include "standalone/npc/mynpcs/npc_peashooter.sp"
#include "standalone/npc/mynpcs/npc_sunflower.sp"
#include "standalone/npc/mynpcs/npc_potatomine.sp"
#include "standalone/npc/mynpcs/npc_melonpult.sp"
#include "standalone/npc/mynpcs/npc_cobcannon.sp"