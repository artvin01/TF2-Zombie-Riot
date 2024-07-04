#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerSoldineKitManagement[MAXPLAYERS+1] = {null, ...};
static float f_West_Aim_Duration[MAXPLAYERS+1];
static int i_West_Target[MAXPLAYERS+1];

#define SOUND_JUMP 	"weapon/rocket_ll_shoot.wav"
#define SOUND_JUMP_Activation 	"items/powerup_pickup_agility.wav"
#define SOUND_MARKET_EXPLOSION 	"items/cart_explode.wav"

static bool FistReady[MAXPLAYERS];

void ResetMapStartSoldine()
{
	Soldine_Map_Precache();
}
void Soldine_Map_Precache()
{
	PrecacheSound(SOUND_JUMP);
	PrecacheSound(SOUND_JUMP_MARKET);
	PrecacheSound(SOUND_MARKET_EXPLOSION);
}

public void Enable_Kit_Soldine(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerSoldineKitManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_SOLDINE)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerSoldineKitManagement[client];
			h_TimerSoldineKitManagement[client] = null;
			DataPack pack;
			h_TimerSoldineKitManagement[client] = CreateDataTimer(0.1, Timer_Management_Soldine_Kit, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_SOLDINE)
	{
		DataPack pack;
		h_TimerSoldineKitManagement[client] = CreateDataTimer(0.1, Timer_Management_Soldine_Kit, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Soldine_Kit(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerSoldineKitManagement[client] = null;
		FistReady = false;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		CreateSoldineEffect(client);
		Victorian_Cooldown_Logic(client, weapon);
		TF2_RemoveCondition(client, TFCond_KingAura);
	}
	else
	{
		DestroySoldineEffect(client);
	}

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		FistReady = false;
		TF2_RemoveCondition(client, TFCond_HalloweenCritCandy);
	}
		
	return Plugin_Continue;
}

public void Soldine_Jump(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 40.0);
			EmitSoundToAll(SOUND_JUMP, client, SNDCHAN_AUTO, 100, _, 0.6);
	  		static float anglesB[3];
			GetClientEyeAngles(client, anglesB);
			static float velocity[3];
			GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
			float knockback = 600.0;
			// knockback is the overall force with which you be pushed, don't touch other stuff
			ScaleVector(velocity, knockback);
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	  		{
		  		velocity[2] = fmax(velocity[2], 600.0);
	 		}
			else
	  		{
				velocity[2] += 300.0;	// a little boost to alleviate arcing issues
	  		}
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			CreateTimer(0.2, Timer_SoldineActivation, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
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
void Soldine_Fist_Swing(int client, float &CustomMeleeRange, float &CustomMeleeWide)
{
	CustomMeleeRange = 50.0;
	CustomMeleeWide = 20.0;

	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1 && TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy))
	{
		CustomMeleeRange *= 1.5;
		CustomeMeleeWide *= 1.5;
	}
	else
	{
		CustomMeleeRange = 50.0;
		CustomMeleeWide = 20.0;
	}
}

void SoldineFist_OnTakeDamage(int attacker, float &damage, int weapon, int zr_damage_custom)
{
	if  ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1 && TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy))
	{

		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);

		float BaseDMG = 1000.0;
		BaseDMG *= Attributes_Get(weapon, 2, 1.0);
		BaseDMG *= Attributes_Get(weapon, 1, 1.0);

		float Radius = EXPLOSION_RADIUS;
		Radius *= Attributes_Get(weapon, 99, 1.0);

		float Falloff = Attributes_Get(weapon, 117, 1.0);
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		if(RaidbossIgnoreBuildingsLogic(1))
		{
			BaseDMG *= 1.5;
		}

		float spawnLoc[3];
		Explode_Logic_Custom(BaseDMG, owner, owner, weapon, position, Radius, Falloff);
		EmitAmbientSound(SOUND_MARKET_EXPLOSION, spawnLoc, entity, 70,_, 1.2);
		ParticleEffectAt(position, "hightower_explosion", 1.5);
	}
}

public Action Timer_SoldineActivation(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	//PrintToChatAll("Rapid Hyper Activate");
	EmitSoundToAll(SOUND_JUMP_Activation, client, SNDCHAN_AUTO, 70, _, 1.2);
	TF2_AddCondition(client, TFCond_HalloweenCritCandy);
	FistReady = true;
	return Plugin_Stop;
}

void CreateSoldineEffect(int client)
{
	if(!IsValidEntity(i_VictoriaParticle[client]))
	{
		return;
	}
	DestroySoldineEffect(client);
	if(FistReady)
	{
		TF2_AddCondition(client, TFCond_KingAura);
	   	float flPos[3];
		float flAng[3];
		GetAttachment (client, "effect_hand_r", flPos, flAng);
		int particle = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.0);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(client, particle, "effect_hand_r");
		i_VictoriaParticle[client][0] = EntIndexToEntRef(particle);
	}

}
void DestroySoldineEffect(int client)
{
	int entity = EntRefToEntIndex(i_VictoriaParticle[client]);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	TF2_RemoveCondition(client, TFCond_KingAura);
	i_VictoriaParticle[client] = INVALID_ENT_REFERENCE;
}