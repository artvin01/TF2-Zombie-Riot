#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/scout_paincrticialdeath01.mp3",
	"vo/scout_paincrticialdeath02.mp3",
	"vo/scout_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/scout_battlecry01.mp3",
	"vo/scout_battlecry02.mp3",
	"vo/scout_battlecry03.mp3",
	"vo/scout_battlecry04.mp3",
	"vo/scout_battlecry05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/scatter_gun_double_shoot.wav",
};

void ApertureRepulsorPerfected_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	PrecacheModel("models/player/scout.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Perfected Aperture Repulsor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_repulsor_perfected");
	strcopy(data.Icon, sizeof(data.Icon), "scout");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return ApertureRepulsorPerfected(vecPos, vecAng, ally);
}
methodmap ApertureRepulsorPerfected < CClotBody
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
	
	
	public ApertureRepulsorPerfected(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureRepulsorPerfected npc = view_as<ApertureRepulsorPerfected>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM2");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ApertureRepulsorPerfected_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureRepulsorPerfected_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureRepulsorPerfected_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 290.0;
		npc.m_flAbilityOrAttack0 = 0.0;
		npc.m_iOverlordComboAttack = 0;
			
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_double_barrel.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
	
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/scout/hardhat.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/jul13_se_headset/jul13_se_headset_scout.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/scout/medieval_glory_armor/medieval_glory_armor.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/scout/pn2_longfall.mdl");

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void ApertureRepulsorPerfected_ClotThink(int iNPC)
{
	ApertureRepulsorPerfected npc = view_as<ApertureRepulsorPerfected>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
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
		ApertureRepulsorPerfectedSelfDefense(npc, GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ApertureRepulsorPerfected_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureRepulsorPerfected npc = view_as<ApertureRepulsorPerfected>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureRepulsorPerfected_NPCDeath(int entity)
{
	ApertureRepulsorPerfected npc = view_as<ApertureRepulsorPerfected>(entity);
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

void ApertureRepulsorPerfectedSelfDefense(ApertureRepulsorPerfected npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.75))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", false);
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
					npc.m_flNextMeleeAttack = gameTime + 4.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_BULLET, -1, _, vecHit);
					Custom_Knockback(npc.index, target, 800.0, true, true);
					Custom_Knockback(target, npc.index, 800.0, true, true);
					if(!HasSpecificBuff(target, "Solid Stance"))
						ApplyStatusEffect(npc.index, target, "Solid Stance", 2.0);	
				}
				delete swingTrace;
			}
		}
	}
}