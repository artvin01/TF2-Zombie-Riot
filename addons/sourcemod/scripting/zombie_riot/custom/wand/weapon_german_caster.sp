#pragma semicolon 1
#pragma newdecls required

#define WAND_GERMAN_HIT_SOUND	"ui/killsound_space.wav"
#define WAND_GERMAN_M2_SOUND	"Taunt.MedicViolinUber"
#define WAND_GERMAN_M1_SOUND	"WeaponMedigun_Vaccinator.Charged_tier_0%d"

static Handle GermanTimer[MAXTF2PLAYERS];
static Handle GermanSilence[MAXTF2PLAYERS];
static int GermanCharges[MAXTF2PLAYERS];
static int GermanWeapon[MAXTF2PLAYERS];

void Weapon_German_MapStart()
{
	PrecacheSound(WAND_GERMAN_HIT_SOUND);
}

public void Weapon_German_M1_Normal(int client, int weapon, bool &result, int slot)
{
	int cost = GermanSilence[client] ? 150 : 200;
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

		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		delay_hud[client] = 0.0;
		Current_Mana[client] -= cost;

		float cooldown = 0.8 * Attributes_Get(weapon, 6, 1.0);
		if(GermanSilence[client])
			cooldown *= 0.6;
		
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + cooldown);
	}
	else if(GermanWeapon[client] == EntIndexToEntRef(weapon))
	{
		int maxcharge = GermanSilence[client] ? 4 : 3;
		if(GermanCharges[client] < maxcharge)
		{
			GermanCharges[client]++;

			PlayChargeSound(client, GermanCharges[client], maxcharge);
			
			Mana_Hud_Delay[client] = 0.0;
			delay_hud[client] = 0.0;
			Current_Mana[client] -= cost;

			float cooldown = 0.8 * Attributes_Get(weapon, 6, 1.0);
			if(GermanSilence[client])
				cooldown *= 0.6;
			
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + cooldown);
		}
		else
		{
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.01);
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
}

public void Weapon_German_M1_Module(int client, int weapon, bool &result, int slot)
{
	int cost = GermanSilence[client] ? 150 : 200;
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

		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		delay_hud[client] = 0.0;
		Current_Mana[client] -= cost;

		float cooldown = 0.7 * Attributes_Get(weapon, 6, 1.0);
		if(GermanSilence[client])
			cooldown *= 0.6;
		
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + cooldown);
	}
	else if(GermanWeapon[client] == EntIndexToEntRef(weapon))
	{
		int maxcharge = GermanSilence[client] ? 5 : 4;
		if(GermanCharges[client] < maxcharge)
		{
			GermanCharges[client]++;

			PlayChargeSound(client, GermanCharges[client], maxcharge);
			
			Mana_Hud_Delay[client] = 0.0;
			delay_hud[client] = 0.0;
			Current_Mana[client] -= cost;

			float cooldown = 0.7 * Attributes_Get(weapon, 6, 1.0);
			if(GermanSilence[client])
				cooldown *= 0.6;
			
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + cooldown);
		}
		else
		{
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.01);
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
		sound = charge - (4 - max);
		if(sound < 1)
			sound = 1;
	}

	char buffer[64];
	FormatEx(buffer, sizeof(buffer), WAND_GERMAN_M1_SOUND, sound);
	EmitGameSoundToClient(client, buffer);
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

				for(int i = 1; i < GermanCharges[client]; i++)
				{
					if(i == 2)
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
					Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_GERMAN, weapon, "unusual_tesla_flash");
				}
			}
			else
			{
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				return Plugin_Continue;
			}
		}
	}

	GermanTimer[client] = null;
	return Plugin_Stop;
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
		Entity_Position = WorldSpaceCenter(target);

		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position, _ , ZR_DAMAGE_LASER_NO_BLAST);
		
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
		delete GermanSilence[client];
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
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 50.0);
			Mana_Regen_Delay[client] = GetGameTime() + 1.0;

			TF2_AddCondition(client, TFCond_FocusBuff, 30.0);
			GermanSilence[client] = CreateTimer(30.0, Weapon_German_SilenceTimer, client);

			EmitGameSoundToClient(client, WAND_GERMAN_M2_SOUND);
		}
	}
}

public Action Weapon_German_SilenceTimer(Handle timer, int client)
{
	GermanSilence[client] = null;
	return Plugin_Stop;	
}