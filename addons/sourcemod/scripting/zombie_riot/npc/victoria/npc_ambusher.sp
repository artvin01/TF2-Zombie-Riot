#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static const char g_ReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_charge_sound[][] = {
	"misc/halloween/spell_blast_jump.wav",
};


void VIctorianAmbusher_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ReloadSound)); i++) { PrecacheSound(g_ReloadSound[i]); }
	for (int i = 0; i < (sizeof(g_charge_sound)); i++) { PrecacheSound(g_charge_sound[i]); }
	PrecacheModel("models/player/sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Brassbunker Ambusher");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ambusher");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_ambusher");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VIctorianAmbusher(vecPos, vecAng, ally);
}

methodmap VIctorianAmbusher < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound[GetRandomInt(0, sizeof(g_ReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayChargeSound() 
	{
		EmitSoundToAll(g_charge_sound[GetRandomInt(0, sizeof(g_charge_sound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80, 85));

	}

	public VIctorianAmbusher(float vecPos[3], float vecAng[3], int ally)
	{
		VIctorianAmbusher npc = view_as<VIctorianAmbusher>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "12000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		func_NPCDeath[npc.index] = view_as<Function>(VIctorianAmbusher_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VIctorianAmbusher_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VIctorianAmbusher_ClotThink);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_iOverlordComboAttack = 30;
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/invasion_final_frontiersman/invasion_final_frontiersman.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/fall2013_kyoto_rider/fall2013_kyoto_rider.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/invasion_jupiter_jetpack/invasion_jupiter_jetpack.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2022_cabinet_mann/hwn2022_cabinet_mann.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		TeleportDiversioToRandLocation(npc.index,_,1250.0, 750.0);

		return npc;
	}
}

public void VIctorianAmbusher_ClotThink(int iNPC)
{
	VIctorianAmbusher npc = view_as<VIctorianAmbusher>(iNPC);
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
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		int NowIDO = VIctorianAmbusherSelfDefense(npc.index, npc.m_iTarget, GetGameTime(npc.index));
		switch(NowIDO)
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.StartPathing();
					npc.m_flSpeed = 200.0;
				}
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.StartPathing();
					npc.m_flSpeed = 300.0;
				}
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
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.StartPathing();
					npc.m_flSpeed = 150.0;
				}
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
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.StartPathing();
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.5;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,0.37);
					npc.m_flSpeed = 350.0;
					npc.PlayReloadSound();

					DataPack ReloadAmmo;
					CreateDataTimer(2.5, Timer_Runaway, ReloadAmmo, TIMER_FLAG_NO_MAPCHANGE);
					ReloadAmmo.WriteCell(npc.index);
					ReloadAmmo.WriteCell(30);
				}
				int Enemy_I_See;
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, Enemy_I_See)) 
				{
					float vBackoffPos[3];
					
					BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
					
					npc.SetGoalVector(vBackoffPos, true);
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Timer_Runaway(Handle timer, DataPack pack)
{
	pack.Reset();
	VIctorianAmbusher npc = view_as<VIctorianAmbusher>(pack.ReadCell());
	if(IsValidEntity(npc.index)) npc.m_iOverlordComboAttack = pack.ReadCell();
	return Plugin_Stop;
}

public Action VIctorianAmbusher_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VIctorianAmbusher npc = view_as<VIctorianAmbusher>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VIctorianAmbusher_NPCDeath(int entity)
{
	VIctorianAmbusher npc = view_as<VIctorianAmbusher>(entity);
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

int VIctorianAmbusherSelfDefense(int iNPC, int target, float gameTime)
{
	VIctorianAmbusher npc = view_as<VIctorianAmbusher>(iNPC);
	if(npc.m_iOverlordComboAttack < 1)
		return 3;
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(npc.m_flCharge_delay < GetGameTime(npc.index))
	{
		if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
		{
			npc.PlayChargeSound();
			if(NpcStats_VictorianCallToArms(npc.index))
			{
				npc.m_flCharge_delay = GetGameTime(npc.index) + 3.5;
			}
			else
			{
				npc.m_flCharge_delay = GetGameTime(npc.index) + 90.0;
			}
			
			PluginBot_Jump(npc.index, vecTarget);
			float flPos[3];
			float flAng[3];
			int Particle_1;
			npc.GetAttachment("flag", flPos, flAng);
			Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "flag", {0.0,0.0,0.0});
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", true);
				npc.m_iTarget = Enemy_I_See;
				npc.m_iOverlordComboAttack--;
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, vecHit, false);
					npc.m_flNextMeleeAttack = gameTime + 0.1;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 10.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
			return 2;
		}
		return 1;
	}
	return 0;
}