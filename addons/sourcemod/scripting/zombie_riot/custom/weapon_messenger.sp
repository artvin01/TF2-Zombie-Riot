#pragma semicolon 1
#pragma newdecls required

static bool Change[MAXPLAYERS];
static int i_MessengerParticle[MAXTF2PLAYERS];
static char MessengerParticle[MAXTF2PLAYERS][48];
static Handle h_TimerMessengerWeaponManagement[MAXPLAYERS+1] = {null, ...};
static float f_Messengerhuddelay[MAXPLAYERS+1]={0.0, ...};

#define SOUND_MES_IMPACT "weapons/cow_mangler_explosion_normal_01.wav"

void ResetMapStartMessengerWeapon()
{
	Zero(f_Messengerhuddelay);
	Messenger_Map_Precache();
}
void Messenger_Map_Precache()
{
	PrecacheSound(SOUND_MES_IMPACT);
}


public void Enable_Messenger_Launcher_Ability(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerMessengerWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MESSENGER_LAUNCHER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerMessengerWeaponManagement[client];
			h_TimerMessengerWeaponManagement[client] = null;
			DataPack pack;
			h_TimerMessengerWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Messenger, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MESSENGER_LAUNCHER)
	{
		DataPack pack;
		h_TimerMessengerWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Messenger, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Messenger(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		DestroyMessengerEffect(client);
		Change[client] = false;
		return Plugin_Stop;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		CreateMessengerEffect(client);
		MessengerHudShow(client,weapon);
	}
	else
	{
		DestroyMessengerEffect(client);
	}
	return Plugin_Continue;
}

void MessengerHudShow(int client, int weapon)
{
	if(f_Messengerhuddelay[client] < GetGameTime())
	{
		f_Messengerhuddelay[client] = GetGameTime() + 0.5;
		CheckMessengerMode(client);
	}
}

void CheckMessengerMode(int client)
{
	if (Change[client] == true )
	{
		PrintHintText(client,"Chaos Blaster");
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	}
	else if (Change[client] == false)
	{
		PrintHintText(client,"Fire Blaster");
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	}
}

void CreateMessengerEffect(int client)
{
	DestroyMessengerEffect(client);
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float flPos[3]; 
		float flAng[3];
		int particle = ParticleEffectAt(flPos, MessengerParticle[client], 0.0);
		GetAttachment(viewmodelModel, "effect_hand_l", flPos, flAng);
		SetParent(viewmodelModel, particle, "effect_hand_l");
		i_MessengerParticle[client][0] = EntIndexToEntRef(particle);
	}
	if(Change[client] == true)
	{
		DestroyMessengerEffect(client);
		Format(MessengerParticle[client], sizeof(MessengerParticle[]), "%s","critical_rocket_blue"); //white
		CreateMessengerEffect(client);
	}
	else if(Change[client] == false)
	{
		DestroyMessengerEffect(client);
		Format(MessengerParticle[client], sizeof(MessengerParticle[]), "%s","critical_rocket_red"); // green
		CreateMessengerEffect(client);
	}
			
}
void DestroyMessengerEffect(int client)
{
	int entity = EntRefToEntIndex(i_MessengerParticle[client]);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	i_MessengerParticle[client] = INVALID_ENT_REFERENCE;
}

public void Weapon_Messenger(int client, int weapon, bool crit)
{
	float damage = 250.0;

	damage *= Attributes_GetOnPlayer(client, 2, true);
			
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
		
	float time = 25.0; //Pretty much inf.
	
	if(Change[client] == true)
	{
		Wand_Projectile_Spawn(client, speed, time, damage, 7/*Default wand*/, weapon, "spell_fireball_small_red",_,false);
	}
	else if(Change[client] == false)
	{
		Wand_Projectile_Spawn(client, speed, time, damage, 7/*Default wand*/, weapon, "spell_fireball_small_blue",_,false);
	}

}

public void Messenger_Modechange(int client, int weapon, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 5.0);
		if(Change[client] == true)
		{
			Change[client] = false;
		}
		if(Change[client] == false)
		{
			Change[client] = true;
		}
	}
}


public void Gun_MessengerTouch(int entity, int target, int victim, int attacker, int client)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		if(Change[client] == true)
		{
			NPC_Ignite(victim, attacker, 3.0, weapon);
		}
		else if(Change[client] == false)
		{
			if((f_LowIceDebuff[target] - 0.5) < GetGameTime())
			{
				f_LowIceDebuff[target] = GetGameTime() + 0.6;
			}
		}
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		EmitSoundToAll(SOUND_MES_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		EmitSoundToAll(SOUND_MES_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}