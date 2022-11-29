#pragma semicolon 1
#pragma newdecls required

#define EMPOWER_RANGE 200.0
#define EMPOWER_SOUND "items/powerup_pickup_king.wav"
#define EMPOWER_MATERIAL "materials/sprites/laserbeam.vmt"
#define EMPOWER_WIDTH 5.0
#define EMPOWER_HIGHT_OFFSET 20.0

static float Duration[MAXTF2PLAYERS];
static int Weapon_Id[MAXTF2PLAYERS];

public void Fusion_Melee_OnMapStart()
{
	Zero(Duration);
	Zero(Weapon_Id);
	PrecacheSound(EMPOWER_SOUND);
}

public float Npc_OnTakeDamage_Fusion(int victim, float damage, int weapon)
{
	
	return damage;
}

public void Fusion_Melee_Empower_State(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Ability_Apply_Cooldown(client, slot, 60.0); //Semi long cooldown, this is a strong buff.

		Duration[client] = GetGameTime() + 10.0; //Just a test.

		EmitSoundToAll(EMPOWER_SOUND, client, SNDCHAN_STATIC, 90, _, 0.6);
		Weapon_Id[client] = EntIndexToEntRef(weapon);
		CreateTimer(0.1, Empower_ringTracker, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Empower_ringTracker_effect, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.0, Empower_ringTracker_effect, client, TIMER_FLAG_NO_MAPCHANGE); //Make it happen atleast once instantly
		f_EmpowerStateSelf[client] = GetGameTime() + 0.6;
		spawnRing(client, EMPOWER_RANGE * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 30, 0.51, EMPOWER_WIDTH, 6.0, 10);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

static Action Empower_ringTracker(Handle ringTracker, int client)
{
	if (IsValidClient(client) && Duration[client] > GetGameTime())
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(EntRefToEntIndex(Weapon_Id[client]) == ActiveWeapon)
		{
			spawnRing(client, EMPOWER_RANGE * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 10, 0.11, EMPOWER_WIDTH, 6.0, 10);
			
			f_EmpowerStateSelf[client] = GetGameTime() + 0.6;

			float chargerPos[3];
			float targPos[3];
			GetClientAbsOrigin(client, chargerPos);
			for (int targ = 1; targ <= MaxClients; targ++)
			{
				if (IsValidClient(targ) && IsValidClient(client))
				{
					GetClientAbsOrigin(targ, targPos);
					if (targ != client && GetVectorDistance(chargerPos, targPos, true) <= Pow(EMPOWER_RANGE, 2.0))
					{
						f_EmpowerStateOther[targ] = GetGameTime() + 0.6;
					}
				}
			}

			//Buff allied npcs too! Is cool!
			for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
			{
				int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
				if (IsValidEntity(baseboss_index_allied))
				{
					GetEntPropVector(baseboss_index_allied, Prop_Data, "m_vecAbsOrigin", chargerPos);
					if (GetVectorDistance(chargerPos, targPos, true) <= Pow(EMPOWER_RANGE, 2.0))
					{
						f_EmpowerStateOther[baseboss_index_allied] = GetGameTime() + 0.6;
					}
				}
			}
		}
		else
		{
			KillTimer(ringTracker, false);
		}

	}
	else
	{
		KillTimer(ringTracker, false);
	}

	return Plugin_Continue;
}

static Action Empower_ringTracker_effect(Handle ringTracker, int client)
{
	if (IsValidClient(client) && Duration[client] > GetGameTime() && IsValidEntity(EntRefToEntIndex(Weapon_Id[client])))
	{
		int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(EntRefToEntIndex(Weapon_Id[client]) == ActiveWeapon)
		{
			//	spawnRing(client, EMPOWER_RANGE * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 30, 0.5, EMPOWER_WIDTH, 6.0, 10);
			spawnRing(client, 0.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 1, 0.51, EMPOWER_WIDTH, 6.1, 1, EMPOWER_RANGE * 2.0);
		}
		else
		{
			KillTimer(ringTracker, false);
		}
	}
	else
	{
		KillTimer(ringTracker, false);
	}

	return Plugin_Continue;
}