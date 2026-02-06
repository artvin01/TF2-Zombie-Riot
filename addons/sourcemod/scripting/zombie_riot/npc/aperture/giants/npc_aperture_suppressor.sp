#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"mvm/giant_common/giant_common_explodes_01",
	"mvm/giant_common/giant_common_explodes_02",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/mght/demoman_mvm_m_gibberish01.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish02.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish03.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish04.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish05.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish06.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish07.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish08.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish09.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish10.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish11.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish12.mp3",
	"vo/mvm/mght/demoman_mvm_m_gibberish13.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/mght/demoman_mvm_m_specialcompleted01.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted02.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted03.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted04.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted05.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted06.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted07.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted08.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted09.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted10.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted11.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted12.mp3",
};

static const char g_AngrySounds[][] = {
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts01.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts02.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts03.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts04.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts05.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts06.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts07.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts08.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts09.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts10.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts11.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts12.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts13.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts14.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts15.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts16.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};


void ApertureSuppressor_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_AngrySounds)); i++) { PrecacheSound(g_AngrySounds[i]); }
	PrecacheModel("models/bots/demo_boss/bot_demo_boss.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Suppressor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_suppressor");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_punel");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ApertureSuppressor(vecPos, vecAng, team);
}

methodmap ApertureSuppressor < CClotBody
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

	public void PlayAngrySound() 
	{
		EmitSoundToAll(g_AngrySounds[GetRandomInt(0, sizeof(g_AngrySounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);

	}
	
	
	public ApertureSuppressor(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureSuppressor npc = view_as<ApertureSuppressor>(CClotBody(vecPos, vecAng, "models/bots/demo_boss/bot_demo_boss.mdl", "1.4", "3000", ally, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flRangedSpecialDelay = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		
		func_NPCDeath[npc.index] = ApertureSuppressor_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ApertureSuppressor_OnTakeDamage;
		func_NPCThink[npc.index] = ApertureSuppressor_ClotThink;
		
		
		npc.StartPathing();
		npc.m_flSpeed = 200.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);


		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_pickaxe/c_pickaxe_s2.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/all_class/all_class_oculus_demo_on.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/sbox2014_juggernaut_jacket/sbox2014_juggernaut_jacket.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/invasion_life_support_system/invasion_life_support_system.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_demo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/demo/sum20_hazard_headgear/sum20_hazard_headgear.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable1, 255, 150, 150, 255);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void ApertureSuppressor_ClotThink(int iNPC)
{
	ApertureSuppressor npc = view_as<ApertureSuppressor>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_fbRangedSpecialOn && npc.m_flNextRangedAttack < GetGameTime(npc.index))
	{
		npc.m_fbRangedSpecialOn = false;
	}
	if(npc.m_fbRangedSpecialOn)
	{
		npc.m_flSpeed = 350.0;
		ExtinguishTarget(npc.m_iWearable1);
		IgniteTargetEffect(npc.m_iWearable1);
	}
	else
	{
		ExtinguishTarget(npc.m_iWearable1);
		npc.m_flSpeed = 200.0;
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
		ApertureSuppressorSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ApertureSuppressor_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureSuppressor npc = view_as<ApertureSuppressor>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
	{
		npc.m_fbRangedSpecialOn = true;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 7.5;
		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 30.0;
		npc.PlayAngrySound();
		float flPos[3];
		float flAng[3];
		GetAttachment(victim, "head", flPos, flAng);		
		int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 7.5);
		SetParent(victim, particler, "head");
		npc.m_iWearable7 = particler;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}	


	
	return Plugin_Changed;
}

public void ApertureSuppressor_NPCDeath(int entity)
{
	ApertureSuppressor npc = view_as<ApertureSuppressor>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void ApertureSuppressorSelfDefense(ApertureSuppressor npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 75.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 4.0;
					if(npc.m_fbRangedSpecialOn)
						damageDealt *= 2.0;


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
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
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

				float timetime = 1.2;

				if(npc.m_fbRangedSpecialOn)
					timetime *= 0.5;

				npc.m_flNextMeleeAttack = gameTime + timetime;
			}
		}
	}
}