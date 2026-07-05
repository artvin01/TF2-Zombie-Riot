#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"vo/mvm/norm/medic_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/medic_mvm_painsharp01.mp3",
	"vo/mvm/norm/medic_mvm_painsharp02.mp3",
	"vo/mvm/norm/medic_mvm_painsharp03.mp3",
	"vo/mvm/norm/medic_mvm_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/medic_mvm_battlecry01.mp3",
	"vo/mvm/norm/medic_mvm_battlecry02.mp3",
	"vo/mvm/norm/medic_mvm_battlecry03.mp3",
	"vo/mvm/norm/medic_mvm_battlecry04.mp3"
};

void ArmoredMedic_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Giant Armored Medibot");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_giant_armored_medic");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_hardener");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Expidonsa; 
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheModel("models/bots/medic/bot_medic.mdl");
	PrecacheModel(LASERBEAM);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ArmoredMedic(vecPos, vecAng, team);
}

methodmap ArmoredMedic < CClotBody
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

	public ArmoredMedic(float vecPos[3], float vecAng[3], int ally)
	{
		ArmoredMedic npc = view_as<ArmoredMedic>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.35", "150000", ally, .isGiant = true));
		
		i_NpcWeight[npc.index] = 3;
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		

		func_NPCDeath[npc.index] = ArmoredMedic_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ArmoredMedic_OnTakeDamage;
		func_NPCThink[npc.index] = ArmoredMedic_ClotThink;		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iNpcStepVariation = 0;
		
		npc.m_flRangedArmor = 0.8;
		npc.m_flMeleeArmor = 0.7;	
		
		
		//IDLE
		npc.m_flSpeed = 150.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		
		npc.m_bnew_target = false;
		npc.StartPathing();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/engineer/spr18_cold_case/spr18_cold_case.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_physician_mask/robo_medic_physician_mask.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable6	= npc.EquipItem("head", "models/workshop/player/items/demo/sum20_hazard_headgear/sum20_hazard_headgear.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		npc.m_iWearable7	= npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2020_wavefinder/hwn2020_wavefinder.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);

		NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 15132390);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable6, 15132390);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable7, 15132390);
		npc.StartPathing();
		
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


static void ArmoredMedic_ClotThink(int iNPC)
{
	ArmoredMedic npc = view_as<ArmoredMedic>(iNPC);
	
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

	if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
	{
		//there is no more valid ally, suicide.
		SmiteNpcToDeath(npc.index);
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		int OldAlly = npc.m_iTargetAlly;
		npc.m_iTargetAlly = GetClosestAlly(npc.index,_,_,ArmoredMedic_HealCheck);
		if(!IsValidAlly(npc.index, npc.m_iTargetAlly))
			npc.m_iTargetAlly = GetClosestAlly(npc.index);

		if(OldAlly != npc.m_iTargetAlly)
		{
			npc.m_bnew_target = false;
			npc.StopHealing();
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
		}

		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	if(IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		npc.SetGoalEntity(npc.m_iTargetAlly);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(!Can_I_See_Ally(npc.index, npc.m_iTargetAlly) || flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7)
			npc.StartPathing();
		else
			npc.StopPathing();
		
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8 && !npc.m_bnew_target && Can_I_See_Ally(npc.index, npc.m_iTargetAlly))
		{
			npc.StartHealing();
			npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, npc.m_iTargetAlly, 255, 215, 0, 3.0, 3.0, 1.35, LASERBEAM);
			npc.Healing = true;
			npc.m_bnew_target = true;
		}
		if(npc.Healing && npc.m_bnew_target)
		{
			int MaxHealth = ReturnEntityMaxHealth(npc.m_iTargetAlly);
			HealEntityGlobal(npc.index, npc.m_iTargetAlly, (float(MaxHealth)*(b_thisNpcIsABoss[npc.m_iTargetAlly] ? 0.00001 : 1.0)), 1.0);
			ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Buffweiser", 1.1);
			if(NpcStats_VestanCallToArms(npc.index))
				ApplyStatusEffect(npc.index, npc.m_iTargetAlly, "Taurine", 1.1);				
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTargetAlly, WorldSpaceVec);
			
			npc.FaceTowards(WorldSpaceVec, 2000.0);
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StopHealing();
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
		npc.m_bnew_target = false;	
	}
	npc.PlayIdleAlertSound();
}

static Action ArmoredMedic_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ArmoredMedic npc = view_as<ArmoredMedic>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ArmoredMedic_NPCDeath(int entity)
{
	ArmoredMedic npc = view_as<ArmoredMedic>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
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

static bool ArmoredMedic_HealCheck(int provider, int entity)
{
	int MaxHealth = ReturnEntityMaxHealth(entity);
	MaxHealth = RoundToNearest(float(MaxHealth) * 1.49);
	int Health = GetEntProp(entity, Prop_Data, "m_iHealth");
	if(MaxHealth <= Health)
		return false;

	return true;
}