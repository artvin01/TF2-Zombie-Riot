#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3",
};


void ApertureMinigunnerPerfected_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSound("weapons/tomislav_shoot.wav");
	PrecacheSound("weapons/gatling_spin.wav");
	PrecacheSound("weapons/gatling_shoot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Perfected Aperture Minigunner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_minigunner_perfected");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);

}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ApertureMinigunnerPerfected(vecPos, vecAng, team);
}

methodmap ApertureMinigunnerPerfected < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayMinigunSound(bool Shooting) 
	{
		if(Shooting)
		{
			if(this.i_GunMode != 0)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/gatling_spin.wav");
				EmitSoundToAll("weapons/gatling_shoot.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/gatling_shoot.wav");
				EmitSoundToAll("weapons/gatling_spin.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 1;
		}
	}

	public ApertureMinigunnerPerfected(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureMinigunnerPerfected npc = view_as<ApertureMinigunnerPerfected>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "10000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_DEPLOYED_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		func_NPCDeath[npc.index] = ApertureMinigunnerPerfected_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ApertureMinigunnerPerfected_OnTakeDamage;
		func_NPCThink[npc.index] = ApertureMinigunnerPerfected_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		
		
		npc.StartPathing();
		npc.m_flSpeed = 120.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/heavy/hardhat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/dec24_cossack_camo_style1/dec24_cossack_camo_style1.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2016_mad_mask/hwn2016_mad_mask.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void ApertureMinigunnerPerfected_ClotThink(int iNPC)
{
	ApertureMinigunnerPerfected npc = view_as<ApertureMinigunnerPerfected>(iNPC);
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
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		ApertureMinigunnerPerfectedSelfDefense(npc); 
	}
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ApertureMinigunnerPerfected_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureMinigunnerPerfected npc = view_as<ApertureMinigunnerPerfected>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureMinigunnerPerfected_NPCDeath(int entity)
{
	ApertureMinigunnerPerfected npc = view_as<ApertureMinigunnerPerfected>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/gatling_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/tomislav_shoot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/gatling_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/tomislav_shoot.wav");
	
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

}

void ApertureMinigunnerPerfectedSelfDefense(ApertureMinigunnerPerfected npc)
{
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	bool SpinSound = true;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
			npc.PlayMinigunSound(true);
			SpinSound = false;
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
			npc.FaceTowards(vecTarget, 20000.0);
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
			{
				target = TR_GetEntityIndex(swingTrace);	
					
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				float origin[3], angles[3];
				view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
				ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 50.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.0;
						
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
				}
			}
			delete swingTrace;
	}
	if(SpinSound)
		npc.PlayMinigunSound(false);
}