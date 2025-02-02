#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerWestWeaponManagement[MAXPLAYERS+1] = {null, ...};
static float f_West_Aim_Duration[MAXPLAYERS+1];
static int i_West_Target[MAXPLAYERS+1];

#define SOUND_REVOLVER_FANG 	"items/powerup_pickup_agility.wav"
#define SOUND_REVOLVER_NOON 	"ambient/medieval_falcon.wav"

void ResetMapStartWest()
{
	West_Map_Precache();
	Zero(f_West_Aim_Duration);
}
void West_Map_Precache()
{
	PrecacheSound(SOUND_REVOLVER_FANG);
	PrecacheSound(SOUND_REVOLVER_NOON);
}

public void Enable_West_Weapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerWestWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WEST_REVOLVER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerWestWeaponManagement[client];
			h_TimerWestWeaponManagement[client] = null;
			DataPack pack;
			h_TimerWestWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Revolver_West, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WEST_REVOLVER)
	{
		DataPack pack;
		h_TimerWestWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Revolver_West, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Revolver_West(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerWestWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		REVOLER_AIM(client);
	}
		
	return Plugin_Continue;
}

public void Revolver_Fang(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 30.0);
			EmitSoundToAll(SOUND_REVOLVER_FANG, client, SNDCHAN_AUTO, 100, _, 0.6);
			ApplyTempAttrib(weapon, 6, 0.3, 2.0);
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
public void Revolver_Fang_PAP1(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 25.0);
			EmitSoundToAll(SOUND_REVOLVER_FANG, client, SNDCHAN_AUTO, 100, _, 0.6);
			ApplyTempAttrib(weapon, 6, 0.3, 2.5);

			static float anglesB[3];
			GetClientEyeAngles(client, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(velocity, velocity);
			float knockback = -750.0;
			// knockback is the overall force with which you be pushed, don't touch other stuff
			ScaleVector(velocity, knockback);
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			{
				velocity[2] = fmax(velocity[2], 300.0);
			}	
			else
			{
				velocity[2] += 90.0;	// a little boost to alleviate arcing issues
			}
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
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

public void Revolver_Highnoon(int client, int weapon, bool crit, int slot, int victim)
{
	if(IsValidEntity(client))
	{
		
		if(Ability_Check_Cooldown(client, slot) < 0.0 && !(GetClientButtons(client) & IN_DUCK) && b_InteractWithReload[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Crouch for ability");	
			return;
		}
		
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 60.0);
			EmitSoundToAll(SOUND_REVOLVER_NOON, client, SNDCHAN_AUTO, 140, _, 0.6);
			ApplyTempAttrib(weapon, 6, 0.1, 1.5);
			ApplyTempAttrib(weapon, 2, 1.3, 1.5);
			ApplyTempAttrib(weapon, 97, 0.01, 1.5);
			MakePlayerGiveResponseVoice(client, 1);

			Handle swingTrace;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9900.0, false, 9900.0, true); //infinite range, and does not ignore walls!
			FinishLagCompensation_Base_boss();

				
			int target = TR_GetEntityIndex(swingTrace);	
			delete swingTrace;
			if(!IsValidEnemy(client, target, true))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}
			i_West_Target[client] = EntIndexToEntRef(target);


			TF2_AddCondition(client, TFCond_HalloweenCritCandy, 2.0, client);
			f_West_Aim_Duration[client] = GetGameTime() + 2.0;	
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

void REVOLER_AIM(int client)
{
	if(f_West_Aim_Duration[client] > GetGameTime())
	{
		int ChargeEnemy = EntRefToEntIndex(i_West_Target[client]);
		if(IsValidEnemy(client, ChargeEnemy, true))
		{
			if(TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy))
			{
				LookAtTarget(client, ChargeEnemy);
			}
		}
		else if(!TF2_IsPlayerInCondition(client, TFCond_Charging))
		{
			f_West_Aim_Duration[client] = 0.0;
		}
	}
	else
	{
		TF2_RemoveCondition(client, TFCond_HalloweenCritCandy);
		f_West_Aim_Duration[client] = 0.0;
	}
}