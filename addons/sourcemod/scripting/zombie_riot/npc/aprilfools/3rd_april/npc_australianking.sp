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

static const char g_MeleeAttackSounds[][] = {
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

void AustralianKing_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "King of Australia");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_australianking");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AustralianKing(vecPos, vecAng, team);
}
methodmap AustralianKing < CClotBody
{
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
	property float m_flAustralianKingStartDidgeridoo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flAustralianKingDoingDidgeridoo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flAustralianKingStopDidgeridoo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flSpiderSummon
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	
	
	public AustralianKing(float vecPos[3], float vecAng[3], int ally)
	{
		AustralianKing npc = view_as<AustralianKing>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAustralianKingStartDidgeridoo = GetGameTime(npc.index) + 7.0;
		npc.m_flAustralianKingDoingDidgeridoo = GetGameTime(npc.index) + 9.0;
		npc.m_flSpiderSummon = GetGameTime(npc.index) + 9.0;
		npc.m_flAustralianKingStopDidgeridoo = GetGameTime(npc.index) + 15.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(AustralianKing_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AustralianKing_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AustralianKing_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 280.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_machete/c_machete.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/demo/crown.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void AustralianKing_ClotThink(int iNPC)
{
	AustralianKing npc = view_as<AustralianKing>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	//Australian Spidors
	if(npc.m_flSpiderSummon < GetGameTime())
	{
		float pos2[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos2);
		int summon = NPC_CreateByName("npc_spider", -1, pos2, {0.0,0.0,0.0}, GetTeam(npc.index));
		if(IsValidEntity(summon))
		{
			AustralianKing npcsummon = view_as<AustralianKing>(summon);
			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;

			fl_Extra_Damage[npcsummon.index] = fl_Extra_Damage[npc.index];
			fl_Extra_Damage[npcsummon.index] *= 1.5;
			npcsummon.m_iTargetAlly = npc.index;
			SetEntProp(summon, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/40);
			SetEntProp(summon, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)/40);
			NpcStats_CopyStats(npc.index, summon);
		}
		npc.m_flSpiderSummon = GetGameTime(npc.index) + 0.5;
	}
	//Start Didgeridoo
	if(npc.m_flAustralianKingStartDidgeridoo < GetGameTime())
	{
		npc.StopPathing();
		npc.AddActivityViaSequence("taunt_didgeridrongo");
		npc.SetCycle(10.01);
		npc.SetPlaybackRate(1.2);
		npc.m_flNextMeleeAttack = GetGameTime() + 999.0;
	}
	//Doing Didgeridoo
	if(npc.m_flAustralianKingDoingDidgeridoo < GetGameTime())
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		Explode_Logic_Custom(0.0, 0, npc.index, -1, pos , 250.0 * 2.0, 1.0, _, true, .FunctionToCallBeforeHit = UmbralAutomaton_Terrified);
		spawnRing_Vectors(pos, 250.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 255, 1, /*duration*/ 0.11, 5.0, 3.0, 1);
		npc.AddActivityViaSequence("taunt_didgeridrongo");
		npc.SetCycle(10.01);
		npc.SetPlaybackRate(0.1);
	}
	//Stop Didgeridoo
	if(npc.m_flAustralianKingStopDidgeridoo < GetGameTime())
	{
		npc.m_flAustralianKingStartDidgeridoo = GetGameTime(npc.index) + 7.0;
		npc.m_flAustralianKingDoingDidgeridoo = GetGameTime(npc.index) + 9.0;
		npc.m_flSpiderSummon = GetGameTime(npc.index) + 9.0;
		npc.m_flAustralianKingStopDidgeridoo = GetGameTime(npc.index) + 15.0;
		npc.StartPathing();
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.m_flNextMeleeAttack = GetGameTime() + 1.0;
	}

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
		AustralianKingSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action AustralianKing_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AustralianKing npc = view_as<AustralianKing>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void AustralianKing_NPCDeath(int entity)
{
	AustralianKing npc = view_as<AustralianKing>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void AustralianKingSelfDefense(AustralianKing npc, float gameTime, int target, float distance)
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
					float damageDealt = 100.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;

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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}