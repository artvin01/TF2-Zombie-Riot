#pragma semicolon 1
#pragma newdecls required

static char g_Boowomp[][] = {
	"weapons/rpg/rocket1.wav",
};
static char g_CritBoost[][] = {
	"weapons/crit_power.wav",
};

#define REDEEMER_ROCKET_MODEL "models/weapons/w_missile_launch.mdl"
public void Guiding_Missile_MapStart()
{
	PrecacheSoundArray(g_Boowomp);
	PrecacheSoundArray(g_CritBoost);
	PrecacheModel("models/empty.mdl");
	PrecacheModel(REDEEMER_ROCKET_MODEL);
}

static Handle Local_Timer[MAXPLAYERS] = {null, ...};
static int PlayerToRocket[MAXPLAYERS] = {0, ...};
static int WhatRocketType[MAXPLAYERS] = {0, ...};
public void Guiding_Missile_Created_Shoot_M2_Normal(int client, int weapon, bool crit, int slot)
{
	Guiding_Missile_Created_Shoot_M2Internal(client, weapon, crit, slot, false);
}
public void Guiding_Missile_Created_Shoot_M2_Nuke(int client, int weapon, bool crit, int slot)
{
	Guiding_Missile_Created_Shoot_M2Internal(client, weapon, crit, slot, true);
}
public void Guiding_Missile_Created_Shoot_M2Internal(int client, int weapon, bool crit, int slot, bool BigNuke)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%T", "Ability has cooldown",client, Ability_CD);	
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	float TimeCooldown = 45.0;
	if(BigNuke) 
		TimeCooldown = 90.0;
	Ability_Apply_Cooldown(client, slot, TimeCooldown);
	if(Local_Timer[client] != null)
		return;
	//dont shoot
	WhatRocketType[client] = 0;
	if(BigNuke)
		WhatRocketType[client] = 1;
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 2, 1.0);

	damage *= 1.25;
	float Speed = 500.0;
	float RocketSize = 1.0;

	Speed *= Attributes_Get(weapon, 103, 1.0);
	Speed *= Attributes_Get(weapon, 104, 1.0);
	Speed *= Attributes_Get(weapon, 475, 1.0);

	if(BigNuke)
	{
		Speed = 300.0;
		RocketSize = 1.5;
	}
	if(BigNuke)
		damage *= 0.85;

	int projectile = Wand_Projectile_Spawn(client, Speed, 0.0, damage, 0, weapon, "rockettrail",_,false);
	SetEntityModel(projectile, REDEEMER_ROCKET_MODEL);
	int Spectator = ApplyCustomModelToWandProjectile(projectile, "models/empty.mdl", RocketSize, "");
	if(BigNuke)
		fl_AbilityOrAttack[projectile][0] = GetGameTime() + 6.0; //MAx Time Rocket Till Full
	else
		fl_AbilityOrAttack[projectile][0] = GetGameTime() + 4.0; //MAx Time Rocket Till Full

	DataPack packremove;
	CreateDataTimer(20.0, Timer_RemoveEntity_Redeemer, packremove, TIMER_FLAG_NO_MAPCHANGE);
	packremove.WriteCell(EntIndexToEntRef(projectile));

	EmitSoundToClient(client, g_Boowomp[GetRandomInt(0, sizeof(g_Boowomp) - 1)], projectile, SNDCHAN_STATIC, 80, _, 1.0, 100);
	Custom_SDKCall_SetLocalOrigin(Spectator, {-45.0,0.0,5.0});	
	WandProjectile_ApplyFunctionToEntity(projectile, RedeemerTouch);
	PlayerToRocket[client] = EntIndexToEntRef(projectile);
	SetClientViewEntity(client, Spectator);
	SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);

	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");

	DataPack pack;
	Local_Timer[client] = CreateDataTimer(0.1, Timer_Local, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(projectile));
}



public Action Timer_RemoveEntity_Redeemer(Handle timer, DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile) && Projectile>MaxClients)
	{
		int owner = EntRefToEntIndex(i_WandOwner[Projectile]);
		if(IsValidClient(owner))
		{
			EmitSoundToClient(owner, g_Boowomp[GetRandomInt(0, sizeof(g_Boowomp) - 1)], Projectile, SNDCHAN_STATIC, 80, SND_STOP, 1.0, 100);
			EmitSoundToClient(owner, g_CritBoost[GetRandomInt(0, sizeof(g_CritBoost) - 1)], Projectile, SNDCHAN_STATIC, 80, SND_STOP, 1.0, 100);
		}
		RemoveEntity(Projectile);
	}

	return Plugin_Stop; 
}
public void Redeemer_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(Local_Timer[client] == null)
		return;
	int Rocket = EntRefToEntIndex(PlayerToRocket[client]);
	if(!IsValidEntity(Rocket))
		return;

	float fVel[3];
	GetEntPropVector(Rocket, Prop_Data, "m_vInitialVelocity", fVel);
	float speed = getLinearVelocity(fVel);

	if(speed <= 0.0)
		return;

	float anglesrocket[3];
	GetEntPropVector(Rocket, Prop_Data, "m_angRotation", anglesrocket);
	anglesrocket[0] += float(mouse[1]) * 0.1;
	anglesrocket[1] -= float(mouse[0]) * 0.1;

	float fBuf[3];
	GetAngleVectors(anglesrocket, fBuf, NULL_VECTOR, NULL_VECTOR);
	fVel[0] = fBuf[0]*speed;
	fVel[1] = fBuf[1]*speed;
	fVel[2] = fBuf[2]*speed;
	Custom_SetAbsVelocity(Rocket, fVel);	
	SetEntPropVector(Rocket, Prop_Data, "m_angRotation", anglesrocket);
	buttons = 0;
}
static Action Timer_Local(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientidx = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	int rocket = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client))
	{
		Local_Timer[clientidx] = null;
		return Plugin_Stop;
	}	
	
	if(!IsValidEntity(rocket))
	{
		if (thirdperson[client])
		{
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
		}
		PrintCenterText(client, "");

		SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 0);
		SetClientViewEntity(client, client);
		Local_Timer[clientidx] = null;
		return Plugin_Stop;
	}
	else
	{
		float fVel[3];

		PrintCenterText(client, "Control your rocket with your mouse!\nThe more it flies, the more damage it will deal.");
		SetEntProp(client, Prop_Send, "m_hObserverTarget", -1);
		GetEntPropVector(rocket, Prop_Data, "m_vInitialVelocity", fVel);

		if(fl_AbilityOrAttack[rocket][0])
		{
			if(WhatRocketType[client])
			{
				ScaleVector(fVel, 1.01);
			}
			else
			{
				ScaleVector(fVel, 1.02);
			}
			if(fl_AbilityOrAttack[rocket][0] < GetGameTime())
			{
				fl_AbilityOrAttack[rocket][0] = 0.0;
				int particle = EntRefToEntIndex(i_WandParticle[rocket]);
				if(IsValidEntity(particle))
					RemoveEntity(particle);

							
				EmitSoundToClient(client,g_Boowomp[GetRandomInt(0, sizeof(g_Boowomp) - 1)], rocket, SNDCHAN_STATIC, 80, SND_STOP, 1.0, 100);
				EmitSoundToClient(client,g_Boowomp[GetRandomInt(0, sizeof(g_Boowomp) - 1)], rocket, SNDCHAN_STATIC, 80, _, 1.0, 80);
				EmitSoundToClient(client,g_CritBoost[GetRandomInt(0, sizeof(g_CritBoost) - 1)], rocket, SNDCHAN_STATIC, 80, _, 1.0, 100);

				float vAbsorigin[3];
				GetAbsOrigin(rocket, vAbsorigin);
				static float fAng[3];
				GetEntPropVector(rocket, Prop_Send, "m_angRotation", fAng);

				particle = ParticleEffectAt(vAbsorigin, "critical_rocket_red", 0.0); //Inf duartion
				TeleportEntity(particle, NULL_VECTOR, fAng, NULL_VECTOR);
				SetParent(rocket, particle);	
				SetEntityCollisionGroup(particle, 27);
				i_WandParticle[rocket] = EntIndexToEntRef(particle);
			}
			Custom_SetAbsVelocity(rocket, fVel);	
			SetEntPropVector(rocket, Prop_Data, "m_vInitialVelocity", fVel);
		}
	}

	return Plugin_Continue;
}

public void RedeemerTouch(int entity, int target)
{
	if (target >= 0)	
	{
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		if(!IsValidClient(owner))
		{
			RemoveEntity(entity);
			return;
		}
		EmitSoundToClient(owner, g_Boowomp[GetRandomInt(0, sizeof(g_Boowomp) - 1)], entity, SNDCHAN_STATIC, 80, SND_STOP, 1.0, 100);
		EmitSoundToClient(owner,g_CritBoost[GetRandomInt(0, sizeof(g_CritBoost) - 1)], entity, SNDCHAN_STATIC, 80, SND_STOP, 1.0, 100);
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(entity, Entity_Position);


		float DamageMulti = 1.0;
		float MaxChargeIs = 4.0;
		if(WhatRocketType[owner])
			MaxChargeIs = 6.0;
		if(!fl_AbilityOrAttack[entity][0] || fl_AbilityOrAttack[entity][0] < GetGameTime())
			DamageMulti = 5.0;
		else
		{
			DamageMulti = ((((((fl_AbilityOrAttack[entity][0] - GetGameTime()) / MaxChargeIs)) -1.0) * -1.0) * 5.0);
		}
		if(DamageMulti <= 1.0)
			DamageMulti = 1.0;
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		float fVel[3];
		GetEntPropVector(entity, Prop_Data, "m_vInitialVelocity", fVel);
		if(fl_AbilityOrAttack[entity][0])
		{
			Explode_Logic_Custom(f_WandDamage[entity] * DamageMulti, owner, entity, weapon, Entity_Position, 150.0, .FunctionToCallBeforeHit = RemoveRaidBonusDmgExplode);
			TE_Particle("rd_robot_explosion", Entity_Position, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			EmitSoundToAll("mvm/mvm_tank_explode.wav", 0, SNDCHAN_STATIC, 60, _, 0.5,_,_,Entity_Position);
		}
		else
		{
			Explode_Logic_Custom(f_WandDamage[entity] * DamageMulti, owner, entity, weapon, Entity_Position, 250.0, .FunctionToCallBeforeHit = RemoveRaidBonusDmgExplode);
			TE_Particle("hightower_explosion", Entity_Position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, owner);
			TE_Particle("rd_robot_explosion", Entity_Position, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			EmitSoundToAll("mvm/mvm_tank_explode.wav", 0, SNDCHAN_STATIC, 80, _, 0.85,_,_,Entity_Position);
		}

		if(IsValidEntity(particle))
			RemoveEntity(particle);

		if(IsValidClient(owner))
		{
			SetEntProp(owner, Prop_Send, "m_bForceLocalPlayerDraw", 0);
			SetClientViewEntity(owner, owner);
			if (thirdperson[owner])
			{
				SetVariantInt(1);
				AcceptEntityInput(owner, "SetForcedTauntCam");
			}
			if(Local_Timer[owner] != null)
			{
				delete Local_Timer[owner];
			}
		}
		RemoveEntity(entity);
	}
}

static float RemoveRaidBonusDmgExplode(int attacker, int victim, float &damage, int weapon)
{
	if(b_thisNpcIsARaid[victim])
	{
		//Remove raid damage bonus from this explosion.
		damage /= EXTRA_RAID_EXPLOSIVE_DAMAGE;
	}
	return 0.0;
}
