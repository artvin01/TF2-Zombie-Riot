#pragma semicolon 1
#pragma newdecls required



static char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static const char g_TeleportSounds[][] = {
	"vo/medic_laughshort01.mp3",
	"vo/medic_laughshort02.mp3",
	"vo/medic_laughshort03.mp3",
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
static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

void AltMedicBerseker_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medic Berserker");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_medic_berserker");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "medic_main");
	data.IconCustom = true;
	data.Flags = 0;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AltMedicBerseker(vecPos, vecAng, team);
}

methodmap AltMedicBerseker < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	
	public AltMedicBerseker(float vecPos[3], float vecAng[3], int ally)
	{
		AltMedicBerseker npc = view_as<AltMedicBerseker>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.00", "25000", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = true;
		npc.m_fbRangedSpecialOn = false;
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);	
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


static void Internal_ClotThink(int iNPC)
{
	AltMedicBerseker npc = view_as<AltMedicBerseker>(iNPC);

	float GameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
	
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		if (npc.m_flReloadDelay < GameTime)
		{
			if (npc.m_flmovedelay < GameTime)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_flmovedelay = GameTime + 1.5;
				npc.m_flSpeed = 300.0;					
			}
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			
		}
		
	
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
		if(flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 2000.0);
			
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GameTime)
			{
					//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GameTime+0.1;
					npc.m_flAttackHappens_bullshit = GameTime+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
						
				if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
				{
					float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
					float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
								
						if(target > 0) 
						{
							float damage = 10.0 * (1.0+(1-(Health/MaxHealth))*2);
							if(iRuinaWave()<30)
							{
								damage=damage/2;
							}
							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
																				
							// Hit particle
							
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					float speed = 0.25 * (Health / MaxHealth);
					npc.m_flNextMeleeAttack = GameTime + speed;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
				{
					float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
					float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
					float speed = 0.2 * (Health / MaxHealth);
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GameTime + speed;
				}
			}
		}
		else if(flDistanceToTarget > 22500 && npc.m_flAttackHappens_2 < GameTime)
		{
			float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
			float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
			float crocket = 10.0 * (Health / MaxHealth);
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
			npc.m_flAttackHappens_2 = GameTime + crocket;
			npc.PlayRangedSound();
			npc.FireParticleRocket(vecTarget, 20.0 , 600.0 , 100.0 , "raygun_projectile_blue_crit");
			//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
		}
		else
		{
			npc.StartPathing();
			
		}
		if (npc.m_flReloadDelay < GameTime)
		{
			npc.StartPathing();
			
		}
		if(npc.m_flNextTeleport < GameTime)
		{
			static float flVel[3];
			GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecVelocity", flVel);
			if (flVel[0] >= 200.0)
			{
				float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
				float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
				float time = 60.0 * (0.40 + (Health / MaxHealth));
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
				npc.m_flNextTeleport = GameTime + time;
				float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
				if(Tele_Check > 120.0)
				{
					bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
					if(Succeed)
					{
						npc.PlayTeleportSound();
					}
					else
					{
						npc.m_flNextTeleport = GameTime + 1.0;
					}
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

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	AltMedicBerseker npc = view_as<AltMedicBerseker>(victim);
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

static void Internal_NPCDeath(int entity)
{
	AltMedicBerseker npc = view_as<AltMedicBerseker>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}
