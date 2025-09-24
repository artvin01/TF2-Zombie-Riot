#pragma semicolon 1				//a lot of shitcode, beware, be very aware
#pragma newdecls required



static const char g_DeathSounds[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/anticitizenone.wav",
	"npc/combine_soldier/vo/prosecuting.wav",
	"npc/combine_soldier/vo/targetone.wav",
};

static const char g_BoomSounds[][] =
{
	"ambient/energy/whiteflash.wav"
};

void ThirtySixFifty_OnMapStart()		//for whatever reason it has to be "OnMapStart" rather than just "MapStart" for the icons to display
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "3650");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_3650");
	strcopy(data.Icon, sizeof(data.Icon), "combine_elite");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	PrecacheModel("models/combine_super_soldier.mdl");
	PrecacheSoundCustom("#zombie_riot/omega/calculated.mp3");
}

static void ClotPrecache()	//lol this shit is messy as fuck but ignore it, aight?
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_BoomSounds);
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheSound("weapons/ar2/fire1.wav");
	PrecacheSound("weapons/pistol/pistol_fire2.wav");
	PrecacheSound("weapons/smg1/smg1_fire1.wav");
	PrecacheSound("weapons/shotgun/shotgun_fire7.wav");
	PrecacheSound("weapons/rpg/rocketfire1.wav");
	PrecacheSound("weapons/357/357_fire2.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ThirtySixFifty(vecPos, vecAng, team);
}

char[] MinibossHealthScaling(float healthDo = 110.0, bool ingoreplayers = false)
{
	if(!ingoreplayers)
	{
		float ScalingAm = ZRStocks_PlayerScalingDynamic();
		if(ScalingAm <= 2.5) //account for this many, or else bosses just die in 1 hit.
			ScalingAm = 2.5;
		healthDo *= ZRStocks_PlayerScalingDynamic(); //yeah its high. will need to scale with waves exponentially.
	}
	
	healthDo *= MinibossScalingReturn();
	healthDo *= 1.5;
	
	if(Waves_GetRoundScale()+1 < RoundToNearest(20.0 * (1.0 / MinibossScalingReturn())))
	{
		healthDo = Pow(((healthDo + float(Waves_GetRoundScale()+1)) * float(Waves_GetRoundScale()+1)),1.25);
	}
	else if(Waves_GetRoundScale()+1 < RoundToNearest(30.0 * (1.0 / MinibossScalingReturn())))
	{
		healthDo = Pow(((healthDo + float(Waves_GetRoundScale()+1)) * float(Waves_GetRoundScale()+1)),1.35);
	}
	else
	{
		healthDo = Pow(((healthDo + float(Waves_GetRoundScale()+1)) * float(Waves_GetRoundScale()+1)),1.40);
	}
	
	healthDo /= 3.0;
	
	char buffer[16];
	IntToString(RoundToNearest(healthDo), buffer, sizeof(buffer));
	return buffer;
}

methodmap ThirtySixFifty < CClotBody
{
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(8.0, 16.0);
	}
	public void PlayHurtSound() 
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayShotgunSound()
	{
		EmitSoundToAll("weapons/shotgun/shotgun_fire7.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySMGSound()
	{
		EmitSoundToAll("weapons/smg1/smg1_fire1.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAR2Sound()
	{
		EmitSoundToAll("weapons/ar2/fire1.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPistolSound()
	{
		EmitSoundToAll("weapons/pistol/pistol_fire2.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRPGSound()
	{
		EmitSoundToAll("weapons/rpg/rocketfire1.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRevolverSound()
	{
		EmitSoundToAll("weapons/357/357_fire2.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int m_iGunType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property float m_flSwitchCooldown	// Delay between switching weapons
	{
		public get()			{	return this.m_flGrappleCooldown;	}
		public set(float value) 	{	this.m_flGrappleCooldown = value;	}
	}

	public void SetWeaponModel(const char[] model)		//dynamic weapon model change, don't touch
	{
		if(IsValidEntity(this.m_iWearable1))
			RemoveEntity(this.m_iWearable1);
		
		if(model[0])
			this.m_iWearable1 = this.EquipItem("head", model);
	}

	public ThirtySixFifty(float vecPos[3], float vecAng[3], int ally)
	{
		ThirtySixFifty npc = view_as<ThirtySixFifty>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", MinibossHealthScaling(70.0), ally, .IgnoreBuildings = true));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_RUN");		//maybe replace with a better initial walk?
		KillFeed_SetKillIcon(npc.index, "headshot");
		
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		/*
			Cosmetics
		*/

		npc.m_iWearable2 = npc.EquipItem("head", "models/combine_super_soldier.mdl");

		/*
			Variables
		*/

		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		npc.m_bDissapearOnDeath = true;
		npc.m_flSpeed = 300.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.5;
		b_NoHealthbar[npc.index] = 0;
		GiveNpcOutLineLastOrBoss(npc.index, true);
		b_thisNpcHasAnOutline[npc.index] = true; 

		npc.m_flAbilityOrAttack0 = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iGunType = 0;
		npc.m_flSwitchCooldown = GetGameTime(npc.index) + 2.0;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		Zero(fl_AlreadyStrippedMusic);
		npc.StartPathing();
		
		Citizen_MiniBossSpawn();

		switch(GetRandomInt(0,4))
		{
			case 0:
			{
				CPrintToChatAll("{white}3650{default}: You, zombie guy, follow me.");
			}
			case 1:
			{
				CPrintToChatAll("{white}3650{default}: I'm more elite than you are, come on.");
			}
			case 2:
			{
				CPrintToChatAll("{white}3650{default}: You guys can't tell, but I have a mean poker face.");
			}
			case 3:
			{
				CPrintToChatAll("{white}3650{default}: THEY have medics, why don't WE have medics?");
			}
			case 4:
			{
				CPrintToChatAll("{white}3650{default}: At least I still have meatshields.");
			}
		}
		return npc;
	}
}
static void ClotThink(int iNPC)
{
	ThirtySixFifty npc = view_as<ThirtySixFifty>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}

	int time = GetTime();
	if(i_PlayMusicSound[npc.index] < time)
	{
		// This doesn't auto loop
		EmitCustomToAll("#zombie_riot/omega/calculated.mp3", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0, 100); //song that plays duh

		i_PlayMusicSound[npc.index] = GetTime() + 43; //loops the song perfectly
	}

	if(npc.m_flAbilityOrAttack0 < gameTime)
	{
		npc.m_flAbilityOrAttack0 = gameTime + 0.25;
		
		int target = GetClosestAlly(npc.index, (250.0 * 250.0), _);
		if(target)
		{
			GrantEntityArmor(target, false, 1.0, 0.10, 0);
			ChaosSupporter npc1 = view_as<ChaosSupporter>(npc.index);
			float ProjectileLoc[3];
			GetEntPropVector(npc1.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
			spawnRing_Vectors(ProjectileLoc, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 150, 150, 0, 200, 1, 0.3, 5.0, 8.0, 3, 40.0 * 2.0);	
		}
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	//Think throttling
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
	{
		i_Target[npc.index] = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(target > 0)		//complex shit down below
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(distance < npc.GetLeadRadius()) 
		{
			PredictSubjectPosition(npc, target,_,_,vecTarget);
			npc.SetGoalVector(vecTarget);
		}
		else
		{
			npc.SetGoalEntity(target);
		}
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		int Enemy_I_See;
		Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(distance < 10000.0)
		{
			if(IsValidEnemy(npc.index, Enemy_I_See)) 
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
		else
		{
			npc.m_bAllowBackWalking = false;
		}

		if(npc.m_flSwitchCooldown < gameTime)
		{
			float cooldown = 10.0;

			switch(npc.m_iGunType)
			{
				case 0, 3, 6:	//Shotgun
				{	
					npc.m_iGunType++;
					npc.SetWeaponModel("models/weapons/w_shotgun.mdl");
					npc.SetActivity("ACT_RUN_AIM_RIFLE");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flSpeed = 300.0;
					cooldown = 8.0;
				}
				case 1, 4, 7:	//SMG
				{
					npc.m_iGunType++;
					npc.SetWeaponModel("models/weapons/w_smg1.mdl");
					npc.SetActivity("ACT_RUN_AIM_RIFLE");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flSpeed = 300.0;
					cooldown = 8.0;
				}
				case 2:			//AR2
				{
					npc.m_iGunType = 3;
					npc.SetWeaponModel("models/weapons/w_irifle.mdl");
					npc.SetActivity("ACT_RUN_AIM_RIFLE");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flSpeed = 300.0;
					cooldown = 8.0;
				}
				case 5:			//RPG
				{
					npc.m_iGunType = 6;
					npc.SetWeaponModel("models/weapons/w_rocket_launcher.mdl");
					npc.SetActivity("ACT_RUN_AIM_RELAXED");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flSpeed = 300.0;
					cooldown = 8.0;
				}
				case 8:			//Pistol
				{
					npc.m_iGunType = 9;
					npc.SetWeaponModel("models/weapons/w_pistol.mdl");
					npc.SetActivity("ACT_RUN_AIM_PISTOL");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flSpeed = 300.0;
					cooldown = 8.0;
				}
				case 9:			//Revolver (shit doesn't work so just skip it outright, unused)
				{
					npc.m_iGunType = 0;
					npc.SetWeaponModel("models/weapons/w_357.mdl");
					npc.SetActivity("ACT_RUN_AIM_PISTOL");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					cooldown = 0.1;
				}
			}
			npc.m_flSwitchCooldown = gameTime + cooldown;
		}
		switch(npc.m_iGunType)
		{
			case 1, 4, 7:	// Shotgun
			{
				npc.StartPathing();

				if(distance < 160000.0 && npc.m_flNextMeleeAttack < gameTime)	// 400 HU
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						KillFeed_SetKillIcon(npc.index, "shotgun_primary");
						
						npc.FaceTowards(vecTarget, 25000.0);
						if(target > MaxClients)
							npc.FaceTowards(vecTarget, 25000.0);

						npc.PlayShotgunSound();

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float vecDirShooting[3], vecRight[3], vecUp[3];

						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];

						float damageDealt = 5.0;
						damageDealt *= npc.m_flWaveScale;		//Damage scales with waves, scary !!

						for(int i; i < 10; i++)
						{
							float x = GetRandomFloat(-0.1, 0.1);
							float y = GetRandomFloat(-0.1, 0.1);
							
							vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							
							FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damageDealt, 3000.0, DMG_BULLET, "bullet_tracer01_red");
						}

						npc.m_flNextMeleeAttack = gameTime + 1.0; //the speed he shoots at

						KillFeed_SetKillIcon(npc.index, "skull");
					}
				}
			}
			case 2, 5, 8:	// SMG
			{
				npc.StartPathing();

				if(distance < 360000.0 && npc.m_flNextMeleeAttack < gameTime)	// 600 HU
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						KillFeed_SetKillIcon(npc.index, "smg");
						
						npc.PlaySMGSound();
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
						if(target > MaxClients)
							npc.FaceTowards(vecTarget, 25000.0);

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float vecDirShooting[3], vecRight[3], vecUp[3];

						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];

						float damageDealt = 3.5;
						damageDealt *= npc.m_flWaveScale;

						for(int i; i < 2; i++)
						{
							float x = GetRandomFloat(-0.05, 0.05);
							float y = GetRandomFloat(-0.05, 0.05);
							
							vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							
							FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damageDealt, 3000.0, DMG_BULLET, "bullet_tracer01_red");
						}

						npc.m_flNextMeleeAttack = gameTime + 0.05;

						KillFeed_SetKillIcon(npc.index, "skull");
					}
				}
			}
			case 3:	// AR2
			{
				npc.StartPathing();

				if(distance < 360000.0 && npc.m_flNextMeleeAttack < gameTime)	// 600 HU
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						KillFeed_SetKillIcon(npc.index, "the_classic");
						
						npc.PlayAR2Sound();
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
						if(target > MaxClients)
							npc.FaceTowards(vecTarget, 25000.0);

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float vecDirShooting[3], vecRight[3], vecUp[3];

						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];

						float damageDealt = 4.0;
						damageDealt *= npc.m_flWaveScale;

						for(int i; i < 2; i++)
						{
							float x = GetRandomFloat(-0.05, 0.05);
							float y = GetRandomFloat(-0.05, 0.05);
							
							vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							
							FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damageDealt, 3000.0, DMG_BULLET, "bullet_tracer01_red");
						}

						npc.m_flNextMeleeAttack = gameTime + 0.05;
						KillFeed_SetKillIcon(npc.index, "skull");
					}
				}
			}
			case 6:	// RPG
			{
				npc.StartPathing();

				if(npc.m_flNextMeleeAttack < gameTime)
				{
					npc.PlayRPGSound();
					float damageDealt = 60.0;
					damageDealt *= npc.m_flWaveScale;
					
					int enemy[4];
					GetHighDefTargets(view_as<UnderTides>(npc), enemy, sizeof(enemy));
					for(int i; (i < sizeof(enemy)) && enemy[i]; i++)
					{
						if(GetURandomInt() % 2)
						{
							PredictSubjectPositionForProjectiles(npc, target, 900.0,_,vecTarget);
						}
						else
						{
							WorldSpaceCenter(target, vecTarget);
						}

						npc.FireRocket(vecTarget, damageDealt, 900.0);
						KillFeed_SetKillIcon(npc.index, "dumpster_device");
					}

					npc.m_flNextMeleeAttack = gameTime + 2.0;
				}
			}
			case 9:	// Pistol
			{
				npc.StartPathing();

				if(distance < 160000.0 && npc.m_flNextMeleeAttack < gameTime)	// 400 HU
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						KillFeed_SetKillIcon(npc.index, "pistol");
						
						npc.FaceTowards(vecTarget, 25000.0);
						if(target > MaxClients)
							npc.FaceTowards(vecTarget, 25000.0);

						npc.PlayPistolSound();
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float vecDirShooting[3], vecRight[3], vecUp[3];

						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];

						float damageDealt = 1.5;
						damageDealt *= npc.m_flWaveScale;

						for(int i; i < 10; i++)
						{
							float x = GetRandomFloat(-0.1, 0.1);
							float y = GetRandomFloat(-0.1, 0.1);
							
							vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							
							FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damageDealt, 3000.0, DMG_BULLET, "bullet_tracer01_red");
						}

						npc.m_flNextMeleeAttack = gameTime + 0.20;

						KillFeed_SetKillIcon(npc.index, "skull");
					}
				}
			}
			case 11:	// Revolver (check revolver case)
			{
				npc.StartPathing();

				if(distance < 160000.0 && npc.m_flNextMeleeAttack < gameTime)	// 400 HU
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						KillFeed_SetKillIcon(npc.index, "enforcer");
						
						npc.FaceTowards(vecTarget, 25000.0);
						if(target > MaxClients)
							npc.FaceTowards(vecTarget, 25000.0);

						npc.PlayRevolverSound();
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float vecDirShooting[3], vecRight[3], vecUp[3];

						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];

						float damageDealt = 40.0;
						damageDealt *= npc.m_flWaveScale;

						for(int i; i < 10; i++)
						{
							float x = GetRandomFloat(-0.1, 0.1);
							float y = GetRandomFloat(-0.1, 0.1);
							
							vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							
							FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damageDealt, 3000.0, DMG_BULLET, "bullet_tracer01_red");
						}

						npc.m_flNextMeleeAttack = gameTime + 2.0;

						KillFeed_SetKillIcon(npc.index, "skull");
					}
				}
			}
		}
	}
}

public Action Timer_RemoveEntityThirtySixFifty(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TE_Particle("halloween_boss_summon", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0); //particle that spawns after his death
		//TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);

		ThirtySixFifty npc = view_as<ThirtySixFifty>(entity);

		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
	
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);

		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
	
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
	
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
		npc.PlayBoomSound();
	}
	return Plugin_Handled;
}

static Action ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage)
{
	ThirtySixFifty npc = view_as<ThirtySixFifty>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ClotDeath(int entity)
{
	ThirtySixFifty npc = view_as<ThirtySixFifty>(entity);

	for(int i; i < 9; i++)
	{
		i_PlayMusicSound[npc.index] = 0;
		StopCustomSound(entity, SNDCHAN_STATIC, "#zombie_riot/omega/calculated.mp3", 5.0);
	}

	if(IsValidEntity(npc.m_iWearable1))
	RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
	RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
	RemoveEntity(npc.m_iWearable3);

	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/combine_super_soldier.mdl");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.15); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("bugbait_hit");
		AcceptEntityInput(entity_death, "SetAnimation");
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsValidClient(client))
				Music_Stop_All(client); //It cost 400000$ to stop music...once...
		}
		pos[2] += 20.0;
		
		CreateTimer(1.0, Timer_RemoveEntityThirtySixFifty, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE); //timer that starts the Timer_RemoveEntityThirtySixFifty chain of events
	}
	
	Citizen_MiniBossDeath(entity);
}