#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
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


static int NPCId;

void VhxisFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vhxis");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vhxis_follower");
	strcopy(data.Icon, sizeof(data.Icon), "void_vhxis");
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_VoidLaserPulseAttack)); i++) { PrecacheSound(g_VoidLaserPulseAttack[i]); }
	for (int i = 0; i < (sizeof(g_VoidLaserPulseAttackInit)); i++) { PrecacheSound(g_VoidLaserPulseAttackInit[i]); }

	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int VhxisFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VhxisFollower(vecPos, vecAng, team);
}

static Action VhxisFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<VhxisFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap VhxisFollower < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.3);
	}
	public void PlayVoidLaserSound() 
	{
		EmitSoundToAll(g_VoidLaserPulseAttack[GetRandomInt(0, sizeof(g_VoidLaserPulseAttack) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayVoidLaserSoundInit() 
	{
		EmitSoundToAll(g_VoidLaserPulseAttackInit[GetRandomInt(0, sizeof(g_VoidLaserPulseAttackInit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
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
	public void SpeechTalk(int client)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 9)
		{
			case 0:
			{
				this.Speech("So I'm yet again met face to face with the mercenaries powered by greed.");
				this.SpeechDelay(5.0, "This'll be your chance to redeem yourselves.");
			}
			case 1:
			{
				this.Speech("I don't hold grudges.");
				this.SpeechDelay(5.0, "Though if you didn't attack me, we wouldn't be in this mess right now.");
			}
			case 2:
			{
				this.Speech("Twirl huh...");
				this.SpeechDelay(5.0,"There's a reason I have this headset on, alright.");
			}
			case 3:
			{
				this.Speech("Omega is a surprisingly loyal guy, despite his military records.");
			}
			case 4:
			{
				this.Speech("You ever tried to harness the void?");
				this.SpeechDelay(5.0,"You're not ready for what awaits you.");
			}
			case 5:
			{
				this.Speech("Chaos doesn't scare me.");
			}
			case 6:
			{
				this.Speech("You know what really grinds my gears?");
				this.SpeechDelay(5.0,"People who talk too much.");
			}
			case 7:
			{
				this.Speech("With how vile Unspeakable looks, I'm surprised it's not called Abomination instead.");
			}
			case 8:
			{
				this.Speech("I miss my Void Ixufans.");
			}
			case 9:
			{
				this.Speech("Too many people try to make a name for themselves, just act like yourself.");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, VhxisFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,120.0}, endingtextscroll);
	}
	property float m_flDeathAnimation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flDeathAnimationCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flCheckItemDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	
	
	public VhxisFollower(float vecPos[3], float vecAng[3],int ally)
	{
		VhxisFollower npc = view_as<VhxisFollower>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.5", "50000", ally, true, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_ROGUE2_VOID_WALK");
		KillFeed_SetKillIcon(npc.index, "sword");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flDeathAnimation = 0.0;
		npc.m_bScalesWithWaves = true;
		npc.m_flVoidLaserPulseCooldown = GetGameTime() + 10.0;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "blue_goggles");
		
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

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	VhxisFollower npc = view_as<VhxisFollower>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(VoidFollowerVhxis_LaserPulseAttack(npc, GetGameTime(npc.index)))
	{
		return;
	}

	int target = npc.m_iTarget;
	int ally = npc.m_iTargetWalkTo;

	if(npc.m_flCheckItemDo <  gameTime)
	{
		npc.m_flCheckItemDo = gameTime + 5.0;
		if(!npc.Anger)
		{
			if(Rogue_HasNamedArtifact("Bob's Wrath"))
			{
				f_AttackSpeedNpcIncrease[npc.index] *= 0.75;
				npc.Anger = true;
				npc.m_flCheckItemDo = FAR_FUTURE;
			}
		}
	}

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, _, 99999.9);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		ally = GetClosestAllyPlayer(npc.index);
		npc.m_iTargetWalkTo = ally;
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}
		if(npc.m_flAttackHappens)
		{
			npc.StopPathing();
		}
		else
		{
			npc.StartPathing();
		}
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target,_,_,_,2))
				{
					target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float damage = 5500.0;
						if(npc.m_bScalesWithWaves)
						{
							damage = 150.0;
						}
						if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
					}
				}

				delete swingTrace;
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_ROGUE2_VOID_ATTACK1");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 1.50;
			}
		}

		npc.SetActivity("ACT_ROGUE2_VOID_WALK");
	}
	else
	{
		if(ally > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

			if(flDistanceToTarget > 25000.0)
			{
				npc.SetGoalEntity(ally);
				npc.StartPathing();
				npc.SetActivity("ACT_ROGUE2_VOID_WALK");
				return;
			}
		}

		npc.StopPathing();
		npc.SetActivity("ACT_CUSTOM_IDLE_SAMURAI_CALM");

		if(target < 1)
			npc.SpeechTalk(ally);
	}
}

static void ClotDeath(int entity)
{
	VhxisFollower npc = view_as<VhxisFollower>(entity);

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
	
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}

static int LastEnemyTargeted[MAXENTITIES];
//This summons the creep, and several enemies on his side!
public void VoidFollowerVhxis_LaserPulseAttack(VhxisFollower npc, float gameTime)
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
				VoidFollowerVhxisInitiateLaserAttack(npc.index, VecEnemy, flPos);
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("LHand"), PATTACH_POINT_FOLLOW, true);
				npc.PlayVoidLaserSound();
				npc.AddGesture("ACT_ROGUE2_VOID_PULSEATTACK_GESTURE");
			}
		}
		if(npc.m_flVoidLaserPulseHappening < gameTime)
		{
			npc.StartPathing();
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
			npc.m_flVoidLaserPulseHappening = 0.0;
		}
		//return true;
	}
	if(npc.m_flDoingAnimation < gameTime && npc.m_flVoidLaserPulseCooldown < gameTime)
	{
		//theres no valid enemy, dont cast.
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			//return false;
		}
		//cant even see one enemy
		if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			//return false;
		}
		//This ability is ready, lets cast it.
		if(npc.m_iChanged_WalkCycle != 4)
		{
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			//npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_ROGUE2_VOID_STAND_PULSEATTACK");
			npc.StopPathing();
			//npc.m_flSpeed = 0.0;
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
		//return true;
	}
	//return false;
}
void VoidFollowerVhxisInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{
	float vecForward[3], vecRight[3], Angles[3];
	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);
	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, VoidFollowerVhxis_TraceWallsOnly);
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
	RequestFrames(VoidFollowerVhxisInitiateLaserAttack_DamagePart, 25, pack);
}
void VoidFollowerVhxisInitiateLaserAttack_DamagePart(DataPack pack)
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
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, VoidFollowerVhxis_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	Vhxis npc = view_as<Vhxis>(entity);
	npc.PlayVoidLaserSoundInit();
	float CloseDamage = 45.0;
	float FarDamage = 40.0;
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
		}
	}
	delete pack;
}
public bool VoidFollowerVhxis_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}
public bool VoidFollowerVhxis_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}