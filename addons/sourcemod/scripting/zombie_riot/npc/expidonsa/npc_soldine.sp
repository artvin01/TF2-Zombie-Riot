#pragma semicolon 1
#pragma newdecls required



#define SOLDINE_NORMAL_MOVESPEED 330.0

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
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
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/soldier_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts19.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts20.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts21.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/rocket_shoot.wav",
};

static const char g_HurtArmorSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

void Soldine_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtArmorSounds)); i++) { PrecacheSound(g_HurtArmorSounds[i]); }
	PrecacheModel("models/player/soldier.mdl");
}


methodmap Soldine < CClotBody
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
	
	
	public Soldine(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Soldine npc = view_as<Soldine>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "7500", ally));
		
		i_NpcInternalId[npc.index] = EXPIDONSA_SOLDINE;

		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		SDKHook(npc.index, SDKHook_Think, Soldine_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

	//	Weapon
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/grfs_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_maniacs_manacles/hw2013_maniacs_manacles.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/eotl_winter_coat/eotl_winter_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Soldine_ClotThink(int iNPC)
{
	Soldine npc = view_as<Soldine>(iNPC);
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
		SoldineSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	SoldineAnimationChange(npc);
	npc.PlayIdleAlertSound();
}

public Action Soldine_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Soldine npc = view_as<Soldine>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		


	
	return Plugin_Changed;
}

public void Soldine_NPCDeath(int entity)
{
	Soldine npc = view_as<Soldine>(entity);
	/*
		Explode on death code here please

	*/
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(npc.index, SDKHook_Think, Soldine_ClotThink);
		
	
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

void SoldineAnimationChange(Soldine npc)
{
	if(npc.m_iChanged_WalkCycle != 5)
	{
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 4;
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		npc.m_flSpeed = 0.0;
		npc.StartPathing();
	}	
}

void SoldineSelfDefense(Soldine npc, float gameTime, int target, float distance)
{
	bool PathingLogic = false;
	//This ranged unit is more of an intruder, so we will get whatever enemy its pathing
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(target);

			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				//Play attack anim
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				
				float DamageRocket = 750.0;
				npc.PlayMeleeSound();
				npc.FireRocket(vecTarget, DamageRocket, 900.0);
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 2.5;
			}
			else
			{
				PathingLogic = true;
			}
		}
		else
		{
			PathingLogic = true;
		}
	}
	//allow moving if can attack and no enemy in sight, otherwise, dont move
	if(PathingLogic)
	{
		if(npc.m_iChanged_WalkCycle != 5)
		{
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 5;
			npc.StartPathing();
		}			
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.SetActivity("ACT_MP_STAND_PRIMARY");
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.StopPathing();
		}			
	}
}