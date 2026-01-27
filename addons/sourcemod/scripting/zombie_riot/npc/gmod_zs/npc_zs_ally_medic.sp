#pragma semicolon 1
#pragma newdecls required

static const char g_ChargingCompleteSounds[][] = {
	"vo/medic_autochargeready01.mp3",
	"vo/medic_autochargeready02.mp3",
	"vo/medic_autochargeready03.mp3"
};
static const char g_UseUberSounds[][] = {
	"vo/medic_specialcompleted04.mp3",
	"vo/medic_specialcompleted05.mp3",
	"vo/medic_specialcompleted06.mp3"
};

void Allymedic_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medimedes");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_ally_medic");
	strcopy(data.Icon, sizeof(data.Icon), "medic_uber");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally; 
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_DefaultMedic_IdleAlertedSounds);
	PrecacheSoundArray(g_ChargingCompleteSounds);
	PrecacheSoundArray(g_UseUberSounds);
	PrecacheModel("models/player/medic.mdl");
	PrecacheModel(LASERBEAM);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Allymedic(vecPos, vecAng, team);
}

methodmap Allymedic < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DefaultMedic_IdleAlertedSounds[GetRandomInt(0, sizeof(g_DefaultMedic_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public void PlayChargingCompleteSound() {
		EmitSoundToAll(g_ChargingCompleteSounds[GetRandomInt(0, sizeof(g_ChargingCompleteSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayUberSound() {
		EmitSoundToAll(g_UseUberSounds[GetRandomInt(0, sizeof(g_UseUberSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	property float m_flBuildUber
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public Allymedic(float vecPos[3], float vecAng[3], int ally)
	{
		ally = TFTeam_Red;
		Allymedic npc = view_as<Allymedic>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "500", ally, true, false));
		
		i_NpcWeight[npc.index] = 1;
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		

		func_NPCDeath[npc.index] = Allymedic_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Allymedic_OnTakeDamage;
		func_NPCThink[npc.index] = Allymedic_ClotThink;		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flReloadDelay = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		//IDLE
		npc.m_bThisEntityIgnored = true;
		b_NpcIsInvulnerable[npc.index] = true;
		
		npc.m_flSpeed = 400.0;
		npc.m_flBuildUber = 0.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bScalesWithWaves = false;
		
		npc.m_bnew_target = false;
		npc.StartPathing();
		
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_proto_backpack/c_proto_backpack.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_medicmedes/hw2013_medicmedes.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sum23_medical_emergency/sum23_medical_emergency.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 0);
		npc.StartPathing();
		
		if(npc.m_bScalesWithWaves)
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 125);
		}
		
		return npc;
	}
	public void StartHealing()
	{
		if(IsValidEntity(this.m_iWearable4))
			this.Healing = true;
	}	
	public void StopHealing()
	{
		int iBeam = this.m_iWearable4;
		if(IsValidEntity(iBeam))
		{
			AcceptEntityInput(iBeam, "ClearParent");
			RemoveEntity(iBeam);
			
			EmitSoundToAll("weapons/medigun_no_target.wav", this.index, SNDCHAN_WEAPON);
			
			this.Healing = false;
		}
	}
}


static void Allymedic_ClotThink(int iNPC)
{
	Allymedic npc = view_as<Allymedic>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 50000.0;
	}
	npc.m_iTarget = GetAllyEmergency(npc.index);
	
	float vecTarget[3];
	if(IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		if(IsValidAlly(npc.index, npc.m_iTarget))
		{
			int MaxHealth = ReturnEntityMaxHealth(npc.m_iTargetAlly);
			int Health = GetEntProp(npc.m_iTargetAlly, Prop_Data, "m_iHealth");
			if(Health>MaxHealth)
			{
				if(!npc.m_flReloadDelay)
					npc.m_flReloadDelay=gameTime+3.0;
				if(npc.m_flReloadDelay < gameTime)
				{
					npc.m_iTargetAlly=npc.m_iTarget;
					npc.m_flReloadDelay=0.0;
				}
			}
		}
	
		WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(Medic_Work(npc, flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 400.0;
					npc.m_iChanged_WalkCycle = 0;
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTargetAlly);
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.StopPathing();
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 1;
				}
			}
		}
	}
	else
		npc.m_flGetClosestTargetTime=0.0;
	npc.PlayIdleAlertSound();
}

static Action Allymedic_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Allymedic npc = view_as<Allymedic>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Allymedic_NPCDeath(int entity)
{
	Allymedic npc = view_as<Allymedic>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	Is_a_Medic[npc.index] = false;
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	npc.StopHealing();
}

static int Medic_Work(Allymedic npc, float distance)
{
	if(!npc.m_iTargetWalkTo)
		npc.m_iTargetWalkTo = GetClosestAllyPlayerGreg(npc.index);
			
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(npc.m_iTargetWalkTo)
	{
		if (GetTeam(npc.m_iTargetWalkTo)==GetTeam(npc.index) && 
		b_BobsCuringHand_Revived[npc.m_iTargetWalkTo] >= 40 &&
		 TeutonType[npc.m_iTargetWalkTo] == TEUTON_NONE &&
		  dieingstate[npc.m_iTargetWalkTo] > 0 && 
		  !b_LeftForDead[npc.m_iTargetWalkTo])
		{
			WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
			distance = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8)
			{
				if(!npc.m_bnew_target)
				{
					npc.StartHealing();
					npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, npc.m_iTargetAlly, 255, 160, 70, 1.5, 1.5, 0.0, LASERBEAM);
					npc.Healing = true;
					npc.m_bnew_target = true;
				}
				ReviveClientFromOrToEntity(npc.m_iTargetWalkTo, npc.index, 1);
				return 1;
			}
			else
			{
				npc.StopHealing();
				npc.m_bnew_target = false;					
			}
			return 0;
		}
		npc.m_iTargetWalkTo=0;
	}

	if(IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8 && Can_I_See_Ally(npc.index, npc.m_iTargetAlly))
		{
			if(!npc.m_bnew_target)
			{
				npc.StartHealing();
				npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, npc.m_iTargetAlly, 255, 160, 70, 1.5, 1.5, 0.0, LASERBEAM);
				npc.Healing = true;
				npc.m_bnew_target = true;
			}
			int MaxHealth = ReturnEntityMaxHealth(npc.m_iTargetAlly);
			if(b_thisNpcIsABoss[npc.m_iTargetAlly])
				MaxHealth = RoundToCeil(float(MaxHealth) * 0.05);
			float healing_Amount=1.0;
			float Healing_GiveArmor=0.35;
			Healing_GiveArmor *= 1.5;
			if(IsValidClient(npc.m_iTargetAlly))
			{
				if(f_TimeUntillNormalHeal[npc.m_iTargetAlly] - 2.0 > GetGameTime())
					healing_Amount*=0.33;
				if(f_TimeUntillNormalHeal[npc.m_iTargetAlly] > GetGameTime())
					Healing_GiveArmor*=0.33;
				bool JustCuredArmor = false;
				if(Armor_Charge[npc.m_iTargetAlly] < 0)
				{
					JustCuredArmor = true;
					Healing_GiveArmor *= 4.0;
				}
				GiveArmorViaPercentage(npc.m_iTargetAlly, Healing_GiveArmor, 1.0, true,_,npc.index);
				if(JustCuredArmor && Armor_Charge[npc.m_iTargetAlly] > 0)
					Armor_Charge[npc.m_iTargetAlly] = 0;
			}
			else
				GrantEntityArmor(npc.m_iTargetAlly, false, 0.5, 0.7, 0, (float(MaxHealth / 400)));
			HealEntityGlobal(npc.index, npc.m_iTargetAlly, float(MaxHealth / 80)*healing_Amount, 1.5);
			ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Healing Resolve", 1.1);
			ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Healing Adaptiveness All", 1.1);
            ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Weapon Clocking", 1.1);
			ApplyStatusEffect(npc.index, npc.index, "Healing Resolve", 1.1);
			
			npc.FaceTowards(vecTarget, 2000.0);
			
			if(!npc.m_bFUCKYOU)
			{
				MaxHealth = ReturnEntityMaxHealth(npc.m_iTargetAlly);
				int Health = GetEntProp(npc.m_iTargetAlly, Prop_Data, "m_iHealth");
				float Ratio = float(Health)/float(MaxHealth);
				if(npc.m_flBuildUber>180.0)
                {
                    if(npc.m_flBuildUber!=181.0)
                    {
                        npc.PlayChargingCompleteSound();
                        npc.m_flBuildUber=181.0;
                    }
                    if(Ratio<0.5)
                    {
                        npc.PlayUberSound();
                        npc.m_flBuildUber=60.0;
                        npc.m_bFUCKYOU=true;
                    }
                }
                else
                    npc.m_flBuildUber+=(0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
            }
            else
            {
                if(IsValidClient(npc.m_iTargetAlly))
                {
                    TF2_AddCondition(npc.m_iTargetAlly, TFCond_UberBulletResist, 1.1);
                    TF2_AddCondition(npc.m_iTargetAlly, TFCond_UberBlastResist, 1.1);
                    TF2_AddCondition(npc.m_iTargetAlly, TFCond_UberFireResist, 1.1);
                }
                ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "UBERCHARGED", 1.1);
                ApplyStatusEffect(npc.index, npc.index, "UBERCHARGED", 1.1);
                npc.m_flBuildUber-=(1.24 + DEFAULT_UPDATE_DELAY_FLOAT);
                if(npc.m_flBuildUber<0.0)
                {
                    npc.m_flBuildUber=0.0;
                    npc.m_bFUCKYOU=false;
                }
			}
		}
		else
		{
			npc.StopHealing();
			npc.m_bnew_target = false;					
		}
	}
	else 
	{
		npc.StopHealing();
		npc.m_bnew_target = false;		
		return 1;
	}
	return ((!Can_I_See_Ally(npc.index, npc.m_iTarget) || distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7) ? 0 : 1);
}

/*static bool Allymedic_HealCheck(int provider, int entity)
{
	int MaxHealth = ReturnEntityMaxHealth(entity);
	MaxHealth = RoundToNearest(float(MaxHealth) * 1.24);
	int Health = GetEntProp(entity, Prop_Data, "m_iHealth");
	if(MaxHealth <= Health)
		return false;

	return true;
}*/

static int GetAllyEmergency(int entity)
{
	float LowHealth = 0.0; 
	int IsTarget = 0; 
	for(int i = 1; i <= MaxClients; i++) 
	{
		if(IsValidClient(i))
		{
			if(GetTeam(i) == GetTeam(entity))
			{
				int MaxHealth = ReturnEntityMaxHealth(i);
				int Health = GetEntProp(i, Prop_Data, "m_iHealth");
				float Ratio = float(Health)/float(MaxHealth) * 100.0;
				
				if(LowHealth) 
				{
					if(Ratio < LowHealth) 
					{
						IsTarget = i; 
						LowHealth = Ratio;		  
					}
				} 
				else 
				{
					IsTarget = i; 
					LowHealth = Ratio;
				}					
			}
		}
	}
	return IsTarget; 
}