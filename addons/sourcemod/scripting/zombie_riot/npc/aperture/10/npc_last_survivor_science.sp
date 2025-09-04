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
};

static char g_MeleeHitSounds[][] = {
	"npc/vort/foot_hit.wav",
};
static char g_MeleeAttackSounds[][] = {
	"vo/ravenholm/monk_blocked01.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/shotgun/shotgun_dbl_fire.wav",
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

static char g_ShieldActivateSounds[][] = {
	"weapons/medi_shield_deploy.wav",
};

static char g_ShieldRetractSounds[][] = {
	"weapons/medi_shield_retract.wav",
};

static char gGlow1;
static char gExplosive1;
static char gLaser1;

public void FatherGrigoriScience_OnMapStart_NPC()
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
	for (int i = 0; i < (sizeof(g_ShieldActivateSounds));   i++) { PrecacheSound(g_ShieldActivateSounds[i]);   }
	for (int i = 0; i < (sizeof(g_ShieldRetractSounds));   i++) { PrecacheSound(g_ShieldRetractSounds[i]);   }
	
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
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Perfected Father Grigori");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_last_survivor_science");
	strcopy(data.Icon, sizeof(data.Icon), "grigori");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FatherGrigoriScience(vecPos, vecAng, team);
}
methodmap FatherGrigoriScience < CClotBody
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

	public void PlayShieldActivateSound() {
		EmitSoundToAll(g_ShieldActivateSounds[GetRandomInt(0, sizeof(g_ShieldActivateSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayShieldRetractSound() {
		EmitSoundToAll(g_ShieldRetractSounds[GetRandomInt(0, sizeof(g_ShieldRetractSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public FatherGrigoriScience(float vecPos[3], float vecAng[3], int ally)
	{
		FatherGrigoriScience npc = view_as<FatherGrigoriScience>(CClotBody(vecPos, vecAng, "models/monk.mdl", "1.15", "10000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
	
		func_NPCDeath[npc.index] = FatherGrigoriScience_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = FatherGrigoriScience_OnTakeDamage;
		func_NPCThink[npc.index] = FatherGrigoriScience_ClotThink;

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, FatherGrigoriScience_OnTakeDamagePost);
		GiveNpcOutLineLastOrBoss(npc.index, true);
					
		//IDLE
		npc.m_bThisNpcIsABoss = true;
		npc.m_iState = 0;
		npc.m_flSpeed = 170.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedBarrage_Spam = 0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
		npc.m_bNextRangedBarrage_OnGoing = false;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 15.0;
		npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 30.0;
		npc.Anger = false;
		npc.StartPathing();
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_shotgun.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_flAttackHappenswillhappen = false;
		
		return npc;
	}
	public void FireGrenade(float vecTarget[3])
	{
		int entity = CreateEntityByName("tf_projectile_pipe");
		if(IsValidEntity(entity))
		{
			float vecForward[3], vecSwingStart[3], vecAngles[3];
			this.GetVectors(vecForward, vecSwingStart, vecAngles);
	
			GetAbsOrigin(this.index, vecSwingStart);
			vecSwingStart[2] += 90.0;
	
			MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
	
			vecSwingStart[0] += vecForward[0] * 64;
			vecSwingStart[1] += vecForward[1] * 64;
			vecSwingStart[2] += vecForward[2] * 64;
	
			vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*800.0;
			vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*800.0;
			vecForward[2] = Sine(DegToRad(vecAngles[0]))*-800.0;
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", this.index);
			
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 77.0); 
			f_CustomGrenadeDamage[entity] = 77.0;	
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			SetEntityModel(entity, "models/weapons/w_grenade.mdl");
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			
			SetEntProp(entity, Prop_Send, "m_bTouched", true);
			SetEntityCollisionGroup(entity, 1);
		}
	}
}


public void FatherGrigoriScience_ClotThink(int iNPC)
{
	FatherGrigoriScience npc = view_as<FatherGrigoriScience>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(npc.m_flAbilityOrAttack0)
	{
		if(IsValidEntity(npc.m_iWearable3))
		{
			npc.m_flAbilityOrAttack0 = gameTime + 999.0;
		}
		if(npc.m_flAbilityOrAttack0 < GetGameTime(npc.index))
		{
			npc.PlayShieldActivateSound();
			npc.m_iWearable3 = npc.SpawnShield(0.0, "models/props_mvm/mvm_player_shield.mdl",40.0);
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
			npc.m_flAbilityOrAttack0 = gameTime + 15.0;
		}
	}
	if(npc.m_flAbilityOrAttack1)
	{
		if(npc.m_flAbilityOrAttack1 < GetGameTime(npc.index))
		{
			npc.PlayShieldRetractSound();
			if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
			npc.m_flAbilityOrAttack1 = gameTime + 30.0;
			npc.m_flAbilityOrAttack0 = gameTime + 15.0;
		}
	}
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest, true))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		npc.StartPathing();
		
		//Target close enough to hit
		
		float vecSpread = 0.1;
				
		float eyePitch[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
		
		float x, y;
		x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		
		float vecDirShooting[3], vecRight[3], vecUp[3];
		
		vecTarget[2] += 15.0;
		float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
		MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
		GetVectorAngles(vecDirShooting, vecDirShooting);
		vecDirShooting[1] = eyePitch[1];
		GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
		float m_vecSrc[3];
		WorldSpaceCenter(npc.index, m_vecSrc);
		float vecEnd[3];
		vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
		vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
		vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
		float vecDir[3];
		vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
		vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
		vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
		NormalizeVector(vecDir, vecDir);
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);


		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && npc.m_flDoingAnimation < GetGameTime(npc.index) && flDistanceToTarget < 202500)
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest,_,_, vPredictedPos);
			if (!npc.Anger)
			{
				npc.FaceTowards(vecTarget, 1000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");
				FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 100.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
				Custom_Knockback(closest, npc.index, 500.0, true, true, true);
				npc.PlayRangedSound();
			}
			else if (npc.Anger)
			{
				npc.FaceTowards(vecTarget, 1000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 3.5;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");
				FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 100.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
				Custom_Knockback(closest, npc.index, 1000.0, true, true, true);
				npc.PlayRangedSound();
			}
		}
											
		if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && flDistanceToTarget < 202500)
		{
			if (!npc.Anger)
			{
				npc.FaceTowards(vecTarget, 500.0);
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;
				if (!npc.m_bNextRangedBarrage_OnGoing)
				{	
					npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.45;
					npc.m_bNextRangedBarrage_OnGoing = true;
					npc.AddGesture("ACT_RANGE_ATTACK_THROW");
				}
				if (npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index) && npc.m_bNextRangedBarrage_OnGoing)
				{
					npc.FireGrenade(vecTarget);
					npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 8.0;
					npc.m_bNextRangedBarrage_OnGoing = false;
				}
			}
			else if (npc.Anger)
			{
				npc.FaceTowards(vecTarget, 500.0);
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;
				if (!npc.m_bNextRangedBarrage_OnGoing)
				{	
					npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.45;
					npc.m_bNextRangedBarrage_OnGoing = true;
					npc.AddGesture("ACT_RANGE_ATTACK_THROW");
				}
				if (npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index) && npc.m_bNextRangedBarrage_OnGoing)
				{
					npc.FireGrenade(vecTarget);
					npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 7.0;
					npc.m_bNextRangedBarrage_OnGoing = false;
				}
			}
		}
		if(npc.m_flNextTeleport < GetGameTime(npc.index) && npc.m_flDoingAnimation < GetGameTime(npc.index) && flDistanceToTarget < 202500)
		{
			if (!npc.Anger)
			{
				npc.FaceTowards(vecTarget, 500.0);
				npc.m_flNextTeleport = GetGameTime(npc.index) + 10.0;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.5;
	//			npc.AddGesture("ACT_SIGNAL1");
				npc.PlayPullSound();
				FatherGrigoriScience_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
			}
			else if (npc.Anger)
			{
				npc.FaceTowards(vecTarget, 500.0);
	//			npc.AddGesture("ACT_SIGNAL1");
				npc.m_flNextTeleport = GetGameTime(npc.index) + 7.0;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.5;
				npc.PlayPullSound();
				FatherGrigoriScience_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
			}
		}
		//Target close enough to hit
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
	//		npc.FaceTowards(vecTarget, 1000.0);
				
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MELEE_ATTACK");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.6;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+1.0;
					npc.m_flAttackHappenswillhappen = true;
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, closest))
					{
								
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							{
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 250.0, DMG_CLUB, -1, _, vecHit);
							}
							
							Custom_Knockback(npc.index, target, 500.0);
							
							// Hit particle
							
									
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.3;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.3;
				}
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
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action FatherGrigoriScience_DrawIon(Handle Timer, any data)
{
	FatherGrigoriScience_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void FatherGrigoriScience_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.25, 25.0, 25.0, 0, NORMAL_ZOMBIE_VOLUME, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1, 0.25, NORMAL_ZOMBIE_VOLUME, 255);
	TE_SendToAll();
}

	public void FatherGrigoriScience_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		float Ionrange = ReadPackFloat(data);
		float Iondamage = ReadPackFloat(data);
		int client = EntRefToEntIndex(ReadPackCell(data));
		
		if(!IsValidEntity(client) || b_NpcHasDied[client])
		{
			delete data;
			return;
		}
		
		spawnRing_Vectors(startPosition, Ionrange * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 10, 255, 10, 255, 1, 0.25, 12.0, 4.0, 3);	
		if (Iondistance > 0)
		{
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
			if(b_thisNpcIsABoss[client])
			{
				// Stage 1
				float s=Sine(nphi/360*6.28)*Iondistance;
				float c=Cosine(nphi/360*6.28)*Iondistance;
				
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[2] = startPosition[2];
				
				position[0] += s;
				position[1] += c;
			//	FatherGrigoriScience_DrawIonBeam(position, {0, 10, 255, 10});
		
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[0] -= s;
				position[1] -= c;
				FatherGrigoriScience_DrawIonBeam(position, {10, 255, 10, 255});
				
				// Stage 2
				s=Sine((nphi+45.0)/360*6.28)*Iondistance;
				c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
				
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[0] += s;
				position[1] += c;
				FatherGrigoriScience_DrawIonBeam(position, {10, 255, 10, 255});
				
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[0] -= s;
				position[1] -= c;
			//	FatherGrigoriScience_DrawIonBeam(position, {0, 10, 255, 10});
				
				// Stage 3
				s=Sine((nphi+90.0)/360*6.28)*Iondistance;
				c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
				
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[0] += s;
				position[1] += c;
			//	FatherGrigoriScience_DrawIonBeam(position,{0, 10, 255, 10});
				
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[0] -= s;
				position[1] -= c;
				FatherGrigoriScience_DrawIonBeam(position,{10, 255, 10, 255});
				
				// Stage 3
				s=Sine((nphi+135.0)/360*6.28)*Iondistance;
				c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
				
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[0] += s;
				position[1] += c;
				FatherGrigoriScience_DrawIonBeam(position, {10, 255, 10, 255});
				
				position[0] = startPosition[0];
				position[1] = startPosition[1];
				position[0] -= s;
				position[1] -= c;
			//	FatherGrigoriScience_DrawIonBeam(position, {0, 10, 255, 10});
			}
		
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 10.0;
		}
		Iondistance -= 10;

		delete data;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackFloat(nData, Ionrange);
		WritePackFloat(nData, Iondamage);
		WritePackCell(nData, EntIndexToEntRef(client));
		ResetPack(nData);
		
		if (Iondistance > -50)
			CreateTimer(0.2, FatherGrigoriScience_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
		else
		{
			startPosition[2] += 25.0;
			makeexplosion(client, startPosition, 150, 175);
			startPosition[2] -= 25.0;
			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			spawnRing_Vectors(startPosition, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 10, 255, 10, 255, 1, 0.5, 20.0, 10.0, 3, Ionrange * 2.0);	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 900.0;
			startPosition[2] += -200;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 1.0, 30.0, 30.0, 0, NORMAL_ZOMBIE_VOLUME, {10, 255, 10, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 1.0, 50.0, 50.0, 0, NORMAL_ZOMBIE_VOLUME, {10, 255, 10, 255}, 3);
			TE_SendToAll();
		//	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, NORMAL_ZOMBIE_VOLUME, {100, 255, 255, 255}, 3);
		//	TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 1.0, 100.0, 100.0, 0, NORMAL_ZOMBIE_VOLUME, {10, 255, 10, 255}, 3);
			TE_SendToAll();
			position[2] = startPosition[2] + 50.0;
			ExpidonsaGroupHeal(client, Ionrange, 500, 1000.0, 1.25, true, .LOS = false,.VecDoAt = position);	
			//new Float:fDirection[3] = {-90.0,0.0,0.0};
			//env_shooter(fDirection, 25.0, 0.1, fDirection, 800.0, 120.0, 120.0, position, "models/props_wasteland/rockgranite03b.mdl");
	
			//env_shake(startPosition, 120.0, 10000.0, 15.0, 250.0);
			
			// Sound
			EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
			// Blend
			//sendfademsg(0, 10, 200, FFADE_OUT, 255, 255, 255, 150);
			
			// Knockback
	/*		float vReturn[3];
			float vClientPosition[3];
			float dist;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
				{	
					GetClientEyePosition(i, vClientPosition);
	
					dist = GetVectorDistance(vClientPosition, position, false);
					if (dist < Ionrange)
					{
						MakeVectorFromPoints(position, vClientPosition, vReturn);
						NormalizeVector(vReturn, vReturn);
						ScaleVector(vReturn, 10000.0 - dist*10);
	
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vReturn);
					}
				}
			}
*/
		}
}

public void FatherGrigoriScience_IOC_Invoke(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		static float distance=87.0; // /29 for duartion till boom
		static float IOCDist=250.0;
		static float IOCdamage=10.0;
		
		float vecTarget[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vecTarget);	
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackFloat(data, IOCDist); // Range
		WritePackFloat(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		FatherGrigoriScience_IonAttack(data);
	}
		
}

public Action FatherGrigoriScience_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	FatherGrigoriScience npc = view_as<FatherGrigoriScience>(victim);
	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker, true))
		return Plugin_Continue;
	*/
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void FatherGrigoriScience_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	FatherGrigoriScience npc = view_as<FatherGrigoriScience>(victim);
	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();
		{
			npc.m_flSpeed = 200.0;
		}
		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
}

public void FatherGrigoriScience_NPCDeath(int entity)
{
	FatherGrigoriScience npc = view_as<FatherGrigoriScience>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, FatherGrigoriScience_OnTakeDamagePost);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}




	
	

	
	


