#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsevere01.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere02.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere03.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere04.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere05.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/soldier_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts19.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts20.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts21.mp3"
};

static const char g_ReloadSound[] = "weapons/ar2/npc_ar2_reload.wav";

static const char g_RangeAttackSounds[] = "weapons/doom_rocket_launcher.wav";

void VictorianRaider_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Raider");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_raider");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_crit");
	data.IconCustom = false;
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
	PrecacheSound(g_ReloadSound);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/bots/soldier_boss/bot_soldier_boss.mdl");
	PrecacheModel("models/player/Soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianRaider(vecPos, vecAng, ally, data);
}

methodmap VictorianRaider < CClotBody
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
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.2);
	}

	public VictorianRaider(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianRaider npc = view_as<VictorianRaider>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.1", "2250", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = VictorianRaider_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianRaider_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianRaider_ClotThink;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "cow_mangler");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iMaxAmmo = 3;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flSpeed = 250.0;
		npc.StartPathing();
		
		if(StrContains(data, "maxclip") != -1)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "maxclip", "");
			npc.m_iMaxAmmo = StringToInt(buffers[0]);
		}
		npc.m_iAmmo = npc.m_iMaxAmmo;
		
		ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/sf14_beep_man/sf14_beep_man.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_soldier.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_armor/tw_soldierbot_armor.mdl");

		npc.m_iWearable6 = npc.EquipItem("head", "models/bots/soldier_boss/bot_soldier_boss.mdl");

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 50, 150, 150, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 50, 150, 150, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable3, 80, 50, 50, 255);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable5, 80, 50, 50, 255);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable6, 80, 50, 50, 255);
		return npc;
	}
}

static void VictorianRaider_ClotThink(int iNPC)
{
	VictorianRaider npc = view_as<VictorianRaider>(iNPC);
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
		switch(VictorianRaiderSelfDefense(npc, GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
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
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
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

static Action VictorianRaider_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianRaider npc = view_as<VictorianRaider>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictorianRaider_NPCDeath(int entity)
{
	VictorianRaider npc = view_as<VictorianRaider>(entity);
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

static int VictorianRaiderSelfDefense(VictorianRaider npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens || !npc.m_iAmmo)
	{
		if(!npc.m_flAttackHappens)
		{
			npc.m_flAttackHappens=gameTime+2.0;
			npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", true,_,_,0.5);
			npc.PlayReloadSound();
		}
		if(gameTime > npc.m_flAttackHappens)
		{
			npc.m_iAmmo = npc.m_iMaxAmmo;
			npc.m_flAttackHappens=0.0;
		}
		return 1;
	}
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(gameTime > npc.m_flNextRangedAttack && IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
			npc.PlayRangeSound();
			npc.FaceTowards(vecTarget, 20000.0);
			
			float projectile_speed = 500.0;
			float Hitdamage = 40.0;
			WorldSpaceCenter(npc.m_iTarget, vecTarget);

			if(NpcStats_VictorianCallToArms(npc.index))
				Hitdamage *= 2.0;
				
			npc.FireParticleRocket(vecTarget, Hitdamage , projectile_speed , 150.0 , "drg_cow_rockettrail_normal_blue");

			npc.m_flNextRangedAttack=gameTime+1.0;
			npc.m_iAmmo--;
			return 1;
		}
	}
	return (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.0 && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) ? 1 : 0;
}