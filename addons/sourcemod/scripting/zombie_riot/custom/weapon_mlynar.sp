#pragma semicolon 1
#pragma newdecls required

#define MYLNAR_RANGE_AGGRO_GAIN 100.0
#define MYLNAR_RANGE_ATTACK 300.0
#define MYLNAR_MAX_CHARGE_TIME 65.0
#define MLYNAR_MAX_ENEMIES_HIT 7

#define MYLNAR_MAXANGLEPITCH	90.0
#define MYLNAR_MAXANGLEYAW		90.0

Handle h_TimerMlynarManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_MlynarHudDelay[MAXTF2PLAYERS];
static float f_MlynarDmgMultiPassive[MAXTF2PLAYERS] = {1.0, ...};
static float f_MlynarDmgMultiAgressiveClose[MAXTF2PLAYERS] = {1.0, ...};
static float f_MlynarDmgMultiHurt[MAXTF2PLAYERS] = {1.0, ...};
static float f_MlynarAbilityActiveTime[MAXTF2PLAYERS];
static bool b_MlynarResetStats[MAXTF2PLAYERS];
int HitEntitiesSphereMlynar[MAXENTITIES];
int i_MlynarMaxDamageGetFromSameEnemy[MAXENTITIES];
static float f_MlynarHurtDuration[MAXTF2PLAYERS];
static float f_MlynarReflectCooldown[MAXTF2PLAYERS][MAXENTITIES];
static float f_AniSoundSpam[MAXPLAYERS+1]={0.0, ...};
static int i_RefWeaponDelete[MAXTF2PLAYERS];

//This will be used to tone down damage over time/on kill
static float f_MlynarDmgAfterAbility[MAXTF2PLAYERS];

void Mlynar_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	Zero(f_MlynarHudDelay);
	for(int i=1; i<=MaxClients; i++)
	{
		f_MlynarDmgMultiPassive[i] = 1.0;
		f_MlynarDmgMultiAgressiveClose[i] = 1.0;
		f_MlynarDmgMultiHurt[i] = 1.0;
		f_MlynarDmgAfterAbility[i] = 1.0;
	}
	Zero2(f_MlynarReflectCooldown);
	Zero(f_MlynarAbilityActiveTime);
	Zero(b_MlynarResetStats);
	Zero(f_AniSoundSpam);
	PrecacheSound("items/powerup_pickup_knockout.wav");
	PrecacheSound("misc/ks_tier_04.wav");
}

void Reset_stats_Mlynar_Global()
{
	Zero(f_MlynarHudDelay);
}
void Mlynar_EntityCreated(int entity) 
{
	i_MlynarMaxDamageGetFromSameEnemy[entity] = 0;
	for(int i=1; i<=MaxClients; i++)
	{
		f_MlynarReflectCooldown[i][entity] = 0.0;
	}
}
void Reset_stats_Mlynar_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerMlynarManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerMlynarManagement[client]);
	}	
	h_TimerMlynarManagement[client] = INVALID_HANDLE;
	f_MlynarDmgMultiPassive[client] = 1.0;
	f_MlynarDmgMultiAgressiveClose[client] = 1.0;
	f_MlynarDmgMultiHurt[client] = 1.0;
	f_MlynarDmgAfterAbility[client] = 1.0;
	f_MlynarAbilityActiveTime[client] = 0.0;
	b_MlynarResetStats[client] = false;
//	Store_RemoveSpecificItem(client, "Mlynar's Greatsword");
}
public void Weapon_MlynarAttack(int client, int weapon, bool &result, int slot)
{
	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	RequestFrames(Weapon_MlynarAttack_Internal, 12, pack);
}
public void Mylnar_DeleteLaserAndParticle(DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Laser = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile))
	{
		int particle = EntRefToEntIndex(i_WandParticle[Projectile]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		
		RemoveEntity(Projectile);
	}
	if(Projectile != Laser)
	{
		if(IsValidEntity(Laser))
			RemoveEntity(Laser);
	}
	delete pack;
}

public void CancelSoundEarlyMlynar(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidClient(client))
	{
		StopSound(client, SNDCHAN_AUTO, "misc/ks_tier_04.wav");
		StopSound(client, SNDCHAN_AUTO, "misc/ks_tier_04.wav");
		StopSound(client, SNDCHAN_AUTO, "misc/ks_tier_04.wav");
		StopSound(client, SNDCHAN_AUTO, "misc/ks_tier_04.wav");
	}
	delete pack;
}
public void Weapon_MlynarAttack_Internal(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client) && IsValidCurrentWeapon(client, weapon))
	{
		//This melee is too unique, we have to code it in a different way.
		static float pos2[3], ang2[3];
		GetClientEyePosition(client, pos2);
		GetClientEyeAngles(client, ang2);
		/*
			Extra effects on bare swing
		*/
		static float AngEffect[3];
		AngEffect = ang2;

		AngEffect[1] -= 90.0;
		int MaxRepeats = 4;
		float Speed = 1500.0;
		int PreviousProjectile;
		EmitSoundToAll("misc/ks_tier_04.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		DataPack pack3 = new DataPack();
		pack3.WriteCell(GetClientUserId(client));
		RequestFrames(CancelSoundEarlyMlynar, 40, pack3);

		for(int repeat; repeat <= MaxRepeats; repeat ++)
		{
			int projectile = Wand_Projectile_Spawn(client, Speed, 99999.9, 0.0, -1, weapon, "", AngEffect);
			DataPack pack2 = new DataPack();
			int laser = projectile;
			if(IsValidEntity(PreviousProjectile))
			{
				laser = ConnectWithBeam(projectile, PreviousProjectile, 255, 255, 0, 10.0, 10.0, 1.0);
			}
			SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
			PreviousProjectile = projectile;
			pack2.WriteCell(EntIndexToEntRef(projectile));
			pack2.WriteCell(EntIndexToEntRef(laser));
			RequestFrames(Mylnar_DeleteLaserAndParticle, 18, pack2);
			AngEffect[1] += (180.0 / float(MaxRepeats));
		}

		float vecSwingForward[3];
		GetAngleVectors(ang2, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
		ang2[0] = fixAngle(ang2[0]);
		ang2[1] = fixAngle(ang2[1]);
		
		float damage = 250.0;
		
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= Attributes_Get(weapon, 476, 1.0);


		damage *= f_MlynarDmgMultiPassive[client];
		damage *= f_MlynarDmgMultiAgressiveClose[client];
		damage *= f_MlynarDmgMultiHurt[client];

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
			
		for(int i=0; i < MAXENTITIES; i++)
		{
			HitEntitiesSphereMlynar[i] = false;
		}
		TR_EnumerateEntitiesSphere(pos2, MYLNAR_RANGE_ATTACK, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_Mlynar, client);

	//	bool Hit = false;
		for (int entity_traced = 0; entity_traced < MLYNAR_MAX_ENEMIES_HIT; entity_traced++)
		{
			if (HitEntitiesSphereMlynar[entity_traced] > 0)
			{
				static float ang3[3];

				float pos1[3];
				pos1 = WorldSpaceCenter(HitEntitiesSphereMlynar[entity_traced]);
				GetVectorAnglesTwoPoints(pos2, pos1, ang3);

				// fix all angles
				ang3[0] = fixAngle(ang3[0]);
				ang3[1] = fixAngle(ang3[1]);

				// verify angle validity
				if(!(fabs(ang2[0] - ang3[0]) <= MYLNAR_MAXANGLEPITCH ||
				(fabs(ang2[0] - ang3[0]) >= (360.0-MYLNAR_MAXANGLEPITCH))))
					continue;

				if(!(fabs(ang2[1] - ang3[1]) <= MYLNAR_MAXANGLEYAW ||
				(fabs(ang2[1] - ang3[1]) >= (360.0-MYLNAR_MAXANGLEYAW))))
					continue;

				// ensure no wall is obstructing
				if(Can_I_See_Enemy_Only(client, HitEntitiesSphereMlynar[entity_traced]))
				{
					// success
			//		Hit = true;
					SDKHooks_TakeDamage(HitEntitiesSphereMlynar[entity_traced], client, client, damage, DMG_CLUB, weapon, CalculateDamageForce(vecSwingForward, 100000.0), pos1);
					EmitSoundToAll("weapons/halloween_boss/knight_axe_hit.wav", HitEntitiesSphereMlynar[entity_traced],_ ,_ ,_ ,0.75);
				}
			}
			else
			{
				break;
			}
		}
	}
	FinishLagCompensation_Base_boss();
	delete pack;
}
public void Weapon_MlynarAttackM2(int client, int weapon, bool &result, int slot)
{
	//This melee is too unique, we have to code it in a different way.
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, MYLNAR_MAX_CHARGE_TIME);
		f_MlynarAbilityActiveTime[client] = GetGameTime() + 15.0;
		b_MlynarResetStats[client] = true;
		float flPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
		int particle_Sing = ParticleEffectAt(flPos, "utaunt_spirit_magical_base", 15.0);
		SetParent(client, particle_Sing);
		EmitSoundToAll("items/powerup_pickup_knockout.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		MakePlayerGiveResponseVoice(client, 1); //haha!
		int weapon_new = Store_GiveSpecificItem(client, "Mlynar's Greatsword");
		i_RefWeaponDelete[client] = EntIndexToEntRef(weapon_new);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon_new);
		ViewChange_Switch(client, weapon_new, "tf_weapon_sword");
		SDKUnhook(client, SDKHook_PreThink, Mlynar_Think);
		SDKHook(client, SDKHook_PreThink, Mlynar_Think);
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


public void Weapon_MlynarAttackM2_pap(int client, int weapon, bool &result, int slot)
{
	//This melee is too unique, we have to code it in a different way.
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, MYLNAR_MAX_CHARGE_TIME);
		f_MlynarAbilityActiveTime[client] = GetGameTime() + 15.0;
		b_MlynarResetStats[client] = true;
		float flPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);		
		int particle_Sing = ParticleEffectAt(flPos, "utaunt_spirit_magical_base", 15.0);
		SetParent(client, particle_Sing);
		EmitSoundToAll("items/powerup_pickup_knockout.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
		MakePlayerGiveResponseVoice(client, 1); //haha!
		int weapon_new = Store_GiveSpecificItem(client, "Mlynar's Greatsword Pap");
		i_RefWeaponDelete[client] = EntIndexToEntRef(weapon_new);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon_new);
		ViewChange_Switch(client, weapon_new, "tf_weapon_sword");
		SDKUnhook(client, SDKHook_PreThink, Mlynar_Think);
		SDKHook(client, SDKHook_PreThink, Mlynar_Think);
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

public void Enable_Mlynar(int client, int weapon) 
{
	if (h_TimerMlynarManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MLYNAR || i_CustomWeaponEquipLogic[weapon] == WEAPON_MLYNAR_PAP) 
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerMlynarManagement[client]);
			h_TimerMlynarManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerMlynarManagement[client] = CreateDataTimer(0.1, Timer_Management_Mlynar, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MLYNAR || i_CustomWeaponEquipLogic[weapon] == WEAPON_MLYNAR_PAP)  //9 Is for Passanger
	{
		DataPack pack;
		h_TimerMlynarManagement[client] = CreateDataTimer(0.1, Timer_Management_Mlynar, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_Mlynar(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Mlynar_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Mlynar(client);
		}
		else
			Kill_Timer_Mlynar(client);
	}
	else
		Kill_Timer_Mlynar(client);
		
	return Plugin_Continue;
}

public void Mlynar_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MLYNAR || i_CustomWeaponEquipLogic[weapon] == WEAPON_MLYNAR_PAP)
		{
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
			{
				//Give power overtime.
				if(f_MlynarAbilityActiveTime[client] < GetGameTime())
				{
					if(b_MlynarResetStats[client])
					{
						f_MlynarDmgMultiPassive[client] = 1.0;
						f_MlynarDmgMultiAgressiveClose[client] = 1.0;
						f_MlynarDmgMultiHurt[client] = 1.0;
						f_MlynarDmgAfterAbility[client] = 1.0;
					}
					b_MlynarResetStats[client] = false;
					f_MlynarDmgMultiPassive[client] += 0.0015;
					if(f_MlynarDmgMultiPassive[client] > 2.0)
					{
						f_MlynarDmgMultiPassive[client] = 2.0;
					}
					float ClientPos[3];
					ClientPos = WorldSpaceCenter(client);
					//we have atleast one enemy near us, more do not equal more strength
					//but the same enemy cannot give a huge amount of power over time.
					for(int i=0; i < MAXENTITIES; i++)
					{
						HitEntitiesSphereMlynar[i] = false;
					}
					TR_EnumerateEntitiesSphere(ClientPos, MYLNAR_RANGE_AGGRO_GAIN, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_Mlynar, client);

					int GatherPower = 0;
					for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
					{
						if (HitEntitiesSphereMlynar[entity_traced] > 0)
						{
							int entityindex = HitEntitiesSphereMlynar[entity_traced];
							//do not get power from the same enemy more then 5 times. unless its a boss or raid, then allow more.
							if(b_thisNpcIsARaid[entityindex])
							{
								//There is no limit to how often you can gather power from a raid.
								GatherPower += 10;
							}
							else if (b_thisNpcIsABoss[entityindex] && i_MlynarMaxDamageGetFromSameEnemy[entityindex] < 400)
							{
								i_MlynarMaxDamageGetFromSameEnemy[entityindex] += 1;
								GatherPower += 4;
							}
							else if(i_MlynarMaxDamageGetFromSameEnemy[entityindex] < 100)
							{
								i_MlynarMaxDamageGetFromSameEnemy[entityindex] += 1;
								GatherPower += 2;
							}
						}
						else
							break;
					}
					if(GatherPower > 0)
					{
						//we can gather power from upto 5 enemies at once, the more the faster.
						if(GatherPower > 10)
						{
							GatherPower = 10;
						}
						f_MlynarDmgMultiAgressiveClose[client] += (0.0015 * float(GatherPower));
						if(f_MlynarDmgMultiAgressiveClose[client] > 3.0)
						{
							f_MlynarDmgMultiAgressiveClose[client] = 3.0;
						}
					}
					//if the client was hurt by an enemy presumeably, then give extra power.
					if(f_MlynarHurtDuration[client] > GetGameTime())
					{
						f_MlynarDmgMultiHurt[client] += 0.01;
						if(IsValidEntity(EntRefToEntIndex(RaidBossActive))) //During raids, give power 2x as fast.
						{
							f_MlynarDmgMultiHurt[client] += 0.01;
						}
						if(f_MlynarDmgMultiHurt[client] > 3.0)
						{
							f_MlynarDmgMultiHurt[client] = 3.0;
						}
					}
				}

				if(f_MlynarHudDelay[client] < GetGameTime())
				{
					float cooldown = Ability_Check_Cooldown(client, 2);
					if(cooldown > 0.0)
					{
						PrintHintText(client,"Unbrilliant Glory [%.1f/%.1f]\nPower Gain: [%.1f％]\nAngered Precence: [%.1f％]\nProvoked Anger: [%.1f％]", cooldown, MYLNAR_MAX_CHARGE_TIME, (f_MlynarDmgMultiPassive[client] - 1.0) * 100.0, (f_MlynarDmgMultiAgressiveClose[client] - 1.0) * 100.0, (f_MlynarDmgMultiHurt[client] - 1.0) * 100.0);	
					}
					else
					{
						PrintHintText(client,"Unbrilliant Glory [READY]\nPower Gain: [%.1f％]\nAngered Precence: [%.1f％]\nProvoked Anger: [%.1f％]", (f_MlynarDmgMultiPassive[client] - 1.0) * 100.0, (f_MlynarDmgMultiAgressiveClose[client] - 1.0) * 100.0, (f_MlynarDmgMultiHurt[client] - 1.0) * 100.0);	
					}
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
					f_MlynarHudDelay[client] = GetGameTime() + 0.5;
				}
			}
		}
		else
		{
			Kill_Timer_Mlynar(client);
		}
	}
	else
	{
		Kill_Timer_Mlynar(client);
	}
}

public void Kill_Timer_Mlynar(int client)
{
	if (h_TimerMlynarManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerMlynarManagement[client]);
		h_TimerMlynarManagement[client] = INVALID_HANDLE;
	}
}

public bool TraceEntityEnumerator_Mlynar(int entity, int filterentity)
{
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		//This will automatically take care of all the checks, very handy. force it to also target invul enemies.
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!HitEntitiesSphereMlynar[i])
			{
				HitEntitiesSphereMlynar[i] = entity;
				break;
			}
		}
	}
	//always keep going!
	return true;
}


float Player_OnTakeDamage_Mlynar(int victim, float &damage, int attacker, int weapon, int pap = 0)
{
	f_MlynarHurtDuration[victim] = GetGameTime() + 1.0;
	//insert reflect code.
	if(f_MlynarReflectCooldown[victim][attacker] < GetGameTime())
	{
		f_MlynarReflectCooldown[victim][attacker] = GetGameTime() + 0.35;

		float damageModif = 15.0;
		if(pap == 1)
		{
			damageModif = 20.0;
		}
		damageModif *= Attributes_Get(weapon, 1, 1.0);
		damageModif *= Attributes_Get(weapon, 2, 1.0);
		damageModif *= Attributes_Get(weapon, 476, 1.0);

		damageModif *= f_MlynarDmgMultiPassive[victim];
		damageModif *= f_MlynarDmgMultiAgressiveClose[victim];
		damageModif *= f_MlynarDmgMultiHurt[victim];

		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			ClientCommand(victim, "playgamesound weapons/samurai/tf_katana_impact_object_02.wav");
		}
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenter(attacker);

		SDKHooks_TakeDamage(attacker, victim, victim, damageModif, DMG_CLUB, weapon, {0.0,0.0,1.0}, Entity_Position, _, ZR_DAMAGE_REFLECT_LOGIC);
	}
		
	return damage;
}

public void Mlynar_Think(int client)
{
	if(GetGameTime() > f_MlynarAbilityActiveTime[client])
	{
		Store_RemoveSpecificItem(client, "Mlynar's Greatsword");
		Store_RemoveSpecificItem(client, "Mlynar's Greatsword Pap");
		//We are Done, kill think.
		int TemomaryGun = EntRefToEntIndex(i_RefWeaponDelete[client]);
		if(IsValidEntity(TemomaryGun))
		{
			TF2_RemoveItem(client, TemomaryGun);
		}
		FakeClientCommand(client, "use tf_weapon_sword");
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
		FakeClientCommand(client, "use tf_weapon_sword");
		SDKUnhook(client, SDKHook_PreThink, Mlynar_Think);
		return;
	}	
}
void MlynarTakeDamagePostRaid(int client, int pap = 0)
{
	if(f_MlynarAbilityActiveTime[client] > GetGameTime())
	{
		if(pap == 0)
		{
			f_MlynarDmgMultiPassive[client] -= 0.025;
			f_MlynarDmgMultiAgressiveClose[client] -= 0.025;
			f_MlynarDmgMultiHurt[client] -= 0.025;
		}
		else if(pap == 1)
		{
			f_MlynarDmgMultiPassive[client] -= 0.015;
			f_MlynarDmgMultiAgressiveClose[client] -= 0.015;
			f_MlynarDmgMultiHurt[client] -= 0.015;
		}

		if(f_MlynarDmgMultiPassive[client] < 1.0)
		{
			f_MlynarDmgMultiPassive[client] = 1.0;
		}
		if(f_MlynarDmgMultiAgressiveClose[client] < 1.0)
		{
			f_MlynarDmgMultiAgressiveClose[client] = 1.0;
		}
		if(f_MlynarDmgMultiHurt[client] < 1.0)
		{
			f_MlynarDmgMultiHurt[client] = 1.0;
		}
	}
}

void MlynarReduceDamageOnKill(int client, int pap = 0)
{
	if(f_MlynarAbilityActiveTime[client] > GetGameTime())
	{
		if(pap == 0)
		{
			f_MlynarDmgMultiPassive[client] -= 0.05;
			f_MlynarDmgMultiAgressiveClose[client] -= 0.05;
			f_MlynarDmgMultiHurt[client] -= 0.05;
		}
		else if(pap == 1)
		{
			f_MlynarDmgMultiPassive[client] -= 0.03;
			f_MlynarDmgMultiAgressiveClose[client] -= 0.03;
			f_MlynarDmgMultiHurt[client] -= 0.03;
		}

		if(f_MlynarDmgMultiPassive[client] < 1.0)
		{
			f_MlynarDmgMultiPassive[client] = 1.0;
		}
		if(f_MlynarDmgMultiAgressiveClose[client] < 1.0)
		{
			f_MlynarDmgMultiAgressiveClose[client] = 1.0;
		}
		if(f_MlynarDmgMultiHurt[client] < 1.0)
		{
			f_MlynarDmgMultiHurt[client] = 1.0;
		}
	}
}