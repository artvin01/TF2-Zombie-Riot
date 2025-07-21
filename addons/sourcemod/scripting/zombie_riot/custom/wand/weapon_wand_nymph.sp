#pragma semicolon 1
#pragma newdecls required

// static Handle PerishTimer[MAXPLAYERS];
// static bool PerishReady[MAXPLAYERS];
static int		 IsAbilityActive[MAXPLAYERS];

/*
void Logos_MapStart()
{
	Zero(PerishReady);
}
*/
public void Weapon_Nymph_M1(int client, int weapon, bool &result, int slot)
{
	int cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if (Current_Mana[client] < cost)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", cost);
	}
	else
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);

		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;

		Current_Mana[client] -= cost;
		delay_hud[client] = 0.0;

		float speed		  = 600.0;
		if (IsAbilityActive[client] == 1)
		{
			speed = 900.0;
		}
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);

		float time = 750.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);

		EmitSoundToAll(SOUND_WAND_SHOT, client, _, 65, _, 0.45);
		Handle swingTrace;
		float  vecSwingForward[3];
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true);	// infinite range, and ignore walls!
		FinishLagCompensation_Base_boss();

		int target = TR_GetEntityIndex(swingTrace);
		delete swingTrace;

		float Angles[3];
		int	  projectile;
		if (IsAbilityActive[client] == 1)
		{
			damage *= 0.65;
			for (int HowOften = 0; HowOften <= 1; HowOften++)
			{
				GetClientEyeAngles(client, Angles);
				for (int spread = 0; spread < 3; spread++)
				{
					Angles[spread] += GetRandomFloat(-15.0, 15.0);
				}
				projectile		= Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_NYMPH, weapon, "unusual_breaker_green_spark", Angles);
				bool LockOnOnce = true;
				if (IsValidEntity(target))
					LockOnOnce = false;
				Initiate_HomingProjectile(projectile,
										  client,
										  90.0,			 // float lockonAngleMax,
										  12.0,			 // float homingaSec,
										  LockOnOnce,	 // bool LockOnlyOnce,
										  true,			 // bool changeAngles,
										  Angles,
										  target);	  // float AnglesInitiate[3]);
			}
		}
		else
		{
			GetClientEyeAngles(client, Angles);
			for (int spread = 0; spread < 3; spread++)
			{
				Angles[spread] += GetRandomFloat(-15.0, 15.0);
			}
			projectile		= Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_NYMPH, weapon, "unusual_magicsmoke_blue_parent", Angles);
			bool LockOnOnce = true;
			if (IsValidEntity(target))
				LockOnOnce = false;
			Initiate_HomingProjectile(projectile,
									  client,
									  90.0,			 // float lockonAngleMax,
									  12.0,			 // float homingaSec,
									  LockOnOnce,	 // bool LockOnlyOnce,
									  true,			 // bool changeAngles,
									  Angles,
									  target);	  // float AnglesInitiate[3]);
		}
	}
}

public void Weapon_Nymph_ActivateAbility(int client, int weapon, bool crit, int slot)
{
	if (weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			if (IsAbilityActive[client] == 0)
			{
				Rogue_OnAbilityUse(client, weapon);
				Ability_Apply_Cooldown(client, slot, 60.0);
				IsAbilityActive[client] = 1;
				ApplyTempAttrib(weapon, 6, 0.75, 15.0);
				ApplyTempAttrib(weapon, 410, 1.65, 15.0);
				CreateTimer(15.0, Disable_Nymph_Ability, client);
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability already Active");
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
}

public Action Disable_Nymph_Ability(Handle timer, int client)
{
	IsAbilityActive[client] = 0;	// 1 for enabled, 0 for disabled
	return Plugin_Handled;
}

void Weapon_Nymph_ProjectileTouch(int entity, int target)
{
	if (target > 0)
	{
		// Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int	  owner	 = EntRefToEntIndex(i_WandOwner[entity]);
		int	  weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3];
		CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

	 	Elemental_AddOsmosisDamage(target, owner, RoundToCeil(f_WandDamage[entity]* 0.75));

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _, ZR_DAMAGE_LASER_NO_BLAST);	 // base projectile damage
		if (Nymph_AllowBonusDamage(target))
		{
			if (IsAbilityActive[owner] == 1)
			{
				SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity] * 0.65, DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _, ZR_DAMAGE_LASER_NO_BLAST);	 // 100% bonus damage under necrosis burst
				ClientCommand(owner, "playgamesound weapons/phlog_end.wav");
				// PrintToChatAll("Buffed damage");
			}
			else
			{
				SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity] * 0.35, DMG_PLASMA, weapon, Dmg_Force, Entity_Position, _, ZR_DAMAGE_LASER_NO_BLAST);	   // 50% bonus damage under necrosis burst
				ClientCommand(owner, "playgamesound weapons/phlog_end.wav");
				// PrintToChatAll("Normal damage");
			}
		}


		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (particle > MaxClients)
			RemoveEntity(particle);

		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
	else if (target == 0)
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (particle > MaxClients)
			RemoveEntity(particle);

		EmitSoundToAll(SOUND_ZAP, entity, SNDCHAN_STATIC, 65, _, 0.65);
		RemoveEntity(entity);
	}
}


bool Nymph_AllowBonusDamage(int victim)
{
	for(int i; i < Element_Osmosis; i++)
	{
		if(f_ArmorCurrosionImmunity[victim][i] > GetGameTime())
		{
			return true;
		}
	}
	if(Osmosis_CurrentlyInDebuff(victim))
		return true;

	return false;
}