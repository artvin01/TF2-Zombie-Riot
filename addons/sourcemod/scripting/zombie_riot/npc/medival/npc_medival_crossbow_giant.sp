#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};


static const char g_MeleeHitSounds[][] = {
	"weapons/bat_baseball_hit_flesh.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/bow_shoot.wav",
};

void MedivalCrossbowGiant_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Crossbow Giant");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_medival_crossbow_giant");
	strcopy(data.Icon, sizeof(data.Icon), "crossbow_big");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Medieval;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MedivalCrossbowGiant(vecPos, vecAng, team);
}
methodmap MedivalCrossbowGiant < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public MedivalCrossbowGiant(float vecPos[3], float vecAng[3], int ally)
	{
		MedivalCrossbowGiant npc = view_as<MedivalCrossbowGiant>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.75", "20000", ally, false, true));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_CUSTOM_WALK_CROSSBOW");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		SetEntityRenderColor(npc.index, 255, 215, 0, 255);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable1, 255, 215, 0, 255);

		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
	
		func_NPCDeath[npc.index] = MedivalCrossbowGiant_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = MedivalCrossbowGiant_OnTakeDamage;
		func_NPCThink[npc.index] = MedivalCrossbowGiant_ClotThink;
		func_NPCAnimEvent[npc.index] = HandleAnimEventMedival_GiantCrossbowMan;

		npc.m_iState = 0;
		npc.m_flSpeed = 120.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

	/*	
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/all_class/sbox2014_toowoomba_tunic/sbox2014_toowoomba_tunic_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
	*/
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void MedivalCrossbowGiant_ClotThink(int iNPC)
{
	MedivalCrossbowGiant npc = view_as<MedivalCrossbowGiant>(iNPC);

	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
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
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			if(npc.m_flJumpStartTime < GetGameTime(npc.index))
			{
				npc.m_flSpeed = 120.0;
			}
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				/*
				int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);
				*/
				
				
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			
			if(flDistanceToTarget < 500000)
			{
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
					{
						npc.m_flSpeed = 0.0;
			//			npc.FaceTowards(vecTarget, 30000.0);
						//Play attack anim
						npc.AddGesture("ACT_CUSTOM_ATTACK_CROSSBOW");
						
			//			npc.PlayMeleeSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.7;
						npc.m_flJumpStartTime = GetGameTime(npc.index) + 0.7; //Reuse this!
					}
					npc.StopPathing();
					
				}
				else
				{
					npc.StartPathing();
					
				}
			}
			else
			{
				npc.StartPathing();
				
			}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public void HandleAnimEventMedival_GiantCrossbowMan(int entity, int event)
{
	if(event == 1001)
	{
		MedivalCrossbowMan npc = view_as<MedivalCrossbowMan>(entity);
		
		int PrimaryThreatIndex = npc.m_iTarget;
	
		if(IsValidEnemy(npc.index, PrimaryThreatIndex))
		{
			float vecTarget[3];
				
			float projectile_speed = 1200.0;
			
			PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed,_,vecTarget);
				
			npc.FaceTowards(vecTarget, 30000.0);
						
			npc.PlayMeleeSound();
			
			float damage = 70.0;
			if(Medival_Difficulty_Level_NotMath >= 2)
			{
				damage = 85.0;
			}
			npc.FireArrow(vecTarget, damage, projectile_speed);
		}
	}
	
}

public Action MedivalCrossbowGiant_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalCrossbowGiant npc = view_as<MedivalCrossbowGiant>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void MedivalCrossbowGiant_NPCDeath(int entity)
{
	MedivalCrossbowGiant npc = view_as<MedivalCrossbowGiant>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}