#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"vo/ravenholm/monk_death07.wav",
};

static char g_HurtSounds[][] = {
	"vo/ravenholm/monk_pain01.wav",
	"vo/ravenholm/monk_pain02.wav",
	"vo/ravenholm/monk_pain03.wav",
	"vo/ravenholm/monk_pain04.wav",
	"vo/ravenholm/monk_pain05.wav",
	"vo/ravenholm/monk_pain06.wav",
	"vo/ravenholm/monk_pain07.wav",
	"vo/ravenholm/monk_pain08.wav",
	"vo/ravenholm/monk_pain09.wav",
	"vo/ravenholm/monk_pain10.wav",
	"vo/ravenholm/monk_pain12.wav",
};

static char g_IdleSounds[][] = {
	"vo/ravenholm/monk_kill01.wav",
	"vo/ravenholm/monk_kill02.wav",
	"vo/ravenholm/monk_kill03.wav",
	"vo/ravenholm/monk_kill04.wav",
	"vo/ravenholm/monk_kill05.wav",
	"vo/ravenholm/monk_kill06.wav",
	"vo/ravenholm/monk_kill07.wav",
	"vo/ravenholm/monk_kill08.wav",
	"vo/ravenholm/monk_kill09.wav",
	"vo/ravenholm/monk_kill10.wav",
	"vo/ravenholm/monk_kill11.wav",
	
};

static char g_IdleAlertedSounds[][] = {
	"vo/ravenholm/monk_rant01.wav",
	"vo/ravenholm/monk_rant02.wav",
	"vo/ravenholm/monk_rant04.wav",
	"vo/ravenholm/monk_rant05.wav",
	"vo/ravenholm/monk_rant06.wav",
	"vo/ravenholm/monk_rant07.wav",
	"vo/ravenholm/monk_rant08.wav",
	"vo/ravenholm/monk_rant09.wav",
	"vo/ravenholm/monk_rant10.wav",
	"vo/ravenholm/monk_rant11.wav",
	"vo/ravenholm/monk_rant12.wav",
	"vo/ravenholm/monk_rant13.wav",
	"vo/ravenholm/monk_rant14.wav",
	"vo/ravenholm/monk_rant15.wav",
	"vo/ravenholm/monk_rant16.wav",
	"vo/ravenholm/monk_rant17.wav",
	"vo/ravenholm/monk_rant19.wav",
	"vo/ravenholm/monk_rant20.wav",
	"vo/ravenholm/monk_rant21.wav",
	"vo/ravenholm/monk_rant22.wav",
	"vo/ravenholm/yard_shepherd.wav",
	"vo/ravenholm/yard_suspect.wav",
	"vo/ravenholm/shotgun_stirreduphell.wav",
	"vo/ravenholm/shotgun_theycome.wav",
	"vo/ravenholm/wrongside_seekchurch.wav",
	"vo/ravenholm/wrongside_town.wav",
	"vo/ravenholm/pyre_keepeye.wav",
	"vo/ravenholm/pyre_anotherlife.wav",
	"vo/ravenholm/madlaugh01.wav",
	"vo/ravenholm/madlaugh02.wav",
	"vo/ravenholm/madlaugh03.wav",
	"vo/ravenholm/madlaugh04.wav",
	"vo/ravenholm/grave_stayclose.wav",
	"vo/ravenholm/grave_follow.wav",
	"vo/ravenholm/attic_apologize.wav",
	"vo/ravenholm/aimforhead.wav",
	"vo/ravenholm/bucket_guardwell.wav",
	"vo/ravenholm/cartrap_iamgrig.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/vort/foot_hit.wav",
};
static char g_MeleeAttackSounds[][] = {
	"vo/ravenholm/monk_blocked01.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/shotgun/shotgun_fire6.wav",
	"weapons/shotgun/shotgun_fire7.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	"vo/ravenholm/monk_helpme01.wav",
	"vo/ravenholm/monk_helpme02.wav",
	"vo/ravenholm/monk_helpme03.wav",
	"vo/ravenholm/monk_helpme04.wav",
	"vo/ravenholm/monk_helpme05.wav",
};

static char g_PullSounds[][] = {
	"vo/ravenholm/monk_mourn02.wav",
	"vo/ravenholm/monk_mourn03.wav",
};


static char g_RangedReloadSound[][] = {
	"weapons/shotgun/shotgun_reload1.wav",
};

static char g_SadDueToAllyDeath[][] = {
	"vo/ravenholm/monk_mourn01.wav",
	"vo/ravenholm/monk_mourn02.wav",
	"vo/ravenholm/monk_mourn03.wav",
	"vo/ravenholm/monk_mourn04.wav",
	"vo/ravenholm/monk_mourn05.wav",
	"vo/ravenholm/monk_mourn06.wav",
	"vo/ravenholm/monk_mourn07.wav",
};

static char g_KilledEnemy[][] = {
	"vo/ravenholm/monk_kill01.wav",
	"vo/ravenholm/monk_kill02.wav",
	"vo/ravenholm/monk_kill03.wav",
	"vo/ravenholm/monk_kill04.wav",
	"vo/ravenholm/monk_kill05.wav",
	"vo/ravenholm/monk_kill06.wav",
	"vo/ravenholm/monk_kill07.wav",
	"vo/ravenholm/monk_kill08.wav",
	"vo/ravenholm/monk_kill09.wav",
	"vo/ravenholm/monk_kill10.wav",
	"vo/ravenholm/monk_kill11.wav",
};

public void CuredFatherGrigori_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_SadDueToAllyDeath));   i++) { PrecacheSound(g_SadDueToAllyDeath[i]);   }
	for (int i = 0; i < (sizeof(g_KilledEnemy));   i++) { PrecacheSound(g_KilledEnemy[i]);   }
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/explode_9.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
}

methodmap CuredFatherGrigori < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		Citizen_LiveCitizenReaction(this.index);	
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(48.0, 60.0);
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		Citizen_LiveCitizenReaction(this.index);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 38.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayDeathSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayRangedSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
	//	if (GetRandomInt(0, 5) == 2)
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
			
			#if defined DEBUG_SOUND
			PrintToServer("CCuredFatherGrigori::PlayMeleeHitSound()");
			#endif
		}
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, 95, _, 1.0);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, 95, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::Playnpc.AngerSound()");
		#endif
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayRangedSound()");
		#endif
	}
	
	public void PlayKilledEnemy() {
		EmitSoundToAll(g_KilledEnemy[GetRandomInt(0, sizeof(g_KilledEnemy) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		this.m_flNextIdleSound += 2.0;
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayRangedSound()");
		#endif
	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayPullSound()");
		#endif
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayTeleportSound()");
		#endif
	}
	public void PlaySadMourn() {
		EmitSoundToAll(g_SadDueToAllyDeath[GetRandomInt(0, sizeof(g_SadDueToAllyDeath) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		this.m_flNextIdleSound += 2.0;
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayTeleportSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCuredFatherGrigori::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public CuredFatherGrigori(int client, float vecPos[3], float vecAng[3])
	{
		CuredFatherGrigori npc = view_as<CuredFatherGrigori>(CClotBody(vecPos, vecAng, "models/monk.mdl", "1.15", "10000", true, true, false));
		
		i_NpcInternalId[npc.index] = CURED_FATHER_GRIGORI;
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, CuredFatherGrigori_ClotThink);
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flNextMeleeAttack = 0.0;
					
		//IDLE
		npc.m_bThisEntityIgnored = true;
		npc.m_iState = 0;
		npc.m_flSpeed = 250.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedBarrage_Spam = 0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
		npc.m_bNextRangedBarrage_OnGoing = false;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		npc.m_iAttacksTillReload = 2;
		npc.m_bWasSadAlready = false;
		npc.Anger = false;
		npc.m_bScalesWithWaves = true;
		npc.StartPathing();
		
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_annabelle.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_flAttackHappenswillhappen = false;
		
		return npc;
	}
}

//TODO 
//Rewrite
public void CuredFatherGrigori_ClotThink(int iNPC)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(iNPC);
	
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
	if(CurrentPlayers <= 4)
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
						
	if(CurrentPlayers <= 4 && IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
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
						int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_iChanged_WalkCycle = 4;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 150.0;
					}
					npc.StartPathing();
					
				}
				else
				{
					
					if(npc.m_iChanged_WalkCycle != 3) 	
					{
						int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
						if(iActivity > 0) npc.StartActivity(iActivity);
						npc.m_iChanged_WalkCycle = 3;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 0.0;
					}
					if (npc.m_iAttacksTillReload == 0)
					{
						npc.AddGesture("ACT_RELOAD_shotgun"); //lol no caps
						npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
						npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
						npc.m_iAttacksTillReload = 2;
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
					MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					npc.m_iAttacksTillReload -= 1;
					
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9000.0, DMG_BULLET, "bullet_tracer01_red", _ , _ , "0");
					
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
					int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
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
							npc.AddGesture("ACT_MELEE_ATTACK");
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
									SDKHooks_TakeDamage(target, npc.index, npc.index, 85.0, DMG_CLUB, -1, _, vecHit);
									
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
		if(CurrentPlayers <= 4)
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
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(flDistanceToTarget > 250000) //500 units
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					int iActivity = npc.LookupActivity("ACT_RUN_AR2_RELAXED");
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
					int iActivity = npc.LookupActivity("ACT_WALK_AR2_RELAXED");
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
					int iActivity = npc.LookupActivity("ACT_MONK_GUN_IDLE");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				if (npc.m_iAttacksTillReload != 2)
				{
					npc.AddGesture("ACT_RELOAD_shotgun"); //lol no caps
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
					npc.m_iAttacksTillReload = 2;
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
				npc.PlaySadMourn();
				npc.m_bWasSadAlready = true;
			}
			npc.m_bGetClosestTargetTimeAlly = false;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
		}
	}
	npc.PlayIdleAlertSound();
}

public Action CuredFatherGrigori_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (damage < 9999999.0)	//So they can be slayed.
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public void CuredFatherGrigori_NPCDeath(int entity)
{
	CuredFatherGrigori npc = view_as<CuredFatherGrigori>(entity);
//	npc.PlayDeathSound(); He cant die.
	
	
	SDKUnhook(npc.index, SDKHook_Think, CuredFatherGrigori_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}


