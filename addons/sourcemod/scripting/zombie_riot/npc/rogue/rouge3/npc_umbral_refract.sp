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
	"vo/mvm/norm/heavy_mvm_jeers01.mp3",
	"vo/mvm/norm/heavy_mvm_jeers02.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/fist_swing_crit.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/fist_hit_world1.wav",
	"weapons/fist_hit_world2.wav",
};


void Umbral_Refract_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Refract");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_refract");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Umbral_Refract(vecPos, vecAng, team);
}
methodmap Umbral_Refract < CClotBody
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
	property float m_flReduceWeight
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property int m_iLayerSave
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property float m_flCauseDamage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		this.m_flNextIdleSound = GetGameTime(this.index) + 1.0;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(35, 40));
		
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
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 60);
	}
	
	public Umbral_Refract(float vecPos[3], float vecAng[3], int ally)
	{
		Umbral_Refract npc = view_as<Umbral_Refract>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "22500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Refract_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Refract_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Refract_ClotThink);
		
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_flGravityMulti = 3.0;

		npc.m_bDissapearOnDeath = true;
		//dont allow self making
		
		npc.m_flSpeed = 300.0;

		SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 125);

		return npc;
	}
}

public void Umbral_Refract_ClotThink(int iNPC)
{
	Umbral_Refract npc = view_as<Umbral_Refract>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
	//	npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
		
		if(npc.IsOnGround())
		{
			static float vec3Origin[3];
			npc.GetVelocity(vec3Origin);
			npc.GetLocomotionInterface().Jump();
			vec3Origin[2] += 900.0;
			npc.SetVelocity(vec3Origin);
			int Layer = npc.AddGestureViaSequence("layer_taunt_yeti_prop");
			npc.m_flReduceWeight = 0.9;
			npc.m_iLayerSave = Layer;
			npc.SetLayerWeight(Layer, npc.m_flReduceWeight);
			npc.SetLayerCycle(Layer, 0.14);
			npc.SetLayerPlaybackRate(Layer, 0.0);
			npc.m_flCauseDamage = GetGameTime() + 0.5;
		}
	}

	if(npc.m_flReduceWeight)
	{
		npc.m_flReduceWeight -= 0.05;
		if(npc.m_flReduceWeight <= 0.0)
		{
			npc.m_flReduceWeight = 0.0;
			if(npc.IsValidLayer(npc.m_iLayerSave))
				npc.FastRemoveLayer(npc.m_iLayerSave);
		}
		else
		{
			if(npc.IsValidLayer(npc.m_iLayerSave))
				npc.SetLayerWeight(npc.m_iLayerSave, npc.m_flReduceWeight);
			else
				npc.m_flReduceWeight = 0.0;
		}
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	UmbralRefractAnimBreak(npc);
	if(npc.m_flCauseDamage)
	{
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float RadiusDamage = 65.0;
		spawnRing_Vectors(f3_NpcSavePos[npc.index], RadiusDamage*2.0, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 255, 1, 0.15, 8.0, 1.5, 1);
		spawnRing_Vectors(f3_NpcSavePos[npc.index], RadiusDamage*2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 255, 1, 0.15, 8.0, 1.5, 1);
		TE_SetupBeamPoints(VecSelfNpc, f3_NpcSavePos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.12, 5.0, 6.0, 0, 5.0, {255,50,50,255}, 3);
		TE_SendToAll(0.0);
		if(npc.IsOnGround())
		{
			spawnRing_Vectors(f3_NpcSavePos[npc.index], 0.1, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 0.15, 8.0, 1.5, 1, RadiusDamage*2.0);
			spawnRing_Vectors(f3_NpcSavePos[npc.index], 0.1, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 0.15, 8.0, 1.5, 1, RadiusDamage*2.0);
			Explode_Logic_Custom(150.0, 0, npc.index, -1, f3_NpcSavePos[npc.index],RadiusDamage, 1.0, _, true);
			EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], -1, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 60, -1, f3_NpcSavePos[npc.index]);
			EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], -1, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 60, -1, f3_NpcSavePos[npc.index]);
			npc.m_flCauseDamage = 0.0;
		}
	}
	
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
		Umbral_RefractSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Umbral_Refract_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Refract npc = view_as<Umbral_Refract>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + (DEFAULT_HURTDELAY * 2.0);
		npc.m_blPlayHurtAnimation = true;
		if(npc.IsOnGround())
		{
			GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", f3_NpcSavePos[victim]);
			f3_NpcSavePos[victim][2] += 5.0;
		}
		
	}
	
	return Plugin_Changed;
}

public void Umbral_Refract_NPCDeath(int entity)
{
	Umbral_Refract npc = view_as<Umbral_Refract>(entity);
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

void Umbral_RefractSelfDefense(Umbral_Refract npc, float gameTime, int target, float distance)
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
					float damageDealt = 140.0;
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
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.5);
				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flDoingAnimation = gameTime + 0.2;
				npc.m_flNextMeleeAttack = gameTime + 0.75;
			}
		}
	}
}



void UmbralRefractAnimBreak(Umbral_Refract npc)
{
	if(npc.m_flSpassOut < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_KART_IMPACT_BIG", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.2);
		Layer = npc.AddGesture("ACT_GRAPPLE_PULL_START", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.1);
	}
	if(npc.m_flSpassOut2 < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut2 = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_MP_GESTURE_VC_HANDMOUTH_MELEE", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.1);
	}
}