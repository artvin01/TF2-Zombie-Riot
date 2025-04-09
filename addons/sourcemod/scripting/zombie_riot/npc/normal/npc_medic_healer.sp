#pragma semicolon 1
#pragma newdecls required

#define LASERBEAM "sprites/laserbeam.vmt"

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void MedicHealer_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel("models/player/medic.mdl");
	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medic Supporter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_medic_healer");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return MedicHealer(vecPos, vecAng, team);
}

methodmap MedicHealer < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	public MedicHealer(float vecPos[3], float vecAng[3], int ally)
	{
		MedicHealer npc = view_as<MedicHealer>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "3500", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		

		func_NPCDeath[npc.index] = MedicHealer_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = MedicHealer_OnTakeDamage;
		func_NPCThink[npc.index] = MedicHealer_ClotThink;		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		

		
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		
		npc.m_bnew_target = false;
		npc.StartPathing();
		
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		npc.StartPathing();
		
		
		return npc;
	}
	public void StartHealing()
	{
		int im_iWearable3 = this.m_iWearable3;
		if(im_iWearable3 != INVALID_ENT_REFERENCE)
		{
			this.Healing = true;
			
		//	EmitSoundToAll("m_iWearable3s/medigun_heal.wav", this.index, SNDCHAN_m_iWearable3);
		}
	}	
	public void StopHealing()
	{
		int iBeam = this.m_iWearable5;
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
			
		//	StopSound(this.index, SNDCHAN_m_iWearable3, "m_iWearable3s/medigun_heal.wav");
			
			this.Healing = false;
		}
	}
}


public void MedicHealer_ClotThink(int iNPC)
{
	MedicHealer npc = view_as<MedicHealer>(iNPC);
	
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
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(!npc.m_bFUCKYOU)
	{
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 5000.0;
		}
		
		int PrimaryThreatIndex = npc.m_iTarget;
		if(IsValidAlly(npc.index, PrimaryThreatIndex))
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			if(flDistanceToTarget < 250000)
			{
				if(flDistanceToTarget < 62500)
				{
					NPC_StopPathing(npc.index);
				}
				else
				{
					npc.StartPathing();	
				}
				if(!npc.m_bnew_target)
				{
					npc.StartHealing();
					npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, PrimaryThreatIndex, 100, 100, 250, 3.0, 3.0, 1.35, LASERBEAM);
					npc.Healing = true;
					npc.m_bnew_target = true;
				}

				if(!NpcStats_IsEnemySilenced(npc.index))
				{
					if(IsValidEntity(npc.m_iWearable4))
					{
						SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
						SetEntityRenderColor(npc.m_iWearable4, 100, 100, 250, 255);
					}
					HealEntityGlobal(npc.index, PrimaryThreatIndex, 50.0, 1.0);
				}
				else
				{
					if(IsValidEntity(npc.m_iWearable4))
					{
						SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
						SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 255);
					}
				}
				float WorldSpaceVec[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 2000.0);
			}
			else
			{
				if(IsValidEntity(npc.m_iWearable4))
					RemoveEntity(npc.m_iWearable4);
					
				npc.StartPathing();

				npc.m_bnew_target = false;					
			}
		}
		else
		{
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
				
			npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
			
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable2, 255, 255, 0, 255);
		
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
				
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.StopHealing();
			npc.Healing = false;
			npc.m_bnew_target = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_bFUCKYOU = true;
			npc.m_iTarget = GetClosestAlly(npc.index);
		}
	}
	else if(npc.m_bFUCKYOU)
	{
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			if(!npc.m_bFUCKYOU_move_anim)
			{
				int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.m_bFUCKYOU_move_anim = true;
			}
			npc.m_flSpeed = 400.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
		
		int PrimaryThreatIndex = npc.m_iTarget;
		
		if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
		{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
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
			
			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
		//		npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
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
								
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 70.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 350.0, DMG_CLUB, -1, _, vecHit);
								
								
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
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
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
	npc.PlayIdleAlertSound();
}

public Action MedicHealer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	MedicHealer npc = view_as<MedicHealer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void MedicHealer_NPCDeath(int entity)
{
	MedicHealer npc = view_as<MedicHealer>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Is_a_Medic[npc.index] = false;
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	npc.StopHealing();
}