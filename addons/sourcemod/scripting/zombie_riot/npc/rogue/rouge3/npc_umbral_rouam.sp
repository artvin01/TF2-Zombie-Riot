#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};
static const char g_EnrageSound[][] = {
	"weapons/breadmonster/gloves/bm_gloves_scream_02.wav",
};
static const char g_HurtSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/scout_mvm_beingshotinvincible01.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible02.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible03.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible04.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible05.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible06.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible07.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible08.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible09.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible11.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible12.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible13.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible14.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible15.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible16.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible17.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible18.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible19.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible21.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible22.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible23.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible24.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible25.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible26.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible27.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible28.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible29.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible31.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible32.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible33.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible34.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible35.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible36.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/gunslinger_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav",
};


void Umbral_Rouam_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_EnrageSound));	   i++) { PrecacheSound(g_EnrageSound[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel(COMBINE_CUSTOM_2_MODEL);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Rouam");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_rouam");
	strcopy(data.Icon, sizeof(data.Icon), "rouam");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Umbral_Rouam(vecPos, vecAng, team);
}
methodmap Umbral_Rouam < CClotBody
{
	property float m_flRoamCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flRageDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpassOut
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property int m_iLayerSave
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property int m_iLayerSave1
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flAutoEnrage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}

	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		this.m_flNextIdleSound = GetGameTime(this.index) + 1.0;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(35, 40));
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.3;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(40, 60));
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
	}
	public void PlayEnrageSound() 
	{
		EmitSoundToAll(g_EnrageSound[GetRandomInt(0, sizeof(g_EnrageSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_EnrageSound[GetRandomInt(0, sizeof(g_EnrageSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_EnrageSound[GetRandomInt(0, sizeof(g_EnrageSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_EnrageSound[GetRandomInt(0, sizeof(g_EnrageSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
	}
	
	public void EnrageUmbral() 
	{
		this.PlayEnrageSound();
		this.m_bisWalking = false;
		this.SetActivity("ACT_UMBRAL_ENRAGE");
		this.m_flRageDuration = GetGameTime(this.index) + 1.2;
		this.Anger = true;
		this.m_flSpeed = 0.0;
		this.StopPathing();
		float pos[3]; GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", pos);
		CreateEarthquake(pos, 1.25, 200.0, 16.0, 255.0);
	}
	
	public Umbral_Rouam(float vecPos[3], float vecAng[3], int ally)
	{
		//ally = TFTeam_Stalkers;
		Umbral_Rouam npc = view_as<Umbral_Rouam>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.75", "22500", ally, .isGiant = true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_UMBRAL_WALK");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");		

		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		int Rand_R = GetRandomInt(0, 12);
		int Rand_G = GetRandomInt(0, 12);
		int Rand_B = GetRandomInt(0, 12);

		SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.index, Rand_R, Rand_G, Rand_B, 125);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum25_fat_friar/sum25_fat_friar.mdl");
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 125);
		npc.m_flRoamCooldown = GetGameTime() + 1.0;
		npc.m_flAutoEnrage = GetGameTime() + 160.0;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Rouam_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Rouam_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Rouam_ClotThink);
		
		npc.StartPathing();
		

		npc.m_bDissapearOnDeath = true;
		if(ally != TFTeam_Red)
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
		}
		else
		{
			fl_Extra_MeleeArmor[npc.index] *= 0.65;
			fl_Extra_RangedArmor[npc.index] *= 0.65;
		}
		//dont allow self making
		
		npc.m_flSpeed = 330.0;
		fl_TotalArmor[npc.index] = 0.25;
		if(ally != TFTeam_Red && Rogue_Mode() && Rogue_GetUmbralLevel() == 0)
		{
			if(Rogue_GetUmbralLevel() == 0)
			{
				//when friendly and they still spawn as enemies, nerf.
				fl_Extra_Damage[npc.index] *= 0.75;
				fl_Extra_Speed[npc.index] *= 0.85;
				fl_Extra_MeleeArmor[npc.index] *= 1.25;
				fl_Extra_RangedArmor[npc.index] *= 1.25;
			}
			else if(Rogue_GetUmbralLevel() == 4)
			{
				//if completly hated.
				//no need to adjust HP scaling, so it can be done here.
				fl_Extra_Damage[npc.index] *= 1.5;
				fl_Extra_MeleeArmor[npc.index] *= 0.75;
				fl_Extra_RangedArmor[npc.index] *= 0.75;
			}
		}
		return npc;
	}
}

public void Umbral_Rouam_ClotThink(int iNPC)
{
	Umbral_Rouam npc = view_as<Umbral_Rouam>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flAutoEnrage < GetGameTime(npc.index))
	{
		npc.EnrageUmbral();
		npc.m_flAutoEnrage = 0.0;
	}
	if(npc.m_flRageDuration)
	{
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.2;
		npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		if(npc.m_flRageDuration < GetGameTime(npc.index))
		{
			fl_TotalArmor[npc.index] = 1.0;
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_UMBRAL_WALK");
			npc.m_flRageDuration = 0.0;
			npc.StartPathing();
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
		}
		return;
	}
	if(Umbral_Rouam_Roam(npc, GetGameTime(npc.index)))
	{
		return;
	}
	Umbral_RouamAnimBreak(npc);
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
		Umbral_RouamSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Umbral_Rouam_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Rouam npc = view_as<Umbral_Rouam>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(npc.Anger)
		return Plugin_Changed;

	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int CurrentHealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	if(float(maxhealth) * 0.9 > float(CurrentHealth))
	{
		npc.EnrageUmbral();
	}


	return Plugin_Changed;
}

public void Umbral_Rouam_NPCDeath(int entity)
{
	Umbral_Rouam npc = view_as<Umbral_Rouam>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, 		{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, 	{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, {90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);

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

void Umbral_RouamSelfDefense(Umbral_Rouam npc, float gameTime, int target, float distance)
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
					float damageDealt = 300.0;
					if(GetTeam(target) != TFTeam_Red)
						damageDealt *= 50.0;

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
				switch(GetRandomInt(1,2))
				{
					case 1:
					{
						npc.AddGesture("ACT_UMBRAL_ATTACK_LEFT",_,_,_,1.0);
					}
					case 2:
					{
						npc.AddGesture("ACT_UMBRAL_ATTACK_RIGHT",_,_,_,1.0);
					}
				}
				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flDoingAnimation = gameTime + 0.2;
				npc.m_flNextMeleeAttack = gameTime + 0.75;
			}
		}
	}
}



bool Umbral_Rouam_Roam(Umbral_Rouam npc, float gameTime)
{
	if(npc.Anger)
	{
		npc.m_flSpeed = 330.0;
		return false;
	}
	npc.m_flSpeed = 100.0;
	if(npc.m_flRoamCooldown < gameTime)
	{
		float VectorSave[3];
		VectorSave[1] = 1.0;
		TeleportDiversioToRandLocation(npc.index, true, 2000.0, 1000.0, false, true, VectorSave);
		npc.m_flRoamCooldown = gameTime + 20.0;
		npc.SetGoalVector(VectorSave);
		npc.StartPathing();
	}
	return true;
}


void Umbral_RouamAnimBreak(Umbral_Rouam npc)
{
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int CurrentHealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	
	float PercentageDo = 1.0;
	PercentageDo = float(CurrentHealth) / float(maxhealth);
	if(PercentageDo >= 1.0)
		PercentageDo = 1.0;
	PercentageDo -= 1.0;
	PercentageDo *= -1.0;

	if(PercentageDo >= 0.8)
		PercentageDo = 0.8;
	
	npc.m_iLayerSave = npc.AddGesture("ACT_UMBRAL_LAYER_1", false);
	if(npc.IsValidLayer(npc.m_iLayerSave))
	{
		npc.SetLayerWeight(npc.m_iLayerSave, PercentageDo);
		npc.SetLayerLooping(npc.m_iLayerSave, true);
	}
	npc.m_iLayerSave1 = npc.AddGesture("ACT_UMBRAL_LAYER_2", false);
	if(npc.IsValidLayer(npc.m_iLayerSave1))
	{
		npc.SetLayerWeight(npc.m_iLayerSave1, PercentageDo);
		npc.SetLayerLooping(npc.m_iLayerSave1, true);
	}
}
