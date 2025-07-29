static Handle h_TimerSensalWeaponManagement[MAXPLAYERS+1] = {null, ...};

#define SENSAL_MELEE_CHARGE_ON_HIT 0.25
#define SENSAL_MELEE_CHARGE_ON_HIT_2 0.1

static float f_SensalAbilityCharge_1[MAXENTITIES];
static float f_SensalAbilityCharge_2[MAXENTITIES];
static float f_Sensalhuddelay[MAXPLAYERS+1]={0.0, ...};
static bool b_ClientPossesBattery[MAXPLAYERS+1]={false, ...};
static float f_Sensal_MaxCharge_1[MAXENTITIES];
static int i_CosmeticScytheThing[MAXPLAYERS+1]={false, ...};

static char g_SyctheHitSound[][] = {
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};

bool IsSensalWeapon(int Index)
{
	if(Index == WEAPON_SENSAL_SCYTHE || Index == WEAPON_SENSAL_SCYTHE_PAP_1 || Index == WEAPON_SENSAL_SCYTHE_PAP_2 || Index == WEAPON_SENSAL_SCYTHE_PAP_3)
		return true;

	return false;
}

#define SensalWeapon_SOUND "ambient_mp3/lair/cap_1_tone_metal_movement2.mp3"
#define SensalWeapon_SOUND_MELEE "ambient/water/water_splash1.wav"
//code that starts up a repeat timer upon weapon equip
public void Enable_SensalWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerSensalWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(IsSensalWeapon(i_CustomWeaponEquipLogic[weapon]))
		{
			b_ClientPossesBattery[client] = Items_HasNamedItem(client, "Expidonsan Battery Device");
			i_CosmeticScytheThing[client] = 0;
			if(b_ClientPossesBattery[client])
				i_WeaponVMTExtraSetting[weapon] = 1;
				
			bool DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Scythe Color Option 1"));
			if(DoCosmetic)
			{
				i_WeaponVMTExtraSetting[weapon] = 2;
				i_CosmeticScytheThing[client] = 1;
			}
			DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Scythe Color Option 2"));
			if(DoCosmetic)
			{
				i_WeaponVMTExtraSetting[weapon] = 3;
				i_CosmeticScytheThing[client] = 2;
			}
			DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Scythe Color Option 3"));
			if(DoCosmetic)
			{
				i_WeaponVMTExtraSetting[weapon] = 4;
				i_CosmeticScytheThing[client] = 4;
			}
			DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Expidonsan Battery Device"));
			if(DoCosmetic)
			{
				i_WeaponVMTExtraSetting[weapon] = 0;
				i_CosmeticScytheThing[client] = 3;
			}
			//Is the weapon it again?
			//Yes?
			delete h_TimerSensalWeaponManagement[client];
			h_TimerSensalWeaponManagement[client] = null;
			DataPack pack;
			h_TimerSensalWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_SensalWeapon, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(IsSensalWeapon(i_CustomWeaponEquipLogic[weapon]))
	{
		b_ClientPossesBattery[client] = Items_HasNamedItem(client, "Expidonsan Battery Device");
		i_CosmeticScytheThing[client] = 0;
		bool DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Scythe Color Option 1"));
		if(DoCosmetic)
		{
			i_CosmeticScytheThing[client] = 1;
		}
		DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Scythe Color Option 2"));
		if(DoCosmetic)
		{
			i_CosmeticScytheThing[client] = 2;
		}
		DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Scythe Color Option 3"));
		if(DoCosmetic)
		{
			i_CosmeticScytheThing[client] = 4;
		}
		DoCosmetic = view_as<bool>(Store_HasNamedItem(client, "Expidonsan Battery Device"));
		if(DoCosmetic)
		{
			i_CosmeticScytheThing[client] = 3;
		}
		DataPack pack;
		h_TimerSensalWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_SensalWeapon, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

void ResetMapStartSensalWeapon()
{
	for (int i = 0; i < (sizeof(g_SyctheHitSound));   i++) { PrecacheSound(g_SyctheHitSound[i]);   }
	Zero(f_Sensalhuddelay);
	PrecacheSound(SensalWeapon_SOUND);
	PrecacheSound(SensalWeapon_SOUND_MELEE);
}

float f_AttackDelaySensal[MAXPLAYERS];
public void Sensal_Ability_M2_Auto(int client, int weapon, bool crit, int slot)
{
	f_AttackDelaySensal[client] = 0.0;
	SDKUnhook(client, SDKHook_PreThink, Sensal_Ability_M2_Auto_Prethink);
	SDKHook(client, SDKHook_PreThink, Sensal_Ability_M2_Auto_Prethink);
}

public void Sensal_Ability_M2_Auto_Prethink(int client)
{
	if(GetClientButtons(client) & IN_RELOAD)
	{
		if(f_AttackDelaySensal[client] > GetGameTime())
		{
			return;
		}
		f_AttackDelaySensal[client] = GetGameTime() + 0.05;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_active < 0)
		{
			SDKUnhook(client, SDKHook_PreThink, Sensal_Ability_M2_Auto_Prethink);
			return;
		}
		if(!IsSensalWeapon(i_CustomWeaponEquipLogic[weapon_active]))
		{
			SDKUnhook(client, SDKHook_PreThink, Sensal_Ability_M2_Auto_Prethink);
			return;
		}
		Sensal_Ability_M2(client, weapon_active, false, 3);
	}
	else
	{
		SDKUnhook(client, SDKHook_PreThink, Sensal_Ability_M2_Auto_Prethink);
		return;
	}
}
public void Sensal_Ability_M2(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Ability_Apply_Cooldown(client, slot, 0.25);
		if(f_SensalAbilityCharge_1[client] >= 0.5 || CvarInfiniteCash.BoolValue)
		{
			Rogue_OnAbilityUse(client, weapon);
			SummonScytheSensalProjectile(client, weapon);
			f_SensalAbilityCharge_1[client] -= 0.5;
			if(f_SensalAbilityCharge_1[client] < 0.0)
			{
				f_SensalAbilityCharge_1[client] = 0.0;
			}
			f_Sensalhuddelay[client] = 0.0;
			SensalTimerHudShow(client, weapon);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Sensal Scythes Not Fully Charged");	
		}
	}
}

public void Sensal_Ability_R_Laser(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		if(f_SensalAbilityCharge_2[client] >= 1.0 || CvarInfiniteCash.BoolValue)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 1.0);
			f_SensalAbilityCharge_2[client] -= 1.0;
			if(f_SensalAbilityCharge_2[client] < 0.0)
			{
				f_SensalAbilityCharge_2[client] = 0.0;
			}
			float fAng[3];
			float flPos[3];
			GetClientEyeAngles(client, fAng);
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
			fAng[0] = 0.0;
			
			float damage = 500.0;

			damage *= Attributes_Get(weapon, 2, 1.0);
					
			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);

			Handle swingTrace;
			float vecSwingForward[3];
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
						
			int foundTarget = TR_GetEntityIndex(swingTrace);	
			delete swingTrace;
			if(foundTarget <= 0)
			{
				foundTarget = -1;
			}
			FinishLagCompensation_Base_boss();

			int spawn_index = NPC_CreateByName("npc_allied_sensal_afterimage", client, flPos, fAng, GetTeam(client));
			if(spawn_index > 0)
			{
				//this is the damage
				CClotBody npc = view_as<CClotBody>(spawn_index);
				npc.m_iTarget = foundTarget;
				fl_heal_cooldown[spawn_index] = damage;
				i_Changed_WalkCycle[spawn_index] = EntIndexToEntRef(weapon);
			}
			f_Sensalhuddelay[client] = 0.0;
			SensalTimerHudShow(client, weapon);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Sensal Scythes Not Fully Charged");	
		}
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

//main code responsible for checking if the player is alive etc. and actualy giving the buffs
public Action Timer_Management_SensalWeapon(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerSensalWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	f_Sensal_MaxCharge_1[client] = 1.0;
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_SENSAL_SCYTHE_PAP_2, WEAPON_SENSAL_SCYTHE_PAP_3:
		{
			f_Sensal_MaxCharge_1[client] *= 2.0;
		}
	}
	
	f_Sensal_MaxCharge_1[client] *= 2.0;
	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		SensalTimerHudShow(client, weapon);
	}
		
	return Plugin_Continue;
}

void SensalTimerHudShow(int client, int weapon)
{
	if(f_Sensalhuddelay[client] < GetGameTime())
	{
		f_Sensalhuddelay[client] = GetGameTime() + 0.5;
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_SENSAL_SCYTHE:
			{
				return;
			}
			case WEAPON_SENSAL_SCYTHE_PAP_1, WEAPON_SENSAL_SCYTHE_PAP_2:
			{
				char SensalHud[255];
				if(f_SensalAbilityCharge_1[client] >= f_Sensal_MaxCharge_1[client])
				{
					FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [READY]",SensalHud);		
				}
				else
				{
					FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [%.0f％ / %.0f％]",SensalHud, f_SensalAbilityCharge_1[client] * 100.0, f_Sensal_MaxCharge_1[client] * 100.0);		
				}
				PrintHintText(client, "%s", SensalHud);
				
			}
			case WEAPON_SENSAL_SCYTHE_PAP_3:
			{
				char SensalHud[255];
				if(f_SensalAbilityCharge_1[client] >= f_Sensal_MaxCharge_1[client])
				{
					FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [READY]",SensalHud);
				}
				else
				{
					FormatEx(SensalHud, sizeof(SensalHud), "%sScythe Summoning [%.0f％ / %.0f％]",SensalHud, f_SensalAbilityCharge_1[client] * 100.0, f_Sensal_MaxCharge_1[client] * 100.0);		
				}

				
				if(f_SensalAbilityCharge_2[client] >= 2.0)
				{
					FormatEx(SensalHud, sizeof(SensalHud), "%s\nLasering Afterimage [READY x2]",SensalHud);
				}
				else
				{
					FormatEx(SensalHud, sizeof(SensalHud), "%s\nLasering Afterimage [%.0f％ / 200％]",SensalHud, f_SensalAbilityCharge_2[client] * 100.0);		
				}
				PrintHintText(client, "%s", SensalHud);
				
			}
		}
	}
}

void WeaponSensal_Scythe_OnTakeDamage(int attacker, int victim,int weapon, int zr_damage_custom)
{
	if(zr_damage_custom & ZR_DAMAGE_REFLECT_LOGIC)
		return;

	f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT;
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE_PAP_2 || i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE_PAP_3)
		f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT * 0.5;

	if(b_thisNpcIsABoss[victim])
	{
		f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT * 0.25;
	}
	if(b_thisNpcIsARaid[victim])
	{
		f_SensalAbilityCharge_1[attacker] += SENSAL_MELEE_CHARGE_ON_HIT * 0.5;
	}

	if(f_SensalAbilityCharge_1[attacker] > f_Sensal_MaxCharge_1[attacker])
	{
		f_SensalAbilityCharge_1[attacker] = f_Sensal_MaxCharge_1[attacker];
	}

	f_SensalAbilityCharge_2[attacker] += SENSAL_MELEE_CHARGE_ON_HIT_2;
	if(b_thisNpcIsABoss[victim])
	{
		f_SensalAbilityCharge_2[attacker] += SENSAL_MELEE_CHARGE_ON_HIT_2 * 0.25;
	}
	if(b_thisNpcIsARaid[victim])
	{
		f_SensalAbilityCharge_2[attacker] += SENSAL_MELEE_CHARGE_ON_HIT_2 * 0.5;
	}

	if(f_SensalAbilityCharge_2[attacker] > 2.0)
	{
		f_SensalAbilityCharge_2[attacker] = 2.0;
	}

	f_Sensalhuddelay[attacker] = 0.0;
	SensalTimerHudShow(attacker, weapon);
}

void SummonScytheSensalProjectile(int client, int weapon)
{
	float damage = 40.0;

	damage *= Attributes_Get(weapon, 2, 1.0);
		
	float speed = 500.0;

	speed *= Attributes_Get(weapon, 103, 1.0);

	speed *= Attributes_Get(weapon, 104, 1.0);

	speed *= Attributes_Get(weapon, 475, 1.0);


	float time = 3000.0/speed;
	time *= Attributes_Get(weapon, 101, 1.0);

	time *= Attributes_Get(weapon, 102, 1.0);

	float Pos_player[3];
	WorldSpaceCenter(client, Pos_player);
	
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);

	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
				
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	if(target <= 0)
	{
		target = -1;
	}
	FinishLagCompensation_Base_boss();
	
	float fAng[3];
	GetClientEyeAngles(client, fAng);
	fAng[0] = 0.0;
	FakeClientCommand(client, "voicemenu 2 1"); //battle cry!
	float RingSpawnVec[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", RingSpawnVec);
	RingSpawnVec[2] += 5.0;
	int red = 125;
	int green = 125;
	int blue = 255;
	bool RecolourToRed = b_ClientPossesBattery[client];
	if(RecolourToRed)
	{
		red = 255;
		green = 125;
		blue = 125;
	}
	switch(i_CosmeticScytheThing[client])
	{
		case 1:
		{
			red = 255;
			green = 255;
			blue = 255;
		}
		case 2:
		{
			red = 215;
			green = 170;
			blue = 0;
		}
		case 4:
		{
			red = 125;
			green = 0;
			blue = 125;
		}
		case 3:
		{
			red = 125;
			green = 125;
			blue = 255;
		}
	}
	spawnRing_Vectors(RingSpawnVec, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, 200, 1, 0.25, 6.0, 2.1, 1, 65.0 * 2.0);	
	EmitSoundToAll("weapons/mortar/mortar_explode3.wav", client, SNDCHAN_AUTO, 80, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Pos_player);	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE_PAP_2 || i_CustomWeaponEquipLogic[weapon] == WEAPON_SENSAL_SCYTHE_PAP_3)
	{
		for(int Repeat; Repeat <= 2; Repeat++)
		{
			int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, WEAPON_SENSAL_SCYTHE, weapon, "", fAng, false , Pos_player);

			int ModelApply = ApplyCustomModelToWandProjectile(projectile, WEAPON_CUSTOM_WEAPONRY_1, 1.35, "scythe_spin");

			if(b_ClientPossesBattery[client] && i_CosmeticScytheThing[client] == 0)
			{
				SetEntityRenderColor(ModelApply, 255, 255, 255, 1);
			}
			else
			{
				if(i_CosmeticScytheThing[client] == 1)
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 2);
				}
				else if(i_CosmeticScytheThing[client] == 2)
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 3);
				}
				else if(i_CosmeticScytheThing[client] == 4)
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 4);
				}
				else
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 0);
				}
			}
			SetVariantInt(2);
			AcceptEntityInput(ModelApply, "SetBodyGroup");

			CreateTimer(time, Timer_RemoveEntityWeaponSensal, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			
			Initiate_HomingProjectile(projectile,
			client,
				90.0,			// float lockonAngleMax,
				45.0,				//float homingaSec,
				false,				// bool LockOnlyOnce,
				true,				// bool changeAngles,
				fAng,
				target);			// float AnglesInitiate[3]);
			
			if(Repeat == 0)
			{
				fAng[1] -= 50.0;
			}
			else if(Repeat == 1)
			{
				fAng[1] += (50.0 * 2.0);
			}
			else
			{
				fAng[1] += 50.0;
			}
		}		
	}
	else
	{
		fAng[1] += 45.0;
		for(int Repeat; Repeat <= 1; Repeat++)
		{
			int projectile = Wand_Projectile_Spawn(client, speed, 0.0, damage, WEAPON_SENSAL_SCYTHE, weapon, "", fAng, false , Pos_player);

			int ModelApply = ApplyCustomModelToWandProjectile(projectile, WEAPON_CUSTOM_WEAPONRY_1, 1.35, "scythe_spin");

			if(b_ClientPossesBattery[client] && i_CosmeticScytheThing[client] == 0)
			{
				SetEntityRenderColor(ModelApply, 255, 255, 255, 1);
			}
			else
			{
				if(i_CosmeticScytheThing[client] == 1)
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 2);
				}
				else if(i_CosmeticScytheThing[client] == 2)
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 3);
				}
				else if(i_CosmeticScytheThing[client] == 4)
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 4);
				}
				else
				{
					SetEntityRenderColor(ModelApply, 255, 255, 255, 0);
				}
			}
			SetVariantInt(2);
			AcceptEntityInput(ModelApply, "SetBodyGroup");

			CreateTimer(time, Timer_RemoveEntityWeaponSensal, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			
			Initiate_HomingProjectile(projectile,
			client,
				90.0,			// float lockonAngleMax,
				45.0,				//float homingaSec,
				false,				// bool LockOnlyOnce,
				true,				// bool changeAngles,
				fAng,
				target);			// float AnglesInitiate[3]);
			fAng[1] -= 90.0;
		}
	}
}


public Action Timer_RemoveEntityWeaponSensal(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		int Particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(Particle))
		{
			RemoveEntity(Particle);
		}
		RemoveEntity(entity);
		
	}
	return Plugin_Stop;
}

public void Weapon_Sensal_WandTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetRocketAngles(entity, angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		EmitSoundToAll(g_SyctheHitSound[GetRandomInt(0, sizeof(g_SyctheHitSound) - 1)], entity, SNDCHAN_AUTO, 80, _, 0.8);
		
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		if(owner < 0)
			owner = 0;
			
		TE_Particle(b_ClientPossesBattery[owner] ? "spell_batball_impact_red" : "spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_CLUB, weapon, Dmg_Force, Entity_Position,_,ZR_DAMAGE_REFLECT_LOGIC);	// 2048 is DMG_NOGIB?
		
		
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}


void SensalApplyRecolour(int client, int entity)
{
	if(b_ClientPossesBattery[client] && i_CosmeticScytheThing[client] == 0)
	{
		SetEntityRenderColor(entity, 255, 255, 255, 1);
	}
	else
	{
		if(i_CosmeticScytheThing[client] == 1)
		{
			SetEntityRenderColor(entity, 255, 255, 255, 2);
		}
		else if(i_CosmeticScytheThing[client] == 2)
		{
			SetEntityRenderColor(entity, 255, 255, 255, 3);
		}
		else if(i_CosmeticScytheThing[client] == 4)
		{
			SetEntityRenderColor(entity, 255, 255, 255, 4);
		}
		else
		{
			SetEntityRenderColor(entity, 255, 255, 255, 0);
		}
	}
}