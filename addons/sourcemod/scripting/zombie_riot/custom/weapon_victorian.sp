#pragma semicolon 1
#pragma newdecls required

#define SOUND_VIC_SHOT 	"mvm/giant_demoman/giant_demoman_grenade_shoot.wav"
#define SOUND_VIC_IMPACT "weapons/explode1.wav"
#define SOUND_VIC_CHARGE_ACTIVATE 	"items/powerup_pickup_agility.wav"
#define SOUND_VIC_SUPER_CHARGE 	"ambient/cp_harbor/furnace_1_shot_05.wav"
#define SOUND_RAPID_SHOT_ACTIVATE "items/powerup_pickup_precision.wav"
#define SOUND_RAPID_SHOT_HYPER "mvm/mvm_warning.wav"
#define SOUND_OVERHEAT "player/medic_charged_death.wav"

#define MAX_VICTORIAN_SUPERCHARGE 10

static Handle h_TimerVictorianLauncher[MAXPLAYERS+1] = {null, ...};

static int g_GrenadeModel;
static int g_LaserIndex;

//wtf Why are there so many particles??
static float VictoriaLauncher_HUDDelay[MAXPLAYERS];
static int VictoriaParticle_I[MAXPLAYERS];
static int VictoriaParticle_II[MAXPLAYERS];
static int VictoriaParticle_III[MAXPLAYERS];

static float fHESH_FlyTime[MAXENTITIES];
static float fHESH_DMG[MAXENTITIES];
static float fHESH_Radius[MAXENTITIES];
static int iHESH_Owner[MAXENTITIES];
static int iHESH_Weapon[MAXENTITIES];
static int iHESH_Particle_I[MAXENTITIES];
static int iHESH_Particle_II[MAXENTITIES];
static int iHESH_Particle_III[MAXENTITIES];
static bool bHESH_BIG_BOOM[MAXENTITIES];

static int Load_SuperCharge[MAXPLAYERS];
static int Load_Maximum[MAXPLAYERS];
static bool Charge_Mode[MAXPLAYERS];
static bool Burst_Mode[MAXPLAYERS];
static float Rapid_Mode[MAXPLAYERS];
static bool Overheat_Mode[MAXPLAYERS];

static float Victoria_TmepSpeed[MAXPLAYERS];
static float Victoria_DoubleTapR[MAXPLAYERS];
static bool Victoria_PerkDeadShot[MAXPLAYERS];

void ResetMapStartVictoria()
{
	Victoria_Map_Precache();
	Zero(Load_SuperCharge);
	Zero(Load_Maximum);
	Zero(Charge_Mode);
	Zero(Burst_Mode);
	Zero(Rapid_Mode);
	Zero(Overheat_Mode);
	Zero(Victoria_PerkDeadShot);
	Zero(Victoria_DoubleTapR);
	Zero(Victoria_TmepSpeed);
}
static void Victoria_Map_Precache()
{
	PrecacheSound(SOUND_VIC_SHOT);
	PrecacheSound(SOUND_VIC_IMPACT);
	PrecacheSound(SOUND_VIC_CHARGE_ACTIVATE);
	PrecacheSound(SOUND_VIC_SUPER_CHARGE);
	PrecacheSound(SOUND_RAPID_SHOT_ACTIVATE);
	PrecacheSound(SOUND_RAPID_SHOT_HYPER);
	PrecacheSound(SOUND_OVERHEAT);
	PrecacheSound("weapons/crit_power.wav");
	g_LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	static char model[PLATFORM_MAX_PATH];
	model = "models/weapons/w_models/w_grenade_grenadelauncher.mdl";
	g_GrenadeModel = PrecacheModel(model);
}

public void Enable_Victorian_Launcher(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(h_TimerVictorianLauncher[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_VICTORIAN_LAUNCHER)
		{
			if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
			{
				if(!Victoria_PerkDeadShot[client])
				{
					Victoria_PerkDeadShot[client]=true;
					SetGlobalTransTarget(client);
					PrintToChat(client, "%t", "VictorianLauncher 5 Perk Desc");
				}
			}
			else
			{
				Victoria_PerkDeadShot[client]=false;
			}
			delete h_TimerVictorianLauncher[client];
			h_TimerVictorianLauncher[client] = null;
			DataPack pack;
			h_TimerVictorianLauncher[client] = CreateDataTimer(0.1, Timer_VictoriaLauncher, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else if(i_CustomWeaponEquipLogic[weapon] == WEAPON_VICTORIAN_LAUNCHER)
	{
		if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
		{
			if(!Victoria_PerkDeadShot[client])
			{
				Victoria_PerkDeadShot[client]=true;
				SetGlobalTransTarget(client);
				PrintToChat(client, "%t", "VictorianLauncher 5 Perk Desc");
			}
		}
		else
		{
			Victoria_PerkDeadShot[client]=false;
		}
		DataPack pack;
		h_TimerVictorianLauncher[client] = CreateDataTimer(0.1, Timer_VictoriaLauncher, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
	if(Store_IsWeaponFaction(client, weapon, Faction_Victoria))	// Victoria
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(h_TimerVictorianLauncher[i])
			{
				ApplyStatusEffect(weapon, weapon, "Victorian Launcher's Call", 9999999.0);
				Attributes_SetMulti(weapon, 99, 1.1);
			}
		}
	}
}

static Action Timer_VictoriaLauncher(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerVictorianLauncher[client] = null;
		Zero(Load_SuperCharge);
		Zero(Load_Maximum);
		Zero(Charge_Mode);
		Zero(Burst_Mode);
		Zero(Rapid_Mode);
		Zero(Overheat_Mode);
		int entity = EntRefToEntIndex(VictoriaParticle_I[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		entity = EntRefToEntIndex(VictoriaParticle_II[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		entity = EntRefToEntIndex(VictoriaParticle_III[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		return Plugin_Stop;
	}	
	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	bool HoldOn;
	if(weapon_holding == weapon)
	{
		Victoria_Launcher_HUD(client);
		HoldOn=true;
	}
	Victoria_Launcher_Effect(client, HoldOn);
	return Plugin_Continue;
}

static void Victoria_Launcher_HUD(int client)
{
	if(VictoriaLauncher_HUDDelay[client] < GetGameTime())
	{
		char C_point_hints[512]="";
		
		SetGlobalTransTarget(client);
		Format(C_point_hints, sizeof(C_point_hints),
		"%t: %i", "Rockets", GetAmmo(client, 8));
		float Ability_CD = Ability_Check_Cooldown(client, 1);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		else
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n%t", C_point_hints, "VictorianLauncher OverHeated");
		}
		if(Rapid_Mode[client]>GetGameTime())
		{
			if(Overheat_Mode[client])
				Format(C_point_hints, sizeof(C_point_hints),
				"%s\n%t", C_point_hints, "VictorianLauncher OverDrive");
			else
				Format(C_point_hints, sizeof(C_point_hints),
				"%s\n%t", C_point_hints, "VictorianLauncher RapidFire");
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n%t\n[%.2f]", C_point_hints, "VictorianLauncher ManuallyR", Rapid_Mode[client]-GetGameTime());
		}
		else if(Charge_Mode[client])
		{
			if(Burst_Mode[client])
			{
				Format(C_point_hints, sizeof(C_point_hints),
				"%s\n%t", C_point_hints, "VictorianLauncher SuperShot", Load_SuperCharge[client]);
			}
			else
			{
				Format(C_point_hints, sizeof(C_point_hints),
				"%s\n%t[%i/%i]", C_point_hints, "VictorianLauncher CRockets", Load_SuperCharge[client], Load_Maximum[client]);
				if(Load_SuperCharge[client]>1 && Load_SuperCharge[client]<=5)
					Format(C_point_hints, sizeof(C_point_hints),
					"%s\n%t", C_point_hints, "VictorianLauncher ManuallyM2");
			}
		}
		if(Victoria_PerkDeadShot[client])
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n%t", C_point_hints, "VictorianLauncher 5 Perk On");
		}

		if(C_point_hints[0] != '\0')
		{
			PrintHintText(client,"%s", C_point_hints);
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			VictoriaLauncher_HUDDelay[client] = GetGameTime() + 0.5;
		}
	}
}

static void Victoria_Launcher_Effect(int client, bool HoldOn=false)
{
	if(CvarInfiniteCash.BoolValue)
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		else
			Ability_Apply_Cooldown(client, 2, 0.0);
		Ability_CD = Ability_Check_Cooldown(client, 3);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		else
			Ability_Apply_Cooldown(client, 3, 0.0);
	}
	if(Victoria_PerkDeadShot[client] && HoldOn)
	{
		if(Victoria_TmepSpeed[client] <= 0.0)
			Victoria_TmepSpeed[client] = 800.0;
		static int color[4] = {200, 255, 50, 200};
		static Handle swingTrace;
		static float pos[3], vecSwingForward[3];
		StartPlayerOnlyLagComp(client, true);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Victoria_TmepSpeed[client], false, 45.0, true);
		int target = TR_GetEntityIndex(swingTrace);	
		if(IsValidEnemy(client, target))
		{
			WorldSpaceCenter(target, pos);
		}
		else
		{
			delete swingTrace;
			int MaxTargethit = -1;
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Victoria_TmepSpeed[client], false, 45.0, true, MaxTargethit);
			TR_GetEndPosition(pos, swingTrace);
			delete swingTrace;
			swingTrace = TR_TraceRayFilterEx(pos, {90.0, 0.0, 0.0}, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
			TR_GetEndPosition(pos, swingTrace);
		}
		EndPlayerOnlyLagComp(client);
		delete swingTrace;
		pos[2] += 10.0;

		TE_SetupBeamRingPoint(pos, 100.0, 101.0, g_LaserIndex, g_LaserIndex, 0, 1, 0.1, 6.0, 0.1, color, 1, 0);
		TE_SendToClient(client);
	}
	if(Rapid_Mode[client]>GetGameTime())
	{
		//It's ridiculous, but this is the solution I came up with.
		if(HoldOn)
			ApplyStatusEffect(client, client, "Victorian Launcher Overdrive", 1.0);
		else //Once you activate the ability, don't swap to another weapon.
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()+1.0);
		VL_EYEParticle(client);
		int entity = EntRefToEntIndex(VictoriaParticle_I[client]);
		if(!IsValidEntity(entity))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			int particle = ParticleEffectAt(flPos, "medic_resist_fire", 0.0);
			SetParent(client, particle, "m_vecAbsOrigin");
			VictoriaParticle_I[client] = EntIndexToEntRef(particle);
		}
		if(!Overheat_Mode[client])
		{
			if(Rapid_Mode[client]-GetGameTime()<=15.0)
			{
				entity = EntRefToEntIndex(VictoriaParticle_II[client]);
				if(!IsValidEntity(entity))
				{
					float flPos[3];
					GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
					int particle = ParticleEffectAt(flPos, "utaunt_lavalamp_yellow_glow", 0.0);
					AddEntityToThirdPersonTransitMode(client, particle);
					SetParent(client, particle, "m_vecAbsOrigin");
					VictoriaParticle_II[client] = EntIndexToEntRef(particle);
				}
				EmitSoundToAll(SOUND_RAPID_SHOT_HYPER, client, SNDCHAN_AUTO, 70, _, 0.9);
				Overheat_Mode[client]=true;
			}
		}
		else
		{
			int health = GetClientHealth(client);
			if(health > 100)
			{
				int maxhealth = SDKCall_GetMaxHealth(client);
				float OverHeatTime = Rapid_Mode[client]-GetGameTime();
				float Overdrive = (12.0-(OverHeatTime > 11.9 ? 11.9 : OverHeatTime))/12.0*0.02;
				int newhealth = health-RoundToCeil(maxhealth * Overdrive);
				if(newhealth > health)newhealth=100;
				SetEntityHealth(client, newhealth);
			}
		}
		TF2_AddCondition(client, TFCond_CritOnKill, 0.3);
		StopSound(client, SNDCHAN_STATIC, "weapons/crit_power.wav");
	}
	else if(Charge_Mode[client])
		VL_EYEParticle(client);
	else
	{
		int entity = EntRefToEntIndex(VictoriaParticle_I[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		entity = EntRefToEntIndex(VictoriaParticle_II[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		entity = EntRefToEntIndex(VictoriaParticle_III[client]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
		if(Overheat_Mode[client])
		{
			Ability_Apply_Cooldown(client, 3, 60.0);
			Overheat_Mode[client]=false;
		}
	}
}

public void Weapon_Victoria_Main(int client, int weapon, bool crit)
{
	int new_ammo = GetAmmo(client, 8);
	if(new_ammo < 3)
	{
		ClientCommand(client, "playgamesound weapons/shotgun_empty.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Ammo", 3);
		return;
	}
	new_ammo -= 3;
	SetAmmo(client, 8, new_ammo);
	CurrentAmmo[client][8] = GetAmmo(client, 8);

	float RocketDMG=950.0;
	float RocketSpeed=800.0;
	float RocketRadius=EXPLOSION_RADIUS;
	float Angles[3], Position[3];
	float SIZEOverdrive=2.0;
	bool S2, S3, Overdrive, DEADSHOT;
	
	RocketSpeed*=Attributes_Get(weapon, 103, 1.0);
	RocketDMG*=Attributes_Get(weapon, 2, 1.0);
	RocketRadius*=Attributes_Get(weapon, 99, 1.0);
	float Cooldownbuff=Attributes_Get(weapon, 97, 1.0);
	//if Reloadspeed is bonus, apply it by halving it while applying it straight when it is debuff (for the sake of balance)
	if(Cooldownbuff!=1.0 && Cooldownbuff<1.0)
	{
		Cooldownbuff*=1.15;
		if(Cooldownbuff>0.9)
			Cooldownbuff=0.9;
	}
	
	GetClientEyeAngles(client, Angles);
	GetClientEyePosition(client, Position);
	Angles[0] -= 40.0;
	if(Angles[0] < -89.0)
		Angles[0] = -89.0;
		
	if(Charge_Mode[client])
	{
		S2=true;
		if(Burst_Mode[client])
		{
			Overdrive=true;
			SIZEOverdrive+=float(Load_SuperCharge[client])/5.0;
			RocketDMG*=1.3*float(Load_SuperCharge[client]);
			RocketRadius*=1.0+(float(Load_SuperCharge[client])/2.0);
			int maxhealth = SDKCall_GetMaxHealth(client);
			int health = GetClientHealth(client);
			int newhealth = health-RoundToNearest((float(Load_SuperCharge[client])/5.0)*(maxhealth*0.4));
			if(newhealth > health)
				newhealth=100;
			SetEntityHealth(client, newhealth);
			Ability_Apply_Cooldown(client, 2, 40.0);
			Ability_Apply_Cooldown(client, 1, (float(Load_SuperCharge[client])*4.0)*Cooldownbuff, .ignoreCooldown=true);
			Burst_Mode[client]=false;
			Charge_Mode[client]=false;
			Load_SuperCharge[client]=0;
		}
		else
		{
			Load_SuperCharge[client]--;
			RocketDMG*=1.2;
			RocketRadius*=1.2;
			if(Load_SuperCharge[client]<=5)RocketDMG*=1.1;
			if(Load_SuperCharge[client]<=0)
			{
				Ability_Apply_Cooldown(client, 2, 40.0);
				Burst_Mode[client]=false;
				Charge_Mode[client]=false;
				Load_SuperCharge[client]=0;
			}
		}
	}
	if(Rapid_Mode[client]>GetGameTime())
	{
		S3=true;
		SIZEOverdrive/=1.5;
		RocketRadius*=1.2;
		if(Overheat_Mode[client])
		{
			SIZEOverdrive*=1.35;
			Overdrive=true;
			RocketDMG*=1.45;
		}
		else RocketDMG*=0.8;
	}
	//Steam Major's rocket is always equipped
	RocketDMG*=1.1;
	if(RaidbossIgnoreBuildingsLogic(1))
		RocketRadius*=1.2;
	if(Victoria_PerkDeadShot[client])
	{
		DEADSHOT=true;
		RocketSpeed+=200.0;
	}
	float Overheat = Ability_Check_Cooldown(client, 1);
	if(Overheat <= 0.0)
		Overheat = 0.0;
	else RocketDMG*=0.5;
	VictoriaLauncher_HUDDelay[client]=0.0;
	int entity = CreateEntityByName("zr_projectile_base");
	if(IsValidEntity(entity))
	{
		bHESH_BIG_BOOM[entity]=false;
		fHESH_FlyTime[entity]=GetGameTime()+1.0;
		fHESH_DMG[entity]=RocketDMG;
		fHESH_Radius[entity]=RocketRadius;
		iHESH_Owner[entity]=EntIndexToEntRef(client);
		iHESH_Weapon[entity]=EntIndexToEntRef(weapon);
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetTeam(entity, GetTeam(client));
		int frame = GetEntProp(entity, Prop_Send, "m_ubInterpolationFrame");
		TeleportEntity(entity, Position, Angles, NULL_VECTOR);
		DispatchSpawn(entity);
		if(DEADSHOT)
		{
			float vec[3], VecStart[3], SpeedReturn[3]; WorldSpaceCenter(client, VecStart);
			Handle swingTrace;
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, RocketSpeed, false, 45.0, true);

			int target = TR_GetEntityIndex(swingTrace);	
			if(IsValidEnemy(client, target))
			{
				WorldSpaceCenter(target, vec);
			}
			else
			{
				delete swingTrace;
				int MaxTargethit = -1;
				DoSwingTrace_Custom(swingTrace, client, vecSwingForward, RocketSpeed, false, 45.0, true, MaxTargethit);
				TR_GetEndPosition(vec, swingTrace);
				delete swingTrace;
				swingTrace = TR_TraceRayFilterEx(vec, {90.0, 0.0, 0.0}, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
				TR_GetEndPosition(vec, swingTrace);
			}
			FinishLagCompensation_Base_boss();
			delete swingTrace;
			Victoria_TmepSpeed[client]=RocketSpeed;
			ArcToLocationViaSpeedProjectile(VecStart, vec, SpeedReturn, 1.0, 1.0);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
		}
		else
		{
			float fVel[3];
			GetAngleVectors(Angles, fVel, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(fVel, RocketSpeed);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
		}
		SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", GetGameTime());
		SetEntProp(entity, Prop_Send, "m_ubInterpolationFrame", frame);
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_GrenadeModel, _, i);
		}

		if(h_NpcSolidHookType[entity] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[entity]);
		h_NpcSolidHookType[entity] = 0;
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Tornado_RocketExplodePre);//I reused*2 code. I'm too lazy.
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Victorian_HESH_Touch);
		Better_Gravity_Rocket(entity, 55.0);
		GetAbsOrigin(entity, Position);
		int particle;
		if(S2)
		{
			if(Overdrive)
			{
				particle=ParticleEffectAt(Position, "critical_rocket_blue", 0.0);
				TeleportEntity(particle, Position, Angles, NULL_VECTOR);
				SetParent(entity, particle);
				iHESH_Particle_III[entity]=EntIndexToEntRef(particle);
				EmitSoundToAll(SOUND_OVERHEAT, client, SNDCHAN_AUTO, 70, _, 1.0, 70);
				bHESH_BIG_BOOM[entity]=true;
			}
			particle=ParticleEffectAt(Position, "critical_rocket_red", 0.0);
			TeleportEntity(particle, Position, Angles, NULL_VECTOR);
			SetParent(entity, particle);
			iHESH_Particle_I[entity]=EntIndexToEntRef(particle);
			particle=ParticleEffectAt(Position, "rockettrail", 0.0);
			TeleportEntity(particle, Position, Angles, NULL_VECTOR);
			SetParent(entity, particle);
			iHESH_Particle_II[entity]=EntIndexToEntRef(particle);
		}
		else if(S3)
		{
			if(Overdrive)
			{
				particle=ParticleEffectAt(Position, "critical_rocket_blue", 0.0);
				TeleportEntity(particle, Position, Angles, NULL_VECTOR);
				SetParent(entity, particle);
				iHESH_Particle_III[entity]=EntIndexToEntRef(particle);
			}
			particle=ParticleEffectAt(Position, "critical_rocket_red", 0.0);
			TeleportEntity(particle, Position, Angles, NULL_VECTOR);
			SetParent(entity, particle);
			iHESH_Particle_I[entity]=EntIndexToEntRef(particle);
			particle=ParticleEffectAt(Position, "halloween_rockettrail", 0.0);
			TeleportEntity(particle, Position, Angles, NULL_VECTOR);
			SetParent(entity, particle);
			iHESH_Particle_II[entity]=EntIndexToEntRef(particle);
		}
		else
		{
			particle=ParticleEffectAt(Position, "rockettrail", 0.0);
			TeleportEntity(particle, Position, Angles, NULL_VECTOR);
			SetParent(entity, particle);
			iHESH_Particle_I[entity]=EntIndexToEntRef(particle);
		}
		ApplyCustomModelToWandProjectile(entity, "models/weapons/w_models/w_grenade_grenadelauncher.mdl", SIZEOverdrive, "");
		EmitSoundToAll(SOUND_VIC_SHOT, client, SNDCHAN_AUTO, 70, _, 0.9);
	}
}

public void Weapon_Victoria_Sub(int client, int weapon, bool crit, int slot)
{
	if(Rapid_Mode[client]<GetGameTime())
	{
		float Ability_CD = Ability_Check_Cooldown(client, 1);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction,"This Weapon still Over Heated! %.1f seconds!", Ability_CD);
			return;
		}
		Ability_CD = Ability_Check_Cooldown(client, slot);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		if(Ability_CD>0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
		else if(!Charge_Mode[client])
		{
			Rogue_OnAbilityUse(client, weapon);
			EmitSoundToAll(SOUND_VIC_CHARGE_ACTIVATE, client, SNDCHAN_AUTO, 70, _, 1.0);
			Load_Maximum[client] = RoundToZero(MAX_VICTORIAN_SUPERCHARGE*Attributes_Get(weapon, 4, 1.0));
			Load_SuperCharge[client]=Load_Maximum[client];
			Charge_Mode[client]=true;
		}
		else if(!Burst_Mode[client] && Load_SuperCharge[client]>1 && Load_SuperCharge[client]<=5)
		{
			Rogue_OnAbilityUse(client, weapon);
			EmitSoundToAll(SOUND_VIC_SUPER_CHARGE, client, SNDCHAN_AUTO, 70, _, 1.0);
			Burst_Mode[client]=true;
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction,"You cannot use 2 abilities at the same time");
	}
}

public void Weapon_Victoria_Spe(int client, int weapon, bool crit, int slot)
{
	if(b_InteractWithReload[client])
	{ 
		bool R_AbilityBlock=false;
		int building = EntRefToEntIndex(i2_MountedInfoAndBuilding[1][client]);
		if(building != -1 && Building_Collect_Cooldown[building][client]<=0.0
		&& IsInteractionBuilding(client, building))
		{
			static float angles[3];
			GetClientEyeAngles(client, angles);
			if(angles[0] < -70.0)
			{
				if(Victoria_DoubleTapR[client] < GetGameTime())
				{
					Victoria_DoubleTapR[client] = GetGameTime() + 0.2;
					R_AbilityBlock=true;
				}
			}
		}
		if(R_AbilityBlock)return;
	}
	if(!Charge_Mode[client])
	{
		float Ability_CD = Ability_Check_Cooldown(client, 1);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction,"This Weapon still Over Heated! %.1f seconds!", Ability_CD);
			return;
		}
		Ability_CD = Ability_Check_Cooldown(client, slot);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		if(Ability_CD>0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
		else
		{
			if(Rapid_Mode[client]<GetGameTime())
			{
				Rogue_OnAbilityUse(client, weapon);
				EmitSoundToAll(SOUND_RAPID_SHOT_ACTIVATE, client, SNDCHAN_AUTO, 70, _, 1.0);
				Rapid_Mode[client]=GetGameTime()+30.0;
			}
			else
			{
				Ability_CD=Rapid_Mode[client]-GetGameTime();
				if(Ability_CD <= 0.0)Ability_CD = 0.0;
				else if(Ability_CD>5.0)Ability_CD=5.0;
				Ability_Apply_Cooldown(client, slot, 60.0-Ability_CD);
				Overheat_Mode[client]=false;
				Rapid_Mode[client]=0.0;
			}
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction,"You cannot use 2 abilities at the same time");
	}
}

static void Victorian_HESH_Touch(int entity, int target)
{
	if(target < 0)	
	{
		//hits soemthing it shouldnt, ignore entirely.
		return;
	}
	int weapon = EntRefToEntIndex(iHESH_Weapon[entity]);
	if(IsValidEntity(weapon))
	{
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		int owner = EntRefToEntIndex(iHESH_Owner[entity]);
		float DMGBoost=1.0, BaseDMG=fHESH_DMG[entity], DistBoost=fHESH_Radius[entity];
		DMGBoost=((fHESH_FlyTime[entity]-GetGameTime()/1.0)*0.15);
		DMGBoost *= -1.0;
		DMGBoost += 1.0;
		if(DMGBoost > 1.15)
			DMGBoost=1.15;
		if(DMGBoost < 0.85)
			DMGBoost=0.85;
		DistBoost*=DMGBoost;
		BaseDMG*=DMGBoost;
		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, DistBoost, Attributes_Get(weapon, 117, 1.0), _, _, _, _, _, Did_Someone_Get_Hit);
		EmitAmbientSound(SOUND_VIC_IMPACT, position, entity, 70,_, 0.9, 70);
		ParticleEffectAt(position, "rd_robot_explosion_smoke_linger", 1.0);
		if(bHESH_BIG_BOOM[entity])
			TE_Particle("hightower_explosion", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = owner);
	}
	int particle = EntRefToEntIndex(iHESH_Particle_I[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	particle = EntRefToEntIndex(iHESH_Particle_II[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	particle = EntRefToEntIndex(iHESH_Particle_III[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	RemoveEntity(entity);
}

static void Did_Someone_Get_Hit(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(entity))
	{
		float Ability_CD = Ability_Check_Cooldown(entity, 2);
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		else
			Ability_Apply_Cooldown(entity, 2, Ability_CD-(b_thisNpcIsARaid[victim] ? 1.0 : 0.2), weapon, true);
	}
}
static void VL_EYEParticle(int client)
{
	int entity = EntRefToEntIndex(VictoriaParticle_I[client]);
	if(!IsValidEntity(entity))
	{
		entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(entity))
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(entity, "eyeglow_l", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "eye_powerup_red_lvl_2", 0.0);
			AddEntityToThirdPersonTransitMode(entity, particle);
			SetParent(entity, particle, "eyeglow_l");
			VictoriaParticle_I[client] = EntIndexToEntRef(particle);
		}
	}
}

bool IsInteractionBuilding(int client, int building)
{
	bool IsInteraction=false;
	if(StrEqual(c_NpcName[building], "Ammo Box")||StrEqual(c_NpcName[building], "Armor Table")||StrEqual(c_NpcName[building], "Food Fridge")
	||StrEqual(c_NpcName[building], "Perk Machine")||StrEqual(c_NpcName[building], "Merchant Brewing Stand")
	||StrEqual(c_NpcName[building], "Merchant Grill")||StrEqual(c_NpcName[building], "Tinker Workshop"))
		IsInteraction=true;
	if(StrEqual(c_NpcName[building], "Pack-a-Punch") && Pap_WeaponCheck(client))
		IsInteraction=true;
	return IsInteraction;
}