#pragma semicolon 1
#pragma newdecls required





static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/sniper_rifle_classic_shoot.wav",
};


void RefragmentedWinterSniper_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DefaultMedic_DeathSounds));	   i++) { PrecacheSound(g_DefaultMedic_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Refragmented Winter Sniper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_refragmented_winter_sniper");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = 0;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return RefragmentedWinterSniper(vecPos, vecAng, ally, data);
}

methodmap RefragmentedWinterSniper < CClotBody
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
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property float m_flSuicideTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flWalkMust
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public RefragmentedWinterSniper(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RefragmentedWinterSniper npc = view_as<RefragmentedWinterSniper>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		
		func_NPCDeath[npc.index] = view_as<Function>(RefragmentedWinterSniper_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(RefragmentedWinterSniper_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(RefragmentedWinterSniper_ClotThink);
		
		npc.m_iChanged_WalkCycle = 0;
		Is_a_Medic[npc.index] = true;
		npc.m_iTarget = StringToInt(data);
		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;
		MakeObjectIntangeable(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_NoKillFeed[npc.index] = true;
		b_CantCollidie[npc.index] = true; 
		b_CantCollidieAlly[npc.index] = true; 
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		npc.m_bDissapearOnDeath = true;

		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.StartPathing();
			npc.m_flSpeed = 330.0;
		}	
		float ExtraTimeRandom = GetRandomFloat(0.1,1.0);
		npc.m_flNextMeleeAttack = GetGameTime() + 1.0 + ExtraTimeRandom;
		npc.m_flSuicideTimer = GetGameTime() + 11.0 + ExtraTimeRandom;
		npc.m_flWalkMust = GetGameTime() + 1.0 + ExtraTimeRandom;
		npc.m_flNextIdleSound = GetGameTime() + ExtraTimeRandom;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		
		
		TE_SetupParticleEffect("utaunt_signalinterference_parent", PATTACH_ABSORIGIN_FOLLOW, npc.index);
		TE_WriteNum("m_bControlPoint1", npc.index);	
		TE_SendToAll();
		SetEntityRenderMode(npc.index, RENDER_GLOW);
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec17_coldfront_commander/dec17_coldfront_commander.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbox2014_medic_wintergarb_gaiter/sbox2014_medic_wintergarb_gaiter.mdl");
		SetEntityRenderMode(npc.m_iWearable1, RENDER_GLOW);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 125, 200);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_GLOW);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 125, 200);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_GLOW);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 125, 200);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_GLOW);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 125, 200);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable5 = Trail_Attach(npc.index, ARROW_TRAIL, 255, 1.0, 60.0, 3.0, 5);
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 255);
		
		return npc;
	}
}

public void RefragmentedWinterSniper_ClotThink(int iNPC)
{
	RefragmentedWinterSniper npc = view_as<RefragmentedWinterSniper>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(npc.m_flSuicideTimer < GetGameTime(npc.index))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ExtraBehavior;
		if(npc.m_flWalkMust < GetGameTime(npc.index))
		{
			ExtraBehavior = RefragmentedWinterSniperSelfDefense(npc,GetGameTime(npc.index)); 
		}
		else
		{
			ExtraBehavior = 0;
		}


		switch(ExtraBehavior)
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
					npc.m_flSpeed = 200.0;
				}	
			}
			case 1:
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

		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
	}
	else
	{
		npc.m_flSuicideTimer = 0.0;
	}
	npc.PlayIdleAlertSound();
}

public Action RefragmentedWinterSniper_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	RefragmentedWinterSniper npc = view_as<RefragmentedWinterSniper>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void RefragmentedWinterSniper_NPCDeath(int entity)
{
	RefragmentedWinterSniper npc = view_as<RefragmentedWinterSniper>(entity);
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

int RefragmentedWinterSniperSelfDefense(RefragmentedWinterSniper npc, float gameTime)
{
	if(!IsValidEnemy(npc.index,npc.m_iTarget))
	{
		return 0;
	}
	if(Rogue_Mode() && i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
		return 0;

	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 15000.0);

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3], angles[3];
	view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
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
			
			ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, ThrowPos[npc.index], false );
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
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayMeleeSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 160.0;
				damageDealt *= RaidModeScaling;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 10.0;

				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				
				if(HasSpecificBuff(target, "Near Zero"))
				{
					ApplyStatusEffect(target, target, "Near Zero", 10.0);
					ApplyStatusEffect(target, target, "Frozen", 10.0);
				}
			} 
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		
		npc.m_flAttackHappens = gameTime + 1.25;
		npc.m_flDoingAnimation = gameTime + 0.95;
		npc.m_flNextMeleeAttack = gameTime + 2.5;
	}
	return 1;
}