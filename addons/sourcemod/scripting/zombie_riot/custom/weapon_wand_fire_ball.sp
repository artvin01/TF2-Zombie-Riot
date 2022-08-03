static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Fireball_Damage[MAXPLAYERS+1]={0.0, ...};

#define SOUND_WAND_ATTACKSPEED_ABILITY "weapons/physcannon/energy_disintegrate4.wav"
public void Wand_Fire_Spell_ClearAll()
{
	Zero(ability_cooldown);
}

void Wand_FireBall_Map_Precache()
{
	PrecacheSound(SOUND_WAND_ATTACKSPEED_ABILITY);
}

public void Weapon_Wand_FireBallSpell(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 35;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Ability_Apply_Cooldown(client, slot, 10.0);
				
				float damage = 50.0;
				
				damage *= 3.5;
				
				Address address = TF2Attrib_GetByDefIndex(weapon, 410);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
			
				Fireball_Damage[client] = damage;
				
				TF2Attrib_SetByDefIndex(client, 698, 0.0);
								
				TF2_RemoveWeaponSlot(client, 5);
				
				int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "");
				TF2Attrib_SetByDefIndex(client, 178, 0.25);
				FakeClientCommand(client, "use tf_weapon_spellbook");
				TF2Attrib_SetByDefIndex(client, 698, 1.0);
				
				SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
				SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
				
				CreateTimer(0.5, Fireball_Remove_Spell, client, TIMER_FLAG_NO_MAPCHANGE);
					
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
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public Action Fireball_Remove_Spell(Handle Fireball_Remove_SpellHandle, int client)
{
	if (IsValidClient(client))
	{
		TF2Attrib_SetByDefIndex(client, 698, 0.0);
		FakeClientCommand(client, "use tf_weapon_bonesaw");
		TF2Attrib_SetByDefIndex(client, 178, 1.0);
		TF2_RemoveWeaponSlot(client, 5);
	}	
	return Plugin_Handled;
}