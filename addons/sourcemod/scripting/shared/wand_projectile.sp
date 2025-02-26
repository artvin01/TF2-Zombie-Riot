#pragma semicolon 1
#pragma newdecls required

#if defined ZR || defined RPG
static int i_ProjectileIndex;
Function func_WandOnTouch[MAXENTITIES];

void WandStocks_Map_Precache()
{
	i_ProjectileIndex = PrecacheModel(ENERGY_BALL_MODEL);
}

stock void WandProjectile_ApplyFunctionToEntity(int projectile, Function Function)
{
	func_WandOnTouch[projectile] = Function;
}
#endif

int iref_PropAppliedToRocket[MAXENTITIES];
//todo:
//Redo entirely, these projectiles are invis once
// spawning for some god knows what reason that pisses me the fuck off.
//somehow make another projectile.
//for now, we set another model and parent this beacuse fuck this shit.

void WandProjectile_GamedataInit()
{
	CEntityFactory EntityFactory = new CEntityFactory("zr_projectile_base", OnCreate_Proj, OnDestroy_Proj);
	EntityFactory.DeriveFromClass("tf_projectile_rocket");
	EntityFactory.BeginDataMapDesc()
	.EndDataMapDesc(); 

	EntityFactory.Install();
}

#if defined ZR || defined RPG
stock int Wand_Projectile_Spawn(int client,
float speed,
float time,
float damage,
int WandId,
int weapon,
const char[] WandParticle,
float CustomAng[3] = {0.0,0.0,0.0},
bool hideprojectile = true,
float CustomPos[3] = {0.0,0.0,0.0}) //This will handle just the spawning, the rest like particle effects should be handled within the plugins themselves. hopefully.
{
	float fAng[3], fPos[3];
	if(client <= MaxClients)
	{
		GetClientEyeAngles(client, fAng);
		GetClientEyePosition(client, fPos);
	}

	if(CustomAng[0] != 0.0 || CustomAng[1] != 0.0)
	{
		fAng[0] = CustomAng[0];
		fAng[1] = CustomAng[1];
		fAng[2] = CustomAng[2];
	}
	if(CustomPos[0] != 0.0 || CustomPos[1] != 0.0)
	{
		fPos[0] = CustomPos[0];
		fPos[1] = CustomPos[1];
		fPos[2] = CustomPos[2];
	}

	if(speed >= 3000.0)
	{
		speed = 3000.0;
		//if its too fast, then it can cause projectile devietion
	}

	if(client <= MaxClients && CustomPos[0] == 0.0 && CustomPos[1] == 0.0)
	{
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
	}


	float fVel[3], fBuf[3];
	GetAngleVectors(fAng, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;

	int entity = CreateEntityByName("zr_projectile_base");
	if(IsValidEntity(entity))
	{
		i_WandOwner[entity] = EntIndexToEntRef(client);
		if(IsValidEntity(weapon))
			i_WandWeapon[entity] = EntIndexToEntRef(weapon);
			
		f_WandDamage[entity] = damage;
		i_WandIdNumber[entity] = WandId;
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		//Edit: Need owner entity, otheriwse you can actuall hit your own god damn rocket and make a ding sound. (Really annoying.)
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage should be nothing. if it somehow goes boom.
		SetTeam(entity, GetTeam(client));
		int frame = GetEntProp(entity, Prop_Send, "m_ubInterpolationFrame");
		TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
		DispatchSpawn(entity);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
		SetEntPropVector(entity, Prop_Send, "m_angRotation", fAng); //set it so it can be used
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", fVel);
	//	SetEntProp(entity, Prop_Send, "m_flDestroyableTime", GetGameTime());
		//make rockets visible on spawn.
		SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", GetGameTime());
		SetEntProp(entity, Prop_Send, "m_ubInterpolationFrame", frame);
		
		SetEntityCollisionGroup(entity, 27);
		for(int i; i<4; i++) //This will make it so it doesnt override its collision box.
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", i_ProjectileIndex, _, i);
		}
		SetEntityModel(entity, ENERGY_BALL_MODEL);

		//Make it entirely invis. Shouldnt even render these 8 polygons.
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
		if(hideprojectile)
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); //Make it entirely invis.
			SetEntityRenderColor(entity, 255, 255, 255, 0);
		}
		
		int particle = 0;

		if(WandParticle[0]) //If it has something, put it in. usually it has one, but incase its invis for some odd reason, allow it to be that.
		{
			particle = ParticleEffectAt(fPos, WandParticle, 0.0); //Inf duartion
			TeleportEntity(particle, NULL_VECTOR, fAng, NULL_VECTOR);
			SetParent(entity, particle);	
			SetEntityCollisionGroup(particle, 27);
			i_WandParticle[entity] = EntIndexToEntRef(particle);
		}

		if(time > 60.0)
		{
			time = 60.0;
		}
#if defined RPG
		//average is 10.
		if(time < 0.1)
		{
			time = 10.0;
		}
#endif
		if(time > 0.1) //Make it vanish if there is no time set, or if its too big of a timer to not even bother.
		{
			DataPack pack;
			CreateDataTimer(time, Timer_RemoveEntity_CustomProjectileWand, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(EntIndexToEntRef(particle));
		}
		//so they dont get stuck on entities in the air.
		//todo: Fix them
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID | FSOLID_TRIGGER); 

		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Wand_DHook_RocketExplodePre); //im lazy so ill reuse stuff that already works *yawn*
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Wand_Base_StartTouch);

		return entity;
	}

	//Somehow failed...
	return -1;
}
#endif

public MRESReturn Wand_DHook_RocketExplodePre(int arrow)
{
	return MRES_Supercede; //DONT.
}

public Action Timer_RemoveEntity_CustomProjectileWand(Handle timer, DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Particle = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile) && Projectile>MaxClients)
	{
		RemoveEntity(Projectile);
	}
	if(IsValidEntity(Particle) && Particle>MaxClients)
	{
		RemoveEntity(Particle);
	}
	return Plugin_Stop; 
}

#if defined ZR || defined RPG
public void Wand_Base_StartTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	Function func = func_WandOnTouch[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_PushCell(target);
		Call_Finish();
		//todo: convert all on death and on take damage to this.
		return;
	}
#if defined ZR
	//OLD CODE!!! DONT USE BELOW!!!
	//USE WandProjectile_ApplyFunctionToEntity
	switch(i_WandIdNumber[entity])
	{
		case 0:
		{
			return; //This was has its own entire logic, dont do anything.
		}
		case 1:
		{
			Want_DefaultWandTouch(entity, target);
		}	
		case 2:
		{
			Want_LightningTouch(entity, target);
		}
		case 3:
		{
			Want_NecroTouch(entity, target);
		}
		case 4:
		{
			Want_FireWandTouch(entity, target);
		}
		case 5:
		{
			Want_HomingWandTouch(entity, target);
		}
		case 6:
		{
			Want_ElementalWandTouch(entity, target);
		}
		case 7:
		{
			Gun_NailgunTouch(entity, target);
		}
		case 8:
		{
			Gun_QuantumTouch(entity, target);
		}
		case 9:
		{
			Gun_ChlorophiteTouch(entity, target);
		}
		case 10:
		{
			Want_CalciumWandTouch(entity, target);
		}
		case WEAPON_LAPPLAND:
		{
			Melee_LapplandArkTouch(entity, target);
		}
		case 15:
		{
			Event_Ark_OnHatTouch(entity, target);
		}
		case 17: //Staff of the Skull Servants auto-fire projectiles.
		{
			Wand_Skulls_Touch(entity, target);
		}
		case 18: //Staff of the Skull Servants launched skull.
		{
			Wand_Skulls_Touch_Launched(entity, target);
		}
		case 19: //Health Hose particle
		{
			Hose_Touch(entity, target);
		}
		case 20: //Vampire Knives thrown knife
		{
			Vamp_Knife_Touch(entity, target);
		}
		case 21: //Vampire Knives thrown cleaver
		{
			Vamp_CleaverHit(entity, target);
		}
		case 23:
		{
			Event_GB_OnHatTouch(entity, target);
		}
		case WEAPON_LANTEAN:
		{
			lantean_Wand_Touch(entity, target);
		}
		case 11:
		{
			Cryo_Touch(entity, target);
		}
		case WEAPON_GLADIIA:
		{
			Gladiia_WandTouch(entity, target);
		}
		case WEAPON_GERMAN:
		{
			Weapon_German_WandTouch(entity, target);
		}
		case WEAPON_LUDO:
		{
			Weapon_Ludo_WandTouch(entity, target);
		}
		case WEAPON_SENSAL_SCYTHE:
		{
			Weapon_Sensal_WandTouch(entity, target);
		}
		case WEAPON_KIT_BLITZKRIEG_CORE:
		{
			Blitzkrieg_Kit_Rocket_StartTouch(entity, target);
		}
		case WEAPON_QUIBAI:
		{
			Melee_QuibaiArkTouch(entity, target);
		}
		case WEAPON_STAR_SHOOTER:
		{
			SuperStarShooterOnHit(entity, target);
		}
		case WEAPON_HEAVY_PARTICLE_RIFLE:
		{
			Weapon_Heavy_Particle_Rifle(entity, target);
		}
		case WEAPON_KAHMLFIST:
		{
			Melee_KahmlFistTouch(entity, target);
		}
		case WEAPON_MESSENGER_LAUNCHER:
		{
			Gun_MessengerTouch(entity, target);
		}
		case WEAPON_MAGNESIS:
		{
			Magnesis_ProjectileTouch(entity, target);
		}
		case WEAPON_LOGOS:
		{
			Weapon_Logos_ProjectileTouch(entity, target);
		}
		case WEAPON_NYMPH:
		{
			Weapon_Nymph_ProjectileTouch(entity, target);
		}
	}
#endif
}
#endif

static void OnCreate_Proj(CClotBody body)
{
	int extra_index = EntRefToEntIndex(iref_PropAppliedToRocket[body.index]);
	if(IsValidEntity(extra_index))
		RemoveEntity(extra_index);

	iref_PropAppliedToRocket[body.index] = INVALID_ENT_REFERENCE;
	return;
}
static void OnDestroy_Proj(CClotBody body)
{
	int extra_index = EntRefToEntIndex(iref_PropAppliedToRocket[body.index]);
	if(IsValidEntity(extra_index))
		RemoveEntity(extra_index);

	iref_PropAppliedToRocket[body.index] = INVALID_ENT_REFERENCE;
#if defined ZR || defined RPG
	func_WandOnTouch[body.index] = INVALID_FUNCTION;
#endif
	return;
}

stock int ApplyCustomModelToWandProjectile(int rocket, char[] modelstringname, float ModelSize, char[] defaultAnimation, float OffsetDown = 0.0)
{
	int extra_index = EntRefToEntIndex(iref_PropAppliedToRocket[rocket]);
	if(IsValidEntity(extra_index))
		RemoveEntity(extra_index);
	
	int entity = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity))
	{
		DispatchKeyValue(entity, "targetname", "ApplyCustomModelToWandProjectile");
		DispatchKeyValue(entity, "model", modelstringname);
		
		
		static float rocketOrigin[3];
		static float rocketang[3];
		GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", rocketOrigin);
		GetEntPropVector(rocket, Prop_Data, "m_angRotation", rocketang);
		int frame = GetEntProp(entity, Prop_Send, "m_ubInterpolationFrame");
		TeleportEntity(entity, rocketOrigin, rocketang, NULL_VECTOR);
		SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", GetGameTime());
		DispatchSpawn(entity);
		SetEntProp(entity, Prop_Send, "m_ubInterpolationFrame", frame);
		MakeObjectIntangeable(entity);
		if(OffsetDown == 0.0)
			SetParent(rocket, entity);
		else
		{
			float Offset3[3];
			Offset3[2] = OffsetDown;
			SetParent(rocket, entity, "root", Offset3, false);
		}
		iref_PropAppliedToRocket[rocket] = EntIndexToEntRef(entity);
		
		if(defaultAnimation[0])
		{
			CClotBody npc = view_as<CClotBody>(entity);
			npc.AddActivityViaSequence(defaultAnimation);
		}
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", ModelSize);
		return entity;
	}
	return -1;
}