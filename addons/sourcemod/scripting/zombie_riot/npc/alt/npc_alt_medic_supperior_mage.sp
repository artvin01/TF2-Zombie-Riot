#pragma semicolon 1
#pragma newdecls required



static char g_IdleAlertedSounds[][] = {
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
static int gExplosive1;


void NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_DefaultCapperShootSound);
	PrecacheSoundArray(g_DefaultLaserLaunchSound);

	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);

	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	
	PrecacheSound("player/flow.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medic Supperior Mage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_medic_supperior_mage");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_punel"); 	//leaderboard_class_(insert the name)
	data.IconCustom = true;							//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;				//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Npc_Alt_Medic_Supperior_Mage(vecPos, vecAng, team);
}
methodmap Npc_Alt_Medic_Supperior_Mage < CClotBody
{
	
	property float m_flTimebeforekamehameha
	{
		public get()							{ return fl_BEAM_RechargeTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_RechargeTime[this.index] = TempValueForProperty; }
	}
	property float m_flTimeBeforeIOC
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_DefaultCapperShootSound[GetRandomInt(0, sizeof(g_DefaultCapperShootSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);	
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
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public Npc_Alt_Medic_Supperior_Mage(float vecPos[3], float vecAng[3], int ally)
	{
		Npc_Alt_Medic_Supperior_Mage npc = view_as<Npc_Alt_Medic_Supperior_Mage>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.25", "25000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
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
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/C_Crossing_Guard/C_Crossing_Guard.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Hood/Xms2013_Medic_Hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Robe/Xms2013_Medic_Robe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable6, 7, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable5, 7, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);	
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		npc.StartPathing();
		npc.m_flTimeBeforeIOC = GetGameTime(npc.index) + 5.0;
		npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 7.5;
		npc.m_bInKame = false;
		npc.Anger = false;
		
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	Npc_Alt_Medic_Supperior_Mage npc = view_as<Npc_Alt_Medic_Supperior_Mage>(iNPC);

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
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_flmovedelay = GameTime + 1.5;
				npc.m_flSpeed = 300.0;					
			}
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			
		}
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		Body_Pitch(npc, VecSelfNpc, vecTarget);
		
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
		if(flDistanceToTarget < 60000)	//Do laser of hopefully not doom within a 100 hu's, might be too close but who knows.
		{
			if(npc.m_flTimebeforekamehameha < GameTime)
			{
				npc.m_bInKame = true;
				Invoke_SupperiorMageLaser(npc);
				npc.m_flTimebeforekamehameha = GameTime + (npc.Anger ? 45.0 : 60.0);
			}
		}
		if(npc.m_bInKame)
		{
			npc.FaceTowards(vecTarget, 700.0);
			npc.m_flSpeed = 100.0;
			f_NpcTurnPenalty[npc.index] = 0.3;
		}
		else
		{
			npc.m_flSpeed = 300.0;
			f_NpcTurnPenalty[npc.index] = 1.0;
		}
		if(flDistanceToTarget > 60000 && flDistanceToTarget < 120000 && !npc.m_bInKame && npc.m_flTimeBeforeIOC < GameTime)
		{
			Invoke_Supperior_Mage_IOC(EntIndexToEntRef(npc.index), PrimaryThreatIndex);
			npc.m_flTimeBeforeIOC = GameTime + (npc.Anger ? 45.0 : 60.0);
		}
		//Target close enough to hit
		if(flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen && !npc.m_bInKame)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 2000.0);
			
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
							float damage = 45.0 * (1.0+(1-(Health/MaxHealth))*2);
							if(iRuinaWave()<=30)
							{
								damage=damage/1.75;
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
					npc.m_flNextMeleeAttack = GameTime + 0.8;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GameTime + 0.8;
				}
			}
		}
		else if(flDistanceToTarget > 22500 && npc.m_flAttackHappens_2 < GameTime)
		{
			float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
			float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
			float crocket = 25.0 / (1.0+(1-(Health/MaxHealth))*2);
			float dmg = 20.0*(1.0+(1-(Health/MaxHealth))*2);
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
			npc.m_flAttackHappens_2 = GameTime + crocket;
			npc.PlayRangedSound();
			npc.FireParticleRocket(vecTarget, dmg , 600.0 , 100.0 , "raygun_projectile_blue");
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
		
	Npc_Alt_Medic_Supperior_Mage npc = view_as<Npc_Alt_Medic_Supperior_Mage>(victim);
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger)) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}		
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Npc_Alt_Medic_Supperior_Mage npc = view_as<Npc_Alt_Medic_Supperior_Mage>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		
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
}

static void Invoke_SupperiorMageLaser(Npc_Alt_Medic_Supperior_Mage npc)
{
	float GameTime = GetGameTime(npc.index);
	fl_BEAM_DurationTime[npc.index] = GameTime + 10.0;
	fl_BEAM_ChargeUpTime[npc.index] = GameTime + 0.5;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 80, _, 0.25, 75);
	
	npc.PlayLaserLaunchSound();
	SDKUnhook(npc.index, SDKHook_Think, Superrior_Mage_LaserTick);
	SDKHook(npc.index, SDKHook_Think, Superrior_Mage_LaserTick);
}


static Action Superrior_Mage_LaserTick(int client)
{
	Npc_Alt_Medic_Supperior_Mage npc = view_as<Npc_Alt_Medic_Supperior_Mage>(client);
	float GameTime = GetGameTime(npc.index);
	if(!IsValidEntity(client) || fl_BEAM_DurationTime[npc.index] < GameTime)
	{
		SDKUnhook(client, SDKHook_Think, Superrior_Mage_LaserTick);

		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);

		npc.m_bInKame = false;

		return Plugin_Stop;
	}

	if(fl_BEAM_ChargeUpTime[npc.index] > GetGameTime(npc.index))
		return Plugin_Continue;

	Basic_NPC_Laser Data;
	Data.npc = npc;
	Data.Radius = 10.0;
	Data.Range = (npc.Anger ? 750.0 : 500.0);
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = (npc.Anger ? 30.0 : 20.0) / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Long_Dps = (npc.Anger ? 17.5: 10.0) / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Color = (npc.Anger ? {255, 255, 255, 60} : {5, 9, 250, 30});
	Data.DoEffects = true;
	GetAttachment(npc.index, "effect_hand_l", Data.EffectsStartLoc, NULL_VECTOR);
	Basic_NPC_Laser_Logic(Data);

	return Plugin_Continue;
}
static void Invoke_Supperior_Mage_IOC(int ref, int enemy)
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
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_IonAttack(data);
	}
}
static void Body_Pitch(CClotBody npc, float VecSelfNpc[3], float vecTarget[3])
{
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;		

	//Body pitch
	float v[3], ang[3];
	SubtractVectors(VecSelfNpc, vecTarget, v); 
	NormalizeVector(v, v);
	GetVectorAngles(v, ang); 
							
	float flPitch = npc.GetPoseParameter(iPitch);
							
	npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
}

public Action NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIon(Handle Timer, any data)
{
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, g_Ruina_Glow_Blue, 1.0, 1.0, 255);
	TE_SendToAll();
}

public void NPC_ALT_MEDIC_SUPPERIOR_MAGE_IonAttack(Handle &data)
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
	spawnRing_Vectors(startPosition, Ionrange * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 175, 55, 255, 1, 0.2, 12.0, 4.0, 3);	
	
	if (Iondistance > 0)
	{
		EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
		
		// Stage 1
		float s=Sine(nphi/360*6.28)*Iondistance;
		float c=Cosine(nphi/360*6.28)*Iondistance;
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] = startPosition[2];
		
		position[0] += s;
		position[1] += c;
	//	NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});

		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
		
		// Stage 2
		s=Sine((nphi+45.0)/360*6.28)*Iondistance;
		c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
	//	NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
		
		// Stage 3
		s=Sine((nphi+90.0)/360*6.28)*Iondistance;
		c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
	//	NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
		
		// Stage 3
		s=Sine((nphi+135.0)/360*6.28)*Iondistance;
		c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
	//	NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});

		if (nphi >= 360)
			nphi = 0.0;
		else
			nphi += 5.0;
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
	
	if (Iondistance > -30)
		CreateTimer(0.1, NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
	else
	{	
		if(b_Anger[client])
			makeexplosion(client, startPosition, RoundToCeil(150.0), 225);
		else
			makeexplosion(client, startPosition, RoundToCeil(75.0), 150);
			
		TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
		spawnRing_Vectors(startPosition, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 175, 55, 255, 1, 0.5, 20.0, 10.0, 3, Ionrange * 2.0);	
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] += startPosition[2] + 900.0;
		startPosition[2] += -200;
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {212, 175, 55, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {212, 175, 55, 200}, 3);
		TE_SendToAll();
	//	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {212, 175, 55, 120}, 3);
	//	TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {212, 175, 55, 75}, 3);
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