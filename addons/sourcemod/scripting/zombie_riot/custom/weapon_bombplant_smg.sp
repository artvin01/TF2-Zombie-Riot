#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerExploARWeaponManagement[MAXPLAYERS] = {null, ...};
static int i_VictoriaParticle[MAXPLAYERS];
static bool b_AbilityActivated[MAXPLAYERS];
static int ExploAR_WeaponPap[MAXPLAYERS+1] = {0, ...};
static int ExploAR_WeaponID[MAXPLAYERS];
static int ExploAR_BurstNum[MAXPLAYERS];
static int ExploAR_OverHit[MAXPLAYERS];

static float ExploAR_OverHeatDelay[MAXPLAYERS];
static float ExploAR_HUDDelay[MAXPLAYERS];
static bool Can_I_Fire[MAXPLAYERS] = {false, ...};

void ResetMapStartExploARWeapon()
{
	PrecacheSound("weapons/stickybomblauncher_det.wav");
	PrecacheSound("weapons/flare_detonator_launch.wav");
	PrecacheSound("weapons/gunslinger_three_hit.wav");
	PrecacheModel("models/props_farm/vent001.mdl");
	Zero(Can_I_Fire);
	Zero(ExploAR_OverHit);
	Zero(ExploAR_HUDDelay);
	Zero(ExploAR_OverHeatDelay);
}

public void BombAR_M1_Attack(int client, int weapon, bool crit, int slot)
{
	ExploAR_OverHit[client]+=2;
	if(ExploAR_WeaponPap[client]==2)
	{
		if(ExploAR_OverHit[client]>150)ExploAR_OverHit[client]=150;
	}
	else if(ExploAR_OverHit[client]>100)ExploAR_OverHit[client]=100;
	ExploAR_OverHeatDelay[client]=GetGameTime()+1.62;
	ExploAR_HUDDelay[client] = 0.0;
	SetEntProp(weapon, Prop_Send, "m_nKillComboCount", GetEntProp(weapon, Prop_Send, "m_nKillComboCount") + 1);
	Firebullet(client, weapon, ExploAR_OverHit[client], ExploAR_WeaponPap[client]);
	if(!Can_I_Fire[client])
	{
		Can_I_Fire[client]=true;
		SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
		SDKHook(client, SDKHook_PreThink, BombAR_M1_PreThink);
	}
}

static void BombAR_M1_PreThink(int client)
{
	int weapon = EntRefToEntIndex(ExploAR_WeaponID[client]);
	if(h_TimerExploARWeaponManagement[client] != null && IsValidEntity(weapon))
	{
		float gameTime = GetGameTime();
		float attackTime = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack")- gameTime;
		float burstRate = Attributes_Get(weapon, 394, 1.0);
		if(GetClientButtons(client) & IN_ATTACK && GetEntProp(weapon, Prop_Send, "m_iClip1") != 0)
		{
			if(GetEntProp(weapon, Prop_Send, "m_nKillComboCount")>=ExploAR_BurstNum[client])
			{
				SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", gameTime + (burstRate * attackTime));
				SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			}
		}
		else
		{
			SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", gameTime + (burstRate * attackTime));
			SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			Can_I_Fire[client]=false;
			SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
			return;
		}
	}
	else
	{
		Can_I_Fire[client]=false;
		SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
		return;
	}
}

/*
public void ExploAR_Ability_M2(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 60.0);
			EmitSoundToAll("ambient/cp_harbor/furnace_1_shot_05.wav", client, SNDCHAN_AUTO, 70, _, 1.0);
			b_AbilityActivated[client] = true;
			CreateTimer(15.0, Timer_Bool_ExploAR, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			//SetParent(client, particle_Base, "m_vecAbsOrigin");
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
	
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
		
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}
}
*/

public void BombAR_ICE_Inject(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		/*if(b_InteractWithReload[client])
		{
			bool R_AbilityBlock=false;
			int building = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][client]);
			if(building != -1 && Building_Collect_Cooldown[building][client]<=0.0
			&& IsInteractionBuilding(building))
			{
				static float angles[3];
				GetClientEyeAngles(client, angles);
				if(angles[0] < -70.0)
				{
					static float R_Delay;
					if(R_Delay < GetGameTime())
					{
						R_Delay = GetGameTime() + 0.2;
						R_AbilityBlock=true;
					}
				}
			}
			if(R_AbilityBlock)return;
		}*/
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		if(Ability_CD <= 0.0 || CvarInfiniteCash.BoolValue)
			Ability_CD = 0.0;
		if(Ability_CD)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		if(ExploAR_OverHit[client]>64)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 5.0);
			EmitSoundToAll("weapons/flare_detonator_launch.wav", client, SNDCHAN_AUTO, 70, _, 1.0);
			EmitSoundToAll("weapons/gunslinger_three_hit.wav", client, SNDCHAN_AUTO, 70, _, 1.0);
			float damage = 500.0;
			damage *= Attributes_Get(weapon, 2, 1.0);
			damage += (float(ExploAR_OverHit[client])/65.0)*(damage/2.0);
			if(ExploAR_WeaponPap[client]==2 && ExploAR_OverHit[client]>99)
				damage *= (float(ExploAR_OverHit[client])/90.0);
			float speed = 3000.0;
			speed *= Attributes_Get(weapon, 103, 1.0);

			float time = 5000.0/speed;
			int Projectile=Wand_Projectile_Spawn(client, speed, time, damage, 8, weapon, "rockettrail_RocketJumper");
			WandProjectile_ApplyFunctionToEntity(Projectile, VentTouch);
			Projectile=ApplyCustomModelToWandProjectile(Projectile, "models/props_farm/vent001.mdl", 0.3, "");
			TeleportEntity(Projectile, NULL_VECTOR, {-90.0, 0.0, 0.0}, NULL_VECTOR);
			int RColor = 100+RoundFloat((float(ExploAR_OverHit[client])/65.0)*101.0);
			if(RColor>255)RColor=255;
			SetEntityRenderColor(Projectile, RColor, 60, 5, 255);
			IgniteTargetEffect(Projectile);
			ExploAR_OverHit[client]=0;
			return;
		}
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
}

public void BombAR_AirStrike_Beacon(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		/*if(b_InteractWithReload[client])
		{
			bool R_AbilityBlock=false;
			int building = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][client]);
			if(building != -1 && Building_Collect_Cooldown[building][client]<=0.0
			&& IsInteractionBuilding(building))
			{
				static float angles[3];
				GetClientEyeAngles(client, angles);
				if(angles[0] < -70.0)
				{
					static float R_Delay;
					if(R_Delay < GetGameTime())
					{
						R_Delay = GetGameTime() + 0.2;
						R_AbilityBlock=true;
					}
				}
			}
			if(R_AbilityBlock)return;
		}*/
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		if(Ability_CD <= 0.0 || CvarInfiniteCash.BoolValue)
			Ability_CD = 0.0;
		if(Ability_CD)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		if(ExploAR_OverHit[client]>64)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 5.0);

			return;
		}
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
}

public void Enable_ExploARWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(h_TimerExploARWeaponManagement[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOMB_AR)
		{
			ExploAR_WeaponPap[client] = ExplosiveAR_Get_Pap(weapon);
			ExploAR_BurstNum[client] = RoundToCeil(Attributes_Get(weapon, 401, 1.0));
			Can_I_Fire[client]=false;
			ExploAR_WeaponID[client]=EntIndexToEntRef(weapon);
			delete h_TimerExploARWeaponManagement[client];
			h_TimerExploARWeaponManagement[client] = null;
			DataPack pack;
			h_TimerExploARWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ExploAR, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOMB_AR)
		{
			ExploAR_WeaponPap[client] = ExplosiveAR_Get_Pap(weapon);
			ExploAR_BurstNum[client] = RoundToCeil(Attributes_Get(weapon, 401, 1.0));
			Can_I_Fire[client]=false;
			ExploAR_WeaponID[client]=EntIndexToEntRef(weapon);
			DataPack pack;
			h_TimerExploARWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ExploAR, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		
	}
	if(Store_IsWeaponFaction(client, weapon, Faction_Victoria))	// Victoria
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(h_TimerExploARWeaponManagement[i])
			{
				ApplyStatusEffect(weapon, weapon, "Castle Breaking Power", 9999999.0);
				Attributes_SetMulti(weapon, 2, 1.1);
			}
		}
	}
}

static Action Timer_Management_ExploAR(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerExploARWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		ExploARWork(client, weapon);
		if(ExploAR_WeaponPap[client]==1972)
			CreateExploAREffect(client);
	}
	else
	{
		if(ExploAR_WeaponPap[client]==1972)
			DestroyExploAREffect(client);
	}

	return Plugin_Continue;
}

static void ExploARWork(int client, int weapon)
{
	float GameTime = GetGameTime();
	static int SaveClip;
	int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
	if(SaveClip>clip)
	{
		SaveClip=clip;
	}
	else if(SaveClip<clip)
	{
		bool WhoExplode;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int npc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if (IsValidEntity(npc) && !b_NpcHasDied[npc] && GetTeam(npc) != TFTeam_Red)
			{
				if(i_HowManyBombsOnThisEntity[npc][client] > 0)
				{
					Cause_Terroriser_Explosion(client, npc, true);
					WhoExplode=true;
				}
			}
		}
		if(WhoExplode)
			EmitSoundToAll("weapons/stickybomblauncher_det.wav", client);
		SaveClip=clip;
	}
	if(ExploAR_OverHeatDelay[client] < GameTime)
	{
		ExploAR_OverHit[client]-=4;
		if(ExploAR_OverHit[client]<0)ExploAR_OverHit[client]=0;
	}
	if(ExploAR_HUDDelay[client] < GameTime)
	{
		if(ExploAR_OverHit[client]>=100)
			PrintHintText(client,"!!! ICE Overheat  %i％ !!!", ExploAR_OverHit[client]);
		else if(ExploAR_OverHit[client]>80)
			PrintHintText(client,"!! ICE Overheat  %i％ !!", ExploAR_OverHit[client]);
		else if(ExploAR_OverHit[client]>65)
			PrintHintText(client,"! ICE Overheat  %i％ !", ExploAR_OverHit[client]);
		else
			PrintHintText(client,"ICE Overheat  %i％", ExploAR_OverHit[client]);
		
		ExploAR_HUDDelay[client] = GameTime + 0.5;
	}
	if(ExploAR_OverHit[client]>65)
	{
		/*int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				GetAttachment(entity, "effect_hand_R", flPos, NULL_VECTOR);
				int particle = ParticleEffectAt(flPos, "drg_pipe_smoke", 0.0);
				AddEntityToThirdPersonTransitMode(client, particle);
				SetParent(entity, particle, "effect_hand_R");
				i_VictoriaParticle[client] = EntIndexToEntRef(particle);
			}
		}*/
	}
	else
	{
		/*int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;*/
	}
}

static void Firebullet(int client, int weapon, int Overheat, int GetPap)
{
	float damage = 500.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	if(Overheat>64)
		damage -= (float(Overheat)/(GetPap==2 ? 130.0 : 100.0))*(damage/2.0);
	float speed = 3500.0;
	speed *= Attributes_Get(weapon, 103, 1.0);

	float time = 5000.0/speed;
	int Projectile;
	if(Overheat>64)
		Projectile=Wand_Projectile_Spawn(client, speed, time, damage, 8, weapon, "raygun_projectile_red_trail");
	else
		Projectile=Wand_Projectile_Spawn(client, speed, time, damage, 8, weapon, "raygun_projectile_blue_trail");
	WandProjectile_ApplyFunctionToEntity(Projectile, Gun_BombARTouch);
}

static int ExplosiveAR_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}

static void VentTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	float ProjectilePos[3];GetAbsOrigin(entity, ProjectilePos);
	makeexplosion(entity, ProjectilePos, 0, 0);
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	Explode_Logic_Custom(f_WandDamage[entity], owner, owner, weapon, ProjectilePos, _, Attributes_Get(weapon, 117, 1.0), _, _, _, _, _, IM_ON_FIREEEEE);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	RemoveEntity(entity);
}

static void IM_ON_FIREEEEE(int entity, int victim, float damage, int weapon)
{
	NPC_Ignite(victim, entity, 3.0, weapon);
}

static void Gun_BombARTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(target > 0)	
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
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);	// 2048 is DMG_NOGIB?

		if(!b_NpcIsInvulnerable[target])
		{
			f_BombEntityWeaponDamageApplied[target][owner] += f_WandDamage[entity] / 12.0;
			i_HowManyBombsOnThisEntity[target][owner]++;
			i_HowManyBombsHud[target]++;
			Apply_Particle_Teroriser_Indicator(target);
		}
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
}

static void CreateExploAREffect(int client)
{
	if(b_AbilityActivated[client])
	{
		int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				float flAng[3];
				GetAttachment(entity, "eyeglow_l", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "eye_powerup_blue_lvl_3", 0.0);
				AddEntityToThirdPersonTransitMode(entity, particle);
				SetParent(entity, particle, "eyeglow_l");
				i_VictoriaParticle[client] = EntIndexToEntRef(particle);
			}
		}
	}
	else
		DestroyExploAREffect(client);
}
static void DestroyExploAREffect(int client)
{
	int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;
}