#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static int NPCId;

void KahmlsteinFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Kahmlstein");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_kahmlstein_follower");
	strcopy(data.Icon, sizeof(data.Icon), "kahmlstein");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int KahmlsteinFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return KahmlsteinFollower(client, vecPos, vecAng);
}

static Action KahmlsteinFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<KahmlsteinFollower>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap KahmlsteinFollower < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void SpeechTalk(int client)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 1)
		{
			case 0:
			{
				this.Speech("I crushed countless cities, evaporated entire armies, set whole seas ablaze.");
				this.SpeechDelay(5.0, "But I couldn't defeat a couple of mercs, crazy.");
				this.SpeechDelay(10.0, "Atleast that got me freed from the influence of this thing somehow, thanks.");
			}
			case 1:
			{
				this.Speech("I always dreamt about being a leader, just not in a way like this", "...");
			}
			case 2:
			{
				this.Speech("Have you ever heard of Hitman? It's pretty rad series, you should play it.");
				this.SpeechDelay(5.0, "OR ELSE", "...");
			}
			case 3:
			{
				this.Speech("Some time ago I had a dream about being this powerful galactic being.");
				this.SpeechDelay(5.0, "And I fought very powerful people in it too, me versus all of them at once.");
				this.SpeechDelay(10.0, "In the end everyone lost because of the time limit ", "-_-");
				this.SpeechDelay(15.0, "Woke up soon after, what a weird dream that was.");
			}
			case 4:
			{
				this.Speech("Chaos makes you crazy, but the Void takes you in and traps you forever.");
				this.SpeechDelay(5.0, "You find yourself in nothing but total darkness, unable to escape.");
				this.SpeechDelay(10.0, "I need to put a stop to it and fix my mistakes.");
			}
			case 5:
			{
				this.Speech("I do really hate goverments, they use up people for their own comfort and gains.");
				this.SpeechDelay(5.0, "I might be sane now, but if I could I would still love to crush them all.");
				this.SpeechDelay(10.0, "This time without the unnecessary casualties.");
				this.SpeechDelay(15.0, "But there are more important matters at hand now.");
			}
			case 6:
			{
				this.Speech("After my fuck ups Ziberia ain't the same anymore...");
				this.SpeechDelay(5.0, "I wish I could go back in time... To the old days", "...");
			}
			case 7:
			{
				this.Speech("After I regained my sanity, I keep having these awful nightmares at night.");
				this.SpeechDelay(5.0, "I see thousands of people being burned alive to crisps.");
				this.SpeechDelay(10.0, "Their screams of pain are awful, they are literally crying for it to stop.");
				this.SpeechDelay(15.0, "And the one that set them on fire... is me.");
				this.SpeechDelay(20.0, "I completely stopped sleeping like a week ago now.");
				this.SpeechDelay(25.0, "...");
			}
			case 8:
			{
				this.Speech("That furry friend of yours who left, he was from Wildingen right?");
				this.SpeechDelay(5.0, "I bet he hates me huh? Yeah, in his place I would do the same.");
			}
			case 9:
			{
				this.Speech("If you feel uneasy, I can give you a hug. This atmosphere is kinda tense.");
				this.SpeechDelay(5.0, "Just keep it a secret from my people, they'd think I got soft.");
			}
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, KahmlsteinFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,120.0}, endingtextscroll);
	}
	
	public KahmlsteinFollower(int client, float vecPos[3], float vecAng[3])
	{
		KahmlsteinFollower npc = view_as<KahmlsteinFollower>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "50000", TFTeam_Red, true, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "steel_fists");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 340.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;

		SetEntPropString(npc.index, Prop_Data, "m_iName", "blue_goggles");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/Robo_Heavy_Chief/Robo_Heavy_Chief.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_chest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 21, 71, 171, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 21, 71, 171, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 21, 71, 171, 255);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 21, 71, 171, 255);
		
		float flPos[3]; // original
		float flAng[3]; // original
	
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		// Cutscene Here
		npc.Speech("This is an urgent matter, so thanks for your assistance.");
		npc.SpeechDelay(5.0, "You'll get your reward later, no time to lose now.");
		Rogue_SetProgressTime(10.0, false);
		Rogue_RemoveNamedArtifact("Waldch Assistance");

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	KahmlsteinFollower npc = view_as<KahmlsteinFollower>(iNPC);
	
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, target);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, _))
				{
					target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float damage = 7500.0;
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

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}

		npc.SetActivity("ACT_MP_RUN_MELEE");
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
				NPC_SetGoalEntity(npc.index, ally);
				npc.StartPathing();
				npc.SetActivity("ACT_MP_RUN_MELEE");
				return;
			}
		}

		npc.StopPathing();
		npc.SetActivity("ACT_MP_STAND_MELEE");

		if(target < 1)
			npc.SpeechTalk(ally);
	}
}

static void ClotDeath(int entity)
{
	KahmlsteinFollower npc = view_as<KahmlsteinFollower>(entity);

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
}