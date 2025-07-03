#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSound[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};


static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/chuckle.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/rpg/rocketfire1.wav",
};

static char g_MeleeHitSounds[][] = {
	
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};
static char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

public void Whiteflower_Nano_Blaster_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Nano Blaster");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_nano_blaster");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Whiteflower_Nano_Blaster(vecPos, vecAng, team);
}

methodmap Whiteflower_Nano_Blaster < CClotBody
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
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.4, 200);
		

	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound(int target) 
	{
		if(!IsValidEntity(target))
			return;

		int Health = GetEntProp(target, Prop_Data, "m_iHealth");
		
		if(Health <= 0)
		{
			if(target <= MaxClients)
			{
				static Race race;
				Races_GetClientInfo(target, race);
				if(StrEqual(race.Name, "Iberian"))
				{
					switch(GetRandomInt(0,2))
					{
						case 0:
							NpcSpeechBubble(this.index, "Iberians are attacking, over.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
						case 1:
							NpcSpeechBubble(this.index, "Iberian counter attack is going on, over.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
						case 2:
							NpcSpeechBubble(this.index, "Need backup, more soon, over.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
					}
					return;
				}
			}

			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "Another one down, over.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "Had intruders, more might come, over.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "Enemies down, over.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	
	public Whiteflower_Nano_Blaster(float vecPos[3], float vecAng[3], int ally)
	{
		Whiteflower_Nano_Blaster npc = view_as<Whiteflower_Nano_Blaster>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");

		int iActivity = npc.LookupActivity("ACT_IDLE_PISTOL");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	
		

		func_NPCDeath[npc.index] = Whiteflower_Nano_Blaster_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_Nano_Blaster_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_Nano_Blaster_ClotThink;
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_pistol.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/hwn2015_iron_lung/hwn2015_iron_lung.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void Whiteflower_Nano_Blaster_ClotThink(int iNPC)
{
	Whiteflower_Nano_Blaster npc = view_as<Whiteflower_Nano_Blaster>(iNPC);

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
	npc.PlayKilledEnemySound(npc.m_iTarget);
	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 400.0, "ACT_RUN_PISTOL", "ACT_IDLE_PISTOL", 0.0, gameTime);
	
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.0) && npc.m_flNextRangedAttack < gameTime)
		{
			//npc.m_iAttacksTillReload <= 0
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.0))
		{
			npc.m_iState = -1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}

		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0))
		{
			npc.m_bAllowBackWalking = true;
			float vBackoffPos[3];
			BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
			npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
		}
		else
		{
			npc.m_bAllowBackWalking = false;
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3]; 
				PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
				
				npc.SetGoalVector(vPredictedPos);
			}
			else
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RUN_PISTOL");
					npc.m_flSpeed = 300.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
			}
			case 1:
			{			
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);	
				if(IsValidEnemy(npc.index, target))
				{
					if(npc.m_iChanged_WalkCycle != 7) 	
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_WALK_AIM_PISTOL");
						npc.m_flSpeed = 125.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
					npc.FaceTowards(vecTarget, 15000.0); //Snap to the enemy. make backstabbing hard to do.

					float eyePitch[3], vecDirShooting[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecSelf, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];

					npc.m_flNextRangedAttack = gameTime + 0.1;
					npc.m_iAttacksTillReload--;
					
					float x = GetRandomFloat( -0.03, 0.03 );
					float y = GetRandomFloat( -0.03, 0.03 );
					
					float vecRight[3], vecUp[3];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					float vecDir[3];
					for(int i; i < 3; i++)
					{
						vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
					}

					NormalizeVector(vecDir, vecDir);
					
					// E2 L0 = 6.0, E2 L5 = 7.0
					KillFeed_SetKillIcon(npc.index, "pistol");
					float damage = 210000.0;
					FireBullet(npc.index, npc.m_iWearable1, vecSelf, vecDir, damage, 9000.0, DMG_BULLET, "bullet_tracer02_blue");
					npc.PlayKilledEnemySound(npc.m_iTarget);

					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
					npc.PlayRangedAttackSecondarySound();
				}
				else
				{
					//Walk to target
					if(!npc.m_bPathing)
						npc.StartPathing();
						
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_RUN_PISTOL");
						npc.m_flSpeed = 300.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
				}
			}
		}
	}
	else
	{
		npc.m_flSpeed = 300.0;
		npc.m_iChanged_WalkCycle = 0;
	}
	npc.PlayIdleSound();
}


public Action Whiteflower_Nano_Blaster_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Whiteflower_Nano_Blaster npc = view_as<Whiteflower_Nano_Blaster>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Whiteflower_Nano_Blaster_NPCDeath(int entity)
{
	Whiteflower_Nano_Blaster npc = view_as<Whiteflower_Nano_Blaster>(entity);
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


