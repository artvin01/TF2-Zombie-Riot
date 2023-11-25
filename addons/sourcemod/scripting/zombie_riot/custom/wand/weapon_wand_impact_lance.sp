#pragma semicolon 1
#pragma newdecls required

static int i_Current_Pap[MAXTF2PLAYERS+1];

#define IMPACT_WAND_PARTICLE_LANCE_BOOM "ambient_mp3/halloween/thunder_04.mp3"
#define IMPACT_WAND_PARTICLE_LANCE_BOOM1 "weapons/air_burster_explode1.wav"
#define IMPACT_WAND_PARTICLE_LANCE_BOOM2 "weapons/air_burster_explode2.wav"
#define IMPACT_WAND_PARTICLE_LANCE_BOOM3 "weapons/air_burster_explode3.wav"


public void Wand_Impact_Lance_Mapstart()
{
	Zero(i_Current_Pap);
	PrecacheSound(IMPACT_WAND_PARTICLE_LANCE_BOOM);
	PrecacheSound(IMPACT_WAND_PARTICLE_LANCE_BOOM1);
	PrecacheSound(IMPACT_WAND_PARTICLE_LANCE_BOOM2);
	PrecacheSound(IMPACT_WAND_PARTICLE_LANCE_BOOM3);
}

public void Wand_Impact_Lance_Multi_Hit(int client, float &CustomMeleeRange, float &CustomMeleeWide)
{
	CustomMeleeRange = 75.0;
	CustomMeleeWide = 10.0;

	switch(i_Current_Pap[client])
	{
		case 0:
		{
			
		}
		case 1:
		{
			CustomMeleeRange +=15.0;
		}
		case 2:
		{
			CustomMeleeRange +=25.0;
			CustomMeleeWide +=2.0;
		}
		case 3:
		{
			CustomMeleeRange +=45.0;
			CustomMeleeWide +=5.0;
		}
	}
}


public void Impact_Lance_M1(int client, int weapon, bool crit)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;

		i_Current_Pap[client] = RoundFloat(Attributes_Get(weapon, 122, 0.0));

		float damage = Attributes_Get(weapon, 410, 1.0);

		ApplyTempAttrib(weapon, 2, damage);

		i_IsWandWeapon[weapon] = false;
		RequestFrame(Impact_Lance_Reset_Wandstate, EntIndexToEntRef(weapon));

	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Impact_Lance_Impact_Driver(int client, int weapon, bool crit, int slot)
{
	int mana_cost = 400;

	if(mana_cost <= Current_Mana[client])
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			
			Handle swingTrace;
			float SpawnLoc[3];
			b_LagCompNPC_No_Layers = true;
			float vecSwingForward[3];
			StartLagCompensation_Base_Boss(client);
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 200.0, false, 45.0, true); //infinite range, and ignore walls!
			FinishLagCompensation_Base_boss();

			int target = TR_GetEntityIndex(swingTrace);	
			TR_GetEndPosition(SpawnLoc, swingTrace);
			delete swingTrace;
			if(!IsValidEnemy(client, target, true))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "No Targets Detected");
				return;
			}

			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 30.0);

			Current_Mana[client]-=mana_cost;
			
			if(!TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
			{
				static float anglesB[3];
				static float velocity[3];
				GetClientEyeAngles(client, anglesB);
				GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
				float knockback = -500.0;
				
				ScaleVector(velocity, knockback);
				if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
					velocity[2] = fmax(velocity[2], 300.0);
				else
					velocity[2] += 100.0; // a little boost to alleviate arcing issues
					
					
				float newVel[3];
				
				newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
				newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
				newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
								
				for (int i = 0; i < 3; i++)
				{
					velocity[i] += newVel[i];
				}
				
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			}

			Client_Shake(client, 0, 50.0, 30.0, 1.25);

			EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM, client, SNDCHAN_STATIC, 90, _, 0.6);
			EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM, client, SNDCHAN_STATIC, 90, _, 0.6);
			switch(GetRandomInt(1,3))
			{
				case 1:
					EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM1, client, SNDCHAN_STATIC, 90, _, 1.0);
				case 2:
					EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM2, client, SNDCHAN_STATIC, 90, _, 1.0);
				case 3:
					EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM3, client, SNDCHAN_STATIC, 90, _, 1.0);
			}

			i_ExplosiveProjectileHexArray[client] = EP_DEALS_CLUB_DAMAGE;
		
			float damage = 500.0;
			
			damage *=Attributes_Get(weapon, 410, 1.0);

			b_LagCompNPC_No_Layers = true;
			StartLagCompensation_Base_Boss(client);
			Explode_Logic_Custom(damage, client, client, weapon, SpawnLoc, 250.0);
			FinishLagCompensation_Base_boss();
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

public void Impact_Lance_Reset_Wandstate(int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if(weapon != -1)
		i_IsWandWeapon[weapon] = true;
}


#define IMPACT_LANCE_EFFECTS 25
static int i_Impact_Lance_CosmeticEffect[MAXENTITIES][IMPACT_LANCE_EFFECTS];

static Handle h_Impact_Lance_CosmeticEffectManagement[MAXPLAYERS+1] = {null, ...};

void Impact_Lance_CosmeticRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<IMPACT_LANCE_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_Impact_Lance_CosmeticEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_Impact_Lance_CosmeticEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}


bool Impact_Lance_CosmeticEffects_IfNotAvaiable(int client)	//warp
{
	int thingsToLoop;
	switch(i_Current_Pap[client])
	{
		case 0:
		{
			thingsToLoop = 12;
		}
		case 1:
		{
			thingsToLoop = 16;
		}
		case 2:
		{
			thingsToLoop = 17;
		}
		case 3:
		{
			thingsToLoop = 24;
		}
	}
	for(int loop = 0; loop<thingsToLoop; loop++)
	{
		int entity = EntRefToEntIndex(i_Impact_Lance_CosmeticEffect[client][loop]);
		if(!IsValidEntity(entity))
		{
			return true;
		}
	}
	return false;
}

void ApplyExtra_Impact_Lance_CosmeticEffects(int client, bool remove = false)
{
	if(remove)
	{
		Impact_Lance_CosmeticRemoveEffects(client);
		return;
	}
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(!IsValidEntity(viewmodelModel))
	{
		Impact_Lance_CosmeticRemoveEffects(client);
		return;
	}

	if(Impact_Lance_CosmeticEffects_IfNotAvaiable(client))
	{
		Impact_Lance_CosmeticRemoveEffects(client);
		Impact_Lance_Effects(client, viewmodelModel, "effect_hand_r");
	}
}


public void Enable_Impact_Lance(int client, int weapon) 
{
	if (h_Impact_Lance_CosmeticEffectManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_IMPACT_LANCE)
		{
			Impact_Lance_CosmeticRemoveEffects(client);
			ApplyExtra_Impact_Lance_CosmeticEffects(client,_);
			//Is the weapon it again?
			//Yes?
			delete h_Impact_Lance_CosmeticEffectManagement[client];
			h_Impact_Lance_CosmeticEffectManagement[client] = null;
			DataPack pack;
			h_Impact_Lance_CosmeticEffectManagement[client] = CreateDataTimer(0.1, Timer_Impact_Lance_Cosmetic, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_IMPACT_LANCE)
	{
		Impact_Lance_CosmeticRemoveEffects(client);
		ApplyExtra_Impact_Lance_CosmeticEffects(client,_);
		DataPack pack;
		h_Impact_Lance_CosmeticEffectManagement[client] = CreateDataTimer(0.1, Timer_Impact_Lance_Cosmetic, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}


public Action Timer_Impact_Lance_Cosmetic(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		ApplyExtra_Impact_Lance_CosmeticEffects(client,true);
		h_Impact_Lance_CosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		ApplyExtra_Impact_Lance_CosmeticEffects(client);
	}
	else
	{
		ApplyExtra_Impact_Lance_CosmeticEffects(client, true);
	}

	return Plugin_Continue;
}
void Impact_Lance_Effects(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	switch(i_Current_Pap[client])
	{
		case 0:
		{
			Impact_Lance_EffectPap0(client, Wearable, attachment);
		}
		case 1:
		{
			Impact_Lance_EffectPap1(client, Wearable, attachment);
		}
		case 2:
		{
			Impact_Lance_EffectPap2(client, Wearable, attachment);
		}
		case 3:
		{
			Impact_Lance_EffectPap3(client, Wearable, attachment);
		}
	}
}

/*
		Fist axies from the POV of the person LOOKINGF at the equipper
		flag

		1st: left and right, negative is left, positive is right 
		2nd: Up and down, negative up, positive down.
		3rd: front and back, negative goes back.
	*/

void Impact_Lance_EffectPap0(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = ParticleEffectAt({0.0, 10.0, 10.0}, "", 0.0); //First offset we go by
	int particle_2_1 = ParticleEffectAt({0.0, 10.0, -10.0}, "", 0.0);

	int particle_3 = ParticleEffectAt({10.0,10.0,0.0}, "", 0.0);
	int particle_3_1 = ParticleEffectAt({-10.0,10.0,0.0}, "", 0.0);

	int particle_4 = ParticleEffectAt({0.0,50.0, 0.0}, "", 0.0);


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(Wearable, particle_1, attachment,_);


	float amp = 0.1;

	float blade_start = 2.0;
	float blade_end = 0.5;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_6 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);

	int Laser_4 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM);
	int Laser_5 = ConnectWithBeamClient(particle_2_1, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM);
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(Laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
}


void Impact_Lance_EffectPap1(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = ParticleEffectAt({0.0, 10.0, 10.0}, "", 0.0); //First offset we go by
	int particle_2_1 = ParticleEffectAt({0.0, 10.0, -10.0}, "", 0.0);

	int particle_3 = ParticleEffectAt({10.0,10.0,0.0}, "", 0.0);
	int particle_3_1 = ParticleEffectAt({-10.0,10.0,0.0}, "", 0.0);

	int particle_4 = ParticleEffectAt({0.0,60.0, 5.0}, "", 0.0);
	int particle_4_1 = ParticleEffectAt({0.0,60.0, -5.0}, "", 0.0);

	int particle_5 = ParticleEffectAt({0.0,-10.0, 0.0}, "", 0.0);


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(Wearable, particle_1, attachment,_);


	float amp = 0.1;

	float blade_start = 2.0;
	float blade_end = 0.5;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_6 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);

	int Laser_4 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM);			//blade
	int Laser_5 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM);		//blade

	int Laser_7 = ConnectWithBeamClient(particle_2, particle_5, red, green, blue, blade_start, blade_end, amp, LASERBEAM);
	int Laser_8 = ConnectWithBeamClient(particle_2_1, particle_5, red, green, blue, blade_start, blade_end, amp, LASERBEAM);
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(Laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(particle_5);
	i_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_7);
	i_Impact_Lance_CosmeticEffect[client][16] = EntIndexToEntRef(Laser_8);
}



void Impact_Lance_EffectPap2(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = ParticleEffectAt({0.0, 10.0, 7.5}, "", 0.0); //First offset we go by
	int particle_2_1 = ParticleEffectAt({0.0, 10.0, -7.5}, "", 0.0);

	int particle_3 = ParticleEffectAt({5.0,10.0,0.0}, "", 0.0);
	int particle_3_1 = ParticleEffectAt({-5.0,10.0,0.0}, "", 0.0);

	int particle_4 = ParticleEffectAt({0.0,70.0,2.5}, "", 0.0);
	int particle_4_1 = ParticleEffectAt({0.0,70.0, -2.5}, "", 0.0);

	int particle_5 = ParticleEffectAt({0.0,-10.0, 5.0}, "", 0.0);
	int particle_5_1 = ParticleEffectAt({0.0,-10.0, -5.0}, "", 0.0);


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	SetParent(particle_1, particle_5_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(Wearable, particle_1, attachment,_);


	float amp = 0.1;

	float blade_start = 2.0;
	float blade_end = 0.5;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_6 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);

	int Laser_4 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM);			//blade
	int Laser_5 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM);		//blade

	int Laser_7 = ConnectWithBeamClient(particle_2, particle_5, red, green, blue, blade_start, blade_end, amp, LASERBEAM);			//inner blade
	int Laser_8 = ConnectWithBeamClient(particle_2_1, particle_5_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM);	//	inner blade
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(Laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(particle_5);
	i_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_7);
	i_Impact_Lance_CosmeticEffect[client][16] = EntIndexToEntRef(Laser_8);
	i_Impact_Lance_CosmeticEffect[client][17] = EntIndexToEntRef(particle_5_1);

}

void Impact_Lance_EffectPap3(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = ParticleEffectAt({0.0, 10.0, 7.5}, "", 0.0); //First offset we go by
	int particle_2_1 = ParticleEffectAt({0.0, 10.0, -7.5}, "", 0.0);

	int particle_3 = ParticleEffectAt({5.0,10.0,0.0}, "", 0.0);
	int particle_3_1 = ParticleEffectAt({-5.0,10.0,0.0}, "", 0.0);

	int particle_4 = ParticleEffectAt({0.0,70.0,2.5}, "", 0.0);
	int particle_4_1 = ParticleEffectAt({0.0,70.0, -2.5}, "", 0.0);

	int particle_5 = ParticleEffectAt({0.0,-10.0, 5.0}, "", 0.0);
	int particle_5_1 = ParticleEffectAt({0.0,-10.0, -5.0}, "", 0.0);

	int particle_6 = ParticleEffectAt({12.0,-5.0, 0.0}, "", 0.0);
	int particle_6_1 = ParticleEffectAt({-12.0,-5.0, 0.0}, "", 0.0);

	int particle_7 = ParticleEffectAt({0.0,-10.0, 0.0}, "", 0.0);


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	SetParent(particle_1, particle_5_1, "",_, true);
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_1, particle_6_1, "",_, true);
	SetParent(particle_1, particle_7, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(Wearable, particle_1, attachment,_);


	float amp = 0.1;

	float blade_start = 2.0;
	float blade_end = 0.5;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_6 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);

	int Laser_4 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM);			//blade
	int Laser_5 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM);		//blade

	int Laser_7 = ConnectWithBeamClient(particle_2, particle_5, red, green, blue, blade_start, blade_end, amp, LASERBEAM);			//inner blade
	int Laser_8 = ConnectWithBeamClient(particle_2_1, particle_5_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM);	//	inner blade

	int Laser_9 = ConnectWithBeamClient(particle_6, particle_3, red, green, blue, blade_end, handguard_size, amp, LASERBEAM);			//wing start
	int Laser_10 = ConnectWithBeamClient(particle_6_1, particle_3_1, red, green, blue, blade_end, handguard_size, amp, LASERBEAM);		//wing start
	int Laser_11 = ConnectWithBeamClient(particle_6, particle_7, red, green, blue, blade_end, blade_start, amp, LASERBEAM);			//wing end
	int Laser_12 = ConnectWithBeamClient(particle_6_1, particle_7, red, green, blue, blade_end, blade_start, amp, LASERBEAM);			//wing end
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(Laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(particle_5);
	i_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_7);
	i_Impact_Lance_CosmeticEffect[client][16] = EntIndexToEntRef(Laser_8);
	i_Impact_Lance_CosmeticEffect[client][17] = EntIndexToEntRef(particle_5_1);
	i_Impact_Lance_CosmeticEffect[client][18] = EntIndexToEntRef(Laser_9);
	i_Impact_Lance_CosmeticEffect[client][19] = EntIndexToEntRef(Laser_10);
	i_Impact_Lance_CosmeticEffect[client][20] = EntIndexToEntRef(Laser_11);
	i_Impact_Lance_CosmeticEffect[client][21] = EntIndexToEntRef(Laser_12);
	i_Impact_Lance_CosmeticEffect[client][22] = EntIndexToEntRef(particle_7);
	i_Impact_Lance_CosmeticEffect[client][23] = EntIndexToEntRef(particle_6);
	i_Impact_Lance_CosmeticEffect[client][24] = EntIndexToEntRef(particle_6_1);

}


