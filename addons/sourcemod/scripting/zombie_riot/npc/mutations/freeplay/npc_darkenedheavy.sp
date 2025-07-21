#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts18.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/slap_hit1.wav",
	"weapons/slap_hit2.wav",
	"weapons/slap_hit3.wav",
	"weapons/slap_hit4.wav",
};

void FogOrbHeavy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Darkened Heavy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_darkenedheavy");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FogOrbHeavy(vecPos, vecAng, team);
}
methodmap FogOrbHeavy < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 60);
		this.m_flNextIdleSound = GetGameTime(this.index) + 12.0;
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public FogOrbHeavy(float vecPos[3], float vecAng[3], int ally)
	{
		FogOrbHeavy npc = view_as<FogOrbHeavy>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "300000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(FogOrbHeavy_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(FogOrbHeavy_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(FogOrbHeavy_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 225.0;
		b_NoHealthbar[npc.index] = true; //Makes it so they never have an outline
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);
		
		npc.m_iWearable2 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		npc.m_iWearable3 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		npc.m_iWearable4 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		npc.m_iWearable5 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		npc.m_iWearable7 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		npc.m_iWearable8 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		npc.m_iWearable9 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-100.0, true);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable8, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable9, Prop_Send, "m_nSkin", skin);
		
		SetVariantString("1.9");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetVariantString("1.95");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetVariantString("2.05");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetVariantString("2.1");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetVariantString("2.15");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetVariantString("2.2");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetVariantString("2.25");
		AcceptEntityInput(npc.m_iWearable8, "SetModelScale");
		SetVariantString("2.3");
		AcceptEntityInput(npc.m_iWearable9, "SetModelScale");


		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable6, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable7, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable8, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable9, 0, 0, 0, 255);

		SetEntityRenderColor(npc.index, 0, 0, 0, 255);
		return npc;
	}
}

public void FogOrbHeavy_ClotThink(int iNPC)
{
	FogOrbHeavy npc = view_as<FogOrbHeavy>(iNPC);

	// help
	if(IsValidEntity(npc.m_iWearable1))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable1, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable2))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable2, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable3))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable3, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable4))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable4, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable5))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable5, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable6))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable6, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable7))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable7, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable8))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable8, vecTarget);
	}
	if(IsValidEntity(npc.m_iWearable9))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 100.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable9, vecTarget);
	}

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
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
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
		FogOrbHeavySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action FogOrbHeavy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	FogOrbHeavy npc = view_as<FogOrbHeavy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	float vecTarget[3];
	WorldSpaceCenter(attacker, vecTarget);

	float VecSelfNpc[3];
	WorldSpaceCenter(victim, VecSelfNpc);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget > (250.0 * 250.0))
	{
		damage *= 0.1;
		HealEntityGlobal(npc.index, npc.index, damage*0.25, 1.0, 0.0, HEAL_ABSOLUTE);
		return Plugin_Handled;
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void FogOrbHeavy_NPCDeath(int entity)
{
	FogOrbHeavy npc = view_as<FogOrbHeavy>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);	
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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

void FogOrbHeavySelfDefense(FogOrbHeavy npc, float gameTime, int target, float distance)
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
					float damageDealt = 100.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 3.0;

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
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}
