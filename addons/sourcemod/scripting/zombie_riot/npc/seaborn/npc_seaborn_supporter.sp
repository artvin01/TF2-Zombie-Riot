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

static const char g_MeleeAttackSounds[][] =
{
	"weapons/capper_shoot.wav"
};

methodmap SeabornSupporter < CClotBody
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
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	
	public SeabornSupporter(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		SeabornSupporter npc = view_as<SeabornSupporter>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "45000", ally, false));

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcInternalId[npc.index] = SEABORN_SUPPORTER;
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "merasmus_zap");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_Think, SeabornSupporter_ClotThink);
		b_ThisNpcIsSawrunner[npc.index] = true;
		
		npc.m_flSpeed = 240.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1 , "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/engineer/mining_hat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 155, 155, 255, 255);

		return npc;
	}
}

public void SeabornSupporter_ClotThink(int iNPC)
{
	SeabornSupporter npc = view_as<SeabornSupporter>(iNPC);

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

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 700.0);
				npc.FaceTowards(vecTarget, 15000.0);

				npc.PlayMeleeSound();
				npc.FireParticleRocket(vecTarget, 80.0, 700.0, 100.0, "raygun_projectile_blue", false, true, _, _, EP_DEALS_DROWN_DAMAGE);
			}

			npc.m_flSpeed = 120.0;
		}
		else
		{
			npc.m_flSpeed = 240.0;
		}

		if(distance < 111000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flNextMeleeAttack = gameTime + 1.05;

				npc.AddGesture("ACT_SEABORN_ATTACK_TOOL_2");
				npc.m_flAttackHappens = gameTime + 0.25;
				//npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flHeadshotCooldown = gameTime + 0.55;
			}
		}

		if(npc.m_flNextRangedAttack < gameTime && !NpcStats_IsEnemySilenced(npc.index))
		{
			npc.m_flNextRangedAttack = gameTime + 5.0;

			int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 4;

			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			bool ally = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2;

			int entity = Npc_Create(SEARUNNER_ALT, -1, pos, ang, ally);
			if(entity > MaxClients)
			{
				if(!ally)
					Zombies_Currently_Still_Ongoing++;
				
				SetEntProp(entity, Prop_Data, "m_iHealth", health);
				SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
				
				fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index] * 0.85;
				fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index] * 2.0;
				view_as<CClotBody>(entity).m_iBleedType = BLEEDTYPE_METAL;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void SeabornSupporter_NPCDeath(int entity)
{
	SeabornSupporter npc = view_as<SeabornSupporter>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_Think, SeabornSupporter_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
