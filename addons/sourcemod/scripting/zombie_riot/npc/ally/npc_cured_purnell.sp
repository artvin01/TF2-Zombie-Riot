#pragma semicolon 1
#pragma newdecls required

static char g_MeleeHitSounds[][] = {
	"cof/purnell/meleehit.mp3",
};
static char g_MeleeAttackSounds[][] = {
	"cof/purnell/shove.mp3",
};

static char g_RangedAttackSounds[][] = {
	"cof/purnell/shoot.mp3",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_PullSounds[][] = {
	"cof/purnell/kill4.mp3",
};

static char g_RangedReloadSound[][] = {
	"cof/purnell/reload.mp3",
};

static char g_KilledEnemy[][] = {
	"cof/purnell/kill1.mp3",
	"cof/purnell/kill2.mp3",
	"cof/purnell/kill3.mp3",
	"cof/purnell/kill4.mp3",
};

public void CuredPurnell_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSoundCustom(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSoundCustom(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSoundCustom(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSoundCustom(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSoundCustom(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_KilledEnemy));   i++) { PrecacheSoundCustom(g_KilledEnemy[i]);   }
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/explode_9.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Cured Purnell");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cured_purnell");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return CuredPurnell(client, vecPos, vecAng, ally);
}

//static bool BoughtGregHelp;

methodmap CuredPurnell < CClotBody
{
		
	public void PlayRangedReloadSound() {
		EmitCustomToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredPurnell::PlayRangedSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
	//	if (GetRandomInt(0, 5) == 2)
		{
			EmitCustomToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
			
			#if defined DEBUG_SOUND
			PrintToServer("CCuredPurnell::PlayMeleeHitSound()");
			#endif
		}
	}
	
	public void PlayRangedSound() {
		EmitCustomToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredPurnell::PlayRangedSound()");
		#endif
	}
	
	public void PlayKilledEnemy() {
		EmitCustomToAll(g_KilledEnemy[GetRandomInt(0, sizeof(g_KilledEnemy) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		this.m_flNextIdleSound += 2.0;
		#if defined DEBUG_SOUND
		PrintToServer("CCuredPurnell::PlayRangedSound()");
		#endif
	}
	
	public void PlayPullSound() {
		EmitCustomToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredPurnell::PlayPullSound()");
		#endif
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredPurnell::PlayTeleportSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		EmitCustomToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredPurnell::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public CuredPurnell(int client, float vecPos[3], float vecAng[3], int ally)
	{
		CuredPurnell npc = view_as<CuredPurnell>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/doctor_purnell.mdl", "1.15", "10000", ally, true, false));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		func_NPCDeath[npc.index] = CuredPurnell_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CuredPurnell_OnTakeDamage;
		func_NPCThink[npc.index] = CuredPurnell_ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flNextMeleeAttack = 0.0;
					
		//IDLE
		npc.m_bThisEntityIgnored = true;
		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedBarrage_Spam = 0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
		npc.m_bNextRangedBarrage_OnGoing = false;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		npc.m_iAttacksTillReload = 6;
		npc.m_bWasSadAlready = false;
		npc.Anger = false;
		npc.m_bScalesWithWaves = true;
		npc.StartPathing();
		npc.m_flNextRangedSpecialAttack = 0.0;
		
		
		//npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_annabelle.mdl");
		//SetVariantString("1.0");
		//AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_flAttackHappenswillhappen = false;
		//BoughtGregHelp = false;
		
		return npc;
	}
}

//TODO 
//Rewrite
public void CuredPurnell_ClotThink(int iNPC)
{
	CuredPurnell npc = view_as<CuredPurnell>(iNPC);
	
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
	//if(BoughtGregHelp || CurrentPlayers <= 4)
	{
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		}
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(npc.m_flReloadDelay > GetGameTime(npc.index))
	{
		npc.m_iChanged_WalkCycle = 999;
		npc.m_flSpeed = 0.0;
		return;
	}
	
	if(!npc.m_iTargetWalkTo)
	{
		npc.m_iTargetWalkTo = GetClosestAllyPlayerGreg(npc.index);
	}
	if(npc.m_iTargetWalkTo > 0)
	{
		if (GetTeam(npc.m_iTargetWalkTo)==GetTeam(npc.index) && 
		b_BobsCuringHand[npc.m_iTargetWalkTo] && b_BobsCuringHand_Revived[npc.m_iTargetWalkTo] >= 20 && TeutonType[npc.m_iTargetWalkTo] == TEUTON_NONE && dieingstate[npc.m_iTargetWalkTo] > 0 
		&& GetEntPropEnt(npc.m_iTargetWalkTo, Prop_Data, "m_hVehicle") == -1 && !b_LeftForDead[npc.m_iTargetWalkTo])
		{
			//walk to client.
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < (70.0*70.0))
			{
				//slowly revive
				ReviveClientFromOrToEntity(npc.m_iTargetWalkTo, npc.index, 1);
				if(npc.m_flNextRangedSpecialAttack && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
				{
					npc.m_flNextRangedSpecialAttack = 0.0;
					npc.SetPlaybackRate(0.0);	
				}
				if(npc.m_iChanged_WalkCycle != 11) 	
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.AddActivityViaSequence("ACT_SPAWN");
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 0.7;
					npc.m_iChanged_WalkCycle = 11;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					//forgot to add walk.
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					int iActivity = npc.LookupActivity("ACT_RUN");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 250.0;
					//forgot to add walk.
				}
				NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
				npc.StartPathing();
			}
		}
		else
		{
			npc.m_iTargetWalkTo = 0;
		}
		return;
	}
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
						
	if(/*BoughtGregHelp || CurrentPlayers <= 4) &&*/ IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
	
			if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 15000 && flDistanceToTarget < 1000000 && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				int Enemy_I_See;
			
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				
				
				if(!IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						int iActivity = npc.LookupActivity("ACT_RUN");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_iChanged_WalkCycle = 4;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 200.0;
					}
					npc.StartPathing();
					
				}
				else
				{
					
					if(npc.m_iChanged_WalkCycle != 3) 	
					{
						int iActivity = npc.LookupActivity("ACT_RUN");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_iChanged_WalkCycle = 3;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 0.0;
					}
					if (npc.m_iAttacksTillReload == 0)
					{
						npc.AddGesture("ACT_RELOAD"); //lol yes caps
						npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
						npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
						npc.m_iAttacksTillReload = 6;
						npc.PlayRangedReloadSound();
						return; //bye
					}
					
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					
					npc.FaceTowards(vecTarget, 10000.0);
					
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.2;
					
					float vecSpread = 0.1;
				
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					
					float x, y;
				//	x = GetRandomFloat( -0.0, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				//	y = GetRandomFloat( -0.0, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					
					vecTarget[2] += 15.0;
					float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
					MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					npc.m_iAttacksTillReload -= 1;
					
					npc.AddGesture("ACT_SHOOT");
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					float DamageDelt = 50.0;
					//if(BoughtGregHelp && CurrentPlayers <= 4)
					{
						DamageDelt = 75.0;
					}
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					FireBullet(npc.index, npc.index, WorldSpaceVec, vecDir, DamageDelt, 9000.0, DMG_BULLET, "bullet_tracer01_red", Owner , _ , "0");

					npc.PlayRangedSound();
					
					if(GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth") < 0)
					{
						npc.PlayKilledEnemy();
					}
				}
			}
			
					
			//Target close enough to hit
			if((flDistanceToTarget < 15000 && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
			{
				npc.StartPathing();
				 //Walk at all times when they are close enough.
					
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					int iActivity = npc.LookupActivity("ACT_RUN");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 250.0;
					//forgot to add walk.
				}
				
				if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
				{
				//	npc.FaceTowards(vecTarget, 1000.0);
					
					if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
					{
						npc.m_flSpeed = 0.0;
						if (!npc.m_flAttackHappenswillhappen)
						{
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.5;
							npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.5;
							npc.AddGesture("ACT_SHOVE");
							npc.PlayMeleeSound();
							npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
							npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
							npc.m_flAttackHappenswillhappen = true;
						}
							
						if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
						{
							Handle swingTrace;
							npc.FaceTowards(vecTarget, 20000.0);
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,2))
							{
									
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									float DamageDelt = 85.0;
									//if(BoughtGregHelp && CurrentPlayers <= 4)
									{
										DamageDelt = 100.0;
									}
									SDKHooks_TakeDamage(target, npc.index, Owner, DamageDelt, DMG_CLUB, -1, _, vecHit);
									
									// Hit particle
									
									
									// Hit sound
									npc.PlayMeleeHitSound();
									
									if(GetEntProp(target, Prop_Data, "m_iHealth") < 0)
									{
										npc.PlayKilledEnemy();
									}
								} 
							}
							delete swingTrace;
							npc.m_flAttackHappenswillhappen = false;
						}
						else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
						{
							npc.m_flAttackHappenswillhappen = false;
						}
					}
				}
			}
	}
	else
	{
		//if(BoughtGregHelp || CurrentPlayers <= 4)
		{
			if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
			{
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
				npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					return;
				}	
			}
		}
		if(!npc.m_bGetClosestTargetTimeAlly)
		{
			npc.m_iTargetAlly = GetClosestAllyPlayer(npc.index);
			npc.m_bGetClosestTargetTimeAlly = true; //Yeah he just picks one.
			npc.m_iChanged_WalkCycle = -1; //Reset
		}
		if(IsValidAllyPlayer(npc.index, npc.m_iTargetAlly))
		{
			npc.m_bWasSadAlready = false;
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget > 250000) //500 units
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					int iActivity = npc.LookupActivity("ACT_RUN");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
					
				}
				NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);	
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);		
				
			}
			else if(flDistanceToTarget > 90000 && flDistanceToTarget < 250000) //300 units
			{
				if(npc.m_iChanged_WalkCycle != 1) 	
				{
					int iActivity = npc.LookupActivity("ACT_RUN");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 125.0;
					npc.StartPathing();
					
				}
				NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);	
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);		
				
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 0) 	//Just copypaste this and alter the id for any and all activities. Standing idle for example is 0.
													//Just alter both id's and add a new walk cylce if you wish to change it, found out that this is the easiest way to do it.
				{
					int iActivity = npc.LookupActivity("ACT_IDLE");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				if (npc.m_iAttacksTillReload < 1)
				{
					npc.AddGesture("ACT_RELOAD"); //lol yes caps
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 4.0;
					npc.m_iAttacksTillReload = 6;
					npc.PlayRangedReloadSound();
				}
				//Stand still.
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
			}
		}
		else
		{
			if(!npc.m_bWasSadAlready)
			{
				npc.m_bWasSadAlready = true;
			}
			npc.m_bGetClosestTargetTimeAlly = false;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
		}
	}
}

public Action CuredPurnell_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (damage < 9999999.0)	//So they can be slayed.
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public void CuredPurnell_NPCDeath(int entity)
{
	CuredPurnell npc = view_as<CuredPurnell>(entity);
//	npc.PlayDeathSound(); He cant die.
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}