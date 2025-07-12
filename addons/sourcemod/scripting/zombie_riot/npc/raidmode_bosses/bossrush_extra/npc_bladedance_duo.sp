#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
};

static const char g_IdleSound[][] = {
	"npc/combine_soldier/vo/prison_soldier_bunker1.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker2.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/prison_soldier_leader9dead.wav"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/irifle/irifle_fire2.wav"
};

static const char g_RangedSpecialAttackSoundsSecondary[][] = {
	"npc/combine_soldier/vo/prison_soldier_fallback_b4.wav"
};

void RaidbossBladedance_Duo_MapStart()
{
	PrecacheModel("models/effects/combineball.mdl");
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));	i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedSpecialAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedSpecialAttackSoundsSecondary[i]);	}

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bladedance, True Teamwork");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bladedance_duo");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossBladedance_Duo(vecPos, vecAng, team, data);
}

/*
TODO:
bladedance
List of abiltiies:
1. Every 10 seconds, switches from melee swinging to orb throwing
During orb throwing, simular to normal bladedance, applies those debuffs
He also backs off a certain distance while he throws orbs

Everytime bladedance hits anyone, he will mark them for 5 seconds

2. Spawns 2 Mercs, one is a melee, another is ranger/Mage (random which), both must be taken out, while they are alive, both bladedance and bob are buffed
3. spawns a medic merc, supports him and bob, (whoever is lower) with health, must be killed fast

4. Exchanges places with bob after casting an animation for a few seconds, anyone near him will be taken with him but take alot of damage
After said exchange, he causes an aoe on where he is now/bob used to be

5. Runs to bob and casts a spell, for a certain amount of time, there will be a lighting link between them, anyone caught in it will take heavy damage, the further away they are, the bigger/fatter
This link becomes, its time limited.

6. Kicks an enemy up, if bob is too far away, bob will instantly teleport to said kicked up target and kick them down, dealing extreme damage
If the target is marked, the target will be stunned as both bob and bladedance stand side by side and fire a massive laser, bascically instantly killing the player and anyone in that vercinity

If bob is close enough, bob will instead throw a very fast orb, but this orb can be dodged by the kicked up player, however the orb can then home onto other players

7. Casts a spell where all buildings will be death zones for a 15 seconds,

8. Bladedance can do a combo attack where he punches a target 3 times, then shoots a orb at them, doesnt have to hit the same target either

9. If bladedance recives too much damage in a short timeframe, a temporary bob clone will appear near him which will support bladedance for a 10 seconds or so
*/
methodmap RaidbossBladedance_Duo < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		int rand = GetRandomInt(0, sizeof(g_IdleSound) - 1);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayKilledEnemySound() 
	{
		int rand = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayRangedSpecialAttackSecondarySound(const float pos[3])
	{
		int numClients;
		int[] clients = new int[MaxClients];

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				static float pos2[3];
				GetClientEyePosition(i, pos2);
				if(GetVectorDistance(pos, pos2, true) < 2000000.0)
				{
					clients[numClients++] = i;
				}
			}
		}

		int rand = GetRandomInt(0, sizeof(g_RangedSpecialAttackSoundsSecondary) - 1);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
	}

	public RaidbossBladedance_Duo(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RaidbossBladedance_Duo npc = view_as<RaidbossBladedance_Duo>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "1500000", ally, false));
		
		i_NpcWeight[npc.index] = 5;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");

		npc.SetActivity("ACT_CUSTOM_WALK_BOW");

		func_NPCDeath[npc.index] = RaidbossBladedance_Duo_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossBladedance_Duo_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossBladedance_Duo_ClotThink;
		
		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		npc.m_bDissapearOnDeath = true;

		npc.m_bThisNpcIsABoss = true;
		npc.Anger = false;
		npc.m_flSpeed = 170.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		b_thisNpcIsARaid[npc.index] = true;

		npc.Anger = false;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flMeleeArmor = 0.75;
		
		Citizen_MiniBossSpawn();
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/spy/spy_party_phantom.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("forward", "models/workshop/player/items/all_class/fall17_jungle_wreath/fall17_jungle_wreath_spy.mdl");//"models/player/items/spy/spy_cardhat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable1, 255, 55, 55, 255);

		SetEntityRenderColor(npc.m_iWearable2, 255, 55, 55, 255);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				LookAtTarget(client_check, npc.index);
		}

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;

		return npc;
	}
}

public void RaidbossBladedance_Duo_ClotThink(int iNPC)
{
	RaidbossBladedance_Duo npc = view_as<RaidbossBladedance_Duo>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(IsValidEntity(RaidBossActive))
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		npc.StopPathing();
		npc.m_flNextThinkTime = FAR_FUTURE;
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	//Think throttling
	if(npc.m_flNextThinkTime > gameTime)
		return;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.05;

	//Set raid to this one incase the previous one has died or somehow vanished
	if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)) || IsPartnerGivingUpSilvester(EntRefToEntIndex(RaidBossActive)))
	{	
		RaidBossActive = EntIndexToEntRef(npc.index);
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime || !IsEntityAlive(npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

}

public Action RaidbossBladedance_Duo_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;

	RaidbossBladedance_Duo npc = view_as<RaidbossBladedance_Duo>(victim);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void RaidbossBladedance_Duo_NPCDeath(int entity)
{
	RaidbossBladedance_Duo npc = view_as<RaidbossBladedance_Duo>(entity);
	
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", npc.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME * 2.0);
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s",WhatDifficultySetting_Internal);
	WavesUpdateDifficultyName();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	RaidBossActive = INVALID_ENT_REFERENCE;
}
