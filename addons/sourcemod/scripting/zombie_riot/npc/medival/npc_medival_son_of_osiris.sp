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

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
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
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"items/powerup_pickup_crits.wav",
};

#define SON_OF_OSIRIS_RANGE 300.0

void MedivalSonOfOsiris_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Son Of Osiris");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_medival_son_of_osiris");
	strcopy(data.Icon, sizeof(data.Icon), "son_of_osiris");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Medieval;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MedivalSonOfOsiris(vecPos, vecAng, team);
}
static bool b_EntityHitByLightning[MAXENTITIES];

methodmap MedivalSonOfOsiris < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}
	
	public MedivalSonOfOsiris(float vecPos[3], float vecAng[3], int ally)
	{
		MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "750000", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
		i_NpcWeight[npc.index] = 5;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_PRINCE_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}

		func_NPCDeath[npc.index] = MedivalSonOfOsiris_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = MedivalSonOfOsiris_OnTakeDamage;
		func_NPCThink[npc.index] = MedivalSonOfOsiris_ClotThink;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/all_class/fall17_war_eagle/fall17_war_eagle_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

	//	b_CannotBeHeadshot[npc.index] = true;
	//	b_CannotBeBackstabbed[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
	//	Is_a_Medic[npc.index] = true; //cannot be healed
		

		npc.StartPathing();
		
		return npc;
	}
}


public void MedivalSonOfOsiris_ClotThink(int iNPC)
{
	MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(iNPC);

	float gameTime = GetGameTime(iNPC);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
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
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			npc.FaceTowards(vecTarget, 20000.0);
		}

		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{		
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				npc.PlayMeleeSound();
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					float TargetLocation[3]; 
					GetEntPropVector( npc.index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
					float EntityLocation[3]; 
					GetEntPropVector( npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
					float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
						
					if(distance <= (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.5)) //Sanity check! we want to change targets but if they are too far away then we just dont cast it.
					{
						SonOfOsiris_Lightning_Strike(npc.index, npc.m_iTarget, 900.0, GetTeam(npc.index) == TFTeam_Red);
					}
				}
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.5) && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_flSpeed = 300.0;
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_PRINCE_WALK");
					npc.StartPathing();
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_PRINCE_IDLE");
						npc.StopPathing();
						npc.m_flSpeed = 0.0;
					}
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_PRINCE_ATTACK");

					npc.m_flAttackHappens = gameTime + 0.8;

					npc.m_flDoingAnimation = gameTime + 1.3;
					npc.m_flNextMeleeAttack = gameTime + 3.0;
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public Action MedivalSonOfOsiris_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void MedivalSonOfOsiris_NPCDeath(int entity)
{
	MedivalSonOfOsiris npc = view_as<MedivalSonOfOsiris>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
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

static void SonOfOsiris_Lightning_Effect(int entity = -1, int target = -1, float VecPos_entity[3] = {0.0,0.0,0.0}, float VecPos_target[3] = {0.0,0.0,0.0})
{	
	int r = 65; //Blue.
	int g = 65;
	int b = 255;
	int laser;
	if(entity != -1 && target != -1)
	{
		laser = ConnectWithBeam(entity, target, r, g, b, 3.0, 3.0, 2.35, LASERBEAM);
	}
	else if(entity != -1)
	{
		laser = ConnectWithBeam(entity, -1, r, g, b, 3.0, 3.0, 2.35, LASERBEAM, _, VecPos_target);
	}
	else if (target != -1)
	{
		laser = ConnectWithBeam(-1, target, r, g, b, 3.0, 3.0, 2.35, LASERBEAM, VecPos_entity, _);
	}
	else
	{
		laser = ConnectWithBeam(-1, -1, r, g, b, 3.0, 3.0, 2.35, LASERBEAM, VecPos_entity, VecPos_target);
	}
	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}


static void SonOfOsiris_Lightning_Strike(int entity, int target, float damage, bool alliednpc = false)
{
	static float vecHit[3];
	GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vecHit);

	float dodamage = damage;
	if(ShouldNpcDealBonusDamage(target)) //If he attacks a building first, then its going to hurt alot more.
	{
	//	damage *= 2.0;
		//actually terrible idea, dont.
		dodamage *= 50.0;
	}

	float vecTarget[3];
	float vecTarget_2[3];
	WorldSpaceCenter(target, vecTarget );
	WorldSpaceCenter(target, vecTarget_2);

	bool first_target = true;
	bool enemy_died = false;

	SDKHooks_TakeDamage(target, entity, entity, dodamage, DMG_PLASMA, _, {0.0, 0.0, -50000.0}, vecHit);	//BURNING TO THE GROUND!!!
	
	if(IsValidEntity(target) && (!b_BuildingHasDied[target] || !b_NpcHasDied[target] || target <= MaxClients))
	{
		SonOfOsiris_Lightning_Effect(entity, target);
	}
	else
	{
		enemy_died = true;
		SonOfOsiris_Lightning_Effect(entity, -1, _, vecTarget_2);	
	}

	b_EntityHitByLightning[target] = true;
//	float original_damage = damage;

	int PreviousTarget = target;
	int TraceFromThis = entity;

	for (int loop = 5; loop > 2; loop--) //Chain upto alot of times
	{
		int enemy = SonOfOsiris_GetClosestTargetNotAffectedByLightning(TraceFromThis, vecHit, alliednpc);
		if(IsValidEntity(enemy) && PreviousTarget != enemy)
		{
			/*
			if(IsValidClient(enemy))
			{
				if(IsInvuln(enemy))
				{
					original_damage *= 2.0;
				}
			}
			*/
		//	damage = (original_damage * (0.15 * loop));

			if(!first_target)
			{
				if(!enemy_died)
				{
					WorldSpaceCenter(PreviousTarget, vecTarget);
				}
				else
				{
					vecTarget = vecTarget_2;
				}
			}

			first_target = false;
			
			WorldSpaceCenter(enemy, vecTarget_2);
			enemy_died = false;
			float vehit_save[3];
			GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vehit_save);
			SDKHooks_TakeDamage(enemy, entity, entity, damage, DMG_PLASMA, _, {0.0, 0.0, -50000.0}, vecHit);	
			if(IsValidEntity(enemy) && (!b_BuildingHasDied[enemy] || !b_NpcHasDied[enemy] || enemy <= MaxClients))
			{
				if(IsValidEntity(PreviousTarget) && (!b_BuildingHasDied[PreviousTarget] || !b_NpcHasDied[PreviousTarget] || PreviousTarget <= MaxClients))
				{
					//both alive!
					SonOfOsiris_Lightning_Effect(PreviousTarget, enemy, _, _);
				}
				else
				{
					//previous died.
					SonOfOsiris_Lightning_Effect(-1, enemy, vecTarget, _);
				}
			}
			else //Enemy died.
			{
				enemy_died = true;
				if(IsValidEntity(PreviousTarget) && (!b_BuildingHasDied[PreviousTarget] || !b_NpcHasDied[PreviousTarget] || PreviousTarget <= MaxClients))
				{
					//enemy died, but previous was alive.
					SonOfOsiris_Lightning_Effect(PreviousTarget, -1, _, vecTarget_2);
				}
				else
				{
					//both died.
					SonOfOsiris_Lightning_Effect(-1, -1, vecTarget, vecTarget_2);
				}
			}	
			vecHit = vehit_save;
			PreviousTarget = enemy;
			TraceFromThis = enemy;
		}
		else
		{
			break;
		}
	}
	Zero(b_EntityHitByLightning); //delete this logic.
}

stock int SonOfOsiris_GetClosestTargetNotAffectedByLightning(int traceentity , float EntityLocation[3], bool ally = false)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	if(ally)
	{
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && !b_EntityHitByLightning[baseboss_index] && GetTeam(baseboss_index) != TFTeam_Red)
			{
				float TargetLocation[3]; 
				GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
					
				if(distance <= (SON_OF_OSIRIS_RANGE * SON_OF_OSIRIS_RANGE ))
				{
					bool hitentity = Can_I_See_Enemy_Only(traceentity, baseboss_index);
					if(hitentity)
					{
						if( TargetDistance ) 
						{
							if( distance < TargetDistance ) 
							{
								ClosestTarget = baseboss_index; 
								TargetDistance = distance;          
							}
						} 
						else 
						{
							ClosestTarget = baseboss_index; 
							TargetDistance = distance;
						}
					}
				}
			}
		}	
	}
	else
	{
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && !b_EntityHitByLightning[baseboss_index] && GetTeam(baseboss_index) == TFTeam_Red)
			{
				float TargetLocation[3]; 
				GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
					
				if(distance <= (SON_OF_OSIRIS_RANGE * SON_OF_OSIRIS_RANGE ))
				{
					bool hitentity = Can_I_See_Enemy_Only(traceentity, baseboss_index);
					if(hitentity)
					{
						if( TargetDistance ) 
						{
							if( distance < TargetDistance ) 
							{
								ClosestTarget = baseboss_index; 
								TargetDistance = distance;          
							}
						} 
						else 
						{
							ClosestTarget = baseboss_index; 
							TargetDistance = distance;
						}
					}
				}
			}
		}	
		for( int client = 1; client <= MaxClients; client++ ) 
		{
			if (IsValidClient(client))
			{
				CClotBody npc = view_as<CClotBody>(client);
				if (!npc.m_bThisEntityIgnored && IsEntityAlive(client) && !b_EntityHitByLightning[client]) //&& CheckForSee(i)) we dont even use this rn and probably never will.
				{
					float TargetLocation[3]; 
					GetEntPropVector( client, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
					float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
						
					if(distance <= (SON_OF_OSIRIS_RANGE * SON_OF_OSIRIS_RANGE ))
					{
						bool hitentity = Can_I_See_Enemy_Only(traceentity, client);
						if(hitentity)
						{
							if( TargetDistance ) 
							{
								if( distance < TargetDistance ) 
								{
									ClosestTarget = client; 
									TargetDistance = distance;          
								}
							} 
							else 
							{
								ClosestTarget = client; 
								TargetDistance = distance;
							}
						}
					}
				}
			}
		}
	}
	if(IsValidEntity(ClosestTarget))
	{
		b_EntityHitByLightning[ClosestTarget] = true;
	}
	return ClosestTarget; 
}

