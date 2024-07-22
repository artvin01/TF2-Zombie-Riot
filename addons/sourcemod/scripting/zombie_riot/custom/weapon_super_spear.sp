#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerBomblancenLauncherManagement[MAXPLAYERS+1] = {null, ...};
int i_HowManyAttack[MAXENTITIES];
bool b_abilityon[MAXENTITIES];
bool b_explode[MAXENTITIES];
bool b_speedbuffed[MAXENTITIES];
static int i_BomblanceParticle[MAXTF2PLAYERS];
static int i_Current_Pap[MAXTF2PLAYERS+1];

#define SOUND_ABILITY_ACTIVATE "items/powerup_pickup_resistance.wav"
#define SOUND_BOOM_SHOT 	"weapons/explode1.wav"

void Reset_Bomblance() //This is on weapon remake. cannot set to 0 outright.
{
	Zero(i_NextAttackDoubleHit);
	Zero(i_HowManyAttack);
	Bomblance_Map_Precache();
}
void Bomblance_Map_Precache()
{
	PrecacheSound(SOUND_ABILITY_ACTIVATE);
}

public void Enable_Bomblance(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerBomblancenLauncherManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOMBLANCE)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerBomblancenLauncherManagement[client];
			h_TimerBomblancenLauncherManagement[client] = null;
			DataPack pack;
			h_TimerBomblancenLauncherManagement[client] = CreateDataTimer(0.25, Timer_Management_Bomblance, pack, TIMER_REPEAT);
			i_Current_Pap[client] = Bomblance_Get_Pap(weapon);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BOMBLANCE)
	{
		DataPack pack;
		h_TimerBomblancenLauncherManagement[client] = CreateDataTimer(0.25, Timer_Management_Bomblance, pack, TIMER_REPEAT);
		i_Current_Pap[client] = Bomblance_Get_Pap(weapon);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Bomblance(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		i_HowManyAttack[client] = 0;
		DestroyBomblanceEffect(client);
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		CreateBomblanceEffect(client);
	}
	else
	{
		i_HowManyAttack[client] = 0;
		DestroyBomblanceEffect(client);
	}
	return Plugin_Continue;
}

void Bomblance_Melee_Swing(float &CustomMeleeRange, float &CustomMeleeWide)
{
	CustomMeleeRange = 55.0;
	CustomMeleeWide = 20.0;
}

static int Bomblance_Get_Pap(int weapon) //deivid inspired pap detection system (as in literally a copy-paste from fantasy blade)
{
	int pap=0;
	pap = RoundFloat(Attributes_Get(weapon, 122, 0.0));
	return pap;
}

public void Weapon_Bomblance_TripleStrike(int client, int weapon, bool crit, int slot)
{
	float attackspeed = Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
	PrintToChatAll("ATTACK");
	if(b_abilityon[client])
	{
		PrintToChatAll("Ability on hit");
		if(i_HowManyAttack[weapon] < 2) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
		{
			PrintToChatAll("Charging attack");
			i_HowManyAttack[weapon] += 1;
			if(!b_speedbuffed[client])
			{
				b_speedbuffed[weapon] = true;
				attackspeed = (attackspeed * 0.2);
				Attributes_Set(weapon, 6, attackspeed);
			}
		}
		else if(i_HowManyAttack[weapon] > 1)
		{
			PrintToChatAll("3rd hit!");
			i_HowManyAttack[weapon] = 0;
			b_speedbuffed[client] = false;
			b_explode[client] = true;
			attackspeed = (attackspeed / 0.2);
			Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
		}
	}
}

public void Bomblance_attack(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 40.0);
			EmitSoundToAll(SOUND_ABILITY_ACTIVATE, client, SNDCHAN_AUTO, 70, _, 1.0);
			CreateTimer(10.0, Bomblance_ability_off, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			ApplyTempAttrib(weapon, 206, 0.75, 10.0);
			ApplyTempAttrib(weapon, 2, 0.6, 10.0);
			b_abilityon[client] = true;
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

public Action Bomblance_ability_off(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	b_abilityon[client] = false;
	PrintToChatAll("Ability off");
	return Plugin_Stop;
}

void Bomblance_OnTakeDamageNpc(int attacker,int victim, int weapon, float &damage)
{
	if(b_explode[attacker])
	{
		PrintToChatAll("Explosive trigger");
		if(IsValidEntity(weapon))
		{
			//if(damagetype & DMG_CLUB)
			//Code to do damage position and ragdolls
			static float angles[3];
			GetEntPropVector(attacker, Prop_Send, "m_angRotation", angles);
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			float position[3];
			GetEntPropVector(attacker, Prop_Data, "effect_hand_r", position);

			int owner = EntRefToEntIndex(i_WandOwner[attacker]);

			float BaseDMG = 250.0;
			BaseDMG *= Attributes_Get(weapon, 2, 1.0);

			float Radius = EXPLOSION_RADIUS;
			Radius *= Attributes_Get(weapon, 99, 1.0);

			float Falloff = Attributes_Get(weapon, 117, 1.0);
			float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

			float spawnLoc[3];
			Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, Radius, Falloff);
			EmitAmbientSound(SOUND_BOOM_SHOT, spawnLoc, attacker, 70,_, 0.6);
			ParticleEffectAt(position, "taunt_pyro_balloon_explosion", 1.0);
			PrintToChatAll("Explode complete");
			b_explode[attacker] = false;
		}
	}
	int pap = i_Current_Pap[attacker];
	switch(pap)
	{
		case 0:
		{
			PrintToChatAll("Normal hit");
		}
		case 1:
		{
			PrintToChatAll("Fire hit");
			NPC_Ignite(victim, attacker, 5.0, weapon);
		}
		case 2:
		{
			PrintToChatAll("ICE hit");
			if((f_LowIceDebuff[victim] - 1.0) < GetGameTime())
				{
					f_LowIceDebuff[victim] = GetGameTime() + 1.1;
				}
			Elemental_AddCyroDamage(victim, attacker, 50, 1);
		}
	}

}

void CreateBomblanceEffect(int client)
{
	if(!IsValidEntity(i_BomblanceParticle[client]))
	{
		return;
	}
	DestroyBomblanceEffect(client);
	
	int pap = i_Current_Pap[client];
	float flPos[3];
	float flAng[3];
	GetAttachment (client, "effect_hand_r", flPos, flAng);
	switch(pap)
	{
		case 0:
		{
			return;
		}
		case 1:
		{
			int particle = ParticleEffectAt(flPos, "unusual_frosty_flavours_red_smoke", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(client, particle, "effect_hand_r");
			i_BomblanceParticle[client][0] = EntIndexToEntRef(particle);
		}
		case 2:
		{
			int particle = ParticleEffectAt(flPos, "unusual_frosty_flavours_blu_smoke", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(client, particle, "effect_hand_r");
			i_BomblanceParticle[client][0] = EntIndexToEntRef(particle);
		}
	}
}
void DestroyBomblanceEffect(int client)
{
	int entity = EntRefToEntIndex(i_BomblanceParticle[client]);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	i_BomblanceParticle[client] = INVALID_ENT_REFERENCE;
}