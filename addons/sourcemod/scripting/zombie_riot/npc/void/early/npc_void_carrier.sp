#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_MeleeHitSounds[][] = {
	"mvm/melee_impacts/cbar_hitbod_robo01.wav",
	"mvm/melee_impacts/cbar_hitbod_robo02.wav",
	"mvm/melee_impacts/cbar_hitbod_robo03.wav",
};

static float LiberiBuff[MAXENTITIES];

void VoidCarrier_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Void Carrier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_void_carrier");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_gru");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Void; 
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VoidCarrier(vecPos, vecAng, team);
}
methodmap VoidCarrier < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	
	public VoidCarrier(float vecPos[3], float vecAng[3], int ally)
	{
		VoidCarrier npc = view_as<VoidCarrier>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.1", "2000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VoidCarrier_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VoidCarrier_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VoidCarrier_ClotThink);
		
		
		
		npc.StartPathing(); 	
		npc.m_flSpeed = 200.0;

		//npc.m_iOverlordComboAttack now refferences what ally he picked up.
		//0 means he didnt pick up anything
		//-1 means he had something and threw it, and thus will just attack normally
		npc.m_iOverlordComboAttack = 0;
		Is_a_Medic[npc.index] = true; //This npc buffs, we dont waant allies to follow this ally.
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2022_road_rage/hwn2022_road_rage.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2022_road_block/hwn2022_road_block.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_heavy.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/heavy/heavy_zombie.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
		
		return npc;
	}
}

public void VoidCarrier_ClotThink(int iNPC)
{
	VoidCarrier npc = view_as<VoidCarrier>(iNPC);
	if(npc.m_iOverlordComboAttack == 2 && IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		fl_TotalArmor[iNPC] = 0.45;
		//stun target
		float Injured[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Injured); 
		Injured[2] += 30.0;
		b_NoGravity[npc.m_iTargetAlly] = true;
		b_DoNotUnStuck[npc.m_iTargetAlly] = true;
		ApplyStatusEffect(npc.m_iTargetAlly, npc.m_iTargetAlly, "Solid Stance", 999999.0);	
		
		SDKCall_SetLocalOrigin(npc.m_iTargetAlly, Injured); //keep teleporting just incase.
		LiberiBuff[npc.m_iTargetAlly] = GetGameTime() + 0.09;
		FreezeNpcInTime(npc.m_iTargetAlly, 0.09);
		b_NpcIsInvulnerable[npc.m_iTargetAlly] = true;
		SDKUnhook(npc.m_iTargetAlly, SDKHook_ThinkPost, LiberiBuffThink);
		SDKHook(npc.m_iTargetAlly, SDKHook_ThinkPost, LiberiBuffThink);
	}
	else
	{
		fl_TotalArmor[iNPC] = 1.0;
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
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_iOverlordComboAttack == 0 || npc.m_iOverlordComboAttack == 1)
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(IsValidAlly(npc.index, npc.m_iTargetAlly))
		{
			npc.m_iOverlordComboAttack = 1;
		}
		else
		{
			npc.m_iOverlordComboAttack = -1;
		}
	}

	if(npc.m_iOverlordComboAttack == 1)
	{
		if(IsValidAlly(npc.index, npc.m_iTargetAlly))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				//mounted ally, do logic!
				npc.m_iOverlordComboAttack = 2;
			}
			else 
			{
				npc.m_flSpeed = 400.0;
				npc.SetGoalEntity(npc.m_iTargetAlly);
			}
		}
		else
		{
			npc.m_iOverlordComboAttack = -1;
		}
		return;
	}
	else
	{
		npc.m_flSpeed = 200.0;
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
				//Throw valid ally
				if(npc.m_iOverlordComboAttack == 2)
				{
					if(IsValidAlly(npc.index, npc.m_iTargetAlly))
					{
						LiberiBuff[npc.m_iTargetAlly] = 0.0;
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY",_,_,_,0.75);
						npc.FaceTowards(vPredictedPos, 20000.0);
						PluginBot_Jump(npc.m_iTargetAlly, vecTarget);
						npc.m_iTargetAlly = 0;
					}
					else
					{

					}
				}
				npc.m_iOverlordComboAttack = -1;
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}
			VoidCarrierSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
	npc.PlayIdleAlertSound();
}

static void LiberiBuffThink(int entity)
{
	if(GetGameTime() > LiberiBuff[entity])
	{
		b_NpcIsInvulnerable[entity] = false;
		b_NoGravity[entity] = false;
		b_DoNotUnStuck[entity] = false;
		RemoveSpecificBuff(entity, "Solid Stance");
		
		SDKUnhook(entity, SDKHook_ThinkPost, LiberiBuffThink);	
	}
}

public Action VoidCarrier_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VoidCarrier npc = view_as<VoidCarrier>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VoidCarrier_NPCDeath(int entity)
{
	VoidCarrier npc = view_as<VoidCarrier>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void VoidCarrierSelfDefense(VoidCarrier npc, float gameTime, int target, float distance)
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
					float damageDealt = 35.0;

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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);
						
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flDoingAnimation = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}