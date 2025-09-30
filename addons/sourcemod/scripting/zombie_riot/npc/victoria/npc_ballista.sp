#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/soldier_negativevocalization01.mp3",
	")vo/soldier_negativevocalization02.mp3",
	")vo/soldier_negativevocalization03.mp3",
	")vo/soldier_negativevocalization04.mp3",
	")vo/soldier_negativevocalization05.mp3",
	")vo/soldier_negativevocalization06.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3",
	"vo/compmode/cm_soldier_pregamefirst_03.mp3"
};

static const char g_ReloadSound[] = "weapons/ar2/npc_ar2_reload.wav";

static const char g_RangeAttackSounds[] = "weapons/rocket_shoot.wav";

void VictorianBallista_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ballista");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ballista");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_ballistas");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheSound(g_ReloadSound);
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianBallista(vecPos, vecAng, ally);
}

methodmap VictorianBallista < CClotBody
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
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, 80, _, 0.3, 80);
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public VictorianBallista(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianBallista npc = view_as<VictorianBallista>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = view_as<Function>(VictorianBallista_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictorianBallista_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictorianBallista_ClotThink);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_iOverlordComboAttack = 3;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "passtime_pass");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_directhit/c_directhit.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/riflemans_rallycap/riflemans_rallycap_soldier.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/sf14_the_supernatural_stalker/sf14_the_supernatural_stalker.mdl");

		SetEntityRenderColor(npc.index, 80, 50, 50, 255);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 50, 150, 150, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 50, 150, 150, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable4, 80, 50, 50, 255);
		return npc;
	}
}

static void VictorianBallista_ClotThink(int iNPC)
{
	VictorianBallista npc = view_as<VictorianBallista>(iNPC);
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
	if(npc.m_iOverlordComboAttack <= 0)
	{
		if(npc.m_iChanged_WalkCycle != 6)
		{
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				if(NpcStats_VictorianCallToArms(npc.index))
				{
					npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 1.5;
				}
				else
				{
					npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 2.0;
				}
			}
			else
			{
				npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 4.0;
			}
			
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 6;
			npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", true,_,_,0.5);
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			npc.PlayReloadSound();
			npc.m_iOverlordComboAttack = 3;
		}
		return;
	}
	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index))
	{
		return;
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
		VictorianBallistaSelfDefense(npc,GetGameTime(npc.index)); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictorianBallista_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianBallista npc = view_as<VictorianBallista>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictorianBallista_NPCDeath(int entity)
{
	VictorianBallista npc = view_as<VictorianBallista>(entity);
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

static void VictorianBallistaSelfDefense(VictorianBallista npc, float gameTime)
{
	int target;
	//some Ranged units will behave differently.
	//not this one.
	target = npc.m_iTarget;
	if(!IsValidEnemy(npc.index,target))
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_MP_STAND_PRIMARY");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}	
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
				{	
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
					npc.m_iOverlordComboAttack --;
					npc.PlayRangeSound();
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						npc.PlayRangeSound();
						//after we fire, we will have a short delay beteween the actual laser, and when it happens
						//This will predict as its relatively easy to dodge
						float projectile_speed = 900.0;

						WorldSpaceCenter(target, vecTarget);

						npc.FaceTowards(vecTarget, 20000.0);
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
						npc.FireParticleRocket(vecTarget, 20.0 , projectile_speed , 150.0 , "flaregun_energyfield_red");
						npc.PlayIdleAlertSound();
					}
					delete swingTrace;
				}
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.m_flSpeed = 250.0;
				npc.StartPathing();
			}
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
	}
}