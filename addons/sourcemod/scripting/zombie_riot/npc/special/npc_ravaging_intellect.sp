#pragma semicolon 1
#pragma newdecls required

static char g_HurtSounds[][] =
{
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
};

static char g_KillSounds[][] =
{
	"vo/scout_invinciblenotready03.mp3",
};

static const char g_IdleAlertedSounds[][] = 
{
	"vo/compmode/cm_scout_pregamefirst_comp_14.mp3",
	"vo/compmode/cm_scout_pregamefirst_comp_20.mp3",
	"vo/scout_domination17.mp3",
	"vo/scout_domination21.mp3",
	"vo/scout_dominationdem03.mp3",
	"vo/scout_misc05.mp3",
};

static const char g_MeleeHitSounds[][] = 
{
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};
static const char g_SpawnClonePerma[][] = 
{
	"weapons/teleporter_explode.wav",
};
static const char g_SpawnCloneTemp[][] = 
{
	"misc/halloween/spell_teleport.wav",
};
static const char g_MeleeAttackSounds[][] = 
{
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};
static const char g_PlayPrepareSpawnClonePerma[][] = 
{
	"vo/taunts/scout_taunts17.mp3",
};

static const char g_PlayTeleportAlly[][] = 
{
	"weapons/teleporter_send.wav",
};

#define RAVANGING_INTELLECT_PAINT 3 // 3 = Spectral Spectrum

static float MarkAreaForBuff[3];
static float MarkAreaForTeleport[3];
#define RAVAGING_INTELLECT_RANGE 200.0
static int NPCIDSAVE;
void RavagingIntellect_OnMapStart()
{
	
	for (int i = 0; i < (sizeof(g_HurtSounds));	   i++) { PrecacheSound(g_HurtSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_KillSounds));	   i++) { PrecacheSound(g_KillSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	   i++) { PrecacheSound(g_IdleAlertedSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	   i++) { PrecacheSound(g_MeleeHitSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	   i++) { PrecacheSound(g_MeleeAttackSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_SpawnClonePerma));	   i++) { PrecacheSound(g_SpawnClonePerma[i]);	   }
	for (int i = 0; i < (sizeof(g_SpawnCloneTemp));	   i++) { PrecacheSound(g_SpawnCloneTemp[i]);	   }
	for (int i = 0; i < (sizeof(g_PlayPrepareSpawnClonePerma));	   i++) { PrecacheSound(g_PlayPrepareSpawnClonePerma[i]);	   }
	for (int i = 0; i < (sizeof(g_PlayTeleportAlly));	   i++) { PrecacheSound(g_PlayTeleportAlly[i]);	   }

	//Mikusch insert cus yes
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ravaging Intellectual");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ravaging_intellectual");
	strcopy(data.Icon, sizeof(data.Icon), "mb_miku");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPCIDSAVE = NPC_Add(data);
	PrecacheSoundCustom("#zombiesurvival/ravaging_intellect.mp3");
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RavagingIntellect(vecPos, vecAng, team, data);
}

methodmap RavagingIntellect < CClotBody
{
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_KillSounds[GetRandomInt(0, sizeof(g_KillSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL);
	}

	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	public void DoEffectsSpawnClonePerma() 
	{
		EmitSoundToAll(g_SpawnClonePerma[GetRandomInt(0, sizeof(g_SpawnClonePerma) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
		EmitSoundToAll(g_SpawnCloneTemp[GetRandomInt(0, sizeof(g_SpawnCloneTemp) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	
		float VecSelfNpcabs[3]; GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		TE_Particle("teleported_blue", VecSelfNpcabs, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		spawnRing_Vectors(VecSelfNpcabs, 40.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 50, 50, 200, 150, 1, /*duration*/ 0.5, 5.0, 3.0, 1);	
		spawnRing_Vectors(VecSelfNpcabs, 40.0 * 2.0, 0.0, 0.0, 30.0, "materials/sprites/laserbeam.vmt", 50, 50, 200, 150, 1, /*duration*/ 0.5, 5.0, 3.0, 1);	
		spawnRing_Vectors(VecSelfNpcabs, 40.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 50, 50, 200, 150, 1, /*duration*/ 0.5, 5.0, 3.0, 1);	
	}
	public void DoEffectsSpawnCloneTemp() 
	{
		EmitSoundToAll(g_SpawnCloneTemp[GetRandomInt(0, sizeof(g_SpawnCloneTemp) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
	
		float VecSelfNpcabs[3]; GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		spawnRing_Vectors(VecSelfNpcabs, 40.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 125, 125, 100, 1, /*duration*/ 0.5, 2.0, 3.0, 1);	
		spawnRing_Vectors(VecSelfNpcabs, 40.0 * 2.0, 0.0, 0.0, 30.0, "materials/sprites/laserbeam.vmt", 125, 125, 125, 100, 1, /*duration*/ 0.5, 2.0, 3.0, 1);	
		spawnRing_Vectors(VecSelfNpcabs, 40.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 125, 125, 125, 100, 1, /*duration*/ 0.5, 2.0, 3.0, 1);	
	}
	public void PlaySoundPrepareSpawnAlly() 
	{
		EmitSoundToAll(g_PlayPrepareSpawnClonePerma[GetRandomInt(0, sizeof(g_PlayPrepareSpawnClonePerma) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	public void PlayTeleportAlly() 
	{
		EmitSoundToAll(g_PlayTeleportAlly[GetRandomInt(0, sizeof(g_PlayTeleportAlly) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
		EmitSoundToAll(g_PlayTeleportAlly[GetRandomInt(0, sizeof(g_PlayTeleportAlly) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
		EmitSoundToAll(g_PlayTeleportAlly[GetRandomInt(0, sizeof(g_PlayTeleportAlly) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	property float m_flSummonAllyEnd
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flTeleportCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flTeleportCooldownDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flSpawnClone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	property float m_flSpawnClonePrepare
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	
	property float m_flSpawnCloneUntillSelfDelete
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	
	public RavagingIntellect(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RavagingIntellect npc = view_as<RavagingIntellect>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", MinibossHealthScaling(40.0), ally));
		i_NpcWeight[npc.index] = 3;
		

		npc.m_iState = -1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_bThisNpcIsABoss = true;
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 5;
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/scout/mnc_mascot_hat.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/scout/scout_prep_shirt.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/scout/mnc_mascot_outfit.mdl");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();

		npc.StartPathing();
		
		// The spectral spectrum spell paint's team colors depend on the cosmetic's team
		int PaintWearable;
		PaintWearable = NpcColourCosmetic_ViaPaint(npc.m_iWearable2, RAVANGING_INTELLECT_PAINT, true);
		SetTeam(PaintWearable, 3);
		PaintWearable = NpcColourCosmetic_ViaPaint(npc.m_iWearable3, RAVANGING_INTELLECT_PAINT, true);
		SetTeam(PaintWearable, 3);
		PaintWearable = NpcColourCosmetic_ViaPaint(npc.m_iWearable4, RAVANGING_INTELLECT_PAINT, true);
		SetTeam(PaintWearable, 3);


		npc.m_flSpeed = 330.0;
		bool final = StrContains(data, "spawn_fake") != -1;
		bool final1 = StrContains(data, "spawn_temp_fake") != -1;
		if(!final && !final1)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/ravaging_intellect.mp3");
			music.Time = 59; //no loop usually 43 loop tho
			music.Volume = 1.8;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Champion 1x1x1x");
			strcopy(music.Artist, sizeof(music.Artist), "NyhtShroud");
			Music_SetRaidMusic(music);
			npc.m_iHealthBar = 1;
			MarkAreaForBuff[0] = 0.0;
			if(GetRandomInt(0,100) == 100)
			{
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: What is this, some type of rioting of Zombies?");
			}
			else
			{
				switch(GetRandomInt(0,4))
				{
					case 0:
					{
						CPrintToChatAll("{darkblue}Ravaging Intellect{default}: You're annoying.");
					}
					case 1:
					{
						CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Get out before I make you.");
					}
					case 2:
					{
						CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Blah blah blah I don't care.");
					}
					case 3:
					{
						CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Don't say hi.");
					}
					case 4:
					{
						CPrintToChatAll("{darkblue}Ravaging Intellect{default}: meow");
					}
				}
			}
			Ravaging_SaySpecialLine();
		
		}
		else
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 175, 100, 100, 125);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
			SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
			MakeObjectIntangeable(npc.index);
			b_DoNotUnStuck[npc.index] = true;
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_NoKillFeed[npc.index] = true;
			b_CantCollidie[npc.index] = true; 
			b_CantCollidieAlly[npc.index] = true; 
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
			npc.m_bThisNpcIsABoss = false;
			npc.m_flSpeed = 350.0;
			npc.Anger = true;
			if(final1)
			{
				npc.m_iHealthBar = 3;
				npc.m_flSpeed = 450.0;
				SetEntityRenderFx(npc.index,		 RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable2, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable3, RENDERFX_DISTORT);
				SetEntityRenderFx(npc.m_iWearable4, RENDERFX_DISTORT);
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 175, 175, 175, 90);
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt_neck_snap_scout");
				npc.SetPlaybackRate(1.0);
				npc.SetCycle(0.05);
				npc.m_flSpawnClonePrepare = GetGameTime() + 0.7;
				npc.m_flSpawnCloneUntillSelfDelete = GetGameTime() + 12.0;
			}
		}
		npc.m_flSpawnClone = GetGameTime() + 5.0;
		float flPos[3], flAng[3];
		RavagingIntellectEars(npc.index);
				
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {5.0,0.0,0.0});
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {5.0,0.0,-15.0});

		func_NPCDeath[npc.index] = view_as<Function>(RavagingIntellect_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(RavagingIntellect_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(RavagingIntellect_ClotThink);
		npc.m_flTeleportCooldown = GetGameTime() + 10.0;
	
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup"); 

		Citizen_MiniBossSpawn();
		return npc;
	}
}

public void RavagingIntellect_ClotThink(int iNPC)
{
	RavagingIntellect npc = view_as<RavagingIntellect>(iNPC);

	int AlphaDo = 255;
	if(b_NoKillFeed[npc.index])
	{
		AlphaDo = 175;
		if(npc.m_iHealthBar == 3)
		{
			AlphaDo = 95;
		}
	}
	
	SetEntityRenderColor(npc.index, 255, 255, 255, AlphaDo);
	if(IsValidEntity(npc.m_iWearable1))
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, AlphaDo);
	if(IsValidEntity(npc.m_iWearable2))
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, AlphaDo);
	if(IsValidEntity(npc.m_iWearable3))
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, AlphaDo);
	if(IsValidEntity(npc.m_iWearable4))
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, AlphaDo);

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
	if(npc.m_flSpawnCloneUntillSelfDelete)
	{
		if(npc.m_flSpawnCloneUntillSelfDelete < GetGameTime())
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(b_NoKillFeed[npc.index])
	{
		if(!IsValidAlly(npc.index,npc.m_iTargetAlly))
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
		else
		{
			RavagingIntellect npcoriginal = view_as<RavagingIntellect>(npc.m_iTargetAlly);
			npc.m_iTarget = npcoriginal.m_iTarget; //same target.
		}
	}
	if(npc.m_flSpawnClonePrepare)
	{
		
		if(npc.m_flSpawnClonePrepare < GetGameTime(npc.index))
		{
			npc.m_flSpawnClonePrepare = 0.0;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
			npc.m_bisWalking = true;
		}
		return;
	}
	if(npc.m_flTeleportCooldownDo)
	{
		
		if(npc.m_flTeleportCooldownDo < GetGameTime())
		{
			//teleport ALL allies!
			static float hullcheckmaxs[3];
			static float hullcheckmins[3];
			hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
			hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );
			float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
			TE_Particle("teleported_blue", VecSelfNpcabs, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			ExpidonsaGroupHeal(npc.index, RAVAGING_INTELLECT_RANGE, 10, 0.0, 1.0, true,RavagingIntellectTeleport);
			float vecTarget[3];
			vecTarget = MarkAreaForTeleport;
			Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, false, true, true);
			npc.m_flTeleportCooldownDo = 0.0;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
			npc.m_bisWalking = true;
		}
		return;
	}
	if(npc.m_flSummonAllyEnd)
	{
		if(npc.m_flSummonAllyEnd < GetGameTime())
		{
			ApplyStatusEffect(npc.index, npc.index, "Altered Functions", 99999.9);

			float vecPos_Npc[3];
			float vecAng_Npc[3];
			GetAbsOrigin(npc.index, vecPos_Npc);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAng_Npc);
			int fake_spawned = NPC_CreateByName("npc_ravaging_intellectual", -1, vecPos_Npc, vecAng_Npc,GetTeam(npc.index), "spawn_fake");
			RavagingIntellect npcally = view_as<RavagingIntellect>(fake_spawned);
			npcally.m_iTargetAlly = npc.index;
			npc.m_iTargetAlly = fake_spawned;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
			npc.m_bisWalking = true;
			npc.m_flSummonAllyEnd = 0.0;
			MarkAreaForBuff = vecPos_Npc;
			npc.DoEffectsSpawnClonePerma();
			npc.m_flTeleportCooldown = GetGameTime(npc.index) + 2.0; //allow teleporting
		}
		return;
	}
	if(!npc.m_iHealthBar && !npc.Anger)
	{
		npc.Anger = true;
		npc.m_flAttackHappens = 0.0;
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_commending_clap_scout");
		npc.SetCycle(0.7);
		npc.SetPlaybackRate(1.0);
		npc.m_flSummonAllyEnd = GetGameTime() + 1.0; //nos cale attackspeed
		fl_TotalArmor[npc.index] = 0.5;
		npc.PlaySoundPrepareSpawnAlly();
		return;
	}
	fl_TotalArmor[npc.index] = 1.0;
	if(HasSpecificBuff(npc.index, "Altered Functions"))
	{
		fl_TotalArmor[npc.index] *= 0.75;
	}
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(npc.m_iHealthBar != 3)
	{
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		RavagingIntellect_ApplyBuffInLocation(VecSelfNpcabs, GetTeam(npc.index), npc.index);
		float Range = RAVAGING_INTELLECT_RANGE;
		spawnRing_Vectors(VecSelfNpcabs, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 125, 50, 200, 1, /*duration*/ 0.11, 3.0, 5.0, 1);	
		if(MarkAreaForBuff[0] != 0.0 && !b_NoKillFeed[npc.index])
		{
			RavagingIntellect_ApplyBuffInLocation(MarkAreaForBuff, GetTeam(npc.index), 0);
			spawnRing_Vectors(MarkAreaForBuff, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 125, 50, 200, 1, /*duration*/ 0.11, 3.0, 5.0, 1);	
			
		}
	}

	npc.m_iTargetWalkTo = 0;
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTargetWalkTo = npc.m_iTarget;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(!b_NoKillFeed[npc.index] && npc.m_flSpawnClone < GetGameTime(npc.index))
		{
			float vecPos_Npc[3];
			float vecAng_Npc[3];
			GetAbsOrigin(npc.index, vecPos_Npc);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAng_Npc);
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
			int fake_spawned = NPC_CreateByName("npc_ravaging_intellectual", -1, vecPos_Npc, vecAng_Npc,GetTeam(npc.index), "spawn_temp_fake");
			RavagingIntellect npcally = view_as<RavagingIntellect>(fake_spawned);
			npcally.m_iTargetAlly = npc.index;
			npc.m_flSpawnClone = GetGameTime(npc.index) + 5.0;
			npc.DoEffectsSpawnCloneTemp();
		}
		RavagingIntellectSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	if(!b_NoKillFeed[npc.index])
	{
		if(IsValidEntity(npc.m_iTargetAlly) && npc.m_flTeleportCooldown < GetGameTime(npc.index))
		{
			int ClosestAlly;
			ClosestAlly = GetClosestAlly(npc.index, _, npc.m_iTargetAlly, RavagingIntellectual_DontSelfTarget);
			if(IsValidEntity(ClosestAlly))
			{
				float vecTarget[3]; WorldSpaceCenter(ClosestAlly, vecTarget );
			
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				if(flDistanceToTarget > (100.0 * 100.0))
				{
					npc.m_iTargetWalkTo = ClosestAlly;
				}
				else
				{
					//We are close enough!!
					if(IsValidEnemy(npc.index, npc.m_iTarget))
					{
						if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
						{
							static float hullcheckmaxs[3];
							static float hullcheckmins[3];
							hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
							hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );
							//account for giants!
							//randomly around the target.
							GetAbsOrigin(npc.m_iTarget, vecTarget);
							vecTarget[0] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
							vecTarget[1] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
							bool Succeed = Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, true, false);
							if(Succeed)
							{
								MarkAreaForTeleport = vecTarget;
								//save pos, do anims.
								//dont speed up anims
								npc.m_flTeleportCooldownDo = GetGameTime() + 1.5;
								npc.m_flTeleportCooldown = GetGameTime(npc.index) + 40.0;
								ExpidonsaGroupHeal(npc.index, RAVAGING_INTELLECT_RANGE, 10, 0.0, 1.0, false,RavagingIntellectStun);
								npc.m_flAttackHappens = 0.0;
								npc.StopPathing();
								
								npc.m_bisWalking = false;
								npc.AddActivityViaSequence("taunt_yeti");
								npc.SetCycle(0.696);
								npc.SetPlaybackRate(1.0);
								float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
								spawnRing_Vectors(VecSelfNpcabs, RAVAGING_INTELLECT_RANGE * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, /*duration*/ 1.5, 2.0, 2.0, 1);
								spawnRing_Vectors(VecSelfNpcabs, RAVAGING_INTELLECT_RANGE * 2.0, 0.0, 0.0, 30.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, /*duration*/ 1.5, 2.0, 2.0, 1);
								spawnRing_Vectors(VecSelfNpcabs, RAVAGING_INTELLECT_RANGE * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, /*duration*/ 1.5, 2.0, 2.0, 1, 1.0);

								
								spawnRing_Vectors(MarkAreaForTeleport, RAVAGING_INTELLECT_RANGE * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, /*duration*/ 1.5, 2.0, 2.0, 1);
								spawnRing_Vectors(MarkAreaForTeleport, RAVAGING_INTELLECT_RANGE * 2.0, 0.0, 0.0, 30.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, /*duration*/ 1.5, 2.0, 2.0, 1);
								spawnRing_Vectors(MarkAreaForTeleport, 1.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, /*duration*/ 1.5, 2.0, 2.0, 1, RAVAGING_INTELLECT_RANGE * 2.0);
								npc.PlayTeleportAlly();
							}
						}
					}
				}
			}
		}
	}
	if(IsValidEntity(npc.m_iTargetWalkTo))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
		}
	}
	npc.PlayIdleAlertSound();
}

public bool RavagingIntellectual_DontSelfTarget(int provider, int entity)
{
	if(i_NpcInternalId[entity] == NPCIDSAVE)
		return false;

	return true;
}
void RavagingIntellectStun(int entity, int victim, float &healingammount)
{
	if(entity == victim)
		return;

	ApplyStatusEffect(victim, victim, "UBERCHARGED", 1.5);
	FreezeNpcInTime(victim, 1.5, true);
}

void RavagingIntellectTeleport(int entity, int victim, float &healingammount)
{
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
	hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );
	float vecTarget[3];
	vecTarget = MarkAreaForTeleport;
	vecTarget[0] += GetRandomFloat(-RAVAGING_INTELLECT_RANGE,RAVAGING_INTELLECT_RANGE);
	vecTarget[1] += GetRandomFloat(-RAVAGING_INTELLECT_RANGE,RAVAGING_INTELLECT_RANGE);

	if(!Npc_Teleport_Safe(victim, vecTarget, hullcheckmins, hullcheckmaxs, false, true, true))
	{
		vecTarget = MarkAreaForTeleport;
		Npc_Teleport_Safe(victim, vecTarget, hullcheckmins, hullcheckmaxs, false, true, true);
	}
	float VecSelfNpcabs[3]; GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	TE_Particle("teleported_blue", VecSelfNpcabs, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	ApplyStatusEffect(entity, victim, "Defensive Backup", 4.5);
}


public void RavagingIntellect_NPCDeath(int entity)
{
	RavagingIntellect npc = view_as<RavagingIntellect>(entity);

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
	ExpidonsaRemoveEffects(entity);
	
	if(!b_NoKillFeed[npc.index])
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: This is getting on my nerves, i'm leaving.");
			}
			case 1:
			{
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Hope you'll have fun dealing with the aftermath.");
			}
			case 2:
			{
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Just because you can, doesn't mean you should.");
			}
			case 3:
			{
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: You're really good at pissing me off.");
			}
		}
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client) && !IsFakeClient(client))
			{
				SetMusicTimer(client, GetTime() + 1); //This is here beacuse of raid music.
				Music_Stop_All(client);
			}
		}
		npc.PlayDeathSound();
		RaidMusicSpecial1.Clear();
	}

	Citizen_MiniBossDeath(entity);
}

public Action RavagingIntellect_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	RavagingIntellect npc = view_as<RavagingIntellect>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

void RavagingIntellectSelfDefense(RavagingIntellect npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 80.0;
					damageDealt *= npc.m_flWaveScale;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 3.0;

					ApplyStatusEffect(npc.index, target, "Altered Functions", 2.5);


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);	

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
			if(npc.m_iHealthBar == 3)
			{
				npc.m_iTargetAlly = 0;
				//Delete self after 1 attack
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.5;
			}
		}
	}
}


void RavagingIntellect_ApplyBuffInLocation(float BannerPos[3], int Team, int iMe = 0)
{
	float targPos[3];
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) == Team)
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (RAVAGING_INTELLECT_RANGE * RAVAGING_INTELLECT_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Altered Functions", 1.0);
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == Team && iMe != ally)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (RAVAGING_INTELLECT_RANGE * RAVAGING_INTELLECT_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Altered Functions", 1.0);
			}
		}
	}
}


void RavagingIntellectEars(int iNpc, char[] attachment = "head")
{
	
	int red = 200;
	int green = 25;
	int blue = 200;
	float flPos[3];
	float flAng[3];
	int particle_ears1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	//fist ear
	int particle_ears2 = InfoTargetParentAt({0.0,-1.85,0.0}, "", 0.0); //First offset we go by
	int particle_ears3 = InfoTargetParentAt({0.0,-4.44,-3.7}, "", 0.0); //First offset we go by
	int particle_ears4 = InfoTargetParentAt({0.0,-5.9,2.2}, "", 0.0); //First offset we go by
	
	//fist ear
	int particle_ears2_r = InfoTargetParentAt({0.0,1.85,0.0}, "", 0.0); //First offset we go by
	int particle_ears3_r = InfoTargetParentAt({0.0,4.44,-3.7}, "", 0.0); //First offset we go by
	int particle_ears4_r = InfoTargetParentAt({0.0,5.9,2.2}, "", 0.0); //First offset we go by

	SetParent(particle_ears1, particle_ears2, "",_, true);
	SetParent(particle_ears1, particle_ears3, "",_, true);
	SetParent(particle_ears1, particle_ears4, "",_, true);
	SetParent(particle_ears1, particle_ears2_r, "",_, true);
	SetParent(particle_ears1, particle_ears3_r, "",_, true);
	SetParent(particle_ears1, particle_ears4_r, "",_, true);
	Custom_SDKCall_SetLocalOrigin(particle_ears1, flPos);
	SetEntPropVector(particle_ears1, Prop_Data, "m_angRotation", flAng); 
	SetParent(iNpc, particle_ears1, attachment,_);


	int Laser_ears_1 = ConnectWithBeamClient(particle_ears4, particle_ears2, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	int Laser_ears_2 = ConnectWithBeamClient(particle_ears4, particle_ears3, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);

	int Laser_ears_1_r = ConnectWithBeamClient(particle_ears4_r, particle_ears2_r, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	int Laser_ears_2_r = ConnectWithBeamClient(particle_ears4_r, particle_ears3_r, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][15] = EntIndexToEntRef(particle_ears1);
	i_ExpidonsaEnergyEffect[iNpc][16] = EntIndexToEntRef(particle_ears2);
	i_ExpidonsaEnergyEffect[iNpc][17] = EntIndexToEntRef(particle_ears3);
	i_ExpidonsaEnergyEffect[iNpc][18] = EntIndexToEntRef(particle_ears4);
	i_ExpidonsaEnergyEffect[iNpc][19] = EntIndexToEntRef(Laser_ears_1);
	i_ExpidonsaEnergyEffect[iNpc][20] = EntIndexToEntRef(Laser_ears_2);
	i_ExpidonsaEnergyEffect[iNpc][21] = EntIndexToEntRef(particle_ears2_r);
	i_ExpidonsaEnergyEffect[iNpc][22] = EntIndexToEntRef(particle_ears3_r);
	i_ExpidonsaEnergyEffect[iNpc][23] = EntIndexToEntRef(particle_ears4_r);
	i_ExpidonsaEnergyEffect[iNpc][24] = EntIndexToEntRef(Laser_ears_1_r);
	i_ExpidonsaEnergyEffect[iNpc][25] = EntIndexToEntRef(Laser_ears_2_r);
}


void Ravaging_SaySpecialLine()
{
	
	int victims;
	int[] victim = new int[MaxClients];
	

	for(int client = 1; client <= MaxClients; client++)
	{
		if(!b_IsPlayerABot[client] && IsClientInGame(client) && !IsFakeClient(client) && GetTeam(client) == 2)
		{
			static char buffer[96];
			GetClientName(client, buffer, sizeof(buffer));

			//i use names instead of id's so people can change their names and see these results.
			if(StrEqual(buffer, "Mikusch", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "42", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "literail", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "JuneOrJuly", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "wo", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "Batfoxkid", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "ficool2", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "riversid", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "eno", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "alex turtle", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "artvin", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "samuu, the cheesy slime", false))
			{
				victim[victims++] = client;
			}
			else if(StrEqual(buffer, "Black_Knight", false))
			{
				victim[victims++] = client;
			}
		}
	}
	if(victims)
	{
		int winner = victim[GetURandomInt() % victims];
		int client = winner;

		if(client)
		{
			static char buffer[96];
			GetClientName(client, buffer, sizeof(buffer));

			//i use names instead of id's so people can change their names and see these results.
			if(StrEqual(buffer, "Mikusch", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: ... Looks like {crimson}%N{default} thinks they can impersonate me, {crimson}i will kill you.",client);
			}
			else if(StrEqual(buffer, "42", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: ... Hey {crimson}%N{default} why are you against me, arent we supposed to be a team?",client);
			}
			else if(StrEqual(buffer, "literail", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Get back to work {crimson}%N{default} , cadets dont get stuff for free.",client);
			}
			else if(StrEqual(buffer, "JuneOrJuly", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Get back to work {crimson}%N{default} , cadets dont get stuff for free.",client);
			}
			else if(StrEqual(buffer, "wo", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: So about Bombermod {crimson}%N{default}...",client);
			}
			else if(StrEqual(buffer, "Batfoxkid", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: When will you finally be done with your scp rework {crimson}%N{default}?",client);
			}
			else if(StrEqual(buffer, "ficool2", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Aren't you supposed to be shilling vscript some more {crimson}%N{default}?",client);
			}
			else if(StrEqual(buffer, "riversid", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: I hope you keep it up {crimson}%N{default}, or else.",client);
			}
			else if(StrEqual(buffer, "eno", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: You did quite well so far {crimson}%N, but not well enough.{default}",client);
			}
			else if(StrEqual(buffer, "alex turtle", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Your szf heros are not here to save you {crimson}%N{default}.",client);
			}
			else if(StrEqual(buffer, "artvin", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: I will not say what you tell me to say {crimson}%N{default}.",client);
			}
			else if(StrEqual(buffer, "samuu, the cheesy slime", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: I vote {crimson}%N{default} for admin! (i dont know who you are)",client);
			}
			else if(StrEqual(buffer, "Black_Knight", false))
			{
				
				CPrintToChatAll("{darkblue}Ravaging Intellect{default}: Seems i have some hardware issues, can you help me out {crimson}%N{default} ?",client);
			}
		}
	}
	

}
