#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerExploARWeaponManagement[MAXPLAYERS] = {null, ...};
static int i_VictoriaParticle[MAXPLAYERS];
static bool b_AbilityActivated[MAXPLAYERS];
static int ExploAR_WeaponPap[MAXPLAYERS+1] = {0, ...};
static int i_WeaponID[MAXPLAYERS];
static int i_BurstNum[MAXPLAYERS];

static float ExploAR_HUDDelay[MAXPLAYERS];
static bool Can_I_Fire[MAXPLAYERS] = {false, ...};
static float f_rest_time[MAXPLAYERS];

#define Projectiles_per_Shot 10

void ResetMapStartExploARWeapon()
{
	ExploAR_Map_Precache();
	Zero(Can_I_Fire);
	Zero(f_rest_time);
}

static void ExploAR_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("weapons/capper_shoot.wav");
	PrecacheSound("weapons/grenade_launcher_worldreload.wav");
	PrecacheSound("weapons/syringegun_reload_air1.wav");
	PrecacheSound("weapons/syringegun_reload_air2.wav");
	PrecacheSound("weapons/sniper_railgun_world_reload.wav");
	PrecacheSound("weapons/sniper_railgun_bolt_back.wav");
}

static void Firebullet(int client, int weapon)
{
	float damage = 500.0;
	damage *=Attributes_Get(weapon, 2, 1.0);
	float speed = 3500.0;
	speed *=Attributes_Get(weapon, 103, 1.0);

	float time = 5000.0/speed;

	EmitSoundToAll("weapons/capper_shoot.wav", client, _, 65, _, 0.45);
	int Projectile = Wand_Projectile_Spawn(client, speed, time, damage, 8, weapon, "raygun_projectile_blue_trail");
	WandProjectile_ApplyFunctionToEntity(Projectile, Gun_BombARTouch);
}

public void BombAR_M1_Attack(int client, int weapon, bool crit, int slot)
{
	switch (ExploAR_WeaponPap[client])
	{
		case -1: //base pap
		{
			ExplosiveAR_Fire_Multiple_Rounds(client, weapon, 2);
		}
		default:
		{
			SetEntProp(weapon, Prop_Send, "m_nKillComboCount", GetEntProp(weapon, Prop_Send, "m_nKillComboCount") + 1);
			EmitSoundToAll("weapons/capper_shoot.wav", client, SNDCHAN_AUTO, 75, _, 0.85, 110);
			Firebullet(client, weapon);
			if(!Can_I_Fire[client])
			{
				Can_I_Fire[client]=true;
				SDKUnhook(client, SDKHook_PreThink, BombAR_M1_PreThink);
				SDKHook(client, SDKHook_PreThink, BombAR_M1_PreThink);
			}
		}
	}
	//EmitSoundToAll(BOOMERANG_FIRE_SOUND, client, SNDCHAN_AUTO, 75, _, 0.85, 110);

	float GameTime = GetGameTime();
	f_rest_time[client] = GameTime + Attributes_Get(weapon, 6, 1.0) *0.4;	//make the rest timer scale on firerate.
	//so a "weapon fires too slow" case doesn't happen and completely fuck over the weapon!
}

static void BombAR_M1_PreThink(int client)
{
	int weapon = EntRefToEntIndex(i_WeaponID[client]);
	if(h_TimerExploARWeaponManagement[client] != null && IsValidEntity(weapon))
	{
		float gameTime = GetGameTime();
		float attackTime = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack")- gameTime;
		float burstRate = Attributes_Get(weapon, 394, 1.0);
		if(GetClientButtons(client) & IN_ATTACK && GetEntProp(weapon, Prop_Send, "m_iClip1") != 0)
		{
			if(GetEntProp(weapon, Prop_Send, "m_nKillComboCount")>=i_BurstNum[client])
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

static int ExplosiveAR_Get_Pap(int weapon)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}

public void ExplosiveAR_Fire_Multiple_Rounds(int client, int weapon, int FireMultiple)
{		
	int FrameDelayAdd = 5;
	float Attackspeed = Attributes_Get(weapon, 6, 1.0);
	Attackspeed *= 0.5;

	FrameDelayAdd = RoundToNearest(float(FrameDelayAdd) * Attackspeed);
	for(int LoopFire ; LoopFire <= FireMultiple; LoopFire++)
	{
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		if(LoopFire == 0)
			pack.WriteCell(0);
		else
			pack.WriteCell(1);

		if(LoopFire == 0)
			Weapon_ExplosiveAR_FireInternal(pack);
		else
			RequestFrames(Weapon_ExplosiveAR_FireInternal, RoundToNearest(float(FrameDelayAdd) * LoopFire), pack);
	}
}

public void Weapon_ExplosiveAR_FireInternal(DataPack DataDo)
{		
	DataDo.Reset();
	int client = EntRefToEntIndex(DataDo.ReadCell());
	int weapon = EntRefToEntIndex(DataDo.ReadCell());
	bool soundDo = DataDo.ReadCell();
	delete DataDo;

	if(!IsValidEntity(weapon) || !IsValidClient(client))
		return;

	if(soundDo)
		EmitSoundToAll("weapons/capper_shoot.wav", client, SNDCHAN_AUTO, 75, _, 0.85, 110);

	Firebullet(client, weapon);
}

public void Gun_BombARTouch(int entity, int target)
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

		/*float GameTime = GetGameTime();

		if(f_rest_time[owner] < GameTime)
		{
			Cause_Terroriser_Explosion(owner, entity);
		}*/
		
		float damage = 500.0;
		damage *=Attributes_Get(weapon, 2, 1.0);

		if(!b_NpcIsInvulnerable[target])
		{
			f_BombEntityWeaponDamageApplied[target][owner] += damage / 12.0;
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

public void Enable_ExploARWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(h_TimerExploARWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOMB_AR)
		{
			//Is the weapon it again?
			//Yes?
			ExploAR_WeaponPap[client] = ExplosiveAR_Get_Pap(weapon);
			i_BurstNum[client] = RoundToCeil(Attributes_Get(weapon, 401, 1.0));
			Can_I_Fire[client]=false;
			i_WeaponID[client]=EntIndexToEntRef(weapon);
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
			i_BurstNum[client] = RoundToCeil(Attributes_Get(weapon, 401, 1.0));
			Can_I_Fire[client]=false;
			i_WeaponID[client]=EntIndexToEntRef(weapon);
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
		if(ExploAR_WeaponPap[client]!=0)
			CreateExploAREffect(client);
	}
	else
	{
		DestroyExploAREffect(client);
	}

	return Plugin_Continue;
}

/*
void WeaponExploAR_OnTakeDamageNpc(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if(i_IsABuilding[victim])
	{
		damage *= 1.2;
	}
	if(b_AbilityActivated[attacker])
	{
		damage *= 0.65;
		if(b_thisNpcIsARaid[victim])
		{
			damage *= 1.15;
		}
	}
	if(Change[attacker]&& (damagetype & DMG_CLUB))
	{
		damage *= 0.5;
		static float angles[3];
		GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		float position[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", position);
		float spawnLoc[3];
		float BaseDMG = 200.0;
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);
		float Falloff = Attributes_Get(weapon, 117, 1.0);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

		Explode_Logic_Custom(BaseDMG, attacker, attacker, weapon, position, _, Falloff);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime(weapon)+1.2);
		SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime(attacker)+1.2);
		
		EmitAmbientSound(SOUND_VIC_IMPACT, spawnLoc, victim, 70,_, 0.9, 70);
		ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);
	}
}
void WeaponExploAR_OnTakeDamage( int victim, float &damage)
{
	if(b_AbilityActivated[victim])
	{
		damage *= 0.90;
	}
}

static Action Timer_Bool_ExploAR(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	b_AbilityActivated[client] = false;
	return Plugin_Stop;
}
*/

static void CreateExploAREffect(int client)
{
	int new_ammo = GetAmmo(client, 8);
	if(ExploAR_HUDDelay[client] < GetGameTime())
	{
			PrintHintText(client,"Mode: PIERCE / Blast Shells: %i", new_ammo);
		
		ExploAR_HUDDelay[client] = GetGameTime() + 0.5;
	}
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