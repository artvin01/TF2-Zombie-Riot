#pragma semicolon 1
#pragma newdecls required
 
static char g_DeathSounds[][] = {
	"npc/strider/striderx_die1.wav",
};

static char g_HurtSounds[][] = {
	"npc/strider/striderx_pain5.wav",
	"npc/strider/striderx_pain7.wav",
	"npc/strider/striderx_pain8.wav",
};

static char g_IdleSounds[][] = {
	"npc/strider/striderx_alert4.wav",
	"npc/strider/striderx_alert6.wav",
};

static char g_IntroSound[][] = {
	"npc/strider/striderx_alert2.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/strider/strider_skewer1.wav",
};
static char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};
static char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static char g_Overheat[][] = {
	"npc/strider/fire.wav",
};

static float fl_DefaultSpeed_Witch = 200.0;

public void XenoMalfuncRobot_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IntroSound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_Overheat);

	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Xeno Malfunctioning Robot");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xenomalf_robot");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_COF;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return XenoMalfuncRobot(vecPos, vecAng, team, data);
}

static float fl_Overheat_CD[MAXENTITIES];
static float fl_Overheat_Timer[MAXENTITIES];
static bool b_Enraged[MAXENTITIES];
static int i_HitAmounts[MAXENTITIES];

methodmap XenoMalfuncRobot < CClotBody
{
	property float f_Overheat_Timer
	{
		public get()							{ return fl_Overheat_Timer[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Overheat_Timer[this.index] = TempValueForProperty; }
	}
	property float f_Overheat_Cooldown
	{
		public get()							{ return fl_Overheat_CD[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Overheat_CD[this.index] = TempValueForProperty; }
	}
	property bool b_Enraged
	{
		public get()							{ return b_Enraged[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Enraged[this.index] = TempValueForProperty; }
	}
	property int i_Hit
	{
		public get()							{ return i_HitAmounts[this.index]; }
		public set(int TempValueForProperty) 	{ i_HitAmounts[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 8.0);
	}
	public void PlayIntro() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IntroSound[GetRandomInt(0, sizeof(g_IntroSound) - 1)], _, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-0.2, 90);
		this.m_flNextIdleSound = GetGameTime(this.index) + 8.0;
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void PlayOverHeatSound() {
		EmitSoundToAll(g_Overheat[GetRandomInt(0, sizeof(g_Overheat) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void ArmorSet(float resistance = -1.0, bool uber = false)
	{
		if(resistance != -1.0 && resistance >= 0.0)
		{
			this.m_flMeleeArmor = resistance;
			this.m_flRangedArmor = resistance;
		}
		b_NpcIsInvulnerable[this.index] = uber;
	}
	
	public XenoMalfuncRobot(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		XenoMalfuncRobot npc = view_as<XenoMalfuncRobot>(CClotBody(vecPos, vecAng, "models/bots/heavy/bot_heavy.mdl", "1.15", "30000", ally, false));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		bool nightmare = StrContains(data, "nightmare") != -1;
		npc.m_fbGunout = nightmare ? true : false;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		int skin = 1;
		npc.m_iWearable2 = npc.EquipItem("head", "models/bots/gameplay_cosmetic/light_heavy_on.mdl", "", 3);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2022_road_block/hwn2022_road_block.mdl", "", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum22_combat_casual/sum22_combat_casual.mdl", "", skin);
		//npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/dec22_heavy_heating_style3/dec22_heavy_heating_style3.mdl", "", skin);//breaks
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2022_horror_shawl_style2/hwn2022_horror_shawl_style2.mdl", "", skin);
		
		SetEntityRenderColor(npc.index, 150, 255, 150, 255);
		SetEntityRenderColor(npc.m_iWearable2, 150, 255, 150, 255);
		SetEntityRenderColor(npc.m_iWearable3, 150, 255, 150, 255);
		SetEntityRenderColor(npc.m_iWearable4, 150, 255, 150, 255);
		SetEntityRenderColor(npc.m_iWearable5, 150, 255, 150, 255);

		func_NPCDeath[npc.index] = XenoMalfuncRobot_NPCDeath;
		func_NPCThink[npc.index] = XenoMalfuncRobot_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		npc.m_flSpeed = fl_DefaultSpeed_Witch;
		npc.Anger = false;
		npc.b_Enraged = false;
		npc.f_Overheat_Cooldown = 0.0;
		npc.f_Overheat_Timer = 0.0;
		npc.i_Hit = 0;

		npc.StartPathing();
		npc.PlayIntro();
		
		return npc;
	}
}

public void XenoMalfuncRobot_ClotThink(int iNPC)
{
	XenoMalfuncRobot npc = view_as<XenoMalfuncRobot>(iNPC);

	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	//bool silence = NpcStats_IsEnemySilenced(npc.index);

	if(!npc.Anger)
	{
		if(npc.i_Hit >= 5)
		{
			npc.Anger = true;
			npc.ArmorSet(npc.m_fbGunout ? 1.08 : 1.25);
			npc.i_Hit = 0;
			npc.f_Overheat_Cooldown = gameTime + 10.0;
			npc.m_flSpeed = npc.m_fbGunout ? fl_DefaultSpeed_Witch * 0.9: fl_DefaultSpeed_Witch * 0.8;
		}
	}
	else
	{
		if(npc.f_Overheat_Cooldown >= gameTime)
		{
			if(npc.f_Overheat_Timer <= gameTime)
			{
				npc.f_Overheat_Timer = gameTime + 0.3;
				float radius = 160.0, damage = 350.0;
				float Loc[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
				Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
				spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 0.1, 8.0, 1.5, 1, radius*2.0);
				spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 0.1, 8.0, 1.5, 1, radius*2.0);
				spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 0.1, 8.0, 1.5, 1, radius*2.0);
				spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", 255, 0, 20, 255, 1, 0.1, 8.0, 1.5, 1, radius*2.0);
				npc.PlayOverHeatSound();
			}
		}
		else
		{
			npc.Anger = false;
			npc.f_Overheat_Cooldown = 0.0;
			npc.f_Overheat_Timer = 0.0;
			npc.m_flSpeed = fl_DefaultSpeed_Witch;
		}
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		
		//Target close enough to hit
		XenoMalfuncRobot_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

static void XenoMalfuncRobot_SelfDefense(XenoMalfuncRobot npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAttackHappens)
	{
		if (npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			Handle swingTrace;
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

			npc.FaceTowards(vecTarget, 20000.0);
			if(npc.DoSwingTrace(swingTrace, target))
			{
				target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(IsValidEnemy(npc.index, target))
				{
					float damage = 100.0;
					if(npc.m_fbGunout)//nightmare
						damage *= 1.4;

					if(target > 0) 
					{
						//SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						float radius = 160.0;
						float vicloc[3];
						WorldSpaceCenter(target, vicloc);
						Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
						ParticleEffectAt(vicloc, "drg_cow_explosioncore_charged_blue", 0.5);
						if(!npc.Anger)
						npc.i_Hit++;
						// Hit sound
						npc.PlayMeleeHitSound();
					}
					else
					{
						npc.PlayMeleeMissSound();
					}
				}
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				bool rng = view_as<bool>(GetRandomInt(0, 1));
				npc.AddGesture(rng ? "ACT_MP_ATTACK_STAND_MELEE_ALLCLASS" : "ACT_MP_ATTACK_STAND_MELEE");
				npc.m_flAttackHappens = gameTime + 0.3;
				float attack = GetRandomFloat(0.6, 1.2);
				npc.m_flNextMeleeAttack = gameTime + attack;
			}
		}
	}
}
/*
static Action XenoMalfuncRobot_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;

	XenoMalfuncRobot npc = view_as<XenoMalfuncRobot>(victim);

	return Plugin_Continue;
}*/

static void XenoMalfuncRobot_NPCDeath(int entity)
{
	XenoMalfuncRobot npc = view_as<XenoMalfuncRobot>(entity);

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

	npc.PlayDeathSound();
}