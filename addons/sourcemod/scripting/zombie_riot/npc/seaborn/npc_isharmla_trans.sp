#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/halloween_boss/knight_pain01.mp3",
	"vo/halloween_boss/knight_pain02.mp3",
	"vo/halloween_boss/knight_pain03.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"vo/halloween_boss/knight_attack01.mp3",
	"vo/halloween_boss/knight_attack02.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
	"vo/halloween_boss/knight_attack04.mp3"
};

void IsharmlaTrans_MapStart()
{
	PrecacheModel("models/bots/headless_hatman.mdl");
	PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl");
	PrecacheSound("ui/halloween_boss_summoned_fx.wav");
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
}

methodmap IsharmlaTrans < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(6.0, 12.0);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)]);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySpawnSound()
	{
		EmitSoundToAll("ui/halloween_boss_summoned_fx.wav");
	}
	
	public IsharmlaTrans(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		IsharmlaTrans npc = view_as<IsharmlaTrans>(CClotBody(vecPos, vecAng, "models/bots/headless_hatman.mdl", "1.5", "45000", ally, false, true));
		
		i_NpcInternalId[npc.index] = ISHARMLA_TRANS;
		i_NpcWeight[npc.index] = 6;
		npc.SetActivity("ACT_MP_STAND_ITEM1");
		KillFeed_SetKillIcon(npc.index, "headtaker");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_Think, IsharmlaTrans_ClotThink);
		
		npc.m_flSpeed = 250.0;//100.0;	// 0.6 - 0.2 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_bDissapearOnDeath = true;
		npc.Anger = false;

		b_ThisNpcIsSawrunner[npc.index] = true;
		b_CannotBeKnockedUp[npc.index] = true;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 55, 55, 255, 255);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bigaxe/c_bigaxe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.DispatchParticleEffect(npc.index, "halloween_boss_summon", vecPos, vecAng, vecPos);
		npc.PlaySpawnSound();
		
		return npc;
	}
}

public void IsharmlaTrans_ClotThink(int iNPC)
{
	IsharmlaTrans npc = view_as<IsharmlaTrans>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget, true))
		npc.m_iTarget = 0;

	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, true);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				if(ShouldNpcDealBonusDamage(npc.m_iTarget))
				{
					SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 500000.0, DMG_DROWN);
				}
				else
				{
					vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1000.0);
					npc.FireParticleRocket(vecTarget, npc.Anger ? 750.0 : 500.0, 1000.0, 275.0, "raygun_projectile_blue", true, true, _, _, EP_DEALS_DROWN_DAMAGE);
				}
			}

			npc.FaceTowards(vecTarget, 15000.0);
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < 640000.0)	// 4.0 * 200
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, target, true))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 1.0;
					npc.m_flNextMeleeAttack = gameTime + 4.45;
					npc.PlayMeleeSound();

					npc.AddGesture(ShouldNpcDealBonusDamage(target) ? "ACT_MP_GESTURE_VC_FINGERPOINT_MELEE" : "ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					npc.m_flAttackHappens = gameTime + 0.65;
					npc.m_flDoingAnimation = gameTime + 1.45;
				}
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
			npc.SetActivity("ACT_MP_STAND_ITEM1");
		}
		else
		{
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
			npc.SetActivity("ACT_MP_RUN_ITEM1");
		}
	}
	else
	{
		npc.StopPathing();
		npc.SetActivity("ACT_MP_STAND_ITEM1");
	}

	npc.PlayIdleSound();
}

void IsharmlaTrans_NPCDeath(int entity)
{
	IsharmlaTrans npc = view_as<IsharmlaTrans>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_Think, IsharmlaTrans_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float pos[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	SeaFounder_SpawnNethersea(pos);
}
