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
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

void SeaReefbreaker_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nethersea Reefbreaker");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_netherseareefbreaker");
	strcopy(data.Icon, sizeof(data.Icon), "ds_reefbreaker");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeaReefbreaker(vecPos, vecAng, team, data);
}

methodmap SeaReefbreaker < CSeaBody
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
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public SeaReefbreaker(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];

		SeaReefbreaker npc = view_as<SeaReefbreaker>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", elite ? "7500" : "6000", ally, false));
		// 20000 x 0.3
		// 25000 x 0.3

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.SetElite(elite, carrier);
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_SEABORN_WALK_BESERK");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		KillFeed_SetKillIcon(npc.index, "nessieclub");
		
		func_NPCDeath[npc.index] = SeaReefbreaker_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SeaReefbreaker_OnTakeDamage;
		func_NPCThink[npc.index] = SeaReefbreaker_ClotThink;
		
		npc.m_flSpeed = 300.0;	// 1.2 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_bCamo = false;
		npc.m_iAttackStack = 0;
		
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		if(carrier)
		{
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			vecMe[2] += 100.0;

			npc.m_iWearable1 = ParticleEffectAt(vecMe, "powerup_icon_strength", -1.0);
			SetParent(npc.index, npc.m_iWearable1);
		}

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_golfclub/c_golfclub.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sf14_deadking_head/sf14_deadking_head.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		
		if(elite)
		{
			SetEntityRenderColor(npc.m_iWearable3, 200, 0, 0, 255);

			SetEntityRenderColor(npc.m_iWearable4, 200, 0, 0, 255);
		}
		return npc;
	}
	public float Attack(float gameTime)
	{
		if(this.m_flStackDecayAt < gameTime)
		{
			// Every second decreases by 1 after 2.5 seconds
			this.m_iAttackStack -= 1 + RoundToFloor(gameTime - this.m_flStackDecayAt);
			if(this.m_iAttackStack < 0)
				this.m_iAttackStack = 0;
		}

		float multi = 1.0 + (this.m_iAttackStack * 0.15);

		if(++this.m_iAttackStack > 15)
			this.m_iAttackStack = 15;
		
		this.m_flStackDecayAt = gameTime + 3.5;

		return multi;
	}

	property float m_flStackDecayAt
	{
		public get()
		{
			return this.m_flGrappleCooldown;
		}
		public set(float value)
		{
			this.m_flGrappleCooldown = value;
		}
	}
	property int m_iAttackStack
	{
		public get()
		{
			return this.m_iOverlordComboAttack;
		}
		public set(int value)
		{
			this.m_iOverlordComboAttack = value;
		}
	}
}

public void SeaReefbreaker_ClotThink(int iNPC)
{
	SeaReefbreaker npc = view_as<SeaReefbreaker>(iNPC);

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

	bool camo = SeaFounder_TouchingNethersea(npc.index);
	if(HasSpecificBuff(npc.index, "Revealed"))
		camo = false;

	if(npc.m_bCamo)
	{
		if(!camo)
		{
			npc.m_bCamo = false;
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
			SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
			SetEntityRenderColor(npc.index, 155, 155, 255, 255);
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1500.0);
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 3000.0);
			SetEntityRenderColor(npc.m_iWearable3, 200, 0, 0, 255);
			SetEntityRenderColor(npc.m_iWearable4, 200, 0, 0, 255);
		}
	}
	else if(camo)
	{
		npc.m_bCamo = true;
		SetEntityRenderColor(npc.index, 155, 155, 255, 1);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 150.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 300.0);
		SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSALPHA);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 0, 1);
		SetEntityRenderColor(npc.m_iWearable4, 200, 0, 0, 1);
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(npc.m_flAttackHappens)
		{
			npc.FaceTowards(vecTarget, 15000.0);
			
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				float attack = (npc.m_bElite ? 120.0 : 90.0) * npc.Attack(gameTime);
				// 300 x 0.3
				// 400 x 0.3

				bool failed = true;

				if(distance < 10000.0)
				{
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);

						if(target > 0)
						{
							failed = false;

							if(ShouldNpcDealBonusDamage(target))
								attack *= 2.5;
							
							SDKHooks_TakeDamage(target, npc.index, npc.index, attack * 1.5, DMG_CLUB);
							npc.PlayMeleeHitSound();

							if(npc.m_bCarrier)
								Elemental_AddNervousDamage(target, npc.index, RoundToCeil(attack * 0.15));
						}
					}

					delete swingTrace;
				}

				if(failed)
				{
					PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0, _,vecTarget);
					int entity = npc.FireArrow(vecTarget, attack * 0.75, 1200.0, "models/weapons/w_bugbait.mdl");
					
					if(entity != -1)
					{
						if(IsValidEntity(f_ArrowTrailParticle[entity]))
							RemoveEntity(f_ArrowTrailParticle[entity]);
						
						SetEntityRenderColor(entity, 100, 100, 255, 255);
						
						WorldSpaceCenter(entity, vecTarget);
						f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "rockettrail_bubbles", 3.0);
						SetParent(entity, f_ArrowTrailParticle[entity]);
						f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);

						if(npc.m_bCarrier)
							i_NervousImpairmentArrowAmount[entity] = RoundToCeil(attack * 0.075);
					}
				}
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < 90000.0)	// 1.5 * 200
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, target, true))
				{
					npc.m_iTarget = target;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.PlayMeleeSound();

					npc.AddGesture("ACT_SEABORN_ATTACK_BESERK_1");	// TODO: Set anim
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
				}
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
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
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

public Action SeaReefbreaker_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	SeaReefbreaker npc = view_as<SeaReefbreaker>(victim);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaReefbreaker_NPCDeath(int entity)
{
	SeaReefbreaker npc = view_as<SeaReefbreaker>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(npc.m_bCarrier)
	{
		float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		Remains_SpawnDrop(pos, Buff_Reefbreaker);
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}
