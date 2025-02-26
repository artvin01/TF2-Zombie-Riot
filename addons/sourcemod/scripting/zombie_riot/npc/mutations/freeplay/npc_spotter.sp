// HEAVILY INTENDED AS A RED-SUPPORT ALLY DO NOT USE ON BLU PLEEAAASE

#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_positivevocalization03.mp3",
	"vo/sniper_mvm_loot_common04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bumper_car_hit1.wav",
    "weapons/bumper_car_hit2.wav",
    "weapons/bumper_car_hit3.wav",
    "weapons/bumper_car_hit4.wav",
    "weapons/bumper_car_hit5.wav",
};

static const char g_BuffUpReactions[][] = {
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static const char g_WarCry[][] = {
	"items/powerup_pickup_supernova_activate.wav",
};

static float f_HealCooldown[MAXENTITIES];

void Spotter_OnMapStart_NPC()
{ 	
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_BuffUpReactions)); i++) { PrecacheSound(g_BuffUpReactions[i]); }
	for (int i = 0; i < (sizeof(g_WarCry)); i++) { PrecacheSound(g_WarCry[i]); }
	PrecacheModel("models/player/sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Spotter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_spotter");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_backup");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_SUPPORT;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Spotter(vecPos, vecAng, team);
}

static Action Spotter_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<Spotter>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}

methodmap Spotter < CClotBody
{
	property float m_fHealCooldown
	{
		public get()							{ return f_HealCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ f_HealCooldown[this.index] = TempValueForProperty; }
	}	
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, Spotter_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 150, 0, 255}, {0.0,0.0,125.0}, endingtextscroll);
	}
	public void KillSpeech()
	{
		switch(GetURandomInt() % 3)
		{
			case 0:
			{
				this.Speech("Perish!");
			}
			case 1:
			{
				this.Speech("BAM!!");
			}
			case 2:
			{
				this.Speech("Woosh!");
			}
			default:
			{
				this.Speech("Off you go!");
			}
		}

		this.m_flNextIdleSound += 3.0;
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + 40.0;
		if(!Waves_InFreeplay())
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
				{
					this.Speech("This isn't the training site...");
				}
				case 1:
				{
					this.Speech("Out of all places...");
				}
				case 2:
				{
					this.Speech("...");
				}
				case 3:
				{
					this.Speech("I fear something bad will occur soon");
				}
				default:
				{
					this.Speech("I... I don't think I should be here");
				}
			}
		}
		else
		{
			switch(GetURandomInt() % 15)
			{
				case 0:
				{
					this.Speech("Quite the relaxing training.");
				}
				case 1:
				{
					this.Speech("Hey, guess what?");
					this.SpeechDelay(4.0, "CHICKEN BUTT!!");
					this.SpeechDelay(8.0, "...yeah i think i'll shut up.");
				}
				case 2:
				{
					this.Speech("I can fold you in the blink of an eye, don't test me.");
				}
				case 3:
				{
					this.Speech("Wondering what Bob meant with that ''Sigmaller''...");
				}
				case 4:
				{
					this.Speech("Training with you guys does help me relax a little.");
				}
				case 5:
				{
					this.Speech("Time to time i have some\nlittle conversations with Koshi.");
					this.SpeechDelay(7.5, "However, as of lately, he seems a bit off...");
					this.SpeechDelay(15.0, "He just keeps talking about some\n''Kimori'' or stuff like that.");
				}
				case 6:
				{
					this.Speech("That Omega guy...");
					this.SpeechDelay(3.5, "I despise him... I REALLY hate him...");
					this.SpeechDelay(10.0, "...oh, you heard that? Don't say anything, please.");
				}
				case 7:
				{
					this.Speech("Hmm, i feel like im forgetting something...");
				}
				case 8:
				{
					this.Speech("Ameneurosis.");
				}
				case 9:
				{
					this.Speech("Hey, come to think of it...");
					this.SpeechDelay(5.0, "Aren't you tired of being nice?");
					this.SpeechDelay(9.0, "Don't you just want to go apesh-");
					this.SpeechDelay(12.5, "...sorry, sorry, my head slipped a bit.");
				}
				case 10:
				{
					this.Speech("In my honest opinion, i dislike brocoli.");
					this.SpeechDelay(6.0, "It just DOESN'T taste good for me.");
				}
				case 11:
				{
					this.Speech("Ah, i just remembered something.");
					this.SpeechDelay(6.0, "But its none of your business.");
				}
				case 12:
				{
					this.Speech("I wonder if this training will be enough...");
					this.SpeechDelay(7.0, "...for me to travel with you guys outside.");
				}
				case 13:
				{
					this.Speech("Sometimes i see a guy named 'Vtuber' say he has no limits.");
					this.SpeechDelay(10.0, "And that he'll charge at full power, too.");
					this.SpeechDelay(17.5, "I think that's part of his training....");
				}
				case 14:
				{
					this.Speech("You stink.");
				}
				default:
				{
					this.Speech("These enemies make me think... Was the world that messed up?");
				}
			}
		}
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	public void PlayBuffReaction() 
	{
		EmitSoundToAll(g_BuffUpReactions[GetRandomInt(0, sizeof(g_BuffUpReactions) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeWarCry() 
	{
		EmitSoundToAll(g_WarCry[GetRandomInt(0, sizeof(g_WarCry) - 1)], this.index, SNDCHAN_STATIC, 110, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public Spotter(float vecPos[3], float vecAng[3], int ally)
	{
		Spotter npc = view_as<Spotter>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.35", "50000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flMeleeArmor = 0.75;
		npc.m_flRangedArmor = 0.75;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.Anger = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_iAttacksTillReload = 0;
		npc.m_fHealCooldown = 0.0;

		func_NPCDeath[npc.index] = view_as<Function>(Spotter_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Spotter_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Spotter_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 365.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/dec24_snug_sharpshooter/dec24_snug_sharpshooter.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/hwn2022_headhunters_brim/hwn2022_headhunters_brim.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/invasion_final_frontiersman/invasion_final_frontiersman.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/headhunters_wrap/headhunters_wrap.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
    
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 135, 0);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 135, 0);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 255, 135, 0);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 255, 135, 0);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 255, 135, 0);

		Freeplay_SpotterStatus(true);
	        switch(GetRandomInt(1, 7))
		{
			case 1:
			{
			    	CPrintToChatAll("{orange}Spotter: {white}Aaaalright Bob, lets see what you put me into...");
			}
			case 2:
			{
				CPrintToChatAll("{orange}Spotter: {white}Well heello there, hope you have space in here for me.");
			}
			case 3:
			{
			    	CPrintToChatAll("{orange}Spotter: {white}I'd say its time to end this, but this is different...");
			}
			case 4:
			{
				CPrintToChatAll("{orange}Spotter: {white}Apparently Bob told me he saw some sort of ''titan soldier'' that calls himself a sigma.");
				CPrintToChatAll("{orange}Spotter: {white}Quite {strange}strange{white}, to be honest.");
			}
			case 5:
			{
			    	CPrintToChatAll("{orange}Spotter: {white}Another day, another session of training.");
			}
			case 6:
			{
				CPrintToChatAll("{orange}Spotter: {white}Hello there!");
			}
			default:
			{
			    	CPrintToChatAll("{orange}Spotter: {white}Im hoping that little {lightblue}Ant {white}Bob told me about shows up now.");
			}
		}

		return npc;
	}
}

public void Spotter_ClotThink(int iNPC)
{
	Spotter npc = view_as<Spotter>(iNPC);
	bool retreat = false;
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
		npc.m_iTarget = GetClosestTarget(npc.index, _, 600.0, _, _, _, _, _, 600.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		ally = GetClosestAllyPlayer(npc.index);
		npc.m_iTargetWalkTo = ally;
	}

	if(GetEntProp(npc.index, Prop_Data, "m_iHealth") > RoundToCeil(float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) * 0.25))
	{
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
			SpotterSelfDefense(npc, GetGameTime(npc.index), target, distance);
			npc.m_flSpeed = 365.0;
		}
		else
		{
			retreat = true;
		}
	}
	else
	{
		retreat = true;
	}

	if(retreat)
	{
		if(ally > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			npc.m_flSpeed = 420.0;
			if(flDistanceToTarget > 25000.0)
			{
				NPC_SetGoalEntity(npc.index, ally);
				npc.StartPathing();
				npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				return;
			}
		}
	
		npc.StopPathing();
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
	}	

	if(npc.m_fHealCooldown < gameTime)
	{	
		if(ally > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			if(flDistanceToTarget < 35000.0)
			{
				float flHealth = float(GetEntProp(ally, Prop_Send, "m_iHealth"));
				float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(ally);
				if(flpercenthpfrommax <= 0.5)
				{
					npc.AddGesture("ACT_MP_THROW");
					HealEntityGlobal(npc.index, ally, 500.0, 1.0, 5.0, HEAL_ABSOLUTE);
					switch(GetRandomInt(1, 3))
					{
						case 1:
						{
						    	CPrintToChat(ally, "{orange}Spotter: {white}Here ya go %N.", ally);
						}
						case 2:
						{
							CPrintToChat(ally, "{orange}Spotter: {white}Well well, don't get too hurt next time yeah %N?", ally);
						}
						default:
						{
						    	CPrintToChat(ally, "{orange}Spotter: {white}Have a nice day, %N.", ally);
						}
					}
				}
			}
		}

		HealEntityGlobal(npc.index, npc.index, 2500.0, 1.0, 5.0, HEAL_ABSOLUTE);
		npc.m_fHealCooldown = gameTime + 6.0;
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();	
	}
	
	if(npc.Anger)
	{
		npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");

		float flPos[3];
		float flAng[3];
		GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
		int ParticleEffect1;
		
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", flAng);
		flAng[0] = 90.0;
		ParticleEffect1 = ParticleEffectAt(flPos, "powerup_supernova_explode_red", 1.0); //Taken from sensal haha
		TeleportEntity(ParticleEffect1, NULL_VECTOR, flAng, NULL_VECTOR);

		SpotterAllyBuff(npc);

		npc.Anger = false;
		npc.m_iAttacksTillReload = 0;
	}

	npc.PlayIdleAlertSound();
}

public Action Spotter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Spotter npc = view_as<Spotter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_fHealCooldown = GetGameTime(npc.index) + 12.0;
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Spotter_NPCDeath(int entity)
{
	Spotter npc = view_as<Spotter>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();

	switch(GetRandomInt(1, 5))
	{
		case 1:
		{
			CPrintToChatAll("{orange}Spotter: {white}I-i think im gonna go now... ouchie...");
		}
		case 2:
		{
			CPrintToChatAll("{orange}Spotter: {crimson}OOOUUCH!!! {white}Retreating, retreating!");
		}
		case 3:
		{
			CPrintToChatAll("{orange}Spotter: {white}Yyeeooowwch.... That's gonna leave a mark...");
		}
		case 4:
		{
			CPrintToChatAll("{orange}Spotter: {crimson}OOW!");
		}
		default:
		{
			CPrintToChatAll("{orange}Spotter: {white}Ow ow, im retreating now, heavily wounded...");
		}
	}
	
	CPrintToChatAll("{crimson}The Spotter bails away.");
	Freeplay_SpotterStatus(false);
	
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
}

void SpotterSelfDefense(Spotter npc, float gameTime, int target, float distance)
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
					float damageDealt = 93750.0;
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					ApplyStatusEffect(npc.index, target, "Silenced", 5.0);
					Custom_Knockback(npc.index, target, 500.0, true);
					HealEntityGlobal(npc.index, npc.index, 1000.0, 1.0, 0.0, HEAL_ABSOLUTE);
					
					npc.m_iAttacksTillReload++;
					if(npc.m_iAttacksTillReload >= 50)
					{
						npc.Anger = true;
					}

					// Hit sound
					npc.PlayMeleeHitSound();

					if(GetEntProp(target, Prop_Data, "m_iHealth") < 0)
					{
						npc.KillSpeech();
					}
				} 
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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 2.5;
			}
		}
	}
}

void SpotterAllyBuff(Spotter npc)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);

	for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
	{
		if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
		{
			if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
			{
				HealEntityGlobal(npc.index, entitycount, (float(GetEntProp(entitycount, Prop_Data, "m_iHealth")) * 0.1), 1.0, 0.0, HEAL_ABSOLUTE);
				ApplyStatusEffect(npc.index, entitycount, "Spotter's Rally", 10.0);
			}
		}
	}

	for (int client = 0; client < MaxClients; client++)
	{
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 5.0);
			ApplyStatusEffect(npc.index, client, "Spotter's Rally", 5.0);
		}
	}

	ApplyStatusEffect(npc.index, npc.index, "Hardened Aura", 5.0);

	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			CPrintToChatAll("{orange}Spotter: {gold}PUSH ON FURTHER!!!!");
			npc.Speech("PUSH ON FURTHER!!!!");
		}
		case 2:
		{
			CPrintToChatAll("{orange}Spotter: {gold}COME ON!!!!!");
			npc.Speech("COME ON!!!!!!");
		}
		case 3:
		{
			CPrintToChatAll("{orange}Spotter: {gold}CHARGE AT FULL POWER!!!!");
			npc.Speech("CHARGE AT FULL POWER!!!!");
		}
		default:
		{
			CPrintToChatAll("{orange}Spotter: {gold}KEEP ON THE PRESSURE!!!!");
			npc.Speech("KEEP ON THE PRESSURE!!!!");
		}
	}
	
	npc.m_flNextIdleSound += 5.0;
	npc.PlayMeleeWarCry();
	npc.PlayBuffReaction();
}
