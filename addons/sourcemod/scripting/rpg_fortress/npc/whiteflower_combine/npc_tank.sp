#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"npc/combine_gunship/gunship_explode2.wav",
};

static char g_HurtSound[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static char g_RocketBarrageInit[][] = {
	"npc/attack_helicopter/aheli_charge_up.wav",
};

static char g_RocketBarrageShoot[][] = {
	"npc/env_headcrabcanister/launch.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/ar2/fire1.wav"
};


public void WhiteflowerTank_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RocketBarrageInit));	i++) { PrecacheSound(g_RocketBarrageInit[i]);	}
	for (int i = 0; i < (sizeof(g_RocketBarrageShoot));	i++) { PrecacheSound(g_RocketBarrageShoot[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Tank");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_tank");
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel("models/combine_apc.mdl");
	PrecacheSound("weapons/sentry_spot_client.wav");
	PrecacheSound("weapons/sentry_rocket.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return WhiteflowerTank(vecPos, vecAng, team);
}

methodmap WhiteflowerTank < CClotBody
{
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayRocketBarrageInit()
	{
		EmitSoundToAll(g_RocketBarrageInit[GetRandomInt(0, sizeof(g_RocketBarrageInit) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
		EmitSoundToAll(g_RocketBarrageInit[GetRandomInt(0, sizeof(g_RocketBarrageInit) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	public void PlayRocketBarrageShoot()
	{
		EmitSoundToAll(g_RocketBarrageShoot[GetRandomInt(0, sizeof(g_RocketBarrageShoot) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	property float m_flRocketCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flRocketBarrageDoTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flRocketBarrageBetweenShots
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	
	public WhiteflowerTank(float vecPos[3], float vecAng[3], int ally)
	{
		WhiteflowerTank npc = view_as<WhiteflowerTank>(CClotBody(vecPos, vecAng, "models/combine_apc.mdl", "1.0", "300", ally, _, true, .CustomThreeDimensions = {60.0, 60.0, 80.0}));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		i_NpcIsABuilding[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	
		npc.m_flRocketCD = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCDeath[npc.index] = WhiteflowerTank_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = WhiteflowerTank_OnTakeDamage;
		func_NPCThink[npc.index] = WhiteflowerTank_ClotThink;
		f_ExtraOffsetNpcHudAbove[npc.index] = 50.0;
	
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void WhiteflowerTank_ClotThink(int iNPC)
{
	WhiteflowerTank npc = view_as<WhiteflowerTank>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 750.0, "ACT_IDLE", "ACT_IDLE", 0.0, gameTime);

	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					
					npc.PlayMeleeSound();
					
					npc.m_flNextMeleeAttack = gameTime + 0.1;
					//shot heavily, no CD
					//Body pitch

					int iPitch = npc.LookupPoseParameter("vehicle_weapon_pitch");
					if(iPitch < 0)
						return;		
				
					float vecTarget[3];
					WorldSpaceCenter(npc.m_iTarget, vecTarget);
					float vecSelf[3];
					WorldSpaceCenter(npc.index, vecSelf);
					//Body pitch
					float v[3], ang[3], vecRight[3], vecUp[3];
					SubtractVectors(vecTarget, vecSelf, v); 
					NormalizeVector(v, v);
					GetVectorAngles(v, ang); 
					KillFeed_SetKillIcon(npc.index, "smg");
					float DirShoot[3];
					GetAngleVectors(ang, DirShoot, vecRight, vecUp);
						
					//add the spray
					float x, y;
					x = GetRandomFloat( -0.25, 0.25 ) + GetRandomFloat( -0.25, 0.25 );
					y = GetRandomFloat( -0.25, 0.25 ) + GetRandomFloat( -0.25, 0.25 );
					float vecSpread = 0.1;
					
					float vecDir[3];
					vecDir[0] = DirShoot[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = DirShoot[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = DirShoot[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					FireBullet(npc.index, npc.index, vecSelf, vecDir, 135000.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					

					float npcAng[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", npcAng);
					ang[1] -= npcAng[1];
					ang[1] -= 90.0;
					ang[0] += 10.0;
					if(ang[0] > 180.0)
						ang[0] -= 360.0;
					
					ang[1] = fixAngle(ang[1]);
					
					float flPitch = npc.GetPoseParameter(iPitch);
					npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 999.0));

					iPitch = npc.LookupPoseParameter("vehicle_weapon_yaw");
					if(iPitch < 0)
						return;	
					
					npc.SetPoseParameter(iPitch, ang[1]);
				}
			}
		}
		WhiteflowerTank_RocketBarrageDo(npc, gameTime);
	}
}

void WhiteflowerTank_RocketBarrageDo(WhiteflowerTank npc, float gameTime)
{
	//do not do anything.
	if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
	{
		return;
	}
	if(npc.m_flRocketCD < gameTime)
	{
		//We initiate the rocket barrage, warning before barrage
		npc.m_flRocketBarrageDoTime = gameTime + 4.0;
		npc.m_flRocketCD = gameTime + 12.0;
		npc.m_flRocketBarrageBetweenShots = gameTime + 2.0;
		npc.PlayRocketBarrageInit();
	}
	if(npc.m_flRocketBarrageDoTime)
	{
		if(npc.m_flRocketBarrageBetweenShots < gameTime)
		{
			//Fire rocket shot, upwards.
			//then freeze the rocket, make them aimbot onto the player
			//after 1 second, shoot towards target with insane speeds.
			npc.PlayRocketBarrageShoot();
			float vecSelf[3];
			WorldSpaceCenter(npc.index, vecSelf);
			vecSelf[2] += 50.0;
			vecSelf[0] += GetRandomFloat(-10.0, 10.0);
			vecSelf[1] += GetRandomFloat(-10.0, 10.0);
			float RocketDamage = 250000.0;
			float RocketSpeed = 150.0;
			
			if(npc.m_iOverlordComboAttack == 1)
				RocketSpeed *= 2.0;
			int RocketGet = npc.FireRocket(vecSelf, RocketDamage, RocketSpeed);
			DataPack pack;
			if(npc.m_iOverlordComboAttack != 1)
				CreateDataTimer(1.0, WhiteflowerTank_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);
			else
				CreateDataTimer(0.5, WhiteflowerTank_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);

			pack.WriteCell(EntIndexToEntRef(RocketGet));
			pack.WriteCell(EntIndexToEntRef(npc.m_iTarget));
			npc.m_flRocketBarrageBetweenShots = gameTime + 0.25;
			if(npc.m_iOverlordComboAttack == 1)
				npc.m_flRocketBarrageBetweenShots = gameTime + 0.125;
		}
		if(npc.m_flRocketBarrageDoTime < gameTime)
		{
			npc.m_flRocketBarrageDoTime = 0.0;
			//Ability ends.
		}
	}
}
public Action WhiteflowerTank_Rocket_Stand(Handle timer, DataPack pack)
{
	pack.Reset();
	int RocketEnt = EntRefToEntIndex(pack.ReadCell());
	int EnemyEnt = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(RocketEnt))
		return Plugin_Stop;
		
	if(!IsValidEntity(EnemyEnt))
	{
		RemoveEntity(RocketEnt);
		return Plugin_Stop;
	}
	EmitSoundToAll("weapons/sentry_spot_client.wav", RocketEnt, SNDCHAN_AUTO, 90, _, 1.0,_);	

	float vecSelf[3];
	WorldSpaceCenter(RocketEnt, vecSelf);
	float vecEnemy[3];
	WorldSpaceCenter(EnemyEnt, vecEnemy);
	
	TE_SetupBeamPoints(vecSelf, vecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {0,0,255,255}, 3);
	TE_SendToAll(0.0);
	float vecAngles[3];
	MakeVectorFromPoints(vecSelf, vecEnemy, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	TeleportEntity(RocketEnt, NULL_VECTOR, vecAngles, {0.0,0.0,0.0});
	//look at target constantly.
	DataPack pack2;
	CreateDataTimer(0.1, WhiteflowerTank_Rocket_Stand_Fire, pack2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(RocketEnt));
	pack2.WriteCell(EntIndexToEntRef(EnemyEnt));
	pack2.WriteFloat(GetGameTime() + 1.0); //time till rocketing to enemy
	return Plugin_Stop;
}


public Action WhiteflowerTank_Rocket_Stand_Fire(Handle timer, DataPack pack)
{
	pack.Reset();
	int RocketEnt = EntRefToEntIndex(pack.ReadCell());
	int EnemyEnt = EntRefToEntIndex(pack.ReadCell());
	float TimeTillRocketing = pack.ReadFloat();
	if(!IsValidEntity(RocketEnt))
		return Plugin_Stop;
		
	if(!IsValidEntity(EnemyEnt))
	{
		RemoveEntity(RocketEnt);
		return Plugin_Stop;
	}

	//keep looking at them
	float vecSelf[3];
	WorldSpaceCenter(RocketEnt, vecSelf);
	float vecEnemy[3];
	WorldSpaceCenter(EnemyEnt, vecEnemy);
	
	float VecSpeedToDo[3];
	float vecAngles[3];
	MakeVectorFromPoints(vecSelf, vecEnemy, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	if(TimeTillRocketing < GetGameTime())
	{
		float SpeedApply = 1000.0;
		VecSpeedToDo[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*SpeedApply;
		VecSpeedToDo[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*SpeedApply;
		VecSpeedToDo[2] = Sine(DegToRad(vecAngles[0]))*-SpeedApply;
		TE_SetupBeamPoints(vecSelf, vecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {255,0,0,255}, 3);
		TE_SendToAll(0.0);
		EmitSoundToAll("weapons/sentry_rocket.wav", RocketEnt, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	else
	{
		
		TE_SetupBeamPoints(vecSelf, vecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
	TeleportEntity(RocketEnt, NULL_VECTOR, vecAngles, VecSpeedToDo);
	if(TimeTillRocketing < GetGameTime())
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action WhiteflowerTank_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	WhiteflowerTank npc = view_as<WhiteflowerTank>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void WhiteflowerTank_NPCDeath(int entity)
{
	WhiteflowerTank npc = view_as<WhiteflowerTank>(entity);
	npc.PlayDeathSound();

	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


