#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

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

//Skeletons won't use guns, but I don't want to remove these and maybe break something
static char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

public void NecroCalcium_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/effects/combineball.mdl", true);
	PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Spookmaster Boner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_necromancy_calcium");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return NecroCalcium(client, vecPos, vecAng);
}
methodmap NecroCalcium < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		

	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
		

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
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flDuration = GetGameTime(npc.index) + 20.0; //They should last this long for now.
		
		SetEntProp(npc.index, Prop_Send, "m_iTeamNum", TFTeam_Red);
		
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		
		func_NPCDeath[npc.index] = NecroCalcium_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = NecroCalcium_OnTakeDamage;
		func_NPCThink[npc.index] = NecroCalcium_ClotThink;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 50000001);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 50000001);
		
		
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
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/engineer/jul13_king_hair/jul13_king_hair.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("flag", "models/workshop/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityCollisionGroup(npc.m_iWearable2, 27);
		
		SetEntityCollisionGroup(npc.m_iWearable1, 27);
		
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
	int owner;
	owner = GetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity");
	
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
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,2))
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
										{
											damage *= 0.5;
										}
									}
									else
									{
										damage *= 0.5;
									}
									SDKHooks_TakeDamage(target, owner, owner, (damage * npc.m_flExtraDamage), DMG_PLASMA, -1, _, vecHit); //Do acid so i can filter it well.
									
									// Hit particle
									
									
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


public void NecroCalcium_NPCDeath(int entity)
{
	NecroCalcium npc = view_as<NecroCalcium>(entity);
//	npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}