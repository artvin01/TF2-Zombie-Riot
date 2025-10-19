#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float ability_cooldown_2[MAXPLAYERS+1]={0.0, ...};
static int Attack3AbilitySlotArray[MAXPLAYERS+1]={0, ...};
static float f_HealDelay[MAXENTITIES];
static float f_Duration[MAXENTITIES];
static bool b_ActivatedDuringLastMann[MAXPLAYERS+1];
static int g_ProjectileModel;
static int g_ProjectileModelArmor;
int g_BeamIndex_heal = -1;
static int i_BurstpackUsedThisRound [MAXPLAYERS];
static int i_MaxMorhpinesThisRound [MAXPLAYERS];
static float f_ReinforceTillMax[MAXPLAYERS];
static bool b_ReinforceReady_soundonly[MAXPLAYERS];
static int i_MaxRevivesAWave;
static float MorphineCharge[MAXPLAYERS+1]={0.0, ...};

void GiveMorphineToEveryone()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		MorphineCharge[client] = 1.0;
	}
}

static const char g_TeleSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};


static const char g_ReinforceSounds[][] = {
	"mvm/mvm_used_powerup.wav",
};

int MaxRevivesReturn()
{
	return i_MaxRevivesAWave;
}

int MaxRevivesAllowed()
{
	int ReviveAllowMax;
	ReviveAllowMax = RoundToNearest(float(CountPlayersOnRed(0, true)) * 0.2);
	if(ReviveAllowMax <= 3)
		ReviveAllowMax = 3;

	return ReviveAllowMax;
}
static const char g_ReinforceReadySounds[] = "mvm/mvm_bought_in.wav";

static char gExplosive1;
static char gLaser1;
static char gBluePoint2;

//#define ARROW_TRAIL_GRENADE "effects/arrowtrail_blu.vmt"

//int trail = Trail_Attach(entity, ARROW_TRAIL_GRENADE, 255, 0.3, 3.0, 3.0, 5);


#define SOUND_HEAL_BEAM			"items/medshot4.wav"
#define SOUND_ARMOR_BEAM			"physics/metal/metal_box_strain1.wav"
#define SOUND_REPAIR_BEAM			"physics/metal/metal_box_strain2.wav"


public void M3_Abilities_Precache()
{
	gBluePoint2 = PrecacheModel("sprites/blueglow2.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	PrecacheModel("models/props_urban/urban_crate002.mdl", true);
//	PrecacheModel(ARROW_TRAIL_GRENADE);
//	PrecacheDecal(ARROW_TRAIL_GRENADE, true);
	static char model[PLATFORM_MAX_PATH];
	model = "models/healthvial.mdl";
	g_ProjectileModel = PrecacheModel(model);
	model = "models/Items/battery.mdl";
	g_ProjectileModelArmor = PrecacheModel(model);
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	for (int i = 0; i < (sizeof(g_TeleSounds));	   i++) { PrecacheSound(g_TeleSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_ReinforceSounds));	   i++) { PrecacheSound(g_ReinforceSounds[i]);	   }
	PrecacheSound(g_ReinforceReadySounds);
	PrecacheSound(SOUND_HEAL_BEAM);
	PrecacheSound(SOUND_ARMOR_BEAM);
	PrecacheSound(SOUND_REPAIR_BEAM);
	PrecacheSound(SOUND_DASH);
	PrecacheSound("mvm/mvm_tank_start.wav");
	PrecacheSound("weapons/air_burster_explode3.wav");
	HookEntityOutput("func_movelinear", "OnFullyOpen", OnBombDrop);
	PrecacheSound("weapons/slam/throw.wav");
}
public void M3_ClearAll()
{
	Zero(b_ActivatedDuringLastMann);
	Zero(ability_cooldown);
	Zero(ability_cooldown_2);
	Zero(Attack3AbilitySlotArray);
	Zero(f_HealDelay);
	Zero(f_Duration);
	Zero(f_ReinforceTillMax);
	Zero(MorphineCharge);
	Zero(b_ReinforceReady_soundonly);
}

public Action CommandAdminReinforce(int client, int args)
{
	if(!IsValidClient(client) || IsFakeClient(client))
	{
		PrintToConsole(client, "Command is in-game only");
		return Plugin_Handled;
	}
	Reinforce(client, true);
	
	return Plugin_Handled;
}

public void M3_Abilities(int client)
{
	switch(Attack3AbilitySlotArray[client])
	{
		case 1:
		{
			PlaceableTempomaryHealingGrenade(client);
		}
		case 2:
		{
			WeakDash(client);
		}
		case 3:
		{
			PlaceableTempomaryArmorGrenade(client);
		}
		case 4:
		{
			GearTesting(client);
		}
		case 5:
		{
			Reinforce(client, false);
		}
		case 6:
		{
			PlaceableTempomaryRepairGrenade(client);
		}
		case 7:
		{
			ReconstructiveTeleporter(client);
		}
		case 8:
		{
			MorphineShot(client);
		}
	}
}

void M3_AbilitiesWaveEnd()
{
	Zero(i_BurstpackUsedThisRound);
	Zero(i_MaxMorhpinesThisRound);
	i_MaxRevivesAWave = 0;
}

bool MorphineMaxed(int client)
{
	return (i_MaxMorhpinesThisRound[client] >= 2);
}

float MorphineChargeFunc(int client)
{
	return MorphineCharge[client];
}

stock void GiveMorphineOnDamage(int client, int victim, float damage, int damagetype)
{
	if(GetAbilitySlotCount(client) != 8)
		return;
		
	if(!(damagetype & DMG_CLUB))
		return; //needs to be melee damage!

	if(MorphineMaxed(client))
	{
		MorphineCharge[client] = 0.0;
		return;
	}
	int MinCashMaxGain = CurrentCash;
	if(MinCashMaxGain <= 1000)
		MinCashMaxGain = 1000;

	MinCashMaxGain -= 250;

	if(MinCashMaxGain >= 200000)
	{
		MinCashMaxGain = 200000;
	}
	
	float DamageForMaxCharge = (Pow(2.0 * MinCashMaxGain, 1.2) + MinCashMaxGain * 3.0);
	
	DamageForMaxCharge *= 0.5;
	
	if(b_thisNpcIsARaid[victim])
		DamageForMaxCharge *= 0.85;

	if(Rogue_Mode())// Rogue op
		DamageForMaxCharge *= 1.5;

	MorphineCharge[client] += (damage / DamageForMaxCharge);
	if(MorphineCharge[client] >= 1.0)
		MorphineCharge[client] = 1.0;
	//Has to be atleast 3k.
}
public void MorphineShot(int client)
{
	if(dieingstate[client] > 0 || MorphineMaxed(client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	if(MorphineCharge[client] < 1.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	i_MaxMorhpinesThisRound[client] += 1;
	MorphineShotLogic(client);	
}

public void WeakDash(int client)
{
	if(dieingstate[client] > 0)
	{
		if (ability_cooldown_2[client] < GetGameTime())
		{
			ability_cooldown_2[client] = GetGameTime() + 120.0;
			WeakDashLogic(client);
		}
		else
		{
			float Ability_CD = ability_cooldown_2[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}		
	}
	else
	{
		if (ability_cooldown[client] < GetGameTime())
		{
			if(i_BurstpackUsedThisRound[client] >= 2)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Burstpack Already Used This Round, Recharging");	
				return;
			}
			i_BurstpackUsedThisRound[client] += 1;
			ability_cooldown[client] = GetGameTime() + (60.0 * CooldownReductionAmount(client));
			WeakDashLogic(client);
		}
		else
		{
			float Ability_CD = ability_cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
	}
}


public void MorphineShotLogic(int client)
{
	EmitSoundToAll(SOUND_HEAL_BEAM, client, _, 70, _, 1.0, 70);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 3.0);
	float MaxHealth = float(SDKCall_GetMaxHealth(client));
	f_AntiStuckPhaseThrough[client] = GetGameTime() + 3.0 + 0.5;
	f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + 3.0 + 0.5;
	ApplyStatusEffect(client, client, "Intangible", 3.0);
	MorphineCharge[client] = 0.0;
	if(Rogue_SuperStimsOn())
	{
		HealEntityGlobal(client, client, MaxHealth * 3.0, 1.0, 3.0, HEAL_SELFHEAL);
	}
	else
	{
		HealEntityGlobal(client, client, MaxHealth * 0.15, 0.5, 3.0, HEAL_SELFHEAL);
	}
}
public void WeakDashLogic(int client)
{
	EmitSoundToAll(SOUND_DASH, client, _, 70, _, 1.0);
			
	static float EntLoc[3];
			
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
			
	SpawnSmallExplosion(EntLoc);
			
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 750.0;
			
	ScaleVector(velocity, knockback);
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
		velocity[2] = fmax(velocity[2], 300.0);
	else
		velocity[2] += 150.0; // a little boost to alleviate arcing issues
			
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

	Magnesis_OnBurstPack(client);
}

public void PlaceableTempomaryArmorGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		EmitSoundToAll("weapons/slam/throw.wav", client, _, 80, _, 0.7);
		ability_cooldown[client] = GetGameTime() + (120.0 * CooldownReductionAmount(client));
		int entity;

		if(b_StickyExtraGrenades[client])
			entity = CreateEntityByName("tf_projectile_pipe_remote");
		else
			entity = CreateEntityByName("tf_projectile_pipe");

		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			if(b_StickyExtraGrenades[client])
				SetEntProp(entity, Prop_Send, "m_iType", 1);
				
			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelArmor, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
			//Make them barely bounce at all.
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + 12.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Armor_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
	//		pack.WriteCell(Healing_Amount);	
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

#define ARMOR_GRENADE_RANGE 400.0

public Action Timer_Detect_Player_Near_Armor_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
//	float Healing_Amount = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 75;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, ARMOR_GRENADE_RANGE * 2.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 3.0, color, 0, 0);
	   			TE_SendToAll();
				for (int target = 0; target < MAXENTITIES; target++)
				{
					if(!IsValidEntity(target))
						continue;

					if(GetTeam(target) != GetTeam(client))
						continue;

					GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", client_pos);
					if (GetVectorDistance(powerup_pos, client_pos, true) > (ARMOR_GRENADE_RANGE * ARMOR_GRENADE_RANGE))
						continue;

					if(target <= MaxClients && IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == 0)
					{
						//Is valid Player
						EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 0.7);
						EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 0.7);
						if(f_TimeUntillNormalHeal[target] > GetGameTime())
						{
							GiveArmorViaPercentage(target, 0.075 * 0.5, 1.0,_,_,client);
						}
						else
						{
							GiveArmorViaPercentage(target, 0.075, 1.0, _,_,client);
						}
						continue;
					}
					
					if(b_ThisWasAnNpc[target] && IsEntityAlive(target, true))
					{
						//IsValidnpc
						float Healing_GiveArmor = 0.075;
						if(f_TimeUntillNormalHeal[target] > GetGameTime())
						{
							//recently hurt, half armor.
							Healing_GiveArmor *= 0.5;
							GrantEntityArmor(target, false, 0.25, 0.25, 0,
								ReturnEntityMaxHealth(target) * Healing_GiveArmor, client);
						}
						else
						{
							GrantEntityArmor(target, false, 0.25, 0.25, 0,
								ReturnEntityMaxHealth(target) * Healing_GiveArmor, client);
						}	
						continue;
					}
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

public void PlaceableTempomaryHealingGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		EmitSoundToAll("weapons/slam/throw.wav", client, _, 80, _, 0.7);
		ability_cooldown[client] = GetGameTime() + (140.0 * CooldownReductionAmount(client));
		
		int entity;		
		if(b_StickyExtraGrenades[client])
			entity = CreateEntityByName("tf_projectile_pipe_remote");
		else
			entity = CreateEntityByName("tf_projectile_pipe");

		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			if(b_StickyExtraGrenades[client])
				SetEntProp(entity, Prop_Send, "m_iType", 1);

			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);	
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
			//Make them barely bounce at all.
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			float Healing_Amount = 10.0;
			Healing_Amount *= Attributes_GetOnPlayer(client, 8, true, true);
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + 12.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Healing_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteFloat(Healing_Amount);	
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action Timer_Detect_Player_Near_Healing_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float Healing_Amount = pack.ReadFloat();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 0;
				color[1] = 255;
				color[2] = 0;
				color[3] = 75;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 500.0 * 2.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 3.0, color, 0, 0);
	   			TE_SendToAll();
				
				for (int target = 0; target < MAXENTITIES; target++)
				{
					if(!IsValidEntity(target))
						continue;

					if(GetTeam(target) != GetTeam(client))
						continue;

					GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", client_pos);

					if (GetVectorDistance(powerup_pos, client_pos, true) > (500.0 * 500.0))
						continue;

					if(target <= MaxClients && IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == 0)
					{
						//Is valid Player
						if(dieingstate[target] > 0)
						{
							EmitSoundToClient(target, SOUND_HEAL_BEAM, target, _, 90, _, 0.7);
							if(i_CurrentEquippedPerk[client] & PERK_REGENE)
							{
								SetEntityHealth(target,  GetClientHealth(target) + 12);
								dieingstate[target] -= 20;
							}
							else
							{
								SetEntityHealth(target,  GetClientHealth(target) + 6);
								dieingstate[target] -= 10;
							}
							if(dieingstate[target] < 1)
							{
								dieingstate[target] = 1;
							}
						}
						else
						{
							if(f_TimeUntillNormalHeal[target] > GetGameTime())
							{
								Healing_Amount *= 0.5;
							}
							if(Healing_Amount < 10.0)
							{
								Healing_Amount = 10.0;
							}
							EmitSoundToClient(target, SOUND_HEAL_BEAM, target, _, 90, _, 0.7);
							HealEntityGlobal(client, target, Healing_Amount, _, 1.0);	
						}
						continue;
					}
					
					if(b_ThisWasAnNpc[target] && IsEntityAlive(target, true))
					{
						if(Citizen_IsIt(target) && Citizen_ThatIsDowned(target))
						{
							if(i_CurrentEquippedPerk[client] & PERK_REGENE)
							{
								Citizen_ReviveTicks(target, 20, client, true);
							}
							else
							{
								Citizen_ReviveTicks(target, 10, client, true);
							}
							continue;
						}
						//IsValidnpc
						if(f_TimeUntillNormalHeal[target] > GetGameTime())
						{
							Healing_Amount *= 0.5;
						}
						if(Healing_Amount < 10.0)
						{
							Healing_Amount = 10.0;
						}
						HealEntityGlobal(client, target, Healing_Amount, _, 1.0);	
						continue;
					}
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

public void ReconstructiveTeleporter(int client)
{
	if(ability_cooldown[client] < GetGameTime() || CvarInfiniteCash.BoolValue)
	{
		float WorldSpaceVec[3];
		bool IsLiveBarrackUnits=false;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(ally) && !b_NpcHasDied[ally] && !i_IsABuilding[ally] && GetTeam(ally) == TFTeam_Red)
			{
				char npc_classname[60];
				NPC_GetPluginById(i_NpcInternalId[ally], npc_classname, sizeof(npc_classname));
				if(BarrackOwner[ally] == GetClientUserId(client) && !(StrEqual(npc_classname, "npc_barrack_building")))
				{
					IsLiveBarrackUnits=true;
					WorldSpaceCenter(ally, WorldSpaceVec);
					ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
					SetEntProp(ally, Prop_Data, "m_iHealth", RoundToCeil(float(ReturnEntityMaxHealth(ally)) * 1.5));
					IncreaseEntityDamageTakenBy(ally, 0.05, 2.0);
					WorldSpaceCenter(client, WorldSpaceVec);
					TeleportEntity(ally, WorldSpaceVec, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		if(!IsLiveBarrackUnits)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Barrack Unit not detected");
			return;
		}
		if(!CvarInfiniteCash.BoolValue)
		{
			ability_cooldown[client] = GetGameTime() + (70.0 * CooldownReductionAmount(client));
		}
		WorldSpaceCenter(client, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
		EmitSoundToClient(client, g_TeleSounds[GetRandomInt(0, sizeof(g_TeleSounds) - 1)], client, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

void HealPointToReinforce(int client, int healthvalue, float autoscale = 0.0)
{
	if(!b_Reinforce[client])
		return;

	float Healing_Amount=Attributes_GetOnPlayer(client, 8, true, true)/2.0;
	if(Healing_Amount<1.0)
		Healing_Amount=1.0;

	int Base_HealingMaxPoints;

	//This is fine to use 
	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(Purnell_Existant(client))
	{
		weapon = Purnell_Existant(client);
	}
	if(Is_Cheesed_Up(client))
	{
		weapon = ReturnWeapon_PlasmaKit(client);
	}
	if(IsValidEntity(weapon))
	{
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_FLAGELLANT_HEAL:
			{
				Healing_Amount=Attributes_Get(weapon, 868, 0.0);
				Healing_Amount += 2.0;
				//it starts at -1.0, so it should go upto 1.0.
				if(Healing_Amount<1.0)
					Healing_Amount=1.0;
				
				Base_HealingMaxPoints=RoundToCeil(3500.0 * Healing_Amount);
			}
			case WEAPON_SEABORN_MISC:
			{
				Healing_Amount=Attributes_Get(weapon, 8, 0.0)/2.0;
				if(Healing_Amount<1.0)
					Healing_Amount=1.0;

				Base_HealingMaxPoints=RoundToCeil(3000.0 * Healing_Amount);
			}
			case WEAPON_PURNELL_PRIMARY:
			{
				Healing_Amount=Attributes_Get(weapon, Attrib_PapNumber, 0.0);
				//it starts at -1.0, so it should go upto 1.0.
				if(Healing_Amount<1.0)
					Healing_Amount=1.0;

				Healing_Amount *= 0.5;
				
				Base_HealingMaxPoints=RoundToCeil(800.0 * Healing_Amount);
			}
			case WEAPON_CHEESY_MELEE:
			{
				Healing_Amount=Attributes_Get(weapon, Attrib_PapNumber, 0.0);
				//it starts at -1.0, so it should go upto 1.0.
				if(Healing_Amount<1.0)
					Healing_Amount=1.0;

				Base_HealingMaxPoints=RoundToCeil(15000.0 * Healing_Amount);
			}
			default:
				Base_HealingMaxPoints=RoundToCeil(1900.0 * Healing_Amount);
		}
	}
	else 
		Base_HealingMaxPoints = RoundToCeil(1900.0 * Healing_Amount);
	
	if(Base_HealingMaxPoints <= 3000)
		Base_HealingMaxPoints = 3000;
		

	//make it easier by 10%
	Base_HealingMaxPoints = RoundToNearest(float(Base_HealingMaxPoints) * 0.9);

	if(autoscale != 0.0)
		f_ReinforceTillMax[client] += autoscale;
	else
		f_ReinforceTillMax[client] += (float(healthvalue) / float(Base_HealingMaxPoints));


	if(f_ReinforceTillMax[client] >= 1.0)
	{
		f_ReinforceTillMax[client] = 1.0;

		if(!b_ReinforceReady_soundonly[client])
		{
			EmitSoundToClient(client, g_ReinforceSounds[GetRandomInt(0, sizeof(g_ReinforceSounds) - 1)], _, _, _, _, 0.5, _, _, _, _, false);
			CPrintToChat(client, "{green}You can now call in reinforcements.");
			b_ReinforceReady_soundonly[client]=true;
		}
	}
	else
	{
		b_ReinforceReady_soundonly[client]=false;
	}
}

float ReinforcePoint(int client)
{
	return f_ReinforceTillMax[client];
}

public void Reinforce(int client, bool NoCD)
{
	if(!NoCD && dieingstate[client] > 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Alive");
		return;
	}
	else
	{
		if(!NoCD)
		{
			if(ability_cooldown[client] > GetGameTime())
			{
				float Ability_CD = ability_cooldown[client] - GetGameTime();

				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;

				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
				return;
			}
			if(f_ReinforceTillMax[client] < 1.0)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Need Healing Point");
				return;
			}
			if(i_MaxRevivesAWave >= MaxRevivesAllowed())
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Too Many Mercs Recruited....");
				return;
			}
		}
		else
		{
			f_ReinforceTillMax[client] = 1.0;
		}

		int MaxCashScale = CurrentCash;
		if(MaxCashScale > 60000)
			MaxCashScale = 60000;
			
		bool DeadPlayer;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(!IsValidClient(client_check))
				continue;
			if(TeutonType[client_check] == TEUTON_NONE)
				continue;
			if(client==client_check || GetTeam(client_check) != TFTeam_Red)
				continue;
			if(!b_HasBeenHereSinceStartOfWave[client_check])
				continue;
			if(f_PlayerLastKeyDetected[client_check] < GetGameTime())
				continue;

			int CashSpendScale = CashSpentTotal[client_check];

			if(CashSpendScale <= 500)
				CashSpendScale = 500;

			if((CashSpendScale * 3) < (MaxCashScale))
				continue;

			DeadPlayer=true;
		}
		if(!DeadPlayer)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Player not detected");
			return;
		}

		
		i_MaxRevivesAWave++;
		CPrintToChatAll("{green}%N Is calling for additonal Mercs for temporary assistance...",client);
		float position[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);

		Handle Reinforcement = CreateDataPack();
		WritePackFloat(Reinforcement, position[0]);
		WritePackFloat(Reinforcement, position[1]);
		WritePackFloat(Reinforcement, position[2]);
		WritePackFloat(Reinforcement, 50.0);
		WritePackCell(Reinforcement, false);
		WritePackFloat(Reinforcement, 1200.0);
		WritePackString(Reinforcement, "ZR_ReinforcePOD_");
		WritePackString(Reinforcement, "models/props_urban/urban_crate002.mdl");
		WritePackString(Reinforcement, "weapons/air_burster_explode3.wav");
		WritePackCell(Reinforcement, client);
		ResetPack(Reinforcement);
		Deploy_Drop(Reinforcement);

		if(!NoCD)
			f_ReinforceTillMax[client]= 0.0;
	}
}

public void Deploy_Drop(Handle data)
{
	float position[3];
	static char PropName[512];
	static char Worldmodel_Patch[PLATFORM_MAX_PATH];
	static char Sound_Patch[PLATFORM_MAX_PATH];
	position[0] = ReadPackFloat(data);
	position[1] = ReadPackFloat(data);
	position[2] = ReadPackFloat(data);
	float Delay = ReadPackFloat(data);
	bool NoDrawBeam =ReadPackCell(data);
	float Prop_Speed = ReadPackFloat(data);
	ReadPackString(data, PropName, sizeof(PropName));
	ReadPackString(data, Worldmodel_Patch, sizeof(Worldmodel_Patch));
	ReadPackString(data, Sound_Patch, sizeof(Sound_Patch));
	int client = ReadPackCell(data);

	if(!IsValidClient(client))
		return;
	
	if(Delay > 0 && !NoDrawBeam)
	{
		float Laserpos[3];
		EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);
		Laserpos[0] = position[0];
		Laserpos[1] = position[1];
		Laserpos[2] = position[2] + 1500.0;
		
		TE_SetupBeamPoints(Laserpos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, {0, 150, 255, 255}, 3);
		TE_SendToAll();
		Laserpos[2] -= 1490.0;
		TE_SetupGlowSprite(Laserpos, gBluePoint2, 1.0, 1.0, 255);
		TE_SendToAll();
	}
	Delay -= 5;
	
	Handle DDPack = CreateDataPack();
	WritePackFloat(DDPack, position[0]);
	WritePackFloat(DDPack, position[1]);
	WritePackFloat(DDPack, position[2]);
	WritePackFloat(DDPack, Delay);
	WritePackCell(DDPack, NoDrawBeam);
	WritePackFloat(DDPack, Prop_Speed);
	WritePackString(DDPack, PropName);
	WritePackString(DDPack, Worldmodel_Patch);
	WritePackString(DDPack, Sound_Patch);
	WritePackCell(DDPack, client);
	ResetPack(DDPack);
	if(Delay > -50)
		CreateTimer(0.1, Recycle_DropProp, DDPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
	else
	{
		if(!StrEqual(Sound_Patch, "No_Sound", true))
			EmitSoundToAll(Sound_Patch, 0, SNDCHAN_AUTO, SNDLEVEL_TRAIN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);

		Drop_Prop(client, position, Prop_Speed, PropName, Worldmodel_Patch);
	}
}

public Action Recycle_DropProp(Handle timer, any data)
{
	Deploy_Drop(data);
	return Plugin_Stop;
}


public Action M3_Ability_Is_Back(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	
	if (IsValidClient(client))
	{
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetHudTextParams(-1.0, 0.45, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "M3 Ability Is Back");
	}
	return Plugin_Handled;
}

public void BuilderMenu(int client)
{
	if(dieingstate[client] == 0)
	{	
		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		static char buffer[128];
		Menu menu = new Menu(BuilderMenuM);
		AnyMenuOpen[client] = 1.0;

		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t", "Extra Menu");
		
		FormatEx(buffer, sizeof(buffer), "%t", "Deleting buildings refunds text");
		menu.AddItem("-999", buffer, ITEMDRAW_DISABLED);

		FormatEx(buffer, sizeof(buffer), "%t", "Mark Building For Deletion");
		menu.AddItem("-1", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Un-Claim Building");
		menu.AddItem("-2", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Destroy all your non-Mounted Buildings");
		menu.AddItem("-3", buffer);
									
		FormatEx(buffer, sizeof(buffer), "%t", "Bring up Class Change Menu");
		menu.AddItem("-4", buffer);

	//	FormatEx(buffer, sizeof(buffer), "%t", "Display top 5");
	//	menu.AddItem("-5", buffer);
		
									
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

/*
	SetStoreMenuLogic(client, false);
	sResetStoreMenuLogic(client);
*/
public int BuilderMenuM(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0.0;
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						DeleteBuildingLookedAt(client);
					}
				}
				case -2:
				{
					if(IsValidClient(client))
					{
						Un_ClaimBuildingLookedAt(client);
					}
				}
				case -3:
				{
					if(IsValidClient(client))
					{
						DestroyAllBuildings_ClientSelf(client);
					}
				}
				case -4:
				{
					if(IsValidClient(client))
					{
						ShowVGUIPanel(client, GetTeam(client) == TFTeam_Red ? "class_red" : "class_blue");
					}
				}
				//case -5:
				//{
				//	if(IsValidClient(client))
				//	{
				//		DisplayCurrentTopScorers(client);
				//	}
				//}
				default:
				{
					delete menu;
				}
			}
		}
		case MenuAction_Cancel:
		{
			AnyMenuOpen[client] = 0.0;
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}
/*
void DisplayCurrentTopScorers(int client)
{
	nv
}
*/
int i_BuildingSelectedToBeDeleted[MAXPLAYERS + 1];
int i_BuildingSelectedToBeUnClaimed[MAXPLAYERS + 1];


public void Un_ClaimBuildingLookedAt(int client)
{
	int entity = GetClientPointVisible(client, _ , true, true);
	if(entity > MaxClients)
	{
		if (IsValidEntity(entity))
		{
			if(!BuildingIsSupport(entity))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "This building cannot be unclaimed, only destroyed.");
				return;
			}
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{
				if(!StrContains(buffer, "obj_"))
				{
					if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
					{
						i_BuildingSelectedToBeUnClaimed[client] = EntIndexToEntRef(entity);
						DataPack pack;
						CreateDataTimer(0.1, UnclaimBuildingTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(client);
						pack.WriteCell(EntIndexToEntRef(entity));
						pack.WriteCell(GetClientUserId(client));
						Menu menu = new Menu(UnClaimBuildingMenu);
						CancelClientMenu(client);
						SetStoreMenuLogic(client, false);

						SetGlobalTransTarget(client);
						
						menu.SetTitle("%t", "UnClaim Current Marked Building");

						FormatEx(buffer, sizeof(buffer), "%t", "Yes");
						menu.AddItem("-1", buffer);
						FormatEx(buffer, sizeof(buffer), "%t", "No");
						menu.AddItem("-2", buffer);
									
						menu.ExitButton = true;
						menu.Display(client, MENU_TIME_FOREVER);
						
						i_BuildingSelectedToBeUnClaimed[client] = EntIndexToEntRef(entity);
					}
				}
			}
		}
	}
}

public Action UnclaimBuildingTimer(Handle sentryHud, DataPack pack)
{
	pack.Reset();
	int original_index = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());

	if(IsValidClient(client))
	{
		if (IsValidEntity(entity) && entity == EntRefToEntIndex(i_BuildingSelectedToBeUnClaimed[client]))
		{
			static float m_vecMaxs[3];
			static float m_vecMins[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMins", m_vecMins);
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", m_vecMaxs);
			float fPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fPos);
			TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, 0.2, view_as<int>({255, 0, 0, 255}));
			return Plugin_Continue;
		}
		else
		{
			i_BuildingSelectedToBeUnClaimed[original_index] = -1;
			return Plugin_Stop;
		}
	}
	else
	{
		i_BuildingSelectedToBeUnClaimed[original_index] = -1;
		return Plugin_Stop;
	}
}

public Action DeleteBuildingTimer(Handle sentryHud, DataPack pack)
{
	pack.Reset();
	int original_index = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());

	if(IsValidClient(client))
	{
		if (IsValidEntity(entity) && entity == EntRefToEntIndex(i_BuildingSelectedToBeDeleted[client]))
		{
			static float m_vecMaxs[3];
			static float m_vecMins[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMins", m_vecMins);
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", m_vecMaxs);
			float fPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fPos);
			TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, 0.2, view_as<int>({255, 0, 0, 255}));
			return Plugin_Continue;
		}
		else
		{
			i_BuildingSelectedToBeDeleted[original_index] = -1;
			return Plugin_Stop;
		}
	}
	else
	{
		i_BuildingSelectedToBeDeleted[original_index] = -1;
		return Plugin_Stop;
	}
}

public void DeleteBuildingLookedAt(int client)
{
	int entity = GetClientPointVisible(client, _ , true, true);
	if(entity > MaxClients)
	{
		if (IsValidEntity(entity))
		{
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{
				if(!StrContains(buffer, "obj_"))
				{
					if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client || GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") > MaxClients)
					{
						ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
						if(IsValidEntity(objstats.m_iMasterBuilding))
							entity = objstats.m_iMasterBuilding;
							
							//change to master entity.
						i_BuildingSelectedToBeDeleted[client] = EntIndexToEntRef(entity);
						DataPack pack;
						CreateDataTimer(0.1, DeleteBuildingTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(client);
						pack.WriteCell(EntIndexToEntRef(entity));
						pack.WriteCell(GetClientUserId(client));
						Menu menu = new Menu(DeleteBuildingMenu);
						CancelClientMenu(client);
						SetStoreMenuLogic(client, false);

						SetGlobalTransTarget(client);
						
						menu.SetTitle("%t", "Delete Current Marked Building");

						FormatEx(buffer, sizeof(buffer), "%t", "Yes");
						menu.AddItem("-1", buffer);
						FormatEx(buffer, sizeof(buffer), "%t", "No");
						menu.AddItem("-2", buffer);
									
						menu.ExitButton = true;
						menu.Display(client, MENU_TIME_FOREVER);
						
						i_BuildingSelectedToBeDeleted[client] = EntIndexToEntRef(entity);
					}
				}
			}
		}
	}
}

public void DestroyAllBuildings_ClientSelf(int client)
{
	Menu menu = new Menu(DestroyAllSelfBuildings_Menu);
	CancelClientMenu(client);
	SetStoreMenuLogic(client, false);
	SetGlobalTransTarget(client);

	static char buffer[64];
	menu.SetTitle("%t", "Destroy all your non-Mounted Buildings Sure");

	FormatEx(buffer, sizeof(buffer), "%t", "Yes");
	menu.AddItem("-1", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "No");
	menu.AddItem("-2", buffer);
				
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}
public int DestroyAllSelfBuildings_Menu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
			{
				ResetStoreMenuLogic(client);		
			}
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						int mountedentity = EntRefToEntIndex(Building_Mounted[client]);
						for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
						{
							int entity = EntRefToEntIndexFast(i_ObjectsBuilding[entitycount]);
							if(IsValidEntity(entity) && entity != 0)
							{
								if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client && mountedentity != entity)
								{
									if(!Can_I_See_Enemy_Only(client, entity))
									{
										DeleteAndRefundBuilding(client, entity);
									}
								}
							}
						}
					}
				}
				default:
				{
					if(IsValidClient(client))
					{
						ResetStoreMenuLogic(client);
					}
				}
			}
		}
	}
	return 0;
}

public void GearTesting(int client)
{
	if(dieingstate[client] > 0)
	{
		if (ability_cooldown_2[client] < GetGameTime())
		{
	//		PrintToChatAll("User is dead");
		}
		else
		{
			float Ability_CD = ability_cooldown_2[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}		
	}
	else
	{
		if (ability_cooldown[client] < GetGameTime())
		{
			ability_cooldown[client] = GetGameTime() + (350.0 * CooldownReductionAmount(client));

			SetEntityMoveType(client, MOVETYPE_NONE);

			i_ClientHasCustomGearEquipped[client] = true;
			b_ActivatedDuringLastMann[client] = false;
			if(LastMann)
			{
				b_ActivatedDuringLastMann[client] = true;
			}

			IncreaseEntityDamageTakenBy(client, 0.5, 3.0);
			
			CreateTimer(3.0, QuantumActivate, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		//	ClientCommand(client, "playgamesound mvm/mvm_tank_start.wav");

			EmitSoundToAll("mvm/mvm_tank_start.wav", client, SNDCHAN_STATIC, 70, _, 0.9);

			float startPosition[3];
			float position[3];
			GetClientAbsOrigin(client, startPosition);

			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 500.0;
			startPosition[2] += -500;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 3.0, 30.0, 30.0, 0, 0.9, {255, 255, 255, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.8, 50.0, 50.0, 0, 0.9, {200, 255, 200, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.5, 80.0, 80.0, 0, 0.9, {180, 255, 180, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.4, 100.0, 100.0, 0, 0.8, {120, 255, 120, 255}, 3);
			TE_SendToAll();
		}
		else
		{
			float Ability_CD = ability_cooldown[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}
}

public Action QuantumActivate(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		if(TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0 && IsPlayerAlive(client))
		{
			float startPosition[3];
			GetClientAbsOrigin(client, startPosition);
			i_HealthBeforeSuit[client] = GetClientHealth(client);

			i_ClientHasCustomGearEquipped[client] = true;
			
			Store_GiveAll(client, 50, true);
			ViewChange_PlayerModel(client);
			
			float HealthMulti = float(CashSpentTotal[client]);
			HealthMulti = Pow(HealthMulti, 1.2);
			HealthMulti *= 0.025;

			HealthMulti *= 1.1;
				
			SetEntityHealth(client, RoundToCeil(HealthMulti));

			SetEntityMoveType(client, MOVETYPE_WALK);

			Store_GiveSpecificItem(client, "Quantum Repeater");
			Store_GiveSpecificItem(client, "Quantum Nanosaber");
			
			SetAmmo(client, 1, 9999);
			SetAmmo(client, 2, 9999);

			//somehow the new tf2 update broke its infinite ammo, i have to set it like this
			//TODO: Find a different fix, 30/07/2023
			SetConVarInt(sv_cheats, 1, false, false);
			SDKCall(g_hImpulse, client, 101);
			if(nav_edit.IntValue != 1)
			{
				SetConVarInt(sv_cheats, 0, false, false);
			}
			ResetReplications();
		
			startPosition[2] += 25.0;
			makeexplosion(client, startPosition, 0, 0);

			CreateTimer(30.0, QuantumDeactivate, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			SetEntityMoveType(client, MOVETYPE_WALK);

			i_ClientHasCustomGearEquipped[client] = false;
		}
	}
	return Plugin_Handled;
}

public Action QuantumDeactivate(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client) && i_HealthBeforeSuit[client] > 0)
	{
		i_ClientHasCustomGearEquipped[client] = false;
		int health = i_HealthBeforeSuit[client];

		i_HealthBeforeSuit[client] = 0;
		f_HealthBeforeSuittime[client] = GetGameTime() + 0.25;
	//	SetEntityMoveType(client, MOVETYPE_WALK);
		UnequipQuantumSet(client);
		//Remove both just in case.
		
		TF2_RegeneratePlayer(client);
	
		ViewChange_PlayerModel(client);
		Store_ApplyAttribs(client);
		Store_GiveAll(client, health);

		CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));
		ViewChange_DeleteHands(client);
		ViewChange_UpdateHands(client, CurrentClass[client]);
		if(b_ActivatedDuringLastMann[client])
		{
			int MaxHealth = SDKCall_GetMaxHealth(client) * 2;
			SetEntProp(client, Prop_Send, "m_iHealth", MaxHealth);
		}
		b_ActivatedDuringLastMann[client] = false;
		//if in lastman, then give extra health.
	}
	return Plugin_Handled;
}

void UnequipQuantumSet(int client)
{
	Store_RemoveSpecificItem(client, "Quantum Repeater");
	Store_RemoveSpecificItem(client, "Quantum Nanosaber");
}

public float GetAbilityCooldownM3(int client)
{
	return ability_cooldown[client] - GetGameTime();
}


public void SetAbilitySlotCount(int client, int value)
{
	Attack3AbilitySlotArray[client] = value;
}

public int GetAbilitySlotCount(int client)
{
	return Attack3AbilitySlotArray[client];
}

public void PlaceableTempomaryRepairGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		EmitSoundToAll("weapons/slam/throw.wav", client, _, 80, _, 0.7);
		ability_cooldown[client] = GetGameTime() + (100.0 * CooldownReductionAmount(client));
		
		int entity;		
		if(b_StickyExtraGrenades[client])
			entity = CreateEntityByName("tf_projectile_pipe_remote");
		else
			entity = CreateEntityByName("tf_projectile_pipe");

		if(IsValidEntity(entity))
		{
			
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			if(b_StickyExtraGrenades[client])
				SetEntProp(entity, Prop_Send, "m_iType", 1);

			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelArmor, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
			//Make them barely bounce at all.
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + 12.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Repair_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
	//		pack.WriteCell(Healing_Amount);	
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}


public Action Timer_Detect_Player_Near_Repair_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
//	float Healing_Amount = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
				color[3] = 75;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 500.0 * 2.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 3.0, color, 0, 0);
	   			TE_SendToAll();
				bool Repaired_Building = false;

				//just get highest value
				float RepairRateBonus = Attributes_GetOnPlayer(client, 95, true, false, 1.0);
				int healing_Amount = RoundToCeil(30.0 * RepairRateBonus);
				int CurrentMetal = GetAmmo(client, 3);

				for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
				{
					int entity_close = EntRefToEntIndexFast(i_ObjectsBuilding[entitycount]);
					if(IsValidEntity(entity_close))
					{
						GetEntPropVector(entity_close, Prop_Data, "m_vecAbsOrigin", client_pos);
						if (GetVectorDistance(powerup_pos, client_pos, true) <= (500.0 * 500.0))
						{
							Repaired_Building = true;
							TE_Particle("halloween_boss_axe_hit_sparks", client_pos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
							if(CurrentMetal < healing_Amount)
							{
								healing_Amount = CurrentMetal;
							}
							if(CurrentMetal > 0)
							{
								int HealthAfter = HealEntityGlobal(client, entity_close, float(healing_Amount), .MaxHealPermitted = CurrentMetal);

								CurrentMetal -= (HealthAfter) / 5;
							}
							Resistance_for_building_High[entity_close] = GetGameTime() + 1.1; 
						}
					}
				}

				SetAmmo(client, 3, CurrentMetal);
				CurrentAmmo[client][3] = GetAmmo(client, 3);
				if(Repaired_Building)
				{
					EmitSoundToAll(SOUND_REPAIR_BEAM, entity, SNDCHAN_STATIC, 90, _, 0.7);
					EmitSoundToAll(SOUND_REPAIR_BEAM, entity, SNDCHAN_STATIC, 90, _, 0.7);
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}


public int UnClaimBuildingMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
			{
				ResetStoreMenuLogic(client);
				i_BuildingSelectedToBeUnClaimed[client] = -1;		
			}
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						int entity = EntRefToEntIndex(i_BuildingSelectedToBeUnClaimed[client]);
						if (IsValidEntity(entity))
						{
							int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
							if(builder_owner == client)
							{
								SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", -1);
							}
						}
						i_BuildingSelectedToBeUnClaimed[client] = -1;	
					}
				}
				default:
				{
					if(IsValidClient(client))
					{
						i_BuildingSelectedToBeUnClaimed[client] = -1;		
					}
				}
			}
		}
	}
	return 0;
}

public int DeleteBuildingMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
			{
				ResetStoreMenuLogic(client);
				i_BuildingSelectedToBeDeleted[client] = -1;		
			}
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						int entity = EntRefToEntIndex(i_BuildingSelectedToBeDeleted[client]);
						if (IsValidEntity(entity))
						{
							DeleteAndRefundBuilding(client, entity);
						}
					}
				}
				default:
				{
					if(IsValidClient(client))
					{
						i_BuildingSelectedToBeDeleted[client] = -1;		
					}
				}
			}
		}
	}
	return 0;
}

stock int Drop_Prop(int client, float fPos[3], float PropSpeed=1200.0, const char [] PropNeam_patch="No_Name", const char [] worldmodel_patch="No_Worldmodel")
{
	int PropMove = CreateEntityByName("func_movelinear");
	if(StrEqual(PropNeam_patch, "No_Name", true))
	{
		LogError("[Prop] Drop_Prop No_Name!!!");
		return -1;
	}
	if(StrEqual(worldmodel_patch, "No_Worldmodel", true))
	{
		LogError("[Prop] Drop_Prop No_Worldmodel!!!");
		return -1;
	}
	if(IsValidEntity(PropMove))
	{
		char buffer[32];
		fPos[2]+=5010.0;
		float Down[3]={90.0,0.0,0.0};
		DispatchKeyValueVector(PropMove, "origin", fPos);
		DispatchKeyValueVector(PropMove, "movedir", Down);
		DispatchKeyValue(PropMove, "movedir", "90 0 0");
		DispatchKeyValue(PropMove, "modelscale", "3");
		Format(buffer, sizeof(buffer), "%.2f", 5000.0);
		DispatchKeyValue(PropMove, "movedistance", buffer);
		Format(buffer, sizeof(buffer), "%.2f", PropSpeed);
		DispatchKeyValue(PropMove, "speed", buffer);
		FormatEx(buffer, sizeof(buffer), "%s_Drop_%d", PropNeam_patch, client);
		DispatchKeyValue(PropMove, "targetname", buffer);
		DispatchKeyValue(PropMove, "startsound", "none");
		DispatchKeyValue(PropMove, "stopsound", "none");
		TeleportEntity(PropMove, fPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(PropMove);
		
		int Prop = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(Prop))
		{
			DispatchKeyValue(Prop, "model", worldmodel_patch);
			DispatchKeyValue(Prop, "angles", "-90 0 0");
			DispatchKeyValue(Prop, "parentname", buffer);
			DispatchKeyValue(Prop, "solid", "0");
			FormatEx(buffer, sizeof(buffer), "%s_%d", PropNeam_patch, client);
			DispatchKeyValue(Prop, "targetname", buffer);
			TeleportEntity(Prop, fPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(Prop);
			
			FormatEx(buffer, sizeof(buffer), "%s_Drop_%d", PropNeam_patch, client);
			SetVariantString(buffer);
			AcceptEntityInput(Prop, "SetParent");
		}
		AcceptEntityInput(PropMove, "Open");
		SetEntPropEnt(PropMove, Prop_Data, "m_hOwnerEntity", client);
		SetEntPropEnt(Prop, Prop_Data, "m_hOwnerEntity", client);
		return PropMove;
	}
	return -1;
}

public Action OnBombDrop(const char [] output, int caller, int activator, float delay)
{
	char name[64];
	GetEntPropString(caller, Prop_Data, "m_iName", name, sizeof(name));
	if(StrContains(name, "ZR_ReinforcePOD_", false) != -1)
	{
		int HELLDIVER = GetEntPropEnt(caller, Prop_Data, "m_hOwnerEntity");
		int PreviousOwner = HELLDIVER;
		float position[3];
		GetEntPropVector(caller, Prop_Data, "m_vecAbsOrigin", position);
		AcceptEntityInput(caller, "KillHierarchy");
		position[2]-=10.0;
		if(IsValidClient(PreviousOwner))
		{
			int RandomHELLDIVER = GetRandomDeathPlayer(HELLDIVER);
			if(IsValidClient(RandomHELLDIVER) && GetTeam(RandomHELLDIVER) == TFTeam_Red && TeutonType[RandomHELLDIVER] == TEUTON_DEAD && b_HasBeenHereSinceStartOfWave[RandomHELLDIVER])
			{
				TeutonType[RandomHELLDIVER] = TEUTON_NONE;
				dieingstate[RandomHELLDIVER] = 0;
				//i_AmountDowned[RandomHELLDIVER]--;
				DHook_RespawnPlayer(RandomHELLDIVER);
				ForcePlayerCrouch(RandomHELLDIVER, false);
				DataPack pack;
				CreateDataTimer(0.5, Timer_DelayTele, pack, TIMER_FLAG_NO_MAPCHANGE);
				Music_EndLastmann(true);
				LastMann = false;
				applied_lastmann_buffs_once = false;
				SDKHooks_UpdateMarkForDeath(RandomHELLDIVER, true);
				SDKHooks_UpdateMarkForDeath(RandomHELLDIVER, false);
				//More time!!!
				pack.WriteCell(GetClientUserId(RandomHELLDIVER));
				pack.WriteFloat(position[0]);
				pack.WriteFloat(position[1]);
				pack.WriteFloat(position[2]);
				GiveCompleteInvul(RandomHELLDIVER, 3.5);
				TF2_AddCondition(RandomHELLDIVER, TFCond_SpeedBuffAlly, 2.0);
				EmitSoundToAll(g_ReinforceReadySounds, RandomHELLDIVER, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
				CPrintToChatAll("{black}Bob The Second {green}responds.... and was able to recuit {yellow}%N!",RandomHELLDIVER);
				DataPack pack_boom = new DataPack();
				pack_boom.WriteFloat(position[0]);
				pack_boom.WriteFloat(position[1]);
				pack_boom.WriteFloat(position[2]);
				pack_boom.WriteCell(1);
				RequestFrame(MakeExplosionFrameLater, pack_boom);
			}
			else
			{
				if(IsValidClient(PreviousOwner))
				{
					CPrintToChat(PreviousOwner, "{black}Bob The Second {default}Wasnt able to get any merc... he refunds the backup call.");
					HealPointToReinforce(PreviousOwner, 0, 1.0);
					i_MaxRevivesAWave--;
				}
			}
			
			float entitypos[3], distance;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(position, entitypos);
					if(distance<125.0)
					{
						float MaxHealth = float(ReturnEntityMaxHealth(entity));
						float damage=(MaxHealth*2.0);
						if(b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] || b_IsGiant[entity])
							damage=(MaxHealth*0.05)+(Pow(float(CashSpentTotal[HELLDIVER]), 1.18)/10.0);
						SDKHooks_TakeDamage(entity, HELLDIVER, HELLDIVER, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_DelayTele(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidClient(client))
	{
		float position[3];
		position[0] = pack.ReadFloat();
		position[1] = pack.ReadFloat();
		position[2] = pack.ReadFloat();
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
		GiveArmorViaPercentage(client, 0.5, 1.0);
		TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
		MakePlayerGiveResponseVoice(client, 3);
	}
	return Plugin_Stop;
}

stock int GetRandomDeathPlayer(int client)
{
	int Getclient = -1;

	int victims;
	int[] victim = new int[MaxClients];

	int MaxCashScale = CurrentCash;
	if(MaxCashScale > 60000)
		MaxCashScale = 60000;

	for(int client_check = 1; client_check <= MaxClients; client_check++)
	{
		if(!IsValidClient(client_check))
			continue;

		if(TeutonType[client_check] == TEUTON_NONE)
			continue;

		if(client==client_check || GetTeam(client_check) != TFTeam_Red)
			continue;

		if(!b_HasBeenHereSinceStartOfWave[client_check])
			continue;

		if(f_PlayerLastKeyDetected[client_check] < GetGameTime())
			continue;

		int CashSpendScale = CashSpentTotal[client_check];

		if(CashSpendScale <= 500)
			CashSpendScale = 500;

		if((CashSpendScale * 3) < (MaxCashScale))
			continue;

		victim[victims++] = client_check;
	}
	
	if(victims)
	{
		int winner = victim[GetURandomInt() % victims];
		Getclient = winner;
	}

	return Getclient;
}