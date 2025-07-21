#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

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

static const char g_RangedSpecialAttackSoundsSecondary[][] = {
	"weapons/medi_shield_deploy.wav",
};

static char gGlow1;
static char gExplosive1;
static char gLaser1;

public void EnemyFatherGrigori_OnMapStart_NPC()
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
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedSpecialAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedSpecialAttackSoundsSecondary[i]);	}
	
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	PrecacheModel("models/monk.mdl");
	PrecacheSound("ambient/explosions/explode_9.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");

	PrecacheModel("models/props_mvm/mvm_player_shield2.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Father Grigori");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_enemy_grigori");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return EnemyFatherGrigori(vecPos, vecAng, team, data);
}
methodmap EnemyFatherGrigori < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 14.0);

	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedReloadSound() 
	{
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}	
	public void PlayRangedSpecialAttackSecondarySound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedSpecialAttackSoundsSecondary) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public EnemyFatherGrigori(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		EnemyFatherGrigori npc = view_as<EnemyFatherGrigori>(CClotBody(vecPos, vecAng, "models/monk.mdl", "1.15", "300", ally, false,_,_,_,_));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "shotgun_soldier");
		
		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.m_bmovedelay = true;

		npc.Anger = false;
		npc.m_iAttacksTillReload = 4;
		npc.m_iOverlordComboAttack = 0;
		//phases.
		
		func_NPCDeath[npc.index] = EnemyFatherGrigori_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = EnemyFatherGrigori_OnTakeDamage;
		func_NPCThink[npc.index] = EnemyFatherGrigori_ClotThink;
		npc.m_flRangedArmor = 0.75;

		

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, EnemyFatherGrigori_OnTakeDamagePost);

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_annabelle.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void EnemyFatherGrigori_ClotThink(int iNPC)
{
	EnemyFatherGrigori npc = view_as<EnemyFatherGrigori>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.PlayIdleSound();

	if(!b_NpcIsInADungeon[npc.index])
	{
		if(npc.m_bmovedelay)
		{
			return;
		}
	}

	npc.Update();	

	if(npc.m_blPlayHurtAnimation) //Dont play dodge anim if we are in an animation.
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}


	//Boss deserves full uptime.
	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	float speed;
	if(npc.m_flAttackHappens_bullshit > gameTime)
	{
		speed = 310.0;
	}
	else
	{
		speed = 200.0;
	}

	Npc_Base_Thinking(iNPC, 500.0, "Walk_aiming_all", "ACT_IDLE", speed, gameTime, true, false);
	if(npc.m_flJumpCooldown)
	{
		if(npc.m_flJumpCooldown < gameTime)
		{
			npc.m_flJumpCooldown = 0.0;
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);		
		}
	}

	if(npc.m_flNextRangedBarrage_Singular)
	{
		if(npc.m_flNextRangedBarrage_Singular < gameTime)
		{
			npc.m_flNextRangedBarrage_Singular = 0.0;
			static float victimPos[3];
			static float partnerPos[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
			spawnRing_Vectors(partnerPos, /*RANGE*/ 250 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, /*DURATION*/ 0.4, 6.0, 0.1, 1, 1.0);
				
			for(int client = 1; client <= MaxClients; client++)
			{
				if (IsClientInGame(client))
				{				
					GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", victimPos); 
						
					//from 
					//https://github.com/Batfoxkid/FF2-Library/blob/edited/addons/sourcemod/scripting/freaks/ff2_sarysamods9.sp
					float Distance = GetVectorDistance(victimPos, partnerPos);
					if(Distance < 1250)
					{				
						static float angles[3];
						GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

						if (GetEntityFlags(client) & FL_ONGROUND)
							angles[0] = 0.0; // toss out pitch if on ground

						static float velocity[3];
						GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
						float attraction_intencity = 2.0;
						ScaleVector(velocity, Distance * attraction_intencity);
										
										
						// min Z if on ground
						if (GetEntityFlags(client) & FL_ONGROUND)
							velocity[2] = fmax(325.0, velocity[2]);
									
						// apply velocity
						TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);       
					}
				}
			}	
		}
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 30000.0;
					
					if(npc.m_iOverlordComboAttack >= 1)
					{
						damage = 35000.0;
					}

					npc.PlayMeleeHitSound();

					if(target > 0) 
					{
						KillFeed_SetKillIcon(npc.index, "club");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						KillFeed_SetKillIcon(npc.index, "shotgun_soldier");
					}
				}
				delete swingTrace;
			}
		}
	}
	if(npc.m_flNextRangedAttackHappening)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; 
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 1000.0);
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				
				float projectile_speed = 1000.0;
				float damage_bullet = 25000.0;

				if(npc.m_iOverlordComboAttack >= 1)
				{
					damage_bullet = 30000.0;
				}
				if(npc.m_flAttackHappens_bullshit > gameTime)
				{
					if(npc.m_iChanged_WalkCycle != 7) 	
					{
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_RANGE_ATTACK_SHOTGUN");
						npc.SetPlaybackRate(2.0);
					}						
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_iChanged_WalkCycle = 4;
						npc.AddActivityViaSequence("Walk_aiming_all");
					}

					
					npc.AddGesture("ACT_RANGE_ATTACK_SHOTGUN");	
				}
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed, _,vecTarget);
				npc.FireArrow(vecTarget, damage_bullet, projectile_speed, "models/weapons/w_bullet.mdl", 2.0);	
				npc.PlayRangedSound();
			}
		}
		else
		{
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
			}
		}
	}
	if(npc.m_flNextRangedSpecialAttackHappens)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3];
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				npc.m_iWearable5 = npc.SpawnShield(6.0, "models/props_mvm/mvm_player_shield2.mdl",80.0, false);
				npc.PlayRangedSpecialAttackSecondarySound();
				npc.m_flNextRangedSpecialAttackHappens = 0.0;
			}
		}
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
			
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
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else if(!NpcStats_IsEnemySilenced(npc.index) && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_iState = 5; //Deploy shield.
		}
		else if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && npc.m_flNextTeleport < gameTime && npc.m_iOverlordComboAttack >= 3)
		{
			npc.m_iState = 3; //holy Light
		}
		else if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && npc.m_flNextRangedBarrage_Spam < gameTime && npc.m_iOverlordComboAttack >= 2)
		{
			npc.m_iState = 4; //Pull
		}
		else if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && npc.m_flNextRangedAttack < gameTime)
		{
			if(Can_I_See_Enemy(npc.index, npc.m_iTarget))
			{
				npc.m_iState = 2; //Shoot the enemy?
			}
			else
			{
				npc.m_iState = 0; //Not Close enough...
			}
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
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.AddActivityViaSequence("Walk_aiming_all");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					if(npc.m_flAttackHappens_bullshit > gameTime)
					{
						if(npc.m_iChanged_WalkCycle != 8) 	
						{
							npc.m_iChanged_WalkCycle = 8;
							npc.SetActivity("ACT_MELEE_ATTACK");
						}
						npc.SetPlaybackRate(3.0);
						npc.m_flAttackHappens = gameTime + 0.15;

						npc.m_flDoingAnimation = gameTime + 0.5;
						npc.m_flNextMeleeAttack = gameTime + 0.5;
					}
					else
					{
						npc.SetPlaybackRate(2.0);
						npc.AddGesture("ACT_MELEE_ATTACK");
						npc.m_flAttackHappens = gameTime + 0.3;

						npc.m_flDoingAnimation = gameTime + 0.75;
						npc.m_flNextMeleeAttack = gameTime + 0.75;
					}
					npc.PlayMeleeSound();
					
					npc.m_bisWalking = false;
				}
				else
				{
					npc.m_flNextMeleeAttack = gameTime + 0.2;
				}
			}
			case 2:
			{			
				if(npc.m_flNextRangedAttack < gameTime)
				{
					int Enemy_I_See;
								
					Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					//Can i see This enemy, is something in the way of us?
					//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
					if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
					{
						npc.m_iTarget = Enemy_I_See;

						if (npc.m_iAttacksTillReload == 0)
						{
							if(npc.m_iChanged_WalkCycle != 3) 	
							{
								npc.m_iChanged_WalkCycle = 3;
								npc.SetActivity("ACT_RELOAD_shotgun");
							}
							if(npc.m_flAttackHappens_bullshit > gameTime)
							{
								npc.SetPlaybackRate(2.0);
								npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.2;
								npc.m_iAttacksTillReload = 8;
							}
							else
							{
								npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.4;
								npc.m_iAttacksTillReload = 4;							
							}

							npc.PlayRangedReloadSound();
							npc.m_bisWalking = false;
						}
						else
						{	
							npc.m_iAttacksTillReload -= 1;	
							npc.m_bisWalking = false;
							if(npc.m_iChanged_WalkCycle != 6) 	
							{
								npc.m_iChanged_WalkCycle = 6;
								npc.AddActivityViaSequence("WalkToShoot");
							}
							if(npc.m_flAttackHappens_bullshit > gameTime)
							{
								npc.SetPlaybackRate(2.0);
								npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 0.3;
								npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.85;
								npc.m_flDoingAnimation = GetGameTime(npc.index) + 0.85;
							}
							else
							{
								npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 0.6;
								npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.7;
								npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.7;
							}
						}
					}
					else
					{
						npc.m_flNextRangedAttack = gameTime + 0.2;
					}
				}				
			}
			case 3:
			{			
				int Enemy_I_See;
								
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					if(npc.m_flAttackHappens_bullshit > gameTime)
					{
						npc.m_flNextTeleport = gameTime + 10.0;
					}
					else
					{
						npc.m_flNextTeleport = gameTime + 15.0;
					}

					npc.AddGestureViaSequence("g_Raise_Gun_Settle");

					npc.m_flDoingAnimation = gameTime + 2.0;
					npc.m_bisWalking = true;
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_iChanged_WalkCycle = 4;
						npc.AddActivityViaSequence("Walk_aiming_all");
					}
					FatherGrigori_IOC_Invoke(EntIndexToEntRef(npc.index), npc.m_iTarget);
				}
				else
				{
					npc.m_flNextTeleport = gameTime + 0.2;
				}
			}
			case 4:
			{
				if(npc.m_flAttackHappens_bullshit > gameTime)
				{
					npc.m_flNextRangedBarrage_Spam = gameTime + 10.0;
				}
				else
				{
					npc.m_flNextRangedBarrage_Spam = gameTime + 15.0;
				}
				npc.m_flNextRangedBarrage_Singular = gameTime + 0.8;

				npc.AddGestureViaSequence("g_High_Chop");
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.AddActivityViaSequence("Walk_aiming_all");
				}
				npc.m_flDoingAnimation = gameTime + 2.0;
				npc.m_bisWalking = true;
				npc.SetPlaybackRate(2.0);
			}
			case 5:
			{
				if(npc.m_flAttackHappens_bullshit > gameTime)
				{
					npc.m_flNextRangedSpecialAttack = gameTime + 10.0;
				}
				else
				{
					npc.m_flNextRangedSpecialAttack = gameTime + 15.0;
				}
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 1.0;

				npc.AddGestureViaSequence("g_Presenting");

				if(npc.m_iChanged_WalkCycle != 5) 	//Stand still.
				{
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_IDLE");
				}
				npc.m_bisWalking = false;
				npc.SetPlaybackRate(1.0);
				npc.m_flDoingAnimation = gameTime + 2.0;
			}
		}
	}
	if(!b_NpcIsInADungeon[npc.index])
	{
		if(npc.m_flNextThinkTime > gameTime)
		{
			return;
		}
		npc.m_flNextThinkTime = gameTime + 1.0;
		//re-enable rage.
		if((ReturnEntityMaxHealth(npc.index)) <= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //Anger after half hp/400 hp
		{
			if(npc.flXenoInfectedSpecialHurtTime > (gameTime - 3.0))
			{
				npc.m_iAttacksTillReload = 4;
				npc.m_iOverlordComboAttack = 0;
				npc.m_bmovedelay = true;
				npc.Anger = false;
			}
		}
	}

}


public Action EnemyFatherGrigori_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	EnemyFatherGrigori npc = view_as<EnemyFatherGrigori>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(npc.m_flJumpCooldown > gameTime)
	{
		damage *= 0.35;
	}
	if(!b_NpcIsInADungeon[victim])
	{
		if(npc.m_bmovedelay)
		{
			npc.m_flNextThinkTime = gameTime + 5.0;
			npc.flXenoInfectedSpecialHurtTime = gameTime + 0.1;
			npc.m_bmovedelay = false;
			damage = 0.0;
		}
		if(npc.flXenoInfectedSpecialHurtTime > gameTime)
		{
			damage = 0.0;		
		}
	}
	return Plugin_Changed;
}

public void EnemyFatherGrigori_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	EnemyFatherGrigori npc = view_as<EnemyFatherGrigori>(victim);

	int maxHealth = ReturnEntityMaxHealth(npc.index);
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	if(maxHealth/4 >= Health && !npc.Anger) //Anger after half hp/400 hp
	{
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 2.0;
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();
		npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 30.0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0; //Take way less damage for 5 seconds.
		SetEntityRenderColor(npc.index, 255, 100, 100, 255);
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
	}
	else if(RoundToCeil(float(maxHealth) * 0.4) >= Health && npc.m_iOverlordComboAttack < 3)
	{
		npc.m_iOverlordComboAttack = 3;
	}
	else if(RoundToCeil(float(maxHealth) * 0.6) >= Health && npc.m_iOverlordComboAttack < 2)
	{
		npc.m_iOverlordComboAttack = 2;
	}
	else if(RoundToCeil(float(maxHealth) * 0.85) >= Health && npc.m_iOverlordComboAttack < 1)
	{
		npc.m_iOverlordComboAttack = 1;
	}
}

public void EnemyFatherGrigori_NPCDeath(int entity)
{
	EnemyFatherGrigori npc = view_as<EnemyFatherGrigori>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}






public void FatherGrigori_IOC_Invoke(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		static float distance=87.0; // /29 for duartion till boom
		static float IOCDist=250.0;
		static float IOCdamage=10.0;
		
		float vecTarget[3];
		GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);	
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackCell(data, IOCDist); // Range
		WritePackCell(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		FatherGrigori_IonAttack(data);
	}
}
public Action FatherGrigori_DrawIon(Handle Timer, any data)
{
	FatherGrigori_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void FatherGrigori_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, NORMAL_ZOMBIE_VOLUME, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1, NORMAL_ZOMBIE_VOLUME, NORMAL_ZOMBIE_VOLUME, 255);
	TE_SendToAll();
}

public void FatherGrigori_IonAttack(Handle &data)
{
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Iondistance = ReadPackCell(data);
	float nphi = ReadPackFloat(data);
	int Ionrange = ReadPackCell(data);
	int Iondamage = ReadPackCell(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
		
	if(!IsValidEntity(client) || b_NpcHasDied[client])
	{
		delete data;
		return;
	}
	spawnRing_Vectors(startPosition, Ionrange * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 150, 255, 255, 1, 0.2, 12.0, 4.0, 3);	
		
	if (Iondistance > 0)
	{
		EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
		// Stage 1
		float s=Sine(nphi/360*6.28)*Iondistance;
		float c=Cosine(nphi/360*6.28)*Iondistance;
			
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] = startPosition[2];
			
		position[0] += s;
		position[1] += c;
		FatherGrigori_DrawIonBeam(position, {0, 150, 255, 255});
	
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
		FatherGrigori_DrawIonBeam(position, {0, 150, 255, 255});
			
		// Stage 2
		s=Sine((nphi+45.0)/360*6.28)*Iondistance;
		c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
		FatherGrigori_DrawIonBeam(position, {0, 150, 255, 255});
			
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
		FatherGrigori_DrawIonBeam(position, {0, 150, 255, 255});
			
		// Stage 3
		s=Sine((nphi+90.0)/360*6.28)*Iondistance;
		c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
		FatherGrigori_DrawIonBeam(position,{0, 150, 255, 255});
			
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
		FatherGrigori_DrawIonBeam(position,{0, 150, 255, 255});
			
		// Stage 3
		s=Sine((nphi+135.0)/360*6.28)*Iondistance;
		c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
		FatherGrigori_DrawIonBeam(position, {0, 150, 255, 255});
			
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
		FatherGrigori_DrawIonBeam(position, {0, 150, 255, 255});
	
		if (nphi >= 360)
			nphi = 0.0;
		else
			nphi += 5.0;
	}
	Iondistance -= 5;

	delete data;
		
	Handle nData = CreateDataPack();
	WritePackFloat(nData, startPosition[0]);
	WritePackFloat(nData, startPosition[1]);
	WritePackFloat(nData, startPosition[2]);
	WritePackCell(nData, Iondistance);
	WritePackFloat(nData, nphi);
	WritePackCell(nData, Ionrange);
	WritePackCell(nData, Iondamage);
	WritePackCell(nData, EntIndexToEntRef(client));
	ResetPack(nData);
		
	if (Iondistance > -50)
	CreateTimer(0.1, FatherGrigori_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
	else
	{
		startPosition[2] += 25.0;
		makeexplosion(client, startPosition, 40000/*damage*/, 175/*Range */);
		startPosition[2] -= 25.0;
		TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
		spawnRing_Vectors(startPosition, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 255, 1, 0.5, 20.0, 10.0, 3, Ionrange * 2.0);	
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] += startPosition[2] + 900.0;
		startPosition[2] += -200;
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, NORMAL_ZOMBIE_VOLUME, {255, 255, 255, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, NORMAL_ZOMBIE_VOLUME, {200, 255, 255, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, NORMAL_ZOMBIE_VOLUME, {100, 255, 255, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, NORMAL_ZOMBIE_VOLUME, {0, 255, 255, 255}, 3);
		TE_SendToAll();
	
		position[2] = startPosition[2] + 50.0;

		EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	}
}