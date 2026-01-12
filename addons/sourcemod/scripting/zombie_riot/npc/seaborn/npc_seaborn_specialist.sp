#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] =
{
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav"
};

static const char g_RangedAttackSoundsSecondary[][] =
{
	"ambient/levels/labs/electric_explosion5.wav",
};

void SeabornSpecialist_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seaborn Specialist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_specialist");
	strcopy(data.Icon, sizeof(data.Icon), "ds_specialist");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeabornSpecialist(vecPos, vecAng, team, data);
}

methodmap SeabornSpecialist < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	public void PlayTeleportSound()
	{
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	
	public SeabornSpecialist(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool teleported;

		float vecPos2[3], vecAng2[3];
		if(ally != TFTeam_Red)
		{
			float lowest = 1.0;
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && IsEntityAlive(entity) && GetTeam(entity) != TFTeam_Red)
				{
					float ratio = float(GetEntProp(entity, Prop_Data, "m_iHealth") + 2) / float(ReturnEntityMaxHealth(entity) + 1);
					if(ratio < lowest)
					{
						teleported = true;
						lowest = ratio;

						GetAbsOrigin(entity, vecPos2);
						GetEntPropVector(entity, Prop_Data, "m_angRotation", vecAng2);
					}
				}
			}
		}

		SeabornSpecialist npc = view_as<SeabornSpecialist>(CClotBody(teleported ? vecPos2 : vecPos, teleported ? vecAng2 : vecAng, COMBINE_CUSTOM_MODEL, "1.15", "35000", ally, false));

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_CUSTOM_WALK_LUCIAN");
		KillFeed_SetKillIcon(npc.index, "claidheamohmor");

		if(teleported)
		{
			npc.AddGesture("ACT_CUSTOM_TELEPORT_LUCIAN");
			npc.PlayTeleportSound();
			npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.8;
			npc.m_flMeleeArmor = 0.25;
			npc.m_flRangedArmor = 0.25;
			ApplyStatusEffect(npc.index, npc.index, "Weapon Overclock",	3.0);
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup",	3.0);
			RemoveSpawnProtectionLogic(npc.index, true);
		}
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = SeabornSpecialist_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = SeabornSpecialist_ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/hw2013_shamans_skull/hw2013_shamans_skull.mdl",_,_, 2.0);
		

		npc.m_iWearable3 = npc.EquipItem("forward", "models/workshop/player/items/soldier/sf14_hellhunters_headpiece/sf14_hellhunters_headpiece.mdl",_,_, 1.2);

		
		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		if(!StrContains(data, "normal"))
		{
			npc.m_iBleedType = BLEEDTYPE_NORMAL;
			npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Specialist");
		}
		else
		{
			SetEntityRenderColor(npc.index, 155, 155, 255, 255);
			SetEntityRenderColor(npc.m_iWearable2, 155, 155, 255, 255);
			SetEntityRenderColor(npc.m_iWearable3, 155, 155, 255, 255);
			SetEntityRenderColor(npc.m_iWearable4, 155, 155, 255, 255);
		}
		return npc;
	}
}

public void SeabornSpecialist_ClotThink(int iNPC)
{
	SeabornSpecialist npc = view_as<SeabornSpecialist>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	npc.m_flMeleeArmor = 1.0;
	npc.m_flRangedArmor = 1.0;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec );
		float distance = GetVectorDistance(vecTarget, npc_vec, true);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, ShouldNpcDealBonusDamage(target) ? 500.0 : 180.0, DMG_CLUB);
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flNextMeleeAttack = gameTime + 0.65;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_CUSTOM_ATTACK_LUCIAN");
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flDoingAnimation = gameTime + 0.55;
				npc.m_flHeadshotCooldown = gameTime + 0.55;
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
			if(distance < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}

			npc.StartPathing();
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void SeabornSpecialist_NPCDeath(int entity)
{
	SeabornSpecialist npc = view_as<SeabornSpecialist>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}
