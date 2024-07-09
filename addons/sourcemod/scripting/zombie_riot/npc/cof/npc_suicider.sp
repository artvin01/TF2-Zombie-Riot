#pragma semicolon 1
#pragma newdecls required
 
static char g_DeathSounds[][] = {
	"cof/suicider/slower_death1.mp3",
};

static char g_HurtSounds[][] = {
	"cof/suicider/slower_pain1.mp3",
	"cof/suicider/slower_pain2.mp3",
};

static char g_IdleSounds[][] = {
	"cof/suicider/slower_alert1.mp3",
	"cof/suicider/slower_alert2.mp3",
	"cof/suicider/slower_alert3.mp3",
};

static char g_IntroSound[][] = {
	"cof/suicider/slower_alert1.mp3",
};

static float fl_DefaultSpeed_Suicider = 100.0;
static float fl_DefaultSpeed_Suicider_Nightmare = 150.0;
static bool b_IsNightmare[MAXENTITIES];

#define COF_SUICIDER_MODEL_PATH "models/zombie_riot/cof/suicider.mdl"


void Suicider_OnMapStart_NPC()
{
	PrecacheModel(COF_SUICIDER_MODEL_PATH);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Suicider");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_suicider");
	strcopy(data.Icon, sizeof(data.Icon), "suicider");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_COF;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	PrecacheModel("models/zombie_riot/cof/booksimon.mdl");
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSoundCustom(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSoundCustom(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSoundCustom(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IntroSound));		i++) { PrecacheSoundCustom(g_IntroSound[i]);		}
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Suicider(client, vecPos, vecAng, ally, data);
}

methodmap Suicider < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitCustomToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayIntro() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitCustomToAll(g_IntroSound[GetRandomInt(0, sizeof(g_IntroSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitCustomToAll("cof/purnell/shoot.mp3", this.index);
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
	property int m_iKillMe
	{
		public get()		{ return this.m_iMedkitAnnoyance; }
		public set(int value) 	{ this.m_iMedkitAnnoyance = value; }
	}
	property bool b_Nightmare
	{
		public get()		{ return b_IsNightmare[this.index]; }
		public set(bool value) 	{ b_IsNightmare[this.index] = value; }
	}
	
	public Suicider(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Suicider npc = view_as<Suicider>(CClotBody(vecPos, vecAng, COF_SUICIDER_MODEL_PATH, "1.0", "400", ally, false));
		
		i_NpcWeight[npc.index] = 5;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.PlayIntro();

		npc.b_Nightmare = false;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iKillMe = 0;
		npc.Anger = false;

		bool nightmare = StrContains(data, "nightmare") != -1;
		if(nightmare)
		{
			npc.b_Nightmare = true;
			npc.m_flSpeed = fl_DefaultSpeed_Suicider_Nightmare;
			npc.m_iAttacksTillReload = 14;
		}
		else
		{
			npc.m_flSpeed = fl_DefaultSpeed_Suicider;
			npc.m_iAttacksTillReload = 9;
		}
		npc.m_flNextRangedSpecialAttack = 0.0;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flAttackHappenswillhappen = false;

		//int skin = 1;
		//npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl", "", skin);
		
		func_NPCDeath[npc.index] = Suicider_NPCDeath;
		func_NPCThink[npc.index] = Suicider_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Suicider_OnTakeDamage;

		//IDLE
		npc.StartPathing();
		
		return npc;
	}
}

public void Suicider_ClotThink(int iNPC)
{
	Suicider npc = view_as<Suicider>(iNPC);

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
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iKillMe)
	{
		switch(npc.m_iKillMe)
		{
			case 1:
			{
				npc.ArmorSet(0.0);
				npc.m_iKillMe++;
				npc.Anger = true;
				int iActivity = npc.LookupActivity("ACT_DIE_GUTSHOT");
				if(iActivity > 0) npc.StartActivity(iActivity);
			}
			case 5:
			{
				npc.m_iKillMe = 0;
				npc.ArmorSet(1.0);
				Suicider_Suicide(npc, "ACT_DIE_HEADSHOT");
			}
			default:
			{
				npc.m_iKillMe++;
			}
		}
		return;
	}

	if(npc.Anger)
	{
		return;
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		/*if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else*/
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		
		Suicider_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

static void Suicider_SelfDefense(Suicider npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.Anger)
	{
		return;
	}

	if(npc.m_flNextRangedSpecialAttack)
	{
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			if(npc.m_iAttacksTillReload > 0)
			{
				npc.m_flNextRangedSpecialAttack = 0.0;
				
				if(npc.m_iTarget > 0)
				{	
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					npc.FaceTowards(vecTarget, 15000.0);
					float pos[3], ang[3];
					npc.GetAttachment("1", pos, ang);
					//npc.m_iAttacksTillReload--;

					npc.AddGesture("ACT_SHOOT");
					float predict = 700.0, damage = 80.0;
					if(npc.b_Nightmare)
					{
						predict = 900.0;
						damage = 120.0;
					}
					PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, npc.b_Nightmare ? predict - 150.0 : predict - 250.0, _, vecTarget);
					npc.FireRocket(vecTarget, damage, predict, "models/weapons/w_bullet.mdl", 2.0);
					
					npc.PlayRangedSound();
				}
			}
			else
			{
				npc.m_iKillMe = 1;
			}
		}
		return;
	}
	float multi = npc.b_Nightmare ? 0.65 : 0.85;

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * multi))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iKillMe = 1;
				return;
			}
		}
		else
		{
			if(npc.m_flNextRangedAttack < gameTime)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.85;
				npc.m_flSpeed = npc.b_Nightmare ? fl_DefaultSpeed_Suicider_Nightmare: fl_DefaultSpeed_Suicider;
				NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
				if(!npc.m_bPathing)
					npc.StartPathing();
			}
		}
	}
	if(gameTime > npc.m_flNextRangedAttack)
	{
		float maxdist = 10.0;
		if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * multi) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * maxdist))
		{
			int Enemy_I_See;			
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				
				npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
				float attackspeed = npc.b_Nightmare ? 0.45 : 0.85;
				npc.m_flNextRangedAttack = gameTime + attackspeed;
				
				npc.m_flSpeed = 0.0;
			
				if(npc.m_bPathing)
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
		}
	}
}

static Action Suicider_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;

	Suicider npc = view_as<Suicider>(victim);

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index) && !npc.Anger)
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Continue;
}

static void Suicider_NPCDeath(int entity)
{
	Suicider npc = view_as<Suicider>(entity);

	npc.PlayDeathSound();

	if(!npc.m_flAttackHappenswillhappen)
	{
		float Pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Pos);
		Suicider_AfterEffect(Pos, Angles);
	}
}

static void Suicider_Suicide(Suicider npc, char anim[255])
{
	if(npc.m_flAttackHappenswillhappen)
	{
		return;
	}
	npc.m_flAttackHappenswillhappen = true;

	float Pos[3];
	float Angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Pos); 
	Suicider_AfterEffect(Pos, Angles, anim);
	Pos[2] += 45.0;
	DataPack pack_boom = new DataPack();
	pack_boom.WriteFloat(Pos[0]);
	pack_boom.WriteFloat(Pos[1]);
	pack_boom.WriteFloat(Pos[2]);
	pack_boom.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack_boom);

	SmiteNpcToDeath(npc.index);
}

static void Suicider_AfterEffect(float pos[3], float Angles[3], char anim[255] = "ACT_DIESIMPLE")
{
	int prop = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(prop))
	{
		TeleportEntity(prop, pos, Angles, NULL_VECTOR);
		
		DispatchKeyValue(prop, "model", COF_SUICIDER_MODEL_PATH);

		DispatchSpawn(prop);
		
		SetEntPropFloat(prop, Prop_Send, "m_flModelScale", 1.0); 
		SetEntityCollisionGroup(prop, 2);
		SetVariantString(anim);
		AcceptEntityInput(prop, "SetAnimation");
		
		//pos[2] += 20.0;
		
		//CreateTimer(2.25, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(2.0, Timer_RemoveEntitySawrunner, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}
}