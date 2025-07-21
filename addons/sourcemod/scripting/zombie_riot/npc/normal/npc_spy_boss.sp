#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"vo/spy_laughhappy01.mp3",
	"vo/spy_laughhappy02.mp3",
	"vo/spy_laughhappy03.mp3",
};


static const char g_RangedAttackSounds[][] = {
	"weapons/diamond_back_01.wav",
	"weapons/diamond_back_02.wav",
	"weapons/diamond_back_03.wav"
};

static const char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static const char g_decloak[][] = {
	"player/spy_uncloak_feigndeath.wav",
};

static const char g_AngerSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};
//int g_iPathLaserModelIndex = -1;

void SpyMainBoss_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_decloak));   i++) { PrecacheSound(g_decloak[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "X10 Spy Main");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_spy_boss");
	strcopy(data.Icon, sizeof(data.Icon), "spy_x10_main");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SpyMainBoss(vecPos, vecAng, team);
}
methodmap SpyMainBoss < CClotBody
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
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayDecloakSound() {
		EmitSoundToAll(g_decloak[GetRandomInt(0, sizeof(g_decloak) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_decloak[GetRandomInt(0, sizeof(g_decloak) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_decloak[GetRandomInt(0, sizeof(g_decloak) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}

	public SpyMainBoss(float vecPos[3], float vecAng[3], int ally)
	{
		SpyMainBoss npc = view_as<SpyMainBoss>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "500000", ally));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		

		func_NPCDeath[npc.index] = SpyMainBoss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SpyMainBoss_OnTakeDamage;
		func_NPCThink[npc.index] = SpyMainBoss_ClotThink;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, SpyMainBoss_ClotDamaged_Post);
		
		npc.m_iAttacksTillReload = 6;
		npc.m_bThisNpcIsABoss = true;
		npc.m_fbGunout = false;
		npc.m_bmovedelay_gun = false;
		npc.m_bmovedelay = false;
		
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		npc.Anger = false;
		npc.m_iState = 0;
		npc.m_flSpeed = 330.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flHalf_Life_Regen = false;

		npc.m_iWearable5 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable5, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 255);
		
		npc.m_iWearable4 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 255);
		
		
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop_partner/player/items/spy/shogun_ninjamask/shogun_ninjamask.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/workshop/player/items/spy/short2014_invisible_ishikawa/short2014_invisible_ishikawa.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/spr17_legendary_lid/spr17_legendary_lid_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
		
		AcceptEntityInput(npc.m_iWearable5, "Disable");
		
		return npc;
	}
	
}


public void SpyMainBoss_ClotThink(int iNPC)
{
	SpyMainBoss npc = view_as<SpyMainBoss>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	float TrueArmor = 1.0;
	if(npc.m_flDead_Ringer_Invis_bool && !NpcStats_IsEnemySilenced(npc.index))
	{
		TrueArmor *= 0.1;
	}
	if(npc.Anger)
	{
		TrueArmor *= 0.65;
	}
	fl_TotalArmor[npc.index] = TrueArmor;

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	if(npc.m_flDead_Ringer_Invis < GetGameTime(npc.index) && npc.m_flDead_Ringer_Invis_bool)
	{
		npc.m_flDead_Ringer_Invis_bool = false;
			
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
			
		SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 255);
			
		SetEntityRenderMode(npc.m_iWearable5, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 255);
			
		SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);
			
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
			
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
			
		npc.PlayDecloakSound();
		npc.PlayDecloakSound();
		b_IsEntityNeverTranmitted[npc.index] = false;
		npc.m_bTeamGlowDefault = true;
		GiveNpcOutLineLastOrBoss(npc.index, true);
	}

	if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
	{
	
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if (npc.m_flReloadDelay < GetGameTime(npc.index) && flDistanceToTarget < 40000 || flDistanceToTarget > 90000 && npc.m_fbGunout == true && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			if (!npc.m_bmovedelay)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay = true;
				if(!npc.Anger)
					npc.m_flSpeed = 330.0;
				else if(npc.Anger)
					npc.m_flSpeed = 340.0;
				npc.m_bmovedelay_gun = false;
			}
			
			AcceptEntityInput(npc.m_iWearable5, "Disable");
			AcceptEntityInput(npc.m_iWearable4, "Enable");
		//	npc.FaceTowards(vecTarget, 1000.0);
			npc.StartPathing();
			
			
		}
		else if (npc.m_flReloadDelay < GetGameTime(npc.index) && flDistanceToTarget > 40000 && flDistanceToTarget < 90000)
		{
			if (!npc.m_bmovedelay_gun)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay_gun = true;
				
				if(!npc.Anger)
					npc.m_flSpeed = 330.0;
				else if(npc.Anger)
					npc.m_flSpeed = 340.0;
					
				npc.m_bmovedelay = false;
			}
			AcceptEntityInput(npc.m_iWearable5, "Enable");
			AcceptEntityInput(npc.m_iWearable4, "Disable");
		//	npc.FaceTowards(vecTarget, 1000.0);
			npc.StartPathing();
			
		}		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
		/*	int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
		
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
		
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
			
			npc.SetGoalVector(vPredictedPos);
		} else {
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		if(npc.m_flDead_Ringer_Invis_bool) //no attack or anything.
		{
			npc.m_flSpeed = 300.0; //Abit slower
			return;
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 40000 && flDistanceToTarget < 90000 && npc.m_flReloadDelay < GetGameTime(npc.index) && !npc.Anger)
		{
			float vecSpread = 0.1;
			
			npc.FaceTowards(vecTarget, 20000.0);
			
			float eyePitch[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
			
			
			float x, y;
			x = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
			y = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
			
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
			
			//add the spray
			float vecbro[3];
			vecbro[0] = vecDirShooting[0] + 0.0 * vecSpread * vecRight[0] + 0.0 * vecSpread * vecUp[0]; 
			vecbro[1] = vecDirShooting[1] + 0.0 * vecSpread * vecRight[1] + 0.0 * vecSpread * vecUp[1]; 
			vecbro[2] = vecDirShooting[2] + 0.0 * vecSpread * vecRight[2] + 0.0 * vecSpread * vecUp[2]; 
			NormalizeVector(vecbro, vecbro);
			
			npc.m_bmovedelay = false;
			
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.7;
			npc.m_iAttacksTillReload -= 1;
			
			if (npc.m_iAttacksTillReload == 0)
			{
				npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
				npc.m_flReloadDelay = GetGameTime(npc.index) + 1.4;
				npc.m_iAttacksTillReload = 6;
				npc.PlayRangedReloadSound();
			}
			
			npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
			float vecDir[3];
			vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
			vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
			vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
			NormalizeVector(vecDir, vecDir);
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);

			FireBullet(npc.index, npc.m_iWearable5, WorldSpaceVec, vecDir, 60.0, 9000.0, DMG_BULLET, "bullet_tracer01_blue");
			
			npc.PlayRangedSound();
		}
		else if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > 40000 && flDistanceToTarget < 90000 && npc.m_flReloadDelay < GetGameTime(npc.index) && npc.Anger)
		{		
			npc.FaceTowards(vecTarget, 20000.0);
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.3;
			npc.m_iAttacksTillReload -= 1;
			
			if (npc.m_iAttacksTillReload == 0)
			{
				npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
				npc.m_flReloadDelay = GetGameTime(npc.index) + 1.4;
				npc.m_iAttacksTillReload = 6;
				npc.PlayRangedReloadSound();
			}
			
			npc.FireRocket(vPredictedPos, 75.0, 900.0);
			npc.PlayRangedSound();
		}
		if(flDistanceToTarget < 90000 && npc.m_flReloadDelay < GetGameTime(npc.index) || flDistanceToTarget > 90000 && npc.m_flReloadDelay < GetGameTime(npc.index) )
		{
			npc.StartPathing();
			
			npc.m_fbGunout = false;
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 2000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) && flDistanceToTarget < 40000)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.1;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.21;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 100.0, 100.0, 100.0 }, { -100.0, -100.0, -100.0 })) 
					{
								
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(!npc.Anger)
							{
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 180.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 3000.0, DMG_CLUB, -1, _, vecHit);	
							}
							else if(npc.Anger)
							{
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 4500.0, DMG_CLUB, -1, _, vecHit);	
							}
								
							if(npc.m_iAttacksTillMegahit >= 3)
							{
								Custom_Knockback(npc.index, target, 500.0);
								
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
										
								npc.m_iAttacksTillMegahit = 0;
										
							}
									
							npc.m_iAttacksTillMegahit += 1;
							// Hit particle
							
								
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.65;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.65;
				}
			}
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


public Action SpyMainBoss_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	SpyMainBoss npc = view_as<SpyMainBoss>(victim);
	
	if(npc.m_flDead_Ringer < GetGameTime(npc.index))
	{
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 1);
		
		SetEntityRenderMode(npc.m_iWearable5, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 1);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 1);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NONE);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
		
		npc.m_flDead_Ringer_Invis = GetGameTime(npc.index) + 2.0;
		npc.m_flDead_Ringer = GetGameTime(npc.index) + 13.0;
		npc.m_flDead_Ringer_Invis_bool = true;
		b_IsEntityNeverTranmitted[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		npc.m_bTeamGlowDefault = false;
		npc.PlayDeathSound();	
				
		float TrueArmor = 1.0;
		if(!NpcStats_IsEnemySilenced(victim))
		{
			if(fl_TotalArmor[npc.index] == 1.0)
			{
				TrueArmor *= 0.1;
				fl_TotalArmor[npc.index] = TrueArmor;
				OnTakeDamageNpcBaseArmorLogic(victim, attacker, damage, damagetype, true);
			}
		}
		fl_TotalArmor[npc.index] = TrueArmor;
	}
	
	return Plugin_Changed;
}

public void SpyMainBoss_ClotDamaged_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	SpyMainBoss npc = view_as<SpyMainBoss>(victim);
	if((ReturnEntityMaxHealth(npc.index) / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();
		npc.m_flHalf_Life_Regen = false;
		
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
	}
}


public Action Set_Spymain_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(entity) / 2));
	}
	return Plugin_Stop;
}

public void SpyMainBoss_NPCDeath(int entity)
{
	SpyMainBoss npc = view_as<SpyMainBoss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, SpyMainBoss_ClotDamaged_Post);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}