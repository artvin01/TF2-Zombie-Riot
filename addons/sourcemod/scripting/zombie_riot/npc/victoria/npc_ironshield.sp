#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/scanner/scanner_explode_crash2.wav",
};

static const char g_HurtSounds[][] = {
	"npc/scanner/scanner_pain1.wav",
	"npc/scanner/scanner_pain2.wav",
};

static const char g_IdleSounds[][] = {
	"vo/mvm/norm/heavy_mvm_jeers03.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers04.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers06.mp3",
	"vo/mvm/norm/heavy_mvm_jeers09.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"npc/scanner/scanner_alert1.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"ambient/materials/metal_groan.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/scanner/cbot_discharge1.wav",
};

void VictorianIronShield_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	NPCData data;
	PrecacheModel("models/bots/heavy_boss/bot_heavy_boss.mdl");
	strcopy(data.Name, sizeof(data.Name), "IronShield");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ironshield");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_ironshield");
	data.IconCustom = true;	
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianIronShield(vecPos, vecAng, ally);
}
methodmap VictorianIronShield < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	
	public VictorianIronShield(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianIronShield npc = view_as<VictorianIronShield>(CClotBody(vecPos, vecAng, "models/bots/heavy_boss/bot_heavy_boss.mdl", "1.5", "65000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.g_TimesSummoned = 0;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		func_NPCDeath[npc.index] = VictorianIronShield_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianIronShield_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianIronShield_ClotThink;
		
		
		//IDLE
		npc.m_flSpeed = 150.0;
		npc.m_iState = 0;
		npc.m_fbRangedSpecialOn = true;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iOverlordComboAttack = 2;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 80, 50, 50, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable1, 100, 100, 150, 255);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/heavy/big_jaw.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec23_impact_impaler/dec23_impact_impaler.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_helmet/tw_heavybot_helmet.mdl");

		SetEntityRenderColor(npc.m_iWearable4, 150, 150, 150, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_armor/tw_heavybot_armor.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void VictorianIronShield_ClotThink(int iNPC)
{
	VictorianIronShield npc = view_as<VictorianIronShield>(iNPC);
	

	if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
	{
		npc.m_fbRangedSpecialOn = true;
	}
	
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
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			
			VictorianIronShieldSelfdefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

void VictorianIronShieldSelfdefense(VictorianIronShield npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))//Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				float HitDamage = 100.0;
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					if(npc.m_iOverlordComboAttack <= 0)
					{
						float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
						makeexplosion(npc.index, npc_vec, RoundToCeil(HitDamage * 2.5), 150,_,_, false, 10.0);
						npc.m_iOverlordComboAttack = 2;
					}
					else
					{
						npc.m_iOverlordComboAttack --;
						if(NpcStats_VictorianCallToArms(npc.index))
						{
							npc.m_iOverlordComboAttack --;
							npc.m_iOverlordComboAttack --;
						}
					}
	
					if(!ShouldNpcDealBonusDamage(target))
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, HitDamage, DMG_CLUB, -1, _, vecHit);
					}
					else
						SDKHooks_TakeDamage(target, npc.index, npc.index, HitDamage, DMG_CLUB, -1, _, vecHit);

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
				if(npc.m_iOverlordComboAttack <= 0)
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
				else
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
			}
		}
	}
}

public Action VictorianIronShield_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianIronShield npc = view_as<VictorianIronShield>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VictorianIronShield_NPCDeath(int entity)
{
	VictorianIronShield npc = view_as<VictorianIronShield>(entity);
	
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int team = GetTeam(npc.index);

	int MaxHealth = RoundToCeil(float(ReturnEntityMaxHealth(npc.index))/3.0);

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	int other = NPC_CreateByName("npc_aviator", -1, pos, ang, team);
	if(other > MaxClients)
	{
		if(team != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;
		
		SetEntProp(other, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(other, Prop_Data, "m_iMaxHealth", MaxHealth);
		
		fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
		b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
		b_StaticNPC[other] = b_StaticNPC[npc.index];
		if(b_StaticNPC[other])
			AddNpcToAliveList(other, 1);
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}

