#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char g_IdleSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/shovel_swing.wav",
};

#define ACHILLES_CHARGE_TIME 3.1
#define ACHILLES_CHARGE_SPAN 1.0
#define ACHILLES_LIGHTNING_RANGE 150.0

void MedivalAchilles_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	PrecacheModel("models/props_junk/harpoon002a.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Achilles");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_medival_achilles");
	strcopy(data.Icon, sizeof(data.Icon), "achilles");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Medieval;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MedivalAchilles(vecPos, vecAng, team);
}

methodmap MedivalAchilles < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public MedivalAchilles(float vecPos[3], float vecAng[3], int ally)
	{
		MedivalAchilles npc = view_as<MedivalAchilles>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "100000", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_BRAWLER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		
		func_NPCDeath[npc.index] = MedivalAchilles_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = MedivalAchilles_OnTakeDamage;
		func_NPCThink[npc.index] = MedivalAchilles_ClotThink;
		func_NPCAnimEvent[npc.index] = HandleAnimEvent_MedivalAchilles;

		npc.m_iState = 0;
		npc.m_flSpeed = 330.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_flMeleeArmor = 0.9;
		npc.m_flRangedArmor = 1.0;

		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		NpcColourCosmetic_ViaPaint(npc.m_iWearable1, 1644825);

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/weapons/c_models/c_persian_shield/c_persian_shield.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/weapons/c_models/c_golfclub/c_golfclub.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		//Hide Sword
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Enable");


		npc.StartPathing();
		
		return npc;
	}
}


public void MedivalAchilles_ClotThink(int iNPC)
{
	MedivalAchilles npc = view_as<MedivalAchilles>(iNPC);

	float gameTime = GetGameTime(iNPC);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float TargetVecPos[3]; WorldSpaceCenter(npc.m_iTarget, TargetVecPos);
				npc.FaceTowards(TargetVecPos, 15000.0); 
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 80.0, 80.0, 80.0 }, { -80.0, -80.0, -80.0 })) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 125.0;

					if(Medival_Difficulty_Level_NotMath >= 3)
					{
						damage = 150.0;
					}

					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 15.0;
					}
					npc.PlayMeleeHitSound();
					if(target > 0)
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}

	if(npc.m_flInJump)
	{
		if(npc.m_flInJump < gameTime)
		{
			npc.m_flInJump = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float TargetLocation[3]; 
				GetEntPropVector( npc.index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float EntityLocation[3]; 
				GetEntPropVector( npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
					
				float vecTarget[3];
				WorldSpaceCenter(npc.m_iTarget, vecTarget);

				if(distance <= (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 16.0)) //Sanity check! we want to change targets but if they are too far away then we just dont cast it.
				{
					PluginBot_Jump(npc.index, vecTarget);
				}
			}
		}
	}

	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			
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
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 18.0) && npc.m_flNextRangedAttack < gameTime)
		{
			npc.m_iState = 3; //Throw Spear
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.5) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0) && npc.m_flJumpCooldown < gameTime)
		{
			npc.m_iState = 2; //Jump
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
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_flSpeed = 330.0;
				}
					
				if(npc.m_flNextRangedAttack > gameTime)
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						//Hide spear
						AcceptEntityInput(npc.m_iWearable3, "Enable");
						AcceptEntityInput(npc.m_iWearable4, "Disable");
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_ACHILLES_RUN_DAGGER");
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						//Hide sword
						AcceptEntityInput(npc.m_iWearable3, "Disable");
						AcceptEntityInput(npc.m_iWearable4, "Enable");
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_ACHILLES_RUN_SPEAR");
					}
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Hide spear
					AcceptEntityInput(npc.m_iWearable3, "Enable");
					AcceptEntityInput(npc.m_iWearable4, "Disable");
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_ACHILLES_ATTACK_DAGGER");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.55;
					npc.m_bisWalking = true;
				}
			}
			case 2:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

				//jump at them.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Hide spear
					AcceptEntityInput(npc.m_iWearable3, "Enable");
					AcceptEntityInput(npc.m_iWearable4, "Disable");
					npc.m_iTarget = Enemy_I_See;

					if(npc.m_iChanged_WalkCycle != 7) 	
					{
						npc.StopPathing();
						
						npc.m_flSpeed = 0.0;
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_BRAWLER_RUN");
					}

					npc.PlayMeleeSound();
					
					npc.m_flInJump = gameTime + 0.5;

					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flJumpCooldown = gameTime + 10.0;
					npc.m_bisWalking = true;
				}
			}
			case 3:
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

				//jump at them.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(IsValidEntity(npc.m_iTarget))
					{
						//Hide sword
						AcceptEntityInput(npc.m_iWearable3, "Disable");
						AcceptEntityInput(npc.m_iWearable4, "Enable");
						float vEnd[3];
						
						GetAbsOrigin(npc.m_iTarget, vEnd);
						Handle pack;
						CreateDataTimer(ACHILLES_CHARGE_SPAN, Smite_Timer_achilles, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, EntIndexToEntRef(npc.index));
						WritePackFloat(pack, 0.0);
						WritePackFloat(pack, vEnd[0]);
						WritePackFloat(pack, vEnd[1]);
						WritePackFloat(pack, vEnd[2]);
						WritePackFloat(pack, 500.0);
							
						spawnRing_Vectors(vEnd, ACHILLES_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, ACHILLES_CHARGE_TIME, 6.0, 0.1, 1, 1.0);
						
						npc.m_flNextRangedAttack = gameTime + 15.0;
						npc.m_flDoingAnimation = gameTime + 2.0;
						if(npc.m_iChanged_WalkCycle != 7) 	
						{
							npc.StopPathing();
							
							npc.m_flSpeed = 0.0;
							npc.m_bisWalking = false;
							//Hide sword
							AcceptEntityInput(npc.m_iWearable3, "Disable");
							AcceptEntityInput(npc.m_iWearable4, "Enable");
							npc.m_iChanged_WalkCycle = 7;
							npc.SetActivity("ACT_ACHILLES_SPEAR_NUKE");
						}
					}
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public Action MedivalAchilles_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalAchilles npc = view_as<MedivalAchilles>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void MedivalAchilles_NPCDeath(int entity)
{
	MedivalAchilles npc = view_as<MedivalAchilles>(entity);
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
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}


public void HandleAnimEvent_MedivalAchilles(int entity, int event)
{
	if(event == 5231)
	{
		MedivalAchilles npc = view_as<MedivalAchilles>(entity);

		AcceptEntityInput(npc.m_iWearable4, "Disable");
	}
}

public Action Smite_Timer_achilles(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= ACHILLES_CHARGE_TIME)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.4, 1, (ACHILLES_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		float vAngles[3];
		int prop2 = CreateEntityByName("prop_dynamic_override");
		if(IsValidEntity(prop2))
		{
			DispatchKeyValue(prop2, "model", "models/props_junk/harpoon002a.mdl");
			DispatchKeyValue(prop2, "modelscale", "2.00");
			DispatchKeyValue(prop2, "StartDisabled", "false");
			DispatchKeyValue(prop2, "Solid", "0");
			SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
			DispatchSpawn(prop2);
			SetEntityCollisionGroup(prop2, 1);
			AcceptEntityInput(prop2, "DisableShadow");
			AcceptEntityInput(prop2, "DisableCollision");
			vAngles[0] += 90.0;
			TeleportEntity(prop2, spawnLoc, vAngles, NULL_VECTOR);
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(prop2), TIMER_FLAG_NO_MAPCHANGE);
		}

		spawnBeam(0.8, 255, 50, 50, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		CreateEarthquake(spawnLoc, 1.0, ACHILLES_LIGHTNING_RANGE * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, ACHILLES_LIGHTNING_RANGE * 1.4,_,0.8, true, 100, false, 25.0);  //Explosion range increase
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, ACHILLES_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + ACHILLES_CHARGE_TIME);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}
