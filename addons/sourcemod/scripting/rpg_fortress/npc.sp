#pragma semicolon 1
#pragma newdecls required

enum
{
	NOTHING 						= 0,
	START_CHICKEN 					= 1,
	MAD_CHICKEN 					= 2,
	MAD_ROOST						= 3,
	HEAVY_BEAR						= 4,
	HEAVY_BEAR_BOSS					= 5,
	HEAVY_BEAR_MINION				= 6,
	MINER_NPC						= 7,
	HEADCRAB_ZOMBIE					= 8,
	HEADCRAB_ZOMBIE_ELECTRO			= 9,
	POISON_ZOMBIE					= 10,
	EXPLOSIVE_ZOMBIE				= 11,
	ZOMBIEFIED_COMBINE_SWORDSMAN	= 12,
	BOB_THE_TARGETDUMMY				= 13,
	FAST_ZOMBIE						= 14,
	FATHER_GRIGORI					= 15,


	FARM_COW						= 16,

	ARK_SLUG		= 17,
	ARK_SINGER		= 18,
	ARK_SLUGACID		= 19,
	ARK_SLUG_INFUSED	= 20,

	COMBINE_PISTOL,
	COMBINE_SMG,
	COMBINE_AR2,
	COMBINE_ELITE,
	COMBINE_SHOTGUN		= 25,
	COMBINE_SWORDSMAN,
	COMBINE_GIANT,
	COMBINE_OVERLORD,
	TOWNGUARD_PISTOL,
	COMBINE_OVERLORD_CC	= 30,
	COMBINE_TURTLE,
	FARM_BEAR
}

public const char NPC_Names[][] =
{
	"nothing",
	"Chicken",
	"Mad Chicken",
	"Mad Roost",
	"Heavy Bear",
	"Heavy Bear Boss",
	"Heavy Bear Minion",
	"Ore Miner",
	"Headcrab Zombie",
	"Arrow Headcrab Zombie",
	"Poison Zombie",
	"Explosive Zombie",
	"Zombified Combine Swordsman",
	"Bob The Second - Target Dummy",
	"Fast Zombie",
	"Father Grigori ?",
	"Farming Cow",
	"Originium Slug",
	"Scarlet Singer",
	"Acid Originium Slug",
	"Infused Originium Slug",
	"Metro Cop",
	"Metro Raider",
	"Combine Rifler",
	"Combine Elite",
	"Combine Shotgunner",
	"Combine Swordsman",
	"Combine Giant Swordsman",
	"Combine Overlord",
	"Rebel Guard",
	"Overlord The Last",
	"Hat Turtle",
	"Heavy Farm Bear"
};

public const char NPC_Plugin_Names_Converted[][] =
{
	"",
	"npc_chicken_2",
	"npc_chicken_mad",
	"npc_roost_mad",
	"npc_heavy_bear",
	"npc_heavy_bear_boss",
	"npc_heavy_bear_minion",
	"npc_miner",
	"npc_headcrab_zombie",
	"npc_headcrab_zombie_electro",
	"npc_poison_zombie",
	"npc_headcrab_zombie_explosive",
	"npc_zombiefied_combine_soldier_swordsman",
	"npc_bob_the_targetdummy",
	"npc_fastzombie",
	"npc_enemy_grigori",
	"npc_heavy_cow",
	"npc_ark_slug",
	"npc_ark_singer",
	"npc_ark_slug_acid",
	"npc_ark_slug_infused",
	"npc_combine_pistol",
	"npc_combine_smg",
	"npc_combine_ar2",
	"npc_combine_elite",
	"npc_combine_shotgun",
	"npc_combine_swordsman",
	"npc_combine_giant",
	"npc_combine_overlord",
	"npc_townguard_pistol",
	"npc_combine_overlord_cc",
	"npc_combine_turtle",
	"npc_heavy_farm_bear",
};

void NPC_MapStart()
{
	MadChicken_OnMapStart_NPC();
	StartChicken_OnMapStart_NPC();
	MadRoost_OnMapStart_NPC();
	HeavyBear_OnMapStart_NPC();
	HeavyBearBoss_OnMapStart_NPC();
	HeavyBearMinion_OnMapStart_NPC();
	Miner_Enemy_OnMapStart_NPC();
	HeadcrabZombie_OnMapStart_NPC();
	HeadcrabZombieElectro_OnMapStart_NPC();
	PoisonZombie_OnMapStart_NPC();
	ExplosiveHeadcrabZombie_OnMapStart_NPC();
	ZombiefiedCombineSwordsman_OnMapStart_NPC();
	BobTheTargetDummy_OnMapStart_NPC();
	FastZombie_OnMapStart_NPC();
	EnemyFatherGrigori_OnMapStart_NPC();
	FarmCow_OnMapStart_NPC();
	ArkSlug_MapStart();
	ArkSinger_MapStart();
	ArkSlugAcid_MapStart();
	ArkSlugInfused_MapStart();
	BaseSquad_MapStart();
	CombineTurtle_MapStart();
	FarmBear_OnMapStart_NPC();
}
#define NORMAL_ENEMY_MELEE_RANGE_FLOAT 120.0
// 120 * 120
#define NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED 14400.0

#define GIANT_ENEMY_MELEE_RANGE_FLOAT 140.0
// 140 * 140
#define GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED 16900.0

stock any Npc_Create(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], bool ally, const char[] data="") //dmg mult only used for summonings
{
	any entity = -1;
	switch(Index_Of_Npc)
	{
		case START_CHICKEN:
		{
			entity = StartChicken(client, vecPos, vecAng, ally);
		}
		case MAD_CHICKEN:
		{
			entity = MadChicken(client, vecPos, vecAng, ally);
		}
		case MAD_ROOST:
		{
			entity = MadRoost(client, vecPos, vecAng, ally);
		}
		case HEAVY_BEAR:
		{
			entity = HeavyBear(client, vecPos, vecAng, ally);
		}
		case HEAVY_BEAR_BOSS:
		{
			entity = HeavyBearBoss(client, vecPos, vecAng, ally);
		}
		case HEAVY_BEAR_MINION:
		{
			entity = HeavyBearMinion(client, vecPos, vecAng, ally);
		}
		case MINER_NPC:
		{
			entity = Miner_Enemy(client, vecPos, vecAng, ally);
		}
		case HEADCRAB_ZOMBIE:
		{
			entity = HeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case HEADCRAB_ZOMBIE_ELECTRO:
		{
			entity = HeadcrabZombieElectro(client, vecPos, vecAng, ally);
		}
		case POISON_ZOMBIE:
		{
			entity = PoisonZombie(client, vecPos, vecAng, ally);
		}
		case EXPLOSIVE_ZOMBIE:
		{
			entity = ExplosiveHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case ZOMBIEFIED_COMBINE_SWORDSMAN:
		{
			entity = ZombiefiedCombineSwordsman(client, vecPos, vecAng, ally);
		}
		case BOB_THE_TARGETDUMMY:
		{
			entity = BobTheTargetDummy(client, vecPos, vecAng, ally);
		}
		case FAST_ZOMBIE:
		{
			entity = FastZombie(client, vecPos, vecAng, ally);
		}
		case FATHER_GRIGORI:
		{
			entity = EnemyFatherGrigori(client, vecPos, vecAng, ally);
		}
		case FARM_COW:
		{
			entity = FarmCow(client, vecPos, vecAng, ally);
		}
		case ARK_SLUG:
		{
			entity = ArkSlug(client, vecPos, vecAng, ally);
		}
		case ARK_SINGER:
		{
			entity = ArkSinger(client, vecPos, vecAng, ally);
		}
		case ARK_SLUGACID:
		{
			entity = ArkSlugAcid(client, vecPos, vecAng, ally);
		}
		case ARK_SLUG_INFUSED:
		{
			entity = ArkSlugInfused(client, vecPos, vecAng, ally);
		}
		case COMBINE_PISTOL:
		{
			entity = CombinePistol(client, vecPos, vecAng, ally);
		}
		case COMBINE_SMG:
		{
			entity = CombineSMG(client, vecPos, vecAng, ally);
		}
		case COMBINE_AR2:
		{
			entity = CombineAR2(client, vecPos, vecAng, ally);
		}
		case COMBINE_ELITE:
		{
			entity = CombineElite(client, vecPos, vecAng, ally);
		}
		case COMBINE_SHOTGUN:
		{
			entity = CombineShotgun(client, vecPos, vecAng, ally);
		}
		case COMBINE_SWORDSMAN:
		{
			entity = CombineSwordsman(client, vecPos, vecAng, ally);
		}
		case COMBINE_GIANT:
		{
			entity = CombineGiant(client, vecPos, vecAng, ally);
		}
		case COMBINE_OVERLORD:
		{
			entity = CombineOverlord(client, vecPos, vecAng, ally);
		}
		case TOWNGUARD_PISTOL:
		{
			entity = TownGuardPistol(client, vecPos, vecAng, ally);
		}
		case COMBINE_OVERLORD_CC:
		{
			entity = CombineOverlordCC(client, vecPos, vecAng, ally);
		}
		case COMBINE_TURTLE:
		{
			entity = CombineTurtle(client, vecPos, vecAng, ally);
		}
		case FARM_BEAR:
		{
			entity = FarmBear(client, vecPos, vecAng, ally);
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
		case START_CHICKEN:
		{
			StartChicken_NPCDeath(entity);
		}
		case MAD_CHICKEN:
		{
			MadChicken_NPCDeath(entity);
		}
		case MAD_ROOST:
		{
			MadRoost_NPCDeath(entity);
		}
		case HEAVY_BEAR:
		{
			HeavyBear_NPCDeath(entity);
		}
		case HEAVY_BEAR_BOSS:
		{
			HeavyBearBoss_NPCDeath(entity);
		}
		case HEAVY_BEAR_MINION:
		{
			HeavyBearMinion_NPCDeath(entity);
		}
		case MINER_NPC:
		{
			Miner_Enemy_NPCDeath(entity);
		}
		case HEADCRAB_ZOMBIE:
		{
			HeadcrabZombie_NPCDeath(entity);
		}
		case HEADCRAB_ZOMBIE_ELECTRO:
		{
			HeadcrabZombieElectro_NPCDeath(entity);
		}
		case POISON_ZOMBIE:
		{
			PoisonZombie_NPCDeath(entity);
		}
		case EXPLOSIVE_ZOMBIE:
		{
			ExplosiveHeadcrabZombie_NPCDeath(entity);
		}
		case ZOMBIEFIED_COMBINE_SWORDSMAN:
		{
			ZombiefiedCombineSwordsman_NPCDeath(entity);
		}
		case BOB_THE_TARGETDUMMY:
		{
			BobTheTargetDummy_NPCDeath(entity);
		}
		case FAST_ZOMBIE:
		{
			FastZombie_NPCDeath(entity);
		}
		case FATHER_GRIGORI:
		{
			EnemyFatherGrigori_NPCDeath(entity);
		}
		case FARM_COW:
		{
			FarmCow_NPCDeath(entity);
		}
		case ARK_SLUG:
		{
			ArkSlug_NPCDeath(entity);
		}
		case ARK_SINGER:
		{
			ArkSinger_NPCDeath(entity);
		}
		case ARK_SLUGACID:
		{
			ArkSlugAcid_NPCDeath(entity);
		}
		case ARK_SLUG_INFUSED:
		{
			ArkSlugInfused_NPCDeath(entity);
		}
		case COMBINE_PISTOL:
		{
			CombinePistol_NPCDeath(entity);
		}
		case COMBINE_SMG:
		{
			CombineSMG_NPCDeath(entity);
		}
		case COMBINE_AR2:
		{
			CombineAR2_NPCDeath(entity);
		}
		case COMBINE_ELITE:
		{
			CombineElite_NPCDeath(entity);
		}
		case COMBINE_SHOTGUN:
		{
			CombineShotgun_NPCDeath(entity);
		}
		case COMBINE_SWORDSMAN:
		{
			CombineSwordsman_NPCDeath(entity);
		}
		case COMBINE_GIANT:
		{
			CombineGiant_NPCDeath(entity);
		}
		case COMBINE_OVERLORD:
		{
			CombineOverlord_NPCDeath(entity);
		}
		case TOWNGUARD_PISTOL:
		{
			TownGuardPistol_NPCDeath(entity);
		}
		case COMBINE_OVERLORD_CC:
		{
			CombineOverlordCC_NPCDeath(entity);
		}
		case COMBINE_TURTLE:
		{
			CombineTurtle_NPCDeath(entity);
		}
		case FARM_BEAR:
		{
			FarmBear_NPCDeath(entity);
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

public void NPC_Despawn(int entity)
{
	if(IsValidEntity(entity))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
		if(IsValidEntity(npc.m_iTextEntity1))
			RemoveEntity(npc.m_iTextEntity1);
		if(IsValidEntity(npc.m_iTextEntity2))
			RemoveEntity(npc.m_iTextEntity2);
		if(IsValidEntity(npc.m_iTextEntity3))
			RemoveEntity(npc.m_iTextEntity3);
		if(IsValidEntity(npc.m_iTextEntity4))
			RemoveEntity(npc.m_iTextEntity4);

		RemoveEntity(entity);
	}
}

void Npc_Base_Thinking(int entity, float distance, const char[] WalkBack, const char[] StandStill, float walkspeedback, float gameTime, bool walkback_use_sequence = false, bool standstill_use_sequence = false)
{
	CClotBody npc = view_as<CClotBody>(entity);
	
	if(npc.m_flGetClosestTargetTime < gameTime) //Find a new victim to destroy.
	{
		if(b_NpcIsInADungeon[npc.index])
		{
			distance = 99999.9;
		}
		int entity_found = GetClosestTarget(npc.index, false, distance);
		if(npc.m_flGetClosestTargetNoResetTime > gameTime) //We want to make sure that their aggro doesnt get reset instantly!
		{
			if(entity_found != -1) //Dont reset it, but if its someone else, allow it.
			{
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, entity_found);
				if((b_NpcIsInADungeon[npc.index]) || (IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))) //Can i even see this enemy that i want to go to newly?
				{
					if(b_NpcIsInADungeon[npc.index])
					{
						npc.m_iTarget = entity_found;
					}
					else
					{
						//found enemy, go to new enemy
						npc.m_iTarget = Enemy_I_See;
					}
				}
			}
		}
		else //Allow the reset of aggro.
		{
			if(entity_found != -1) //Dont reset it, but if its someone else, allow it.
			{
				int Enemy_I_See;
								
				Enemy_I_See = Can_I_See_Enemy(npc.index, entity_found);
				if((b_NpcIsInADungeon[npc.index]) || (IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See)))
				{
					if(b_NpcIsInADungeon[npc.index])
					{
						npc.m_iTarget = entity_found;
					}
					else
					{
						//found enemy, go to new enemy
						npc.m_iTarget = Enemy_I_See;
					}
				}
			}
			else //can reset to -1
			{
				npc.m_iTarget = entity_found;
			}
		}
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		i_NoEntityFoundCount[npc.index] += 1; //no enemy found, increment a few times.
		if(i_NoEntityFoundCount[npc.index] > 11) //There was no enemies found after like 11 tries, which is a second. go back to our spawn position.
		{	
			float vecTarget[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecTarget);

			float fl_DistanceToOriginalSpawn = GetVectorDistance(vecTarget, f3_SpawnPosition[npc.index], true);
			if(fl_DistanceToOriginalSpawn > (80.0 * 80.0)) //We are too far away from our home! return!
			{
				NPC_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					if(walkback_use_sequence)
					{
						npc.AddActivityViaSequence(WalkBack);
					}
					else
					{
						npc.SetActivity(WalkBack);
					}
				}

			}
			else
			{
				//We now afk and are back in our spawnpoint heal back up, but not instantly incase they quickly can attack again.

				int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
				int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

				int HealthToHealPerIncrement = MaxHealth / 100;

				if(HealthToHealPerIncrement < 1) //should never be 0
				{
					HealthToHealPerIncrement = 1;
				}

				SetEntProp(npc.index, Prop_Data, "m_iHealth", Health + HealthToHealPerIncrement);
				

				if((Health + HealthToHealPerIncrement) >= MaxHealth)
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
				}
				//Slowly heal when we are standing still.

				Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

				npc.m_bisWalking = false;
				if(npc.m_iChanged_WalkCycle != 5) 	//Stand still.
				{
					npc.m_iChanged_WalkCycle = 5;
					if(standstill_use_sequence)
					{
						npc.AddActivityViaSequence(StandStill);
					}
					else
					{
						npc.SetActivity(StandStill);
					}
				}

				char HealthString[512];
				Format(HealthString, sizeof(HealthString), "%i / %i", Health, MaxHealth);

				if(IsValidEntity(npc.m_iTextEntity3))
				{
					DispatchKeyValue(npc.m_iTextEntity3, "message", HealthString);
				}
			}
		}
		npc.m_flGetClosestTargetTime = 0.0;
	}
	else
	{
		if(npc.m_flDoingAnimation < GetGameTime())
		{
			if(ShouldNpcJumpAtThisClient(npc.m_iTarget))
			{
				float vecMe[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe);
				float vecTarget[3];
				GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", vecTarget);

				if((vecTarget[2] - vecMe[2]) > 100.0 && (vecTarget[2] - vecMe[2]) < 250.0)
				{
					vecMe[2] = vecTarget[2];
					//Height should not be a factor in this calculation.
					float f_DistanceForJump = GetVectorDistance(vecMe, vecTarget, true);
					if(f_DistanceForJump < (200.0 * 200.0)) //Are they close enough for us to even jump after them..?
					{
						if((GetGameTime() - npc.m_flJumpStartTimeInternal) < 2.0)
							return;

						npc.m_flJumpStartTimeInternal = GetGameTime();

						vecTarget[2] += 50.0;

						PluginBot_Jump(npc.index, vecTarget);
					}
				}
			}
		}
		i_NoEntityFoundCount[npc.index] = 0;

	}

	if(!npc.m_bisWalking) //Dont move, or path. so that he doesnt rotate randomly, also happens when they stop follwing.
	{
		if(walkspeedback != 0.0)
		{
			npc.m_flSpeed = 0.0;
		}
		if(npc.m_bPathing)
		{
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;	
		}
	}
	else
	{
		if(walkspeedback != 0.0)
		{
			npc.m_flSpeed = walkspeedback;
		}
		if(!npc.m_bPathing)
			npc.StartPathing();
	}
}
Action NpcSpecificOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	switch(i_NpcInternalId[victim])
	{
		
	}
}

bool ShouldNpcJumpAtThisClient(int client)
{
	bool AllowJump = true;

	if(AbilityGroundPoundReturnFloat(client) > GetGameTime())
	{
		AllowJump = false;
	}
	return AllowJump;
}

bool AllyNpcInteract(int client, int entity, int weapon)
{
	bool result;
	switch(i_NpcInternalId[entity])
	{
		case FARM_COW:
		{
			result = HeavyCow_Interact(client, weapon);
		}
		case FARM_BEAR:
		{
			result = HeavyBear_Interact(client, weapon);
		}
	}
	return result;
}

#include "rpg_fortress/npc/normal/npc_chicken_2.sp"
#include "rpg_fortress/npc/normal/npc_chicken_mad.sp"
#include "rpg_fortress/npc/normal/npc_roost_mad.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear_boss.sp"
#include "rpg_fortress/npc/normal/npc_heavy_bear_minion.sp"
#include "rpg_fortress/npc/normal/npc_miner.sp"

#include "rpg_fortress/npc/normal/npc_headcrab_zombie.sp"
#include "rpg_fortress/npc/normal/npc_headcrab_zombie_electro.sp"
#include "rpg_fortress/npc/normal/npc_poison_zombie.sp"
#include "rpg_fortress/npc/normal/npc_headcrab_zombie_explosive.sp"
#include "rpg_fortress/npc/normal/npc_zombiefied_combine_soldier_swordsman.sp"
#include "rpg_fortress/npc/normal/npc_bob_the_targetdummy.sp"
#include "rpg_fortress/npc/normal/npc_fastzombie.sp"
#include "rpg_fortress/npc/normal/npc_enemy_grigori.sp"

#include "rpg_fortress/npc/farm/npc_heavy_cow.sp"
#include "rpg_fortress/npc/farm/npc_heavy_bear.sp"

#include "rpg_fortress/npc/normal/npc_ark_slug.sp"
#include "rpg_fortress/npc/normal/npc_ark_singer.sp"
#include "rpg_fortress/npc/normal/npc_ark_slug_acid.sp"
#include "rpg_fortress/npc/normal/npc_ark_slug_infused.sp"

#include "rpg_fortress/npc/combine/npc_basesquad.sp"
#include "rpg_fortress/npc/combine/npc_combine_pistol.sp"
#include "rpg_fortress/npc/combine/npc_combine_smg.sp"
#include "rpg_fortress/npc/combine/npc_combine_ar2.sp"
#include "rpg_fortress/npc/combine/npc_combine_elite.sp"
#include "rpg_fortress/npc/combine/npc_combine_shotgun.sp"
#include "rpg_fortress/npc/combine/npc_combine_swordsman.sp"
#include "rpg_fortress/npc/combine/npc_combine_giant.sp"
#include "rpg_fortress/npc/combine/npc_combine_overlord.sp"
#include "rpg_fortress/npc/combine/npc_townguard_pistol.sp"
#include "rpg_fortress/npc/combine/npc_combine_overlord_cc.sp"
#include "rpg_fortress/npc/combine/npc_combine_turtle.sp"