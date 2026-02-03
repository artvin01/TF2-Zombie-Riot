#pragma semicolon 1
#pragma newdecls required


static const char g_IdleAlertedSoundsStart[][] =
{
	"ambient/levels/prison/radio_random1.wav",
	"ambient/levels/prison/radio_random2.wav",
	"ambient/levels/prison/radio_random3.wav",
	"ambient/levels/prison/radio_random4.wav",
	"ambient/levels/prison/radio_random5.wav",
	"ambient/levels/prison/radio_random6.wav",
	"ambient/levels/prison/radio_random7.wav",
	"ambient/levels/prison/radio_random8.wav",
	"ambient/levels/prison/radio_random9.wav",
	"ambient/levels/prison/radio_random10.wav",
	"ambient/levels/prison/radio_random11.wav",
	"ambient/levels/prison/radio_random12.wav",
	"ambient/levels/prison/radio_random13.wav",
	"ambient/levels/prison/radio_random14.wav",
	"ambient/levels/prison/radio_random15.wav",
};
static const char g_IdleAlertedSounds[][] =
{
	"npc/overwatch/radiovoice/controlsection.wav",
	"npc/overwatch/radiovoice/criminaltrespass63.wav",
	"npc/overwatch/radiovoice/finalverdictadministered.wav",
	"npc/overwatch/radiovoice/illegalcarrying95.wav",
	"npc/overwatch/radiovoice/lostbiosignalforunit.wav",
	"npc/overwatch/radiovoice/riot404.wav", //zombie riot!!!!!!!!!!!
	"npc/overwatch/radiovoice/suspectisnow187.wav",
	"npc/overwatch/radiovoice/violationofcivictrust.wav",
	"npc/overwatch/radiovoice/stormsystem.wav",
	"npc/overwatch/radiovoice/lockdownlocationsacrificecode.wav",
};
static const char g_DeathSounds[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};
static const char g_HurtSounds[][] =
{
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};
static const char g_Panic_WeaponBroke[][] =
{
	"vo/medic_sf12_badmagic08.mp3",
	"vo/medic_sf12_badmagic07.mp3",
	"vo/medic_sf12_badmagic10.mp3",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"mvm/melee_impacts/blade_slice_robo01.wav",
	"mvm/melee_impacts/blade_slice_robo01.wav",
	"mvm/melee_impacts/blade_slice_robo03.wav",
};
void AlmagestProximaOnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_IdleAlertedSoundsStart);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_Panic_WeaponBroke);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Almagest Proxima");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_almagest_proxima");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AlmagestProxima(vecPos, vecAng, team);
}

methodmap AlmagestProxima < CClotBody
{
	property float m_flDoIdleSound
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
		{
			if(this.m_flDoIdleSound && this.m_flDoIdleSound < GetGameTime(this.index))
			{
				EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
				this.m_flDoIdleSound = 0.0;
			}
			return;
		}
		EmitSoundToAll(g_IdleAlertedSoundsStart[GetRandomInt(0, sizeof(g_IdleAlertedSoundsStart) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0);
		
		this.m_flDoIdleSound = GetGameTime(this.index) + 0.75;
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(7.0, 11.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 110);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}

	property int m_iAttacksLeft
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property float m_flHealCooldownDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	public AlmagestProxima(float vecPos[3], float vecAng[3], int ally)
	{
		AlmagestProxima npc = view_as<AlmagestProxima>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 2;
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		KillFeed_SetKillIcon(npc.index, "crossbow");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = AlmagestProxima_TakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		EnemyShieldCantBreak[npc.index] = true;
		VausMagicaGiveShield(npc.index, 5);

		npc.m_flSpeed = 360.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/zombie_riot/weapons/ruina_models_2_5.mdl");
		SetVariantInt(65536);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_physician_mask/robo_medic_physician_mask.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 13595446);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2015_mechanical_engineer/hwn2015_mechanical_engineer.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2025_mad_drip_style3/hwn2025_mad_drip_style3.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable4, 13595446);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec25_lazer_gazers/dec25_lazer_gazers_medic.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable5, 13595446);

		/*
		int ModelIndex = GetEntProp(npc.index, Prop_Send, "m_nModelIndex");
		char model[PLATFORM_MAX_PATH];
		ModelIndexToString(ModelIndex, model, PLATFORM_MAX_PATH);
		int WearableDo = TF2_CreateGlow_White(model, npc.index, GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale"));
		if(IsValidEntity(WearableDo))
		{
			SetEntProp(WearableDo, Prop_Send, "m_bGlowEnabled", false);
			SetEntityRenderMode(WearableDo, RENDER_ENVIRONMENTAL);
			TE_SetupParticleEffect("utaunt_auroraglow_orange_sparkle", PATTACH_ABSORIGIN_FOLLOW, WearableDo);
			TE_WriteNum("m_bControlPoint1", WearableDo);	
			TE_SendToAll();
			SetVariantInt(1);
			AcceptEntityInput(WearableDo, "SetBodyGroup");
		}
		npc.m_iWearable6 = WearableDo;
		*/

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.StartPathing();
		return npc;
	}
}

static bool Almagest_DidHealDo;

static void ClotThink(int iNPC)
{
	AlmagestProxima npc = view_as<AlmagestProxima>(iNPC);

	GrantEntityArmor(iNPC, true, 0.5, 0.25, 0);
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
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	if(npc.m_flHealCooldownDo < GetGameTime(npc.index))
	{
		npc.m_flHealCooldownDo = GetGameTime(npc.index) + 0.5;
		Almagest_DidHealDo = false;
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		ExpidonsaGroupHeal(npc.index, 150.0, 99, float(maxhealth) / 20.0, 1.0, false,Expidonsa_OnlyHealSameIndex, AlmagestProximaBuff);
		if(Almagest_DidHealDo)
			DesertYadeamDoHealEffect(npc.index, 150.0);
	}
	
	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		int MovementDo = AlmagestProxima_SelfDefense(npc, distance, vecTarget, gameTime); 
		switch(MovementDo)
		{
			case 1:
			{
				if(distance < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos,npc.m_bAllowBackWalking);
				}
				else 
				{
					npc.SetGoalEntity(target,npc.m_bAllowBackWalking);
				}
				npc.m_bAllowBackWalking = false;
			}
			case 2:
			{
				//juke them
				npc.m_bAllowBackWalking = true;
				npc.FaceTowards(vecTarget, 1000.0);	
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos, 1);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
			case 3:
			{
				npc.m_bAllowBackWalking = true;
				npc.FaceTowards(vecTarget, 350.0);	
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
				//too close!!!
			}
		}
	}

	npc.PlayIdleSound();
}

int AlmagestProxima_SelfDefense(AlmagestProxima npc, float distance, float vecTarget[3], float gameTime)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			npc.FaceTowards(vecTarget, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
				int target = TR_GetEntityIndex(swingTrace);
				if(target > 0)
				{
					float damage = 450.0;
					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 10.0;
					}
					if(StatusEffects_PikemanDebuffMaxStacks(target))
					{
						damage *= 3.0;
						if(IsValidClient(target))
						{
							if(f_ReceivedTruedamageHit[target] < GetGameTime())
							{
								f_ReceivedTruedamageHit[target] = GetGameTime() + 0.5;
								ClientCommand(target, "playgamesound player/crit_received%d.wav", (GetURandomInt() % 3) + 1);
							}
						}
					}

					if(!ShouldNpcDealBonusDamage(target))
					{
						//not to buildings
						ApplyStatusEffect(target, target, "Pikeman's Slashes", 7.5);
						StatusEffects_PikemanDebuffAdd(target, 2);
					}

					npc.PlayMeleeHitSound();
					SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

				}
			}

			delete swingTrace;
		}
	}

	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && npc.m_flNextMeleeAttack < gameTime)
	{
		int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, target, false, true))
		{
			npc.m_iTarget = target;

			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS",_,_,_, 0.75);
			npc.PlayMeleeSound();
			
			npc.m_flAttackHappens = gameTime + 0.35;
			npc.m_flNextMeleeAttack = gameTime + 0.95;
		}
	}
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
	{
		return 2;
	}
	return 1;
}
static void ClotDeath(int entity)
{
	AlmagestProxima npc = view_as<AlmagestProxima>(entity);
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
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}


void AlmagestProxima_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AlmagestProxima npc = view_as<AlmagestProxima>(victim);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}


void AlmagestProximaBuff(int entity, int victim)
{
	Almagest_DidHealDo = true;
	float vecSelf[3];
	WorldSpaceCenter(entity, vecSelf);
	float vecAlly[3];
	WorldSpaceCenter(victim, vecAlly);

	TE_SetupBeamPoints(vecSelf, vecAlly, Shared_BEAM_Laser, 0, 0, 0, 0.25, 10.0, 10.0, 0, 1.0, {65,255,65,125}, 3);
	TE_SendToAll(0.0);
}