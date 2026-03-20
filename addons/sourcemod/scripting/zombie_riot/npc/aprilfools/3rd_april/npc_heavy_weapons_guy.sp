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
	"vo/taunts/heavy/heavy_aerobic_01.mp3",
	"vo/taunts/heavy/heavy_aerobic_05.mp3",
	"vo/taunts/heavy/heavy_aerobic_06.mp3",
	"vo/taunts/heavy/heavy_aerobic_08.mp3",
	"vo/taunts/heavy/heavy_aerobic_17.mp3",
	"vo/taunts/heavy/heavy_aerobic_22.mp3",
};


void HeavyWeaponsGuy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSound("weapons/minigun_spin.wav");
	PrecacheSound("weapons/minigun_shoot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Heavy Weapons Guy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_heavy_weapons_guy");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPC_Add(data);

}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return HeavyWeaponsGuy(vecPos, vecAng, team);
}

methodmap HeavyWeaponsGuy < CClotBody
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
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(6.0, 8.0);
		
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
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
				EmitSoundToAll("weapons/minigun_shoot.wav", this.index, SNDCHAN_STATIC, 85, _, 0.8);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
				EmitSoundToAll("weapons/minigun_spin.wav", this.index, SNDCHAN_STATIC, 85, _, 0.8);
			}
			this.i_GunMode = 1;
		}
	}

	public HeavyWeaponsGuy(float vecPos[3], float vecAng[3], int ally)
	{
		HeavyWeaponsGuy npc = view_as<HeavyWeaponsGuy>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "10000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_DEPLOYED_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		func_NPCDeath[npc.index] = HeavyWeaponsGuy_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = HeavyWeaponsGuy_OnTakeDamage;
		func_NPCThink[npc.index] = HeavyWeaponsGuy_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		
		
		npc.StartPathing();
		npc.m_flSpeed = 80.0;
		
		
		npc.i_GunMode = 1;
		npc.PlayMinigunSound(false);
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_minigun/c_minigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void HeavyWeaponsGuy_ClotThink(int iNPC)
{
	HeavyWeaponsGuy npc = view_as<HeavyWeaponsGuy>(iNPC);
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
		HeavyWeaponsGuySelfDefense(npc); 
	}
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action HeavyWeaponsGuy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	HeavyWeaponsGuy npc = view_as<HeavyWeaponsGuy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void HeavyWeaponsGuy_NPCDeath(int entity)
{
	HeavyWeaponsGuy npc = view_as<HeavyWeaponsGuy>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void HeavyWeaponsGuySelfDefense(HeavyWeaponsGuy npc)
{
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	bool SpinSound = true;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(Can_I_See_Enemy_Only(npc.index, target))
	{
		npc.PlayMinigunSound(true);
		npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
		npc.FaceTowards(vecTarget, 20000.0);
		FireBulletBase(npc, vecTarget);
		SpinSound = false;
	}
	if(SpinSound)
		npc.PlayMinigunSound(false);
}

static void FireBulletBase(HeavyWeaponsGuy npc, float vecTarget[3])
{
	float vecSpread = 0.1;

	float eyePitch[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
	
	static float Spread = 1.0;
	float x, y;
	x = GetRandomFloat( -Spread, Spread ) + GetRandomFloat( -Spread, Spread );
	y = GetRandomFloat( -Spread, Spread ) + GetRandomFloat( -Spread, Spread );
	
	float vecDirShooting[3], vecRight[3], vecUp[3];
	
	vecTarget[2] += 15.0;
	float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
	MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
	GetVectorAngles(vecDirShooting, vecDirShooting);
	vecDirShooting[1] = eyePitch[1];
	GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);

	float vecDir[3];
	vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
	vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
	vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
	NormalizeVector(vecDir, vecDir);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 25.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
}
