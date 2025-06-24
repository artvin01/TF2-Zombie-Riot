#pragma semicolon 1
#pragma newdecls required

static float f_TimerForDamageTexan[MAXPLAYERS];

#define SOUND_DASH "npc/roller/mine/rmine_explode_shock1.wav"

void Weapon_TexanBuisnesMapChange()
{
	PrecacheSound(SOUND_DASH);
	Zero(f_TimerForDamageTexan);
}

public void Weapon_TexanBuisness(int attacker, float &damage, int damagetype)
{
	if(damagetype & DMG_CLUB)
	{
		if (f_TimerForDamageTexan[attacker] > GetGameTime())
		{
			f_TimerForDamageTexan[attacker] = 0.0;
			damage *= 12.0;

			ClientCommand(attacker, "playgamesound weapons/air_burster_explode3.wav");
			static float anglesB[3];
			GetClientEyeAngles(attacker, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			float knockback = -325.0;
			// knockback is the overall force with which you be pushed, don't touch other stuff
			ScaleVector(velocity, knockback);
			if ((GetEntityFlags(attacker) & FL_ONGROUND) != 0 || GetEntProp(attacker, Prop_Send, "m_nWaterLevel") >= 1)
				velocity[2] = fmax(velocity[2], 300.0);
			else
				velocity[2] += 150.0;    // a little boost to alleviate arcing issues

			TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, velocity);
		}
	}
}

public void Texan_business_altattack(int client, int weapon, bool crit, int slot)
{
    if(Object_MaxSupportBuildings(client, true) > 4)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Handle swingTrace;
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 700.0, false, 45.0, true); //infinite range, and ignore walls!
			FinishLagCompensation_Base_boss();

			int target = TR_GetEntityIndex(swingTrace);	
			delete swingTrace;
			if(!IsValidEnemy(client, target, true))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				return;
			}
			
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 30.0);
			static float EntLoc[3];

			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);

			SpawnSmallExplosionNotRandom(EntLoc);

			EmitSoundToAll(SOUND_DASH, client, _, 70, _, 1.0);

			static float anglesB[3];
			GetClientEyeAngles(client, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			float knockback = 600.0;
			// knockback is the overall force with which you be pushed, don't touch other stuff
			ScaleVector(velocity, knockback);
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
				velocity[2] = fmax(velocity[2], 300.0);
			else
				velocity[2] += 150.0;    // a little boost to alleviate arcing issues

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

			f_TimerForDamageTexan[client] = GetGameTime() + 2.0;
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);

			if (Ability_CD <= 0.0)
				Ability_CD = 0.0;

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}/*
	else
	{

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Builder Upgrades");
	}*/
}