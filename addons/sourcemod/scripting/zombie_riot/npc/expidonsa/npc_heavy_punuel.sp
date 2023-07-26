#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	")vo/demo_battlecry01.mp3",
	")vo/demo_battlecry02.mp3",
	")vo/demo_battlecry03.mp3",
	")vo/demo_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/airboat/airboat_gun_energy1.wav",
	"weapons/airboat/airboat_gun_energy2.wav",
};

static const char g_HurtArmorSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

void HeavyPunuel_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtArmorSounds)); i++) { PrecacheSound(g_HurtArmorSounds[i]); }
	PrecacheModel("models/player/demo.mdl");
}


methodmap HeavyPunuel < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);

	}
	public void PlayHurtArmorSound() 
	{
		EmitSoundToAll(g_HurtArmorSounds[GetRandomInt(0, sizeof(g_HurtArmorSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);

	}
	property float m_flArmorCountMax
	{
		public get()							{ return fl_NextRangedAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttack[this.index] = TempValueForProperty; }
	}
	property float m_flArmorCount
	{
		public get()							{ return fl_NextRangedAttackHappening[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttackHappening[this.index] = TempValueForProperty; }
	}
	property bool m_bArmorGiven
	{
		public get()							{ return b_Gunout[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Gunout[this.index] = TempValueForProperty; }
	}
	
	
	public HeavyPunuel(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		HeavyPunuel npc = view_as<HeavyPunuel>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.5", "1500", ally, false, true));
		
		i_NpcInternalId[npc.index] = EXPIDONSA_HEAVYPUNUEL;
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		/*
			Slow and has armor
			once armor breaks, gains heavy speed
		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_bArmorGiven = false;
		
		SDKHook(npc.index, SDKHook_Think, HeavyPunuel_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 200.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);


		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_crossing_guard/c_crossing_guard.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/player/items/heavy/dex_sarifarm/dex_sarifarm.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop_partner/player/items/spy/dex_belltower/dex_belltower.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		return npc;
	}
}

public void HeavyPunuel_ClotThink(int iNPC)
{
	HeavyPunuel npc = view_as<HeavyPunuel>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(!npc.m_bArmorGiven)
	{
		npc.m_bArmorGiven = true;
		int flMaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		npc.m_flArmorCount = float(flMaxHealth) * 2.0;
		npc.m_flArmorCountMax = float(flMaxHealth) * 2.0;
	}
	if(npc.m_flArmorCount > 0.0)
	{
		npc.m_flSpeed = 200.0;
	}
	else
	{
		npc.m_flSpeed = 340.0;
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
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
	
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		HeavyPunuelSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action HeavyPunuel_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	HeavyPunuel npc = view_as<HeavyPunuel>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(npc.m_flArmorCount > 0.0)
	{
		npc.m_flArmorCount -= damage * 0.9;
		damage *= 0.1; //negate damage heavy.
		npc.PlayHurtArmorSound();
		float percentageArmorLeft = npc.m_flArmorCount / npc.m_flArmorCountMax;

		if(percentageArmorLeft <= 0.0)
		{
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
		}
		else if(percentageArmorLeft <= 0.3)
		{
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
		}
		else if(percentageArmorLeft <= 0.6)
		{
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
		}
	}
	else
	{
		if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}		
	}


	
	return Plugin_Changed;
}

public void HeavyPunuel_NPCDeath(int entity)
{
	HeavyPunuel npc = view_as<HeavyPunuel>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(npc.index, SDKHook_Think, HeavyPunuel_ClotThink);
		
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void HeavyPunuelSelfDefense(HeavyPunuel npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 55.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 4.0;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
				delete swingTrace;
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 1.55, 2.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}