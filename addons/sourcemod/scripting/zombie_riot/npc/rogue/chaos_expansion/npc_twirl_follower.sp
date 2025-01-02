#pragma semicolon 1
#pragma newdecls required

static const char g_RangeAttackSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};

static int NPCId;

void TwirlFollowerr_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Twirl");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_twirl_follower");
	strcopy(data.Icon, sizeof(data.Icon), "");

	PrecacheSoundArray(g_RangeAttackSounds);
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int TwirlFollowerr_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return TwirlFollowerr(vecPos, vecAng, team, data);
}

static Action TwirlFollowerr_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<TwirlFollowerr>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap TwirlFollowerr < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll("npc/strider/striderx_die1.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayRangeAttackSound() {
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void SpeechTalk()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(this.index) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 11)
		{
			case 0:
			{
				this.Speech("I have been studying many places across irln ever since whiteflower was killed.");
				this.SpeechDelay(5.0, "I found many things i liked.");
				this.SpeechDelay(10.0, "And many i did not.");
			}
			case 1:
			{
				this.Speech("I wonder if Bladedance will ever forgive me", "...");
			}
			case 2:
			{
				this.Speech("I know what you did to guln.");
				this.SpeechDelay(5.0,"I know it was in his wish.");
				this.SpeechDelay(10.0,"That doesnt mean ill be any less forgiving for it.");
			}
			case 3:
			{
				this.Speech("People view me as a hero, i view myself as being curious.");
			}
			case 4:
			{
				this.Speech("I have no idea why Whiteflower did what he did.");
				this.SpeechDelay(5.0,"Regardless, it is unforgiveable.");
			}
			case 5:
			{
				this.Speech("How my friendgroup met? Mazeat.");
			}
			case 6:
			{
				this.Speech("You want my sword? No chance.");
			}
			case 7:
			{
				this.Speech("Ever since the seaborn stuff happend, you all have been alot more reasonable.");
				this.SpeechDelay(5.0,"Could be PTSD.");
			}
			case 8:
			{
				this.Speech("Even if everything is going to hell, This is the right path.");
			}
			case 9:
			{
				this.Speech("Overtime i can feel everything relaxing abit, The only common big enemy is the void.");
				this.SpeechDelay(5.0, "... or whatever that is..");
			}
			case 10:
			{
				this.Speech("Chaos, i still dont know if its made by someone, or a force of nature.");
				this.SpeechDelay(5.0, "Time will tell what it is..");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, TwirlFollowerr_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,90.0}, endingtextscroll);
	}
	
	public TwirlFollowerr(float vecPos[3], float vecAng[3],int ally, const char[] data)
	{
		TwirlFollowerr npc = view_as<TwirlFollowerr>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "50000", TFTeam_Red, true, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		npc.m_flSpeed = 310.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;
		npc.m_bScalesWithWaves = true;

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable2 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_3);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl", _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl", _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tomb_readers/tomb_readers_medic.mdl", _, skin);
		float flPos[3], flAng[3];
		npc.GetAttachment("head", flPos, flAng);	
		npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "unusual_invasion_boogaloop_2", npc.index, "head", {0.0,0.0,0.0});
		

		SetVariantInt(RUINA_WINGS_4);
		AcceptEntityInput(npc.m_iWearable2, "SetBodyGroup");
		SetVariantInt(RUINA_TWIRL_CREST_4);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		if(Rogue_Mode())
		{
			// Cutscene Here
			npc.Speech("Bob did his job, chaos is over here in one of the ruanian cities.");
			npc.SpeechDelay(5.0, "This might actually be serious for once","...");
			Rogue_SetProgressTime(10.0, false);

			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == BobTheFirstFollower_ID() && IsEntityAlive(other))
				{
					view_as<CClotBody>(other).m_bDissapearOnDeath = true;
					SmiteNpcToDeath(other);
					break;
				}
			}
		}

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	TwirlFollowerr npc = view_as<TwirlFollowerr>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
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
		npc.m_iTargetWalkTo = -1;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.m_bisWalking = true;
		npc.StartPathing();
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = TwirlFollowerrSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, 128.0,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		int ally = npc.m_iTargetWalkTo;
		if(IsValidAlly(npc.index,ally))
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget );
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget > 25000.0)
			{
				npc.m_bisWalking = true;
				NPC_SetGoalEntity(npc.index, ally);
				npc.StartPathing();
				npc.SetActivity("ACT_MP_RUN_MELEE");
				return;
			}

			npc.m_bisWalking = false;
			npc.StopPathing();
			npc.SetActivity("ACT_MP_STAND_MELEE");
		}
		else
		{
			ally = GetClosestAllyPlayer(npc.index);
			npc.m_iTargetWalkTo = ally;
		}
	}
	npc.SpeechTalk();
}


int TwirlFollowerrSelfDefense(TwirlFollowerr npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				float target_vec[3];
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				float DamageProject = 30.0;
				float projectile_speed = 900.0;
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayRangeAttackSound();

				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed, _,target_vec);
				npc.FaceTowards(target_vec, 100000.0);
				char Particle[50];
				if(npc.m_iState)
					Particle = "raygun_projectile_blue";
				else
					Particle = "raygun_projectile_red";

				if(npc.m_iState)
					npc.m_iState = 0;
				else
					npc.m_iState = 1;

				float flPos[3];
			
				GetAttachment(npc.index, "effect_hand_r", flPos, NULL_VECTOR);
				npc.FireParticleRocket(target_vec, DamageProject, projectile_speed , 0.0 , Particle, false, _, true, flPos);
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
			return 0;
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	return 0;
}


static void ClotDeath(int entity)
{
	TwirlFollowerr npc = view_as<TwirlFollowerr>(entity);

	npc.PlayDeathSound();

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
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}
