// HEAVILY INTENDED AS A RED-SUPPORT ALLY DO NOT USE ON BLU PLEEAAASE

/*
    Spotter - A support voidspeaker hired by Bob the Second, tasked to support the Worthy in freeplay.

    Melee Damage: 75000 base.
    Attack Delay: 2.5s
    Melee Effects:
    - Silences the target for 3s
    - Grants Spotter the Void Strength II buff for 1 second.
    - Knocks the target away.
    - Charges Spotter's Ally Buff by 1.

    Spotter's Ally Buff:
    Buffs all allied NPCS and Players in the map. Takes 30 hits to charge, and can be reused.
    When activated, grants the following:

    NPCS:
    - Void Strength II for 15s
    - 750HP instant heal
    - Spotter's Rally for 15s

    Players:
    - Speedboost for 1.5s
    - Battalion's Backup for 2.5s
    - Spotter's Rally for 7.5s
*/

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

methodmap Spotter < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
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
		Spotter npc = view_as<Spotter>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.35", "100000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.Anger = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_iAttacksTillReload = 0;

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
        SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
        SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
        SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
    
        SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 75, 0, 145);
        SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 75, 0, 145);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 75, 0, 145);
        SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 75, 0, 145);
        SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 75, 0, 145);


        switch(GetRandomInt(1, 3))
	    {
		    case 1:
		    {
		    	CPrintToChatAll("{orange}Spotter: {white}Aaaalright Bob, lets see what you put me into...");
		    }
		    case 2:
		    {
		    	CPrintToChatAll("{orange}Spotter: {white}Well heello there, hope you have space in here for a lil' bit of the {purple}void...");
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
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

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
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
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
		SpotterSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
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

	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			CPrintToChatAll("{orange}Spotter: {white}I-i think im gonna go now... ouchie...");
		}
		case 2:
		{
			CPrintToChatAll("{orange}Spotter: {crimson}OOOUUCH!!! {white}Retreating, retreating!");
		}
		default:
		{
			CPrintToChatAll("{orange}Spotter: {white}B-bob, im retreating now, im heavily wounded...");
		}
	}
	
	Freeplay_SpotterDeath();
	
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
					float damageDealt = 75000.0;
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					ApplyStatusEffect(npc.index, target, "Silenced", 3.0);
					Custom_Knockback(npc.index, target, 500.0, true); 
					
					npc.m_iAttacksTillReload++;
					if(npc.m_iAttacksTillReload >= 25)
					{
						npc.Anger = true;
					}

					// Hit sound
					npc.PlayMeleeHitSound();
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
				HealEntityGlobal(npc.index, entitycount, 750.0, 1.0, 0.0, HEAL_ABSOLUTE);
				ApplyStatusEffect(npc.index, entitycount, "Spotter's Rally", 15.0);
			}
		}
	}

	for (int client = 0; client < MaxClients; client++)
	{
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 3.0);
			ApplyStatusEffect(npc.index, client, "Battilons Backup", 5.0);
			ApplyStatusEffect(npc.index, client, "Spotter's Rally", 7.5);
		}
	}

	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			CPrintToChatAll("{orange}Spotter: {purple}VOID, {gold}GIVE US YOUR BLESSING!!");
		}
		case 2:
		{
			CPrintToChatAll("{orange}Spotter: {gold}COME ON!!!!!");
		}
		default:
		{
			CPrintToChatAll("{orange}Spotter: {gold}KEEP ON THE PRESSURE!!!!");
		}
	}

	npc.PlayMeleeWarCry();
	npc.PlayBuffReaction();
}
