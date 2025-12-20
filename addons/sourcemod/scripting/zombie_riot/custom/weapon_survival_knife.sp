#pragma semicolon 1
#pragma newdecls required

static float CD_Knife[MAXPLAYERS+1]={0.0, ...};
static float CD_KnifeSet[MAXPLAYERS+1]={0.0, ...};
static float CD_Throw[MAXPLAYERS+1]={0.0, ...};
static float CD_Mode[MAXPLAYERS+1]={0.0, ...};
static int Knife_Count[MAXPLAYERS+1]={0, ...};
static int Knife_Max[MAXPLAYERS+1]={0, ...};
static bool Knife_Triple_Mode[MAXPLAYERS+1]={false, ...};
static bool InMadness[MAXPLAYERS+1]={false, ...};
Handle Timer_Knife_Management[MAXPLAYERS+1] = {null, ...};
static float f_KnifeHudDelay[MAXENTITIES]={0.0, ...};

#define KNIFE_SPEED_1 2500.0
#define KNIFE_SPEED_2 2700.0
#define KNIFE_SPEED_3 3000.0

bool IsSurvivalKnife(int weaponid)
{
	if(weaponid == WEAPON_10 || weaponid == WEAPON_SURVIVAL_KNIFE_PAP1 || weaponid == WEAPON_SURVIVAL_KNIFE_PAP2 || weaponid == WEAPON_SURVIVAL_KNIFE_PAP3)
		return true;
	
	return false;
}

public void Survival_Knife_ClearAll()
{
	Zero(CD_Knife);
	Zero(CD_KnifeSet);
	Zero(CD_Throw);
	Zero(CD_Mode);
	Zero(f_KnifeHudDelay);
}

#define MODEL_KNIFE 	"models/weapons/c_models/c_knife/c_knife.mdl"
#define MODEL_KUNAI 	"models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl"
#define MODEL_WANGA 	"models/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl"
#define SOUND_MADNESS_BACK		"items/taunts/killer_solo/killer_solo_01.mp3"
#define SOUND_MADNESS_ENTER		"items/pyro_guitar_solo_no_verb.wav"
#define SOUND_MADNESS_ENTER2	"weapons/halloween_boss/knight_axe_hit.wav"
#define SOUND_MADNESS_END	"misc/killstreak.wav"

#define SOUND_KNIFE_HIT_FLESH "weapons/fx/rics/arrow_impact_flesh.wav"
#define SOUND_KNIFE_HIT_GROUND "weapons/fx/rics/arrow_impact_concrete.wav"

void Survival_Knife_Map_Precache()
{
	PrecacheModel(MODEL_KNIFE);
	PrecacheModel(MODEL_KUNAI);
	PrecacheModel(MODEL_WANGA);
	PrecacheSound(SOUND_MADNESS_BACK);
	PrecacheSound(SOUND_MADNESS_ENTER);
	PrecacheSound(SOUND_MADNESS_ENTER2);
	PrecacheSound(SOUND_MADNESS_END);
	PrecacheSound(SOUND_KNIFE_HIT_FLESH);
	PrecacheSound(SOUND_KNIFE_HIT_GROUND);
	
}

void Reset_stats_Survival_Singular(int client) //This is on disconnect/connect
{
	if (Timer_Knife_Management[client] != null)
	{
		delete Timer_Knife_Management[client];
	}	
	Timer_Knife_Management[client] = null;
}


public void Survival_Knife_Attack(int client, int weapon, bool crit)
{
	return;
}

public void Enable_Management_Knife(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Knife_Management[client] != null)
	{
		//This timer already exists.
		if(IsSurvivalKnife(i_CustomWeaponEquipLogic[weapon])) //10 Is for Survival Knife
		{
			int iTier = i_SurvivalKnifeCount[weapon];
			
			CD_Knife[client] = GetGameTime() + 5.0;
			switch(iTier)
			{
				case 1:
				{
					CD_KnifeSet[client] = 5.0;	// Cd for knife
					Knife_Max[client] = 3;	// Max knife
			//		Knife_Count[client] = 3;	// Knife count
				}
					
				case 2:
				{
					CD_KnifeSet[client] = 4.5;	// Cd for knife
					Knife_Max[client] = 6;	// Max knife
			//		Knife_Count[client] = 6;	// Knife count
				}
					
				case 3:
				{
					CD_KnifeSet[client] = 3.3;	// Cd for knife
					Knife_Max[client] = 7;	// Max knife
			//		Knife_Count[client] = 7;	// Knife count
				}
				
				case 4:
				{
					CD_KnifeSet[client] = 2.8;	// Cd for knife
					Knife_Max[client] = 8;	// Max knife
			//		Knife_Count[client] = 7;	// Knife count
				}
			}

			//Is the weapon it again?
			//Yes?
			delete Timer_Knife_Management[client];
			Timer_Knife_Management[client] = null;
			DataPack pack;
			Timer_Knife_Management[client] = CreateDataTimer(0.1, Timer_Management_Survival, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(IsSurvivalKnife(i_CustomWeaponEquipLogic[weapon])) //10 Is for Survival Knife
	{
		int iTier = i_SurvivalKnifeCount[weapon];
			
		CD_Knife[client] = GetGameTime() + 5.0;
		switch(iTier)
		{
			case 1:
			{
				CD_KnifeSet[client] = 5.0;	// Cd for knife
				Knife_Max[client] = 3;	// Max knife
		//		Knife_Count[client] = 3;	// Knife count
			}
				
			case 2:
			{
				CD_KnifeSet[client] = 4.5;	// Cd for knife
				Knife_Max[client] = 6;	// Max knife
		//		Knife_Count[client] = 6;	// Knife count
			}
				
			case 3:
			{
				CD_KnifeSet[client] = 3.3;	// Cd for knife
				Knife_Max[client] = 7;	// Max knife
		//		Knife_Count[client] = 7;	// Knife count
			}
			
			case 4:
			{
				CD_KnifeSet[client] = 2.8;	// Cd for knife
				Knife_Max[client] = 8;	// Max knife
		//		Knife_Count[client] = 7;	// Knife count
			}
		}

		DataPack pack;
		Timer_Knife_Management[client] = CreateDataTimer(0.1, Timer_Management_Survival, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Management_Survival(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Timer_Knife_Management[client] = null;
		return Plugin_Stop;
	}	
		
	if (CD_Knife[client]<=GetGameTime())
	{
		if(Knife_Max[client] > Knife_Count[client])
		{
				
			Knife_Count[client]++;

			CD_Knife[client] = GetGameTime() + (CD_KnifeSet[client] * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee
		}
	}
	if(f_KnifeHudDelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(InMadness[client])
			{
				PrintHintText(client,"무한의 검날!");				
			}
			else
			{
				if(Knife_Count[client] != Knife_Max[client])
				{
					PrintHintText(client,"칼 [%i/%i] (재충전까지 : %.1f)",Knife_Count[client], Knife_Max[client],CD_Knife[client]-GetGameTime());
				}
				else
				{
					PrintHintText(client,"칼 [%i/%i]",Knife_Count[client],Knife_Max[client]);
				}							
			}

			
			f_KnifeHudDelay[client] = GetGameTime() + 0.5;
		}
	}
		
	return Plugin_Continue;
}

public void Survival_Knife_Tier1_Alt(int client, int weapon, bool crit, int slot)
{
	if (CD_Throw[client]>GetGameTime())
		return;

	CD_Throw[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee

	if(Knife_Count[client]>0)
	{
		Knife_Count[client] -= 1;
		Throw_Knife(client, weapon, KNIFE_SPEED_1, 0);
		
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t" , "Knife Amount", Knife_Count[client]);
		if(Knife_Count[client] <= 0)
		{
			Ability_Apply_Cooldown(client, slot, CD_Knife[client]-GetGameTime());	
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "No Knifes left", CD_Knife[client]-GetGameTime());
	}
}

public void Survival_Knife_Tier2_Reload(int client, int weapon, bool crit)
{
	if (CD_Mode[client]>GetGameTime())
		return;
	
	Knife_Triple_Mode[client] = (!Knife_Triple_Mode[client]);
	CD_Mode[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0));
}

public void Survival_Knife_Tier2_Alt(int client, int weapon, bool crit, int slot)
{
	if (CD_Throw[client]>GetGameTime())
		return;
		
	CD_Throw[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee
	if (!Knife_Triple_Mode[client])
	{
		if(Knife_Count[client]>0)
		{
			Knife_Count[client] -= 1;
			CD_Throw[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee
			Throw_Knife(client, weapon, KNIFE_SPEED_2, 1);
			
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t" , "Knife Amount", Knife_Count[client]);
			if(Knife_Count[client] <= 0)
			{
				Ability_Apply_Cooldown(client, slot, CD_Knife[client]-GetGameTime());	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "No Knifes left", CD_Knife[client]-GetGameTime());
		}
	}
	else
	{
		if(Knife_Count[client]>=3)
		{
			Knife_Count[client] -= 3;
			CD_Throw[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee
			Throw_Knife(client, weapon, KNIFE_SPEED_2, 1);

			DataPack pack = new DataPack();
			CreateTimer(0.1, Timer_Throw_Extra_Knife, pack, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.2, Timer_Throw_Extra_Knife, pack, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Knife Amount", Knife_Count[client]);
			if(Knife_Count[client] <= 0)
			{
				Ability_Apply_Cooldown(client, slot, CD_Knife[client]-GetGameTime());	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "No Knifes left ability", Knife_Count[client], CD_Knife[client]-GetGameTime());
		}
	}
}

public void Survival_Knife_Tier3_Reload(int client, int weapon, bool crit, int slot)
{
	if (InMadness[client])
		return;
	
	if(Ability_Check_Cooldown(client, slot) < 0.0 && !(GetClientButtons(client) & IN_DUCK) && NeedCrouchAbility(client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Crouch for ability");	
		return;
	}
	
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(client, weapon);
		EmitSoundToAll(SOUND_MADNESS_ENTER2, client, SNDCHAN_STATIC, 70, _, 0.9);
		EmitSoundToAll(SOUND_MADNESS_ENTER, client, SNDCHAN_STATIC, 70, _, 0.9);
	
		ApplyTempAttrib(weapon, 6, 0.7, 5.0);
		ApplyTempAttrib(weapon, 205, 0.65, 5.0);
		ApplyTempAttrib(weapon, 206, 0.65, 5.0);
		int flMaxHealth = SDKCall_GetMaxHealth(client);
		int flHealth = GetClientHealth(client);
		
		int health = flMaxHealth / 4;
		f_TimeUntillNormalHeal[client] = GetGameTime() + 4.0;

		flHealth -= health;
		if((flHealth) < 1)
		{
			flHealth = 1;
		}

		SetEntityHealth(client, flHealth); // Self dmg

		DataPack pack;
		CreateDataTimer(5.0, Timer_Madness_Duration, pack, TIMER_FLAG_NO_MAPCHANGE);// Madness duration
		pack.WriteCell(client);
		InMadness[client] = true;

		Ability_Apply_Cooldown(client, slot, 60.0);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
	}
}

public Action Timer_Madness_Duration(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	InMadness[client] = false;
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client))
		{
			EmitSoundToClient(client,SOUND_MADNESS_END, client, SNDCHAN_STATIC, 70, _, 0.9);
			
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Madness ends");
		}
	}
	return Plugin_Handled;
}
public void Survival_Knife_Tier3_Alt(int client, int weapon, bool crit, int slot)
{

	if (CD_Throw[client]>GetGameTime())
		return;
	CD_Throw[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee
	if (!InMadness[client])
	{
		if(Knife_Count[client]>0)
		{
			Knife_Count[client] -= 1;
			CD_Throw[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee
			Throw_Knife(client, weapon, KNIFE_SPEED_3, 2);
			if(Knife_Count[client] <= 0)
			{
				Ability_Apply_Cooldown(client, slot, CD_Knife[client]-GetGameTime());	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "No Knifes left", CD_Knife[client]-GetGameTime());
		}
	}
	else
	{
		CD_Throw[client] = GetGameTime() + (0.4 * Attributes_Get(weapon, 6, 1.0)); // prevent spamming, idk if you already have something for that but hee
		Throw_Knife(client, weapon, KNIFE_SPEED_3, 2);
	}
}
public Action Timer_Throw_Extra_Knife(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client))
		{
			int weapon = EntRefToEntIndex(pack.ReadCell());
			if(weapon != INVALID_ENT_REFERENCE)
				Throw_Knife(client, weapon, KNIFE_SPEED_2, 1);
		}
	}
	return Plugin_Continue;
}

public void Throw_Knife(int client, int weapon, float speed, int iModel)
{
	f_KnifeHudDelay[client] = 0.0;
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);

	int projectile = Wand_Projectile_Spawn(client, speed, 10.0, damage, -1, weapon, "");

	if(IsValidEntity(i_WandParticle[projectile]))
		RemoveEntity(i_WandParticle[projectile]);

	int trail = Trail_Attach(projectile, ARROW_TRAIL_RED, 255, 0.3, 3.0, 3.0, 5);

	i_WandParticle[projectile]= EntIndexToEntRef(trail);
	
	//Just use a timer tbh.
	
	ClientCommand(client, "playgamesound weapons/cleaver_throw.wav");
	WandProjectile_ApplyFunctionToEntity(projectile, Event_Knife_Touch);
}

public void Event_Knife_Touch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float PushforceDamage[3];
		CalculateDamageForce(vecForward, 10000.0, PushforceDamage);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_CLUB, weapon, PushforceDamage, Entity_Position, _);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			float f3_PositionTemp[3];
			GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
			AcceptEntityInput(particle, "ClearParent");
		//	TeleportEntity(particle, f3_PositionTemp, NULL_VECTOR, NULL_VECTOR);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}
		EmitSoundToAll(SOUND_KNIFE_HIT_FLESH, entity, SNDCHAN_STATIC, 65, _, 0.65);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		WandProjectile_ApplyFunctionToEntity(entity, INVALID_FUNCTION);
		SetEntityMoveType(entity, MOVETYPE_NONE);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle) && particle != 0)
		{
			float f3_PositionTemp[3];
			GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
			EmitSoundToAll(SOUND_KNIFE_HIT_GROUND, entity, SNDCHAN_STATIC, 80, _, 0.9);
			AcceptEntityInput(particle, "ClearParent");

		//	TeleportEntity(particle, f3_PositionTemp, NULL_VECTOR, NULL_VECTOR);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		WandProjectile_ApplyFunctionToEntity(entity, INVALID_FUNCTION);
		//We delay deletion
		SetEntityMoveType(entity, MOVETYPE_NONE);
	}
}

float f_AttackDelayKnife[MAXPLAYERS];

public void Survival_Knife_ThrowBlade(int client, int weapon, bool crit, int slot)
{
	f_AttackDelayKnife[client] = 0.0;
	SDKUnhook(client, SDKHook_PreThink, SurvivalKnifeAttackM2_PreThink);
	SDKHook(client, SDKHook_PreThink, SurvivalKnifeAttackM2_PreThink);
}


public void SurvivalKnifeAttackM2_PreThink(int client)
{
	if(GetClientButtons(client) & IN_ATTACK2)
	{
		if(f_AttackDelayKnife[client] > GetGameTime())
		{
			return;
		}
		f_AttackDelayKnife[client] = GetGameTime() + 0.05;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_active < 0)
		{
			SDKUnhook(client, SDKHook_PreThink, SurvivalKnifeAttackM2_PreThink);
			return;
		}
		if(!IsSurvivalKnife(i_CustomWeaponEquipLogic[weapon_active]))
		{
			SDKUnhook(client, SDKHook_PreThink, SurvivalKnifeAttackM2_PreThink);
			return;
		}

		switch(i_CustomWeaponEquipLogic[weapon_active])
		{
			case WEAPON_10:
			{
				Survival_Knife_Tier1_Alt(client, weapon_active, false, 2);
			}
			case WEAPON_SURVIVAL_KNIFE_PAP1:
			{
				Survival_Knife_Tier2_Alt(client, weapon_active, false, 2);
			}
			case WEAPON_SURVIVAL_KNIFE_PAP2:
			{
				Survival_Knife_Tier3_Alt(client, weapon_active, false, 2);
			}
			case WEAPON_SURVIVAL_KNIFE_PAP3:
			{
				Survival_Knife_Tier3_Alt(client, weapon_active, false, 2);
			}
		}

	}
	else
	{
		SDKUnhook(client, SDKHook_PreThink, SurvivalKnifeAttackM2_PreThink);
		return;
	}
}