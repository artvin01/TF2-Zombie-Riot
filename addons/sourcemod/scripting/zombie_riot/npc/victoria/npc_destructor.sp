#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav"
};

static const char g_ExplosionSounds[] = "weapons/explode1.wav";

void VictoriaDestructor_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Destructor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_destructor");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_destructor");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_ExplosionSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VictoriaDestructor(vecPos, vecAng, team);
}

methodmap VictoriaDestructor < CSeaBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayExplosionSound() 
	{
		EmitSoundToAll(g_ExplosionSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80,125));
	}
	
	public VictoriaDestructor(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaDestructor npc = view_as<VictoriaDestructor>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.3", "4000", ally, false, .isGiant = true));

		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_3");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = VictoriaDestructor_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaDestructor_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaDestructor_ClotThink;
		
		KillFeed_SetKillIcon(npc.index, "firedeath");
		npc.m_flSpeed = 225.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", FAR_FUTURE);	
		
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/C_Crossing_Guard/C_Crossing_Guard.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_physician_mask/robo_medic_physician_mask.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/thief_soldier_helmet/thief_soldier_helmet.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/sbox2014_juggernaut_jacket/sbox2014_juggernaut_jacket.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_flMeleeArmor = 1.25;
		npc.m_flRangedArmor = 0.5;
		return npc;
	}
}

static void VictoriaDestructor_ClotThink(int iNPC)
{
	VictoriaDestructor npc = view_as<VictoriaDestructor>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float distance = GetVectorDistance(vecTarget, vecMe, true);		
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		npc.StartPathing();

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_flNextMeleeAttack = gameTime + 3.0;

			float radius = 250.0;
			if(NpcStats_VictorianCallToArms(npc.index))
				radius *= 1.5;

			npc.PlayExplosionSound();
			spawnRing_Vectors(vecMe, radius, 0.0, 0.0, 50.0, "materials/sprites/laserbeam.vmt", 100, 150, 255, 175, 1, 0.5, 6.0, 0.1, 1, 640.0);
			Explode_Logic_Custom(25.0, -1, npc.index, -1, vecMe, radius, _, 0.75, true, _, false, _, VictoriaDestructor_ExplodePost);
		}
	}
	else
	{
		npc.StopPathing();
		npc.m_flGetClosestTargetTime=0.0;
	}
	npc.PlayIdleSound();
}

static void VictoriaDestructor_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	NPC_Ignite(victim, attacker,8.0, -1, 5.5);
}

static Action VictoriaDestructor_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	VictoriaDestructor npc = view_as<VictoriaDestructor>(victim);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void VictoriaDestructor_NPCDeath(int entity)
{
	VictoriaDestructor npc = view_as<VictoriaDestructor>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}
