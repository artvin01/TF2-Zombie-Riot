#pragma semicolon 1
#pragma newdecls required

static int i_tornado_index[MAXENTITIES+1];
static int i_tornado_wep[MAXENTITIES+1];
static float fl_tornado_dmg[MAXENTITIES+1];
static int g_ProjectileModel;


static int i_RocketsSaved[MAXENTITIES+1];
static int i_RocketsSavedMax[MAXENTITIES+1];

static bool bl_tornado_barrage_mode[MAXPLAYERS+1]={false,...};
static int i_tornado_pap[MAXPLAYERS+1]={0, ...};
static float HudCooldown[MAXPLAYERS+1]={0.0, ...};


#define SOUND_IMPACT_1 					"physics/flesh/flesh_impact_bullet1.wav"	//We hit flesh, we are also kinetic, yes.
#define SOUND_IMPACT_2 					"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_IMPACT_3 					"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_IMPACT_4 					"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_IMPACT_5 					"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_IMPACT_CONCRETE_1			"physics/concrete/concrete_impact_bullet1.wav"//we hit the ground? HOW DARE YOU MISS?
#define SOUND_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

#define ROCKET_EFFICIENCY_MULTI 5
static int g_particleImpactTornado;

public void Weapon_Tornado_Blitz_Precache()
{
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	PrecacheSound(SOUND_IMPACT_CONCRETE_1);
	PrecacheSound(SOUND_IMPACT_CONCRETE_2);
	PrecacheSound(SOUND_IMPACT_CONCRETE_3);
	PrecacheSound(SOUND_IMPACT_CONCRETE_4);
	
	PrecacheSound(SOUND_IMPACT_1);
	PrecacheSound(SOUND_IMPACT_2);
	PrecacheSound(SOUND_IMPACT_3);
	PrecacheSound(SOUND_IMPACT_4);
	PrecacheSound(SOUND_IMPACT_5);
	PrecacheSound(")weapons/doom_rocket_launcher.wav");
	Zero(HudCooldown);
	
	static char model[PLATFORM_MAX_PATH];
	model = "models/weapons/w_bullet.mdl";
	g_ProjectileModel = PrecacheModel(model);
}
float Tornado_WeaponSavedAttribute[MAXPLAYERS+1];
public void Enable_TornadoBlitz(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_TORNADO_BLITZ)
	{
		Tornado_WeaponSavedAttribute[client] = Attributes_Get(weapon, 4014, 0.0);
	}
}
public void Weapon_Tornado_Laucher_M2(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if(bl_tornado_barrage_mode[client])
		{
			bl_tornado_barrage_mode[client]=false;
			Attributes_Set(weapon, 4014, Tornado_WeaponSavedAttribute[client]);
			ClientCommand(client, "playgamesound misc/halloween/spelltick_01.wav");
			PrintHintText(client,"Barrage: OFF\nBarrage Ammo [%i/%i]", i_RocketsSaved[client]/ROCKET_EFFICIENCY_MULTI , i_RocketsSavedMax[client]/ROCKET_EFFICIENCY_MULTI);
		}
		else if (i_RocketsSaved[client] >= ROCKET_EFFICIENCY_MULTI)
		{
			bl_tornado_barrage_mode[client]=true;
			Attributes_Set(weapon, 4014, 0.0);
			ClientCommand(client, "playgamesound misc/halloween/spelltick_02.wav");
			PrintHintText(client,"Barrage: ON\nBarrage Ammo [%i/%i]", i_RocketsSaved[client]/ROCKET_EFFICIENCY_MULTI , i_RocketsSavedMax[client]/ROCKET_EFFICIENCY_MULTI);
		}
	}
}

public void Weapon_tornado_launcher_Spam(int client, int weapon, bool crit, int slot)
{
	i_tornado_pap[client] = 0;
	bl_tornado_barrage_mode[client]=false;
	if(!bl_tornado_barrage_mode[client])
		i_RocketsSaved[client]++;
	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

public void Weapon_tornado_launcher_Spam_Pap1(int client, int weapon, bool crit, int slot)
{
	i_tornado_pap[client] = 0;
	i_RocketsSavedMax[client] = 30;
	bl_tornado_barrage_mode[client]=false;
	if(!bl_tornado_barrage_mode[client])
		i_RocketsSaved[client]++;

	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

public void Weapon_tornado_launcher_Spam_Pap2(int client, int weapon, bool crit, int slot)
{
	i_RocketsSavedMax[client] = 15 * ROCKET_EFFICIENCY_MULTI;
	i_tornado_pap[client]=2;
	if(!bl_tornado_barrage_mode[client])
		i_RocketsSaved[client]++;
	
	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

public void Weapon_tornado_launcher_Spam_Pap3(int client, int weapon, bool crit, int slot)
{
	i_RocketsSavedMax[client] = 20 * ROCKET_EFFICIENCY_MULTI;
	i_tornado_pap[client]=4;
	if(!bl_tornado_barrage_mode[client])
		i_RocketsSaved[client]++;

	Weapon_Tornado_Launcher_Spam_Fire_Rocket(client, weapon);
}

void Weapon_Tornado_Launcher_Spam_Fire_Rocket(int client, int weapon)
{
	if(i_RocketsSaved[client] >= i_RocketsSavedMax[client])
		i_RocketsSaved[client] = i_RocketsSavedMax[client];

	if(weapon >= MaxClients)
	{

		float speedMult = 1250.0;
		float dmgProjectile = 90.0;
		
		
		//note: redo attributes for better customizability
		dmgProjectile *= Attributes_Get(weapon, 1, 1.0);

		dmgProjectile *= Attributes_Get(weapon, 2, 1.0);
				
		speedMult *= Attributes_Get(weapon, 103, 1.0);
		
		speedMult *= Attributes_Get(weapon, 104, 1.0);
		
		speedMult *= Attributes_Get(weapon, 475, 1.0);
			
		float damage=dmgProjectile;
		if(bl_tornado_barrage_mode[client] && i_RocketsSaved[client] >= ROCKET_EFFICIENCY_MULTI)
		{
			i_RocketsSaved[client] -= ROCKET_EFFICIENCY_MULTI;
			EmitSoundToAll(")weapons/doom_rocket_launcher.wav", weapon, SNDCHAN_WEAPON, 75, _, 0.9, 100);
			for(int i=1; i<=i_tornado_pap[client] ;i++)
			{
				BlitzRocket(client, speedMult, damage*0.75, weapon);
			}
		}
		else
		{
			if(bl_tornado_barrage_mode[client])
			{
				bl_tornado_barrage_mode[client] = false;
				ClientCommand(client, "playgamesound misc/halloween/spelltick_01.wav");
			}
			BlitzRocket(client, speedMult, damage, weapon);
		}
		if(i_tornado_pap[client] >= 2)
		{
			if(bl_tornado_barrage_mode[client])
			{
				Attributes_Set(weapon, 4014, 0.0);
				if(HudCooldown[client] < GetGameTime())
				{
					PrintHintText(client,"Barrage: ON\nBarrage Ammo [%i/%i]", i_RocketsSaved[client] /ROCKET_EFFICIENCY_MULTI, i_RocketsSavedMax[client]/ROCKET_EFFICIENCY_MULTI);
					HudCooldown[client] = GetGameTime() + 0.4;
				}
			}
			else
			{
				Attributes_Set(weapon, 4014, Tornado_WeaponSavedAttribute[client]);
				if(HudCooldown[client] < GetGameTime())
				{
					PrintHintText(client,"Barrage: OFF\nBarrage Ammo [%i/%i]", i_RocketsSaved[client] /ROCKET_EFFICIENCY_MULTI, i_RocketsSavedMax[client]/ROCKET_EFFICIENCY_MULTI);
					HudCooldown[client] = GetGameTime() + 0.4;
				}
			}
		}
	}
}

void BlitzRocket(int client, float speed, float damage, int weapon)
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	if(bl_tornado_barrage_mode[client])	//we randomise the barrage so it doesn't become a direct upgrade.
	{
		fAng[0] = fAng[0]+GetRandomFloat(-6.0,6.0);
		fAng[1] = fAng[1]+GetRandomFloat(-6.0,6.0);
		fAng[2] = fAng[2]+GetRandomFloat(-0.25,0.25);
	}


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
		fl_tornado_dmg[entity]=damage;
		i_tornado_wep[entity]=EntIndexToEntRef(weapon);
		i_tornado_index[entity]=EntIndexToEntRef(client);
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		SetTeam(entity, GetTeam(client));
		int frame = GetEntProp(entity, Prop_Send, "m_ubInterpolationFrame");
		TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
		DispatchSpawn(entity);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
		SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", GetGameTime());
		SetEntProp(entity, Prop_Send, "m_ubInterpolationFrame", frame);
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
		}
		float ModelSizeAdd = 2.0;
		if(bl_tornado_barrage_mode[client])	//we make the rocket smaller on barrage mode.
		{
			ModelSizeAdd = 2.0;
		}
		else
		{
			ModelSizeAdd = 3.0;
		}
		if(h_NpcSolidHookType[entity] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[entity]);
		h_NpcSolidHookType[entity] = 0;
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Tornado_RocketExplodePre); //In this case I reused code that was reused due to laziness, I am the ultiamte lazy. *yawn*
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Tornado_Blitz_StartTouch);
		ApplyCustomModelToWandProjectile(entity, "models/weapons/w_bullet.mdl", ModelSizeAdd, "");
	}
	return;
}
public MRESReturn Tornado_RocketExplodePre(int entity)
{
	//CPrintToChatAll("explode pre");
	return MRES_Supercede;
}
public void Tornado_Blitz_StartTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);
		
		int owner = EntRefToEntIndex(i_tornado_index[entity]);
		int weapon = EntRefToEntIndex(i_tornado_wep[entity]);

		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, fl_tornado_dmg[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		
		//CPrintToChatAll("sdk_dmg");
		
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		float pos1[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_ParticleInt(g_particleImpactTornado, pos1);
		TE_SendToAll();
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		RemoveEntity(entity);
	}
	return;
}
