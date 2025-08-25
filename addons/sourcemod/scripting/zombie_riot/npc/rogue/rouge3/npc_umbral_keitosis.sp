#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static const char g_HurtSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/pyro_mvm_painsevere04.mp3",
	"vo/mvm/norm/pyro_mvm_painsevere05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_explode.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/fist_hit_world1.wav",
	"weapons/fist_hit_world2.wav",
};


void Umbral_Keitosis_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Keitosis");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_keitosis");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Umbral_Keitosis(vecPos, vecAng, team);
}
methodmap Umbral_Keitosis < CClotBody
{
	property float m_flSpassOut
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpassOut2
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flScalingDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flExplodeTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
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
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_ITEM, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.6, 30);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
	}
	
	public Umbral_Keitosis(float vecPos[3], float vecAng[3], int ally)
	{
		Umbral_Keitosis npc = view_as<Umbral_Keitosis>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.35", "22500", ally, .isGiant = true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_SWIM_MELEE");
		SetVariantInt(31);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;

		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		Is_a_Medic[npc.index] = true;
		ApplyStatusEffect(npc.index, target, "Anti-Waves", 999.0);

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}
		npc.m_flScalingDo = 1.0;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Keitosis_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Keitosis_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Keitosis_ClotThink);
		
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_bDissapearOnDeath = true;
		//dont allow self making
		
		npc.m_flSpeed = 150.0;
		npc.m_flExplodeTimer = 0.0;

		SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 125);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_vampyro/sf14_vampyro.mdl");
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable1, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 125);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_maniacs_manacles/hw2013_maniacs_manacles.mdl");
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable2, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 125);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_war_pants/sbox2014_war_pants.mdl");
		SetEntityRenderFx(npc.m_iWearable3, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable3, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 125);
		
		return npc;
	}
}

public void Umbral_Keitosis_ClotThink(int iNPC)
{
	Umbral_Keitosis npc = view_as<Umbral_Keitosis>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(npc.m_flScalingDo >= 2.0)
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
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
	
	UmbralKeitosisAnimBreak(npc);
	
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
	//	Umbral_KeitosisSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Umbral_Keitosis_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Keitosis npc = view_as<Umbral_Keitosis>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		
	}
	
	return Plugin_Changed;
}

public void Umbral_Keitosis_NPCDeath(int entity)
{
	Umbral_Keitosis npc = view_as<Umbral_Keitosis>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	int MaxenemySpawnScaling = 2;
	MaxenemySpawnScaling = RoundToNearest(float(MaxenemySpawnScaling) * MultiGlobalEnemy);

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	int MaxHealthGet = ReturnEntityMaxHealth(npc.index);

	MaxenemySpawnScaling = RoundToNearest(float(MaxenemySpawnScaling) * npc.m_flScalingDo);
	MaxHealthGet = RoundToNearest(float(MaxHealthGet) * 0.1);
	MaxHealthGet = RoundToNearest(float(MaxHealthGet) * npc.m_flScalingDo);

	for(int i; i<MaxenemySpawnScaling; i++)
	{
		int summon = NPC_CreateByName("npc_umbral_ltzens", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
		if(IsValidEntity(summon))
		{
			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(summon, Prop_Data, "m_iHealth", MaxHealthGet);
			SetEntProp(summon, Prop_Data, "m_iMaxHealth", MaxHealthGet);
			
			NpcStats_CopyStats(npc.index, summon);
			fl_Extra_MeleeArmor[summon] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[summon] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index];
		}
		summon = NPC_CreateByName("npc_umbral_refract", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
		if(IsValidEntity(summon))
		{
			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			NpcStats_CopyStats(npc.index, summon);
			SetEntProp(summon, Prop_Data, "m_iHealth", (MaxHealthGet) / 2);
			SetEntProp(summon, Prop_Data, "m_iMaxHealth", (MaxHealthGet) / 2);
			
			fl_Extra_MeleeArmor[summon] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[summon] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index];
		}
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
/*
void Umbral_KeitosisSelfDefense(Umbral_Keitosis npc, float gameTime, int target, float distance)
{
	return;
}

*/


void UmbralKeitosisAnimBreak(Umbral_Keitosis npc)
{
	if(npc.m_flExplodeTimer < GetGameTime())
	{
		npc.m_flExplodeTimer = GetGameTime() + 0.5;
		i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
		float radius = 160.0, damage = 350.0;
		float Loc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
		Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		npc.PlayMeleeSound();
	}
	if(EntRefToEntIndex(RaidBossActive) == npc.index)
		RaidModeScaling += 0.00125;

	npc.m_flScalingDo += 0.00125;
	if(npc.m_flSpassOut < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_KART_IMPACT_BIG", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.7);
		Layer = npc.AddGesture("ACT_GRAPPLE_PULL_START", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.4);
	}
	if(npc.m_flSpassOut2 < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut2 = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_MP_GESTURE_VC_HANDMOUTH_MELEE", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.3);
	}
}