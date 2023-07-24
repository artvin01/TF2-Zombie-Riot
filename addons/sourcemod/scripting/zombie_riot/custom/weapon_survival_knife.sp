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
Handle Timer_Knife_Management[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static int Projectile_To_Weapon[MAXENTITIES]={0, ...};

static float Damage_Projectile[MAXENTITIES]={0.0, ...};
static float f_KnifeHudDelay[MAXENTITIES]={0.0, ...};
static int Projectile_To_Client[MAXENTITIES]={0, ...};
static int Projectile_To_Particle[MAXENTITIES]={0, ...};

#define KNIFE_SPEED_1 2500.0
#define KNIFE_SPEED_2 2700.0
#define KNIFE_SPEED_3 3000.0



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
	if (Timer_Knife_Management[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Knife_Management[client]);
	}	
	Timer_Knife_Management[client] = INVALID_HANDLE;
}


public void Survival_Knife_Attack(int client, int weapon, bool crit)
{
	return;
}

public void Enable_Management_Knife(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (Timer_Knife_Management[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == 10) //10 Is for Survival Knife
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
			}

			//Is the weapon it again?
			//Yes?
			KillTimer(Timer_Knife_Management[client]);
			Timer_Knife_Management[client] = INVALID_HANDLE;
			DataPack pack;
			Timer_Knife_Management[client] = CreateDataTimer(0.1, Timer_Management_Survival, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == 10) //10 Is for Survival Knife
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
		}

		DataPack pack;
		Timer_Knife_Management[client] = CreateDataTimer(0.1, Timer_Management_Survival, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Management_Survival(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());

	if (!IsValidMulti(client))
		Kill_Timer_Management(client);
		
	if(IsValidEntity(weapon))
	{
		if (IsPlayerAlive(client))
		{
			if (CD_Knife[client]<=GetGameTime())
			{
				if(Knife_Max[client] > Knife_Count[client])
				{
						
					Knife_Count[client]++;

					CD_Knife[client] = GetGameTime() + CD_KnifeSet[client];
				}
			}
			if(f_KnifeHudDelay[client] < GetGameTime())
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					int iTier = i_SurvivalKnifeCount[weapon];
					if(iTier == 2)
					{
						if(Knife_Count[client] != Knife_Max[client])
						{
							if(Knife_Triple_Mode[client])
							{
								PrintHintText(client,"Triple Throw! Knives [%i/%i] (Recharge in: %.1f)",Knife_Count[client], Knife_Max[client],CD_Knife[client]-GetGameTime());
							}
							else
							{
								PrintHintText(client,"Knives [%i/%i] (Recharge in: %.1f)",Knife_Count[client], Knife_Max[client],CD_Knife[client]-GetGameTime());
							}
						}
						else
						{
							if(Knife_Triple_Mode[client])
							{
								PrintHintText(client,"Triple Throw! Knives [%i/%i]",Knife_Count[client],Knife_Max[client]);
							}
							else
							{
								PrintHintText(client,"Knives [%i/%i]",Knife_Count[client],Knife_Max[client]);	
							}
						}
					}
					else if(InMadness[client])
					{
						PrintHintText(client,"Infinite Knives!");				
					}
					else
					{
						if(Knife_Count[client] != Knife_Max[client])
						{
							PrintHintText(client,"Knives [%i/%i] (Recharge in: %.1f)",Knife_Count[client], Knife_Max[client],CD_Knife[client]-GetGameTime());
						}
						else
						{
							PrintHintText(client,"Knives [%i/%i]",Knife_Count[client],Knife_Max[client]);
						}							
					}

					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
					f_KnifeHudDelay[client] = GetGameTime() + 0.5;
				}
			}
		}
		else
			Kill_Timer_Management(client);
	}
	else
		Kill_Timer_Management(client);
		
	return Plugin_Continue;
}

public void Kill_Timer_Management(int client)
{
	if (Timer_Knife_Management[client] != INVALID_HANDLE)
	{
		KillTimer(Timer_Knife_Management[client]);
		Timer_Knife_Management[client] = INVALID_HANDLE;
	}
}

public void Survival_Knife_Tier1_Alt(int client, int weapon, bool crit, int slot)
{
	if (CD_Throw[client]>GetGameTime())
		return;
	
	if(Knife_Count[client]>0)
	{
		Knife_Count[client] -= 1;
		CD_Throw[client] = GetGameTime() + 0.3; // prevent spamming, idk if you already have something for that but hee
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
	CD_Mode[client] = GetGameTime() + 0.3;
}

public void Survival_Knife_Tier2_Alt(int client, int weapon, bool crit, int slot)
{

	if (CD_Throw[client]>GetGameTime())
		return;
	
	if (!Knife_Triple_Mode[client])
	{
		if(Knife_Count[client]>0)
		{
			Knife_Count[client] -= 1;
			CD_Throw[client] = GetGameTime() + 0.3; // prevent spamming, idk if you already have something for that but hee
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
			CD_Throw[client] = GetGameTime() + 0.3; // prevent spamming, idk if you already have something for that but hee
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

	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		EmitSoundToAll(SOUND_MADNESS_ENTER2, client, SNDCHAN_STATIC, 70, _, 0.9);
		EmitSoundToAll(SOUND_MADNESS_ENTER, client, SNDCHAN_STATIC, 70, _, 0.9);
		
		InMadness[client] = true;
		
		ApplyTempAttrib(weapon, 6, 0.7, 5.0);
		ApplyTempAttrib(weapon, 205, 0.65, 5.0);
		ApplyTempAttrib(weapon, 206, 0.65, 5.0);
		int flMaxHealth = SDKCall_GetMaxHealth(client);
		int flHealth = GetClientHealth(client);
		
		int health = flMaxHealth / 5;

		flHealth -= health;
		if((flHealth) < 1)
		{
			flHealth = 1;
		}

		SetEntityHealth(client, flHealth); // Self dmg

		DataPack pack;
		CreateDataTimer(5.0, Timer_Madness_Duration, pack, TIMER_FLAG_NO_MAPCHANGE);// Madness duration
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));

		Ability_Apply_Cooldown(client, slot, 15.0);
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
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client))
		{
			InMadness[client] = false;
			
			EmitSoundToAll(SOUND_MADNESS_END, client, SNDCHAN_STATIC, 70, _, 0.9);
			
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Madness ends");
			
			CreateTimer(10.0, Timer_Reable_Madness, client, TIMER_FLAG_NO_MAPCHANGE); // Next Madness
		}
	}
	InMadness[client] = false;
	return Plugin_Handled;
}

public Action Timer_Reable_Madness(Handle timer, int client)
{
	if (IsClientInGame(client))
	{
		if (IsPlayerAlive(client))
		{
			EmitSoundToAll(SOUND_MADNESS_BACK, client, SNDCHAN_STATIC, 70, _, 0.9);
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Madness is back... Idk if it's a good thing");
		}
	}
	return Plugin_Handled;
}

public void Survival_Knife_Tier3_Alt(int client, int weapon, bool crit, int slot)
{

	if (CD_Throw[client]>GetGameTime())
		return;
	
	if (!InMadness[client])
	{
		if(Knife_Count[client]>0)
		{
			Knife_Count[client] -= 1;
			CD_Throw[client] = GetGameTime() + 0.3; // prevent spamming, idk if you already have something for that but hee
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
			CD_Throw[client] = GetGameTime() + 0.3; // prevent spamming, idk if you already have something for that but hee
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
	float damage = 75.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	int iRot = CreateEntityByName("func_door_rotating");
	if(iRot == -1) return;
	
	DispatchKeyValueVector(iRot, "origin", fPos);
	DispatchKeyValue(iRot, "distance", "99999");
	DispatchKeyValueFloat(iRot, "speed", speed);
	DispatchKeyValue(iRot, "spawnflags", "12288"); // passable|silent
	DispatchSpawn(iRot);
	SetEntityCollisionGroup(iRot, 27);
	
	SetVariantString("!activator");
	AcceptEntityInput(iRot, "Open");
	ClientCommand(client, "playgamesound weapons/cleaver_throw.wav");
	
	float time = 10.0;
	//	CreateTimer(0.1, Timer_HatThrow_Woosh, EntIndexToEntRef(iRot), TIMER_REPEAT);
	Wand_Launch(client, iRot, speed, time, damage, iModel, weapon);
	
	/*
	int Knife = SDKCall_CTFCreateArrow(fPos, fAng, flSpeed, 0.25, 8, client, client); // 0.2 gravity, not a sniper knife too
	if(IsValidEntity(Knife))
	{
		ClientCommand(client, "playgamesound weapons/cleaver_throw.wav");
		
		SetEntityCollisionGroup(Knife, 27);
		SetEntDataFloat(Knife, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);	// Damage
		SetEntPropEnt(Knife, Prop_Send, "m_hOriginalLauncher", weapon);
		SetEntPropEnt(Knife, Prop_Send, "m_hLauncher", weapon);
		SetEntProp(Knife, Prop_Send, "m_bCritical", false);
		
		switch(iModel)
		{
			case 1:SetEntityModel(Knife, MODEL_KUNAI);
			case 2: SetEntityModel(Knife, MODEL_WANGA);
	   		default: SetEntityModel(Knife, MODEL_KNIFE);
	  	}
	}
	
	Dont use this, its arrow/bullet dmg, so anything barbarians mind will make it not work, but its a melee, time to use wand logic! 
	*/
}


static void Wand_Launch(int client, int iRot, float speed, float time, float damage, int model, int weapon)
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);

	int iCarrier = CreateEntityByName("prop_physics_override");
	if(iCarrier == -1) return;

	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	SetEntPropEnt(iCarrier, Prop_Send, "m_hOwnerEntity", client);
	switch(model)
	{
		case 1:DispatchKeyValue(iCarrier, "model", MODEL_KUNAI);
		case 2: DispatchKeyValue(iCarrier, "model", MODEL_WANGA);
		default: DispatchKeyValue(iCarrier, "model", MODEL_KNIFE);
	}
	DispatchKeyValue(iCarrier, "modelscale", "1");
	DispatchSpawn(iCarrier);
	
	TeleportEntity(iCarrier, fPos, NULL_VECTOR, fVel);
	SetEntityMoveType(iCarrier, MOVETYPE_FLY);
	
	SetEntProp(iCarrier, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(iRot, Prop_Send, "m_iTeamNum", GetClientTeam(client));

	SetVariantString("!activator");
	AcceptEntityInput(iRot, "SetParent", iCarrier, iRot, 0);
	SetEntityCollisionGroup(iCarrier, 27);
	
	Projectile_To_Client[iCarrier] = client;
	Damage_Projectile[iCarrier] = damage;
	Projectile_To_Weapon[iCarrier] = EntIndexToEntRef(weapon);
	float position[3];
	
	GetEntPropVector(iCarrier, Prop_Data, "m_vecAbsOrigin", position);
	
	int particle = 0;
	
	switch(GetClientTeam(client))
	{
		case 2:
			particle = ParticleEffectAt(position, "raygun_projectile_red_crit", 5.0);

		default:
			particle = ParticleEffectAt(position, "raygun_projectile_red_blue", 5.0);
	}
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	TeleportEntity(particle, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iCarrier, NULL_VECTOR, Angles, NULL_VECTOR);
	TeleportEntity(iRot, NULL_VECTOR, Angles, NULL_VECTOR);
	
	SetParent(iCarrier, particle);	
	
	Projectile_To_Particle[iCarrier] = EntIndexToEntRef(particle);
	/*
	SetEntityRenderMode(iCarrier, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iCarrier, 255, 255, 255, 0);
	*/
	DataPack pack;
	CreateDataTimer(time, Timer_RemoveEntity_CustomProjectile, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iCarrier));
	pack.WriteCell(EntIndexToEntRef(particle));
	pack.WriteCell(EntIndexToEntRef(iRot));
		
	SDKHook(iCarrier, SDKHook_StartTouch, Event_Knife_Touch);
}

public Action Event_Knife_Touch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(target);
		//Code to do damage position and ragdolls
		
		int weapon = EntRefToEntIndex(Projectile_To_Weapon[entity]);
		SDKHooks_TakeDamage(target, Projectile_To_Client[entity], Projectile_To_Client[entity], Damage_Projectile[entity], DMG_CLUB, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_KNIFE_HIT_FLESH, entity, SNDCHAN_STATIC, 80, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(Projectile_To_Particle[entity]);
		if(IsValidEntity(particle) && particle != 0)
		{
			EmitSoundToAll(SOUND_KNIFE_HIT_GROUND, entity, SNDCHAN_STATIC, 80, _, 0.9);
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}