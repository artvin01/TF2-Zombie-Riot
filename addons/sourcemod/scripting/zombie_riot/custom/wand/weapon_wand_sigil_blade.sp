#pragma semicolon 1
#pragma newdecls required

//static int Weapon_Sigil_MaxPap = 3;

static Handle h_Sigil_hud[MAXPLAYERS];
static float fl_Sigil_Next_hud[MAXPLAYERS];
static int i_Current_Pap[MAXPLAYERS];
static int i_Sigil[MAXENTITIES];
static int i_Sigil_Slash_Trail[MAXPLAYERS];
static int i_Sigil_Prop[MAXENTITIES];
static float fl_Sigil_Spawn_Time[MAXPLAYERS];
static float fl_Sigilpos[MAXPLAYERS][3];
//static float fl_Manaflow_rate[MAXPLAYERS];
static float fl_Slash_increase[MAXPLAYERS];
static float fl_Slash_duration[MAXPLAYERS];
static int i_Slash_Target_Ref[MAXPLAYERS];

static int i_Max_ION_Hit = 5;

static float fl_Sigil_Melee_Range = 130.0;
static float fl_Sigil_Crystal_ManaCost_Percent = 0.35;
static float fl_Sigil_Crystal_LifeSpan = 6.0;
static float fl_Sigil_Crystal_Spawn_Cooldown = 180.0;
static float fl_Slash_ManaCost_Max_Percent = 0.5;
static float fl_Slash_Time_Max = 3.0;
static float fl_Slash_Increase_Time = 2.0;
static float fl_Slash_Increase_Max = 2.5;
static float fl_Slash_Damage_Raidus = 100.0;
static float fl_Slash_Damage_Raidus_Sqared = 10000.0;
//static float fl_ManaFlow_SelfHeal_Time = 3.0;

static float fl_Sigil_Tele_Cooldown_Return[4] = {0.0, 0.0, 4.0, 6.0};
static float DamageToManaOverFlowRatio[4] = {0.0, 0.5, 0.75, 1.0};
static float fl_ManaFlow_Dmg_Percent[4] = {0.0, 0.2, 0.25, 0.3};
static float fl_ManaFlow_ION_BaseDmg[4] = {0.0, 90.0, 105.0, 125.0};

static int i_sigil_color[4] = {34, 177, 76, 255};

#define SIGIL_PLACED "items/spawn_item.wav"

static const char g_SIGIL_BREAK[][] = {
	"physics/glass/glass_impact_bullet1.wav",
	"physics/glass/glass_impact_bullet2.wav",
	"physics/glass/glass_impact_bullet3.wav",
	"physics/glass/glass_impact_bullet4.wav"
};

static const char g_SIGIL_TELE[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

#define SIGIL_SLASH_SOUND "ambient/sawblade_impact1.wav"
#define SIGIL_SLASH_CHARGE1 "mvm/mvm_tank_horn.wav"
#define SIGIL_SLASH_CHARGE2 "weapons/airstrike_fire_01.wav"

#define SIGIL_MELEE_HIT	"weapons/halloween_boss/knight_axe_hit.wav"

#define SIGIL_CRYSTAL	"models/props_moonbase/moon_gravel_crystal_blue.mdl"

#define SIGIL_LASTMANN "#zombiesurvival/expidonsa_waves/wave_45_music_1.mp3"

static const char Sigil_Melee_Hit_World[][] = {
	"weapons/samurai/tf_katana_impact_object_01.wav",
	"weapons/samurai/tf_katana_impact_object_02.wav",
	"weapons/samurai/tf_katana_impact_object_03.wav"
};

static const char Sigil_Charge_Hit_World[][] = {
	"weapons/demo_charge_hit_world1.wav",
	"weapons/demo_charge_hit_world2.wav",
	"weapons/demo_charge_hit_world3.wav"
};


public void Wand_Sigil_Blade_MapStart()
{
	Zero(i_Current_Pap);
	Zero(h_Sigil_hud);
	//Zero(fl_Manaflow_rate);
	Zero(fl_Slash_duration);
	Zero(i_Sigil_Prop);
	Zero(i_Sigil_Slash_Trail);
	Zero(fl_Slash_increase);
	Zero(i_Slash_Target_Ref);
	PrecacheSound(SIGIL_PLACED);
	PrecacheSoundArray(g_SIGIL_BREAK);
	PrecacheSoundArray(g_SIGIL_TELE);
	PrecacheSound(SIGIL_MELEE_HIT);
	PrecacheSound(SIGIL_SLASH_SOUND);
	PrecacheSound(SIGIL_SLASH_CHARGE1);
	PrecacheSound(SIGIL_SLASH_CHARGE2);
	PrecacheSound(SIGIL_LASTMANN);
	
	PrecacheParticleEffect("player_sparkles_red");
  
	PrecacheModel(SIGIL_CRYSTAL);
  
	for (int i = 0; i < (sizeof(Sigil_Melee_Hit_World)); i++) { PrecacheSound(Sigil_Melee_Hit_World[i]); }
	for (int i = 0; i < (sizeof(Sigil_Charge_Hit_World)); i++) { PrecacheSound(Sigil_Charge_Hit_World[i]); }
}

public void Enable_Sigil_Blade(int client, int weapon)
{
//	used in zombie_riot/store.sp
	if (h_Sigil_hud[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SIGIL_BLADE)
		{
			delete h_Sigil_hud[client];
			h_Sigil_hud[client] = null;
			DataPack pack;
			h_Sigil_hud[client] = CreateDataTimer(0.1, Timer_Sigil_Blade, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SIGIL_BLADE)
	{
		DataPack pack;
		h_Sigil_hud[client] = CreateDataTimer(0.1, Timer_Sigil_Blade, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		fl_Sigil_Next_hud[client] = 0.0;
	}
}

public Action Timer_Sigil_Blade(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_Sigil_hud[client] = null;
		return Plugin_Stop;
	}
	i_Current_Pap[client] = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	Sigil_Blade_HUD(client, weapon, false);
	return Plugin_Continue;
}

public void Sigil_Blade_HUD(int client, int weapon, bool forced)
{
	if(fl_Sigil_Next_hud[client] < GetGameTime() || forced)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon_holding == weapon)
		{
			int a = 0;
			if(i_Sigil[client] != 0)
				a++;
			if(fl_Slash_increase[client] > 0.0)
				a += 2;
			if(a == 3)
			{
				float crystaltimeleft = FloatAbs(GetGameTime() - fl_Sigil_Spawn_Time[client]);
				PrintHintText(client, "Crystal life time: [%.1f/%.1f]\nCharge damage bonus: [%.2f/%.2f]", crystaltimeleft, fl_Sigil_Crystal_LifeSpan, (fl_Slash_increase[client] + 1.0), fl_Slash_Increase_Max);
			}
			if(a == 2)
			{
				PrintHintText(client, "Charge damage bonus: [%.2f/%.2f]", (fl_Slash_increase[client] + 1.0), fl_Slash_Increase_Max);
			}
			if(a == 1)
			{
				float crystaltimeleft = FloatAbs(GetGameTime() - fl_Sigil_Spawn_Time[client]);
				PrintHintText(client, "Crystal life time: [%.1f/%.1f]", crystaltimeleft, fl_Sigil_Crystal_LifeSpan);
			}
		}
		fl_Sigil_Next_hud[client] = GetGameTime() + 0.5;
	}
}

public void Weapon_Sigil_Blade_M1(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if(mana_cost <= Current_Mana[client])
	{
		float clientEyePos[3], vicPos[3], clientEyeAng[3], clientRight[3], direction[3], hullMin[3], hullMax[3];
		SDKhooks_SetManaRegenDelayTime(client, 1.25);
		Mana_Hud_Delay[client] = 0.0;
		Current_Mana[client] -= mana_cost;
			
		delay_hud[client] = 0.0;
		
		GetClientEyePosition(client, clientEyePos);
		GetClientEyeAngles(client, clientEyeAng);
		GetAngleVectors(clientEyeAng, direction, clientRight, NULL_VECTOR);
		ScaleVector(direction, fl_Sigil_Melee_Range);
		
		hullMin[0] = -40.0;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		
		AddVectors(clientEyePos, direction, vicPos);
		
		StartLagCompensation_Base_Boss(client);
		
		Handle trace = TR_TraceRayFilterEx(clientEyePos, vicPos, MASK_SHOT, RayType_EndPoint, BulletAndMeleeTrace, client);
		int target = TR_GetEntityIndex(trace);
		TR_GetEndPosition(vicPos, trace);
		float traceFraction = TR_GetFraction(trace);
		if(traceFraction == 1.0)
		{
			trace = TR_TraceHullFilterEx(clientEyePos, vicPos, hullMin, hullMax, MASK_SHOT, BulletAndMeleeTrace, client);
			target = TR_GetEntityIndex(trace);
			TR_GetEndPosition(vicPos, trace);
			traceFraction = TR_GetFraction(trace);
		}
		delete trace;
		
		FinishLagCompensation_Base_boss();
		
		if(IsValidEnemy(client, target, true))
		{
			float damage = 35.0;
			damage *= Attributes_Get(weapon, 410, 1.0);
			EmitSoundToAll(SIGIL_MELEE_HIT, 0, SNDCHAN_STATIC, 70, _, 1.0, SNDPITCH_NORMAL, -1, vicPos);
			Weapon_Sigil_Blade_Hit_Target_Effect(target, clientEyePos, clientRight, vicPos);
			int currentPap = i_Current_Pap[client];
			if(currentPap > 0)
			{
				int maxmana = RoundToCeil(float(ReturnEntityMaxHealth(target)) / 5.0);//according to how i set it in elemental
				if(Elemental_AddManaOverflowDamage(target, client, RoundToNearest(fl_ManaFlow_Dmg_Percent[currentPap] * maxmana + damage * DamageToManaOverFlowRatio[currentPap]), 1))
				{
					Force_ExplainBuffToClient(client, "Mana Overflow");
					Weapon_Sigil_Blade_Manaflow(client, target, weapon);
				}
		    }
		    if(Ability_Check_Cooldown(client, 2) > 0.0 && fl_Sigil_Tele_Cooldown_Return[currentPap] > 0.0)
		    {
		    	float cooldown = Ability_Check_Cooldown(client, 2);
		    	cooldown -= fl_Sigil_Tele_Cooldown_Return[currentPap];
		    	Ability_Apply_Cooldown(client, 2, cooldown);
		    }
			SDKHooks_TakeDamage(target, client, client, damage, DMG_CLUB, weapon, _, vicPos);
		}
		else
		{
			if(traceFraction < 1.0)
			{
				Weapon_Sigil_Blade_Hit_World_Effect(client, clientEyePos, clientEyeAng, vicPos);
				EmitSoundToAll(Sigil_Melee_Hit_World[GetRandomInt(0, sizeof(Sigil_Melee_Hit_World)-1)], 0, SNDCHAN_STATIC, 70, _, 1.0, SNDPITCH_NORMAL, -1, vicPos);
			}
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Weapon_Sigil_Blade_M2(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundFloat(fl_Sigil_Crystal_ManaCost_Percent * max_mana[client]);
	if(Ability_Check_Cooldown(client, slot) > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	
	
	if(i_Sigil[client] != 0)
	{
		
		float clientPos[3]; WorldSpaceCenter(client, clientPos);
		int sigilCrystal = EntRefToEntIndex(i_Sigil[client]);
		float sigilfPos[3];
		GetEntPropVector(sigilCrystal, Prop_Data, "m_vecAbsOrigin", sigilfPos);
		sigilfPos[0] = fl_Sigilpos[client][0];sigilfPos[1] = fl_Sigilpos[client][1];
		Handle trace = TR_TraceRayFilterEx(clientPos, sigilfPos, MASK_SHOT, RayType_EndPoint, Weapon_Sigil_Blade_Crystal_TraceFilter);
		float traceFraction = TR_GetFraction(trace);
		delete trace;
		if(traceFraction == 1.0)
		{
			float flPos[3];GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				
			TE_Start("TFParticleEffect");
			TE_WriteFloat("m_vecOrigin[0]", flPos[0]);
			TE_WriteFloat("m_vecOrigin[1]", flPos[1]);
			TE_WriteFloat("m_vecOrigin[2]", flPos[2]);
			TE_WriteNum("entindex", client);
			TE_WriteNum("m_iAttachType", 1);
			TE_WriteNum("m_iParticleSystemIndex", GetParticleEffectIndex("player_sparkles_red"));
			TE_SendToAll(-1.0);
	
			DataPack pack = new DataPack();
			RequestFrame(Sigil_Crystal_Teleport, pack);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(i_Sigil[client]));
			pack.WriteCell(EntIndexToEntRef(i_Sigil_Prop[client]));
			pack.WriteCell(0);
			
			fl_Slash_duration[client] = GetGameTime() + fl_Slash_Time_Max;
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Sigil must be in your sight.");
		}
		
	}
	else
	{
		if(mana_cost <= Current_Mana[client])
		{
			SDKhooks_SetManaRegenDelayTime(client, 1.25);
			Mana_Hud_Delay[client] = 0.0;
			Current_Mana[client] -= mana_cost;
			
			Rogue_OnAbilityUse(client, weapon);
			
			float clientPos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", clientPos);
			EmitSoundToAll(SIGIL_PLACED, 0, SNDCHAN_STATIC, 80, _, 1.0, SNDPITCH_NORMAL, -1, clientPos);
			fl_Sigilpos[client][0] = clientPos[0];fl_Sigilpos[client][1] = clientPos[1];fl_Sigilpos[client][2] = clientPos[2];
			
			i_Sigil[client] = Wand_Projectile_Spawn(client, 0.0, 12.0, 0.0, 0, weapon, "");
			SetEntProp(i_Sigil[client], Prop_Send, "m_usSolidFlags", 12); 
			i_Sigil_Prop[client] = CreateEntityByName("prop_physics_override");
			
			if(IsValidEntity(i_Sigil_Prop[client]) && IsValidEntity(i_Sigil[client]))
			{
				float Angles[3];
				char modelName[100];
				modelName = SIGIL_CRYSTAL;
				Angles[0] = 0.0;
				Angles[1] = 0.0;
				Angles[2] = 0.0;
				float loc[3];
				GetEntPropVector(i_Sigil[client], Prop_Send, "m_vecOrigin", loc);
					
				DispatchKeyValue(i_Sigil_Prop[client], "targetname", "sigilModel"); 
				DispatchKeyValue(i_Sigil_Prop[client], "spawnflags", "2"); 
				DispatchKeyValue(i_Sigil_Prop[client], "model", modelName);
				DispatchSpawn(i_Sigil_Prop[client]);
				MakeObjectIntangeable(i_Sigil_Prop[client]);
					
				TeleportEntity(i_Sigil_Prop[client], loc, Angles, NULL_VECTOR);
				SetParent(i_Sigil[client], i_Sigil_Prop[client]);
				SetEntityRenderMode(i_Sigil_Prop[client], RENDER_TRANSALPHA);
				SetEntityRenderColor(i_Sigil_Prop[client], i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 200);
				SetEntPropFloat(i_Sigil_Prop[client], Prop_Send, "m_flModelScale", 2.0);
			}
			SDKUnhook(i_Sigil[client], SDKHook_StartTouch, Rocket_Particle_StartTouch);
			fl_Sigil_Spawn_Time[client] = GetGameTime();
			CreateTimer(0.1, Sigil_Crystal_Think, EntIndexToEntRef(i_Sigil[client]), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			DataPack pack = new DataPack();
			CreateTimer(fl_Sigil_Crystal_LifeSpan, Timer_Sigil_Crystal_Remove, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(i_Sigil[client]));
			pack.WriteCell(EntIndexToEntRef(i_Sigil_Prop[client]));
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public void Weapon_Sigil_Blade_R(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundFloat(fl_Sigil_Crystal_ManaCost_Percent * max_mana[client] / (fl_Slash_Time_Max * 10));

	if(Ability_Check_Cooldown(client, slot) > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);

		if (Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	else
	{
		if(mana_cost <= Current_Mana[client])
		{
			
			Handle swingTrace;
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 1500.0, false, 45.0, true);
			FinishLagCompensation_Base_boss();
		
			int target = TR_GetEntityIndex(swingTrace);	
			delete swingTrace;
			if(!IsValidEnemy(client, target, true))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}
			SDKhooks_SetManaRegenDelayTime(client, 1.25);
			Mana_Hud_Delay[client] = 0.0;
			Current_Mana[client] -= mana_cost;
			
			i_Slash_Target_Ref[client] = EntIndexToEntRef(target);
		
			float clientAngle[3];	
			SetEntityGravity(client, 0.0001);
			
			Ability_Apply_Cooldown(client, slot, 60.0);
			
			fl_Slash_duration[client] = GetGameTime() + fl_Slash_Time_Max;
			f_AntiStuckPhaseThrough[client] = GetGameTime() + 0.5;
			f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + 0.5;
			ApplyStatusEffect(client, client, "Intangible", 0.5);
			TF2_AddCondition(client, TFCond_LostFooting, 999.0);
			TF2_AddCondition(client, TFCond_AirCurrent, 999.0);
			
			float selfPos[3];
			WorldSpaceCenter(client, selfPos);
			if(GetRandomInt(1, 100) >= 95)
				EmitSoundToAll(SIGIL_SLASH_CHARGE1, 0, SNDCHAN_STATIC, 90, _, 1.0, SNDPITCH_NORMAL, -1, selfPos);
			else
				EmitSoundToAll(SIGIL_SLASH_CHARGE2, 0, SNDCHAN_STATIC, 90, _, 1.0, SNDPITCH_NORMAL, -1, selfPos);
			
			IncreaseEntityDamageTakenBy(client, 0.8, 0.1);
			LookAtTarget(client, EntRefToEntIndex(i_Slash_Target_Ref[client]));
			GetClientEyeAngles(client, clientAngle);
			float velocity[3];
			GetAngleVectors(clientAngle, velocity, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(velocity, velocity);
			float speed = 750.0;
			ScaleVector(velocity, speed);
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

			int entIndex = CreateEntityByName("env_spritetrail");
			if (entIndex > 0 && IsValidEntity(entIndex))
			{
				char strTargetName[MAX_NAME_LENGTH];
		
				DispatchKeyValue(client, "targetname", strTargetName);
				Format(strTargetName,sizeof(strTargetName),"trail%d",EntIndexToEntRef(client));
				DispatchKeyValue(client, "targetname", strTargetName);
				DispatchKeyValue(entIndex, "parentname", strTargetName);
				
		
				DispatchKeyValue(entIndex, "spritename", "effects/beam001_red.vmt");
				SetEntPropFloat(entIndex, Prop_Send, "m_flTextureRes", 1.0);
					
				char sTemp[5];
				IntToString(255, sTemp, sizeof(sTemp));
				DispatchKeyValue(entIndex, "renderamt", sTemp);
					
				DispatchKeyValueFloat(entIndex, "lifetime", 1.2);
				DispatchKeyValueFloat(entIndex, "startwidth", 38.0);
				DispatchKeyValueFloat(entIndex, "endwidth", 3.0);
				
				IntToString(5, sTemp, sizeof(sTemp));
				DispatchKeyValue(entIndex, "rendermode", sTemp);
					
				DispatchSpawn(entIndex);
				float f_origin[3];
				WorldSpaceCenter(client, f_origin);
				f_origin[2] += 10.0;
				TeleportEntity(entIndex, f_origin, NULL_VECTOR, NULL_VECTOR);
				SetVariantString(strTargetName);
				SetParent(client, entIndex, "", _, false);
				i_Sigil_Slash_Trail[client] = EntIndexToEntRef(entIndex);
			}	
						
			
			
			DataPack pack = new DataPack();
			CreateTimer(0.1, Sigil_Slash_Think, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public Action Sigil_Slash_Think(Handle h, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	
	int team = GetTeam(client);
	int target = EntRefToEntIndex(i_Slash_Target_Ref[client]);
	bool charge = false;
	int mana_cost = RoundFloat(fl_Sigil_Crystal_ManaCost_Percent * max_mana[client] / (fl_Slash_Time_Max * 10));
	
	if(!b_NpcHasDied[target] && fl_Slash_duration[client] > GetGameTime() && mana_cost <= Current_Mana[client])
	{
		charge = true;
		for(int a; a < i_MaxcountNpcTotal; a++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			{
				if(GetTeam(entity) == team)
					continue;
	
				float selfPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", selfPos);
				float vecHitPos[3];WorldSpaceCenter(entity, vecHitPos);
				
				if(GetVectorDistance(selfPos, vecHitPos, true) > fl_Slash_Damage_Raidus_Sqared)
					continue;
	
				float damage = 35.0;
				damage *= Attributes_Get(weapon, 410, 1.0);
				damage *= 0.08;
				float clientEyePos[3];
				float angle[3];
				angle[0] = 0.0;angle[1] = GetRandomFloat(-180.0,180.0);angle[2] = 0.0;
				GetClientEyePosition(client, clientEyePos);
				Weapon_Sigil_Blade_Hit_Target_Effect(entity, clientEyePos, angle, vecHitPos);
				if(entity != target)
				{
					SDKHooks_TakeDamage(entity, client, client, damage, DMG_CLUB, weapon, _, vecHitPos);
				}
				else
				{
					charge = false;
					damage = 35.0;
					damage *= Attributes_Get(weapon, 410, 1.0);
					damage *= (1.0 + fl_Slash_increase[client]);
					int currentPap = i_Current_Pap[client];
					WorldSpaceCenter(client, selfPos);
					EmitSoundToAll(SIGIL_SLASH_SOUND, 0, SNDCHAN_STATIC, 90, _, 1.0, SNDPITCH_NORMAL, -1, selfPos);
					SDKHooks_TakeDamage(entity, client, client, damage, DMG_CLUB, weapon, _, vecHitPos);
					int maxmana = RoundToCeil(float(ReturnEntityMaxHealth(target)) / 5.0);//according to how i set it in elemental
					if(Elemental_AddManaOverflowDamage(target, client, RoundToNearest(fl_ManaFlow_Dmg_Percent[currentPap] * maxmana + damage * DamageToManaOverFlowRatio[currentPap]), 1))
					{
						Force_ExplainBuffToClient(client, "Mana Overflow");
						Weapon_Sigil_Blade_Manaflow(client, target, weapon);
					}
				}
			}
		}
		float clientVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", clientVelocity);
		if(GetVectorLength(clientVelocity, true) < 40000)
		{
			charge = false;
			float selfPos[3];
			WorldSpaceCenter(client, selfPos);
			EmitSoundToAll(Sigil_Charge_Hit_World[GetRandomInt(0, sizeof(Sigil_Charge_Hit_World)-1)], 0, SNDCHAN_STATIC, 90, _, 1.0, SNDPITCH_NORMAL, -1, selfPos);
		}
	}
	if(charge)
	{
		SDKhooks_SetManaRegenDelayTime(client, 1.25);
		Mana_Hud_Delay[client] = 0.0;
		Current_Mana[client] -= mana_cost;
			
		if(fl_Slash_increase[client] < fl_Slash_Increase_Max - 1.0 - fl_Slash_Increase_Max / (fl_Slash_Increase_Time * 10))
		{
			fl_Slash_increase[client] += fl_Slash_Increase_Max / (fl_Slash_Increase_Time * 10);
		}
		else
		{
			fl_Slash_increase[client] = fl_Slash_Increase_Max - 1.0;
		}
		f_AntiStuckPhaseThrough[client] = GetGameTime() + 0.5;
		f_AntiStuckPhaseThroughFirstCheck[client] = GetGameTime() + 0.5;
		ApplyStatusEffect(client, client, "Intangible", 0.5);
		IncreaseEntityDamageTakenBy(client, 0.8, 0.1);
		
		float selfPos[3];
		WorldSpaceCenter(client, selfPos);
		float targetPos[3];WorldSpaceCenter(target, targetPos);
		
		LookAtTarget(client, target);
		float clientAngle[3];
		GetClientEyeAngles(client, clientAngle);
		if(FloatAbs(selfPos[2] - targetPos[2]) < fl_Slash_Damage_Raidus * 0.5)	
			clientAngle[0] = -0.1;
		float velocity[3];
		GetAngleVectors(clientAngle, velocity, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(velocity, velocity);
		float speed = 750.0;
		ScaleVector(velocity, speed);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		return Plugin_Continue;
	}
	
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
	
	int trail = EntRefToEntIndex(i_Sigil_Slash_Trail[client]);
	if(IsValidEntity(trail))
	{
		RemoveEntity(trail);
	}
	
	TF2_RemoveCondition(client, TFCond_LostFooting);
	TF2_RemoveCondition(client, TFCond_AirCurrent);
	//TF2_RemoveCondition(client, TFCond_Charging);
	SetEntityGravity(client, 1.0);
	fl_Slash_increase[client] = 0.0;
	
	delete pack;
	return Plugin_Stop;
}

public Action Sigil_Crystal_Think(Handle spin, int ref)
{
	int projectile = EntRefToEntIndex(ref);
	if (IsValidEntity(projectile))
	{
		float ang[3];
		GetEntPropVector(projectile, Prop_Data, "m_angRotation", ang);
		float selfPos[3];
		GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", selfPos);
		int client = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");
		if(IsValidEntity(client))
		{
			float ownerPos[3];
			WorldSpaceCenter(client, ownerPos);
			Handle trace = TR_TraceRayFilterEx(ownerPos, selfPos, MASK_SHOT, RayType_EndPoint, Weapon_Sigil_Blade_Crystal_TraceFilter);
			float traceFraction = TR_GetFraction(trace);
			delete trace;
			if(traceFraction == 1.0)
			{
				TE_SetupBeamPoints(selfPos, ownerPos, Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, i_sigil_color, 0);
				int[] clients = new int[1];
				clients[0] = client;
				TE_Send(clients, 1, 0.0);
			}
			ownerPos[0] = fl_Sigilpos[client][0];ownerPos[1] = fl_Sigilpos[client][1];
			ownerPos[2] = fl_Sigilpos[client][2] + 70.0;
			ang[1] += 40.0;
			TeleportEntity(projectile, ownerPos, ang, {0.0,0.0,0.0});
		}
		
		
		return Plugin_Continue;
	}
	
	return Plugin_Stop;
}

public bool Weapon_Sigil_Blade_Crystal_TraceFilter(int entity, int contentsMask)
{
	if(IsEntityAlive(entity))
		return false;
	else
		return true;
}

public Action Timer_Sigil_Crystal_Remove(Handle h, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int projectile = EntRefToEntIndex(pack.ReadCell());
	int prop = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(projectile))
	{
		RemoveEntity(projectile);
		
		if(IsValidEntity(prop))
			RemoveEntity(prop);
	
		i_Sigil[client] = 0;
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Sigil crystal disappeared.");
		//EmitSoundToAll(SIGIL_DISABLE, 0, SNDCHAN_STATIC, 80, _, 1.0, SNDPITCH_NORMAL, -1, fl_Sigilpos[client]);
		//EmitSoundToClient(client, SIGIL_DISABLE);
		EmitSoundToClient(client, g_SIGIL_BREAK[GetRandomInt(0, sizeof(g_SIGIL_BREAK) - 1)], client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		//EmitSoundToClient(client, g_SIGIL_CRYSTAL[1], client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		Ability_Apply_Cooldown(client, 2, fl_Sigil_Crystal_Spawn_Cooldown);
	}
	delete pack;
	return Plugin_Stop; 
}
/*
public Action Sigil_Crystal_Teleport_H(Handle h, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int projectile = EntRefToEntIndex(pack.ReadCell());
	int prop = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(projectile))
	{
		RemoveEntity(projectile);
		
		if(IsValidEntity(prop))
			RemoveEntity(prop);
	
		i_Sigil[client] = 0;
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "You back to sigil.");
		float clientVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", clientVel);
		TeleportEntity(client, fl_Sigilpos[client], NULL_VECTOR, clientVel);
		ParticleEffectAt(fl_Sigilpos[client], "teleportedin_red", 1.0);
		Ability_Apply_Cooldown(client, 2, fl_Sigil_Crystal_Spawn_Cooldown);
		//EmitSoundToClient(client, SIGIL_TELE);
		EmitSoundToClient(client, g_SIGIL_TELE[GetRandomInt(0, sizeof(g_SIGIL_TELE) - 1)], client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.8);
		//EmitSoundToClient(client, g_SIGIL_CRYSTAL[0], client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	delete pack;
	return Plugin_Stop;
}*/

public void Sigil_Crystal_Teleport(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int projectile = EntRefToEntIndex(pack.ReadCell());
	int prop = EntRefToEntIndex(pack.ReadCell());
	int time = pack.ReadCell();
	
	if(time < 2)
	{
		if(time == 1)
		{
			TE_Start("EffectDispatch");
			TE_WriteNum("entindex", client);
			TE_WriteNum("m_nHitBox", GetParticleEffectIndex("player_sparkles_red"));
			TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
			TE_SendToAll();
		}
		pack.Position--;
		time++;
		pack.WriteCell(time);
		RequestFrame(Sigil_Crystal_Teleport, pack);
		return;
	}
	
	if(IsValidEntity(projectile))
	{
		RemoveEntity(projectile);
		
		if(IsValidEntity(prop))
			RemoveEntity(prop);
	
		i_Sigil[client] = 0;
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "You back to sigil.");
		float clientVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", clientVel);
		TeleportEntity(client, fl_Sigilpos[client], NULL_VECTOR, clientVel);
		ParticleEffectAt(fl_Sigilpos[client], "teleportedin_red", 1.0);
		Ability_Apply_Cooldown(client, 2, fl_Sigil_Crystal_Spawn_Cooldown);
		//EmitSoundToClient(client, SIGIL_TELE);
		EmitSoundToClient(client, g_SIGIL_TELE[GetRandomInt(0, sizeof(g_SIGIL_TELE) - 1)], client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.8);
		//EmitSoundToClient(client, g_SIGIL_CRYSTAL[0], client, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	delete pack;
}

public void Weapon_Sigil_Blade_Manaflow(int attacker, int victim, int weapon)
{//mostly the Apply_Sickness from ruina_npc_enchanced_ai_core
	int currentPap = i_Current_Pap[attacker];
	float 	dmg 		= fl_ManaFlow_ION_BaseDmg[currentPap],
			time 		= 2.5,		//how long until it goes boom
			Radius		= 100.0 * (1.0 + fl_Slash_increase[attacker]);
			
//	Sigil_Blade_Manaflow_SelfHeal(attacker, victim);
	
	dmg *= Attributes_Get(weapon, 410, 1.0);
	
	if(b_thisNpcIsARaid[victim])
		dmg *= 1.2;//its hard to keep raid bosses standing inside ION
	
	//Force_ExplainBuffToClient(Target, "Overmana Overload");
	float end_point[3];
	WorldSpaceCenter(victim, end_point);
	end_point[2]-=25.0;	

	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.75, i_sigil_color, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(end_point, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.1, i_sigil_color, 1, 0);
	TE_SendToAll();

	EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_SPAWN, attacker, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 1.0);

	Ruina_IonSoundInvoke(end_point);

	DataPack pack;
	CreateDataTimer(time, Sigil_Blade_Manaflow_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(attacker));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteFloatArray(end_point, sizeof(end_point));
	pack.WriteFloat(Radius);
	pack.WriteFloat(dmg);

	if(AtEdictLimit(EDICT_NPC))
		return;

	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=500.0; end_point[2]-=100.0;

	int laser;
	laser = ConnectWithBeam(-1, -1, i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);

	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

}

/*void Sigil_Blade_Manaflow_SelfHeal(int attacker, int victim)
{
	float maxhealth = float(ReturnEntityMaxHealth(attacker));
	float ratio = 0.04;
	if(b_thisNpcIsABoss[victim])
		ratio = 0.1;
	if(b_thisNpcIsARaid[victim])
		ratio = 0.2;
	HealEntityGlobal(attacker, attacker, maxhealth * ratio, _, fl_ManaFlow_SelfHeal_Time, HEAL_SELFHEAL);
}*/

Action Sigil_Blade_Manaflow_Ion(Handle Timer, DataPack data)
{//mostly the Ruina_Mana_Sickness_Ion from ruina_npc_enchanced_ai_core
//it records attacker, so players are able to know how much damage they delt with ION
	data.Reset();
	int attacker = EntRefToEntIndex(data.ReadCell());
	//int Team = GetTeam(attacker);
	int weapon = EntRefToEntIndex(data.ReadCell());
	float end_point[3];
	data.ReadFloatArray(end_point, sizeof(end_point));
	float Radius	= data.ReadFloat();
	float dmg 		= data.ReadFloat();

	float hitExtra = 0.0;
	hitExtra =	Radius / 100.0;
	if(hitExtra > 2.0)
		hitExtra = 2.0;
	
	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, 0.0, Radius*2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.75, Thickness, 0.75, i_sigil_color, 1, 0);
	TE_SendToAll();

	EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	
	EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_ATTACK);
	EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_ATTACK);

	//int count = 0;
	
	Explode_Logic_Custom(dmg, attacker, attacker, weapon, end_point, Radius, _, _, _, RoundToNearest(float(i_Max_ION_Hit) *  hitExtra));

	/*for(int a; a < i_MaxcountNpcTotal; a++)
	{
		if(count < RoundToNearest(float(i_Max_ION_Hit) *  hitExtra))
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			{
				if(GetTeam(entity) == Team)
					continue;
	
				float Vic_Pos[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Vic_Pos);
	
				if(GetVectorDistance(Vic_Pos, end_point, true) > Radius)
					continue;
	
				SDKHooks_TakeDamage(entity, attacker, attacker, dmg, DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE);
	
				int laser;
				laser = ConnectWithBeam(-1, entity, i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, end_point);
				CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
				
				count++;
			}
		}
	}*/

	if(AtEdictLimit(EDICT_NPC))
		return Plugin_Stop; 

	float Sky_Loc[3]; Sky_Loc = end_point; Sky_Loc[2]+=1000.0; end_point[2]-=100.0;

	int laser;
	laser = ConnectWithBeam(-1, -1, i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 7.0, 7.0, 1.0, BEAM_COMBINE_BLACK, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	laser = ConnectWithBeam(-1, -1, i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 5.0, 5.0, 0.1, LASERBEAM, end_point, Sky_Loc);
	CreateTimer(1.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

	int particle = ParticleEffectAt(Sky_Loc, "kartimpacttrail", 1.0);
	SetEdictFlags(particle, (GetEdictFlags(particle) | FL_EDICT_ALWAYS));	
	CreateTimer(0.25, Nearl_Falling_Shot, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}

void Weapon_Sigil_Blade_Hit_Target_Effect(int target,float clientEyePos[3], float clientRight[3], float vecHitPos[3])
{
	float f_slope = 0.2;
	float hitDistance;
	float vecTargetPos[3], vecRight[3], vecEyeToHit[3], vecEffectCenter[3], vecPointLeft[3], vecPointRight[3];
	WorldSpaceCenter(target, vecTargetPos);
	NormalizeVector(clientRight, vecRight);
	MakeVectorFromPoints(clientEyePos, vecHitPos, vecEyeToHit);
	hitDistance = GetVectorLength(vecEyeToHit);
	
	vecEffectCenter[0] = vecTargetPos[0];
	vecEffectCenter[1] = vecTargetPos[1];
	vecEffectCenter[2] = vecHitPos[2];
	
	if(hitDistance > 80.0)
		hitDistance = 80.0;
	if(hitDistance < 40.0)
		hitDistance = 40.0;
	ScaleVector(vecRight, hitDistance * 0.5);
	vecRight[0] += GetRandomInt(-7, 7);
	vecRight[1] += GetRandomInt(-7, 7);
	AddVectors(vecEffectCenter, vecRight, vecPointRight);
	NegateVector(vecRight);
	AddVectors(vecEffectCenter, vecRight, vecPointLeft);
	vecPointRight[2] -= f_slope * hitDistance;
	vecPointLeft[2] += f_slope * hitDistance;
	
	int laser = ConnectWithBeam(-1, -1, i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, vecPointLeft, vecPointRight);
	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}

void Weapon_Sigil_Blade_Hit_World_Effect(int client, float clientEyePos[3], float clientEyeAng[3], float vecHitPos[3])
{
	float rotateAxis[3], vecEyeToHit[3], vecRay[3], vecPointStart[3], vecPointEnd[3], clientEyeDir[3], clientRight[3];
	vecPointStart[0] = 0.0;vecPointStart[1] = 0.0;vecPointStart[2] = 0.0;
	
	GetAngleVectors(clientEyeAng, clientEyeDir, clientRight, NULL_VECTOR);
	MakeVectorFromPoints(clientEyePos, vecHitPos, vecEyeToHit);
	int lines = 0;
	//float r = GetVectorIncludedAngle(clientEyeDir, vecEyeToHit);
	//if(r > 0.017453)
	//{
		float signX, signY, signZ;
		
		if(clientEyeDir[0] == 0)
			signX = 1.0;
		else
			signX = FloatAbs(clientEyeDir[0]) / clientEyeDir[0];
		if(clientEyeDir[1] == 0)
			signY = 1.0;
		else
			signY = FloatAbs(clientEyeDir[1]) / clientEyeDir[1];
		if(clientEyeDir[2] == 0)
			signZ = 1.0;
		else
			signZ = FloatAbs(clientEyeDir[2]) / clientEyeDir[2];
		float sqrtXY = SquareRoot(clientEyeDir[0] * clientEyeDir[0] + clientEyeDir[1] * clientEyeDir[1]);
		//PrintToConsoleAll("sqrtXY : %.1f", sqrtXY);
		rotateAxis[0] = (-signX) * FloatAbs(clientEyeDir[0]) * FloatAbs(clientEyeDir[2]) / sqrtXY;
		rotateAxis[1] = (-signY) * FloatAbs(clientEyeDir[1]) * FloatAbs(clientEyeDir[2]) / sqrtXY;
		rotateAxis[2] = signZ * sqrtXY;
		NormalizeVector(rotateAxis, rotateAxis);
		//GetVectorCrossProduct(clientEyeDir, vecEyeToHit, rotateAxis);
		float 	rotateRad = 3.14159265 / 3,//60
				inirotateRad = rotateRad / 2;
		for(int i = 0; i < 8; i++)
		{
			float vicPos[3];
			float rot = inirotateRad - (rotateRad / 7) * i;
			GetRotatedVectorV(clientEyeDir, rotateAxis, rot, vecRay);
			GetRotatedVectorV(vecRay, clientEyeDir, -0.197395, vecRay);//arctan(1/5), 0.2 slope
			NormalizeVector(vecRay, vecRay);
			ScaleVector(vecRay, fl_Sigil_Melee_Range);
			AddVectors(clientEyePos, vecRay, vicPos);
			
			Handle trace = TR_TraceRayFilterEx(clientEyePos, vicPos, MASK_SHOT, RayType_EndPoint, Weapon_Sigil_Blade_Effect_TraceFilter, client);
			TR_GetEndPosition(vicPos, trace);
			float traceFraction = TR_GetFraction(trace);
			int target = TR_GetEntityIndex(trace);
			delete trace;
			
			if(traceFraction != 1.0 && !IsEntityAlive(target))
			{
				if(GetVectorLength(vecPointStart, true) == 0.0)
				{
					vecPointStart[0] = vicPos[0];vecPointStart[1] = vicPos[1];vecPointStart[2] = vicPos[2];
				}
				else
				{
					vecPointEnd[0] = vicPos[0];vecPointEnd[1] = vicPos[1];vecPointEnd[2] = vicPos[2];
					int laser = ConnectWithBeam(-1, -1, i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, vecPointStart, vecPointEnd);
					CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
					vecPointStart[0] = vecPointEnd[0];vecPointStart[1] = vecPointEnd[1];vecPointStart[2] = vecPointEnd[2];
					lines++;
				}
			}
		}
	//}
	
	if(lines == 0 /*|| r < 0.017453*/)
	{
		float f_slope = 0.2, hitDistance = 40.0;

		ScaleVector(clientRight, hitDistance * 0.5);
		AddVectors(vecHitPos, clientRight, vecPointStart);
		NegateVector(clientRight);
		AddVectors(vecHitPos, clientRight, vecPointEnd);
		vecPointStart[2] -= f_slope * hitDistance;
		vecPointEnd[2] += f_slope * hitDistance;
		
		int laser = ConnectWithBeam(-1, -1, i_sigil_color[0], i_sigil_color[1], i_sigil_color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK, vecPointEnd, vecPointStart);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public bool Weapon_Sigil_Blade_Effect_TraceFilter(int entity, int contentsMask, any iExclude)
{
	if (entity == iExclude)
		return false;
	else
		return true;
}

/**
 ****************************************************************************
 * --------------------	tool functions by e̶		----------------------------
 ****************************************************************************
**/
public void GetRotatedVectorV(float vec[3], float axis[3], float radian, float res[3])
{//Rodrigues' rotation formula
	float v0[3],v1[3],out[3];
	float f0;
	float sinr = Sine(radian);
	float cosr = Cosine(radian);
	f0 = (1 - cosr) * GetVectorDotProduct(vec, axis);
	v0[0] = vec[0];v0[1] = vec[1];v0[2] = vec[2];
	v1[0] = axis[0];v1[1] = axis[1];v1[2] = axis[2];
	ScaleVector(v1, f0);
	ScaleVector(v0, cosr);
	AddVectors(v0, v1, out);
	v0[0] = out[0];v0[1] = out[1];v0[2] = out[2];
	GetVectorCrossProduct(vec, axis, v1);
	ScaleVector(v1, sinr);
	AddVectors(v0, v1, out);
	
	res[0] = out[0];
	res[1] = out[1];
	res[2] = out[2];
}

public float GetVectorIncludedAngle(float vec1[3], float vec2[3])
{
//	get included angle between 2 vectors
//	returns radian
	float res[3];
	GetVectorCrossProduct(vec1, vec2, res);
	float radian = ArcTangent2( GetVectorLength(res, false), GetVectorDotProduct(vec1, vec2) );
	return radian;

}
/**
 ****************************************************************************
 * -------------------		end of tool functions ̶		---------------------
 ****************************************************************************
**/


bool Sigil_LastMann(int client)
{
	bool SigilTHEME=false;
	if(h_Sigil_hud[client] != null)
	{
		if(i_Current_Pap[client] >= 2)
			SigilTHEME=true;
	}
	return SigilTHEME;
}
