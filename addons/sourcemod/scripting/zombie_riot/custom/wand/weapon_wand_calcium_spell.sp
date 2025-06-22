#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Necro_Damage[MAXPLAYERS+1]={0.0, ...};

public void Wand_Calcium_Spell_ClearAll()
{
	Zero(ability_cooldown);
}

#define SOUND_WAND_CALCIUM_ABILITY "misc/halloween/spell_skeleton_horde_rise.wav"

void Wand_CalciumSpell_Map_Precache()
{
	PrecacheSound(SOUND_WAND_CALCIUM_ABILITY);
}

public void Weapon_Calcium_FireBallSpell(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 250;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(client, weapon);
				Ability_Apply_Cooldown(client, slot, 19.0);
				
				Necro_Damage[client] = 1.0;

				Necro_Damage[client] *= Attributes_Get(weapon, 410, 1.0);
				
				Necro_Damage[client] *= 1.6;
				
				Necro_Damage[client] *= 2.0; //Two times so i can half minions.
				
				Attributes_Set(client, 698, 0.0);
								
				TF2_RemoveWeaponSlot(client, 5);
				
				int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "13 ; 9999");
				Attributes_Set(client, 178, 0.25);
				FakeClientCommand(client, "use tf_weapon_spellbook");
				Attributes_Set(client, 698, 1.0);
				
				SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
				SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
				Delete_Flame[client] = true;
				CreateTimer(0.5, Calcium_Remove_Spell, client, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(0.4, Fireball_Remove_Spell_Entity, EntIndexToEntRef(spellbook), TIMER_FLAG_NO_MAPCHANGE);
					
				SDKhooks_SetManaRegenDelayTime(client, 1.0);
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

public Action Wand_Calcium_Spell(int entity)
{
	if (IsValidEntity(entity))
	{
		SetEntityCollisionGroup(entity, 27);
		//Make it act like a rocket so it passes through.
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		
		// Is the owner a player?
		if (owner > 0 && owner <= MaxClients && Delete_Flame[owner])
		{
			RemoveEntity(entity);
			Delete_Flame[owner] = false;
		}
	}
	return Plugin_Handled;
}

public Action Calcium_Remove_Spell(Handle Calcium_Remove_SpellHandle, int client)
{
	if (IsValidClient(client))
	{
		Spawn_Calcium(client);
		Attributes_Set(client, 698, 0.0);
		FakeClientCommand(client, "use tf_weapon_bonesaw");
		Attributes_Set(client, 178, 1.0);
		TF2_RemoveWeaponSlot(client, 5);
	}	
	return Plugin_Handled;
}

public void Spawn_Calcium(int client)
{
	float flPos[3], flAng[3];
	GetClientAbsOrigin(client, flPos);
	GetClientAbsAngles(client, flAng);
	
	int npc = NPC_CreateByName("npc_necromancy_calcium", client, flPos, flAng, TFTeam_Red);
	fl_Extra_Damage[npc] = Necro_Damage[client];
}
