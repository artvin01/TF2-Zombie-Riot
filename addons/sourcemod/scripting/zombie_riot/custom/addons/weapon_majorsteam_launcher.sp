#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerMajorSteam_Launcher[MAXPLAYERS] = {null, ...};
static float f_MajorSteam_Launcher_Delay[MAXPLAYERS];
static float f_MajorSteam_Launcher_HUDDelay[MAXPLAYERS];
static int i_MajorSteam_Launcher_Resistance[MAXPLAYERS];
static int i_MajorSteam_Launcher_Recharging[MAXPLAYERS];
static int i_MajorSteam_Launcher_WeaponPap[MAXPLAYERS];
static int i_MajorSteam_Launcher_Perk[MAXPLAYERS];
static bool b_MajorSteam_Launcher_Toggle[MAXPLAYERS];
static int Chaos_ParticleEffect_I[MAXPLAYERS];
static int Chaos_ParticleEffect_II[MAXPLAYERS];

static const char g_ResistanceSounds[][] = {
	"weapons/fx/rics/ric1.wav",
	"weapons/fx/rics/ric2.wav",
	"weapons/fx/rics/ric3.wav",
	"weapons/fx/rics/ric4.wav",
	"weapons/fx/rics/ric5.wav"
};

float f_MajorSteam_Launcher_Resistance(int client)
{
	if(h_TimerMajorSteam_Launcher[client] != null)
	{
		if(i_MajorSteam_Launcher_WeaponPap[client]==1)
		{
			float f_Resistance = 1.8;
			if(i_MajorSteam_Launcher_Resistance[client]>0)
				f_Resistance=(float(1000-i_MajorSteam_Launcher_Resistance[client])/1000.0)*1.8;
			if(f_Resistance>1.8)f_Resistance=1.8;
			if(f_Resistance<0.1)f_Resistance=0.1;
			return f_Resistance;
		}
		else
		{
			float f_Resistance = 1.2;
			if(i_MajorSteam_Launcher_Resistance[client]>0)
				f_Resistance=(float(1000-i_MajorSteam_Launcher_Resistance[client])/1000.0)*1.2;
			if(f_Resistance>1.8)f_Resistance=1.2;
			if(f_Resistance<0.1)f_Resistance=0.4;
			return f_Resistance;
		}
	}
	return 1.0;
}

void TFProjectile_Rocket_Spawn(int entity)
{
	RequestFrame(TFProjectile_Rocket_SpawnFrame, EntRefToEntIndex(entity));
}

void TFProjectile_Rocket_SpawnFrame(int ref)
{
	int entity = EntRefToEntIndex(ref);
	int client=GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(IsValidClient(client) && h_TimerMajorSteam_Launcher[client] != null)
	{
		if(i_MajorSteam_Launcher_WeaponPap[client]==1)
		{
			float vecSwingStart[3], vecAngles[3];
			GetAbsOrigin(entity, vecSwingStart);
			int particle = ParticleEffectAt(vecSwingStart, "critical_rocket_blue", 0.0); //Inf duartion
			i_rocket_particle[entity]= EntIndexToEntRef(particle);
			GetEntPropVector(entity, Prop_Data, "m_angRotation", vecAngles);
			TeleportEntity(particle, NULL_VECTOR, vecAngles, NULL_VECTOR);
			SetParent(entity, particle);
			SDKHook(entity, SDKHook_StartTouchPost, MajorSteam_ProjectileTouch);
		}
	}
}

static void MajorSteam_ProjectileTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)
	{
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
}

public void MajorSteam_Launcher_OnMapStart()
{
	Zero(i_MajorSteam_Launcher_WeaponPap);
	Zero(i_MajorSteam_Launcher_Resistance);
	Zero(f_MajorSteam_Launcher_Delay);
	Zero(f_MajorSteam_Launcher_HUDDelay);
	Zero(i_MajorSteam_Launcher_Recharging);
	Zero(i_MajorSteam_Launcher_Perk);
	Zero(b_MajorSteam_Launcher_Toggle);
	PrecacheSoundArray(g_ResistanceSounds);
}

public void MajorSteam_Launcher_WaveEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !b_IsPlayerABot[client])
			i_MajorSteam_Launcher_Resistance[client]=1000;
	}
}

public void Enable_MajorSteam_Launcher(int client, int weapon)
{
	if(h_TimerMajorSteam_Launcher[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAJORSTEAM_LAUNCHER)
		{
			i_MajorSteam_Launcher_Perk[client]=i_CurrentEquippedPerk[client];
			i_MajorSteam_Launcher_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 122, 0.0));
			b_MajorSteam_Launcher_Toggle[client] = false;
			int RocketLoad = GetEntData(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
			int RockeyAmmo=GetAmmo(client, 8);
			int RocketAmmoMAX=(i_MajorSteam_Launcher_WeaponPap[client]==1 ? 11 : 6);
			if(RocketLoad<RocketAmmoMAX)
			{
				SetAmmo(client, 8, RockeyAmmo+RocketLoad);
				SetEntData(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 0);
			}
			DestroyChaos_ParticleEffect(client);
			Add_Chaos_ParticleEffect(client);
			delete h_TimerMajorSteam_Launcher[client];
			h_TimerMajorSteam_Launcher[client] = null;
			DataPack pack;
			h_TimerMajorSteam_Launcher[client] = CreateDataTimer(0.1, Timer_MajorSteam_Launcher, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAJORSTEAM_LAUNCHER)
	{
		i_MajorSteam_Launcher_Perk[client]=i_CurrentEquippedPerk[client];
		i_MajorSteam_Launcher_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		b_MajorSteam_Launcher_Toggle[client] = false;
		int RocketLoad = GetEntData(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
		int RockeyAmmo=GetAmmo(client, 8);
		int RocketAmmoMAX=(i_MajorSteam_Launcher_WeaponPap[client]==1 ? 11 : 6);
		if(RocketLoad<RocketAmmoMAX)
		{
			SetAmmo(client, 8, RockeyAmmo+RocketLoad);
			SetEntData(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 0);
		}
		DestroyChaos_ParticleEffect(client);
		Add_Chaos_ParticleEffect(client);
		DataPack pack;
		h_TimerMajorSteam_Launcher[client] = CreateDataTimer(0.1, Timer_MajorSteam_Launcher, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

static Action Timer_MajorSteam_Launcher(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		DestroyChaos_ParticleEffect(client);
		h_TimerMajorSteam_Launcher[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	bool holding;
	if(weapon_holding == weapon)
	{
		holding=true;
		ApplyStatusEffect(client, client, "Major Steam's Launcher Resistance", 0.5);
	}
	else
		holding=false;
	MajorSteam_Launcher_Function(client, weapon, holding);
	if(holding)
		MajorSteam_Launcher_HUD(client);

	return Plugin_Continue;
}

public void MajorSteam_Launcher_PlayerTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(attacker) || GetTeam(attacker) == TFTeam_Red)
		return;
	if(!IsValidClient(victim))
		return;
	f_MajorSteam_Launcher_Delay[victim]= GetGameTime() + 10.0;
	if(i_MajorSteam_Launcher_Resistance[victim] > 0)
	{
		EmitSoundToAll(g_ResistanceSounds[GetRandomInt(0, sizeof(g_ResistanceSounds) - 1)], victim, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		if(i_MajorSteam_Launcher_WeaponPap[victim]==1)
		{
			if(RaidbossIgnoreBuildingsLogic(1))
				i_MajorSteam_Launcher_Resistance[victim]-=20;
			else
				i_MajorSteam_Launcher_Resistance[victim]-=5;
		}
		else
		{
			if(RaidbossIgnoreBuildingsLogic(1))
				i_MajorSteam_Launcher_Resistance[victim]-=40;
			else
				i_MajorSteam_Launcher_Resistance[victim]-=10;
		}
		if(i_MajorSteam_Launcher_Resistance[victim]<1)
			i_MajorSteam_Launcher_Resistance[victim]=0;
	}
}

public void MajorSteam_Launcher_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if(!CheckInHud() && i_MajorSteam_Launcher_WeaponPap[attacker]==1)
	{
		if(Items_HasNamedItem(attacker, "Major Steam's Rocket"))
		{
			ApplyStatusEffect(attacker, victim, "Cryo", 1.0);
			Elemental_AddCyroDamage(victim, attacker, RoundFloat(damage*0.65), 1);
		}
		else
		{
			ApplyStatusEffect(attacker, victim, "Freeze", 1.0);
			Elemental_AddCyroDamage(victim, attacker, RoundFloat(damage*0.5), 0);
		}
		if(NpcStats_IsEnemyTrueFrozen(victim) && f_TimeFrozenStill[victim] > GetGameTime(victim))
		{
			damage*=1.25;
			DisplayCritAboveNpc(victim, attacker, true, _, _, false);
		}
	}
}

static void MajorSteam_Launcher_Function(int client, int weapon, bool holding)
{
	if(Armor_Charge[client] < 1)
	{
		//none
	}
	else if(Waves_InSetup())
	{
		i_MajorSteam_Launcher_Resistance[client]=1000;
	}
	else if(holding && f_MajorSteam_Launcher_Delay[client] < GetGameTime())
	{
		i_MajorSteam_Launcher_Recharging[client]+=(RaidbossIgnoreBuildingsLogic(1) ? 2 : 1);
		if(i_MajorSteam_Launcher_Recharging[client]>30 && i_MajorSteam_Launcher_Resistance[client]<1000)
		{
			i_MajorSteam_Launcher_Recharging[client]=0;
			i_MajorSteam_Launcher_Resistance[client]+=(i_MajorSteam_Launcher_WeaponPap[client]==1 ? 50 : 25);
			if(i_MajorSteam_Launcher_Resistance[client]>1000)
				i_MajorSteam_Launcher_Resistance[client]=1000;
		}
	}
	else i_MajorSteam_Launcher_Recharging[client]=0;
	
	if(IsValidEntity(weapon))
	{
		int RocketLoad = GetEntData(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
		if(holding && RocketLoad<=0 && !b_MajorSteam_Launcher_Toggle[client] && (GetClientButtons(client) & IN_ATTACK))
		{
			if(!b_MajorSteam_Launcher_Toggle[client])
			{
				b_MajorSteam_Launcher_Toggle[client]=true;
				SDKUnhook(client, SDKHook_PreThink, MajorSteam_Launcher_M1_PreThink);
				SDKHook(client, SDKHook_PreThink, MajorSteam_Launcher_M1_PreThink);
			}
		}
	}
}

static void MajorSteam_Launcher_M1_PreThink(int client)
{
	int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	if(h_TimerMajorSteam_Launcher[client] != null && IsValidEntity(getweapon))
	{
		if(GetClientButtons(client) & IN_ATTACK)
		{
		}
		else
		{
			int RocketLoad = GetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
			int RockeyAmmo=GetAmmo(client, 8);
			int RocketAmmoMAX=(i_MajorSteam_Launcher_WeaponPap[client]==1 ? 11 : 6);
			if(RocketLoad<RocketAmmoMAX)
			{
				SetAmmo(client, 8, RockeyAmmo+RocketLoad);
				SetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 0);
				Store_GiveAll(client, GetClientHealth(client));
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You need to Reload by %i!", (i_MajorSteam_Launcher_WeaponPap[client]==1 ? 11 : 6));
			}
			b_MajorSteam_Launcher_Toggle[client]=false;
			SDKUnhook(client, SDKHook_PreThink, MajorSteam_Launcher_M1_PreThink);
			return;
		}
	}
	else
	{
		b_MajorSteam_Launcher_Toggle[client]=false;
		SDKUnhook(client, SDKHook_PreThink, MajorSteam_Launcher_M1_PreThink);
		return;
	}
}

static void MajorSteam_Launcher_HUD(int client)
{
	if(f_MajorSteam_Launcher_HUDDelay[client] < GetGameTime())
	{
		char C_point_hints[512]="";
		
		Format(C_point_hints, sizeof(C_point_hints),
		"Shield: %1.f％", (float(i_MajorSteam_Launcher_Resistance[client])/1000.0)*100.0);
		if(Armor_Charge[client] < 1)
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor startup requires Armor!]", C_point_hints);
		}
		else if(Waves_InSetup() || i_MajorSteam_Launcher_Resistance[client]>=1000)
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor Idle Mode]", C_point_hints);
		}
		else if(f_MajorSteam_Launcher_Delay[client] > GetGameTime())
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor Restarting in %1.fs]", C_point_hints, (f_MajorSteam_Launcher_Delay[client]-GetGameTime()));
		else
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[", C_point_hints);
			for(int i=1; i<20; i++)
			{
				if(float(i_MajorSteam_Launcher_Recharging[client]) >= 30.0*(float(i)*0.05))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_FULL);
				}
				else if(float(i_MajorSteam_Launcher_Recharging[client]) > 30.0*(float(i)*0.05 - 1.0/60.0))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_PARTFULL);
				}
				else if(float(i_MajorSteam_Launcher_Recharging[client]) > 30.0*(float(i)*0.05 - 1.0/30.0))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_PARTEMPTY);
				}
				else
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_EMPTY);
				}
			}
			Format(C_point_hints, sizeof(C_point_hints),
			"%s]", C_point_hints);
		}

		if(C_point_hints[0] != '\0')
		{
			PrintHintText(client,"%s", C_point_hints);
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			f_MajorSteam_Launcher_HUDDelay[client] = GetGameTime() + 0.5;
		}
	}
}

static void Add_Chaos_ParticleEffect(int client)
{
	int entity = EntRefToEntIndex(Chaos_ParticleEffect_I[client]);
	if(!IsValidEntity(entity))
	{
		entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(entity))
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(entity, "eyes", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "unusual_smoking", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(entity, particle, "eyes", {5.0,0.0,0.0});
			Chaos_ParticleEffect_I[client] = EntIndexToEntRef(particle);
		}
	}
	entity = EntRefToEntIndex(Chaos_ParticleEffect_II[client]);
	if(!IsValidEntity(entity))
	{
		entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(entity))
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(entity, "eyes", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "unusual_psychic_eye_white_glow", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(entity, particle, "eyes", {5.0,0.0,-20.0});
			Chaos_ParticleEffect_II[client] = EntIndexToEntRef(particle);
		}
	}
}

static void DestroyChaos_ParticleEffect(int client)
{
	int entity = EntRefToEntIndex(Chaos_ParticleEffect_I[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	Chaos_ParticleEffect_I[client] = INVALID_ENT_REFERENCE;
	entity = EntRefToEntIndex(Chaos_ParticleEffect_II[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	Chaos_ParticleEffect_II[client] = INVALID_ENT_REFERENCE;
}