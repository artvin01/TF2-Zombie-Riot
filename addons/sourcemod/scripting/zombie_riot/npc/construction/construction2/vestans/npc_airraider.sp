#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/soldier_negativevocalization01.mp3",
	")vo/soldier_negativevocalization02.mp3",
	")vo/soldier_negativevocalization03.mp3",
	")vo/soldier_negativevocalization04.mp3",
	")vo/soldier_negativevocalization05.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/soldier_dominationsniper13.mp3",
	"vo/soldier_dominationsniper01.mp3",
	"vo/compmode/cm_soldier_pregamefirst_04.mp3",
	"vo/compmode/cm_soldier_pregamefirst_05.mp3"
};

static const char g_ExplosionSounds[][]= {
	"weapons/explode1.wav",
	"weapons/explode2.wav",
	"weapons/explode3.wav"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav"
};
static const char g_MeleeAttackSounds[] = "weapons/shotgun_shoot.wav";
static const char g_ShotgunReloadingSounds[][] = {
	")weapons/shotgun_cock_back.wav",
	")weapons/shotgun_cock_forward.wav",
	")weapons/shotgun_reload.wav"
};

static int SaveSolidFlags;
static int SaveSolidType;

void Airraider_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Airraider");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_airraider");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_airstrike_para");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Vesta;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_ShotgunReloadingSounds);
	PrecacheSoundArray(g_ExplosionSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Airraider(vecPos, vecAng, team, data);
}

methodmap Airraider < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index) || this.b_AirraiderRocketJump)
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayShotgunSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int i_TPMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float f_AirraiderRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool b_AirraiderRocketJump
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}

	public Airraider(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Airraider npc = view_as<Airraider>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "7500", ally));

		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = Airraider_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Airraider_OnTakeDamage;
		func_NPCThink[npc.index] = Airraider_ClotThink;
		
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		npc.m_flGravityMulti = 0.35;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 2.0;
		npc.i_TPMode=1;

		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 3.0;
		npc.f_AirraiderRocketJumpCD_Wearoff = GetGameTime(npc.index) + 1.0;
	//	b_NpcIsInvulnerable[npc.index] = true;
		npc.m_bTeamGlowDefault = false;
		
		f_NoUnstuckVariousReasons[npc.index] = FAR_FUTURE;
		b_DoNotUnStuck[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.Anger = true;
		npc.b_AirraiderRocketJump = true;
		npc.m_bFUCKYOU = false;
		npc.m_fbRangedSpecialOn = false;
		
		if(StrContains(data, "no_tp") != -1)
			npc.i_TPMode=0;
		if(StrContains(data, "type_b") != -1)
		{
			SaveSolidFlags=GetEntProp(npc.index, Prop_Send, "m_usSolidFlags");
			SaveSolidType=GetEntProp(npc.index, Prop_Send, "m_nSolidType");
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnoredEntirelyFromAllCollisions[npc.index] = true;
			npc.i_TPMode=2;
		}
		if(StrContains(data, "angry") != -1)
		{
			npc.m_fbRangedSpecialOn = true;
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
	//	Weapon
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_paratooper_pack/c_paratrooper_parachute.mdl");
		SetVariantString("3.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec2014_skullcap/dec2014_skullcap.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec15_gift_bringer/dec15_gift_bringer_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/fall17_attack_packs/fall17_attack_packs.mdl");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2025_seamanns/hwn2025_seamanns.mdl");

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_paratooper_pack/c_paratrooper_pack.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		NpcColourCosmetic_ViaPaint(npc.m_iWearable3, 1581885);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable4, 1581885);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable5, 1581885);
		
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 1.0);

		SetVariantString("deploy_idle");
		AcceptEntityInput(npc.m_iWearable2, "SetAnimation");
		
		return npc;
	}
}

static void Airraider_ClotThink(int iNPC)
{
	Airraider npc = view_as<Airraider>(iNPC);
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	float vecTarget[3],VecSelfNpc[3],flDistanceToTarget;
	if(npc.b_AirraiderRocketJump)
	{
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
		if(IsValidEntity(i_InvincibleParticle[npc.index]))
		{
			int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
			SetEntityRenderMode(particle, RENDER_NONE);
			SetEntityRenderColor(particle, 255, 255, 255, 1);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
		}
		if(npc.i_TPMode==2)
		{
			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			if(!IsValidEnemy(npc.index, npc.m_iTarget))
				npc.m_iTarget=GetRandomPlayer(npc);
			npc.m_bisWalking = true;
			npc.StartPathing();
			npc.m_flSpeed = 400.0;
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			WorldSpaceCenter(npc.index, VecSelfNpc);
			flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else
				npc.SetGoalEntity(npc.m_iTarget);
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*5.0*GetRandomFloat(1.0, 5.0))
			{
				npc.m_flSpeed = 0.0;
				npc.m_bisWalking = false;
				SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", SaveSolidFlags);
				SetEntProp(npc.index, Prop_Data, "m_nSolidType", SaveSolidType);
				if(GetTeam(npc.index) == TFTeam_Red)
					SetEntityCollisionGroup(npc.index, 24);
				else
					SetEntityCollisionGroup(npc.index, 9);
				b_NoKnockbackFromSources[npc.index] = false;
				b_ThisEntityIgnoredEntirelyFromAllCollisions[npc.index] = false;
				b_NpcIgnoresbuildings[npc.index] = false;
				npc.f_AirraiderRocketJumpCD_Wearoff = GameTime + 1.0;
				npc.i_TPMode=0;
			}
			else
			{
				b_NpcIgnoresbuildings[npc.index] = true;
				MakeObjectIntangeable(npc.index);
			}
			return;
		}
		npc.StopPathing();
		if(npc.f_AirraiderRocketJumpCD_Wearoff < GameTime)
		{
			if(npc.i_TPMode==1)
				TeleportDiversioToRandLocation(npc.index);
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 3000.0;
			PluginBot_Jump(npc.index, flPos);
			npc.f_AirraiderRocketJumpCD_Wearoff = GameTime + 1.0;
			npc.m_flNextRangedAttack = GameTime + 2.0;
			npc.b_AirraiderRocketJump = false;
		}
		return;
	}
	else
	{
		if(npc.Anger && npc.f_AirraiderRocketJumpCD_Wearoff < GameTime && npc.m_bFUCKYOU == false)
		{
		//	b_NpcIsInvulnerable[npc.index] = false;
			npc.m_bTeamGlowDefault = true;
			if(IsValidEntity(i_InvincibleParticle[npc.index]))
			{
				int Shield = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
				if(b_NpcIsInvulnerable[npc.index])
				{
					if(i_InvincibleParticlePrev[Shield] != 0)
					{
						SetEntityRenderColor(Shield, 0, 255, 0, 255);
						i_InvincibleParticlePrev[Shield] = 0;
					}
				}
				else if(i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
				{
					if(i_InvincibleParticlePrev[Shield] != 1)
					{
						SetEntityRenderColor(Shield, 0, 50, 50, 35);
						i_InvincibleParticlePrev[Shield] = 1;
					}
				}
				SetEntPropFloat(Shield, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(Shield, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 0.0);
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 0.0);
			if(IsValidEntity(npc.m_iWearable2))
			{
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 0.0);
			}
			SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 0.0);
			SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 0.0);
			SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 0.0);
			SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 0.0);
			SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 0.0);
			if(npc.IsOnGround())
			{
				npc.m_bFUCKYOU = true;
				if(!npc.m_fbRangedSpecialOn)
				{
					npc.Anger = false;
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl");

					npc.m_iMaxAmmo = 6;
					npc.m_iAmmo =6;
					ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
				}
				if(IsValidEntity(npc.m_iWearable2))
					RemoveEntity(npc.m_iWearable2);
				npc.m_flGravityMulti = 1.0;
				npc.m_flSpeed = 250.0;
				npc.m_flRangedArmor = 1.0;
				npc.StartPathing();
				f_NoUnstuckVariousReasons[npc.index] = GameTime + 1.0;
				b_DoNotUnStuck[npc.index] = false;
				Is_a_Medic[npc.index] = false;
			}
		}
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, VecSelfNpc);
		flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
			npc.SetGoalEntity(npc.m_iTarget);
		AirraiderSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	AirraiderAnimationChange(npc);
	npc.PlayIdleAlertSound();
}

static Action Airraider_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Airraider npc = view_as<Airraider>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(npc.b_AirraiderRocketJump)
		damage*=0.0;
	return Plugin_Changed;
}

static void Airraider_NPCDeath(int entity)
{
	Airraider npc = view_as<Airraider>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
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

static void AirraiderAnimationChange(Airraider npc)
{
	if(npc.Anger) //primary
	{
		if (npc.IsOnGround())
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				SetVariantInt(2);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 1;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.StartPathing();
			}	
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				SetVariantInt(2);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
				npc.StopPathing();
			}	
		}
	}
	else //Secondary
	{
		if (npc.IsOnGround())
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				SetVariantInt(2);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 3;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.StartPathing();
			}	
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				SetVariantInt(2);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_JUMP_FLOAT_SECONDARY");
				npc.StopPathing();
			}	
		}
	}
}

static void AirraiderSelfDefense(Airraider npc, float gameTime, int target, float distance)
{
	if(!npc.Anger && npc.m_bFUCKYOU)
	{
		if(npc.m_flAttackHappens || !npc.m_iAmmo)
		{
			if(!npc.m_flAttackHappens)
			{
				EmitSoundToAll(g_ShotgunReloadingSounds[0], npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
				npc.m_flAttackHappens=gameTime+2.35;
				npc.m_flDoingAnimation=gameTime+0.2;
			}
			if(gameTime > npc.m_flDoingAnimation)
			{
				npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,1.8);
				npc.m_flDoingAnimation=gameTime+0.35;
				EmitSoundToAll(g_ShotgunReloadingSounds[2], npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
				npc.m_iAmmo++;
			}
			if(gameTime > npc.m_flAttackHappens)
			{
				npc.m_iAmmo = npc.m_iMaxAmmo;
				npc.m_flNextRangedAttack = gameTime + 0.3;
				npc.m_flAttackHappens=0.0;
				EmitSoundToAll(g_ShotgunReloadingSounds[1], npc.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
			}
			return;
		}
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See) && gameTime > npc.m_flNextRangedAttack)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				npc.m_iTarget = Enemy_I_See;
				npc.PlayShotgunSound();
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
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
					npc.m_flNextMeleeAttack = gameTime + 0.75;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 90.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 2.0;
						
						KillFeed_SetKillIcon(npc.index, "reserve_shooter");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
					npc.m_flNextRangedAttack = gameTime + 0.50;
				}
				delete swingTrace;
				npc.m_iAmmo--;
			}
		}
		return;
	}
	if(npc.Anger && npc.m_bFUCKYOU)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			npc.AddGesture("ACT_MP_THROW");
			float EnemyPos[3];
			WorldSpaceCenter(npc.m_iTarget, EnemyPos);
			npc.FaceTowards(EnemyPos, 15000.0);
			int projectile = npc.FireRocket(EnemyPos, 150.0, 1000.0, "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl", 1.0);
			SDKHook(projectile, SDKHook_StartTouch, Airraider_Eat_This_Shit_StartTouch);
			npc.Anger = false;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl");

			npc.m_iMaxAmmo = 6;
			npc.m_iAmmo =6;
			ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
		}
		return;
	}
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 900.0))
	{	
		if(gameTime > npc.m_flNextRangedAttack)
		{	
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				float projectile_speed = 1000.0;
				float DamageRocket = 30.0;
				float vPredictedPos[3];
				PredictSubjectPositionForProjectiles(npc, target, projectile_speed, _,vPredictedPos);
				
				npc.FaceTowards(vPredictedPos, 20000.0);
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				
				KillFeed_SetKillIcon(npc.index, "airstrike");
				npc.PlayRangedSound();
				npc.FireRocket(vPredictedPos, DamageRocket, projectile_speed, "models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl");
				npc.m_flNextRangedAttack = gameTime + 0.30;
			}
		}
	}
	return;
}

static int GetRandomPlayer(Airraider npc)
{
	int Getclient = -1;

	int victims;
	int[] victim = new int[MaxClients];

	for(int client_check = 1; client_check <= MaxClients; client_check++)
	{
		if(!IsValidClient(client_check))
			continue;

		if(TeutonType[client_check] != TEUTON_NONE)
			continue;

		if(dieingstate[client_check] > 0)
			continue;
			
		if(!IsValidEnemy(npc.index, client_check))
			continue;

		victim[victims++] = client_check;
	}
	
	if(victims)
	{
		int winner = victim[GetURandomInt() % victims];
		Getclient = winner;
	}
	else
		Getclient = GetClosestTarget(npc.index);

	return Getclient;
}

static Action Airraider_Eat_This_Shit_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

	if(inflictor == -1)
		inflictor = owner;

	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	Explode_Logic_Custom(0.0, owner, inflictor, -1, ProjectileLoc, EXPLOSION_RADIUS, _, _, true, _, false, _, AirStrikeBomb);
	ParticleEffectAt(ProjectileLoc, "ExplosionCore_MidAir", 1.0);
	EmitSoundToAll(g_ExplosionSounds[GetRandomInt(0, sizeof(g_ExplosionSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, -1, ProjectileLoc);
	RemoveEntity(entity);

	for(int rocketcount ; rocketcount < 3 ; rocketcount++)
	{
		float RocketDamage = 10.0;
		float RocketSpeed = 500.0;
		float vecTargetrandombomb[3]; 
		vecTargetrandombomb = ProjectileLoc;
		vecTargetrandombomb[0] += GetRandomFloat(-50.0, 50.0);
		vecTargetrandombomb[1] += GetRandomFloat(-50.0, 50.0);
		vecTargetrandombomb[2] += GetRandomFloat(-30.0, 30.0);

		float SpeedReturn[3];

		int RocketGet = view_as<Airraider>(entity).FireRocket(vecTargetrandombomb, RocketDamage, RocketSpeed);
		Attributes_Set(RocketGet, Attrib_MultiBuildingDamage, 2.0);
		//Reducing gravity, reduces speed, lol.
		SetEntityGravity(RocketGet, 1.0);
		ArcToLocationViaSpeedProjectile(RocketGet, vecTargetrandombomb, SpeedReturn, 0.5, 1.0);
		SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
		TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
	}

	return Plugin_Handled;
}

static void AirStrikeBomb(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(GetTeam(entity) != GetTeam(victim))
	{
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = entity;
		damage = 30.0;
		if(ShouldNpcDealBonusDamage(victim))
			damage *= 3.0;
		SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
	}
}