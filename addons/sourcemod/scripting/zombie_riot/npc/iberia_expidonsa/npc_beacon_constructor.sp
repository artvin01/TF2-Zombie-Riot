#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};
static const char g_BuildSound[][] = {
	"ui/item_metal_weapon_drop.wav",
};

void IberiaBeaconConstructor_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_BuildSound)); i++) { PrecacheSound(g_BuildSound[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Beacon Constructor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_beacon_constructor");
	strcopy(data.Icon, sizeof(data.Icon), "engineer");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return IberiaBeaconConstructor(vecPos, vecAng, team, data);
}
methodmap IberiaBeaconConstructor < CClotBody
{
	property float m_flArmorToGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
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
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayBuildSound() 
	{
		EmitSoundToAll(g_BuildSound[GetRandomInt(0, sizeof(g_BuildSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		EmitSoundToAll(g_BuildSound[GetRandomInt(0, sizeof(g_BuildSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	
	public IberiaBeaconConstructor(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		IberiaBeaconConstructor npc = view_as<IberiaBeaconConstructor>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "600", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_BUILDING_DEPLOYED");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_flArmorToGive = StringToFloat(data);

		func_NPCDeath[npc.index] = view_as<Function>(IberiaBeaconConstructor_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(IberiaBeaconConstructor_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(IberiaBeaconConstructor_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_iChanged_WalkCycle = 1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 200.0;
		fl_TotalArmor[npc.index] = 0.5;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_toolbox/c_toolbox.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2022_more_gun_marshal/hwn2022_more_gun_marshal.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec23_sleuth_suit/dec23_sleuth_suit.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

public void IberiaBeaconConstructor_ClotThink(int iNPC)
{
	IberiaBeaconConstructor npc = view_as<IberiaBeaconConstructor>(iNPC);
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
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		if(npc.m_iChanged_WalkCycle == 1)
		{
			IberiaBeaconConstructorBuildObject(npc, flDistanceToTarget); 
		}
		else
		{
			IberiaBeaconConstructorSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action IberiaBeaconConstructor_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	IberiaBeaconConstructor npc = view_as<IberiaBeaconConstructor>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void IberiaBeaconConstructor_NPCDeath(int entity)
{
	IberiaBeaconConstructor npc = view_as<IberiaBeaconConstructor>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void IberiaBeaconConstructorBuildObject(IberiaBeaconConstructor npc, float distance)
{
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_spikewrench/c_spikewrench.mdl");
			int spawn_index = NPC_CreateByName("npc_iberia_beacon", -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				CClotBody npc1 = view_as<CClotBody>(spawn_index);
				npc1.m_flNextThinkTime = GetGameTime() + 2.0;
				fl_AbilityOrAttack[spawn_index] = fl_AbilityOrAttack[npc.index];
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				ScalingMultiplyEnemyHpGlobalScale(spawn_index);
			}
			npc.PlayBuildSound();
			npc.m_flSpeed = 300.0;
			fl_TotalArmor[npc.index] = 1.0;
		}
	}
}
void IberiaBeaconConstructorSelfDefense(IberiaBeaconConstructor npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 50.0;
					
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;

					int DamageType = DMG_CLUB;

					//prevents knockback!
					//gimic of new wavetype, but silenceable.
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DamageType, -1, _, vecHit);

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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.0);
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}