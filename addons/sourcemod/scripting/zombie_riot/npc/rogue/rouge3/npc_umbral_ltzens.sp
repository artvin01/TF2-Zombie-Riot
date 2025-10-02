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
	"vo/mvm/norm/pyro_mvm_jeers01.mp3",
	"vo/mvm/norm/pyro_mvm_jeers02.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"player/taunt_yeti_standee_demo_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav",
};


void Umbral_Ltzens_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Ltzens");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_ltzens");
	strcopy(data.Icon, sizeof(data.Icon), "ltzens");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Curtain;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Umbral_Ltzens(vecPos, vecAng, team);
}
methodmap Umbral_Ltzens < CClotBody
{
	property float m_flLaggyMovmentDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property bool m_bLaggyMovementMode
	{
		public get()							{ return b_Gunout[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Gunout[this.index] = TempValueForProperty; }
	}
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
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		this.m_flNextIdleSound = GetGameTime(this.index) + 1.0;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(50, 55));
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.3;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(40, 60));
		
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
	
	public Umbral_Ltzens(float vecPos[3], float vecAng[3], int ally)
	{
		Umbral_Ltzens npc = view_as<Umbral_Ltzens>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "22500", ally));

		vecAng[1] = GetRandomFloat(-25.0,25.0);
		vecAng[2] = GetRandomFloat(-25.0,25.0);

		SetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAng);
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.SetPlaybackRate(1.5);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Ltzens_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Ltzens_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Ltzens_ClotThink);
		
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_bisWalking = false; //we want them to have laggy animations.
		f_NpcAdjustFriction[npc.index] = 15.0;

		npc.m_bDissapearOnDeath = true;
		//dont allow self making
		npc.m_iPoseMoveX = -1;
		npc.m_iPoseMoveY = -1;
		npc.SetPoseParameter_Easy("move_x", 1.0);
		
		npc.m_bLaggyMovementMode = true;
		npc.m_flLaggyMovmentDo = GetRandomFloat(1.0, 2.0);
		npc.m_flSpeed = 2000.0;
		npc.m_flSpassOut = 0.0;
		SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 65);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2022_horror_shawl/hwn2022_horror_shawl.mdl");
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable1, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 65);

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
				fl_Extra_Damage[npc.index] *= 1.65;
				fl_Extra_MeleeArmor[npc.index] *= 0.5;
				fl_Extra_RangedArmor[npc.index] *= 0.5;
				fl_Extra_Speed[npc.index] *= 1.05;
			}
		}
		return npc;
	}
}

public void Umbral_Ltzens_ClotThink(int iNPC)
{
	Umbral_Ltzens npc = view_as<Umbral_Ltzens>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
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
	
	UmbralLtzensAnimBreak(npc);
	if(npc.m_flLaggyMovmentDo < GetGameTime())
	{
		if(npc.m_bLaggyMovementMode)
		{
			npc.m_flLaggyMovmentDo = GetGameTime() + 3.0;
			npc.m_bLaggyMovementMode = false;
		}
		else
		{
			npc.m_flLaggyMovmentDo = GetGameTime() + 0.5;
			npc.m_bLaggyMovementMode = true;
		}
	}

	if(npc.m_bLaggyMovementMode)
	{
		npc.m_flSpeed = 2000.0;
	}
	else
	{
		npc.m_flSpeed = 0.0;
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
		Umbral_LtzensSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Umbral_Ltzens_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Ltzens npc = view_as<Umbral_Ltzens>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Umbral_Ltzens_NPCDeath(int entity)
{
	Umbral_Ltzens npc = view_as<Umbral_Ltzens>(entity);
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

void Umbral_LtzensSelfDefense(Umbral_Ltzens npc, float gameTime, int target, float distance)
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
					float damageDealt = 200.0;
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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,2.0);
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.4;
			}
		}
	}
}



void UmbralLtzensAnimBreak(Umbral_Ltzens npc)
{
	if(npc.m_flSpassOut < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_KART_IMPACT_BIG", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.8);
		Layer = npc.AddGesture("ACT_GRAPPLE_PULL_START", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.5);
	}
	if(npc.m_flSpassOut2 < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut2 = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_MP_GESTURE_VC_HANDMOUTH_MELEE", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.2);
	}
}
