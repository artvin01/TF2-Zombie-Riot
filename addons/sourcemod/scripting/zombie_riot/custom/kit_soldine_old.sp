#pragma semicolon 1
#pragma newdecls required

static Handle MarketTimer[MAXPLAYERS] = {null, ...};
static float MarketHUDDelay[MAXPLAYERS];
static int Market_WeaponPap[MAXPLAYERS];
static int Market_Perk[MAXPLAYERS];
static int i_MarketParticleOne[MAXPLAYERS];
static int i_MarketParticleTwo[MAXPLAYERS];
static int i_RocketJump_AirboneTime[MAXPLAYERS];

static float i_SoldinAmmoSet[MAXPLAYERS];
static int i_SoldinCharging[MAXPLAYERS];
static int i_SoldinChargingMAX[MAXPLAYERS];
static bool b_SoldinPowerHit[MAXPLAYERS];
static bool b_SoldinLastMann_Buff;
static bool PrecachedMusic;



static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";

bool Wkit_Soldin_BvB(int client)
{
	return MarketTimer[client] != null;
}

bool Wkit_Soldin_LastMann(int client)
{
	bool SoldinTHEME=false;
	switch(Market_WeaponPap[client])
	{
		case 0, 1:
		{
		}
		case 2, 3, 4, 5, 6, 7, 8:
		{
			if(MarketTimer[client] != null)SoldinTHEME=true;
		}
	}
	return SoldinTHEME;
}

void Wkit_Soldin_LastMann_buff(int client, bool b_On)
{
	b_SoldinLastMann_Buff=b_On;
	if(b_On)
	{
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(MarketTimer[client] != null)
				{
					i_SoldinCharging[client]=i_SoldinChargingMAX[client];
				}
			}
		}
	}
}

public void Wkit_Soldin_OnMapStart()
{
	PrecachedMusic = false;
	Zero(Market_WeaponPap);
	Zero(Market_Perk);
	Zero(MarketHUDDelay);
}

public void Wkit_Soldin_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(MarketTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_PROTOTYPE)
		{
			if(!PrecachedMusic)
			{
				PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",_,1);
				PrecachedMusic = true;
			}
			Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			Market_Perk[client]=i_CurrentEquippedPerk[client];
			int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			if(IsValidEntity(getweapon))
			{
				i_SoldinAmmoSet[client] = Attributes_Get(getweapon, 4, 1.0);
				i_SoldinReloadRateSet[client] = Attributes_Get(getweapon, 97, 2.0);
			}
			int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
			delete MarketTimer[client];
			MarketTimer[client] = null;
			DataPack pack;
			MarketTimer[client] = CreateDataTimer(0.1, Timer_Wkit_Soldin, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteCell(EntIndexToEntRef(melee));
		}
		return;
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PROTOTYPE)
	{
		if(!PrecachedMusic)
		{
			PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",_,1);
			PrecachedMusic = true;
		}
		Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		Market_Perk[client]=i_CurrentEquippedPerk[client];
		int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		if(IsValidEntity(getweapon))
		{
			i_SoldinAmmoSet[client] = Attributes_Get(getweapon, 4, 1.0);
		}
		int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		DataPack pack;
		MarketTimer[client] = CreateDataTimer(0.1, Timer_Wkit_Soldin, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(EntIndexToEntRef(melee));
	}
}

static Action Timer_Wkit_Soldin(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int primary = EntRefToEntIndex(pack.ReadCell());
	int melee = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(primary) || !IsValidEntity(melee))
	{
		MarketTimer[client] = null;
		b_On_Self_Damage[client] = false;
		return Plugin_Stop;
	}	
	
	bool IsMelee=false;
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == primary)
	{
		
	}
	else if(weapon_holding == melee)
	{
		IsMelee=true;
	}
	else
	{
		//wtf???
	}
	Wkit_Soldin_HUD(client, IsMelee);
	Wkit_Soldin_Effect(client, IsMelee);

	return Plugin_Continue;
}

public void Wkit_Soldin_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	int melee = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee);
	float Attackerpos[3]; GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Attackerpos);
	if(weapon==melee && (damagetype & DMG_CLUB) && !(damagetype & DMG_BLAST))
	{
		switch(Market_WeaponPap[attacker])
		{
			case 0, 1:
			{
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(!b_SoldinPowerHit[attacker])
				{
					i_SoldinCharging[attacker]+=1+i_RocketJump_Count[attacker];
					if(i_SoldinCharging[attacker]>i_SoldinChargingMAX[attacker])
						i_SoldinCharging[attacker]=i_SoldinChargingMAX[attacker];
				}
				else
				{
					Rogue_OnAbilityUse(attacker, weapon);
					float position[3]; WorldSpaceCenter(victim, position);
					position[2]+=35.0;
					DataPack pack_boom = new DataPack();
					pack_boom.WriteFloat(position[0]);
					pack_boom.WriteFloat(position[1]);
					pack_boom.WriteFloat(position[2]);
					pack_boom.WriteCell(0);
					RequestFrame(MakeExplosionFrameLater, pack_boom);

					//For client only cus too much fancy shit
					EmitSoundToClient(attacker, g_BoomSounds, victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					TE_Particle("hightower_explosion", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);

					TE_Particle("mvm_soldier_shockwave", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
					if(RaidbossIgnoreBuildingsLogic(1))
						damage *= 2.0;

					Explode_Logic_Custom(damage*2.0, attacker, attacker, weapon, position, 250.0, 0.75, _, _, _, _, _, Ground_Slam);
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime(weapon)+1.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime(attacker)+1.0);
					damage *= 3.0;
					GiveArmorViaPercentage(attacker, 0.25, 1.0);
					b_SoldinPowerHit[attacker]=false;
				}
			}
		}
	}
	else
	{
		switch(Market_WeaponPap[attacker])
		{
			case 0, 1:
			{
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(RaidbossIgnoreBuildingsLogic(1))damage *= 2.0;
				if(i_SoldinCharging[attacker])
					damage *= 1.0+(float(i_SoldinCharging[attacker])*(b_SoldinLastMann_Buff ? 0.1 : 0.05));
				if(i_RocketJump_Count[attacker]>0 && i_RocketJump_AirboneTime[attacker]>5)
				{
					damage *= 1.15;
					DisplayCritAboveNpc(victim, attacker, true, _, _, true);
				}
			}
		}
	}
}

#define SOLDINE_JUMPDURATIONUFF 2.5
static void Wkit_Soldin_Effect(int client, bool weapons)
{
	if(GetEntityFlags(client)&FL_ONGROUND || !TF2_IsPlayerInCondition(client, TFCond_BlastJumping))
	{
		i_RocketJump_Count[client]=0;
		i_RocketJump_AirboneTime[client]=0;
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
				if(weapons)
				{
				}
				else
				{
				}
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(weapons)
				{
					if(b_SoldinPowerHit[client])
						TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
				}
				else
				{
					if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client] && !b_SoldinPowerHit[client])
						b_On_Self_Damage[client] = true;
				}
			}
		}
		if(b_SoldinPowerHit[client])
			i_SoldinCharging[client]=0;
		DestroyWkit_Soldin_Effect(client);
	}
	else if(i_RocketJump_Count[client])
	{
		i_RocketJump_AirboneTime[client]++;
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
				if(weapons)
				{
				}
				else
				{
				}
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(weapons)
				{
					if(b_SoldinPowerHit[client])TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
				}
				else
				{
					if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client])
					{
						TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
						TF2_AddCondition(client, TFCond_RunePrecision, 0.2);
						if(!b_SoldinPowerHit[client])
						{
							TF2_AddCondition(client, TFCond_Parachute, SOLDINE_JUMPDURATIONUFF);
							TF2_AddCondition(client, TFCond_ParachuteDeployed, SOLDINE_JUMPDURATIONUFF);
							float velocity[3];
							GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
							velocity[2] += 650.0;
							TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
							int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
							if(IsValidEntity(getweapon))
							{
								ApplyTempAttrib(getweapon, 6, 0.175, SOLDINE_JUMPDURATIONUFF);
								Rogue_OnAbilityUse(client, getweapon);
							}
							b_SoldinPowerHit[client]=true;
							b_On_Self_Damage[client] = false;
						}
						int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
						if(IsValidEntity(getweapon))
						{
							int RocketLoad = GetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
							int RockeyAmmo=GetAmmo(client, 8);
							int RocketAmmoMAX=RoundToCeil(4.0*i_SoldinAmmoSet[client]);
							if(RockeyAmmo>1 && RocketLoad<RocketAmmoMAX)
							{
								SetAmmo(client, 8, RockeyAmmo-1);
								SetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), RocketLoad+1);
							}
						}
					}
				}
			}
		}
		int entity = EntRefToEntIndex(i_MarketParticleOne[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				float flAng[3];
				GetAttachment(entity, "foot_L", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "rockettrail", 0.0);
				AddEntityToThirdPersonTransitMode(client, particle);
				SetParent(entity, particle, "foot_L");
				i_MarketParticleOne[client] = EntIndexToEntRef(particle);
			}
		}
		entity = EntRefToEntIndex(i_MarketParticleTwo[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				float flAng[3];
				GetAttachment(entity, "foot_R", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "rockettrail", 0.0);
				AddEntityToThirdPersonTransitMode(client, particle);
				SetParent(entity, particle, "foot_R");
				i_MarketParticleTwo[client] = EntIndexToEntRef(particle);
			}
		}
	}
}
static void DestroyWkit_Soldin_Effect(int client)
{
	int entity = EntRefToEntIndex(i_MarketParticleOne[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_MarketParticleOne[client] = INVALID_ENT_REFERENCE;
	entity = EntRefToEntIndex(i_MarketParticleTwo[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_MarketParticleTwo[client] = INVALID_ENT_REFERENCE;
}

static void Wkit_Soldin_HUD(int client, bool weapons)
{
	if(MarketHUDDelay[client] < GetGameTime())
	{
		char C_point_hints[512]="";
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
				b_IsCannibal[client]=false;
				if(weapons)
				{
				
				}
				else
				{
				
				}
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				b_IsCannibal[client]=true;
				i_SoldinChargingMAX[client]=(b_SoldinLastMann_Buff ? 13 : 15);
				if(i_RocketJump_Count[client] && b_SoldinPowerHit[client])
					Format(C_point_hints, sizeof(C_point_hints),
					"Rocket Barrage Online!");
				else if(i_SoldinCharging[client]<i_SoldinChargingMAX[client])
				{
					Format(C_point_hints, sizeof(C_point_hints),
					"Battery: %i％", RoundToCeil(float(i_SoldinCharging[client])/float(i_SoldinChargingMAX[client])*100.0));
				}
				else
					Format(C_point_hints, sizeof(C_point_hints),
					"Rocket Barrage Ready!");

				if(weapons)
				{
					if(!b_SoldinPowerHit[client])
					{
						if(i_SoldinCharging[client]<i_SoldinChargingMAX[client])
						{
							Format(C_point_hints, sizeof(C_point_hints),
							"%s\nMelee Hit To Battery Charge.", C_point_hints);
						}
					}
					else
						Format(C_point_hints, sizeof(C_point_hints),
						"%s\nMelee Power Hit Online!", C_point_hints);
				}
				else
				{
					Format(C_point_hints, sizeof(C_point_hints),
					"%s\nRocket DMG Bonus +%i％", C_point_hints, RoundToCeil(float(i_SoldinCharging[client])*2.5));
					if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client] && !b_SoldinPowerHit[client] && i_RocketJump_Count[client]<1)
						Format(C_point_hints, sizeof(C_point_hints),
						"%s\nNow Rocket Jump!", C_point_hints);
				}
			}
		}

		if(C_point_hints[0] != '\0')
		{
			PrintHintText(client,"%s", C_point_hints);
			
			MarketHUDDelay[client] = GetGameTime() + 0.5;
		}
	}
}

static void Ground_Slam(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim))
	{
		ApplyStatusEffect(entity, victim, "Silenced", (b_thisNpcIsARaid[victim] ? 1.0 : 1.5));
		if(b_thisNpcIsARaid[victim])
			FreezeNpcInTime(victim, 0.5);
		else
			FreezeNpcInTime(victim, 1.0);
		Custom_Knockback(entity, victim, 600.0, true, true, true);
	}
}