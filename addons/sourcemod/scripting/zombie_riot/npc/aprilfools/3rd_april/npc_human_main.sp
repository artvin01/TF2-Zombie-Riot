#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/engineer_taunts06.mp3",
	"vo/engineer_meleedare01.mp3",
	"vo/engineer_meleedare02.mp3",
	"vo/engineer_meleedare03.mp3",
};


static char g_RangedAttackSounds[][] = {
	"weapons/shotgun/shotgun_dbl_fire.wav",
};
void HumanMain_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSound("weapons/minigun_spin.wav");
	PrecacheSound("weapons/minigun_shoot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Human Main");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_human_main");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPC_Add(data);

}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return HumanMain(vecPos, vecAng, team);
}

methodmap HumanMain < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(6.0, 8.0);
		
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
	public void PlayGunSound() 
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public HumanMain(float vecPos[3], float vecAng[3], int ally)
	{
		HumanMain npc = view_as<HumanMain>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "10000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		func_NPCDeath[npc.index] = HumanMain_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = HumanMain_OnTakeDamage;
		func_NPCThink[npc.index] = HumanMain_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		
		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);

		SetVariantInt(16);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2023_constructors_cover/hwn2023_constructors_cover.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);


		return npc;
	}
}

public void HumanMain_ClotThink(int iNPC)
{
	HumanMain npc = view_as<HumanMain>(iNPC);
	float gameTime = GetGameTime(npc.index);
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

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
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
		HumanMainSelfDefense(npc); 
	}
	npc.PlayIdleAlertSound();
}

public Action HumanMain_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	HumanMain npc = view_as<HumanMain>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void HumanMain_NPCDeath(int entity)
{
	HumanMain npc = view_as<HumanMain>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void HumanMainSelfDefense(HumanMain npc)
{
	if(npc.m_flNextRangedAttack > GetGameTime(npc.index))
		return;
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0) && Can_I_See_Enemy_Only(npc.index, target))
	{
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 4.5;
		npc.PlayGunSound();
		npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
		npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", false, .SetGestureSpeed = 0.5);
		npc.FaceTowards(vecTarget, 20000.0);
		for(int bullets; bullets < 10; bullets++)
		{
			float vecTargetSave[3];
			vecTargetSave = vecTarget;
			FireBulletBase(npc, vecTargetSave);
		}
		Custom_Knockback(target, npc.index, 1000.0, true, true, true);
	}
}

static void FireBulletBase(HumanMain npc, float vecTarget[3])
{
	float vecSpread = 0.1;

	float eyePitch[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
	
	static float Spread = 1.0;
	float x, y;
	x = GetRandomFloat( -Spread, Spread ) + GetRandomFloat( -Spread, Spread );
	y = GetRandomFloat( -Spread, Spread ) + GetRandomFloat( -Spread, Spread );
	
	float vecDirShooting[3], vecRight[3], vecUp[3];
	
	vecTarget[2] += 15.0;
	float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
	MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
	GetVectorAngles(vecDirShooting, vecDirShooting);
	vecDirShooting[1] = eyePitch[1];
	GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);

	float vecDir[3];
	vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
	vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
	vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
	NormalizeVector(vecDir, vecDir);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 25.0, 9000.0, DMG_BULLET, "bullet_tracer01_red", _,_,"duelrea_left_spike");
}
