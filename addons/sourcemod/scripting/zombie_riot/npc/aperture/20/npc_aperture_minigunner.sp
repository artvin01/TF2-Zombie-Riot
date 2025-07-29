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


void ApertureMinigunner_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSound("weapons/minifun_spin.wav");
	PrecacheSound("weapons/minifun_shoot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Minigunner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_minigunner");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);

}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ApertureMinigunner(vecPos, vecAng, team);
}

methodmap ApertureMinigunner < CClotBody
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
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minifun_spin.wav");
				EmitSoundToAll("weapons/minifun_shoot.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minifun_shoot.wav");
				EmitSoundToAll("weapons/minifun_spin.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 1;
		}
	}

	public ApertureMinigunner(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureMinigunner npc = view_as<ApertureMinigunner>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "10000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_DEPLOYED_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		func_NPCDeath[npc.index] = ApertureMinigunner_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ApertureMinigunner_OnTakeDamage;
		func_NPCThink[npc.index] = ApertureMinigunner_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		
		
		npc.StartPathing();
		npc.m_flSpeed = 150.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_minigun/c_minigun_natascha.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/heavy/hardhat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr17_wingman/spr17_wingman_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void ApertureMinigunner_ClotThink(int iNPC)
{
	ApertureMinigunner npc = view_as<ApertureMinigunner>(iNPC);
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
		ApertureMinigunnerSelfDefense(npc); 
	}
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ApertureMinigunner_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureMinigunner npc = view_as<ApertureMinigunner>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureMinigunner_NPCDeath(int entity)
{
	ApertureMinigunner npc = view_as<ApertureMinigunner>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minifun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minifun_shoot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minifun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minifun_shoot.wav");
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void ApertureMinigunnerSelfDefense(ApertureMinigunner npc)
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
					float damageDealt = 15.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 4.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					if (!IsInvuln(target) && !i_IsABuilding[target])
					{
						if(!HasSpecificBuff(target, "Fluid Movement"))
						TF2_StunPlayer(target, 0.1, 0.5, TF_STUNFLAG_SLOWDOWN);
					}
				}
			}
			delete swingTrace;
	}
	if(SpinSound)
		npc.PlayMinigunSound(false);
}