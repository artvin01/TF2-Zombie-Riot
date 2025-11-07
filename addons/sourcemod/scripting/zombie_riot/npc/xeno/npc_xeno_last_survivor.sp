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


static char gGlow1_Xeno;
static char gExplosive1_Xeno;
static char gLaser1_Xeno;

public void XenoFatherGrigori_OnMapStart_NPC()
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
	
	gLaser1_Xeno = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1_Xeno = PrecacheModel("sprites/blueglow2.vmt", true);
	gExplosive1_Xeno = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/explode_9.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Xeno Father Grigori");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_last_survivor");
	strcopy(data.Icon, sizeof(data.Icon), "grigori");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Xeno;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return XenoFatherGrigori(vecPos, vecAng, team);
}
methodmap XenoFatherGrigori < CClotBody
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		

	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80, 80);
		

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);

	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public XenoFatherGrigori(float vecPos[3], float vecAng[3], int ally)
	{
		XenoFatherGrigori npc = view_as<XenoFatherGrigori>(CClotBody(vecPos, vecAng, "models/zombie_riot/grigori/monk_custom.mdl", "1.15", "10000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK_AIM_RIFLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iBleedType = BLEEDTYPE_XENO;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
	
		func_NPCDeath[npc.index] = XenoFatherGrigori_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = XenoFatherGrigori_OnTakeDamage;
		func_NPCThink[npc.index] = XenoFatherGrigori_ClotThink;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, XenoFatherGrigori_ClotDamagedPost);
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		SetEntityRenderColor(npc.index, 150, 255, 150, 255);
		
		//IDLE
		npc.m_bThisNpcIsABoss = true;
		npc.m_flSpeed = 170.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedBarrage_Spam = 0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
		npc.m_bNextRangedBarrage_OnGoing = false;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
		npc.m_flDoingAnimation = 0.0;
		npc.Anger = false;
		npc.StartPathing();
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_annabelle.mdl");
		SetVariantString("1.0");
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
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 75.0);
			f_CustomGrenadeDamage[entity] = 75.0;			
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			SetEntityModel(entity, "models/weapons/w_grenade.mdl");
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
		}
	}
}


public void XenoFatherGrigori_ClotThink(int iNPC)
{
	XenoFatherGrigori npc = view_as<XenoFatherGrigori>(iNPC);
	
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
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
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
		
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			if (!npc.Anger)
			{
				npc.FaceTowards(vecTarget, 1000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.5;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");
				
				float projectile_speed = 800.0;
				
				PredictSubjectPositionForProjectiles(npc, closest, projectile_speed,_, vecTarget);
							
				npc.PlayMeleeSound();
				
				npc.FireRocket(vecTarget, 20.0, projectile_speed, "models/weapons/w_bullet.mdl", 2.0);	
				npc.PlayRangedSound();
			}
			else if (npc.Anger)
			{
				npc.FaceTowards(vecTarget, 1000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.5;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.0;
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SHOTGUN");		
				float projectile_speed = 800.0;
				
				PredictSubjectPositionForProjectiles(npc, closest, projectile_speed,_, vecTarget);
							
				npc.PlayMeleeSound();
				
				npc.FireRocket(vecTarget, 20.0, projectile_speed, "models/weapons/w_bullet.mdl", 2.0);	
				npc.PlayRangedSound();
			}
		}
			/*							
			if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && flDistanceToTarget < 562500)
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
			*/
		if(npc.m_flNextTeleport < GetGameTime(npc.index) && npc.m_flDoingAnimation < GetGameTime(npc.index) && flDistanceToTarget < 260500)
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, closest);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == closest)
			{
				if (!npc.Anger)
				{
					npc.FaceTowards(vecTarget, 500.0);
					npc.m_flNextTeleport = GetGameTime(npc.index) + 10.0;
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.5;
		//			npc.AddGesture("ACT_SIGNAL1");
					npc.PlayPullSound();
					XenoFatherGrigori_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
				}
				else if (npc.Anger)
				{
					npc.FaceTowards(vecTarget, 500.0);
		//			npc.AddGesture("ACT_SIGNAL1");
					npc.m_flNextTeleport = GetGameTime(npc.index) + 7.0;
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.5;
					npc.PlayPullSound();
					XenoFatherGrigori_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
				}
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
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
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
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action XenoFatherGrigori_DrawIon(Handle Timer, any data)
{
	XenoFatherGrigori_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void XenoFatherGrigori_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1_Xeno, 0, 0, 0, 0.25, 25.0, 25.0, 0, NORMAL_ZOMBIE_VOLUME, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1_Xeno, 0.25, NORMAL_ZOMBIE_VOLUME, 255);
	TE_SendToAll();
}

public void XenoFatherGrigori_IonAttack(Handle &data)
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
	spawnRing_Vectors(startPosition, Ionrange * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 150, 255, 150, 255, 1, 0.2, 12.0, 4.0, 3);	
	
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
		//	XenoFatherGrigori_DrawIonBeam(position, {150, 255, 150, 255});
	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			XenoFatherGrigori_DrawIonBeam(position, {150, 255, 150, 255});
			
			// Stage 2
			s=Sine((nphi+45.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			XenoFatherGrigori_DrawIonBeam(position, {150, 255, 150, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
		//	XenoFatherGrigori_DrawIonBeam(position, {150, 255, 150, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
		//	XenoFatherGrigori_DrawIonBeam(position,{150, 255, 150, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			XenoFatherGrigori_DrawIonBeam(position,{150, 255, 150, 255});
			
			// Stage 3
			s=Sine((nphi+135.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			XenoFatherGrigori_DrawIonBeam(position, {150, 255, 150, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
		//	XenoFatherGrigori_DrawIonBeam(position, {150, 255, 150, 255});
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
		CreateTimer(0.2, XenoFatherGrigori_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
	else
	{
		startPosition[2] += 25.0;
		makeexplosion(client, startPosition, 150, 175);
		startPosition[2] -= 25.0;
		TE_SetupExplosion(startPosition, gExplosive1_Xeno, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
		spawnRing_Vectors(startPosition, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 150, 255, 150, 255, 1, 0.5, 20.0, 10.0, 3, Ionrange * 2.0);	
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] += startPosition[2] + 900.0;
		startPosition[2] += -200;
		TE_SetupBeamPoints(startPosition, position, gLaser1_Xeno, 0, 0, 0, 1.0, 30.0, 30.0, 0, 1.0, {150, 255, 150, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1_Xeno, 0, 0, 0, 1.0, 50.0, 50.0, 0, 1.0, {150, 255, 150, 255}, 3);
		TE_SendToAll();
	//	TE_SetupBeamPoints(startPosition, position, gLaser1_Xeno, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {150, 255, 150, 255}, 3);
	//	TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, gLaser1_Xeno, 0, 0, 0, 1.0, 100.0, 100.0, 0, 1.0, {150, 255, 150, 255}, 3);
		TE_SendToAll();

		position[2] = startPosition[2] + 50.0;
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

public void XenoFatherGrigori_IOC_Invoke(int ref, int enemy)
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
		WritePackFloat(data, IOCDist); // Range
		WritePackFloat(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		XenoFatherGrigori_IonAttack(data);
	}
}

public Action XenoFatherGrigori_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	XenoFatherGrigori npc = view_as<XenoFatherGrigori>(victim);
	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void XenoFatherGrigori_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	XenoFatherGrigori npc = view_as<XenoFatherGrigori>(victim);
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
public void XenoFatherGrigori_NPCDeath(int entity)
{
	XenoFatherGrigori npc = view_as<XenoFatherGrigori>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, XenoFatherGrigori_ClotDamagedPost);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}



	
	

	
	


