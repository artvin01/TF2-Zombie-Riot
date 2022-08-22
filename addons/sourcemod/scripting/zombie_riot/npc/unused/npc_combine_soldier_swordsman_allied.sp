#include <sdkhooks>
#include <tf2_stocks>
#include <PathFollower>
#include <PathFollower_Nav>
#include <customkeyvalues>
#include <dhooks>

//#define DEBUG_UPDATE
//#define DEBUG_ANIMATION
//#define DEBUG_SOUND
#define ISCOMBINESTEPSOUND
#define ISALLY
	
#include <base/CBaseActor_ZR>

#pragma newdecls required;




char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfirm.wav",
};

char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};
char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

// Code based on Clot from Pelo. Credit to him.
public Plugin myinfo = 
{
	name = "[TF2] Custom NPC", 
	author = "Pelipoika & Artvin", 
	description = "", 
	version = "1.0", 
	url = "" 
};

public void OnPluginStart()
{
	RegAdminCmd("sm_combine_soldier_swordsman_Ally", Command_PetMenu, ADMFLAG_ROOT);
	
	InitGamedata();
}


public void OnMapStart_NPC()
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
	InitNavGamedata();
}

methodmap Clot < CClotBody
{
	property float m_flHeadshotCooldown
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flHeadshotCooldown"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flHeadshotCooldown", buff, true); }
	}
	property int m_iState
	{
		public get()			  { return this.ExtractStringValueAsInt("m_iState"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iState", buff, true); }
	}
	property int m_iGun
	{
		public get()			  { return this.ExtractStringValueAsInt("m_iGun"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iGun", buff, true); }
	}
	property int m_iAttacksTillReload
	{
		public get()			  { return this.ExtractStringValueAsInt("m_iAttacksTillReload"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iAttacksTillReload", buff, true); }
	}
	property float m_flNextTargetTime
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flNextTargetTime"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flNextTargetTime", buff, true); }
	}
	property float m_flNextIdleSound
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flNextIdleSound"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flNextIdleSound", buff, true); }
	}
	property float m_flNextHurtSound
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flNextHurtSound"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flNextHurtSound", buff, true); }
	}
	property float m_flNextBloodSpray
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flNextBloodSpray"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flNextBloodSpray", buff, true); }
	}
	
	property float m_flAttackHappens
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flAttackHappens"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flAttackHappens", buff, true); }
	}
	property float m_flAttackHappens_bullshit
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flAttackHappens_bullshit"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flAttackHappens_bullshit", buff, true); }
	}
	property bool m_flAttackHappenswillhappen
	{
		public get()			{ return !!this.ExtractStringValueAsInt("m_flAttackHappenswillhappen"); }
		public set(bool bOnOff) { char buff[8]; IntToString(bOnOff, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flAttackHappenswillhappen", buff, true); }
	}
	property float m_flNextRangedAttack
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flNextRangedAttack"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flNextRangedAttack", buff, true); }
	}
	property float m_flNextRangedSpecialAttack
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flNextRangedSpecialAttack"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flNextRangedSpecialAttack", buff, true); }
	}
	property float m_flmovedelay
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flmovedelay"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flmovedelay", buff, true); }
	}
	property float m_flReloadDelay
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flReloadDelay"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flReloadDelay", buff, true); }
	}
	property float m_flRangedSpecialDelay
	{
		public get()				 { return this.ExtractStringValueAsFloat("m_flRangedSpecialDelay"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_flRangedSpecialDelay", buff, true); }
	}
	property bool m_fbRangedSpecialOn
	{
		public get()			{ return !!this.ExtractStringValueAsInt("m_fbRangedSpecialOn"); }
		public set(bool bOnOff) { char buff[8]; IntToString(bOnOff, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_fbRangedSpecialOn", buff, true); }
	}
		
		
	property int m_iBatton
	{
		public get()		 
		{ 
			return EntRefToEntIndex(this.ExtractStringValueAsInt("m_iBatton")); 
		}
		public set(int iInt) 
		{
			char buff[32]; 
			IntToString(iInt == INVALID_ENT_REFERENCE ? -1 : EntIndexToEntRef(iInt), buff, sizeof(buff)); 
			SetCustomKeyValue(this.index, "m_iBatton", buff, true); 
		}
	}
	property int m_ihat
	{
		public get()		 
		{ 
			return EntRefToEntIndex(this.ExtractStringValueAsInt("m_ihat")); 
		}
		public set(int iInt) 
		{
			char buff[32]; 
			IntToString(iInt == INVALID_ENT_REFERENCE ? -1 : EntIndexToEntRef(iInt), buff, sizeof(buff)); 
			SetCustomKeyValue(this.index, "m_ihat", buff, true); 
		}
	}
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, 90, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	
	public Clot(int client, float vecPos[3], float vecAng[3], const char[] model)
	{
		Clot npc = view_as<Clot>(CBaseActor(vecPos, vecAng, model, "1.15", "2000"));
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.CreatePather(16.0, npc.GetMaxJumpHeight(), 1000.0, npc.GetSolidMask(), 100.0, 0.4, 1.75);
		npc.m_flNextTargetTime  = GetGameTime() + GetRandomFloat(1.0, 4.0);
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 220.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_iBatton = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iBatton, "SetModelScale");
		
		npc.m_ihat = npc.EquipItem("partyhat", "models/workshop/player/items/demo/jul13_trojan_helmet/jul13_trojan_helmet.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_ihat, "SetModelScale");
		
		PF_StartPathing(npc.index);
		npc.m_bPathing = true;
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void ClotThink(int iNPC)
{
	Clot npc = view_as<Clot>(iNPC);
	
	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime() + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime() + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime())
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
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
				
				PF_SetGoalVector(npc.index, vPredictedPos);
			} else {
				PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
	
			if(npc.m_flNextRangedSpecialAttack < GetGameTime() && flDistanceToTarget < 22500 || npc.m_fbRangedSpecialOn)
			{
		//		npc.FaceTowards(vecTarget, 20000.0);
				if(!npc.m_fbRangedSpecialOn)
				{
					npc.AddGesture("ACT_PUSH_PLAYER");
					npc.m_flRangedSpecialDelay = GetGameTime() + 0.4;
					npc.m_fbRangedSpecialOn = true;
					npc.m_flReloadDelay = GetGameTime() + 1.0;
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				if(npc.m_flRangedSpecialDelay < GetGameTime())
				{
					npc.m_fbRangedSpecialOn = false;
					npc.m_flNextRangedSpecialAttack = GetGameTime() + 5.0;
					npc.PlayRangedAttackSecondarySound();
		
					float vecSpread = 0.1;
					
					npc.FaceTowards(vecTarget, 20000.0);
					
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
							
					//
					//
					
					
					float x, y;
					x = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
					y = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					//GetAngleVectors(eyePitch, vecDirShooting, vecRight, vecUp);
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					//add the spray
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
					FireBullet(npc.index, npc.index, WorldSpaceCenter(npc.index), vecDir, 200.0, 100.0, DMG_SLASH, "bullet_tracer02_blue");
				}
			}
			
			//Target close enough to hit
			if((flDistanceToTarget < 10000 && npc.m_flReloadDelay < GetGameTime()) || npc.m_flAttackHappenswillhappen)
			{
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				if(npc.m_flNextMeleeAttack < GetGameTime())
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime() + 2.0;
						npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime()+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime()+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime() && npc.m_flAttackHappens_bullshit >= GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
							{
								
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									
									SDKHooks_TakeDamage(target, npc.index, npc.index, 150.0, DMG_SLASH);
									
									// Hit particle
									
									
									// Hit sound
									npc.PlayMeleeHitSound();
								} 
							}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.6;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.6;
					}
				}
			}
			if (npc.m_flReloadDelay < GetGameTime())
			{
				PF_StartPathing(npc.index);
				npc.m_bPathing = true;
			}
	}
	else
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			return;
		}
		if(!npc.m_bGetClosestTargetTimeAlly)
		{
			npc.m_iTargetAlly = GetClosestAllyPlayer(npc.index);
			npc.m_bGetClosestTargetTimeAlly = true;
		}
		if(IsValidAllyPlayer(npc.index, npc.m_iTargetAlly))
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(flDistanceToTarget > 90000) //300 units
			{
				PF_SetGoalEntity(npc.index, npc.m_iTargetAlly);	
				PF_StartPathing(npc.index);
				npc.m_bPathing = true;
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);		
				
			}
			else
			{
				PF_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
				
			}
		}
		else
		{
			npc.m_bGetClosestTargetTimeAlly = false;
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index, _ , 1000.0);	
		}
	}
	npc.PlayIdleAlertSound();
}

public Action ClotDamaged_flare(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Clot npc = view_as<Clot>(victim);
	
	if(npc.m_fbRangedSpecialOn)
		damage *= 0.75;
	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + 0.25;
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD");
		npc.PlayHurtSound();
		
	}
	
	npc.m_vecpunchforce(damageForce, true);
	return Plugin_Changed;
}

public void NPCDeath(int entity)
{
	Clot npc = view_as<Clot>(entity);
	npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iBatton))
		RemoveEntity(npc.m_iBatton);
	if(IsValidEntity(npc.m_ihat))
		RemoveEntity(npc.m_ihat);
}

public void NPC_Despawn(int entity)
{
	Clot npc = view_as<Clot>(entity);
	
	
	if(IsValidEntity(npc.m_iBatton))
		RemoveEntity(npc.m_iBatton);
	if(IsValidEntity(npc.m_ihat))
		RemoveEntity(npc.m_ihat);
}

// Ent_Create style position from Doomsday Nuke



public Action Command_PetMenu(int client, int argc)
{
	//What are you.
	if(!(client > 0 && client <= MaxClients && IsClientInGame(client)))
		return Plugin_Handled;
	
	float flPos[3], flAng[3];
	GetClientAbsAngles(client, flAng);
	if(!SetTeleportEndPoint(client, flPos))
	{
		PrintToChat(client, "Could not find place.");
		return Plugin_Handled;
	}
	Clot(client, flPos, flAng, "models/zombie_riot/combine_attachment_police_50.mdl");
	
	return Plugin_Handled;
}

public int SummonMe(float pos[3], float ang[3], char name[64])
{
	strcopy(name, sizeof(name), "Non-Zomibiefied Combine Swordsman");
	return Clot(0, pos, ang, "models/zombie_riot/combine_attachment_police_50.mdl").index;
}






	
	

	
	








