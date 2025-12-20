#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/demoman_negativevocalization01.mp3",
	"vo/demoman_negativevocalization02.mp3",
	"vo/demoman_negativevocalization03.mp3",
	"vo/demoman_negativevocalization04.mp3",
	"vo/demoman_negativevocalization05.mp3",
	"vo/demoman_negativevocalization06.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/demoman_moveup01.mp3",
	"vo/demoman_moveup02.mp3",
	"vo/demoman_moveup03.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static const char g_AngerSounds[][] = {
	"vo/taunts/demoman_taunts01.mp3",
	"vo/taunts/demoman_taunts02.mp3",
	"vo/taunts/demoman_taunts03.mp3",
	"vo/taunts/demoman_taunts04.mp3",
	"vo/taunts/demoman_taunts05.mp3",
	"vo/taunts/demoman_taunts06.mp3",
	"vo/taunts/demoman_taunts07.mp3",
	"vo/taunts/demoman_taunts08.mp3"
};

static const char g_MeleeHitSounds[] = "weapons/halloween_boss/knight_axe_hit.wav";

void Victorian_Charger_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Charger");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_charger");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_charger");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheModel("models/player/demo.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianCharger(vecPos, vecAng, ally);
}

methodmap VictorianCharger < CClotBody
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
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound() 
	{
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	property float m_flSpawnTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public VictorianCharger(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianCharger npc = view_as<VictorianCharger>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = VictorianCharger_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianCharger_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianCharger_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "bushwacka");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flSpeed = 50.0;
		npc.m_flSpawnTime = GetGameTime();
		npc.Anger = false;
		npc.StartPathing();
		
		npc.m_flMeleeArmor = 1.5;
		npc.m_flRangedArmor = 0.9;
		
		fl_ruina_battery_max[npc.index] = 20.0;
		fl_ruina_battery[npc.index] = 0.0;
		
		ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/riflemans_rallycap/riflemans_rallycap_demo.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_stunt_suit_style2/hwn2023_stunt_suit_style2.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 80, 100, 175, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable3, 80, 50, 50, 255);

		return npc;
	}
}

static void VictorianCharger_ClotThink(int iNPC)
{
	VictorianCharger npc = view_as<VictorianCharger>(iNPC);
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

	float TimeMultiplier = 1.0;
	TimeMultiplier = GetGameTime(npc.index) - npc.m_flSpawnTime;

	TimeMultiplier *= 0.50;

	if(TimeMultiplier > 20.0)
	{
		TimeMultiplier = 20.0;
	}
	else if(TimeMultiplier > 8.0)
	{
		if(!npc.Anger)
		{
			KillFeed_SetKillIcon(npc.index, "splendid_screen");
			npc.PlayAngerSound();
			npc.Anger = true;
		}
	}
	else if(TimeMultiplier < 1.0)
	{
		KillFeed_SetKillIcon(npc.index, "bushwacka");
		TimeMultiplier = 1.0;
		npc.Anger = false;
	}
	fl_ruina_battery[npc.index] = TimeMultiplier;
	npc.m_flSpeed = (50.0 * TimeMultiplier);

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
		VictorianChargerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictorianCharger_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianCharger npc = view_as<VictorianCharger>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictorianCharger_NPCDeath(int entity)
{
	VictorianCharger npc = view_as<VictorianCharger>(entity);
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

static void VictorianChargerSelfDefense(VictorianCharger npc, float gameTime, int target, float distance)
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
					float damageDealt = 4.0;
					damageDealt *= (npc.m_flSpeed * 0.1);
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.45;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
			npc.m_flSpawnTime = gameTime;
		}
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) * 0.6)
		{
			int Enemy_I_See;
			
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
						
				npc.m_flAttackHappens = gameTime + 0.1;
				npc.m_flDoingAnimation = gameTime + 0.1;
				npc.m_flNextMeleeAttack = gameTime + 2.4;
			}
		}
	}
}