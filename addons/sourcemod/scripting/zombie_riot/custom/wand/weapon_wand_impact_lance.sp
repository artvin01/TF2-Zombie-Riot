#pragma semicolon 1
#pragma newdecls required

static int i_Current_Pap[MAXPLAYERS+1];
static float fl_thorwn_lance[MAXPLAYERS+1];
static float f_projectile_dmg[MAXENTITIES];
static int i_Impact_Lance_index[MAXENTITIES+1];
static int i_Impact_Lance_wep[MAXENTITIES+1];
static int i_current_pap_projectile[MAXENTITIES];


#define IMPACT_WAND_PARTICLE_LANCE_BOOM "ambient_mp3/halloween/thunder_04.mp3"
#define IMPACT_WAND_PARTICLE_LANCE_BOOM1 "weapons/air_burster_explode1.wav"
#define IMPACT_WAND_PARTICLE_LANCE_BOOM2 "weapons/air_burster_explode2.wav"
#define IMPACT_WAND_PARTICLE_LANCE_BOOM3 "weapons/air_burster_explode3.wav"

static char gExplosive1;

public void Wand_Impact_Lance_Mapstart()
{
	Zero(i_Current_Pap);
	Zero(fl_thorwn_lance);
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
		case 0:	//baseline pap 0
		{
			
		}
		case 1:	//normal pap 1
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

		case 4:	//alt pap 1
		{
			CustomMeleeRange +=7.5;
		}
		case 5:
		{
			CustomMeleeRange +=15.0;
			CustomMeleeWide +=5.0;
		}
		case 6:
		{
			CustomMeleeRange +=25.0;
			CustomMeleeWide +=15.0;
		}
	}
}

void LanceDamageCalc(int client, int weapon, float &damage, bool checkvalidity = false)
{
	float GameTime = GetGameTime();
	if(fl_thorwn_lance[client]>GameTime)
	{
		damage = 0.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Lance is not ready!");
		return;
	}
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	mana_cost = RoundToNearest(float(mana_cost) * LaserWeapons_ReturnManaCost(weapon));
	if(mana_cost <= Current_Mana[client])
	{
		if(!checkvalidity)
		{
			SDKhooks_SetManaRegenDelayTime(client, 1.5);
			Mana_Hud_Delay[client] = 0.0;
			
			Current_Mana[client] -= mana_cost;
			
			delay_hud[client] = 0.0;

			i_Current_Pap[client] = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
			damage *= Attributes_Get(weapon, 410, 1.0);
		}
	}
	else
	{
		damage = 0.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Impact_Lance_Impact_Driver(int client, int weapon, bool crit, int slot)
{
	float GameTime = GetGameTime();
	if(fl_thorwn_lance[client]>GameTime)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Lance is not ready!");
		return;
	}

	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	mana_cost = RoundToFloor(mana_cost*4.0);

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

			int target = TR_GetEntityIndex(swingTrace);	
			TR_GetEndPosition(SpawnLoc, swingTrace);
			delete swingTrace;
			if(!IsValidEnemy(client, target, true))
			{
				FinishLagCompensation_Base_boss();
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "No Targets Detected");
				return;
			}

			Rogue_OnAbilityUse(client, weapon);
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

			TE_Particle("asplode_hoodoo", SpawnLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

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
		
			float damage = 200.0;
			
			damage *= Attributes_Get(weapon, 410, 1.0);

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

public void Impact_Lance_Throw_Lance(int client, int weapon, bool crit, int slot)
{
	float GameTime = GetGameTime();
	if(fl_thorwn_lance[client]>GameTime)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Lance is not ready!");
		return;
	}
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	mana_cost = RoundToFloor(mana_cost*3.0);

	if(mana_cost <= Current_Mana[client])
	{

		if (Ability_Check_Cooldown(client, slot) > 0.0)
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			return;
		}
		SDKhooks_SetManaRegenDelayTime(client, 2.5);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;

		Rogue_OnAbilityUse(client, weapon);
		Ability_Apply_Cooldown(client, slot, 5.0);

		float speed = 1250.0;
		float damage = 65.0;
		
		
		damage *=Attributes_Get(weapon, 410, 1.0);
				
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);

		Throw_Lance(client, speed, damage, weapon);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

static void Throw_Lance(int client, float speed, float damage, int weapon)
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);

	float tmp[3];
	float actualBeamOffset[3];
	float BEAM_BeamOffset[3];
	BEAM_BeamOffset[0] = 0.0;
	BEAM_BeamOffset[1] = -8.0;
	BEAM_BeamOffset[2] = -10.0;

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(tmp, fAng, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	fPos[0] += actualBeamOffset[0];
	fPos[1] += actualBeamOffset[1];
	fPos[2] += actualBeamOffset[2];


	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	int entity = CreateEntityByName("zr_projectile_base");
	if(IsValidEntity(entity))
	{
		
		i_current_pap_projectile[entity] = i_Current_Pap[client];
		f_projectile_dmg[entity] = damage;
		
		i_Impact_Lance_wep[entity]= EntIndexToEntRef(weapon);
		i_Impact_Lance_index[entity]= EntIndexToEntRef(client);
		
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetTeam(entity, GetTeam(client));
		TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
		DispatchSpawn(entity);
		int particle = 0;

		particle = ParticleEffectAt(fPos, "raygun_projectile_blue", 0.0); //Inf duartion
		i_rocket_particle[entity]= EntIndexToEntRef(particle);
		TeleportEntity(particle, NULL_VECTOR, fAng, NULL_VECTOR);
		SetParent(entity, particle);	
		SetEntityRenderMode(entity, RENDER_NONE); //Make it entirely invis.
		SetEntityRenderColor(entity, 255, 255, 255, 0);

		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
		
		for(int i; i<4; i++) //This will make it so it doesnt override its collision box.
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_rocket_particle, _, i);
		}
		SetEntityModel(entity, PARTICLE_ROCKET_MODEL);
	
		//Make it entirely invis. Shouldnt even render these 8 polygons.
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);

		DataPack pack;
		CreateDataTimer(10.0, Timer_RemoveEntity_Impact_Lance_Projectile, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(EntIndexToEntRef(particle));

		if(h_NpcSolidHookType[entity] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[entity]);
		h_NpcSolidHookType[entity] = 0;

		h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Impact_Lance_RocketExplodePre); 
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Impact_Lance_StartTouch);
		Impact_Lance_Effects_Projectile(client, entity);
		/*
		if(!Items_HasNamedItem(client, "Alaxios's Godly assistance"))
		{

			DataPack pack2;
			CreateDataTimer(0.0, Impact_Lance_Timer_Update, pack2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack2.WriteCell(EntIndexToEntRef(client));
			pack2.WriteCell(EntIndexToEntRef(entity));
		}
		*/
	}
	return;
}

public Action Impact_Lance_Timer_Update(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int Entity = EntRefToEntIndex(pack.ReadCell());
	if (IsValidEntity(Entity) && IsValidClient(client))
	{
		fl_thorwn_lance[client] = GetGameTime()+2.0;
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public MRESReturn Impact_Lance_RocketExplodePre(int entity)
{
	return MRES_Supercede;	//Do. Not.
}

public Action Impact_Lance_StartTouch(int entity, int other)
{
	int client = EntRefToEntIndex(i_Impact_Lance_index[entity]);
	int weapon = EntRefToEntIndex(i_Impact_Lance_wep[entity]);

	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);

	pos1[2]+=25.0;

	i_ExplosiveProjectileHexArray[client] = EP_DEALS_CLUB_DAMAGE;

	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	Explode_Logic_Custom(f_projectile_dmg[entity], client, client, weapon, pos1, 250.0);
	FinishLagCompensation_Base_boss();

	pos1[2]-=30.0;

	TE_SetupExplosion(pos1, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();

	//spawnRing_Vectors(pos1, 250.0 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.75, 6.0, 0.1, 1, 1.0);
	switch(GetRandomInt(1,3))
	{
		case 1:
			EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM1, client, SNDCHAN_STATIC, 90, _, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos1);
		case 2:
			EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM2, client, SNDCHAN_STATIC, 90, _, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos1);
		case 3:
			EmitSoundToAll(IMPACT_WAND_PARTICLE_LANCE_BOOM3, client, SNDCHAN_STATIC, 90, _, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos1);
	}
	int particle = EntRefToEntIndex(i_rocket_particle[entity]);

	Impact_Lance_CosmeticRemoveEffects_Projectile(entity);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	RemoveEntity(entity);

	return Plugin_Handled;
}
public Action Timer_RemoveEntity_Impact_Lance_Projectile(Handle timer, DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Particle = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile))
	{
		RemoveEntity(Projectile);
		Impact_Lance_CosmeticRemoveEffects_Projectile(Projectile);
	}
	if(IsValidEntity(Particle))
	{
		RemoveEntity(Particle);
	}
	return Plugin_Stop; 
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
		case 4:
		{
			thingsToLoop = 14;
		}
		case 5:
		{
			thingsToLoop = 16;
		}
		case 6:
		{
			thingsToLoop = 22;
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

	if(AtEdictLimit(EDICT_PLAYER))
		return;
		
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
			i_Current_Pap[client] = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));

		//	Impact_Lance_CosmeticRemoveEffects(client);
		//	ApplyExtra_Impact_Lance_CosmeticEffects(client,_);
			//Is the weapon it again?
			//Yes?
			delete h_Impact_Lance_CosmeticEffectManagement[client];
			h_Impact_Lance_CosmeticEffectManagement[client] = null;
			if(i_Current_Pap[client]<4)
			{
				//CPrintToChatAll("Voided lance");
				return;
			}
			DataPack pack;
			h_Impact_Lance_CosmeticEffectManagement[client] = CreateDataTimer(0.1, Timer_Impact_Lance_Cosmetic, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_IMPACT_LANCE)
	{
		i_Current_Pap[client] = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
		if(i_Current_Pap[client]<4)
		{
			//CPrintToChatAll("Voided lance");
			return;
		}
	//	Impact_Lance_CosmeticRemoveEffects(client);
	//	ApplyExtra_Impact_Lance_CosmeticEffects(client,_);
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
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		ApplyExtra_Impact_Lance_CosmeticEffects(client,true);
		h_Impact_Lance_CosmeticEffectManagement[client] = null;
		return Plugin_Stop;
	}

	float GameTime = GetGameTime();
	if(fl_thorwn_lance[client]>GameTime)
	{
		ApplyExtra_Impact_Lance_CosmeticEffects(client, true);
	}
	else
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			ApplyExtra_Impact_Lance_CosmeticEffects(client);
		}
		else
		{
			ApplyExtra_Impact_Lance_CosmeticEffects(client, true);
		}
	}

	return Plugin_Continue;
}
void Impact_Lance_Effects(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	//CPrintToChatAll("Created Lance");
	switch(i_Current_Pap[client])
	{
		case 4:
		{	// 14
			Impact_Lance_EffectPap4(client, Wearable, attachment);
		}
		case 5:
		{	// 16
			Impact_Lance_EffectPap5(client, Wearable, attachment);
		}
		case 6:
		{	// 22
			Impact_Lance_EffectPap6(client, Wearable, attachment);
		}
	}
}
void Impact_Lance_Effects_Projectile(int client, int entity)
{
	float flAng[3];
	GetClientEyeAngles(client, flAng);

	flAng[1]-=90.0;
	flAng[2]=flAng[0]; flAng[0]=0.0;
	flAng[2] *=-1;
	switch(i_current_pap_projectile[entity])
	{
		case 4:
		{
			Impact_Lance_EffectPap_proj_1(entity, flAng);
		}
		case 5:
		{
			Impact_Lance_EffectPap_proj_2(entity, flAng);
		}
		case 6:
		{
			Impact_Lance_EffectPap_proj_3(entity, flAng);
		}
		default:
		{
			Impact_Lance_EffectPap_proj_0(entity, flAng);
		}
	}
}
void Impact_Lance_CosmeticRemoveEffects_Projectile(int iNpc)
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

/*
		Fist axies from the POV of the person LOOKINGF at the equipper
		flag

		1st: left and right, negative is left, positive is right 
		2nd: Up and down, negative up, positive down.
		3rd: front and back, negative goes back.
	*/

void Impact_Lance_EffectPap_proj_0(int client, float flAng[3])
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];

	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);

	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 10.0}, "", 0.0); //First offset we go by
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -10.0}, "", 0.0);

	int particle_3 = InfoTargetParentAt({10.0,10.0,0.0}, "", 0.0);
	int particle_3_1 = InfoTargetParentAt({-10.0,10.0,0.0}, "", 0.0);

	int particle_4 = InfoTargetParentAt({0.0,50.0, 0.0}, "", 0.0);


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_1, "",_);


	float amp = 0.1;

	float blade_start = 2.0;
	float blade_end = 0.5;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_6 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );

	int Laser_4 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM );
	int Laser_5 = ConnectWithBeamClient(particle_2_1, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM );
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(Laser_5);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(Laser_6);
}


void Impact_Lance_EffectPap_proj_1(int client, float flAng[3])
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];

	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);

	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

		/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 10.0}, "", 0.0); 	//top
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -10.0}, "", 0.0);	//bottom

	int particle_3 = InfoTargetParentAt({10.0,10.0,0.0}, "", 0.0);			//Left
	int particle_3_1 = InfoTargetParentAt({-10.0,10.0,0.0}, "", 0.0);			//Right

	int particle_4 = InfoTargetParentAt({0.0,50.0, 0.0}, "", 0.0);			//front
	int particle_4_1 = InfoTargetParentAt({0.0,-25.0, 0.0}, "", 0.0);			//front-mid


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_1, "",_);


	float amp = 0.01;

	float blade_start = 2.0;
	float blade_end = 0.25;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_4 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);

	int laser_5 = ConnectWithBeamClient(particle_4, particle_4_1, red, green, blue, blade_end, blade_start, amp, LASERBEAM);	//core blade

	int Laser_6 = ConnectWithBeamClient(particle_2, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM);		//blade to handguard
	int Laser_7 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM);
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(Laser_7);
}



void Impact_Lance_EffectPap_proj_2(int client, float flAng[3])
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];

	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 10.0}, "", 0.0); 	//top
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -10.0}, "", 0.0);	//bottom

	int particle_3 = InfoTargetParentAt({10.0,10.0,0.0}, "", 0.0);			//Left
	int particle_3_1 = InfoTargetParentAt({-10.0,10.0,0.0}, "", 0.0);			//Right

	int particle_4 = InfoTargetParentAt({0.0,50.0, 0.0}, "", 0.0);			//front
	int particle_4_1 = InfoTargetParentAt({0.0,-25.0, 0.0}, "", 0.0);			//front-mid


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_1, "",_);


	float amp = 0.01;

	float blade_start = 2.0;
	float blade_end = 0.25;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_4 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );

	int laser_5 = ConnectWithBeamClient(particle_4, particle_4_1, red, green, blue, blade_end, blade_start, amp, LASERBEAM );	//core blade

	int Laser_6 = ConnectWithBeamClient(particle_2, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM );		//core blade to handguard
	int Laser_7 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM );

	int Laser_8 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM );		//blade edge to handguard
	int Laser_9 = ConnectWithBeamClient(particle_3_1, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM );
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(Laser_7);
	i_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(Laser_8);
	i_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_9);

}

void Impact_Lance_EffectPap_proj_3(int client, float flAng[3])
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];

	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 5.0}, "", 0.0); 	//top
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -5.0}, "", 0.0);	//bottom

	int particle_3 = InfoTargetParentAt({10.0,25.0,0.0}, "", 0.0);			//Left
	int particle_3_1 = InfoTargetParentAt({-10.0,25.0,0.0}, "", 0.0);			//Right

	int particle_4 = InfoTargetParentAt({0.0,50.0, 0.0}, "", 0.0);			//front
	int particle_4_1 = InfoTargetParentAt({0.0,-25.0, 0.0}, "", 0.0);			//front-mid

	int particle_5 = InfoTargetParentAt({15.0,30.0,0.0}, "", 0.0);			//Left
	int particle_5_1 = InfoTargetParentAt({-15.0,30.0,0.0}, "", 0.0);			//Right


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
	SetParent(client, particle_1, "",_);


	float amp = 0.01;

	float blade_start = 2.0;
	float blade_end = 0.25;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );
	int Laser_4 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM );

	int laser_5 = ConnectWithBeamClient(particle_4, particle_4_1, red, green, blue, blade_end, blade_start, amp, LASERBEAM );	//core blade

	int Laser_6 = ConnectWithBeamClient(particle_2, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM );		//core blade to handguard
	int Laser_7 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM );

	int Laser_8 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM );		//blade edge to handguard
	int Laser_9 = ConnectWithBeamClient(particle_3_1, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM );

	int Laser_10 = ConnectWithBeamClient(particle_5, particle_3, red, green, blue, handguard_size, handguard_size, amp, LASERBEAM );
	int Laser_11 = ConnectWithBeamClient(particle_5_1, particle_3_1, red, green, blue, handguard_size, handguard_size, amp, LASERBEAM );

	int Laser_12 = ConnectWithBeamClient(particle_5, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM );
	int Laser_13 = ConnectWithBeamClient(particle_5_1, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM );

	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(Laser_7);
	i_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(Laser_8);
	i_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_9);
	i_Impact_Lance_CosmeticEffect[client][16] = EntIndexToEntRef(Laser_10);
	i_Impact_Lance_CosmeticEffect[client][17] = EntIndexToEntRef(Laser_11);
	i_Impact_Lance_CosmeticEffect[client][18] = EntIndexToEntRef(particle_5);
	i_Impact_Lance_CosmeticEffect[client][19] = EntIndexToEntRef(particle_5_1);
	i_Impact_Lance_CosmeticEffect[client][20] = EntIndexToEntRef(Laser_12);
	i_Impact_Lance_CosmeticEffect[client][21] = EntIndexToEntRef(Laser_13);

}

void Impact_Lance_EffectPap4(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 10.0}, "", 0.0); 	//top
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -10.0}, "", 0.0);	//bottom

	int particle_3 = InfoTargetParentAt({10.0,10.0,0.0}, "", 0.0);			//Left
	int particle_3_1 = InfoTargetParentAt({-10.0,10.0,0.0}, "", 0.0);			//Right

	int particle_4 = InfoTargetParentAt({0.0,50.0, 0.0}, "", 0.0);			//front
	int particle_4_1 = InfoTargetParentAt({0.0,-25.0, 0.0}, "", 0.0);			//front-mid


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(Wearable, particle_1, attachment,_);


	float amp = 0.01;

	float blade_start = 2.0;
	float blade_end = 0.25;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_4 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);

	int laser_5 = ConnectWithBeamClient(particle_4, particle_4_1, red, green, blue, blade_end, blade_start, amp, LASERBEAM ,client);	//core blade

	int Laser_6 = ConnectWithBeamClient(particle_2, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM ,client);		//blade to handguard
	int Laser_7 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM ,client);
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(Laser_7);
}


void Impact_Lance_EffectPap5(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 10.0}, "", 0.0); 	//top
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -10.0}, "", 0.0);	//bottom

	int particle_3 = InfoTargetParentAt({10.0,10.0,0.0}, "", 0.0);			//Left
	int particle_3_1 = InfoTargetParentAt({-10.0,10.0,0.0}, "", 0.0);			//Right

	int particle_4 = InfoTargetParentAt({0.0,50.0, 0.0}, "", 0.0);			//front
	int particle_4_1 = InfoTargetParentAt({0.0,-25.0, 0.0}, "", 0.0);			//front-mid


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(Wearable, particle_1, attachment,_);


	float amp = 0.01;

	float blade_start = 2.0;
	float blade_end = 0.25;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_4 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);

	int laser_5 = ConnectWithBeamClient(particle_4, particle_4_1, red, green, blue, blade_end, blade_start, amp, LASERBEAM ,client);	//core blade

	int Laser_6 = ConnectWithBeamClient(particle_2, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM ,client);		//core blade to handguard
	int Laser_7 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM ,client);

	int Laser_8 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM ,client);		//blade edge to handguard
	int Laser_9 = ConnectWithBeamClient(particle_3_1, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM ,client);
	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(Laser_7);
	i_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(Laser_8);
	i_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_9);
}



void Impact_Lance_EffectPap6(int client, int Wearable, char[] attachment = "effect_hand_r")
{
	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 t
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 5.0}, "", 0.0); 	//top
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -5.0}, "", 0.0);	//bottom

	int particle_3 = InfoTargetParentAt({10.0,25.0,0.0}, "", 0.0);			//Left
	int particle_3_1 = InfoTargetParentAt({-10.0,25.0,0.0}, "", 0.0);			//Right

	int particle_4 = InfoTargetParentAt({0.0,50.0, 0.0}, "", 0.0);			//front
	int particle_4_1 = InfoTargetParentAt({0.0,-25.0, 0.0}, "", 0.0);			//front-mid

	int particle_5 = InfoTargetParentAt({15.0,30.0,0.0}, "", 0.0);			//Left
	int particle_5_1 = InfoTargetParentAt({-15.0,30.0,0.0}, "", 0.0);			//Right


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


	float amp = 0.01;

	float blade_start = 2.0;
	float blade_end = 0.25;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);
	int Laser_4 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM ,client);

	int laser_5 = ConnectWithBeamClient(particle_4, particle_4_1, red, green, blue, blade_end, blade_start, amp, LASERBEAM ,client);	//core blade

	int Laser_6 = ConnectWithBeamClient(particle_2, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM ,client);		//core blade to handguard
	int Laser_7 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, handguard_size, blade_start, amp, LASERBEAM ,client);

	int Laser_8 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM ,client);		//blade edge to handguard
	int Laser_9 = ConnectWithBeamClient(particle_3_1, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM ,client);

	int Laser_10 = ConnectWithBeamClient(particle_5, particle_3, red, green, blue, handguard_size, handguard_size, amp, LASERBEAM ,client);
	int Laser_11 = ConnectWithBeamClient(particle_5_1, particle_3_1, red, green, blue, handguard_size, handguard_size, amp, LASERBEAM ,client);

	int Laser_12 = ConnectWithBeamClient(particle_5, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM ,client);
	int Laser_13 = ConnectWithBeamClient(particle_5_1, particle_4, red, green, blue, handguard_size, blade_end, amp, LASERBEAM ,client);

	

	i_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(particle_4_1);
	i_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(laser_5);
	i_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(Laser_6);
	i_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(Laser_7);
	i_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(Laser_8);
	i_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_9);
	i_Impact_Lance_CosmeticEffect[client][16] = EntIndexToEntRef(Laser_10);
	i_Impact_Lance_CosmeticEffect[client][17] = EntIndexToEntRef(Laser_11);
	i_Impact_Lance_CosmeticEffect[client][18] = EntIndexToEntRef(particle_5);
	i_Impact_Lance_CosmeticEffect[client][19] = EntIndexToEntRef(particle_5_1);
	i_Impact_Lance_CosmeticEffect[client][20] = EntIndexToEntRef(Laser_12);
	i_Impact_Lance_CosmeticEffect[client][21] = EntIndexToEntRef(Laser_13);

}