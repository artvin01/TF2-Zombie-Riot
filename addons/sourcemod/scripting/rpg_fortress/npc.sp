#pragma semicolon 1
#pragma newdecls required

enum
{
	NOTHING 				= 0,	
	HEADCRAB_ZOMBIE 			= 1
}

public const char NPC_Names[][] =
{
	"nothing",
	"Headcrab Zombie"
};

public const char NPC_Plugin_Names_Converted[][] =
{
	"",
	"headcrabzombie"
};

void NPC_MapStart()
{
	HeadcrabZombie_OnMapStart_NPC();
	Fortified_HeadcrabZombie_OnMapStart_NPC();
	FastZombie_OnMapStart_NPC();
	FortifiedFastZombie_OnMapStart_NPC();
	TorsolessHeadcrabZombie_OnMapStart_NPC();
	FortifiedGiantPoisonZombie_OnMapStart_NPC();
	PoisonZombie_OnMapStart_NPC();
	FortifiedPoisonZombie_OnMapStart_NPC();
	FatherGrigori_OnMapStart_NPC();
	
	Combine_Police_Pistol_OnMapStart_NPC();
	CombinePoliceSmg_OnMapStart_NPC();
	CombineSoldierAr2_OnMapStart_NPC();
	CombineSoldierShotgun_OnMapStart_NPC();
	CombineSwordsman_OnMapStart_NPC();
	CombineElite_OnMapStart_NPC();
	CombineGaint_OnMapStart_NPC();
	CombineDDT_OnMapStart_NPC();
	CombineCollos_OnMapStart_NPC();
	CombineOverlord_OnMapStart_NPC();
	
	Scout_OnMapStart_NPC();
	Engineer_OnMapStart_NPC();
	Heavy_OnMapStart_NPC();
	FlyingArmor_OnMapStart_NPC();
	FlyingArmorTiny_OnMapStart_NPC();
	Kamikaze_OnMapStart_NPC();
	MedicHealer_OnMapStart_NPC();
	HeavyGiant_OnMapStart_NPC();
	Spy_OnMapStart_NPC();
	Soldier_OnMapStart_NPC();
	SoldierMinion_OnMapStart_NPC();
	SoldierGiant_OnMapStart_NPC();
	
	SpyThief_OnMapStart_NPC();
	SpyTrickstabber_OnMapStart_NPC();
	SpyCloaked_OnMapStart_NPC();
	SniperMain_OnMapStart_NPC();
	DemoMain_OnMapStart_NPC();
	MedicMain_OnMapStart_NPC();
	PyroGiant_OnMapStart_NPC();
	CombineDeutsch_OnMapStart_NPC();
	Alt_CombineDeutsch_OnMapStart_NPC();
	SpyMainBoss_OnMapStart_NPC();
	/*
	XenoHeadcrabZombie_OnMapStart_NPC();
	XenoFortified_HeadcrabZombie_OnMapStart_NPC();
	XenoFastZombie_OnMapStart_NPC();
	XenoFortifiedFastZombie_OnMapStart_NPC();
	XenoTorsolessHeadcrabZombie_OnMapStart_NPC();
	XenoFortifiedGiantPoisonZombie_OnMapStart_NPC();
	XenoPoisonZombie_OnMapStart_NPC();
	XenoFortifiedPoisonZombie_OnMapStart_NPC();
	*/
	XenoFatherGrigori_OnMapStart_NPC();
	/*
	XenoCombine_Police_Pistol_OnMapStart_NPC();
	XenoCombinePoliceSmg_OnMapStart_NPC();
	XenoCombineSoldierAr2_OnMapStart_NPC();
	XenoCombineSoldierShotgun_OnMapStart_NPC();
	XenoCombineSwordsman_OnMapStart_NPC();
	XenoCombineElite_OnMapStart_NPC();
	XenoCombineGaint_OnMapStart_NPC();
	XenoCombineDDT_OnMapStart_NPC();
	XenoCombineCollos_OnMapStart_NPC();
	XenoCombineOverlord_OnMapStart_NPC();
	
	XenoScout_OnMapStart_NPC();
	XenoEngineer_OnMapStart_NPC();
	XenoHeavy_OnMapStart_NPC();
	XenoFlyingArmor_OnMapStart_NPC();
	XenoFlyingArmorTiny_OnMapStart_NPC();
	XenoKamikaze_OnMapStart_NPC();
	MedicHealer_OnMapStart_NPC();
	XenoHeavyGiant_OnMapStart_NPC();
	XenoSpy_OnMapStart_NPC();
	XenoSoldier_OnMapStart_NPC();
	XenoSoldierMinion_OnMapStart_NPC();
	XenoSoldierGiant_OnMapStart_NPC();
	*/
	
	/*
	XenoSpyThief_OnMapStart_NPC();
	XenoSpyTrickstabber_OnMapStart_NPC();
	XenoSpyCloaked_OnMapStart_NPC();
	XenoSniperMain_OnMapStart_NPC();
	XenoDemoMain_OnMapStart_NPC();
	XenoMedicMain_OnMapStart_NPC();
	XenoPyroGiant_OnMapStart_NPC();
	XenoCombineDeutsch_OnMapStart_NPC();
	XenoSpyMainBoss_OnMapStart_NPC();
	*/
	NaziPanzer_OnMapStart_NPC();
	BobTheGod_OnMapStart_NPC();
	NecroCombine_OnMapStart_NPC();
	NecroCalcium_OnMapStart_NPC();
	CuredFatherGrigori_OnMapStart_NPC();
	
	Bloon_MapStart();
	Moab_MapStart();
	Bfb_MapStart();
	Zomg_MapStart();
	DDT_MapStart();
	Bad_MapStart();
	AltMedicApprenticeMage_OnMapStart_NPC();
	SawRunner_OnMapStart_NPC();
	TrueFusionWarrior_OnMapStart();
	AltMedicCharger_OnMapStart_NPC();
	AltMedicBerseker_OnMapStart_NPC();
	
	MedivalMilitia_OnMapStart_NPC();
	MedivalArcher_OnMapStart_NPC();
	MedivalManAtArms_OnMapStart_NPC();
	MedivalSkirmisher_OnMapStart_NPC();
	MedivalSwordsman_OnMapStart_NPC();
	MedivalTwoHandedSwordsman_OnMapStart_NPC();
	MedivalCrossbowMan_OnMapStart_NPC();
	MedivalSpearMan_OnMapStart_NPC();
	MedivalHandCannoneer_OnMapStart_NPC();
	MedivalEliteSkirmisher_OnMapStart_NPC();
	Blitzkrieg_OnMapStart();
	MedivalPikeman_OnMapStart_NPC();
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnMapStart_NPC();
	Citizen_OnMapStart();
	MedivalEagleScout_OnMapStart_NPC();
	MedivalSamurai_OnMapStart_NPC();
	Kahmlstein_OnMapStart_NPC();
	Sniper_railgunner_OnMapStart_NPC();
	
	L4D2_Tank_OnMapStart_NPC();
	Addiction_OnMapStart_NPC();
	MedivalRam_OnMapStart();
	
	Soldier_Barrager_OnMapStart_NPC();
	The_Shit_Slapper_OnMapStart_NPC();
	
	BasicBones_OnMapStart_NPC();
	Itstilives_MapStart();
	
	Mecha_Engineer_OnMapStart_NPC();
	Mecha_Heavy_OnMapStart_NPC();
	Mecha_HeavyGiant_OnMapStart_NPC();
	Mecha_PyroGiant_OnMapStart_NPC();
	Mecha_Scout_OnMapStart_NPC();
	
	Donnerkrieg_OnMapStart_NPC();
	Schwertkrieg_OnMapStart_NPC();
	PhantomKnight_OnMapStart_NPC();
}

any Npc_Create(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], bool ally, const char[] data="") //dmg mult only used for summonings
{
	any entity = -1;
	switch(Index_Of_Npc)
	{
		case HEADCRAB_ZOMBIE:
		{
			entity = HeadcrabZombie(client, vecPos, vecAng, ally);
		}
		default:
		{
			PrintToChatAll("Please Spawn the NPC via plugin or select which npcs you want! ID:[%i] Is not a valid npc!", Index_Of_Npc);
		}
	}
	
	return entity;
}	
public void NPCDeath(int entity)
{
	switch(i_NpcInternalId[entity])
	{
		case HEADCRAB_ZOMBIE:
		{
			HeadcrabZombie_NPCDeath(entity);
		}
		default:
		{
			PrintToChatAll("This Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
		}
	}
	
	/*if(view_as<CClotBody>(entity).m_iCreditsOnKill)
	{
		CurrentCash += view_as<CClotBody>(entity).m_iCreditsOnKill;
			
		int extra;
		
		int client_killer = GetClientOfUserId(LastHitId[entity]);
		if(client_killer && IsClientInGame(client_killer))
		{
			extra = RoundToFloor(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * Building_GetCashOnKillMulti(client_killer));
			extra -= view_as<CClotBody>(entity).m_iCreditsOnKill;
		}
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(extra > 0)
				{
					CashSpent[client] -= extra;
					CashRecievedNonWave[client] += extra;
				}
				if(GetClientTeam(client)!=2)
				{
					SetGlobalTransTarget(client);
					CashSpent[client] += RoundToCeil(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * 0.40);
					
				}
				else if (TeutonType[client] == TEUTON_WAITING)
				{
					SetGlobalTransTarget(client);
					CashSpent[client] += RoundToCeil(float(view_as<CClotBody>(entity).m_iCreditsOnKill) * 0.30);
				}
			}
		}
	}*/
}

#include "zombie_riot/npc/normal/npc_headcrabzombie.sp"
