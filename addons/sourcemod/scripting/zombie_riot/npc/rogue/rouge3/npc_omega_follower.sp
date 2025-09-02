#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] = {
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard2.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard4.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/vort/claw_swing1.wav",
	"npc/vort/claw_swing2.wav",
};

static const char g_PickupSounds[][] = {
	"items/gunpickup2.wav"
};

static const char g_ThrowSounds[][] =  {
	"weapons/cleaver_throw.wav"
};

enum
{
	OMEGA_FOLLOWER_GRAB_STATE_NONE,
	OMEGA_FOLLOWER_GRAB_STATE_HOLDING,
	OMEGA_FOLLOWER_GRAB_STATE_TARGET_MISSING,
	OMEGA_FOLLOWER_GRAB_STATE_JUST_THREW
}

#define OMEGA_FOLLOWER_MAX_RANGE 300.0
#define OMEGA_FOLLOWER_HOLD_TIME 1.5

static int NPCId;

void OmegaFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Omega");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_omega_follower");
	strcopy(data.Icon, sizeof(data.Icon), "");

	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_PickupSounds)); i++) { PrecacheSound(g_PickupSounds[i]); }
	for (int i = 0; i < (sizeof(g_ThrowSounds)); i++) { PrecacheSound(g_ThrowSounds[i]); }
}

stock int OmegaFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return OmegaFollower(vecPos, vecAng, team);
}

static Action OmegaFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<OmegaFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap OmegaFollower < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.3);
	}
	public void PlayPickupSound()
	{
		EmitSoundToAll(g_PickupSounds[GetRandomInt(0, sizeof(g_PickupSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayThrowSound()
	{
		EmitSoundToAll(g_ThrowSounds[GetRandomInt(0, sizeof(g_ThrowSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void SpeechTalk(int client)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 21)
		{
			case 0:
			{
				this.Speech("You'd think that things would one day go back to being normal.");
				this.SpeechDelay(5.0, "Hooo boy, what a wild dream to have.");
			}
			case 1:
			{
				this.Speech("No matter how many people you think you've went up against...");
				this.SpeechDelay(7.0, "There will always be a new, stronger foe that you've never encountered in your life before.");
			}
			case 2:
			{
				this.Speech("Do you think there's something that comes after death?");
				this.SpeechDelay(5.0,"I've heard rumors about this...skeleton.");
				this.SpeechDelay(10.0,"I suppose I shall get my answer once my own time comes.");
				this.SpeechDelay(15.0,"That time sure as hell ain't coming soon though.");
			}
			case 3:
			{
				this.Speech("There are no good guys.");
				this.SpeechDelay(5.0,"Just people who happen to be on the right side of the story.");
			}
			case 4:
			{
				this.Speech("It's a good thing Bob stopped me before I destroyed you guys.");
				this.SpeechDelay(5.0,"Huh, what do you mean we've never met before?");
				this.SpeechDelay(10.0,"Giant prison, a lot of Whiteflower goons?");
				this.SpeechDelay(15.0,"I must have fought a different group, then.");
				this.SpeechDelay(20.0,"Still, they looked eerily similar to you.");
			}
			case 5:
			{
				this.Speech("Mazeat...home.");
				this.SpeechDelay(5.0,"Well, it was home before everything went to shit.");
			}
			case 6:
			{
				this.Speech("It is not easy to gain Bob's trust, especially after that traitorous Whiteflower son of a-");
				this.SpeechDelay(7.0,"Got a bit carried away there.");
			}
			case 7:
			{
				this.Speech("I've never given it this much thought before, why do I even indulge in these fights?");
				this.SpeechDelay(7.0,"Maybe it's for the death-defying scenarios. Maybe it's for the adrenaline.");
				this.SpeechDelay(12.0,"Or maybe, it's just to be a show-off.");
			}
			case 8:
			{
				this.Speech("So...why'd you attack Vhxis?");
				this.SpeechDelay(5.0,"You've brought this shitstorm upon all of us by doing so, you're lucky you've got so many great friends.");
			}
			case 9:
			{
				this.Speech("I'm waiting for all of this to blow over so I can go back to uh...");
				this.SpeechDelay(5.0, "Huh...what did I even do before all of this chaos nonsense?");
			}
			case 10:
			{
				this.Speech("With our current circumstances, I recommend sleeping with an open eye.");
				this.SpeechDelay(5.0, "It's quite good for your psyche.");
			}
			case 11:
			{
				this.Speech("All of these people talking about how they love beer so much.");
				this.SpeechDelay(7.0, "And yet they don't have the courage to get shitfaced with me.");
				this.SpeechDelay(12.0, "Cowards.");
			}
			case 12:
			{
				this.Speech("You know that Gambler guy at Bladedance's casino?");
				this.SpeechDelay(5.0, "I let him borrow my trusty RPG sometimes, not exactly sure what he needs it for.");
			}
			case 13:
			{
				this.Speech("All these deaths, viruses, and wars, and yet...");
				this.SpeechDelay(5.0, "There's still people desperate enough to fantasize about Twirl.");
				this.SpeechDelay(10.0, "Some things just never die, huh?");
			}
			case 14:
			{
				this.Speech("You ever went up against a trio?");
				this.SpeechDelay(5.0, "Sounds rough, but with enough preparation, anything is possible.");
			}
			case 15:
			{
				this.Speech("Expidonsa is not as innocent as it seems, but then again that goes for any race, fair's fair.");
			}
			case 16:
			{
				this.Speech("Sometimes I like to listen to music and pretend that the people I'm fighting are hearing that exact same music as well.");
				this.SpeechDelay(5.0, "Can you imagine how sick that would be?");
			}
			case 17:
			{
				this.Speech("You seen those Omega symbols all over the place?");
				this.SpeechDelay(5.0, "No problem.");
			}
			case 18:
			{
				this.Speech("It's pretty impressive how a bald guy is able to own so many good wares.");
				this.SpeechDelay(5.0, "Pricey though.");
			}
			case 19:
			{
				this.Speech("Considering that the Void is a thing...");
				this.SpeechDelay(5.0, "Have you ever wondered what else might be out there?");
				this.SpeechDelay(10.0, "Things way beyond our comprehension.");
			}
			case 20:
			{
				this.Speech("I sleep peacefully at night, knowing that Whiteflower will never be seen again.");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, OmegaFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,100.0}, endingtextscroll);
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
	property float m_flNextGrab
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property int m_iGrabState
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	property int m_iThrowType
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property bool m_bAlternatingPunch
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
	}
	
	public OmegaFollower(float vecPos[3], float vecAng[3],int ally)
	{
		OmegaFollower npc = view_as<OmegaFollower>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "50000", ally, true, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_BRAWLER_RUN");
		KillFeed_SetKillIcon(npc.index, "fists");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flNextGrab = GetGameTime(npc.index) + 10.0;
		npc.m_iGrabState = OMEGA_FOLLOWER_GRAB_STATE_NONE;
		
		npc.m_flSpeed = 310.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;
		npc.m_flDeathAnimation = 0.0;
		npc.m_bScalesWithWaves = true;
		
		i_GrabbedThis[npc.index] = INVALID_ENT_REFERENCE;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "blue_goggles");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/combine_super_soldier.mdl");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/sniper/jarate_headband.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 30.0;

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	OmegaFollower npc = view_as<OmegaFollower>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	switch (npc.m_iGrabState)
	{
		case OMEGA_FOLLOWER_GRAB_STATE_HOLDING:
		{
			OmegaFollower_AdjustGrabbedTarget(npc.index);
			
			if (npc.m_flNextGrab < gameTime)
			{
				OmegaFollower_ThrowTarget(npc);
				return;
			}
			
			int grabbee = EntRefToEntIndex(i_GrabbedThis[npc.index]);
			if (!IsValidEntity(grabbee) || !IsValidEnemy(npc.index, grabbee))
			{
				npc.m_iGrabState = OMEGA_FOLLOWER_GRAB_STATE_TARGET_MISSING;
				npc.m_flNextGrab = GetGameTime(npc.index) + 0.5;
				return;
			}
			
			float vecPos[3];
			WorldSpaceCenter(npc.index, vecPos);
			vecPos[2] -= 30.0;
			
			int candidate = GetClosestTarget(npc.index, true, .CanSee = true, .ExtraValidityFunction = OmegaFollower_ClosestValidTarget);
			if (candidate < 0)
				return;
			
			float vecTargetPos[3];
			WorldSpaceCenter(candidate, vecTargetPos);
			npc.FaceTowards(vecTargetPos, 20000.0);
			
			npc.m_flGetClosestTargetTime = gameTime + 0.3;
			
			f3_NpcSavePos[npc.index] = vecTargetPos;
			
			return;
		}
		
		case OMEGA_FOLLOWER_GRAB_STATE_JUST_THREW, OMEGA_FOLLOWER_GRAB_STATE_TARGET_MISSING:
		{
			if (npc.m_flNextGrab < gameTime)
			{
				npc.m_flNextGrab = gameTime + 35.0;
				npc.m_iGrabState = OMEGA_FOLLOWER_GRAB_STATE_NONE;
				
				int activity = npc.LookupActivity("ACT_BRAWLER_RUN");
				if (activity > 0)
					npc.StartActivity(activity);
				
				npc.SetPlaybackRate(1.0);
				
				npc.StartPathing();
				npc.m_bisWalking = true;
				
				npc.m_flSpeed = 310.0;
			}
			
			return;
		}
	}
	
	float vecTarget2[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget2);
	int target = npc.m_iTarget;
	int ally = npc.m_iTargetWalkTo;
	
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
						npc.m_iOverlordComboAttack++;
						float damage = 5500.0;
						if(npc.m_bScalesWithWaves)
						{
							damage = 50.0;
						}
						if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
						IncreaseEntityDamageTakenBy(target, 0.02, 3.0, true);

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
				if (!OmegaFollower_TryToGrabTarget(npc, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 1.0;
					
					npc.AddGesture(npc.m_bAlternatingPunch ? "ACT_BRAWLER_ATTACK_LEFT" : "ACT_BRAWLER_ATTACK_RIGHT");
					npc.m_bAlternatingPunch = !npc.m_bAlternatingPunch;
					
					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.15;
					npc.m_flNextMeleeAttack = gameTime + 0.25;
				}
			}
		}

		npc.SetActivity("ACT_BRAWLER_RUN");
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
				npc.SetActivity("ACT_BRAWLER_RUN");
				return;
			}
		}

		npc.StopPathing();
		npc.SetActivity("ACT_IDLE_STARTER_1");

		if(target < 1)
			npc.SpeechTalk(ally);
	}
}

static void ClotDeath(int entity)
{
	OmegaFollower npc = view_as<OmegaFollower>(entity);

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

static bool OmegaFollower_TryToGrabTarget(OmegaFollower npc, int target)
{
	if (npc.m_flNextGrab >= GetGameTime(npc.index) || npc.m_iGrabState != OMEGA_FOLLOWER_GRAB_STATE_NONE)
		return false; 
	
	// To preserve my sanity, this guy will only grab npcs
	if (target <= MaxClients)
		return false;
	
	if (i_NpcIsABuilding[target])
		return false;
	
	i_GrabbedThis[npc.index] = EntIndexToEntRef(target);
	b_DoNotUnStuck[target] = true;
	npc.m_iGrabState = OMEGA_FOLLOWER_GRAB_STATE_HOLDING;
	npc.m_flNextGrab = GetGameTime(npc.index) + OMEGA_FOLLOWER_HOLD_TIME;
	f_TankGrabbedStandStill[target] = GetGameTime(npc.index) + OMEGA_FOLLOWER_HOLD_TIME;
	f_NoUnstuckVariousReasons[target] = GetGameTime(npc.index) + OMEGA_FOLLOWER_HOLD_TIME;
	b_NoGravity[target] = true;
	FreezeNpcInTime(target, OMEGA_FOLLOWER_HOLD_TIME + 0.5, true);
	ApplyStatusEffect(target, target, "Intangible", OMEGA_FOLLOWER_HOLD_TIME + 0.5);
	
	npc.StopPathing();
	npc.m_bisWalking = false;
	
	npc.m_flSpeed = 0.0;
	
	//npc.SetActivity("ACT_BLADEDANCE_BUFF");
	int activity = npc.LookupActivity("ACT_BLADEDANCE_BUFF");
	if (activity > 0)
		npc.StartActivity(activity);
	
	npc.SetCycle(0.6);
	npc.SetPlaybackRate(0.0);
	
	npc.PlayPickupSound();
	
	npc.m_flStandStill = GetGameTime(npc.index) + OMEGA_FOLLOWER_HOLD_TIME + 0.5;
	return true;
}

static void OmegaFollower_ThrowTarget(OmegaFollower npc)
{
	int target = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	if (IsValidEntity(target))
	{
		ApplyStatusEffect(target, target, "Intangible", 0.5);
		
		EntityKilled_HitDetectionCooldown(target, TankThrowLogic);
		
		i_TankThrewThis[target] = npc.index;
		
		float flPos[3]; // original
		float flAng[3]; // original
	
		npc.GetAttachment("weapon_bone_2", flPos, flAng);
		TeleportEntity(target, flPos, NULL_VECTOR, {0.0,0.0,0.0});
			
		SDKCall_SetLocalOrigin(target, flPos);
		
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(npc.index, vecPos);
		
		int Closest_non_grabbed_player = GetClosestTarget(npc.index, true, .CanSee = true, .ExtraValidityFunction = OmegaFollower_ClosestValidTarget);
		if (Closest_non_grabbed_player > 0)
		{
			WorldSpaceCenter(Closest_non_grabbed_player, vecTargetPos);
		}
		else if (GetVectorLength(f3_NpcSavePos[npc.index]))
		{
			vecTargetPos = f3_NpcSavePos[npc.index];
		}
		else
		{
			vecTargetPos = vecPos;
			vecTargetPos[2] += OMEGA_FOLLOWER_MAX_RANGE;
		}
		
		float vecForce[3];
		SubtractVectors(vecTargetPos, vecPos, vecForce);
		
		// This makes the force static, doesn't depend on proximity
		float range = GetVectorLength(vecForce);
		ScaleVector(vecForce, OMEGA_FOLLOWER_MAX_RANGE / range);
		
		// Change force based on the target's weight
		int weight = i_NpcWeight[target];
		if (weight < 1)
			weight = 1;
		if (weight > 4)
			weight = 4;
		
		ScaleVector(vecForce, 1.0 - ((weight - 1) * 0.33));
		AddVectors(vecPos, vecForce, vecTargetPos);
		TeleportEntity(target, vecPos);
		
		npc.FaceTowards(vecTargetPos, 20000.0);
		PluginBot_Jump(target, vecTargetPos);
		RequestFrame(ApplySdkHookOmegaThrow, EntIndexToEntRef(target));
		CreateTimer(0.1, CheckStuckTank, EntIndexToEntRef(target), TIMER_FLAG_NO_MAPCHANGE);
		
		f3_NpcSavePos[npc.index] = view_as<float>({ 0.0, 0.0, 0.0 });
		
		i_TankAntiStuck[target] = EntIndexToEntRef(npc.index);
		b_DoNotUnStuck[target] = false;
		b_NoGravity[target] = false;
		
		npc.AddGesture("ACT_MILITIA_ATTACK", .SetGestureSpeed = 2.0);
		npc.PlayThrowSound();
	}
	
	i_GrabbedThis[npc.index] = INVALID_ENT_REFERENCE;
	npc.m_iGrabState = OMEGA_FOLLOWER_GRAB_STATE_JUST_THREW;
	npc.m_flNextGrab = GetGameTime(npc.index) + 0.5;
}

static void OmegaFollower_AdjustGrabbedTarget(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	int entity = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	
	if(!IsValidEntity(entity))
		return;
	
	float flPos[3]; // original
	float flAng[3]; // original

	npc.GetAttachment("weapon_bone_2", flPos, flAng);
	
	float vecPos[3], vecMaxs[3];
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxs);
	
	float offset = vecMaxs[2] * 0.5;
	flPos[2] -= offset;
	
	GetAbsOrigin(iNPC, vecPos);
	
	// If the expected origin of the target is lower than ours, they're either too big or we're too small! Adjust
	if (flPos[2] - offset < vecPos[2])
		flPos[2] = vecPos[2] + 20.0;
	
	TeleportEntity(entity, flPos, NULL_VECTOR, {0.0,0.0,0.0});
}

static bool OmegaFollower_ClosestValidTarget(int entity, int target)
{
	return i_GrabbedThis[entity] != EntIndexToEntRef(target);
}

static Action contact_throw_omega_entity(int client)
{
	// Almost completely copy-pasted from the Tank, with a few changes (mainly only dealing damage to enemies of the thrower)
	CClotBody npc = view_as<CClotBody>(client);
	float targPos[3];
	float chargerPos[3];
	float flVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVel);
	if (npc.IsOnGround() && fl_ThrowDelay[client] < GetGameTime(npc.index))
	{
		EntityKilled_HitDetectionCooldown(client, TankThrowLogic);
		SDKUnhook(client, SDKHook_Think, contact_throw_omega_entity);	
		return Plugin_Continue;
	}
	else
	{
		char classname[60];
		WorldSpaceCenter(client, chargerPos);
		for(int entity=1; entity <= MAXENTITIES; entity++)
		{
			if (IsValidEntity(entity) && !b_ThisEntityIgnored[entity])
			{
				GetEntityClassname(entity, classname, sizeof(classname));
				if (StrEqual(classname, "zr_base_npc")) // Simplified for the sake of optimization
				{
					WorldSpaceCenter(entity, targPos);
					if (GetVectorDistance(chargerPos, targPos, true) <= (125.0* 125.0))
					{
						int thrower = i_TankThrewThis[client];
						if (!IsIn_HitDetectionCooldown(client,entity,TankThrowLogic) && entity != client && thrower != entity && IsValidEnemy(thrower, entity))
						{		
							float damageToEntityHit = ReturnEntityMaxHealth(entity) * 0.1;
							float damageToEntityThrown = ReturnEntityMaxHealth(client) * 0.05;
							
							if (damageToEntityHit > 25000.0)
								damageToEntityHit = 25000.0;
							
							if (damageToEntityThrown > 25000.0)
								damageToEntityThrown = 25000.0;
							
							if (ShouldNpcDealBonusDamage(entity))
								damageToEntityHit *= 4.0;
							
							SDKHooks_TakeDamage(entity, thrower, thrower, damageToEntityHit, DMG_GENERIC, -1, NULL_VECTOR, targPos);
							SDKHooks_TakeDamage(client, thrower, thrower, damageToEntityThrown, DMG_GENERIC, -1, NULL_VECTOR, targPos);
							
							EmitSoundToAll("weapons/physcannon/energy_disintegrate5.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
							Set_HitDetectionCooldown(client,entity,FAR_FUTURE,TankThrowLogic);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}


stock void ApplySdkHookOmegaThrow(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		EntityKilled_HitDetectionCooldown(entity, TankThrowLogic);
		fl_ThrowDelay[entity] = GetGameTime(entity) + 0.1;
		SDKHook(entity, SDKHook_Think, contact_throw_omega_entity);		
	}
}