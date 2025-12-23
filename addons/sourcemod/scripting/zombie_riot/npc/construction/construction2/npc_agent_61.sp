#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static const char g_HurtSounds[][] = {
	"music/mvm_class_menu_01.wav",
	"music/mvm_class_menu_02.wav",
	"music/mvm_class_menu_03.wav",
	"music/mvm_class_menu_04.wav",
	"music/mvm_class_menu_05.wav",
	"music/mvm_class_menu_06.wav",
	"music/mvm_class_menu_07.wav",
	"music/mvm_class_menu_08.wav",
	"music/mvm_class_menu_09.wav",
};
static const char g_IdleAlertedSounds[][] = {
	"misc/flame_engulf.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/doom_scout_shotgun.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

void Agent61_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Agent 61");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_agent_61");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Agent61(vecPos, vecAng, team);
}

methodmap Agent61 < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_WEAPON, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound(bool AttackFast)
	{
		if(AttackFast)
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 140);
		}
		else
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.2);
	}
	property float m_flSuicideTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public Agent61(float vecPos[3], float vecAng[3], int ally)
	{
		Agent61 npc = view_as<Agent61>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "5000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_iAttacksTillReload = 1;
		
		npc.m_flSuicideTimer = GetGameTime() + 50.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;


		Is_a_Medic[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
		f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE, //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions

		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;

		b_DoNotUnStuck[npc.index] = true;

		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;


		ApplyStatusEffect(npc.index, npc.index, "Challenger", 99999999.0);

		func_NPCDeath[npc.index] = view_as<Function>(Agent61_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Agent61_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Agent61_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_ethereal_hood/hw2013_ethereal_hood_spy.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/sum24_tuxedo_royale_style2/sum24_tuxedo_royale_style2.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
		int enemy_2[1];
		//find 1 target
		//itll work wierdly but its needed.
		//this will instead get the lowest def target, so itll target medics and non tanky targets and focus them
		GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), false, false, npc.index, _, false);
		for(int i; i < sizeof(enemy_2); i++)
		{
			if(enemy_2[i])
			{
				npc.m_iTarget = enemy_2[i];
				npc.m_iWearable5 = ConnectWithBeam(npc.index, npc.m_iTarget, 125, 65, 65, 2.0, 2.0, 0.0, "sprites/laserbeam.vmt");
				EmitSoundToAll("misc/freeze_cam.wav", npc.m_iTarget, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
			}
		}

		
		return npc;
	}
}

public void Agent61_ClotThink(int iNPC)
{
	Agent61 npc = view_as<Agent61>(iNPC);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1)
	{
		if(IsValidEntity(npc.m_iWearable5))
		{
			RemoveEntity(npc.m_iWearable5);
		}
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.m_iWearable5 = ConnectWithBeam(npc.index, npc.m_iTarget, 125, 65, 65, 2.0, 2.0, 0.0, "sprites/laserbeam.vmt");
			EmitSoundToAll("misc/freeze_cam.wav", npc.m_iTarget, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
	}
	
	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}
		int ActionDo;
		if(npc.m_iAttacksTillReload >= 1)
		{
			ActionDo = Clot_SelfDefense_Gun(npc,GetGameTime(npc.index));
		}
		else
		{
			ActionDo = Clot_SelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		}

		switch(ActionDo)
		{
			case 0:
			{
				npc.StartPathing();
				npc.m_flSpeed = 290.0;
			}
			case 1:
			{
				npc.StopPathing();
				npc.m_flSpeed = 0.0;
				//Stand still.
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
					npc.m_flSpeed = 290.0;
				}	
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}
			}
		}
	}

	npc.PlayIdleSound();
}

public void Agent61_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Agent61 npc = view_as<Agent61>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

public void Agent61_NPCDeath(int entity)
{
	Agent61 npc = view_as<Agent61>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

static int Clot_SelfDefense(Agent61 npc, float gameTime, int target, float distance)
{

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _,_,_,_, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 250.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.PlayMeleeSound(false);
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}	
	return 0;	
}



static int Clot_SelfDefense_Gun(Agent61 npc, float gameTime)
{
	float DistanceCheckMax = (NORMAL_ENEMY_MELEE_RANGE_FLOAT * 4.0);
	
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTargetWalkTo))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				return 2;
			}
		}
	}
		
	//Lets save this enemy!
	npc.m_iTargetAlly = npc.m_iTargetWalkTo;
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, VecEnemy);
	npc.FaceTowards(VecEnemy, 15000.0);

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3], angles[3];
	view_as<CClotBody>(npc.m_iWearable3).GetAttachment("muzzle", origin, angles);
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo))
		{
			WorldSpaceCenter(npc.m_iTargetWalkTo, ThrowPos[npc.index]);
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
			
	npc.FaceTowards(ThrowPos[npc.index], 15000.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;		
			ShootLaser(npc.m_iWearable3, "bullet_tracer02_blue_crit", origin, ThrowPos[npc.index], false );
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;	
			int target = Can_I_See_Enemy(npc.index, npc.m_iTargetWalkTo,_ ,ThrowPos[npc.index]);
			npc.PlayRangedSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 250.0;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 5.5;


				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				//once hit, apply massive fear to target AFTER damage calculations.
				NpcStats_PrimalFearChange(victim, 0.5);
				ApplyStatusEffect(npc.index, victim, "Primal Fear", 99.0);
				ApplyStatusEffect(npc.index, victim, "Primal Fear Hide", 5.0);
			} 
			npc.m_iAttacksTillReload --;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.m_flAttackHappens = gameTime + 0.9;
		npc.m_flDoingAnimation = gameTime + 0.55;
		npc.m_flNextMeleeAttack = gameTime + 2.5;
	}
	return 3;
}