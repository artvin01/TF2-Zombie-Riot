#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/strider/striderx_die1.wav",
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};


static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_VoidSummonCharge[][] = {
	"items/powerup_pickup_supernova.wav",
};

static const char g_VoidSummonCast[][] = {
	"misc/halloween/merasmus_hiding_explode.wav",
};

static const char g_VoidLaserPulseAttack[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};
static const char g_VoidLaserPulseAttackInit[][] = {
	"weapons/gauss/fire1.wav",
};

static const char g_VoidQuakeCharge[][] = {
	"weapons/physcannon/physcannon_charge.wav",
};

static const char g_VoidQuakeCast[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};


static const char g_VoidMagicCharge[][] = {
	"npc/scanner/scanner_blip1.wav",
};

static const char g_VoidMagicCast[][] = {
	"npc/scanner/cbot_discharge1.wav",
};


void Vhxis_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_VoidSummonCharge)); i++) { PrecacheSound(g_VoidSummonCharge[i]); }
	for (int i = 0; i < (sizeof(g_VoidSummonCast)); i++) { PrecacheSound(g_VoidSummonCast[i]); }
	for (int i = 0; i < (sizeof(g_VoidLaserPulseAttack)); i++) { PrecacheSound(g_VoidLaserPulseAttack[i]); }
	for (int i = 0; i < (sizeof(g_VoidLaserPulseAttackInit)); i++) { PrecacheSound(g_VoidLaserPulseAttackInit[i]); }
	for (int i = 0; i < (sizeof(g_VoidQuakeCharge)); i++) { PrecacheSound(g_VoidQuakeCharge[i]); }
	for (int i = 0; i < (sizeof(g_VoidQuakeCast)); i++) { PrecacheSound(g_VoidQuakeCast[i]); }
	for (int i = 0; i < (sizeof(g_VoidMagicCharge)); i++) { PrecacheSound(g_VoidMagicCharge[i]); }
	for (int i = 0; i < (sizeof(g_VoidMagicCast)); i++) { PrecacheSound(g_VoidMagicCast[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vhxis");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vhxis");
	strcopy(data.Icon, sizeof(data.Icon), "void_vhxis");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/forest_rogue/vhxis_battle.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Vhxis(vecPos, vecAng, team, data);
}

methodmap Vhxis < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);

	}
	public void PlaySummonChargeSound()
	{
		EmitSoundToAll(g_VoidSummonCharge[GetRandomInt(0, sizeof(g_VoidSummonCharge) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	public void PlaySummonCastSound() 
	{
		EmitSoundToAll(g_VoidSummonCast[GetRandomInt(0, sizeof(g_VoidSummonCast) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	public void PlayVoidLaserSound() 
	{
		EmitSoundToAll(g_VoidLaserPulseAttack[GetRandomInt(0, sizeof(g_VoidLaserPulseAttack) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayVoidLaserSoundInit() 
	{
		EmitSoundToAll(g_VoidLaserPulseAttackInit[GetRandomInt(0, sizeof(g_VoidLaserPulseAttackInit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayVoidQuakeSound() 
	{
		EmitSoundToAll(g_VoidQuakeCharge[GetRandomInt(0, sizeof(g_VoidQuakeCharge) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayVoidQuakeSoundInit() 
	{
		EmitSoundToAll(g_VoidQuakeCast[GetRandomInt(0, sizeof(g_VoidQuakeCast) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMagicChargeSound() 
	{
		EmitSoundToAll(g_VoidQuakeCharge[GetRandomInt(0, sizeof(g_VoidQuakeCharge) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMagicCastSound() 
	{
		EmitSoundToAll(g_VoidQuakeCast[GetRandomInt(0, sizeof(g_VoidQuakeCast) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
	}

	property float m_flVoidSummonCooldown
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property float m_flVoidSummonHappening
	{
		public get()							{ return fl_NextRangedAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttack[this.index] = TempValueForProperty; }
	}
	property float m_flVoidLaserPulseCooldown
	{
		public get()							{ return fl_NextRangedAttackHappening[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttackHappening[this.index] = TempValueForProperty; }
	}
	property float m_flVoidLaserPulseHappening
	{
		public get()							{ return fl_XenoInfectedSpecialHurtTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_XenoInfectedSpecialHurtTime[this.index] = TempValueForProperty; }
	}

	property float m_flVoidGroundShakeCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	property float m_flVoidGroundShakeHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flEffectThrottle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}

	property float m_flVoidMagicCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}

	property float m_flVoidMagicHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	
	property float m_flDeathAnimation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	
	
	
	public Vhxis(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Vhxis npc = view_as<Vhxis>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "2.0", "30000", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_ROGUE2_VOID_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_flVoidSummonCooldown = GetGameTime() + 5.0;
		npc.m_flVoidLaserPulseCooldown = GetGameTime() + 10.0;
		npc.m_flVoidGroundShakeCooldown = GetGameTime() + 15.0;
		npc.m_flVoidMagicCooldown = GetGameTime() + 20.0;
		AlreadySaidWin = false;
		AlreadySaidLastmann = false;
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Vhxis_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Vhxis_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Vhxis_ClotThink);
		func_NPCFuncWin[npc.index] = view_as<Function>(VoidVhxisWin);
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/forest_rogue/vhxis_battle.mp3");
		music.Time = 122;
		music.Volume = 1.35;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Breach and Escape");
		strcopy(music.Artist, sizeof(music.Artist), "Spencer Baggett");
		Music_SetRaidMusic(music);
	
		bool final = StrContains(data, "final_item") != -1;

		if(Rogue_HasNamedArtifact("Ascension Stack"))
			final = false;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}

		b_NpcUnableToDie[npc.index] = true;
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Vhxis arrived");
			}
		}
		npc.m_flMeleeArmor = 1.25;
		
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 350.0;
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}

		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff

		RaidModeScaling *= 0.9;

		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2022_dustbowl_devil/hwn2022_dustbowl_devil.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/pyro/hwn_pyro_misc1.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/engineer/fwk_engineer_cranial.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		CPrintToChatAll("{purple}Vhxis: {default}Youre nothing before the power of the void!");

		
		SetEntityRenderColor(npc.index, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);

		
		SetEntityRenderFx(npc.index, 		RENDERFX_GLOWSHELL);
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_GLOWSHELL);
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_GLOWSHELL);
		SetEntityRenderFx(npc.m_iWearable3, RENDERFX_GLOWSHELL);
		SetEntityRenderFx(npc.m_iWearable4, RENDERFX_GLOWSHELL);
		SetEntityRenderFx(npc.m_iWearable5, RENDERFX_GLOWSHELL);

		float flPos[3], flAng[3];
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_eyeboss_vortex", npc.index, "eyes", {0.0,0.0,0.0});
		
		return npc;
	}
}

public void Vhxis_ClotThink(int iNPC)
{
	Vhxis npc = view_as<Vhxis>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flDeathAnimation)
	{
		if(npc.m_iChanged_WalkCycle != 10)
		{
			CPrintToChatAll("{purple}Vhxis: {default}You fools!... You think i made the void?!");
			if(IsValidEntity(npc.m_iWearable1))
			{
				AcceptEntityInput(npc.m_iWearable1, "Disable");
			}
			float ProjectileLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
			TE_Particle("halloween_boss_summon", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 10;
			npc.SetActivity("ACT_ROGUE2_VOID_DRAMATIC_DEATH");
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
		}
		if(npc.m_flDeathAnimation < GetGameTime(npc.index))
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			CPrintToChatAll("{purple}The void has been released...");
		}
		return;
	}
	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		CPrintToChatAll("{purple}Vhxis: {default}You almost released the void, i have to keep it in check, piss off!");
		return;
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	/*
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	*/
	npc.PlayIdleAlertSound();

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(VoidVhxis_LaserPulseAttack(npc, GetGameTime(npc.index)))
	{
		return;
	}
	
	if(VoidVhxis_GroundQuake(npc, GetGameTime(npc.index)))
	{
		return;
	}

	if(VoidVhxis_VoidSummoning(npc, GetGameTime(npc.index)))
	{
		return;
	}

	if(VoidVhxis_VoidMagic(npc, GetGameTime(npc.index)))
	{
		return;
	}

	
	//default fight animation, set whenever no ability is in use.
	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			if(IsValidEntity(npc.m_iWearable1))
			{
				AcceptEntityInput(npc.m_iWearable1, "Enable");
			}
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_ROGUE2_VOID_WALK");
			npc.StartPathing();
			npc.m_flSpeed = 310.0;
		}
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
		VhxisSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Vhxis_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Vhxis npc = view_as<Vhxis>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_flDeathAnimation)
	{
		npc.m_flDeathAnimation = GetGameTime(npc.index) + 4.1;
		npc.PlayDeathSound();
	}
	if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true;
		CPrintToChatAll("{purple}Vhxis: {default}Die already! Im giving it all already!!");
	}
	return Plugin_Changed;
}

public void Vhxis_NPCDeath(int entity)
{
	Vhxis npc = view_as<Vhxis>(entity);
	
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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

void VhxisSelfDefense(Vhxis npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			int HowManyEnemeisAoeMelee = 64;
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
			delete swingTrace;
			bool PlaySound = false;
			for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
			{
				if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
				{
					if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
					{
						PlaySound = true;
						target = i_EntitiesHitAoeSwing_NpcSwing[counter];
						float vecHit[3];
						WorldSpaceCenter(target, vecHit);
									
						float damageDealt = 30.0 * RaidModeScaling;

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);	
						Elemental_AddVoidDamage(target, npc.index, 350, true, true);							
						
						bool Knocked = false;
						
						if(IsValidClient(target))
						{
							if (IsInvuln(target))
							{
								Knocked = true;
								Custom_Knockback(npc.index, target, 900.0, true);
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
							else
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
									
						if(!Knocked)
							Custom_Knockback(npc.index, target, 150.0, true); 
					}
				}
			}
			if(PlaySound)
			{
				npc.PlayMeleeHitSound();
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_ROGUE2_VOID_ATTACK1");
				/*
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						npc.AddGesture("ACT_ROGUE2_VOID_ATTACK1");
					}
					case 1:
					{
						npc.AddGesture("ACT_ROGUE2_VOID_ATTACK2");
					}
				}
				attack2 looks shit ngl
				*/

				npc.m_flAttackHappens = gameTime + 0.5;
				npc.m_flDoingAnimation = gameTime + 0.5;
				npc.m_flNextMeleeAttack = gameTime + 0.9;
			}
		}
	}
}

#define VOID_GROUNDQUAKE_RANGE 750.0
#define VOID_GROUNDQUAKE_DAMAGE (100.0 * RaidModeScaling)

int VoidGroundShake[MAXENTITIES];

float VoidVhxis_GroundQuakeCheck(int entity, int victim, float damage, int weapon)
{
	VoidGroundShake[victim] = true;
	return damage;
}


//This summons the creep, and several enemies on his side!
bool VoidVhxis_GroundQuake(Vhxis npc, float gameTime)
{
	if(npc.m_flVoidGroundShakeHappening)
	{
		float ProjectileLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		if(npc.m_flEffectThrottle < gameTime)
		{
			spawnRing_Vectors(ProjectileLoc, VOID_GROUNDQUAKE_RANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.3, 5.0, 8.0, 3);	
			spawnRing_Vectors(ProjectileLoc, VOID_GROUNDQUAKE_RANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.3, 5.0, 8.0, 3);	
			spawnRing_Vectors(ProjectileLoc, VOID_GROUNDQUAKE_RANGE * 10.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.3, 5.0, 8.0, 3, VOID_GROUNDQUAKE_RANGE * 2.0);	
			spawnRing_Vectors(ProjectileLoc, VOID_GROUNDQUAKE_RANGE * 10.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.3, 5.0, 8.0, 3, VOID_GROUNDQUAKE_RANGE * 2.0);	
			npc.m_flEffectThrottle = gameTime + 0.25;
		}
		if(npc.m_flVoidGroundShakeHappening < gameTime)
		{
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);

			npc.PlayVoidQuakeSoundInit();
			
			//This will only detect people, not damage them.
			Zero(VoidGroundShake);
			ProjectileLoc[2] += 60.0;
			Explode_Logic_Custom(1.0, 0, npc.index, -1, ProjectileLoc, VOID_GROUNDQUAKE_RANGE, 1.0, _, false, 99,_,_,_,VoidVhxis_GroundQuakeCheck);
			
			static float victimPos[3];
			static float partnerPos[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
			float playerPos[3];
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (IsValidEnemy(npc.index, victim, true))
				{
					if(!VoidGroundShake[victim])
					{
						if(b_ThisWasAnNpc[victim])
							PluginBot_Jump(victim, {0.0,0.0,1000.0});
						else
							TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,1000.0});

						GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
						SDKHooks_TakeDamage(victim, npc.index, npc.index, VOID_GROUNDQUAKE_DAMAGE, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
						Elemental_AddVoidDamage(victim, npc.index, 200, true, true);
					}
					else
					{
						ApplyStatusEffect(npc.index, victim, "Teslar Shock", 5.0);
						if(!b_ThisWasAnNpc[victim])
						{
							GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", victimPos); 
							static float angles[3];
							GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

							if (GetEntityFlags(victim) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 1500.0;
							ScaleVector(velocity, attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(victim) & FL_ONGROUND)
							{
								velocity[2] = 350.0;
							}
							else
							{
								velocity[2] = 200.0;
							}
										
							// apply velocity
							velocity[0] *= -1.0;
							velocity[1] *= -1.0;
						//	velocity[2] *= -1.0;
							TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);    
						}
					}
				}
			}
			TE_Particle("hammer_bell_ring_shockwave2", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			CreateEarthquake(ProjectileLoc, 1.0, 1000.0, 12.0, 100.0);
			npc.m_flVoidGroundShakeHappening = 0.0;
		}
		return true;
	}

	if(npc.m_flDoingAnimation < gameTime && npc.m_flVoidGroundShakeCooldown < gameTime)
	{
		//This ability is ready, lets cast it.
		if(npc.m_iChanged_WalkCycle != 3)
		{
			//This lasts 60 frames
			//at frame 40 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 3;
			npc.SetActivity("ACT_ROGUE2_VOID_GROUND_VAPORISER");
			npc.SetPlaybackRate(0.5);
			npc.StopPathing();
			
			npc.m_flSpeed = 0.0;
		}

		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		float pos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		Event event = CreateEvent("show_annotation");
		if(event)
		{
			event.SetFloat("worldPosX", pos[0]);
			event.SetFloat("worldPosY", pos[1]);
			event.SetFloat("worldPosZ", pos[2]);
		//	event.SetInt("follow_entindex", 0);
			event.SetFloat("lifetime", 3.0);
		//	event.SetInt("visibilityBitfield", (1<<client));
			//event.SetBool("show_effect", effect);
			event.SetString("text", "STAY IN ZONE!!");
			event.SetString("play_sound", "vo/null.mp3");
			event.SetInt("id", 999979); //What to enter inside? Need a way to identify annotations by entindex!
			event.Fire();
		}
		pos[2] += 5.0;
		float ang_Look[3];
		float DelayPillars = 4.5;
		float DelaybewteenPillars = 0.25;
		int MaxCount = 6;
		ResetTEStatusSilvester();
		SetSilvesterPillarColour({125, 0, 125, 200});
		for(int Repeat; Repeat <= 15; Repeat++)
		{
			Silvester_Damaging_Pillars_Ability(npc.index,
			25.0 * RaidModeScaling,				 	//damage
			MaxCount, 	//how many
			DelayPillars,									//Delay untill hit
			DelaybewteenPillars,									//Extra delay between each
			ang_Look 								/*2 dimensional plane*/,
			pos,
			0.25,
			1.25);									//volume
			ang_Look[1] += 22.5;
		}

		npc.PlayVoidQuakeSound();

		float flPos[3], flAng[3];
		npc.GetAttachment("LHand", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "unusual_eyeboss_parent", npc.index, "LHand", {0.0,0.0,0.0});

		npc.m_flVoidGroundShakeHappening = gameTime + 3.12;
		npc.m_flDoingAnimation = gameTime + 5.0;
		npc.m_flVoidGroundShakeCooldown = gameTime + 60.0;
		return true;
	}

	return false;
}

#define VOID_SUMMON_RANGE_BOOM 500.0
#define VOID_SUMMON_DAMAGE (70.0 * RaidModeScaling)

//This summons the creep, and several enemies on his side!
bool VoidVhxis_VoidSummoning(Vhxis npc, float gameTime)
{
	if(npc.m_flVoidSummonHappening)
	{
		float ProjectileLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		
		if(npc.m_flEffectThrottle < gameTime)
		{
			spawnRing_Vectors(ProjectileLoc, VOID_SUMMON_RANGE_BOOM * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 0, 125, 200, 1, 0.3, 5.0, 8.0, 3);	
			spawnRing_Vectors(ProjectileLoc, VOID_SUMMON_RANGE_BOOM * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 125, 0, 125, 200, 1, 0.3, 5.0, 8.0, 3);	
			spawnRing_Vectors(ProjectileLoc, VOID_SUMMON_RANGE_BOOM * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 125, 0, 125, 200, 1, 0.3, 5.0, 8.0, 3);	
			spawnRing_Vectors(ProjectileLoc, 1.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 125, 0, 125, 200, 1, 0.3, 5.0, 8.0, 3, VOID_SUMMON_RANGE_BOOM * 2.0);	
			npc.m_flEffectThrottle = gameTime + 0.25;
		}
		if(npc.m_flVoidSummonHappening < gameTime)
		{
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);

			npc.PlaySummonCastSound();
			
			//remove particle, spawn creep, deal aoe damage
			ProjectileLoc[2] += 5.0;
			VoidArea_SpawnNethersea(ProjectileLoc);
			ProjectileLoc[2] += 60.0;
			Explode_Logic_Custom(VOID_SUMMON_DAMAGE, 0, npc.index, -1, ProjectileLoc, VOID_SUMMON_RANGE_BOOM * 0.95, 1.0, _, true, 20);
			ProjectileLoc[2] -= 60.0;
			TE_Particle("asplode_hoodoo", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			CreateEarthquake(ProjectileLoc, 1.0, 1000.0, 12.0, 100.0);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			float maxhealth = float(ReturnEntityMaxHealth(npc.index));
			maxhealth *= 0.0015;
			for (int DoSpawns = 0; DoSpawns < CountPlayersOnRed(1); DoSpawns++)
			{
				int spawn_index = NPC_CreateByName("npc_void_ixufan", -1, ProjectileLoc, ang, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToNearest(maxhealth));
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", RoundToNearest(maxhealth));
					fl_Extra_Damage[spawn_index] *= 4.5;
					fl_Extra_Speed[spawn_index] *= 1.05;
				}
			}
			npc.m_flVoidSummonHappening = 0.0;
		}

		return true;
	}

	if(npc.m_flDoingAnimation < gameTime && npc.m_flVoidSummonCooldown < gameTime)
	{
		//This ability is ready, lets cast it.
		if(npc.m_iChanged_WalkCycle != 5)
		{
			if(IsValidEntity(npc.m_iWearable1))
			{
				AcceptEntityInput(npc.m_iWearable1, "Disable");
			}
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 5;
			npc.SetActivity("ACT_ROGUE2_VOID_GENERATOR");
			npc.StopPathing();
			
			npc.m_flSpeed = 0.0;
		}
		float ProjectileLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		CreateEarthquake(ProjectileLoc, 3.0, 1000.0, 8.0, 50.0);
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);

		npc.PlaySummonChargeSound();

		float flPos[3], flAng[3];
		npc.GetAttachment("LHand", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "flaregun_energyfield_blue", npc.index, "LHand", {0.0,0.0,0.0});
		npc.GetAttachment("RHand", flPos, flAng);
		npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "flaregun_energyfield_red", npc.index, "RHand", {0.0,0.0,0.0});

		npc.m_flVoidSummonHappening = gameTime + 2.54;
		npc.m_flDoingAnimation = gameTime + 3.04;
		npc.m_flVoidSummonCooldown = gameTime + 30.0;
		return true;
	}

	return false;
}

static int LastEnemyTargeted[MAXENTITIES];
//This summons the creep, and several enemies on his side!
bool VoidVhxis_LaserPulseAttack(Vhxis npc, float gameTime)
{

	if(npc.m_flVoidLaserPulseHappening)
	{
		if(npc.m_flDoingAnimation < gameTime)
		{
			npc.m_flDoingAnimation = gameTime + 0.25;
			//We change who he targets.	
			int TargetEnemy = false;
			TargetEnemy = GetClosestTarget(npc.index,.ingore_client = LastEnemyTargeted[npc.index],  .CanSee = true, .UseVectorDistance = true);
			LastEnemyTargeted[npc.index] = TargetEnemy;
			if(TargetEnemy == -1)
			{
				TargetEnemy = GetClosestTarget(npc.index, .CanSee = true, .UseVectorDistance = true);
			}
			if(IsValidEnemy(npc.index, TargetEnemy))
			{
				float flPos[3], flAng[3];
				npc.GetAttachment("LHand", flPos, flAng);
				float VecEnemy[3]; WorldSpaceCenter(TargetEnemy, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				VoidVhxisInitiateLaserAttack(npc.index, VecEnemy, flPos);
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("LHand"), PATTACH_POINT_FOLLOW, true);
				npc.PlayVoidLaserSound();
				npc.AddGesture("ACT_ROGUE2_VOID_PULSEATTACK_GESTURE");
			}
		}
		if(npc.m_flVoidLaserPulseHappening < gameTime)
		{
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
			
			npc.m_flVoidLaserPulseHappening = 0.0;
		}

		return true;
	}

	if(npc.m_flDoingAnimation < gameTime && npc.m_flVoidLaserPulseCooldown < gameTime)
	{
		//theres no valid enemy, dont cast.
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			return false;
		}
		//cant even see one enemy
		if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			return false;
		}
		//This ability is ready, lets cast it.
		if(npc.m_iChanged_WalkCycle != 4)
		{
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_ROGUE2_VOID_STAND_PULSEATTACK");
			npc.StopPathing();
			
			npc.m_flSpeed = 0.0;
		}
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);

		float flPos[3], flAng[3];
		npc.GetAttachment("LHand", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "spell_teleport_red", npc.index, "LHand", {0.0,0.0,0.0});

		npc.m_flVoidLaserPulseHappening = gameTime + 2.54;
		npc.m_flDoingAnimation = gameTime + 0.25;
		npc.m_flVoidLaserPulseCooldown = gameTime + 10.0;
		return true;
	}

	return false;
}






void VoidVhxisInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{

	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, VoidVhxis_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(VectorTarget, trace);
		
		float lineReduce = 10.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(VectorStart, VectorTarget, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(VectorTarget, VectorStart, VectorTarget, curDist - lineReduce);
		}
	}
	delete trace;

	int red = 125;
	int green = 0;
	int blue = 125;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 100);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.6, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.4, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.2, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Glow, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(VoidVhxisInitiateLaserAttack_DamagePart, 25, pack);
}

void VoidVhxisInitiateLaserAttack_DamagePart(DataPack pack)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		LaserVarious_HitDetection[i] = false;
	}
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();

	int red = 125;
	int green = 25;
	int blue = 125;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 100);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(10);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, VoidVhxis_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	Vhxis npc = view_as<Vhxis>(entity);
	npc.PlayVoidLaserSoundInit();
			
	float CloseDamage = 45.0 * RaidModeScaling;
	float FarDamage = 40.0 * RaidModeScaling;
	float MaxDistance = 2000.0;
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (LaserVarious_HitDetection[victim] && IsValidEnemy(entity, victim, true))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < 0)
				damage *= -1.0;

			
			if(ShouldNpcDealBonusDamage(victim))
				damage *= 3.0;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
			Elemental_AddVoidDamage(victim, entity, 200, true, true);
			IncreaseEntityDamageTakenBy(victim, 0.15, 10.0, true);
		}
	}
	delete pack;
}


public bool VoidVhxis_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}

public bool VoidVhxis_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}



//This summons the creep, and several enemies on his side!
bool VoidVhxis_VoidMagic(Vhxis npc, float gameTime)
{
	if(npc.m_flVoidMagicHappening)
	{
		if(npc.m_flVoidMagicHappening < gameTime)
		{
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
			float ProjectileLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);


			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			float maxhealth = float(ReturnEntityMaxHealth(npc.index));
			maxhealth *= 0.02;
			for (int DoSpawns = 0; DoSpawns < 2; DoSpawns++)
			{
				int spawn_index = NPC_CreateByName("npc_seaborn_vanguard", -1, ProjectileLoc, ang, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					CClotBody npc1 = view_as<CClotBody>(spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToNearest(maxhealth));
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", RoundToNearest(maxhealth));
					fl_Extra_Damage[spawn_index] *= 8.5;
					fl_Extra_Speed[spawn_index] *= 0.35;
					SetEntityRenderColor(npc1.index, 125, 0, 125, 255);
					SetEntityRenderColor(npc1.m_iWearable1, 125, 0, 125, 255);
					SetEntityRenderColor(npc1.m_iWearable2, 125, 0, 125, 255);
					SetEntityRenderColor(npc1.m_iWearable3, 125, 0, 125, 255);
					FormatEx(c_NpcName[npc1.index], sizeof(c_NpcName[]), "Voided Vanguard");
				}
			}
			npc.PlayMagicCastSound();
			
			TE_Particle("halloween_boss_summon", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			npc.m_flVoidMagicHappening = 0.0;
		}

		return true;
	}
			
	if(npc.m_flDoingAnimation < gameTime && npc.m_flVoidMagicCooldown < gameTime)
	{
		//This ability is ready, lets cast it.
		if(npc.m_iChanged_WalkCycle != 6)
		{
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 6;
			npc.SetActivity("ACT_ROGUE2_VOID_MAGIC");
			npc.StopPathing();
			
			npc.m_flSpeed = 0.0;
		}
		
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);

		npc.PlayMagicChargeSound();

		float flPos[3], flAng[3];
		npc.GetAttachment("LHand", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "unusual_genplasmos_b_glow1", npc.index, "LHand", {0.0,0.0,0.0});

		npc.m_flVoidMagicHappening = gameTime + 1.5;
		npc.m_flDoingAnimation = gameTime + 1.8;
		npc.m_flVoidMagicCooldown = gameTime + 30.0;
		return true;
	}

	return false;
}



public void VoidVhxisWin(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	//b_NpcHasDied[client]
	CPrintToChatAll("{purple}Vhxis: {default}Back to the void gate i go.");
}