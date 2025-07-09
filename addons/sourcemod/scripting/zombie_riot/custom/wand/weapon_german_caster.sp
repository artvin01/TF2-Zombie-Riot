#pragma semicolon 1
#pragma newdecls required

#define WAND_GERMAN_HIT_SOUND	"ui/killsound_space.wav"
#define WAND_GERMAN_M2_SOUND	"Taunt.MedicViolinUber"
#define WAND_GERMAN_M1_SOUND	"WeaponMedigun_Vaccinator.Charged_tier_0%d"

static Handle GermanTimer[MAXPLAYERS];
static Handle GermanSilence[MAXPLAYERS];
static int GermanCharges[MAXPLAYERS];
static int GermanWeapon[MAXPLAYERS];
static int GermanAltModule[MAXPLAYERS];
static float f3_GermanFiredFromHere[MAXENTITIES][3];

void Weapon_German_MapStart()
{
	Zero2(f3_GermanFiredFromHere);
	PrecacheSound(WAND_GERMAN_HIT_SOUND);
}

public void Weapon_German_M1_Normal(int client, int weapon, bool &result, int slot)
{
	GermanAltModule[client] = 0;
	Weapon_German_M1(client, weapon, GermanSilence[client] ? 4 : 3);
}

public void Weapon_German_M1_Module(int client, int weapon, bool &result, int slot)
{
	GermanAltModule[client] = 0;
	Weapon_German_M1(client, weapon, GermanSilence[client] ? 5 : 4);
}

public void Weapon_German_M1_AltModule(int client, int weapon, bool &result, int slot)
{
	GermanAltModule[client] = 1;
	Weapon_German_M1(client, weapon, GermanSilence[client] ? 4 : 3);
}

public void Weapon_German_M1_AltModule2(int client, int weapon, bool &result, int slot)
{
	GermanAltModule[client] = 2;
	Weapon_German_M1(client, weapon, GermanSilence[client] ? 4 : 3);
}

static void Weapon_German_M1(int client, int weapon, int maxcharge)
{
	int cost = GermanSilence[client] ? 75 : 100;
	cost = RoundToNearest(Attributes_Get(weapon, 733, 1.0) * float(cost));

	if(Current_Mana[client] < cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", cost);

		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.01);
	}
	else if(!GermanTimer[client])
	{
		GermanTimer[client] = CreateTimer(0.1, Weapon_German_Timer, client, TIMER_REPEAT);
		GermanWeapon[client] = EntIndexToEntRef(weapon);
		GermanCharges[client] = 1;
		
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), WAND_GERMAN_M1_SOUND, GermanCharges[client]);
		EmitGameSoundToClient(client, buffer);
		EmitGameSoundToClient(client, buffer);

		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		delay_hud[client] = 0.0;
		Current_Mana[client] -= cost;
	}
	else if(GermanWeapon[client] == EntIndexToEntRef(weapon))
	{
		if(GermanCharges[client] < maxcharge)
		{
			GermanCharges[client]++;

			PlayChargeSound(client, GermanCharges[client], maxcharge);
			
			Mana_Hud_Delay[client] = 0.0;
			delay_hud[client] = 0.0;
			Current_Mana[client] -= cost;
		}
		else
		{
			SetCoooldown(client, weapon, GetGameTime() + 0.1);
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
}

static void PlayChargeSound(int client, int charge, int max)
{
	int sound = 1;
	if(charge > 1)
	{
		sound = charge - (max - 4);
		if(sound < 1)
			sound = 1;
	}

	char buffer[64];
	FormatEx(buffer, sizeof(buffer), WAND_GERMAN_M1_SOUND, sound);
	EmitGameSoundToClient(client, buffer);
	EmitGameSoundToClient(client, buffer);
}

static void SetCoooldown(int client, int weapon, float duration)
{
	DataPack pack = new DataPack();
	pack.WriteFloat(duration);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	RequestFrame(Weapon_German_Frame, pack);
}

public void Weapon_German_Frame(DataPack pack)
{
	pack.Reset();

	float duration = pack.ReadFloat();

	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", duration);

		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", duration);
		}
	}
	delete pack;
}

public Action Weapon_German_Timer(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = EntRefToEntIndex(GermanWeapon[client]);
		if(weapon != -1)
		{
			if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") && !(GetClientButtons(client) & IN_ATTACK))
			{
				float cooldown = 0.8 * Attributes_Get(weapon, 6, 1.0);
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + cooldown);
				SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + cooldown);

				float damage = 65.0 * Attributes_Get(weapon, 410, 1.0);

				if(GermanSilence[client])
					damage *= 1.65;
				
				float speed = 1100.0;
				speed *= Attributes_Get(weapon, 103, 1.0);
				speed *= Attributes_Get(weapon, 104, 1.0);
				speed *= Attributes_Get(weapon, 475, 1.0);

				float time = 500.0 / speed;
				time *= Attributes_Get(weapon, 101, 1.0);
				time *= Attributes_Get(weapon, 102, 1.0);

				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client);
				Handle swingTrace;
				float vecSwingForward[3];
				DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 2000.0, false, 45.0, false);
				int target = TR_GetEntityIndex(swingTrace);	
				delete swingTrace;
				FinishLagCompensation_Base_boss();

				if(target == 0)
					target = -1;

				for(int i; i < GermanCharges[client]; i++)
				{
					if(i == 1)
					{
						if(GermanSilence[client])	// The damage boosting effect of this unit's first Talent increases to 140% of the original
						{
							damage *= 1.35 * 1.4;
						}
						else	// Stored attacks deal 135% damage
						{
							damage *= 1.35;
						}
					}
					
					EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
					int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_GERMAN, weapon, "unusual_tesla_flash");
					WorldSpaceCenter(client, f3_GermanFiredFromHere[projectile]);
					static float ang_Look[3];
					GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
					if(target > 0)
					{
						Initiate_HomingProjectile(projectile,
							client,
							80.0,		// float lockonAngleMax,
							20.0,		// float homingaSec,
							true,		// bool LockOnlyOnce,
							true,		// bool changeAngles,
							ang_Look,	// float AnglesInitiate[3]);
							target);
					}
				}

				PrintHintText(client, "Charges: %d", GermanCharges[client]);
				
			}
			else
			{
				PrintHintText(client, "Charges: %d", GermanCharges[client]);
				

				SDKhooks_SetManaRegenDelayTime(client, 1.0);
				return Plugin_Continue;
			}
		}
	}

	GermanTimer[client] = null;
	return Plugin_Stop;
}

static stock bool IsValidHomingTarget(int projectile, int target, int owner)
{
	if(!IsValidEnemy(projectile, target))
		return false;
	
	if(GermanSilence[owner])	// Ignores non-elite enemies while in ability
	{
		if(!b_thisNpcIsABoss[target] &&
		   !b_thisNpcIsARaid[target] &&
		   !b_StaticNPC[target] &&
		   !b_thisNpcHasAnOutline[target] &&
		   !b_ThisNpcIsImmuneToNuke[target] &&
		   !b_IsGiant[target])
			return false;
	}

	return true;
}

void Weapon_German_WandTouch(int entity, int target)
{
	if(target > 0)	
	{
		int owner = EntRefToEntIndex(i_WandOwner[entity]);

		if(GermanSilence[owner])	// Ignores non-elite enemies while in ability
		{
			if(!b_thisNpcIsABoss[target] &&
			   !b_thisNpcIsARaid[target] &&
			   !b_StaticNPC[target] &&
			   !b_thisNpcHasAnOutline[target] &&
			   !b_ThisNpcIsImmuneToNuke[target] &&
			   !b_IsGiant[target])
				return;
		}

		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		
		float DamageWand = f_WandDamage[entity];

		float distance = GetVectorDistance(f3_GermanFiredFromHere[entity], Entity_Position, true);
		
		distance -= 1600.0;// Give 60 units of range cus its not going from their hurt pos

		if(distance < 0.1)
		{
			distance = 0.1;
		}
		float WeaponDamageFalloff = 0.85;

		DamageWand *= Pow(WeaponDamageFalloff, (distance/1000000.0)); //this is 1000, we use squared for optimisations sake

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, DamageWand, DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);
		
		if(GermanAltModule[owner] > 0)
			Elemental_AddNecrosisDamage(target, owner, RoundFloat(DamageWand), weapon);

		if(GermanAltModule[owner] > 1)
		{
			if(Nymph_AllowBonusDamage(target))
				StartBleedingTimer(target, owner, DamageWand * 0.075, 4, weapon, DMG_PLASMA, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
		}

		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		EmitSoundToAll(WAND_GERMAN_HIT_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(particle > MaxClients)
			RemoveEntity(particle);
		
		EmitSoundToAll(WAND_GERMAN_HIT_SOUND, entity, SNDCHAN_STATIC, 70, _, 0.9);
		RemoveEntity(entity);
	}
}

public void Weapon_German_M2(int client, int weapon, bool &result, int slot)
{
	if(GermanSilence[client])
	{
		TriggerTimer(GermanSilence[client]);
		Ability_Apply_Cooldown(client, slot, 20.0);
		TF2_RemoveCondition(client, TFCond_FocusBuff);
	}
	else
	{
		float cooldown = Ability_Check_Cooldown(client, slot);
		if(cooldown > 0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		}
		else
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 50.0);
			SDKhooks_SetManaRegenDelayTime(client, 1.0);

			TF2_AddCondition(client, TFCond_FocusBuff, 30.0);
			Attributes_SetMulti(weapon, 6, 0.6);

			DataPack pack;
			GermanSilence[client] = CreateDataTimer(30.0, Weapon_German_SilenceTimer, pack);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));

			EmitGameSoundToClient(client, WAND_GERMAN_M2_SOUND);
		}
	}
}

public Action Weapon_German_SilenceTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	GermanSilence[pack.ReadCell()] = null;

	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(weapon != -1)
	{
		Attributes_SetMulti(weapon, 6, 1.0 / 0.6);
	}
	return Plugin_Stop;	
}