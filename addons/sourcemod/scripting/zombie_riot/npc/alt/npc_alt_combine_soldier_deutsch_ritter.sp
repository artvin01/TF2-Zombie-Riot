#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static const char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};


static const char g_RangedAttackSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static int i_barrage[MAXENTITIES];
static float fl_barragetimer[MAXENTITIES];
static float fl_singularbarrage[MAXENTITIES];
static bool b_barrage[MAXENTITIES];

void Alt_CombineDeutsch_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Holy Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_combine_soldier_deutsch_ritter");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "teutons"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = 0;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Alt_CombineDeutsch(vecPos, vecAng, team);
}

methodmap Alt_CombineDeutsch < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	
	public Alt_CombineDeutsch(float vecPos[3], float vecAng[3], int ally)
	{
		Alt_CombineDeutsch npc = view_as<Alt_CombineDeutsch>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "90000", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		i_NpcWeight[npc.index] = 2;
		
		int iActivity = npc.LookupActivity("ACT_TEUTON_NEW_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);	
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		SetEntityRenderColor(npc.index, 150, 175, 255, 255);

		npc.m_iState = 0;
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_soldier.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/dec17_brass_bucket/dec17_brass_bucket.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		
		SetEntityRenderColor(npc.m_iWearable2, 100, 150, 255, 255);
		SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
		SetEntityRenderColor(npc.m_iWearable1, 100, 150, 255, 255);
		SetEntityRenderColor(npc.m_iWearable4, 50, 125, 150, 255);
		
		npc.StartPathing();
		
		i_barrage[npc.index] = 0;
		fl_barragetimer[npc.index] = GetGameTime(npc.index) + GetRandomFloat(5.0, 10.0);
		fl_singularbarrage[npc.index] = GetGameTime(npc.index) + 1.0;
		b_barrage[npc.index] = false;
		return npc;
	}
	
	
}


static void Internal_ClotThink(int iNPC)
{
	Alt_CombineDeutsch npc = view_as<Alt_CombineDeutsch>(iNPC);
	
//	SetVariantInt(1);
//	AcceptEntityInput(iNPC, "SetBodyGroup");
	
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

	float TrueArmor = 1.0;
	if(npc.m_fbRangedSpecialOn)
		TrueArmor *= 0.75;
	
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
			
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
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
		
		if(fl_barragetimer[npc.index] <= GetGameTime(npc.index) && fl_singularbarrage[npc.index] <= GetGameTime(npc.index))
		{	
			SetEntityRenderMode(npc.m_iWearable3, RENDER_NONE);
			SetEntityRenderColor(npc.m_iWearable3, 1, 1, 1, 1);
			
			float  dmg=40.0;
			if(iRuinaWave()<20)
			{
				dmg=20.0;
			}
			i_barrage[npc.index]++;
			
			float Angles[3], distance = 100.0, UserLoc[3];
			
			
			GetAbsOrigin(npc.index, UserLoc);
			
			MakeVectorFromPoints(UserLoc, vecTarget, Angles);
			GetVectorAngles(Angles, Angles);
			
			float type;
			
			if(flDistanceToTarget < 62500)	//Target is close, we do wide attack
			{
				Angles[1]-=22.5;
				type = 9.0;
			}
			else	//Target is far, we do long range attack.
			{
				Angles[1]-=10.0;
				type = 4.0;
			}
			
			for(int alpha=1 ; alpha<=5 ; alpha++)	//Shoot 5 rockets dependant on the stuff above this
			{
						
				float tempAngles[3], endLoc[3], Direction[3];
				tempAngles[0] = -32.5;
				tempAngles[1] = Angles[1] + type * alpha;
				tempAngles[2] = 0.0;
						
				GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(Direction, distance);
				AddVectors(UserLoc, Direction, endLoc);
						
				npc.FireParticleRocket(endLoc, dmg , 450.0 , 100.0 , "raygun_projectile_blue");
				//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
	
			}
			npc.PlayRangedSound();
			npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
			fl_singularbarrage[npc.index] = GetGameTime(npc.index) + 0.1;
			b_barrage[npc.index] = true;
			if (i_barrage[npc.index] >= 1)	//Stays here incase you want this multi shoot to act like a barrage
			{
				SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
				i_barrage[npc.index] = 0;
				fl_barragetimer[npc.index] = GetGameTime(npc.index) + 60.0;
				b_barrage[npc.index] = false;
			}
		}
		//Target close enough to hit
		if((flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) && !b_barrage[npc.index])
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
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
								float damage=150.0;
								if(iRuinaWave()<20)
								{
									damage=75.0;
								}
								if(ShouldNpcDealBonusDamage(target))
								{
									damage *= 3.3;
								}
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
								// Hit particle
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
							} 
						}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.9;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.9;
				}
			}
		}
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
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
		
	Alt_CombineDeutsch npc = view_as<Alt_CombineDeutsch>(victim);

	
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
	Alt_CombineDeutsch npc = view_as<Alt_CombineDeutsch>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
		
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}