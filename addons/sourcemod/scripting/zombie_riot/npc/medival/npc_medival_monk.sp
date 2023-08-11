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
	"weapons/shovel_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_WarCry[][] = {
	"ambient/rottenburg/tunneldoor_open.wav",
};

static float f3_PlaceLocated[MAXENTITIES][3];
void MedivalMonk_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_WarCry));   i++) { PrecacheSound(g_WarCry[i]);   }
	PrecacheModel(COMBINE_CUSTOM_MODEL);
}

static int i_ClosestAlly[MAXENTITIES];
static float i_ClosestAllyCD[MAXENTITIES];
static int i_ClosestAllyTarget[MAXENTITIES];
static float i_ClosestAllyCDTarget[MAXENTITIES];

#define MONK_MAXRANGE 250.0 	
#define MONK_MAXRANGE_ALLY 350.0 		

methodmap MedivalMonk < CClotBody
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
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeWarCry() {
		EmitSoundToAll(g_WarCry[GetRandomInt(0, sizeof(g_WarCry) - 1)], this.index, _, 90, _, 0.8, 100);
	}
	
	public MedivalMonk(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		MedivalMonk npc = view_as<MedivalMonk>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "75000", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcInternalId[npc.index] = MEDIVAL_MONK;
		i_NpcWeight[npc.index] = 2;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MONK_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		
		SDKHook(npc.index, SDKHook_Think, MedivalMonk_ClotThink);

		npc.m_iState = 0;
		npc.m_flSpeed = 150.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flAttackHappens_bullshit = GetGameTime() + 10.0;
		i_ClosestAllyCD[npc.index] = 0.0;

		Is_a_Medic[npc.index] = true; //This npc buffs, we dont waant allies to follow this ally.
		
		npc.m_flMeleeArmor = 3.0;
		npc.m_flRangedArmor = 1.0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void MedivalMonk_ClotThink(int iNPC)
{
	MedivalMonk npc = view_as<MedivalMonk>(iNPC);

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


	if(i_ClosestAllyCD[npc.index] < GetGameTime())
	{
		i_ClosestAllyCD[npc.index] = GetGameTime() + 1.0;
		i_ClosestAlly[npc.index] = GetClosestAlly(npc.index);			
	}


	int Behavior = -1;
	if(npc.m_flDoingAnimation > GetGameTime())
	{
		Behavior = -1;
	}
	else if(IsValidAlly(npc.index, i_ClosestAlly[npc.index]))
	{
		Behavior = 1; //We go to the closest ally, and support them in battle!
	}
	else //Current ally died, find a new one to help.
	{
		i_ClosestAlly[npc.index] = GetClosestAlly(npc.index);	
		
		if(IsValidAlly(npc.index, i_ClosestAlly[npc.index]))
		{
			Behavior = 1; //We go to the closest ally, and support them in battle!
		}
		else
		{
			Behavior = 0; //No ally left, attack!
		}
	}

	switch(Behavior)
	{
		case -1:
		{
			//nothing.
		}
		case 0:
		{
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
				
				float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
					
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_flSpeed = 150.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MONK_WALK");
				}
				NPC_StartPathing(npc.index); //Charge at them!
			}
			else
			{
				NPC_StopPathing(iNPC);
				npc.m_iTarget = GetClosestTarget(npc.index); //Find new target instantly.
			}
		}
		case 1:
		{
			float flDistanceToTarget;
			if(i_ClosestAllyCDTarget[npc.index] < GetGameTime(npc.index))
			{
				i_ClosestAllyTarget[npc.index] = GetClosestTarget(i_ClosestAlly[npc.index], true, 200.0);
				i_ClosestAllyCDTarget[npc.index] = GetGameTime(npc.index) + 1.0;
			}
			if(IsValidEnemy(npc.index, i_ClosestAllyTarget[npc.index]))
			{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(i_ClosestAllyTarget[npc.index]);
				
				flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
					
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, i_ClosestAllyTarget[npc.index]);
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, i_ClosestAllyTarget[npc.index]);
				}
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_flSpeed = 150.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MONK_WALK");
				}
				NPC_StartPathing(npc.index); //Charge at them!
			}
			else
			{
				flDistanceToTarget = GetVectorDistance(WorldSpaceCenter(i_ClosestAlly[npc.index]), WorldSpaceCenter(npc.index), true);
				if(flDistanceToTarget < (125.0* 125.0) && Can_I_See_Ally(npc.index, i_ClosestAlly[npc.index])) //make sure we can also see them for no unfair bs
				{
					if(npc.m_iChanged_WalkCycle != 5)
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_MONK_IDLE");
						NPC_StopPathing(iNPC);
					}
				}
				else
				{
					float AproxRandomSpaceToWalkTo[3];
					GetEntPropVector(i_ClosestAlly[npc.index], Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
					NPC_SetGoalVector(iNPC, AproxRandomSpaceToWalkTo);
					NPC_StartPathing(iNPC);
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_flSpeed = 150.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_MONK_WALK");
					}		
				}
			}
		}
	}

	MonkSelfDefense(npc,GetGameTime(npc.index));

	npc.PlayIdleSound();
}
/*
void HussarAOEBuff(MedivalMonk npc, float gameTime)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flAttackHappens_bullshit < gameTime)
	{
		bool buffed_anyone;
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (entitycount <= MaxClients || !b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetEntProp(entitycount, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (MONK_MAXRANGE * MONK_MAXRANGE))
					{
						if(i_NpcInternalId[entitycount] != MEDIVAL_HUSSAR) //Hussars cannot buff eachother.
						{
							f_HussarBuff[entitycount] = GetGameTime() + 5.0; //allow buffing of players too if on red.
							//Buff this entity.
							buffed_anyone = true;	
						}
					}
				}
			}
		}
		if(buffed_anyone)
		{
			npc.m_flAttackHappens_bullshit = gameTime + 10.0;
			f_HussarBuff[npc.index] = GetGameTime() + 5.0;
			static int r;
			static int g;
			static int b ;
			static int a = 255;
			if(b_Is_Blue_Npc[npc.index])
			{
				r = 125;
				g = 125;
				b = 255;
			}
			else
			{
				r = 255;
				g = 125;
				b = 125;
			}
			static float UserLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", UserLoc);
			spawnRing(npc.index, MONK_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing(npc.index, MONK_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
			spawnRing(npc.index, MONK_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, MONK_MAXRANGE * 2.0);		
			f3_PlaceLocated[npc.index] = UserLoc;
			
			npc.PlayMeleeWarCry();
		}
		else
		{
			npc.m_flAttackHappens_bullshit = gameTime + 1.0; //Try again in a second.
		}
	}
}
*/
void MonkSelfDefense(MedivalMonk npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		npc.AddGesture("ACT_MONK_ATTACK", false);
		if(npc.m_flAttackHappens < gameTime)
		{
			static int r;
			static int g;
			static int b;
			static int a = 255;
			if(b_Is_Blue_Npc[npc.index])
			{
				r = 125;
				g = 125;
				b = 255;
			}
			else
			{
				r = 255;
				g = 125;
				b = 125;
			}
			npc.m_flAttackHappens = 0.0;
			spawnRing_Vectors(f3_PlaceLocated[npc.index], MONK_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 10.0, 5.0, 3.1, 1, _);		
		//	spawnRing_Vectors(f3_PlaceLocated[npc.index], MONK_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 10.0, 5.0, 3.1, 1, _);		
		//	spawnRing_Vectors(f3_PlaceLocated[npc.index], MONK_MAXRANGE * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 10.0, 5.0, 3.1, 1, _);		
		//	spawnRing_Vectors(f3_PlaceLocated[npc.index], MONK_MAXRANGE * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 10.0, 5.0, 3.1, 1, _);		
			spawnRing_Vectors(f3_PlaceLocated[npc.index], MONK_MAXRANGE * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 10.0, 5.0, 3.1, 1, _);		
			DataPack pack;
			CreateDataTimer(0.1, MonkHealDamageZone, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteFloat(GetGameTime() + 10.0);
			pack.WriteFloat(f3_PlaceLocated[npc.index][0]);
			pack.WriteFloat(f3_PlaceLocated[npc.index][1]);
			pack.WriteFloat(f3_PlaceLocated[npc.index][2]);
			pack.WriteCell(b_IsAlliedNpc[npc.index]);
			pack.WriteCell(EntIndexToEntRef(npc.index));
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, PrimaryThreatIndex)) 
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);

			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget <(NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 22.5))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.PlayMeleeWarCry();
					static int r;
					static int g;
					static int b ;
					static int a = 50;
					if(b_Is_Blue_Npc[npc.index])
					{
						r = 125;
						g = 125;
						b = 255;
					}
					else
					{
						r = 255;
						g = 125;
						b = 125;
					}
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MONK_ATTACK");
							
					npc.m_flAttackHappens = gameTime + 1.3;
					float UserLoc[3];
					GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", UserLoc);
					spawnRing(npc.m_iTarget, MONK_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.3, 6.0, 6.1, 1);
					spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.3, 12.0, 6.1, 1, MONK_MAXRANGE * 2.0);		

					npc.FaceTowards(UserLoc, 15000.0);

					npc.m_flDoingAnimation = gameTime + 1.3;
					npc.m_flNextMeleeAttack = gameTime + 5.0;
					f3_PlaceLocated[npc.index] = UserLoc;
					if(npc.m_iChanged_WalkCycle != 5)
					{
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_MONK_IDLE");
						NPC_StopPathing(npc.index);
					}
				}
			}
		}
		else
		{
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

public Action MedivalMonk_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalMonk npc = view_as<MedivalMonk>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void MedivalMonk_NPCDeath(int entity)
{
	MedivalMonk npc = view_as<MedivalMonk>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, MedivalMonk_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}


public Action MonkHealDamageZone(Handle timer, DataPack pack)
{
	pack.Reset();
	float TimeSinceUsage = pack.ReadFloat();
	if(TimeSinceUsage < GetGameTime())
	{
		return Plugin_Stop;
	}
	float vector[3];
	vector[0] = pack.ReadFloat();
	vector[1] = pack.ReadFloat();
	vector[2] = pack.ReadFloat();
	bool AlliedUnit = pack.ReadCell();
	int Monk = EntRefToEntIndex(pack.ReadCell());
	float damage = 10.0;
	if(Monk == -1)
	{
		Monk = 0;
	}
	
	if(AlliedUnit)
	{
		BarrackBody npc = view_as<BarrackBody>(Monk);
		for(int entitycount; entitycount<i_MaxcountNpc; entitycount++) //BLUE npcs.
		{
			int entity_close = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
			if(IsValidEntity(entity_close) && !b_NpcHasDied[entity_close] && !i_NpcIsABuilding[entity_close] && i_NpcInternalId[entity_close] != MEDIVAL_MONK)
			{
				static float pos2[3];
				GetEntPropVector(entity_close, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(vector, pos2, true) < (MONK_MAXRANGE_ALLY * MONK_MAXRANGE_ALLY))
				{
					SDKHooks_TakeDamage(entity_close, Monk, GetClientOfUserId(npc.OwnerUserId), damage * 40.0, DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE, -1, _, WorldSpaceCenter(entity_close));	
					damage *= 0.8;
				}
			}
		}
		//Doesnt do anything for now, too lazy.
	}
	else
	{
		if(!NpcStats_IsEnemySilenced(Monk))
		{
			for(int entitycount; entitycount<i_MaxcountNpc; entitycount++) //BLUE npcs.
			{
				int entity_close = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
				if(IsValidEntity(entity_close) && !b_NpcHasDied[entity_close] && !i_NpcIsABuilding[entity_close] && i_NpcInternalId[entity_close] != MEDIVAL_MONK && i_NpcInternalId[entity_close] != RAIDMODE_GOD_ARKANTOS)
				{
					bool regrow = true;
					Building_CamoOrRegrowBlocker(entity_close, _, regrow);
					if(regrow)
					{
						static float pos2[3];
						GetEntPropVector(entity_close, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(vector, pos2, true) < (MONK_MAXRANGE * MONK_MAXRANGE))
						{
							SetEntProp(entity_close, Prop_Data, "m_iHealth",GetEntProp(entity_close, Prop_Data, "m_iMaxHealth"));
						}
					}
				}
			}
		}
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] == TEUTON_NONE && IsPlayerAlive(client))
			{
				static float pos2[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(vector, pos2, true) < (MONK_MAXRANGE * MONK_MAXRANGE))
				{
					SDKHooks_TakeDamage(client, Monk, Monk, damage, DMG_SHOCK|DMG_PREVENT_PHYSICS_FORCE, -1, _, WorldSpaceCenter(client));	
				}
			}
		}
		for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
		{
			int entity_close = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
			if(IsValidEntity(entity_close))
			{
				static float pos2[3];
				GetEntPropVector(entity_close, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(vector, pos2, true) < (MONK_MAXRANGE * MONK_MAXRANGE))
				{
					SDKHooks_TakeDamage(entity_close, Monk, Monk, damage * 3.0, DMG_SHOCK|DMG_PREVENT_PHYSICS_FORCE, -1, _, WorldSpaceCenter(entity_close));	
				}
			}
		}
		for(int entitycount; entitycount<i_MaxcountNpc_Allied; entitycount++) //RED npcs.
		{
			int entity_close = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount]);
			if(IsValidEntity(entity_close))
			{
				static float pos2[3];
				GetEntPropVector(entity_close, Prop_Data, "m_vecAbsOrigin", pos2);
				if(GetVectorDistance(vector, pos2, true) < (MONK_MAXRANGE * MONK_MAXRANGE))
				{
					SDKHooks_TakeDamage(entity_close, Monk, Monk, damage, DMG_SHOCK|DMG_PREVENT_PHYSICS_FORCE, -1, _, WorldSpaceCenter(entity_close));	
				}
			}
		}
	}
	return Plugin_Continue;
}