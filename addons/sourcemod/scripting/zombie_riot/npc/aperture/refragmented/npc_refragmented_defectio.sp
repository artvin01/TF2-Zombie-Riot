#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
	"vo/npc/male01/ohno.wav",
};

static const char g_HurtSounds[][] = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/watchout.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/iceaxe/iceaxe_swing1.wav",
};

static const char g_MeleeHitSounds[][] = {
	"physics/flesh/flesh_impact_bullet1.wav",
	"physics/flesh/flesh_impact_bullet2.wav",
	"physics/flesh/flesh_impact_bullet3.wav",
	"physics/flesh/flesh_impact_bullet4.wav",
};

void Defectio_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/humans/group03/male_09.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Refragmented Defectio");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_refragmented_defectio");
	strcopy(data.Icon, sizeof(data.Icon), "spy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Defectio(vecPos, vecAng, team);
}
methodmap Defectio < CClotBody
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
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	public Defectio(float vecPos[3], float vecAng[3], int ally)
	{
		Defectio npc = view_as<Defectio>(CClotBody(vecPos, vecAng, "models/humans/group03/male_09.mdl", "1.15", "5000", ally));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Defectio_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Defectio_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Defectio_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 270.0;
		
		npc.m_flMeleeArmor = 0.10;
		npc.m_flRangedArmor = 0.10;

		npc.m_iWearable1 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0,true);
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		if(IsValidEntity(npc.m_iWearable1))
			SetParent(npc.index, npc.m_iWearable1);

		npc.m_iWearable3 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_crowbar.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable3 = TF2_CreateGlow_White("models/humans/group03/male_09.mdl", npc.index, 1.15);
		if(IsValidEntity(npc.m_iWearable3))
		{
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_bGlowEnabled", false);
			SetEntityRenderMode(npc.m_iWearable3, RENDER_ENVIRONMENTAL);
			TE_SetupParticleEffect("utaunt_signalinterference_parent", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable3);
			TE_WriteNum("m_bControlPoint1", npc.m_iWearable3);	
			TE_SendToAll();
		}

		SetEntityRenderMode(npc.index, RENDER_GLOW);
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
		
		return npc;
	}
}

public void Defectio_ClotThink(int iNPC)
{
	Defectio npc = view_as<Defectio>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
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

	float vecTarget2[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget2);
	float VecSelfNpc2[3]; WorldSpaceCenter(npc.index, VecSelfNpc2);
	float distance2 = GetVectorDistance(vecTarget2, VecSelfNpc2, true);
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	if(distance2 < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[npc.m_iTarget])
	{
		npc.PlayHurtSound();
		SDKHooks_TakeDamage(npc.index, npc.m_iTarget, npc.m_iTarget, 50.0, DMG_TRUEDAMAGE, -1, _, vecMe);
		//Explode_Logic_Custom(10.0, npc.index, npc.index, -1, vecMe, 15.0, _, _, false, 1, false);
		SetEntityRenderColor(npc.index, 180, 0, 0, 200);
	}
	if(distance2 > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[npc.m_iTarget])
	{
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget2 = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget2 < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		DefectioSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget2); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Defectio_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Defectio npc = view_as<Defectio>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget );
	float VecSelfNpc[3]; WorldSpaceCenter(victim, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

	if(flDistanceToTarget < (300.0 * 300.0))
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Defectio_NPCDeath(int entity)
{
	Defectio npc = view_as<Defectio>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

}

void DefectioSelfDefense(Defectio npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 200.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;

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
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MELEE_ATTACK_SWING");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.50;
				npc.m_flNextMeleeAttack = gameTime + 0.50;
			}
		}
	}
}