#pragma semicolon 1
#pragma newdecls required

#define ENERGY_BALL_MODEL	"models/weapons/w_models/w_drg_ball.mdl" //This will accept particles and also hide itself.

static int i_ProjectileIndex;

void WandStocks_Map_Precache()
{
	i_ProjectileIndex = PrecacheModel(ENERGY_BALL_MODEL);
}

int Wand_Projectile_Spawn(int client,
float speed,
float time,
float damage,
int WandId,
int weapon,
const char[] WandParticle,
float CustomAng[3] = {0.0,0.0,0.0},
bool hideprojectile = true) //This will handle just the spawning, the rest like particle effects should be handled within the plugins themselves. hopefully.
{
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);

	if(CustomAng[0] != 0.0 || CustomAng[1] != 0.0)
	{
		fAng[0] = CustomAng[0];
		fAng[1] = CustomAng[1];
		fAng[2] = CustomAng[2];
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

	int entity = CreateEntityByName("tf_projectile_rocket");
	if(IsValidEntity(entity))
	{
		i_WandOwner[entity] = EntIndexToEntRef(client);
		i_WandWeapon[entity] = EntIndexToEntRef(weapon);
		f_WandDamage[entity] = damage;
		i_WandIdNumber[entity] = WandId;
		b_EntityIsArrow[entity] = true;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client); //No owner entity! woo hoo
		//Edit: Need owner entity, otheriwse you can actuall hit your own god damn rocket and make a ding sound. (Really annoying.)
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage should be nothing. if it somehow goes boom.
		SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
		TeleportEntity(entity, fPos, fAng, NULL_VECTOR);
		DispatchSpawn(entity);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);

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

		if(time < 10.0 && time > 0.1) //Make it vanish if there is no time set, or if its too big of a timer to not even bother.
		{
			DataPack pack;
			CreateDataTimer(time, Timer_RemoveEntity_CustomProjectileWand, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(EntIndexToEntRef(particle));
		}

		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Wand_DHook_RocketExplodePre); //im lazy so ill reuse stuff that already works *yawn*
		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
		SDKHook(entity, SDKHook_StartTouch, Wand_Base_StartTouch);

		return entity;
	}

	//Somehow failed...
	return -1;
}

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


public void Wand_Base_StartTouch(int entity, int other)
{
	int target = Target_Hit_Wand_Detection(entity, other);
	#if defined ZR
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
		/* Doesnt work, this projectile has noclip, go to DHOOK public bool PassfilterGlobal(int ent1, int ent2, bool result)
		case 11:
		{
			
			Cryo_Touch(entity, target);
		}
		*/
	}
#else
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
		case 4:
		{
			Want_FireWandTouch(entity, target);
		}	
	}
#endif
}
