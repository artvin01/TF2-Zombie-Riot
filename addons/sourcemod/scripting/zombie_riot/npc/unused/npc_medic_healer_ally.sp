#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
#include <tf2_stocks>
#include <PathFollower>
#include <PathFollower_Nav>
#include <customkeyvalues>
#include <dhooks>

//#define DESTOYED_ENTITY_EXTRA
//#define DEBUG_ANIMATION
//#define DEBUG_SOUND
#define ISALLY
#include <base/CBaseActor_ZR>

bool Is_a_Medic[2048];
#define LASERBEAM "sprites/laserbeam.vmt"

#pragma newdecls required;



char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
};

char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
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
	RegAdminCmd("sm_medic_main_healer_ally", Command_PetMenu, ADMFLAG_ROOT);
	
	InitGamedata();
}

public void OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }

	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
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
	property bool m_bFUCKYOU
	{
		public get()			{ return !!this.ExtractStringValueAsInt("m_bFUCKYOU"); }
		public set(bool bOnOff) { char buff[8]; IntToString(bOnOff, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_bFUCKYOU", buff, true); }
	}
	property bool m_bFUCKYOU_move_anim
	{
		public get()			{ return !!this.ExtractStringValueAsInt("m_bFUCKYOU_move_anim"); }
		public set(bool bOnOff) { char buff[8]; IntToString(bOnOff, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_bFUCKYOU_move_anim", buff, true); }
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
	property int m_ihat2
	{
		public get()		 
		{ 
			return EntRefToEntIndex(this.ExtractStringValueAsInt("m_ihat2")); 
		}
		public set(int iInt) 
		{
			char buff[32]; 
			IntToString(iInt == INVALID_ENT_REFERENCE ? -1 : EntIndexToEntRef(iInt), buff, sizeof(buff)); 
			SetCustomKeyValue(this.index, "m_ihat2", buff, true); 
		}
	}
	property int m_ilaser
	{
		public get()		 
		{ 
			return EntRefToEntIndex(this.ExtractStringValueAsInt("m_ilaser")); 
		}
		public set(int iInt) 
		{
			char buff[32]; 
			IntToString(iInt == INVALID_ENT_REFERENCE ? -1 : EntIndexToEntRef(iInt), buff, sizeof(buff)); 
			SetCustomKeyValue(this.index, "m_ilaser", buff, true); 
		}
	}
	
	property bool m_bnew_target
	{
		public get()			{ return !!this.ExtractStringValueAsInt("m_bnew_target"); }
		public set(bool bOnOff) { char buff[8]; IntToString(bOnOff, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_bnew_target", buff, true); }
	}
	property int Weapon
	{
		public get()		 
		{ 
			return EntRefToEntIndex(this.ExtractStringValueAsInt("Weapon")); 
		}
		public set(int iInt) 
		{
			char buff[32]; 
			IntToString(iInt == INVALID_ENT_REFERENCE ? -1 : EntIndexToEntRef(iInt), buff, sizeof(buff)); 
			SetCustomKeyValue(this.index, "Weapon", buff, true); 
		}
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 75, _, 1.0);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, 75, _, 1.0);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, 75, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, 75, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, 75, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, 75, _, 1.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	property int BeamEntity
	{
		public get()		 
		{ 
			return EntRefToEntIndex(this.ExtractStringValueAsInt("BeamEntity")); 
		}
		public set(int iInt) 
		{
			char buff[32]; 
			IntToString(iInt == INVALID_ENT_REFERENCE ? -1 : EntIndexToEntRef(iInt), buff, sizeof(buff)); 
			SetCustomKeyValue(this.index, "BeamEntity", buff, true); 
		}
	}
	
	
	
	public Clot(int client, float vecPos[3], float vecAng[3], const char[] model)
	{
		Clot npc = view_as<Clot>(CBaseActor(vecPos, vecAng, model, "1.0", "3500"));
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.CreatePather(16.0, npc.GetMaxJumpHeight(), 1000.0, npc.GetSolidMask(), 100.0, 0.4, 1.75);
		npc.m_flNextTargetTime  = GetGameTime() + GetRandomFloat(1.0, 4.0);
		npc.m_flNextMeleeAttack = 0.0;
		
		
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.BeamEntity = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		
		npc.m_bnew_target = false;
		NPC_StartPathing(npc.index);
		npc.m_bPathing = true;
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.Weapon = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.Weapon, "SetModelScale");
		
		npc.m_ihat2	= npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_ihat2, "SetModelScale");
		
		SetEntProp(npc.Weapon, Prop_Send, "m_nSkin", 1);
		NPC_StartPathing(npc.index);
		npc.m_bPathing = true;
		
		return npc;
	}
	
	
	property bool Healing
	{
		public get()			{ return !!this.ExtractStringValueAsInt("Healing"); }
		public set(bool bOnOff) { char buff[8]; IntToString(bOnOff, buff, sizeof(buff)); SetCustomKeyValue(this.index, "Healing", buff, true); }
	}
	property float NextHealTime
	{
		public get()				 { return this.ExtractStringValueAsFloat("NextHealTime"); }
		public set(float flNextTime) { char buff[8]; FloatToString(flNextTime, buff, sizeof(buff)); SetCustomKeyValue(this.index, "NextHealTime", buff, true); }
	}
	public void StartHealing(int iEnt)
	{
		int iWeapon = this.Weapon;
		if(iWeapon != INVALID_ENT_REFERENCE)
		{
			this.Healing = true;
			
		//	EmitSoundToAll("weapons/medigun_heal.wav", this.index, SNDCHAN_WEAPON);
		}
	}	
	public void StopHealing()
	{
		int iBeam = this.BeamEntity;
		if(iBeam != INVALID_ENT_REFERENCE)
		{
			int iBeamTarget = GetEntPropEnt(iBeam, Prop_Send, "m_hOwnerEntity");
			if(IsValidEntity(iBeamTarget))
			{
				AcceptEntityInput(iBeamTarget, "ClearParent");
				RemoveEntity(iBeamTarget);
			}
			
			AcceptEntityInput(iBeam, "ClearParent");
			RemoveEntity(iBeam);
			
			EmitSoundToAll("weapons/medigun_no_target.wav", this.index, SNDCHAN_WEAPON);
			
		//	StopSound(this.index, SNDCHAN_WEAPON, "weapons/medigun_heal.wav");
			
			this.Healing = false;
		}
	}
}

//TODO 
//Rewrite
public void ClotThink(int iNPC)
{
	Clot npc = view_as<Clot>(iNPC);
	
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
			npc.m_iTarget = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime() + 5000.0;
		}
		
		int PrimaryThreatIndex = npc.m_iTarget;
		if(IsValidAllyNotFullHealth(npc.index, PrimaryThreatIndex))
		{
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
				float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
				float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
				
				if(flDistanceToTarget < 250000)
				{
					if(flDistanceToTarget < 62500)
					{
						NPC_StopPathing(npc.index);
						npc.m_bPathing = false;	
					}
					else
					{
						NPC_StartPathing(npc.index);
						npc.m_bPathing = false;		
					}
					if(!npc.m_bnew_target)
					{
						npc.StartHealing(PrimaryThreatIndex);
						npc.m_ilaser = ConnectWithBeam(npc.Weapon, PrimaryThreatIndex, 250, 100, 100, 3.0, 3.0, 1.35, LASERBEAM);
						npc.Healing = true;
						npc.m_bnew_target = true;
					}
					SetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth", GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth") + 25);
					if(GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth") >= GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iMaxHealth"))
					{
						SetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth", GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iMaxHealth"));
					}
					
					npc.FaceTowards(WorldSpaceCenter(PrimaryThreatIndex), 2000.0);
				}
				else
				{
					if(IsValidEntity(npc.m_ilaser))
						RemoveEntity(npc.m_ilaser);
						
					NPC_StartPathing(npc.index);
					npc.m_bPathing = true;		
					npc.m_bnew_target = false;					
				}
		}
	else
	{
		if(IsValidEntity(npc.m_ilaser))
			RemoveEntity(npc.m_ilaser);
			
		npc.m_bnew_target = false;
		npc.m_iTarget = GetClosestAlly(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
		if(IsValidAllyNotFullHealth(npc.index, npc.m_iTarget))
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
				NPC_SetGoalEntity(npc.index, npc.m_iTargetAlly);	
				NPC_StartPathing(npc.index);
				npc.m_bPathing = true;
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestAlly(npc.index);			
				
			}
			else
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestAlly(npc.index);	
				
			}
		}
		else
		{
			npc.m_bGetClosestTargetTimeAlly = false;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestAlly(npc.index);	
		}
	}
	/*
	else if(npc.m_bFUCKYOU)
	{
		if(npc.m_flGetClosestTargetTime < GetGameTime())
		{
			if(!npc.m_bFUCKYOU_move_anim)
			{
				int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.m_bFUCKYOU_move_anim = true;
			}
			npc.m_flSpeed = 400.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
		}
		
		int PrimaryThreatIndex = npc.m_iTarget;
		
		if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
		{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
				float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
				
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) {
					
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
					
					int color[4];
					color[0] = 255;
					color[1] = 255;
					color[2] = 0;
					color[3] = 255;
				
					int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
				
					TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
					TE_SendToAllInRange(vecTarget, RangeType_Visibility);
					
					NPC_SetGoalVector(npc.index, vPredictedPos);
				} else {
					NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
				}
				
				//Target close enough to hit
				if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
				{
					//Look at target so we hit.
			//		npc.FaceTowards(vecTarget, 1000.0);
					
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime())
					{
						//Play attack ani
						if (!npc.m_flAttackHappenswillhappen)
						{
							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
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
									
									if(target <= MaxClients)
										SDKHooks_TakeDamage(target, npc.index, npc.index, 70.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, 350.0, DMG_CLUB, -1, _, vecHit);
									
									
									
									
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
				else
				{
					NPC_StartPathing(npc.index);
					npc.m_bPathing = true;
				}
		}
		else
		{
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
	*/
	npc.PlayIdleAlertSound();
}

public Action ClotDamaged_flare(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Clot npc = view_as<Clot>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + 0.25;
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		

	}
	npc.m_vecpunchforce(damageForce, true);
	return Plugin_Changed;
}

public void NPCDeath(int entity)
{
	Clot npc = view_as<Clot>(entity);
	npc.PlayDeathSound();
	
	
	Is_a_Medic[npc.index] = false;
	if(IsValidEntity(npc.m_ihat))
		RemoveEntity(npc.m_ihat);
	if(IsValidEntity(npc.m_ihat2))
		RemoveEntity(npc.m_ihat2);
	if(IsValidEntity(npc.Weapon))
		RemoveEntity(npc.Weapon);
	if(IsValidEntity(npc.m_ilaser))
		RemoveEntity(npc.m_ilaser);
	if(IsValidEntity(npc.BeamEntity))
		RemoveEntity(npc.BeamEntity);
	npc.StopHealing();
}

public void NPC_Despawn(int entity)
{
	Clot npc = view_as<Clot>(entity);
	
	Is_a_Medic[npc.index] = false;
	
	if(IsValidEntity(npc.m_ihat))
		RemoveEntity(npc.m_ihat);
	if(IsValidEntity(npc.m_ihat2))
		RemoveEntity(npc.m_ihat2);
	if(IsValidEntity(npc.Weapon))
		RemoveEntity(npc.Weapon);
	if(IsValidEntity(npc.m_ilaser))
		RemoveEntity(npc.m_ilaser);
	if(IsValidEntity(npc.BeamEntity))
		RemoveEntity(npc.BeamEntity);
	npc.StopHealing();
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
	Clot(client, flPos, flAng, "models/player/medic.mdl");
	
	return Plugin_Handled;
}

public int SummonMe(float pos[3], float ang[3], char name[64])
{
	strcopy(name, sizeof(name), "Medic Supporter");
	return Clot(0, pos, ang, "models/player/medic.mdl").index;
}





stock int ConnectWithBeam(int iEnt, int iEnt2, int iRed=255, int iGreen=255, int iBlue=255, float fStartWidth=1.0, float fEndWidth=1.0, float fAmp=1.35, char[] Model = "sprites/laserbeam.vmt"){
	int iBeam = CreateEntityByName("env_beam");
	if(iBeam <= MaxClients)
		return -1;

	if(!IsValidEntity(iBeam))
		return -1;

	SetEntityModel(iBeam, Model);
	char sColor[16];
	Format(sColor, sizeof(sColor), "%d %d %d", iRed, iGreen, iBlue);

	DispatchKeyValue(iBeam, "rendercolor", sColor);
	DispatchKeyValue(iBeam, "life", "0");

	DispatchSpawn(iBeam);

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt));
	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt2), 1);

	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	SetEntPropFloat(iBeam, Prop_Data, "m_fAmplitude", fAmp);

	SetVariantFloat(32.0);
	AcceptEntityInput(iBeam, "Amplitude");
	AcceptEntityInput(iBeam, "TurnOn");
	
	SetVariantInt(0);
	AcceptEntityInput(iBeam, "TouchType");

	SetVariantString("0");
	AcceptEntityInput(iBeam, "damage");
	return iBeam;
}

stock int TF2_CreateParticle(int iEnt, const char[] attachment, const char[] particle)
{
	int b = CreateEntityByName("info_particle_system");
	DispatchKeyValue(b, "effect_name", particle);
	DispatchSpawn(b);
	
	SetVariantString("!activator");
	AcceptEntityInput(b, "SetParent", iEnt);
	
	SetVariantString(attachment);
	AcceptEntityInput(b, "SetParentAttachment", iEnt);
	
	ActivateEntity(b);
	AcceptEntityInput(b, "Start");	
	
	return b;
}


stock int GetClosestAlly(int entity)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 

		int i = MaxClients + 1;
		while ((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
		{
			if (GetEntProp(entity, Prop_Send, "m_iTeamNum")==GetEntProp(i, Prop_Send, "m_iTeamNum") && !Is_a_Medic[i] && GetEntProp(i, Prop_Data, "m_iHealth") < GetEntProp(i, Prop_Data, "m_iMaxHealth"))
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
					
					
				float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						ClosestTarget = i; 
						TargetDistance = distance;		  
					}
				} 
				else 
				{
					ClosestTarget = i; 
					TargetDistance = distance;
				}			
			}
		}
	return ClosestTarget; 
}

stock bool IsValidAllyNotFullHealth(int index, int ally)
{
	if(IsValidEntity(ally))
	{
		static char strClassname[16];
		GetEntityClassname(ally, strClassname, sizeof(strClassname));
		if(StrEqual(strClassname, "zr_base_npc"))
		{
			if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(ally, Prop_Send, "m_iTeamNum") && GetEntProp(ally, Prop_Data, "m_iHealth") > 0 && GetEntProp(ally, Prop_Data, "m_iHealth") < GetEntProp(ally, Prop_Data, "m_iMaxHealth")) 
			{
				return true;
			}
		}
	}
	
	return false;
}
