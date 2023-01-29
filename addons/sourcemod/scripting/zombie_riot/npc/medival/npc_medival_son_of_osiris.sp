#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char g_IdleSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthatcan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"items/powerups_pickup_crits.wav",
};


static int BeamWand_Laser;
static int BeamWand_Glow;
#define SON_OF_OSIRIS_RANGE 200.0

void MedivalSonOfOsiris_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

static bool b_EntityHitByLightning[MAXENTITIES];

methodmap MedivalSonOfOsiris < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public MedivalSonOfOsiris(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "750000", ally));
		
		i_NpcInternalId[npc.index] = MEDIVAL_SON_OF_OSIRIS;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_BRAWLER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, MedivalSonOfOsiris_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, MedivalSonOfOsiris_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/all_class/fall17_war_eagle/fall17_war_eagle_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iState = 0;
		npc.m_flSpeed = 330.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		b_CannotBeHeadshot[npc.index] = true;
		b_CannotBeBackstabbed[npc.index] = true;
		b_CannotBeStunned[npc.index] = true;
		b_CannotBeKnockedUp[npc.index] = true;
		b_CannotBeSlowed[npc.index] = true;
		Is_a_Medic[npc.index] = true; //cannot be healed
		

		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void MedivalSonOfOsiris_ClotThink(int iNPC)
{
	MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(iNPC);

	float gameTime = GetGameTime(iNPC);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.m_flAttackHappens)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.FaceTowards(vecTarget, 20000.0);
		}

		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{		

				float TargetLocation[3]; 
				GetEntPropVector( npc.index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float EntityLocation[3]; 
				GetEntPropVector( npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
					
				if(distance <= Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 6.5, 2.0)) //Sanity check! we want to change targets but if they are too far away then we just dont cast it.
				{
					npc.PlayMeleeSound();
				
					vecTarget = WorldSpaceCenter(npc.index);
					SonOfOsiris_Lightning_Strike(npc.index, npc.m_iTarget, 450.0, vecTarget, b_IsAlliedNpc[npc.index]);
				}
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 4.0, 2.0) && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_BRAWLER_RUN");
				}
			}
			case 1:
			{			
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in rape, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_BRAWLER_ATTACK_RIGHT");

					npc.m_flAttackHappens = gameTime + 1.0;

					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_flNextMeleeAttack = gameTime + 2.0;
					npc.m_bisWalking = true;
				}
			}
		}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public Action MedivalSonOfOsiris_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void MedivalSonOfOsiris_NPCDeath(int entity)
{
	MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, MedivalSonOfOsiris_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, MedivalSonOfOsiris_ClotThink);
		
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
}

static void SonOfOsiris_Lightning_Effect(float belowBossEyes[3], float vecHit[3], int Power)
{	
	
	int r = 65; //Yellow.
	int g = 65;
	int b = 255;
	float diameter = 30.0;

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, r, g, b, 125);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
	if(Power == 2)
	{
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);

		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
		TE_SendToAll(0.0);
	}
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	int glowColor[4];
	SetColorRGBA(glowColor, r, g, b, 125);
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
	TE_SendToAll(0.0);
}


static void SonOfOsiris_Lightning_Strike(int entity, int target, float damage, float StartLightningPos[3], bool alliednpc = false)
{
	static float vecHit[3];
	StartLightningPos = WorldSpaceCenter(entity);
	GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vecHit);
//	if(Firstlightning)
	{
		SonOfOsiris_Lightning_Effect(StartLightningPos, WorldSpaceCenter(target), 1);
	}
	StartLightningPos = WorldSpaceCenter(target);

	if(ShouldNpcDealBonusDamage(target)) //If he attacks a building first, then its going to hurt alot more.
	{
		damage *= 3.0;
	}

	SDKHooks_TakeDamage(target, entity, entity, damage, DMG_PLASMA, _, {0.0, 0.0, -50000.0}, vecHit);	//BURNING TO THE GROUND!!!
	b_EntityHitByLightning[target] = true;
	float original_damage = damage;
	for (int loop = 6; loop > 2; loop--)
	{
		int enemy = SonOfOsiris_GetClosestTargetNotAffectedByLightning(vecHit, alliednpc);
		if(IsValidEntity(enemy))
		{
			if(IsValidClient(enemy))
			{
				if(IsInvuln(enemy))
				{
					original_damage *= 2.0;
				}
			}
			damage = (original_damage * (0.15 * loop));
			SDKHooks_TakeDamage(enemy, entity, entity, damage, DMG_PLASMA, _, {0.0, 0.0, -50000.0}, vecHit);		
			GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecHit);
			SonOfOsiris_Lightning_Effect(StartLightningPos, WorldSpaceCenter(enemy), 3);
			StartLightningPos = WorldSpaceCenter(enemy);
		}
		else
		{
			break;
		}
	}
	Zero(b_EntityHitByLightning); //delete this logic.
}

stock int SonOfOsiris_GetClosestTargetNotAffectedByLightning(float EntityLocation[3], bool ally = false)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	if(ally)
	{
		for(int targ; targ<i_MaxcountNpc; targ++)
		{
			int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && !b_EntityHitByLightning[baseboss_index])
			{
				float TargetLocation[3]; 
				GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
					
				if(distance <= Pow(SON_OF_OSIRIS_RANGE , 2.0))
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = baseboss_index; 
							TargetDistance = distance;          
						}
					} 
					else 
					{
						ClosestTarget = baseboss_index; 
						TargetDistance = distance;
					}
				}
			}
		}	
	}
	else
	{
		for(int targ; targ<i_MaxcountNpc; targ++)
		{
			int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs_Allied[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && !b_EntityHitByLightning[baseboss_index])
			{
				float TargetLocation[3]; 
				GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
					
				if(distance <= Pow(SON_OF_OSIRIS_RANGE , 2.0))
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = baseboss_index; 
							TargetDistance = distance;          
						}
					} 
					else 
					{
						ClosestTarget = baseboss_index; 
						TargetDistance = distance;
					}
				}
			}
		}	
		for( int client = 1; client <= MaxClients; client++ ) 
		{
			if (IsValidClient(client))
			{
				CClotBody npc = view_as<CClotBody>(client);
				if (!npc.m_bThisEntityIgnored && IsEntityAlive(client)) //&& CheckForSee(i)) we dont even use this rn and probably never will.
				{
					float TargetLocation[3]; 
					GetEntPropVector( client, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
					float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
						
					if(distance <= Pow(SON_OF_OSIRIS_RANGE , 2.0))
					{
						if( TargetDistance ) 
						{
							if( distance < TargetDistance ) 
							{
								ClosestTarget = client; 
								TargetDistance = distance;          
							}
						} 
						else 
						{
							ClosestTarget = client; 
							TargetDistance = distance;
						}
					}
				}
			}
		}
	}
	if(IsValidEntity(ClosestTarget))
	{
		b_EntityHitByLightning[ClosestTarget] = true;
	}
	return ClosestTarget; 
}

