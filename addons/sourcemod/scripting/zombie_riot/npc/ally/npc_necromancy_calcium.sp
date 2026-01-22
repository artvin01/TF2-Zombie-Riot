#pragma semicolon 1
#pragma newdecls required

static char g_HurtSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_05.wav",
	")misc/halloween/skeletons/skelly_medium_06.wav",
	")misc/halloween/skeletons/skelly_medium_07.wav",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav",
};

static char g_MeleeHitSounds[][] = {
	"weapons/3rd_degree_hit_01.wav",
	"weapons/axe_hit_flesh1.wav",
	"weapons/slap_hit1.wav",
};

static char g_MeleeAttackSounds[][] = {
	")misc/halloween/skeletons/skelly_giant_02.wav",
	")misc/halloween/skeletons/skelly_giant_03.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

public void NecroCalcium_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Spookmaster Boner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_necromancy_calcium");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return NecroCalcium(client, vecPos, vecAng);
}

methodmap NecroCalcium < CClotBody
{
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public NecroCalcium(int client, float vecPos[3], float vecAng[3])
	{
		NecroCalcium npc = view_as<NecroCalcium>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper/skeleton_sniper.mdl", "0.8", "1250", TFTeam_Red, true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flDuration = GetGameTime(npc.index) + 20.0; //They should last this long for now.
		
		SetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity", client);
		
		func_NPCOnTakeDamage[npc.index] = NecroCalcium_OnTakeDamage;
		func_NPCThink[npc.index] = NecroCalcium_ClotThink;
		
		npc.m_bThisEntityIgnored = true;
	//	npc.m_flNextThinkTime = GetGameTime(npc.index) + GetRandomFloat(0.2, 0.5);
		npc.m_iState = 0;
		npc.m_flSpeed = 600.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDissapearOnDeath = true;
		npc.m_bNoKillFeed = true;
		b_NpcIsInvulnerable[npc.index] = true;
		
		SetEntityCollisionGroup(npc.index, 27);
		SetEntityRenderColor(npc.index, 192, 192, 192, 255);
		
		npc.StartPathing();
		return npc;
	}
}

public void NecroCalcium_ClotThink(int iNPC)
{
	NecroCalcium npc = view_as<NecroCalcium>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, false, .ExtraValidityFunction = Necromancy_AttackMarkOnly);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	int owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(IsValidClient(owner) && npc.m_flDuration > GetGameTime(npc.index))
	{
		int PrimaryThreatIndex = npc.m_iTarget;
		if(IsValidEnemy(npc.index, PrimaryThreatIndex) && NpcStats_IberiaIsEnemyMarked(PrimaryThreatIndex))
		{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			
			//Target close enough to hit
			if((flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
			{
			//	npc.FaceTowards(vecTarget, 1000.0);
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 40000.0);
						if (npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,2))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								float damage = 65.0;
								int weapon = GetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon");
								if(weapon > 0)
								{
									if(i_CustomWeaponEquipLogic[weapon] != WEAPON_NECRO_WANDS)
										damage *= 0.5;
								}
								else
								{
									damage *= 0.5;
								}
								SDKHooks_TakeDamage(target, owner, owner, (damage * npc.m_flExtraDamage), DMG_PLASMA, -1, _, vecHit); //Do acid so i can filter it well.
								
								// Hit sound
								npc.PlayMeleeHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
					}
				}
			}
			if (npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				npc.StartPathing();
			}
		}
		else
		{
			npc.StopPathing();
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index, _, _, false, .ExtraValidityFunction = Necromancy_AttackMarkOnly);
		}
		npc.PlayIdleAlertSound();
	}
	else
	{
		SDKHooks_TakeDamage(npc.index, 0, 0, 999999999.0, DMG_GENERIC); //Kill it so it triggers the neccecary shit.
	}
}

bool Necromancy_AttackMarkOnly(int entity, int target)
{
	if(NpcStats_IberiaIsEnemyMarked(target))
	{
		return true;
	}
	return false;
}

public Action NecroCalcium_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (damage < 9999999.0)	//So they can be slayed.
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}