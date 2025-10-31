#pragma semicolon 1
#pragma newdecls required

#define UMBRAL_AUTOMATON_STEPRANGE 190.0
static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};
static const char g_SpawnActivateSound[][] = {
	"physics/concrete/rock_scrape_rough_loop1.wav",
};

static const char g_HurtSounds[][] = {
	"physics/concrete/rock_impact_hard1.wav",
	"physics/concrete/rock_impact_hard2.wav",
	"physics/concrete/rock_impact_hard3.wav",
	"physics/concrete/rock_impact_hard4.wav",
	"physics/concrete/rock_impact_hard5.wav",
	"physics/concrete/rock_impact_hard6.wav",
};


static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_miss.wav",
};


static int NPCId;

int Umbral_Automaton_ID()
{
	return NPCId;
}

void Umbral_Automaton_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_SpawnActivateSound));	   i++) { PrecacheSound(g_SpawnActivateSound[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel(COMBINE_CUSTOM_2_MODEL);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Automaton");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_automaton");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}



static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Umbral_Automaton(vecPos, vecAng, team, data);
}
methodmap Umbral_Automaton < CClotBody
{
	
	public void PlayHurtSound() 
	{
		int RandInt = GetRandomInt(0, sizeof(g_HurtSounds) - 1);
		EmitSoundToAll(g_HurtSounds[RandInt], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		EmitSoundToAll(g_HurtSounds[RandInt], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		EmitSoundToAll(g_HurtSounds[RandInt], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
	}
	public void PlayActivateSound(bool Activate) 
	{
		if(Activate)
			EmitSoundToAll(g_SpawnActivateSound[GetRandomInt(0, sizeof(g_SpawnActivateSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		else
			StopSound(this.index, SNDCHAN_AUTO, g_SpawnActivateSound[GetRandomInt(0, sizeof(g_SpawnActivateSound) - 1)]);
	}

	
	public void PlayMeleeSound()
	{
		if(b_IsGiant[this.index])
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		}
		else
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
		}
	}
	public void PlayMeleeHitSound() 
	{
		if(b_IsGiant[this.index])
		{
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
		}
		else
		{
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
			
		}
	}
	property float m_flEnemyDead
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flEnemyStandStill
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flRandomWakeupTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property int m_iWhichWakeupDo
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property float m_flRandomWakeupTimeFinish
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public Umbral_Automaton(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool IsGiantDo = StrContains(data, "giant") != -1;
		bool InstantWakeup = false;
		//hard coded im lazy
		if(StrContains(data, "giant_shadow_statue_4") != -1)
			InstantWakeup = true;
		else if(StrContains(data, "giant_shadow_statue_3") != -1)
			InstantWakeup = true;

		bool FoundstatueToReplace = false;
		
		int EntityFound = ReturnFoundEntityViaName(data);
		Umbral_Automaton npc;
		if(IsValidEntity(EntityFound))
		{
			FoundstatueToReplace = true;
			GetEntPropVector(EntityFound, Prop_Data, "m_vecAbsOrigin", vecPos);
			GetEntPropVector(EntityFound, Prop_Data, "m_angRotation", vecAng);
		}
		if(!IsGiantDo)
		{
			npc = view_as<Umbral_Automaton>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.15", "22500", ally,.isGiant = IsGiantDo));
		}
		else
		{
			npc = view_as<Umbral_Automaton>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "4.0", "22500", ally,.isGiant = IsGiantDo, .CustomThreeDimensions = {55.0, 55.0, 300.0}));
		}
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_flSpeed = 0.0;
		if(!FoundstatueToReplace)
		{
			if(b_IsGiant[npc.index])
				npc.m_flSpeed = 100.0;
			else
				npc.m_flSpeed = 150.0;

			npc.m_flRandomWakeupTime = 0.0;
			if(IsGiantDo)
			{
				npc.SetActivity("ACT_SHADOW_STATUE_BIG_WALK");
			}
			else
			{
				npc.SetActivity("ACT_SHADOW_STATUE_SMALL_WALK");
			}
			//just spawn and walk
		}
		else
		{
			RemoveSpawnProtectionLogic(npc.index, true);
			UmbralAutomaton_MakeInvulnerable(npc.index, false);
			//giant version only has 1
			if(IsGiantDo)
			{
				int WakeupWhich;
				if(StrContains(data, "wakeup_1") != -1)
				{
					WakeupWhich = 1;
					npc.SetActivity("ACT_SHADOW_STATUE_1");
				}
				else if(StrContains(data, "wakeup_3") != -1)
				{
					WakeupWhich = 3;
					npc.SetActivity("ACT_SHADOW_STATUE_3");
				}
				else if(StrContains(data, "wakeup_4") != -1)
				{
					WakeupWhich = 4;
					npc.SetActivity("ACT_SHADOW_STATUE_4");
				}
				else
				{
					WakeupWhich = 2;
					npc.SetActivity("ACT_SHADOW_STATUE_2");
				}
				npc.m_iWhichWakeupDo = WakeupWhich;
			}
			else
			{
				int WakeupWhich;
				if(StrContains(data, "wakeup_1") != -1)
				{
					WakeupWhich = 1;
					npc.SetActivity("ACT_SHADOW_STATUE_1");
				}
				else if(StrContains(data, "wakeup_3") != -1)
				{
					WakeupWhich = 3;
					npc.SetActivity("ACT_SHADOW_STATUE_3");
				}
				else if(StrContains(data, "wakeup_4") != -1)
				{
					WakeupWhich = 4;
					npc.SetActivity("ACT_SHADOW_STATUE_4");
				}
				npc.m_iWhichWakeupDo = WakeupWhich;

			}
			npc.m_flRandomWakeupTime = GetGameTime() + GetRandomFloat(5.0, 15.0);
			if(InstantWakeup)
				npc.m_flRandomWakeupTime = GetGameTime() + 0.1;
			DataPack pack;
			CreateDataTimer(npc.m_flRandomWakeupTime - GetGameTime(), Automaton_DisableBrushAndProp, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteString(data);
		
			
			DataPack pack2;
			CreateDataTimer(0.5, Automaton_ReEnableBrushAndProp, pack2, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			pack2.WriteCell(EntIndexToEntRef(npc.index));
			pack2.WriteString(data);
		}
		
		npc.m_flNextMeleeAttack = 0.0;
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Automaton_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Automaton_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Automaton_ClotThink);
		if(b_IsGiant[npc.index])
		{
			f_NpcTurnPenalty[npc.index] = 0.35;
		}
		func_NPCAnimEvent[npc.index] = view_as<Function>(Umbral_Automaton_AnimEvent);
		npc.StartPathing();

		b_thisNpcHasAnOutline[npc.index] = true; // NEVER outline
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);
		

		npc.m_bDissapearOnDeath = true;
		//dont allow self making
		
		i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;

		SetEntityRenderColor(npc.index, 105, 82, 117, 255);
		
		if(ally != TFTeam_Red && Rogue_Mode())
		{
			if(Rogue_GetUmbralLevel() == 0)
			{
				//when friendly and they still spawn as enemies, nerf.
				fl_Extra_Damage[npc.index] *= 0.5;
				fl_Extra_Speed[npc.index] *= 0.5;
			}
			else if(Rogue_GetUmbralLevel() == 4)
			{
				
				//if completly hated.
				//no need to adjust HP scaling, so it can be done here.
				fl_Extra_Damage[npc.index] *= 1.5;
				fl_Extra_Speed[npc.index] *= 1.1;
				fl_Extra_MeleeArmor[npc.index] *= 0.85;
				fl_Extra_RangedArmor[npc.index] *= 0.85;
			}
		}
		
		return npc;
	}
}

stock bool Umbral_AutomatonHealAlly(int entity, int victim, float &healingammount)
{
	if(i_NpcInternalId[entity] == i_NpcInternalId[victim])
		return true;

	ApplyStatusEffect(entity, victim, "Very Defensive Backup", 2.0);
	ApplyStatusEffect(entity, victim, "War Cry", 2.0);
	return false;
}
public void Umbral_Automaton_ClotThink(int iNPC)
{
	Umbral_Automaton npc = view_as<Umbral_Automaton>(iNPC);
	if(npc.m_flRandomWakeupTime)
	{
		if(npc.m_flRandomWakeupTime < GetGameTime())
		{
			UmbralAutomaton_MakeInvulnerable(npc.index, true);
			npc.m_bisWalking = false;
			switch(npc.m_iWhichWakeupDo)
			{
				case 1:
				{
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_SHADOW_STATUE_1_BREAKOUT");
					npc.m_flRandomWakeupTimeFinish = GetGameTime() + 2.6;
				}
				case 2:
				{
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_SHADOW_STATUE_2_BREAKOUT");
					npc.m_flRandomWakeupTimeFinish = GetGameTime() + 4.0;
				}
				case 3:
				{
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_SHADOW_STATUE_3_BREAKOUT");
					npc.m_flRandomWakeupTimeFinish = GetGameTime() + 4.0;
				}
				case 4:
				{
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_SHADOW_STATUE_4_BREAKOUT");
					npc.m_flRandomWakeupTimeFinish = GetGameTime() + 2.6;
				}
			}
			npc.PlayActivateSound(true);
			npc.m_flRandomWakeupTimeFinish -= 0.1;
			npc.m_flRandomWakeupTime = 0.0;
		}
		return;
	}
	if(npc.m_flRandomWakeupTimeFinish)
	{
		if(npc.m_flRandomWakeupTimeFinish < GetGameTime())
		{
			if(b_IsGiant[npc.index])
			{
				npc.SetActivity("ACT_SHADOW_STATUE_BIG_WALK");
			}
			else
			{
				npc.SetActivity("ACT_SHADOW_STATUE_SMALL_WALK");
			}
			npc.m_bisWalking = true;
			npc.m_flRandomWakeupTimeFinish = 0.0;
			if(b_IsGiant[npc.index])
				npc.m_flSpeed = 100.0;
			else
				npc.m_flSpeed = 150.0;
		}
		return;
	}
	if(npc.m_flEnemyDead)
	{
		if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		{
			return;
		}
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.3;
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float Range = 150.0;
		if(b_IsGiant[npc.index])
		{
			Range = 400.0;
		}
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, /*duration*/ 0.35, 10.0, 1.0, 1);	
		ExpidonsaGroupHeal(npc.index, Range, 99, 0.0, 1.0, false, Umbral_AutomatonHealAlly);
		return;
	}
	if(b_IsGiant[npc.index])
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		Explode_Logic_Custom(0.0, 0, npc.index, -1, pos ,UMBRAL_AUTOMATON_STEPRANGE * 1.5, 1.0, _, true, .FunctionToCallBeforeHit = UmbralAutomaton_VisionBlurr);
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flEnemyStandStill)
	{
		npc.m_flSpeed = 0.0;
		if(npc.m_flEnemyStandStill < GetGameTime(npc.index))
		{
			npc.StartPathing();
			npc.m_flEnemyStandStill = 0.0;
			if(b_IsGiant[npc.index])
			{
				npc.m_flSpeed = 100.0;
			}
			else
			{
				npc.m_flSpeed = 150.0;
			}
		}
	}
	if(npc.m_blPlayHurtAnimation)
	{
	//	npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(b_IsGiant[npc.index])
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		Explode_Logic_Custom(0.0, 0, npc.index, -1, pos ,UMBRAL_AUTOMATON_STEPRANGE, 1.0, _, true, .FunctionToCallBeforeHit = UmbralAutomaton_Terrified);
		spawnRing_Vectors(pos, UMBRAL_AUTOMATON_STEPRANGE * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 0, 0, 200, 1, /*duration*/ 0.11, 15.0, 3.0, 1);	
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
		if(b_IsGiant[npc.index])
		{
			Umbral_AutomatonSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
		}
		else
		{
			Umbral_Automaton_Melee_Small(npc,GetGameTime(npc.index), flDistanceToTarget); 
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Umbral_Automaton_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Automaton npc = view_as<Umbral_Automaton>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + (DEFAULT_HURTDELAY * 0.5);
		npc.m_blPlayHurtAnimation = true;
	}
	if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		npc.m_iBleedType = 0;
		npc.m_flEnemyDead = 1.0;
		npc.SetPlaybackRate(1.0);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 1);
		damage = 0.0;
		if(npc.m_iWhichWakeupDo != 999)
		{
			if(b_IsGiant[npc.index])
			{
				npc.SetActivity("ACT_SHADOW_STATUE_BIG_DIE");
			}
			else
			{
				npc.SetActivity("ACT_SHADOW_STATUE_SMALL_DIE");
			}
			npc.m_iWhichWakeupDo = 999;
			SetEntProp(npc.index, Prop_Data, "m_bSequenceLoops", false);
			UmbralAutomaton_MakeInvulnerable(npc.index, false);
			npc.PlayActivateSound(false);
		}
		return Plugin_Changed;
	}
	
	return Plugin_Changed;
}

public void Umbral_Automaton_NPCDeath(int entity)
{
	Umbral_Automaton npc = view_as<Umbral_Automaton>(entity);
	npc.PlayDeathSound();	
	npc.PlayActivateSound(false);
		
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

void Umbral_AutomatonSelfDefense(Umbral_Automaton npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens)
	{
		
		float vecSwingStart[3];

		GetAbsOrigin(npc.index, vecSwingStart);
		vecSwingStart[2] += 5.0;
		float vecForward[3], vecRight[3], vecTarget[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecForward); 	
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
			
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * 150.0;
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * 150.0;
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * 150.0;
		float Range = 250.0;
		spawnRing_Vectors(vecSwingEnd, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 200, 1, /*duration*/ 0.11, 20.0, 1.0, 1);	
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			TE_Particle("Explosion_ShockWave_01", vecSwingEnd, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("grenade_smoke_cycle", vecSwingEnd, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("hammer_bell_ring_shockwave", vecSwingEnd, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			npc.PlayMeleeHitSound();
			CreateEarthquake(vecSwingEnd, 2.0, Range * 2.2, 35.0, 255.0);
			Explode_Logic_Custom(15000.0, 0, npc.index, -1, vecSwingEnd ,Range, 1.0, _, true);
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.StopPathing();
				npc.m_flSpeed = 0.0;
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_SHADOW_STATUE_BIG_ATTACK",_,_,_,1.0);
				npc.m_flAttackHappens = gameTime + 1.5;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flNextMeleeAttack = gameTime + 10.5;
				npc.m_flEnemyStandStill = gameTime + 3.5;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
			}
		}
	}
}

void Umbral_Automaton_AnimEvent(int entity, int event)
{
	if(IsWalkEvent(event))
	{	
		Umbral_Automaton npc = view_as<Umbral_Automaton>(entity);
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		if(b_IsGiant[npc.index])
		{
			TE_Particle("Explosion_ShockWave_01", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
			npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
			npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
			npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
			CreateEarthquake(pos, 1.0, UMBRAL_AUTOMATON_STEPRANGE * 2.2, 16.0, 255.0);
			Explode_Logic_Custom(1500.0, 0, npc.index, -1, pos ,UMBRAL_AUTOMATON_STEPRANGE, 1.0, _, true, .FunctionToCallOnHit = UmbralAutomaton_KnockbackDo);
		}
		else
		{
			npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
			npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, STEPSOUND_GIANT, true);
		}
	}
}
/*

stock void Custom_Knockback(int attacker,
 int enemy,
  float knockback,
   bool ignore_attribute = false,
	bool override = false,
	 bool work_on_entity = false,
	 float PullDuration = 0.0,
	 bool ReceiveInfo = false,
	 float ReceivePullInfo[3] = {0.0,0.0,0.0},
	 float OverrideLookAng[3] ={0.0,0.0,0.0})
*/
void UmbralAutomaton_KnockbackDo(int entity, int victim, float damage, int weapon)
{
	float VecMe[3]; WorldSpaceCenter(entity, VecMe);
	float VecEnemy[3]; WorldSpaceCenter(victim, VecEnemy);

	float AngleVec[3];
	MakeVectorFromPoints(VecMe, VecEnemy, AngleVec);
	GetVectorAngles(AngleVec, AngleVec);

	AngleVec[0] = -45.0;
	Custom_Knockback(entity, victim, 500.0, true, true, true, .OverrideLookAng = AngleVec);
}
float UmbralAutomaton_VisionBlurr(int attacker, int victim, float &damage, int weapon)
{
	if(victim > MaxClients)
		return 0.0;
	
	float vecTarget[3]; GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", vecTarget);

	float VecSelfNpc[3]; GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc);
	flDistanceToTarget = (flDistanceToTarget / UMBRAL_AUTOMATON_STEPRANGE * 2.0);
	flDistanceToTarget *= 1.3;
	if(flDistanceToTarget <= 0.0)
		flDistanceToTarget = 0.0;
	if(flDistanceToTarget >= 1.0)
		flDistanceToTarget = 1.0;
	flDistanceToTarget *= 200.0;
	UTIL_ScreenFade(victim, 600, 0, 0x0001, 0, 0, 0, RoundToNearest(flDistanceToTarget));
	return 0.0;
}
float UmbralAutomaton_Terrified(int attacker, int victim, float &damage, int weapon)
{
	ApplyStatusEffect(attacker, victim, "Terrified", 1.0);

	return 0.0;
}

void UmbralAutomaton_MakeInvulnerable(int statue, bool Wakeup)
{
	if(Wakeup)
	{

		b_NpcIsInvulnerable[statue] = false;
		b_HideHealth[statue] = false;
		b_NoHealthbar[statue] = 0;
		b_CannotBeHeadshot[statue] = false;
		b_CannotBeBackstabbed[statue] = false;
		b_DoNotUnStuck[statue] = false;
		b_ThisEntityIgnored[statue] = false;
		RemoveSpecificBuff(statue, "Fluid Movement");
		RemoveSpecificBuff(statue, "Solid Stance");
		RemoveSpecificBuff(statue, "Clear Head");
		return;
	}
	b_ThisEntityIgnored[statue] = true;
	b_NpcIsInvulnerable[statue] = true;
	b_HideHealth[statue] = true;
	b_NoHealthbar[statue] = 2;
	b_CannotBeHeadshot[statue] = true;
	b_CannotBeBackstabbed[statue] = true;
	b_DoNotUnStuck[statue] = true;
	ApplyStatusEffect(statue, statue, "Fluid Movement", 999999.0);	
	ApplyStatusEffect(statue, statue, "Solid Stance", 999999.0);	
	ApplyStatusEffect(statue, statue, "Clear Head", 999999.0);	
}



static Action Automaton_DisableBrushAndProp(Handle timer, DataPack pack)
{
	pack.Reset();
	char entity_name[255];
	char brush_name[255];
	pack.ReadString(entity_name, sizeof(entity_name));
	Format(brush_name, sizeof(brush_name), "%s_brush", entity_name);

	int Disable;
	Disable = ReturnFoundEntityViaName(entity_name);
	if(IsValidEntity(Disable))
		AcceptEntityInput(Disable, "Disable");
	Disable = ReturnFoundEntityViaName(brush_name);
	if(IsValidEntity(Disable))
		AcceptEntityInput(Disable, "Disable");

	Recalculate_NavBlockers();
	return Plugin_Stop;
}

static Action Automaton_ReEnableBrushAndProp(Handle timer, DataPack pack)
{
	pack.Reset();
	int Statue = pack.ReadCell();
	if(IsValidEntity(Statue))
	{
		return Plugin_Continue;
	}
	
	char entity_name[255];
	char brush_name[255];
	pack.ReadString(entity_name, sizeof(entity_name));
	Format(brush_name, sizeof(brush_name), "%s_brush", entity_name);

	int Enable;
	Enable = ReturnFoundEntityViaName(entity_name);
	if(IsValidEntity(Enable))
		AcceptEntityInput(Enable, "Enable");
	Enable = ReturnFoundEntityViaName(brush_name);
	if(IsValidEntity(Enable))
		AcceptEntityInput(Enable, "Enable");
	return Plugin_Stop;
}

			
stock int ReturnFoundEntityViaName(const char[] name)
{
	for(int entity = 0; entity <= MAXENTITIES; entity++)
	{
		if(IsValidEntity(entity))
		{
			static char buffer[255];
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				return entity;
			}
		}
	}
	return 0;
}


void Umbral_Automaton_Melee_Small(Umbral_Automaton npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))//Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				int target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 2000.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.5;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.85))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_SHADOW_STATUE_SMALL_ATTACK");
				npc.StopPathing();
				npc.m_flSpeed = 0.0;
						
				npc.m_flAttackHappens = gameTime + 0.5;
				npc.m_flDoingAnimation = gameTime + 0.5;
				npc.m_flEnemyStandStill = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
			}
		}
	}
}



void Recalculate_NavBlockers()
{
	int entity = CreateEntityByName("tf_point_nav_interface");

	if (!IsValidEntity(entity))
		return;
	AcceptEntityInput(  entity, "RecomputeBlockers" );

	CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}