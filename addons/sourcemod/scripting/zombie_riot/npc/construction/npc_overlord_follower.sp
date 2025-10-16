#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	")weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	")weapons/demo_sword_swing1.wav",
	")weapons/demo_sword_swing2.wav",
	")weapons/demo_sword_swing3.wav"
};

static int NPCId;

void OverlordFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Overlord The Last");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_overlord_follower");
	strcopy(data.Icon, sizeof(data.Icon), "");
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }

	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int OverlordFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return OverlordFollower(vecPos, vecAng, team);
}

static Action OverlordFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<OverlordFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap OverlordFollower < CClotBody
{
	property int m_iAttackType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.3);
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
				this.Speech("For Irln!");
			}
			case 1:
			{
				this.Speech("The void has done enough already!");
			}
			case 2:
			{
				this.Speech("Your command?");
			}
			case 3:
			{
				this.Speech("The army never truly falls.");
			}
			case 4:
			{
				this.Speech("Void spreads beyond the stars.");
				this.SpeechDelay(5.0, "Maybe today it will end.");
			}
			case 5:
			{
				this.Speech("No army is secondary, everyone counts.");
			}
			case 6:
			{
				this.Speech("United against a common foe.");
			}
			case 7:
			{
				this.Speech("For all races!");
			}
			case 8:
			{
				this.Speech("The fire still burns!");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(100.0, 150.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, OverlordFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,90.0}, endingtextscroll);
	}
	
	public OverlordFollower(float vecPos[3], float vecAng[3],int ally)
	{
		OverlordFollower npc = view_as<OverlordFollower>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "50000", ally, true, false));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_LAST_OVERLORD_WALK");
		KillFeed_SetKillIcon(npc.index, "sword");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SetVariantInt(3);	// Combine Model
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 0);

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

		SetEntPropString(npc.index, Prop_Data, "m_iName", "blue_goggles");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/player/items/demo/tw_kingcape/tw_kingcape.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 2);

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 50.0;

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	OverlordFollower npc = view_as<OverlordFollower>(iNPC);
	

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;


	int target = npc.m_iTarget;
	int ally = npc.m_iTargetWalkTo;

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, false, 600.0, .fldistancelimitAllyNPC = 600.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		ally = GetClosestAlly(npc.index, .ExtraValidityFunction = BarracksNPCOnly);
		if(ally == -1)
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
		if(npc.m_iAttackType == -1 && npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.SetActivity("ACT_LAST_OVERLORD_WALK");
				npc.m_bisWalking = true;
				npc.StartPathing();
				npc.m_iAttackType = 0;
			}
		}
		else if(npc.m_flAttackHappens)
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
							damage = 50.0;
						}
						if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
						NPC_Ignite(target, npc.index, 8.0, -1, 4.0);
					}
				}

				delete swingTrace;
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 1.0;

					npc.AddGesture("ACT_LAST_OVERLORD_ATTACK");
					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.35;
				}
			}
		} 
		
		if(npc.m_iAttackType == 0)
		{
			npc.SetActivity("ACT_LAST_OVERLORD_WALK");
		}
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
				npc.SetActivity("ACT_LAST_OVERLORD_WALK");
				return;
			}
		}

		npc.StopPathing();
		npc.SetActivity("ACT_LAST_OVERLORD_IDLE");

		if(target < 1)
			npc.SpeechTalk(ally);
	}
}

static bool BarracksNPCOnly(int entity, int target)
{
	if(target > MaxClients)
	{
		char name[32];
		NPC_GetPluginById(i_NpcInternalId[target], name, sizeof(name));
		if(!StrContains(name, "npc_barrack"))
		{
			if(StrEqual(name, "npc_barrack_building"))
				return false;
				
			if(StrEqual(name, "npc_barrack_villager"))
				return false;
			
			return true;
		}
	}

	return false;
}

static void ClotDeath(int entity)
{
	OverlordFollower npc = view_as<OverlordFollower>(entity);

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
