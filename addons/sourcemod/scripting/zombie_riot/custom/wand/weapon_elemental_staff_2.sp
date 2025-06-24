#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

static int client_slammed_how_many_times[MAXPLAYERS];
static int client_slammed_how_many_times_limit[MAXPLAYERS];
static float client_slammed_pos[MAXPLAYERS][3];
static float client_slammed_forward[MAXPLAYERS][3];
static float client_slammed_right[MAXPLAYERS][3];
static float f_OriginalDamage[MAXPLAYERS];
static bool HitAlreadyWithSame[MAXPLAYERS][MAXENTITIES];

public void Wand_Elemental_2_ClearAll()
{
	Zero(ability_cooldown);
}
#define spirite "spirites/zerogxplode.spr"

#define EarthStyleShockwaveRange 250.0
void Wand_Elemental_2_Map_Precache()
{
	PrecacheSound("ambient/explosions/explode_3.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_flyby2.wav", true);
	PrecacheSound("ambient/atmosphere/terrain_rumble1.wav", true);
	PrecacheSound("ambient/explosions/explode_9.wav", true);
}

public void Weapon_Elemental_Wand_2(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 350;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(client, weapon);
				Ability_Apply_Cooldown(client, slot, 15.0);
				SDKhooks_SetManaRegenDelayTime(client, 1.0);
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
				
				delay_hud[client] = 0.0;
				float damage = 500.0;
				damage *= Attributes_Get(weapon, 410, 1.0);
					
				f_OriginalDamage[client] = damage;
				client_slammed_how_many_times_limit[client] = 5;
				client_slammed_how_many_times[client] = 0;
				float vecUp[3];
				
				GetVectors(client, client_slammed_forward[client], client_slammed_right[client], vecUp); //Sorry i dont know any other way with this :(
				GetAbsOrigin(client, client_slammed_pos[client]);
				client_slammed_pos[client][2] += 5.0;
				
				float vecSwingEnd[3];
				vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (1 * client_slammed_how_many_times[client]);
				vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (1 * client_slammed_how_many_times[client]);
				vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
				
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecUp);
				
				
				DataPack pack = new DataPack();
				pack.WriteFloat(vecUp[0]);
				pack.WriteFloat(vecUp[1]);
				pack.WriteFloat(vecUp[2]);
				pack.WriteCell(1);
				RequestFrame(MakeExplosionFrameLater, pack);
				
				for(int i; i<MAXENTITIES; i++)
				{
					HitAlreadyWithSame[client][i] = false;
				}
				Explode_Logic_Custom(damage, client, client, weapon,vecUp,_,_,_,false, .FunctionToCallBeforeHit = Elemental_BeforeExplodeHit);
			
				CreateTimer(0.1, shockwave_explosions, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

static float Elemental_BeforeExplodeHit(int attacker, int victim, float &damage, int weapon)
{
	if(HitAlreadyWithSame[attacker][victim])
	{
		//Each next hit deals much less damage.
		damage *= 0.1;
	}
	HitAlreadyWithSame[attacker][victim] = true;
	if(NpcStats_ElementalAmp(victim))
	{
		//double!
		bool PlaySound = false;
		if(f_MinicritSoundDelay[attacker] < GetGameTime())
		{
			PlaySound = true;
			f_MinicritSoundDelay[attacker] = GetGameTime() + 0.01;
		}
		DisplayCritAboveNpc(victim, attacker, PlaySound); //Display crit above head
		return damage;
	}
	return 0.0;
}

public Action shockwave_explosions(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		client_slammed_how_many_times[client] += 1;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
		
		int ent = CreateEntityByName("env_explosion");
		if(ent != -1)
		{
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
									
			EmitAmbientSound("ambient/explosions/explode_9.wav", vecSwingEnd);
							
			DispatchKeyValueVector(ent, "origin", vecSwingEnd);
			DispatchKeyValue(ent, "spawnflags", "64");
			
			DispatchKeyValue(ent, "rendermode", "5");
			DispatchKeyValue(ent, "fireballsprite", spirite);
							
			SetEntProp(ent, Prop_Data, "m_iMagnitude", 0); 
			SetEntProp(ent, Prop_Data, "m_iRadiusOverride", 200); 
						
			DispatchSpawn(ent);
			ActivateEntity(ent);
						
			AcceptEntityInput(ent, "explode");
			AcceptEntityInput(ent, "kill");
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, -1, vecSwingEnd,_,_,_,false, .FunctionToCallBeforeHit = Elemental_BeforeExplodeHit);
		}
		if(client_slammed_how_many_times[client] > client_slammed_how_many_times_limit[client])
		{
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


//Passanger Ability stuff.

Handle h_TimerPassangerManagement[MAXPLAYERS+1] = {null, ...};
static float f_PassangerHudDelay[MAXPLAYERS];
static int i_PassangerAbilityCount[MAXPLAYERS+1]={0, ...};
static float f_PassangerAbilityCooldownRegen[MAXPLAYERS+1]={0.0, ...};

static int BeamWand_Laser;
static int BeamWand_Glow;


#define CUSTOM_MELEE_RANGE_DETECTION 1000.0
#define PASSANGER_RANGE 200.0
#define PASSANGER_ABILITY_RANGE 350.0
#define PASSANGER_DURATION 8
#define PASSANGER_DELAY_ABILITY 0.2
#define PASSANGER_MAX_ABILITIES 2
#define PASSANGER_ABILITY_REGARGE_TIME 38.0
#define SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO "misc/halloween/spell_lightning_ball_cast.wav"
#define SOUND_WAND_LIGHTNING_ABILITY_PAP_HIT "misc/halloween/spell_lightning_ball_impact.wav"
#define SOUND_WAND_PASSANGER "npc/scanner/scanner_electric2.wav"

void Passanger_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO);
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_HIT);
	PrecacheSound(SOUND_WAND_PASSANGER);
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
//	PrecacheSound(PHLOG_ABILITY);
}

void Reset_stats_Passanger_Global()
{
	Zero(f_PassangerAbilityCooldownRegen);
	Zero(i_PassangerAbilityCount);
	Zero(f_PassangerHudDelay);
}

void Reset_stats_Passanger_Singular(int client) //This is on disconnect/connect
{
	f_PassangerAbilityCooldownRegen[client] = 0.0;
	i_PassangerAbilityCount[client] = 0;
	if (h_TimerPassangerManagement[client] != null)
	{
		delete h_TimerPassangerManagement[client];
	}	
	h_TimerPassangerManagement[client] = null;
}
static bool b_EntityHitByLightning[MAXENTITIES];

public void Weapon_Passanger_Attack(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 75;
		mana_cost = RoundToNearest(float(mana_cost) * LaserWeapons_ReturnManaCost(weapon));
		if(mana_cost <= Current_Mana[client])
		{
			SDKhooks_SetManaRegenDelayTime(client, 2.0);
			Mana_Hud_Delay[client] = 0.0;
			
			Current_Mana[client] -= mana_cost;
			
			delay_hud[client] = 0.0;
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			Handle swingTrace;
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, CUSTOM_MELEE_RANGE_DETECTION);
				
			int target = TR_GetEntityIndex(swingTrace);
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);	

			delete swingTrace;
			static float belowBossEyes[3];

			belowBossEyes[0] = 0.0;
			belowBossEyes[1] = 0.0;
			belowBossEyes[2] = 0.0;

			float damage = 65.0;
			damage *= Attributes_Get(weapon, 410, 1.0);

			EmitSoundToAll(SOUND_WAND_PASSANGER, client, SNDCHAN_AUTO, 80, _, 0.9, GetRandomInt(95, 110));

			if(IsValidEnemy(client, target, true, true)) //Must detect camo.
			{
				//We have found a victim.
				GetBeamDrawStartPoint_Stock(client, belowBossEyes);
				Passanger_Lightning_Strike(client, target, weapon, damage, belowBossEyes);
			}
			else
			{
				//We will just fire a trace on whatever we hit.
				//Doesnt do anything.
				GetBeamDrawStartPoint_Stock(client, belowBossEyes);
				Passanger_Lightning_Effect(belowBossEyes, vecHit, 1);
			}
			FinishLagCompensation_Base_boss();
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

stock int GetClosestTargetNotAffectedByLightning(float EntityLocation[3])
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 

	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && !b_EntityHitByLightning[baseboss_index] && GetTeam(baseboss_index) != TFTeam_Red)
		{
			float TargetLocation[3]; 
			GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
			float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
				
			if(distance <= (PASSANGER_RANGE * PASSANGER_RANGE))
			{
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						ClosestTarget = baseboss_index; 
						TargetDistance = distance;          
					}
				} 
				else 
				{
					ClosestTarget = baseboss_index; 
					TargetDistance = distance;
				}
			}
		}
	}
	if(IsValidEntity(ClosestTarget))
	{
		b_EntityHitByLightning[ClosestTarget] = true;
	}
	return ClosestTarget; 
}


void Passanger_Lightning_Effect(float belowBossEyes[3], float vecHit[3], int Power, float diameter_override = 0.0, int color[3] = {0,0,0})
{	
	
	int r = 255; //Yellow.
	int g = 255;
	int b = 65;
	float diameter = 10.0;
	if(Power == 2)
	{
		diameter = 50.0;
	}
	if(Power == 3)
	{
		diameter = 25.0;
	}
	if(diameter_override != 0.0)
	{
		diameter = diameter_override;
	}
	if(color[0] != 0)
	{
		r = color[0]; //Yellow.
		g = color[1];
		b = color[2];
	}
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, r, g, b, 125);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
	if(Power == 2)
	{
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);

		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
		TE_SendToAll(0.0);
	}
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	int glowColor[4];
	SetColorRGBA(glowColor, r, g, b, 125);
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
	TE_SendToAll(0.0);
}

public void Enable_Passanger(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerPassangerManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == 9) //9 Is for Passanger
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerPassangerManagement[client];
			h_TimerPassangerManagement[client] = null;
			DataPack pack;
			h_TimerPassangerManagement[client] = CreateDataTimer(0.1, Timer_Management_Passanger, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == 9) //9 Is for Passanger
	{
		DataPack pack;
		h_TimerPassangerManagement[client] = CreateDataTimer(0.1, Timer_Management_Passanger, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_Passanger(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerPassangerManagement[client] = null;
		return Plugin_Stop;
	}	

	Passanger_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}

bool Passanger_HasCharge(int client)
{
	return h_TimerPassangerManagement[client] != null;
}

void Passanger_ChargeReduced(int client, float time)
{
	if(h_TimerPassangerManagement[client] != null)
		f_PassangerAbilityCooldownRegen[client] -= time;
}
bool b_PassangerExtraCharge[MAXPLAYERS];
public void Passanger_Cooldown_Logic(int client, int weapon)
{
	if(f_PassangerHudDelay[client] < GetGameTime())
	{
		if(f_PassangerAbilityCooldownRegen[client] < GetGameTime())
		{
			f_PassangerAbilityCooldownRegen[client] = GetGameTime() +(PASSANGER_ABILITY_REGARGE_TIME * CooldownReductionAmount(client));
			i_PassangerAbilityCount[client]++;
			if(i_PassangerAbilityCount[client] >= 2)
			{
				f_PassangerAbilityCooldownRegen[client] = FAR_FUTURE;
				i_PassangerAbilityCount[client] = 2;
			}
		}
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			b_PassangerExtraCharge[client] = true;
			float ClientPos[3];
			WorldSpaceCenter(client, ClientPos);
			TR_EnumerateEntitiesSphere(ClientPos, 100.0, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_Passanger, client);

			if(b_PassangerExtraCharge[client])
			{
				f_PassangerAbilityCooldownRegen[client] -= 0.2;
			}
			if(b_PassangerExtraCharge[client])
			{
				if(i_PassangerAbilityCount[client] != 2)
				{
					PrintHintText(client,"Glorious Shards!! [%i/%i] (Recharge in: %.1f)",i_PassangerAbilityCount[client], PASSANGER_MAX_ABILITIES,f_PassangerAbilityCooldownRegen[client]-GetGameTime());
				}
				else
				{
					PrintHintText(client,"Glorious Shards!! [%i/%i]",PASSANGER_MAX_ABILITIES,PASSANGER_MAX_ABILITIES);
				}
			}
			else
			{
				if(i_PassangerAbilityCount[client] != 2)
				{
					PrintHintText(client,"Glorious Shards [%i/%i] (Recharge in: %.1f)",i_PassangerAbilityCount[client], PASSANGER_MAX_ABILITIES,f_PassangerAbilityCooldownRegen[client]-GetGameTime());
				}
				else
				{
					PrintHintText(client,"Glorious Shards [%i/%i]",PASSANGER_MAX_ABILITIES,PASSANGER_MAX_ABILITIES);
				}				
			}

			
			f_PassangerHudDelay[client] = GetGameTime() + 0.5;
		}
	}
}

public bool TraceEntityEnumerator_Passanger(int entity, int filterentity)
{
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		b_PassangerExtraCharge[filterentity] = false;
		return false; //stop.
	}
	//always keep going!
	return true;
}
public void Weapon_Passanger_LightningArea(int client, int weapon, bool crit, int slot)
{
	if(i_PassangerAbilityCount[client] > 0 || CvarInfiniteCash.BoolValue)
	{	
		int mana_cost = 350;
		if(mana_cost <= Current_Mana[client])
		{		
			Rogue_OnAbilityUse(client, weapon);
			SDKhooks_SetManaRegenDelayTime(client, 1.0);
			Mana_Hud_Delay[client] = 0.0;
			
			Current_Mana[client] -= mana_cost;
			
			delay_hud[client] = 0.0;
			if(i_PassangerAbilityCount[client] == 2)
			{
				f_PassangerAbilityCooldownRegen[client] = GetGameTime() + (PASSANGER_ABILITY_REGARGE_TIME * CooldownReductionAmount(client));
			}
			i_PassangerAbilityCount[client] -= 1;

			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			Handle swingTrace;
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9); //Infinite range., enough to be infinite.
				
			int target = TR_GetEntityIndex(swingTrace);
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);	

			delete swingTrace;
			
			if(IsValidEnemy(client, target, true, true)) //Must detect camo.
			{
				//We have found a victim.
				static float belowBossEyes[3];
				belowBossEyes[0] = 0.0;
				belowBossEyes[1] = 0.0;
				belowBossEyes[2] = 0.0;

				GetBeamDrawStartPoint_Stock(client, belowBossEyes);
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vecHit);
				Passanger_Activate_Storm(client, weapon, vecHit);
				spawnRing_Vectors(vecHit, PASSANGER_ABILITY_RANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, (float(PASSANGER_DURATION + 2) * PASSANGER_DELAY_ABILITY), 12.0, 6.1, 1);
				EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecHit);
				EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecHit);
			
			}
			else
			{
				
				float vAngles[3];
				float vOrigin[3];
			
				GetClientEyePosition(client, vOrigin);
				GetClientEyeAngles(client, vAngles);

				Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, HitOnlyWorld, client);
							
				if(TR_DidHit(trace)) //We have hit not target, we will now just go whereever the client looked, ignoring any range.
				{   
					TR_GetEndPosition(vecHit, trace);
					Passanger_Activate_Storm(client, weapon, vecHit);
					spawnRing_Vectors(vecHit, PASSANGER_ABILITY_RANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, (float(PASSANGER_DURATION + 2) * PASSANGER_DELAY_ABILITY), 12.0, 6.1, 1);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecHit);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecHit);
				}
				//We hit nothing somehow, we will entirely disregard this and do nothing.
				delete trace;
				

			}
			FinishLagCompensation_Base_boss();
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");		
	}
	f_PassangerHudDelay[client] = 0.0;
	Passanger_Cooldown_Logic(client, weapon);
}


void Passanger_Lightning_Strike(int client, int target, int weapon, float damage, float StartLightningPos[3], bool Firstlightning = true)
{
	static float vecHit[3];
	if(weapon != -2)
		GetBeamDrawStartPoint_Stock(client, StartLightningPos);
		
	GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vecHit);
	vecHit[2] += 40.0;

	//weapon = -1 means its a building that caused it, i guess.

	//deal more damage during raids, otherwise its really weak in most cases.
	if(client <= MaxClients && b_PassangerExtraCharge[client])
	{
		damage *= 1.1;
	}
	if(Firstlightning)
	{
		float EnemyVecPos[3]; WorldSpaceCenter(target, EnemyVecPos);
		Passanger_Lightning_Effect(StartLightningPos, EnemyVecPos, 1);
	}
	WorldSpaceCenter(target, StartLightningPos);
	ApplyStatusEffect(client, target, "Electric Impairability", 0.3);
	SDKHooks_TakeDamage(target, client, client, damage, DMG_PLASMA, weapon, {0.0, 0.0, -50000.0}, vecHit);	//BURNING TO THE GROUND!!!
	if(weapon == -2)
		ApplyStatusEffect(client, target, "Medusa's Teslar", 5.0);

	if(client <= MaxClients)
		f_CooldownForHurtHud[client] = 0.0;
	b_EntityHitByLightning[target] = true;
	float original_damage = damage;
	for (int loop = 6; loop > 2; loop--)
	{
		int enemy = GetClosestTargetNotAffectedByLightning(vecHit);
		if(IsValidEntity(enemy))
		{
			damage = (original_damage * (0.15 * loop));
			if(b_thisNpcIsARaid[enemy])
			{
				damage *= 1.5;
				//undo damage nerf that we did before for the ability
				if(Firstlightning == false)
					damage /= 0.5;
			}
			ApplyStatusEffect(client, enemy, "Electric Impairability", 0.3);
			SDKHooks_TakeDamage(enemy, client, client, damage, DMG_PLASMA, weapon, {0.0, 0.0, -50000.0}, vecHit);	
			if(weapon == -2)
				ApplyStatusEffect(client, target, "Medusa's Teslar", 5.0);

			if(client <= MaxClients)	
				f_CooldownForHurtHud[client] = 0.0;
			GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecHit);
			float EnemyVecPos[3]; WorldSpaceCenter(enemy, EnemyVecPos);
			Passanger_Lightning_Effect(StartLightningPos, EnemyVecPos, 3);
			WorldSpaceCenter(enemy, StartLightningPos);
		}
		else
		{
			break;
		}
	}
	Zero(b_EntityHitByLightning); //delete this logic.
}
void Passanger_CauseCoolSoundEffect(float StartLightningPos[3])
{
	int particle_extra;
	float Angles[3];

	particle_extra = ParticleEffectAt(StartLightningPos, "utaunt_lightning_bolt", 1.0);
	Angles [1] = GetRandomFloat(-180.0, 180.0);
	TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
	particle_extra = ParticleEffectAt(StartLightningPos, "utaunt_lightning_bolt", 1.0);
	Angles [1] = GetRandomFloat(-180.0, 180.0);
	TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
	particle_extra = ParticleEffectAt(StartLightningPos, "utaunt_lightning_bolt", 1.0);
	Angles [1] = GetRandomFloat(-180.0, 180.0);
	TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);				

	EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_HIT, 0, SNDCHAN_AUTO, 80, SND_NOFLAGS, 0.9, SNDPITCH_NORMAL, -1, StartLightningPos);
	EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_HIT, 0, SNDCHAN_AUTO, 80, SND_NOFLAGS, 0.9, SNDPITCH_NORMAL, -1, StartLightningPos);	
}

void Passanger_Activate_Storm(int client, int weapon, float lightningpos[3])
{
	float damage = 150.0;
	damage *= Attributes_Get(weapon, 410, 1.0); //massive damage!
	damage *= 0.5;


	FakeClientCommand(client, "voicemenu 0 2"); //Go go go! Cause them to point!
	PassangerHandLightningEffect(client, lightningpos);
	DataPack pack;
	CreateDataTimer(PASSANGER_DELAY_ABILITY, TimerPassangerAbility, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteFloat(damage);
	pack.WriteFloat(lightningpos[0]);
	pack.WriteFloat(lightningpos[1]);
	pack.WriteFloat(lightningpos[2]);
	pack.WriteCell(8); //Amount of hits to do


	DataPack pack_instant;
	CreateDataTimer(0.0, TimerPassangerAbility, pack_instant, TIMER_FLAG_NO_MAPCHANGE);
	pack_instant.WriteCell(client);
	pack_instant.WriteCell(EntIndexToEntRef(weapon));
	pack_instant.WriteFloat(damage);
	pack_instant.WriteFloat(lightningpos[0]);
	pack_instant.WriteFloat(lightningpos[1]);
	pack_instant.WriteFloat(lightningpos[2]);
	pack_instant.WriteCell(0); //Amount of hits to do
}


public Action TimerPassangerAbility(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadFloat();
	float lightningpos[3];
	lightningpos[0] = pack.ReadFloat();
	lightningpos[1] = pack.ReadFloat();
	lightningpos[2] = pack.ReadFloat();
	if(IsValidClient(client))
	{
		int count;
		static int targets[i_MaxcountNpc];
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && GetTeam(baseboss_index) != TFTeam_Red)
			{
				static float TargetLocation[3]; 
				GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float distance = GetVectorDistance( lightningpos, TargetLocation, true );  
					
				if(distance <= (PASSANGER_ABILITY_RANGE * PASSANGER_ABILITY_RANGE))
				{
					targets[count++] = baseboss_index;
				}
			}
		}
		if(count) //we got one!
		{
			static float RandomTargetLocation[3];
			int target = targets[GetRandomInt(0, count - 1)];
			GetEntPropVector( target, Prop_Data, "m_vecAbsOrigin", RandomTargetLocation ); 
			static float RandomTargetLocation_Elevated[3];

			RandomTargetLocation_Elevated = RandomTargetLocation;
			RandomTargetLocation_Elevated[2] += 1000.0;// We wantthe big laser to come from the holy skies.

		//	EmitSoundToAll(IRENE_KICKUP_1, target, _, 75, _, 0.60);
			
			DataPack pack_boom = new DataPack();
			pack_boom.WriteFloat(RandomTargetLocation[0]);
			pack_boom.WriteFloat(RandomTargetLocation[1]);
			pack_boom.WriteFloat(RandomTargetLocation[2]);
			pack_boom.WriteCell(0);
			RequestFrame(MakeExplosionFrameLater, pack_boom);

			Passanger_CauseCoolSoundEffect(RandomTargetLocation);

			Passanger_Lightning_Effect(RandomTargetLocation_Elevated, RandomTargetLocation, 2);
			Passanger_Lightning_Strike(client, target, weapon, damage, RandomTargetLocation, false);
			//We want 1 big lightning to happen.

		}

		//If no one is hit, then we just do not care.
	}
	else
	{
		return Plugin_Stop;
	}	
	
	int LightningStrikes = pack.ReadCell();
	if(LightningStrikes < 1)
	{
		return Plugin_Stop;
	}

	pack.Position--;
	pack.WriteCell(LightningStrikes-1, false);

	return Plugin_Continue;
}

static void PassangerHandLightningEffect(int entity = -1, float VecPos_target[3] = {0.0,0.0,0.0})
{	
	int r = 255; //Blue.
	int g = 255;
	int b = 65;
	int laser;

	laser = ConnectWithBeam(entity, -1, r, g, b, 3.0, 3.0, 2.35, LASERBEAM, _, VecPos_target,"effect_hand_l");

	CreateTimer(1.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}



float LaserWeapons_ReturnManaCost(int weapon)
{
	float ManaCost = 1.0;
	//This will take into account projectile stuff for lasers, so tinkers and other stuff dont give free damage.
	ManaCost *= (1.0 / Attributes_Get(weapon, 101, 1.0));
	ManaCost *= (1.0 / Attributes_Get(weapon, 102, 1.0));
	ManaCost *= (1.0 / Attributes_Get(weapon, 103, 1.0));
	ManaCost *= (1.0 / Attributes_Get(weapon, 104, 1.0));
	return ManaCost;
}