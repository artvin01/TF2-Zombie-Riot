#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static char g_HurtSound[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};

static char g_IdleSound[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"weapons/cbar_hit1.wav",
	"weapons/cbar_hit2.wav",
};
static char g_MeleeAttackSounds[][] = {
	"weapons/ar2/fire1.wav"
};


public void WhiteflowerTank_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Tank");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_tank");
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel("models/combine_apc.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return WhiteflowerTank(client, vecPos, vecAng, ally);
}

methodmap WhiteflowerTank < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	
	public WhiteflowerTank(int client, float vecPos[3], float vecAng[3], int ally)
	{
		WhiteflowerTank npc = view_as<WhiteflowerTank>(CClotBody(vecPos, vecAng, "models/combine_apc.mdl", "1.0", "300", ally, _, true, .CustomThreeDimensions = {100.0, 100.0, 100.0}));

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
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCDeath[npc.index] = WhiteflowerTank_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = WhiteflowerTank_OnTakeDamage;
		func_NPCThink[npc.index] = WhiteflowerTank_ClotThink;
	
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;	
		
		return npc;
	}
	
}

//TODO 
//Rewrite
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
	Npc_Base_Thinking(iNPC, 0.0, "ACT_IDLE", "ACT_IDLE", 0.0, gameTime);

	
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
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					
					npc.PlayMeleeSound();
					
					/*
		// npc_peashooter Reference

		float vecMe[3], vecTarget[3], vecAngles[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);

		MakeVectorFromPoints(vecMe, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

		if(vecAngles[0] > 180.0)
			vecAngles[0] -= 360.0;
		
		vecAngles[0] = -vecAngles[0];
		vecAngles[1] = fixAngle(vecAngles[1]);
		vecAngles[1] = -vecAngles[1];
		
		if(AimPitch >= 0)
			npc.SetPoseParameter(AimPitch, vecAngles[0]);
		
		if(AimYaw >= 0)
			npc.SetPoseParameter(AimYaw, vecAngles[1]);
					*/
				
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
	}
	npc.PlayIdleSound();
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
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


