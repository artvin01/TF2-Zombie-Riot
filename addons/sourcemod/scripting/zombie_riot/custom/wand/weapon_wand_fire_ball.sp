#pragma semicolon 1
#pragma newdecls required

static int i_FireBallsToThrow[MAXPLAYERS+1]={0, ...};
static float f_FireBallDamage[MAXPLAYERS+1]={0.0, ...};

#define WAND_FIREBALL_SOUND "misc/halloween/spell_fireball_cast.wav"

public void Wand_Fire_Spell_ClearAll()
{
	Zero(i_FireBallsToThrow);
}

void Wand_FireBall_Map_Precache()
{
	PrecacheSound(WAND_FIREBALL_SOUND);
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
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 5.0);
				
				Attributes_Set(client, 698, 0.0);
								
				TF2_RemoveWeaponSlot(client, 5);
				
				int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "");
				Attributes_Set(client, 178, 0.25);
				FakeClientCommand(client, "use tf_weapon_spellbook");
				Attributes_Set(client, 698, 1.0);
				
				SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
				SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
				
				CreateTimer(0.4, Fireball_Remove_Spell, client, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(0.4, Fireball_Remove_Spell_Entity, EntIndexToEntRef(spellbook), TIMER_FLAG_NO_MAPCHANGE);
					
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

public void Weapon_Wand_FireBallSpell2(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 50;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 10.0);
				
				Attributes_Set(client, 698, 0.0);
								
				TF2_RemoveWeaponSlot(client, 5);
				f_FireBallDamage[client] = 150.0;
				f_FireBallDamage[client] *= Attributes_Get(weapon, 410, 1.0);
				
				int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "");
				Attributes_Set(client, 178, 0.25);
				FakeClientCommand(client, "use tf_weapon_spellbook");
				Attributes_Set(client, 698, 1.0);
				
				SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
				SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
				
				CreateTimer(0.4, Fireball_Remove_Spell, client, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(0.4, Fireball_Remove_Spell_Entity, EntIndexToEntRef(spellbook), TIMER_FLAG_NO_MAPCHANGE);
					
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;

				i_FireBallsToThrow[client] = 1;
				CreateTimer(0.2, FireMultipleFireBalls, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

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


public void Weapon_Wand_FireBallSpell3(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 100;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 10.0);
				
				Attributes_Set(client, 698, 0.0);
								
				TF2_RemoveWeaponSlot(client, 5);
				f_FireBallDamage[client] = 150.0;
				f_FireBallDamage[client] *= Attributes_Get(weapon, 410, 1.0);
				
				int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "");
				Attributes_Set(client, 178, 0.25);
				FakeClientCommand(client, "use tf_weapon_spellbook");
				Attributes_Set(client, 698, 1.0);
				
				SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
				SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
				
				CreateTimer(0.4, Fireball_Remove_Spell, client, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(0.4, Fireball_Remove_Spell_Entity, EntIndexToEntRef(spellbook), TIMER_FLAG_NO_MAPCHANGE);
					
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;

				i_FireBallsToThrow[client] = 2;
				CreateTimer(0.2, FireMultipleFireBalls, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

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


public void Weapon_Wand_FireBallSpell4(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 150;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				Ability_Apply_Cooldown(client, slot, 10.0);
				
				Attributes_Set(client, 698, 0.0);
								
				TF2_RemoveWeaponSlot(client, 5);
				f_FireBallDamage[client] = 150.0;
				f_FireBallDamage[client] *= Attributes_Get(weapon, 410, 1.0);
				
				int spellbook = SpawnWeapon_Special(client, "tf_weapon_spellbook", 1070, 100, 5, "");
				Attributes_Set(client, 178, 0.25);
				FakeClientCommand(client, "use tf_weapon_spellbook");
				Attributes_Set(client, 698, 1.0);
				
				SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
				SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
				
				CreateTimer(0.4, Fireball_Remove_Spell, client, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(0.4, Fireball_Remove_Spell_Entity, EntIndexToEntRef(spellbook), TIMER_FLAG_NO_MAPCHANGE);
					
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;

				i_FireBallsToThrow[client] = 4;
				CreateTimer(0.2, FireMultipleFireBalls, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

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


public Action Fireball_Remove_Spell(Handle Fireball_Remove_SpellHandle, int client)
{
	if (IsValidClient(client))
	{
		Attributes_Set(client, 698, 0.0);
		FakeClientCommand(client, "use tf_weapon_bonesaw");
		Attributes_Set(client, 178, 1.0);
	}	
	return Plugin_Handled;
}


public Action Fireball_Remove_Spell_Entity(Handle Fireball_Remove_SpellHandle, int ref)
{
	int index = EntRefToEntIndex(ref);
	if (IsValidEntity(index))
	{
		RemoveEntity(index);
	}	
	return Plugin_Handled;
}

public Action FireMultipleFireBalls(Handle Timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsValidClient(client))
	{
		if(i_FireBallsToThrow[client] > 0)
		{
			int mana_cost = 50;
			if(mana_cost <= Current_Mana[client])
			{

				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;


				int i, weapon;
				while(TF2_GetItem(client, weapon, i))
				{
					if(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 939)
					{
						break;
					}
				}



				float fAng[3], fPos[3];
				GetClientEyeAngles(client, fAng);
				GetClientEyePosition(client, fPos);

				static float speed = 1000.0;

				float fVel[3], fBuf[3];
				GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
				fVel[0] = fBuf[0]*speed;
				fVel[1] = fBuf[1]*speed;
				fVel[2] = fBuf[2]*speed;

				int entity = CreateEntityByName("tf_projectile_spellfireball");
				if(IsValidEntity(entity))
				{
					SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
					SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
					SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
					TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
					DispatchSpawn(entity);
					TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
					f_CustomGrenadeDamage[entity] = f_FireBallDamage[client];
					
				}
				EmitSoundToAll(WAND_FIREBALL_SOUND, client, SNDCHAN_AUTO, 80, _, 0.7);
				i_FireBallsToThrow[client] -= 1;
							
				return Plugin_Continue;
			}
			else
			{
				return Plugin_Stop;
			}
		}
		else
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Stop;
}