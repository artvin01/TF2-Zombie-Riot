#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie_poison/pz_idle3.wav",
	"npc/zombie_poison/pz_idle4.wav",
};

static const char g_SuperJumpSound[][] = {
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
};


static const char g_MeleeHitSounds[][] = {
	"weapons/stunstick/spark1.wav",
	"weapons/stunstick/spark2.wav",
	"weapons/stunstick/spark3.wav",
};

void VoudSprayer_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Void Sprayer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_void_sprayer");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Void; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VoudSprayer(vecPos, vecAng, team);
}
methodmap VoudSprayer < CClotBody
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
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}	
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	
	public VoudSprayer(float vecPos[3], float vecAng[3], int ally)
	{
		VoudSprayer npc = view_as<VoudSprayer>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VoudSprayer_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VoudSprayer_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VoudSprayer_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/demo/hw2013_the_parasight/hw2013_the_parasight.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/hw2013_the_ghoulic_extension/hw2013_the_ghoulic_extension.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_manneater/hw2013_the_manneater_demo.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/demo/demo_zombie.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 200, 0, 200, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);
		
		return npc;
	}
}

public void VoudSprayer_ClotThink(int iNPC)
{
	VoudSprayer npc = view_as<VoudSprayer>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

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
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = VoudSprayerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{		
					if(npc.m_flJumpCooldown < GetGameTime(npc.index))
					{
						if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
						{
							if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
							{
								npc.FaceTowards(vecTarget, 15000.0);
								PluginBot_Jump(npc.index, vecTarget);
								npc.PlayIdleAlertSound();
								npc.m_flJumpCooldown = GetGameTime(npc.index) + 7.5;
								npc.PlaySuperJumpSound();
							}
						}
					}
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}


int VoudSprayerSelfDefense(VoudSprayer npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeHitSound();
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flNextMeleeAttack = gameTime + 1.25;
				float DamageProject = 30.0;

				int entity = npc.FireArrow(vecTarget, DamageProject, 700.0, ENERGY_BALL_MODEL);
					
				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);
					
					SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
					SetEntityRenderColor(entity, 200, 0, 200, 255);
					
					WorldSpaceCenter(entity, vecTarget);
					f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "unusual_magicsmoke_purple_glow", 5.0);
					SetParent(entity, f_ArrowTrailParticle[entity]);
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);

					i_VoidArrowAmount[entity] = RoundToCeil(DamageProject * 4.0);
				}
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
			return 0;
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	return 0;
}

public Action VoudSprayer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VoudSprayer npc = view_as<VoudSprayer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VoudSprayer_NPCDeath(int entity)
{
	VoudSprayer npc = view_as<VoudSprayer>(entity);
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