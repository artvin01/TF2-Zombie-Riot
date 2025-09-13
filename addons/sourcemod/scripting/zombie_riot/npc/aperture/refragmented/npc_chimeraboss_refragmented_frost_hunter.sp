#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/scout_paincrticialdeath01.mp3",
	"vo/scout_paincrticialdeath02.mp3",
	"vo/scout_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/scout_battlecry01.mp3",
	"vo/scout_battlecry02.mp3",
	"vo/scout_battlecry03.mp3",
	"vo/scout_battlecry04.mp3",
	"vo/scout_battlecry05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/doom_scout_shotgun.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

void RefragmentedWinterFrostHunter_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Refragmented Frost Hunter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_refragmented_frost_hunter");
	strcopy(data.Icon, sizeof(data.Icon), "scout_fan");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RefragmentedWinterFrostHunter(vecPos, vecAng, team, data);
}

methodmap RefragmentedWinterFrostHunter < CClotBody
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
	
	public void PlayMeleeSound(bool AttackFast)
	{
		if(AttackFast)
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 140);
		}
		else
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.2);
	}
	property float m_flSuicideTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public RefragmentedWinterFrostHunter(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RefragmentedWinterFrostHunter npc = view_as<RefragmentedWinterFrostHunter>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		npc.m_flSuicideTimer = GetGameTime() + 10.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		npc.m_iOverlordComboAttack = 2;
		npc.m_iChanged_WalkCycle = 1;
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
		b_NpcIsInvulnerable[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		TE_SetupParticleEffect("utaunt_signalinterference_parent", PATTACH_ABSORIGIN_FOLLOW, npc.index);
		TE_WriteNum("m_bControlPoint1", npc.index);	
		TE_SendToAll();

		func_NPCDeath[npc.index] = view_as<Function>(RefragmentedWinterFrostHunter_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(RefragmentedWinterFrostHunter_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(RefragmentedWinterFrostHunter_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 660.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_prinny_knife/c_prinny_knife.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/scout/dec23_isotopic_insulator/dec23_isotopic_insulator.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/scout/scout_gloves_leather_open/scout_gloves_leather_open.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/scout/fall17_transparent_trousers/fall17_transparent_trousers.mdl");
		
		SetEntityRenderColor(npc.index, 0, 0, 125);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 125);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 125);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 125);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 125);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable5 = Trail_Attach(npc.index, ARROW_TRAIL, 255, 1.0, 60.0, 3.0, 5);
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 255);
		
		KillFeed_SetKillIcon(npc.index, "purgatory");
		
		return npc;
	}
}

public void RefragmentedWinterFrostHunter_ClotThink(int iNPC)
{
	RefragmentedWinterFrostHunter npc = view_as<RefragmentedWinterFrostHunter>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flSuicideTimer < GetGameTime(npc.index))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	if (IsValidEntity(Aperture_GetLastStandBoss()))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
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

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = RefragmentedWinterFrostHunterSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				//Get the normal prediction code.
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
		}
	}
	else
	{
		npc.m_flSuicideTimer = 0.0;
	}
	npc.PlayIdleAlertSound();
}

public void RefragmentedWinterFrostHunter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	RefragmentedWinterFrostHunter npc = view_as<RefragmentedWinterFrostHunter>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

public void RefragmentedWinterFrostHunter_NPCDeath(int entity)
{
	RefragmentedWinterFrostHunter npc = view_as<RefragmentedWinterFrostHunter>(entity);
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

int RefragmentedWinterFrostHunterSelfDefense(RefragmentedWinterFrostHunter npc, float gameTime, int target, float distance)
{

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flSuicideTimer = 0.0;
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
					float damageDealt = 80.0;
					damageDealt *= RaidModeScaling;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.5;


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
				npc.PlayMeleeSound(false);
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
		else
		{
			npc.PlayMeleeSound(true);
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS", .SetGestureSpeed = 4.0);
					
			npc.m_flNextMeleeAttack = gameTime + 0.15;
		}
	}		
	return 0;
}
