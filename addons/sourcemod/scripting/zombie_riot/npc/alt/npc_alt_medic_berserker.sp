#pragma semicolon 1
#pragma newdecls required

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
static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

void AltMedicBerseker_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
}

methodmap AltMedicBerseker < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	
	
	public AltMedicBerseker(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		AltMedicBerseker npc = view_as<AltMedicBerseker>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.00", "25000", ally));
		
		i_NpcInternalId[npc.index] = ALT_MEDIC_BERSERKER;
		i_NpcWeight[npc.index] = 1;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = true;
		npc.m_fbRangedSpecialOn = false;
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		
		SDKHook(npc.index, SDKHook_Think, AltMedicBerseker_ClotThink);
		
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
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);	
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void AltMedicBerseker_ClotThink(int iNPC)
{
	AltMedicBerseker npc = view_as<AltMedicBerseker>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
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
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			if (npc.m_flmovedelay < GetGameTime(npc.index))
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_flmovedelay = GetGameTime(npc.index) + 1.5;
				npc.m_flSpeed = 300.0;					
			}
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			
		}
		
	
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
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		} else {
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 2000.0);
			
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
					//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.1;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
						
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
					float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
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
							if(ZR_GetWaveCount()<45)
							{
								damage=damage/2;
							}
							if(target <= MaxClients)
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
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + speed;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
					float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
					float speed = 0.2 * (Health / MaxHealth);
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + speed;
				}
			}
		}
		else if(flDistanceToTarget > 22500 && npc.m_flAttackHappens_2 < GetGameTime(npc.index))
		{
			float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
			float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
			float crocket = 10.0 * (Health / MaxHealth);
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
			npc.m_flAttackHappens_2 = GetGameTime(npc.index) + crocket;
			npc.PlayRangedSound();
			npc.FireParticleRocket(vecTarget, 20.0 , 600.0 , 100.0 , "raygun_projectile_blue_crit");
			//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
		}
		else
		{
			npc.StartPathing();
			
		}
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			npc.StartPathing();
			
		}
		if(npc.m_flNextTeleport < GetGameTime(npc.index))
		{
			static float flVel[3];
			GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecVelocity", flVel);
			if (flVel[0] >= 200.0)
			{
				float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
				float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
				float time = 60.0 * (0.40 + (Health / MaxHealth));
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
				npc.m_flNextTeleport = GetGameTime(npc.index) + time;
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
						npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
					}
				}
			}
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action AltMedicBerseker_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

public void AltMedicBerseker_NPCDeath(int entity)
{
	AltMedicBerseker npc = view_as<AltMedicBerseker>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, AltMedicBerseker_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}
