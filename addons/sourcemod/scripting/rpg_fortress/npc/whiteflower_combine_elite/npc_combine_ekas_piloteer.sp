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
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static char g_RocketSound[][] = {
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
static char g_RangedAttack[][] = {
	"weapons/pistol/pistol_fire2.wav",
};

public void Whiteflower_Ekas_Piloteer_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttack));	i++) { PrecacheSound(g_RangedAttack[i]);	}
	for (int i = 0; i < (sizeof(g_RocketSound));	i++) { PrecacheSound(g_RocketSound[i]);	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Ekas Piloteer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_ekas_piloteer");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Whiteflower_Ekas_Piloteer(vecPos, vecAng, team);
}

methodmap Whiteflower_Ekas_Piloteer < CClotBody
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
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayGunShot() 
	{
		EmitSoundToAll(g_RangedAttack[GetRandomInt(0, sizeof(g_RangedAttack) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	property float m_flTimeUntillKickDone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTimeUntillSummonRocket
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public void PlayKilledEnemySound(int target) 
	{
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
							NpcSpeechBubble(this.index, "One iberian down, 30 million left to go.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
						case 1:
							NpcSpeechBubble(this.index, "Their head is a good source of fear for iberians.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
						case 2:
							NpcSpeechBubble(this.index, "Iberians are so dumb.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
					}
					return;
				}
			}

			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "The clan of Whiteflower stands tall.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "You are nothing before us.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "Useless.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayRocketSound()
 	{
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	
	public Whiteflower_Ekas_Piloteer(float vecPos[3], float vecAng[3], int ally)
	{
		Whiteflower_Ekas_Piloteer npc = view_as<Whiteflower_Ekas_Piloteer>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));

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
		

		func_NPCDeath[npc.index] = Whiteflower_Ekas_Piloteer_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_Ekas_Piloteer_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_Ekas_Piloteer_ClotThink;
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_pistol.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/heavy/sbox2014_war_helmet/sbox2014_war_helmet.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/robo_medic_physician_mask/robo_medic_physician_mask.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iAttacksTillReload = 6;
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void Whiteflower_Ekas_Piloteer_ClotThink(int iNPC)
{
	Whiteflower_Ekas_Piloteer npc = view_as<Whiteflower_Ekas_Piloteer>(iNPC);

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
	Npc_Base_Thinking(iNPC, 400.0, "ACT_RUN_PISTOL", "ACT_IDLE_PISTOL", 0.0, gameTime);
	
	//very strong kick
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 375000.0;

					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();

						npc.PlayKilledEnemySound(npc.m_iTarget);
					}
				}
				delete swingTrace;
			}
		}
		return;
	}
	if(npc.m_flTimeUntillKickDone)
	{
		if(npc.m_iChanged_WalkCycle != 5) 	
		{
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			npc.m_iChanged_WalkCycle = 5;
			npc.AddGesture("ACT_METROPOLICE_DEPLOY_MANHACK", .SetGestureSpeed = 2.0);
			npc.m_flTimeUntillSummonRocket = gameTime + 0.5;
		}
		if(npc.m_flTimeUntillSummonRocket && npc.m_flTimeUntillSummonRocket < gameTime)
		{
			npc.m_flTimeUntillSummonRocket = 0.0;
			npc.m_iAttacksTillReload = 6;
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				npc.PlayRocketSound();
				float vecSelf[3];
				WorldSpaceCenter(npc.index, vecSelf);
				vecSelf[2] += 50.0;
				vecSelf[0] += GetRandomFloat(-10.0, 10.0);
				vecSelf[1] += GetRandomFloat(-10.0, 10.0);
				float RocketDamage = 350000.0;
				int RocketGet = npc.FireRocket(vecSelf, RocketDamage, 300.0);
				DataPack pack;
				CreateDataTimer(0.5, WhiteflowerTank_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(EntIndexToEntRef(RocketGet));
				pack.WriteCell(EntIndexToEntRef(npc.m_iTarget));
			}
		}
		if(npc.m_flTimeUntillKickDone < gameTime)
		{
			npc.m_flTimeUntillKickDone = 0.0;
		}
		return;
	}
	
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
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
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(npc.m_iAttacksTillReload <= 0)
		{
			//they ran out of bullets, melee.
			npc.m_iState = 2; //enemy is abit further away.
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.0) && npc.m_flNextRangedAttack < gameTime)
		{
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
					npc.m_flSpeed = 350.0;
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
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_IDLE_ANGRY_PISTOL");
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
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
					float damage = 175000.0;
					FireBullet(npc.index, npc.m_iWearable1, vecSelf, vecDir, damage, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					npc.PlayKilledEnemySound(npc.m_iTarget);

					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
					npc.PlayGunShot();
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
						npc.m_flSpeed = 350.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
				}
			}
			case 2:
			{		
				if(npc.m_iChanged_WalkCycle != 9) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 9;
					npc.SetActivity("ACT_RUN_PISTOL");
					npc.m_flSpeed = 480.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
				{
					int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);	
					if(IsValidEnemy(npc.index, target))
					{
						npc.m_flTimeUntillKickDone = gameTime + 1.0;
						npc.m_flAttackHappens = gameTime + 0.2;
						
						if(npc.m_iChanged_WalkCycle != 8) 	
						{
							npc.m_iChanged_WalkCycle = 8;
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
							
							npc.m_bisWalking = false;
							npc.AddActivityViaSequence("kickdoorbaton");
							npc.SetCycle(0.30);
							npc.SetPlaybackRate(2.0);
						}
					}
				}
			}
		}
	}
	else
	{
		npc.m_flSpeed = 260.0;
		npc.m_iChanged_WalkCycle = 0;
	}
	npc.PlayIdleSound();
}


public Action Whiteflower_Ekas_Piloteer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Whiteflower_Ekas_Piloteer npc = view_as<Whiteflower_Ekas_Piloteer>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Whiteflower_Ekas_Piloteer_NPCDeath(int entity)
{
	Whiteflower_Ekas_Piloteer npc = view_as<Whiteflower_Ekas_Piloteer>(entity);
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


