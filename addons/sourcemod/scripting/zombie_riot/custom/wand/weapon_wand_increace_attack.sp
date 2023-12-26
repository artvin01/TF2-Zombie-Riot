#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static int weapon_id[MAXPLAYERS+1]={0, ...};

#define SOUND_WAND_ATTACKSPEED_ABILITY "weapons/physcannon/energy_disintegrate4.wav"

public void Wand_Default_Spell_ClearAll()
{
	Zero(ability_cooldown);
}
void Wand_Attackspeed_Map_Precache()
{
	PrecacheSound(SOUND_WAND_ATTACKSPEED_ABILITY);
}

public void Weapon_Wand_AttackSpeed(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 30;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 15.0);
				
				weapon_id[client] = weapon;
				
				float Original_Atackspeed = 1.0;
				
				Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);
				
				Attributes_Set(weapon, 6, Original_Atackspeed * 0.25);
				
				EmitSoundToAll(SOUND_WAND_ATTACKSPEED_ABILITY, client, SNDCHAN_STATIC, 80, _, 0.9);
				
				CreateTimer(3.0, Reset_Wand_Attackspeed, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
				
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
				
				delay_hud[client] = 0.0;
				
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


public Action Reset_Wand_Attackspeed(Handle cut_timer, int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (IsValidEntity(weapon))
	{
		float Original_Atackspeed;

		Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);

		Attributes_Set(weapon, 6, Original_Atackspeed / 0.25);
	}
	return Plugin_Handled;
}