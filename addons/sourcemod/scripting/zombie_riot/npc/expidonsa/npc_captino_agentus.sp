#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_SapperHitSounds[][] = {
	"weapons/rescue_ranger_charge_01.wav",
	"weapons/rescue_ranger_charge_02.wav",
};

static const char g_TeleportSound[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_MeleeAttackBackstabSounds[][] = {
	"player/spy_shield_break.wav",
};

void CaptinoAgentus_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackBackstabSounds)); i++) { PrecacheSound(g_MeleeAttackBackstabSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_SapperHitSounds)); i++) { PrecacheSound(g_SapperHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleportSound)); i++) { PrecacheSound(g_TeleportSound[i]); }
	PrecacheModel("models/player/spy.mdl");
}


methodmap CaptinoAgentus < CClotBody
{

	property float f_CaptinoAgentusTeleport
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}

	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeBackstabSound(int target)
	{
		EmitSoundToAll(g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		if(target <= MaxClients)
		{
			EmitSoundToClient(target, g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], target, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlaySapperHitSound() 
	{
		EmitSoundToAll(g_SapperHitSounds[GetRandomInt(0, sizeof(g_SapperHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlayTeleportSound() 
	{
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public CaptinoAgentus(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CaptinoAgentus npc = view_as<CaptinoAgentus>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "750", ally));
		
		i_NpcInternalId[npc.index] = EXPIDONSA_CAPTINOAGENTUS;
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.i_GunMode = 1;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_Think, CaptinoAgentus_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 340.0;
		b_TryToAvoidTraverse[npc.index] = true;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/heavy/pn2_knife_canteen.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/all_class/all_halo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2022_turncoat/hwn2022_turncoat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/fwk_seacaptain/fwk_seacaptain_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");


		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);


		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 500.0);

		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 500.0);

		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 500.0);

		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 500.0);
		
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 500.0);
		
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 500.0);
		
		SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 500.0);

		TeleportDiversioToRandLocation(npc.index);
		return npc;
	}
}

public void CaptinoAgentus_ClotThink(int iNPC)
{
	CaptinoAgentus npc = view_as<CaptinoAgentus>(iNPC);
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
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	npc.i_GunMode = 1;
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		bool IsEnemyBuilding = ShouldNpcDealBonusDamage(npc.m_iTarget);

		if(IsEnemyBuilding)
			npc.i_GunMode = 0;

		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
	
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			if(!IsEnemyBuilding)
			{
				float vPredictedPos[3];
				b_TryToAvoidTraverse[npc.index] = false;
				vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
				vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
				b_TryToAvoidTraverse[npc.index] = true;
				NPC_SetGoalVector(npc.index, vPredictedPos, true);
				if(GetGameTime(npc.index) > npc.f_CaptinoAgentusTeleport)
				{
					
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
					hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	

					float PreviousPos[3];
					PreviousPos = WorldSpaceCenter(npc.index);
					
					bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
					if(Succeed)
					{
						int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
						maxhealth /= 10;
						float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
						float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
						
						int spawn_index = Npc_Create(EXPIDONSA_DIVERSIONISTICO, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
						if(spawn_index > MaxClients)
						{
							Zombies_Currently_Still_Ongoing += 1;
							TeleportEntity(spawn_index, pos, ang);
							SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
							SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
							fl_Extra_Damage[spawn_index] = 1.5; //2x dmg so they are scary
						}
						npc.PlayTeleportSound();
						ParticleEffectAt(PreviousPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						ParticleEffectAt(WorldSpaceCenter(npc.index), "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
						npc.f_CaptinoAgentusTeleport = GetGameTime(npc.index) + 12.5;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.7; //so they cant instastab you!
					}
					else
					{
						npc.f_CaptinoAgentusTeleport = GetGameTime(npc.index) + 1.0; //Retry in a second
					}
				}
			}
			else
			{
				float vPredictedPos[3];
				vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		CaptinoAgentusSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	npc.PlayIdleAlertSound();
	CaptinoAgentusAnimationChange(npc);
}

public Action CaptinoAgentus_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CaptinoAgentus npc = view_as<CaptinoAgentus>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void CaptinoAgentus_NPCDeath(int entity)
{
	CaptinoAgentus npc = view_as<CaptinoAgentus>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(npc.index, SDKHook_Think, CaptinoAgentus_ClotThink);
		
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

void CaptinoAgentusSelfDefense(CaptinoAgentus npc, float gameTime, int target, float distance)
{
	if(npc.i_GunMode == 0)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			if(gameTime > npc.m_flDoingAnimation)
			{
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.AddGesture("ACT_MP_ATTACK_STAND_GRENADE_BUILDING");
			}

			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Ignore barricades
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 500.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlaySapperHitSound();
				} 
			}
			delete swingTrace;
		}
		return;
	}
	bool BackstabDone = false;
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;					
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.PlayMeleeSound();
				if(IsBehindAndFacingTarget(npc.index, npc.m_iTarget))
				{
					BackstabDone = true;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");	
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				}
				npc.m_flAttackHappens = 1.0;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Ignore barricades
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 100.0;

					if(BackstabDone)
					{
						npc.PlayMeleeBackstabSound(target);
						damageDealt *= 3.0;
					}

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}
}

void ResetCaptinoAgentusWeapon(CaptinoAgentus npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 0:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_p2rec/c_p2rec.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
	}
}

void CaptinoAgentusAnimationChange(CaptinoAgentus npc)
{
	switch(npc.i_GunMode)
	{
		case 1: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					fl_RangedArmor[npc.index] = 1.0;
					fl_MeleeArmor[npc.index] = 1.0;
					ResetCaptinoAgentusWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					fl_RangedArmor[npc.index] = 1.0;
					fl_MeleeArmor[npc.index] = 1.0;
					ResetCaptinoAgentusWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Sapper
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					fl_RangedArmor[npc.index] = 0.5;
					fl_MeleeArmor[npc.index] = 0.5;
					ResetCaptinoAgentusWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_BUILDING");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					fl_RangedArmor[npc.index] = 0.5;
					fl_MeleeArmor[npc.index] = 0.5;
					ResetCaptinoAgentusWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_BUILDING");
					npc.StartPathing();
				}	
			}
		}
	}

}
