#pragma semicolon 1
#pragma newdecls required





static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};
static const char g_RangedAttackSounds[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};
static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_blast_jump.wav",
};
static const char g_PlayRegenShieldInit[][] = {
	"weapons/cow_mangler_over_charge_shot.wav",
};


void VoidSpeechless_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DefaultMedic_DeathSounds));	   i++) { PrecacheSound(g_DefaultMedic_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_PlayRegenShieldInit)); i++) { PrecacheSound(g_PlayRegenShieldInit[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Speechless");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_void_speechless");
	strcopy(data.Icon, sizeof(data.Icon), "scout_armored_hyper");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Void; 
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return VoidSpeechless(vecPos, vecAng, team, data);
}

methodmap VoidSpeechless < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayShieldRegenSoundInit()
	{
		EmitSoundToAll(g_PlayRegenShieldInit[GetRandomInt(0, sizeof(g_PlayRegenShieldInit) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 130);
		EmitSoundToAll(g_PlayRegenShieldInit[GetRandomInt(0, sizeof(g_PlayRegenShieldInit) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 130);
	}
	property float m_flGiveBuffOnce
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flDashAtTarget
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flAttackspeedIncrease
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}	
	
	
	public VoidSpeechless(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VoidSpeechless npc = view_as<VoidSpeechless>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "12500", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		func_NPCDeath[npc.index] = VoidSpeechless_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VoidSpeechless_OnTakeDamage;
		func_NPCThink[npc.index] = VoidSpeechless_ClotThink;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		VausMagicaGiveShield(npc.index, 5);
		npc.m_flGiveBuffOnce = 0.0;

		
		bool final = StrContains(data, "final_item") != -1;
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = MultiGlobalHealth;
			if(RaidModeScaling == 1.0) //Dont show scaling if theres none.
				RaidModeScaling = 0.0;
			else
				RaidModeScaling *= 1.5;
		}

		npc.m_iHealthBar = 1;
		if(i_RaidGrantExtra[npc.index] == 1)
		{
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{violet}Speechless{default}: It controlls us, it knows our immunity to chaos, kill us...");
				}
				case 1:
				{
					CPrintToChatAll("{violet}Speechless{default}: Help me..");
				}
				case 2:
				{
					CPrintToChatAll("{violet}Speechless{default}: Tell {blue}Sensal{default}.. his shields are useless...");
				}
				case 3:
				{
					CPrintToChatAll("{violet}Speechless{default}: I cannot controll my body...");
				}
			}
		}
		
		npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetVariantInt(8192);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 7);
		npc.m_flAttackspeedIncrease = 1.0;
		npc.StartPathing();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sum24_hazardous_vest/sum24_hazardous_vest.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sum23_medical_emergency/sum23_medical_emergency.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_medic.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		

		SetEntityRenderColor(npc.index, 200, 0, 200, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
		
		return npc;
	}
}

public void VoidSpeechless_ClotThink(int iNPC)
{
	VoidSpeechless npc = view_as<VoidSpeechless>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	ExpidonsanExplorerLifeLoss(npc);
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
		VoidSpeechlessDash(npc,GetGameTime(npc.index), flDistanceToTarget); 
		VoidSpeechlessSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{	
		ExpidonsanExplorerScaleAttackspeed(npc, 0.1);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VoidSpeechless_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VoidSpeechless npc = view_as<VoidSpeechless>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	ExpidonsanExplorerLifeLoss(npc);
	return Plugin_Changed;
}

public void VoidSpeechless_NPCDeath(int entity)
{
	VoidSpeechless npc = view_as<VoidSpeechless>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	ExpidonsaRemoveEffects(entity);
		
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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

void VoidSpeechlessDash(VoidSpeechless npc, float gameTime, float distance)
{
	if(npc.m_flJumpCooldown > gameTime)
		return;

	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			npc.FaceTowards(vecTarget, 15000.0);
			PluginBot_Jump(npc.index, vecTarget);
			npc.PlayIdleAlertSound();
			npc.m_flJumpCooldown = GetGameTime(npc.index) + 7.5;
			npc.PlaySuperJumpSound();
			float flPos[3];
			float flAng[3];
			int Particle_1;
			int Particle_2;
			npc.GetAttachment("foot_L", flPos, flAng);
			Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
			

			npc.GetAttachment("foot_R", flPos, flAng);
			Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void VoidSpeechlessSelfDefense(VoidSpeechless npc, float gameTime, int target, float distance)
{
	bool InAttackTry = false;
	if(npc.m_flAttackHappens)
	{
		InAttackTry = true;
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
					float damageDealt = 400.0;
					if(ShouldNpcDealBonusDamage(target))
					{
						damageDealt *= 10.0;
					}
					float DamageDoExtra = MultiGlobalHealth;
					if(DamageDoExtra != 1.0)
					{
						DamageDoExtra *= 1.5;
					}
					damageDealt *= DamageDoExtra; //Incase too many enemies, boost damage.



					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					Elemental_AddVoidDamage(target, npc.index, 200, true, true);
					VausMagicaGiveShield(npc.index, 1, false);

					if(ShouldNpcDealBonusDamage(target))
					{
						VausMagicaGiveShield(npc.index, 2, true);
					}

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
				InAttackTry = true;
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE", .SetGestureSpeed= (1.0 / npc.m_flAttackspeedIncrease));
						
				npc.m_flAttackHappens = gameTime + (0.25 * npc.m_flAttackspeedIncrease);
				npc.m_flDoingAnimation = gameTime + (0.25 * npc.m_flAttackspeedIncrease);
				npc.m_flNextMeleeAttack = gameTime + (0.6 * npc.m_flAttackspeedIncrease);
			}
		}
	}
	if(gameTime > npc.m_flAttackHappens_2)
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			VoidSpeechlessInitiateLaserAttack(npc.index, VecEnemy, WorldSpaceVec);
			npc.AddGesture("ACT_MP_THROW");
					
			npc.m_flDoingAnimation = gameTime + 0.75;
			npc.m_flAttackHappens_2 = gameTime + 1.75;
			npc.PlayRangedSound();
		}
	}
	if(InAttackTry)
		ExpidonsanExplorerScaleAttackspeed(npc, -0.1);
	else
		ExpidonsanExplorerScaleAttackspeed(npc, 0.1);

}



void VoidSpeechlessInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{

	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, VoidSpeechless_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(VectorTarget, trace);
		
		float lineReduce = 10.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(VectorStart, VectorTarget, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(VectorTarget, VectorStart, VectorTarget, curDist - lineReduce);
		}
	}
	delete trace;

	int red = 125;
	int green = 0;
	int blue = 125;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 100);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.6, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.4, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.2, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Glow, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(VoidSpeechlessInitiateLaserAttack_DamagePart, 50, pack);
}

void VoidSpeechlessInitiateLaserAttack_DamagePart(DataPack pack)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		LaserVarious_HitDetection[i] = false;
	}
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();

	int red = 125;
	int green = 25;
	int blue = 125;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 100);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(10);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, VoidSpeechless_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	float CloseDamage = 450.0;
	float FarDamage = 300.0;
	float MaxDistance = 2000.0;
	float playerPos[3];
	bool HitEnemy = false;
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (LaserVarious_HitDetection[victim] && IsValidEnemy(entity, victim, true))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < 0)
				damage *= -1.0;

			
			if(ShouldNpcDealBonusDamage(victim))
				damage *= 3.0;

			float DamageDoExtra = MultiGlobalHealth;
			if(DamageDoExtra != 1.0)
			{
				DamageDoExtra *= 1.5;
			}
			damage *= DamageDoExtra; //Incase too many enemies, boost damage.

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
			Elemental_AddVoidDamage(victim, entity, 200, true, true);
			HitEnemy = true;
			
		}
	}
	if(HitEnemy)
	{
		VausMagicaGiveShield(entity, 3, true);
	}
	delete pack;
}


public bool VoidSpeechless_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}

public bool VoidSpeechless_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}


void ExpidonsanExplorerLifeLoss(VoidSpeechless npc)
{
	if(!npc.m_flGiveBuffOnce && !npc.m_iHealthBar)
	{
		npc.m_flGiveBuffOnce = 1.0;
		ApplyStatusEffect(npc.index, npc.index, "Anti-Waves", 99999.0);
		ApplyStatusEffect(npc.index, npc.index, "Expidonsan Anger", 99999.0);
		ApplyStatusEffect(npc.index, npc.index, "Zilius Prime Technology", 99999.0);
		if(i_RaidGrantExtra[npc.index] == 1)
		{
			CPrintToChatAll("{violet}Speechless{default}: Zilius was right... Im sorry...\n{purple}It takes full controll of The expidonsans body.");
			CPrintToChatAll("{violet}The forgotten expidonsans suit activates its protocolls and repells the void as much as it can, as such, blocks all healing from itself.");
		}
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		npc.PlayShieldRegenSoundInit();
	}
}


void ExpidonsanExplorerScaleAttackspeed(VoidSpeechless npc, float Addition)
{
	npc.m_flAttackspeedIncrease += Addition;

	if(npc.m_flAttackspeedIncrease <= 0.33)
		npc.m_flAttackspeedIncrease = 0.33;

	if(npc.m_flAttackspeedIncrease >= 1.0)
		npc.m_flAttackspeedIncrease = 1.0;
		
	npc.m_flSpeed = 330.0 * npc.m_flAttackspeedIncrease;
}