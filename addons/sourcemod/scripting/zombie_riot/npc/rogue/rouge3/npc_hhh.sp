#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/halloween_boss/knight_dying.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/halloween_boss/knight_alert01.mp3",
	"vo/halloween_boss/knight_alert02.mp3",
};

static const char g_BooSounds[][] = {
	"vo/halloween_boo1.mp3",
	"vo/halloween_boo2.mp3",
	"vo/halloween_boo3.mp3",
	"vo/halloween_boo4.mp3",
	"vo/halloween_boo5.mp3",
	"vo/halloween_boo6.mp3",
	"vo/halloween_boo7.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"vo/halloween_boss/knight_attack01.mp3",
	"vo/halloween_boss/knight_attack02.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_TeleSound[][] = {
	"misc/halloween/spell_teleport.wav",
};

static const char g_PreTeleSound[][] = {
	"ui/halloween_boss_chosen_it.wav",
};

static const char g_SpawnSounds[][] = {
	"ui/halloween_boss_summoned_fx.wav",
};

static const char g_PreGhostSounds[][] = {
	"misc/halloween/gotohell.wav",
};

static const char g_GhostSounds[][] = {
	"vo/halloween_moan1.mp3",
	"vo/halloween_moan2.mp3",
	"vo/halloween_moan3.mp3",
	"vo/halloween_moan4.mp3",
};

static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};

static float CustomMinMaxBoundingBoxDimensions[3] = { 42.0, 42.0, 82.0 }; // Same height as players but fatter

void HHH_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_BooSounds));		i++) { PrecacheSound(g_BooSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleSound)); i++) { PrecacheSound(g_TeleSound[i]); }
	for (int i = 0; i < (sizeof(g_PreTeleSound)); i++) { PrecacheSound(g_PreTeleSound[i]); }
	for (int i = 0; i < (sizeof(g_SpawnSounds)); i++) { PrecacheSound(g_SpawnSounds[i]); }
	for (int i = 0; i < (sizeof(g_PreGhostSounds)); i++) { PrecacheSound(g_PreGhostSounds[i]); }
	for (int i = 0; i < (sizeof(g_GhostSounds)); i++) { PrecacheSound(g_GhostSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Horseless Headless Horsemann");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_hhh");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/bots/headless_hatman.mdl");
	PrecacheModel("models/props_halloween/ghost_no_hat.mdl");
	
	PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl");
	PrecacheSound("#ui/holiday/gamestartup_halloween.mp3");
	
	PrecacheParticleSystem("ghost_appearation");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return HHH(vecPos, vecAng, team);
}
methodmap HHH < CClotBody
{
	property float m_flNextGhostMode
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flNextTeleport
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	property float m_flNextFuckingDEATH
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	property float m_flSpawnMessageTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	property bool m_bIsGhost
	{
		public get()							{ return b_Anger[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Anger[this.index] = TempValueForProperty; }
	}
	
	property bool m_bIsTeleporting
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	
	property bool m_bDoNotInterrupt
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
	}
	
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if (this.m_flNextFuckingDEATH || this.m_bIsGhost)
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		if (this.m_flNextFuckingDEATH || this.m_bIsGhost)
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlaySpawnSound() 
	{
		EmitSoundToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)]);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	public void PlayTeleSound() 
	{
		EmitSoundToAll(g_TeleSound[GetRandomInt(0, sizeof(g_TeleSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBooSound() 
	{
		EmitSoundToAll(g_BooSounds[GetRandomInt(0, sizeof(g_BooSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPreGhostSound() 
	{
		EmitSoundToAll(g_PreGhostSounds[GetRandomInt(0, sizeof(g_PreGhostSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGhostSound() 
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PreGhostSounds[0]);
		EmitSoundToAll(g_GhostSounds[GetRandomInt(0, sizeof(g_GhostSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 75);
	}
	public void FixCollisionBox()
	{
		// Collision boxes change on model change! But we need the actual models to do animations!
		// Revert collision box on each model change.
		// The globals will already have the right values so we don't need to change everything.
		
		float vecMins[3], vecMaxs[3];
		vecMaxs = CustomMinMaxBoundingBoxDimensions;
		vecMins[0] = -CustomMinMaxBoundingBoxDimensions[0];
		vecMins[1] = -CustomMinMaxBoundingBoxDimensions[1];
		
		CBaseNPC baseNPC = view_as<CClotBody>(this).GetBaseNPC();
		
		baseNPC.SetBodyMaxs(vecMaxs);
		baseNPC.SetBodyMins(vecMins);
		
		SetEntPropVector(this.index, Prop_Data, "m_vecMaxs", vecMaxs);
		SetEntPropVector(this.index, Prop_Data, "m_vecMins", vecMins);
		
		//Fixed wierd clientside issue or something
		float vecMaxsNothing[3], vecMinsNothing[3];
		vecMaxsNothing = view_as<float>( { 1.0, 1.0, 2.0 } );
		vecMinsNothing = view_as<float>( { -1.0, -1.0, 0.0 } );		
		SetEntPropVector(this.index, Prop_Send, "m_vecMaxsPreScaled", vecMaxsNothing);
		SetEntPropVector(this.index, Prop_Data, "m_vecMaxsPreScaled", vecMaxsNothing);
		SetEntPropVector(this.index, Prop_Send, "m_vecMinsPreScaled", vecMinsNothing);
		SetEntPropVector(this.index, Prop_Data, "m_vecMinsPreScaled", vecMinsNothing);
	}
	
	public HHH(float vecPos[3], float vecAng[3], int ally)
	{
		HHH npc = view_as<HHH>(CClotBody(vecPos, vecAng, "models/bots/headless_hatman.mdl", "1.0", "5000", ally, .isGiant = true, .CustomThreeDimensions = CustomMinMaxBoundingBoxDimensions)); // Not resized, but needs to be giant because he's tall
		float gameTime = GetGameTime(npc.index);
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_TANK;

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = gameTime + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}
		func_NPCDeath[npc.index] = view_as<Function>(HHH_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(HHH_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(HHH_ClotThink);

		//HHH Music (STRAIGHT-..eh, well I wouldn't say bangin but the song is good.)
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#ui/holiday/gamestartup_halloween.mp3");
		music.Time = 81; //no loop usually 43 loop tho
		music.Volume = 1.25;
		music.Custom = false;
		strcopy(music.Name, sizeof(music.Name), "{redsunsecond}Haunted Fortress 2");
		strcopy(music.Artist, sizeof(music.Artist), "{redsunsecond}Mike Morasky");
		Music_SetRaidMusic(music);
		
		npc.m_bIsGhost = false;
		npc.m_bIsTeleporting = false;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flSpawnMessageTime = gameTime + 0.5;
		npc.m_flNextTeleport = gameTime + 5.0; //Teleport Prepare
		npc.m_flNextGhostMode = gameTime + 10.0; //Ghost Form
		
		KillFeed_SetKillIcon(npc.index, "headtaker");
		
		npc.m_bGib = true; // always gib
		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_bigaxe/c_bigaxe.mdl");
		
		int color[4] = { 155, 0, 155, 50 };
		SetCustomFog(FogType_NPC, color, color, 400.0, 100.0, 0.9);
		
		npc.PlaySpawnSound();
		
		return npc;
	}
}

public void HHH_ClotThink(int iNPC)
{
	HHH npc = view_as<HHH>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	// die
	if (npc.m_flNextFuckingDEATH)
	{
		if (npc.m_flNextFuckingDEATH < gameTime)
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		
		return;
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if (npc.m_flSpawnMessageTime && npc.m_flSpawnMessageTime < gameTime)
	{
		npc.m_flSpawnMessageTime = 0.0;
		VSHJokeSpawnMessage(npc.index, "Horseless Headless Horsemann");
	}
	
	// Prepare for Teleport
	if (!npc.m_bIsGhost && !npc.m_bDoNotInterrupt && npc.m_flNextTeleport < gameTime)
	{
		switch (npc.m_iChanged_WalkCycle)
		{
			case 0:
			{
				EmitSoundToAll("ui/halloween_boss_chosen_it.wav");
				npc.StopPathing();
				npc.SetActivity("ACT_MP_CROUCH_ITEM1");
				
				npc.m_flNextTeleport = gameTime + 0.9;
				npc.m_bIsTeleporting = true;
				npc.m_iChanged_WalkCycle = 1;
			}
			
			case 1:
			{
				for (int client = 1; client <= MaxClients; client++)
				{
					// Blink!
					if (IsClientInGame(client) && !IsFakeClient(client))
						UTIL_ScreenFade(client, 66, 333, FFADE_OUT, 0, 0, 0, 255);
				}
				
				npc.m_flNextTeleport = gameTime + 0.25;
				npc.m_iChanged_WalkCycle = 2;
			}
			
			case 2:
			{
				for (int client = 1; client <= MaxClients; client++)
				{
					// Stop blinking
					if (IsClientInGame(client) && !IsFakeClient(client))
						UTIL_ScreenFade(client, 66, 1, FFADE_IN | FFADE_PURGE, 0, 0, 0, 255);
				}
				
				// Teleport EVERYTHING
				for (int entitycount = 1; entitycount < MAXENTITIES; entitycount++)
				{
					bool teleported;
					if (IsValidEnemy(npc.index, entitycount)) //Check for players
					{
						teleported = true;
						TeleportDiversioToRandLocation(entitycount,_,1750.0, 1250.0);
					}
					else if (IsValidAlly(npc.index, entitycount)) //Check for NPCs
					{
						teleported = true;
						TeleportDiversioToRandLocation(entitycount,_,1750.0, 1250.0);
					}
					
					if (teleported && entitycount <= MaxClients)
						EmitSoundToClient(entitycount, "misc/halloween/spell_teleport.wav");
				}
				npc.PlayTeleSound();
				
				npc.StartPathing();
				npc.SetActivity("ACT_MP_RUN_ITEM1");
				
				npc.m_flNextTeleport = gameTime + 15.0;
				npc.m_bIsTeleporting = false;
				npc.m_iChanged_WalkCycle = 0;
				
				// buffer next ghost time if it'll happen very soon
				npc.m_flNextGhostMode = fmax(npc.m_flNextGhostMode, gameTime + 4.0);
			}
		}
		
		return;
	}
	
	if (npc.m_bIsTeleporting)
		return;
	
	// Ghost Mode
	if (npc.m_flNextGhostMode < gameTime)
	{
		switch (npc.m_iChanged_WalkCycle)
		{
			case 0:
			{
				npc.PlayPreGhostSound();
				npc.AddGesture("ACT_MP_GESTURE_VC_HANDMOUTH_ITEM1", .SetGestureSpeed = 0.2);
				
				npc.m_flNextMeleeAttack = FAR_FUTURE; //Never attacks with "axe"
				npc.m_bDoNotInterrupt = true;
				npc.m_flNextGhostMode = gameTime + 2.1;
				npc.m_iChanged_WalkCycle = 1;
			}
			
			case 1:
			{
				// Just became a ghost, set up
				npc.SetActivity("ACT_MP_RUN_MELEE"); // change activity before changing model so it updates when we set it back
				npc.PlayBooSound();
				npc.PlayGhostSound();
				KillFeed_SetKillIcon(npc.index, "purgatory");
				
				float vecPos[3];
				GetAbsOrigin(npc.index, vecPos);
				ParticleEffectAt(vecPos, "ghost_appearation");
				
				b_NpcUnableToDie[npc.index] = true; //You can't kill a ghost
				SetEntityCollisionGroup(npc.index, 1); //Makes projectiles (and bullets?) go through him
				AcceptEntityInput(npc.m_iWearable1, "Disable"); //Disables Axe
				SetEntityModel(npc.index, "models/props_halloween/ghost_no_hat.mdl"); //Sets model to ghost
				
				npc.m_flSpeed = 200.0;
				npc.m_bIsGhost = true;
				npc.m_flNextGhostMode = gameTime + 8.0; // ghost duration
				
				npc.FixCollisionBox();
				npc.m_iChanged_WalkCycle = 2;
			}
			
			case 2:
			{
				// Just stopped being a ghost, revert
				KillFeed_SetKillIcon(npc.index, "headtaker");
				
				float vecPos[3];
				GetAbsOrigin(npc.index, vecPos);
				ParticleEffectAt(vecPos, "ghost_appearation");
				
				b_NpcUnableToDie[npc.index] = false; //You can kill a pumpkin though
				SetEntityCollisionGroup(npc.index, 0); //Set collision back to normal
				npc.m_flNextMeleeAttack = gameTime + 1.0; //Restore attack cooldown to normal
				AcceptEntityInput(npc.m_iWearable1, "Enable"); //Enables Axe
				SetEntityModel(npc.index, "models/bots/headless_hatman.mdl"); //Set model back to pumpkin man
				npc.SetActivity("ACT_MP_RUN_ITEM1");
				
				for (int entity = 1; entity < MAXENTITIES; entity++)
				{
					if (IsValidEntity(i_LaserEntityIndex[entity]))
						RemoveEntity(i_LaserEntityIndex[entity]);
				}
				
				npc.m_flSpeed = 300.0;
				npc.m_bIsGhost = false;
				npc.m_bDoNotInterrupt = false;
				npc.m_flNextGhostMode = gameTime + 33.0;
				
				// buffer next teleport time if it'll happen very soon
				npc.m_flNextTeleport = fmax(npc.m_flNextTeleport, gameTime + 4.0);
				
				npc.FixCollisionBox();
				npc.m_iChanged_WalkCycle = 0;
			}
		}
	}
	else if (npc.m_bIsGhost)
	{
		float vecPos[3], vecAbs[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecPos);
		GetAbsOrigin(npc.index, vecAbs);
		
		spawnRing_Vectors(vecAbs, 300.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 0, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1); //Purple ring
		for (int entity = 1; entity < MAXENTITIES; entity++)
		{
			if(IsValidEnemy(npc.index, entity))
			{
				WorldSpaceCenter(entity, vecTarget);
				
				float Distance = GetVectorDistance(vecPos, vecTarget, true);
				if(Distance <= (300.0 * 300.0))
				{
					//Apply laser if someone is near
					if(IsValidClient(entity) && Can_I_See_Enemy_Only(npc.index, entity) && IsEntityAlive(entity))
					{
						int red = 200;
						int green = 0;
						int blue = 255;
						if(!IsValidEntity(i_LaserEntityIndex[entity]))
						{
							int laser;

							laser = ConnectWithBeam(npc.index, entity, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);

							i_LaserEntityIndex[entity] = EntIndexToEntRef(laser);
							//New target, relocate laser
						}
						else
						{
							int laser = EntRefToEntIndex(i_LaserEntityIndex[entity]);
							SetEntityRenderColor(laser, red, green, blue, 255);
						}
						
						SDKHooks_TakeDamage(entity, npc.index, npc.index, 250.0, DMG_TRUEDAMAGE | DMG_PREVENT_PHYSICS_FORCE); //How much HHH deals with his succ
						HealEntityGlobal(npc.index, npc.index, 1000.0, 1.50, 0.0, HEAL_SELFHEAL); ///How much HHH heals
						
						// succ (clients only) - code stolen from vsh rewrite but it's ok, I'm literally stealing from myself
						float vecPullVelocity[3];
						MakeVectorFromPoints(vecTarget, vecPos, vecPullVelocity);
						
						// We don't want players to helplessly hover slightly above ground if the boss is above them, so we don't modify their vertical velocity
						vecPullVelocity[2] = 0.0;
						
						NormalizeVector(vecPullVelocity, vecPullVelocity);
						ScaleVector(vecPullVelocity, 60.0);
						
						// Consider their current velocity
						float vecTargetVelocity[3];
						GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vecTargetVelocity);
						AddVectors(vecTargetVelocity, vecPullVelocity, vecPullVelocity);
						
						TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecPullVelocity);
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[entity]))
							RemoveEntity(i_LaserEntityIndex[entity]);
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[entity]))
						RemoveEntity(i_LaserEntityIndex[entity]);
				}
			}
			else
			{
				if(IsValidEntity(i_LaserEntityIndex[entity]))
					RemoveEntity(i_LaserEntityIndex[entity]);						
			}
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
		HHHSelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action HHH_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	HHH npc = view_as<HHH>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (!npc.m_bIsGhost && RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		if (!npc.m_flNextFuckingDEATH)
		{
			npc.StopPathing();
			npc.PlayDeathSound();
			npc.m_flNextFuckingDEATH = GetGameTime(npc.index) + 2.0;
			npc.AddGesture("ACT_DIESIMPLE");
		}
		
		damage = 0.0;
		return Plugin_Changed;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void HHH_NPCDeath(int entity)
{
	HHH npc = view_as<HHH>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	//Remove fog on death
	ClearCustomFog(FogType_NPC);

	//Remove laser on death
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}				
	}
		
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void HHHSelfDefense(HHH npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			//Extra Range
			static float MaxVec[3] = {256.0, 256.0, 256.0};
			static float MinVec[3] = {-256.0, -256.0, -256.0};
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec))
			{
				target = TR_GetEntityIndex(swingTrace);	

				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 2500.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;	
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);	
					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}

void VSHJokeSpawnMessage(int iNPC, const char[] boss)
{
	char message[128], prettyHealth[32];
	int health = ReturnEntityMaxHealth(iNPC);
	IntToString(health, prettyHealth, sizeof(prettyHealth));
	ThousandString(prettyHealth, sizeof(prettyHealth));
	FormatEx(message, sizeof(message), "%s has spawned as %s with %s health!", c_NpcName[iNPC], boss, prettyHealth);
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
			ShowGameText(client, "leaderboard_streak", 0, message);
	}
}