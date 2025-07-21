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

static const char g_WarCry[][] = {
	"mvm/mvm_tank_horn.wav",
};

static float f_GlobalSoundCD;
static int NPCId;

void MedivalHussar_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_WarCry));   i++) { PrecacheSound(g_WarCry[i]);   }
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	f_GlobalSoundCD = 0.0;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hussar");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_medival_hussar");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_backup");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Medieval;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MedivalHussar(vecPos, vecAng, team);
}






#define HUSSAR_BUFF_MAXRANGE 350.0 		

methodmap MedivalHussar < CClotBody
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
	public void PlayMeleeWarCry() 
	{
		if(f_GlobalSoundCD > GetGameTime())
			return;
			
		f_GlobalSoundCD = GetGameTime() + 5.0;

		EmitSoundToAll(g_WarCry[GetRandomInt(0, sizeof(g_WarCry) - 1)], this.index, _, 85, _, 0.8, 100);
	}
	
	public MedivalHussar(float vecPos[3], float vecAng[3], int ally)
	{
		MedivalHussar npc = view_as<MedivalHussar>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "75000", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RIDER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bisWalking = false; //Animation it uses has no groundspeed, this is needed.
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		
		func_NPCDeath[npc.index] = MedivalHussar_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = MedivalHussar_OnTakeDamage;
		func_NPCThink[npc.index] = MedivalHussar_ClotThink;

		npc.m_iState = 0;
		npc.m_flSpeed = 350.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flAttackHappens_bullshit = GetGameTime() + 10.0;
		i_ClosestAllyCD[npc.index] = 0.0;

		Is_a_Medic[npc.index] = true; //This npc buffs, we dont waant allies to follow this ally.
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 0.75;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/hwn2022_pony_express/hwn2022_pony_express.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.StartPathing();
		
		return npc;
	}
}


public void MedivalHussar_ClotThink(int iNPC)
{
	MedivalHussar npc = view_as<MedivalHussar>(iNPC);

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
	if(IsValidAlly(npc.index, i_ClosestAlly[npc.index]))
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
		case 0:
		{
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
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_flSpeed = 350.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RIDER_RUN");
				}
				npc.StartPathing(); //Charge at them!
			}
			else
			{
				view_as<CClotBody>(iNPC).StopPathing();
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
				float vecTarget[3]; WorldSpaceCenter(i_ClosestAllyTarget[npc.index], vecTarget );
				
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];  PredictSubjectPosition(npc, i_ClosestAllyTarget[npc.index],_,_,vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(i_ClosestAllyTarget[npc.index]);
				}
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_flSpeed = 350.0;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RIDER_RUN");
				}
				npc.StartPathing(); //Charge at them!
			}
			else
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(i_ClosestAlly[npc.index], WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(npc.index, WorldSpaceVec2);
				flDistanceToTarget = GetVectorDistance(WorldSpaceVec, WorldSpaceVec2, true);
				if(flDistanceToTarget < (125.0* 125.0) && Can_I_See_Ally(npc.index, i_ClosestAlly[npc.index])) //make sure we can also see them for no unfair bs
				{
					if(npc.m_iChanged_WalkCycle != 5)
					{
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_RIDER_IDLE");
						view_as<CClotBody>(iNPC).StopPathing();
					}
				}
				else
				{
					float AproxRandomSpaceToWalkTo[3];
					GetEntPropVector(i_ClosestAlly[npc.index], Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
					view_as<CClotBody>(iNPC).SetGoalVector(AproxRandomSpaceToWalkTo);
					view_as<CClotBody>(iNPC).StartPathing();
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_flSpeed = 350.0;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_RIDER_RUN");
					}		
				}
			}
		}
	}

	HussarSelfDefense(npc,GetGameTime(npc.index));
	HussarAOEBuff(npc,GetGameTime(npc.index));

	npc.PlayIdleSound();
}

void HussarAOEBuff(MedivalHussar npc, float gameTime, bool mute = false)
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
				if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (HUSSAR_BUFF_MAXRANGE * HUSSAR_BUFF_MAXRANGE))
					{
						if(i_NpcInternalId[entitycount] != NPCId) //Hussars cannot buff eachother.
						{
							ApplyStatusEffect(npc.index, entitycount, "Hussar's Warscream", 5.0);
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
			ApplyStatusEffect(npc.index, npc.index, "Hussar's Warscream", 5.0);
			static int r;
			static int g;
			static int b ;
			static int a = 255;
			if(GetTeam(npc.index) != TFTeam_Red)
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
			spawnRing(npc.index, HUSSAR_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, HUSSAR_BUFF_MAXRANGE * 2.0);		
			if(!mute)
			{
				spawnRing(npc.index, HUSSAR_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
				spawnRing(npc.index, HUSSAR_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
				npc.PlayMeleeWarCry();
			}
		}
		else
		{
			npc.m_flAttackHappens_bullshit = gameTime + 1.0; //Try again in a second.
		}
	}
}

void HussarSelfDefense(MedivalHussar npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 0)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 75.0;

					if(Medival_Difficulty_Level_NotMath >= 2)
					{
						damage = 100.0;
					}
					if(Medival_Difficulty_Level_NotMath >= 3)
					{
						damage = 150.0;
					}

					if(target > MaxClients)
					{
						damage *= 5.0;
					}

					npc.PlayMeleeHitSound();

					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, PrimaryThreatIndex)) 
		{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_RIDER_ATTACK");
							
					npc.m_flAttackHappens = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
		else
		{
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

public Action MedivalHussar_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	MedivalHussar npc = view_as<MedivalHussar>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void MedivalHussar_NPCDeath(int entity)
{
	MedivalHussar npc = view_as<MedivalHussar>(entity);
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
}