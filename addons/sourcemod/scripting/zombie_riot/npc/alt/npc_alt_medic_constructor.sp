#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/medic_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/medic_mvm_painsharp01.mp3",
	"vo/mvm/norm/medic_mvm_painsharp02.mp3",
	"vo/mvm/norm/medic_mvm_painsharp03.mp3",
	"vo/mvm/norm/medic_mvm_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/medic_mvm_battlecry01.mp3",
	"vo/mvm/norm/medic_mvm_battlecry02.mp3",
	"vo/mvm/norm/medic_mvm_battlecry03.mp3",
	"vo/mvm/norm/medic_mvm_battlecry04.mp3",
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

void Alt_Medic_Constructor_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheModel("models/bots/medic/bot_medic.mdl");
	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medic Constructor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_medic_healer_3");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "medic"); 		//leaderboard_class_(insert the name)
	data.IconCustom = false;													//download needed?
	data.Flags = 0;								//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Alt_Medic_Constructor(vecPos, vecAng, team);
}

methodmap Alt_Medic_Constructor < CClotBody
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
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	public Alt_Medic_Constructor(float vecPos[3], float vecAng[3], int ally)
	{
		Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.0", "3500", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		
		npc.m_bnew_target = false;
		npc.StartPathing();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable6	= npc.EquipItem("head", "models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		npc.StartPathing();
		
		SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
			
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


static void Internal_ClotThink(int iNPC)
{
	Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(iNPC);

	float GameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(!npc.m_bFUCKYOU)
	{
		if(npc.m_flGetClosestTargetTime < GameTime)
		{
			npc.m_iTarget = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = GameTime + 5000.0;
		}
		
		int PrimaryThreatIndex = npc.m_iTarget;
		if(IsValidAlly(npc.index, PrimaryThreatIndex))
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
			if(flDistanceToTarget < 250000 && Can_I_See_Enemy_Only(npc.index, PrimaryThreatIndex))
			{
				if(flDistanceToTarget < 62500)
				{
					npc.StopPathing();
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
				
				int MaxHealth = ReturnEntityMaxHealth(PrimaryThreatIndex);
				if(b_thisNpcIsABoss[PrimaryThreatIndex])
					MaxHealth = RoundToCeil(float(MaxHealth) * 0.05);

				HealEntityGlobal(npc.index, PrimaryThreatIndex, float(MaxHealth / 70), 1.0);
				
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
				
			npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
			
			SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
		
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
				
			npc.StopPathing();
			
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
		if(npc.m_flGetClosestTargetTime < GameTime)
		{
			if(!npc.m_bFUCKYOU_move_anim)
			{
				int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.m_bFUCKYOU_move_anim = true;
			}
			npc.m_flSpeed = 400.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
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
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
		//		npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime+0.4;
						npc.m_flAttackHappens_bullshit = GameTime+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
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
									SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 400.0, DMG_CLUB, -1, _, vecHit);
								
								
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + 0.6;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.6;
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
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(entity);
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
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	npc.StopHealing();
}