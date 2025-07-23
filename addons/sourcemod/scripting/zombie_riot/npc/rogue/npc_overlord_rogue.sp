#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	")npc/combine_soldier/die1.wav",
	")npc/combine_soldier/die2.wav",
	")npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	")npc/combine_soldier/pain1.wav",
	")npc/combine_soldier/pain2.wav",
	")npc/combine_soldier/pain3.wav",
};

static const char g_IdleSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};
static const char g_MeleeHitSounds[][] = {
	")weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_ChargeSounds[][] = {
	")weapons/physcannon/physcannon_charge.wav",
};

static const char g_MeleeAttackSounds[][] = {
	")weapons/demo_sword_swing1.wav",
	")weapons/demo_sword_swing2.wav",
	")weapons/demo_sword_swing3.wav",
};


static const char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"ambient_mp3/halloween/thunder_01.mp3",
	"ambient_mp3/halloween/thunder_04.mp3",
	"ambient_mp3/halloween/thunder_06.mp3"
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

static char SpawnPoint[128];

void OverlordRogue_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	for (int i = 0; i < (sizeof(g_ChargeSounds));   i++) { PrecacheSound(g_ChargeSounds[i]);   }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Overlord The Last");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_overlord_rogue");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/wave_music/bat_talulha.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return OverlordRogue(vecPos, vecAng, team, data);
}

methodmap OverlordRogue < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)]);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	public void PlayRangedAttackSecondarySound() {
		
		int rand = GetURandomInt() % sizeof(g_RangedAttackSoundsSecondary);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[rand]);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[rand]);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlaySpecialChargeSound() {
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, _, 110, _, BOSS_ZOMBIE_VOLUME);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	
	public OverlordRogue(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		OverlordRogue npc = view_as<OverlordRogue>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.25", "100000", ally));
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		i_NpcWeight[npc.index] = 99;
		KillFeed_SetKillIcon(npc.index, "firedeath");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_LAST_OVERLORD_IDLE");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = OverlordRogue_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = OverlordRogue_OnTakeDamage;
		func_NPCThink[npc.index] = OverlordRogue_ClotThink;
		
		bool final = StrContains(data, "final_item") != -1;
		bool final2 = StrContains(data, "music_do") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		if(final2)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/wave_music/bat_talulha.mp3");
			music.Time = 209;
			music.Volume = 1.75;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Arknights bat_talulha (no Official name.)");
			strcopy(music.Artist, sizeof(music.Artist), "Arknights");
			Music_SetRaidMusic(music);
		}
		npc.m_bDissapearOnDeath = true;
		
		CPrintToChatAll("{crimson}최후의 대군주{default}: 이 대군주들은 나의 자리를 차지하기 위해 찾아온 자들이다... 그리고 네 놈도 저 놈들과 별 다를게 없겠지...");
		strcopy(SpawnPoint, sizeof(SpawnPoint), data);
		ReplaceString(SpawnPoint, sizeof(SpawnPoint), "final_item ", "");
		ReplaceString(SpawnPoint, sizeof(SpawnPoint), "final_item", "");

		npc.m_bThisNpcIsABoss = true;
		npc.m_iState = 0;
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = true;
		npc.m_flNextChargeSpecialAttack = 0.0;
		npc.m_flNextDelayTime = GetGameTime(npc.index) + 30.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;
		RaidModeScaling = 0.0;
		RaidModeTime = GetGameTime() + 999.9;

		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/player/items/demo/tw_kingcape/tw_kingcape.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 2);
		
		return npc;
	}
	
	
}


public void OverlordRogue_ClotThink(int iNPC)
{
	OverlordRogue npc = view_as<OverlordRogue>(iNPC);
	
	SetVariantInt(3);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
		
	float TrueArmor = 1.0;
	if(npc.m_flAngerDelay > GetGameTime(npc.index))
		TrueArmor *= 0.25;
	
	if(npc.m_fbRangedSpecialOn)
		TrueArmor *= 0.15;
	fl_TotalArmor[npc.index] = TrueArmor;

	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_HURT", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			if (npc.m_flmovedelay < GetGameTime(npc.index) && npc.m_flAngerDelay < GetGameTime(npc.index))
			{
				if(npc.m_iChanged_WalkCycle != 7)
				{
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_LAST_OVERLORD_WALK");
				}
				npc.m_flmovedelay = GetGameTime(npc.index) + 1.0;
				npc.m_flSpeed = 90.0;
			}
			if (npc.m_flmovedelay < GetGameTime(npc.index) && npc.m_flAngerDelay > GetGameTime(npc.index))
			{
				if(npc.m_iChanged_WalkCycle != 8)
				{
					npc.m_iChanged_WalkCycle = 8;
					npc.SetActivity("ACT_LAST_OVERLORD_CHARGE_LOOP");
				}
				npc.m_flmovedelay = GetGameTime(npc.index) + 1.0;
				npc.m_flSpeed = 380.0;
			}
		//	npc.FaceTowards(vecTarget);
		}
			
		if(npc.m_flJumpStartTime > GetGameTime(npc.index))
		{
			npc.m_flSpeed = 0.0;
		}
		
	//	npc.FaceTowards(vecTarget, 1000.0);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
		/*	int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
		
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
		
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
			
			npc.SetGoalVector(vPredictedPos);
		} else {
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		
		if(npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index) && npc.m_flReloadDelay < GetGameTime(npc.index) && flDistanceToTarget < 160000)
		{
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 20.0;
			npc.m_flReloadDelay = GetGameTime(npc.index) + 2.0;
			npc.m_flRangedSpecialDelay += GetGameTime(npc.index) + 2.0;
			npc.m_flAngerDelay = GetGameTime(npc.index) + 5.0;
			if(npc.m_bThisNpcIsABoss)
			{
				npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
			}
			npc.PlaySpecialChargeSound();
			npc.SetActivity("ACT_LAST_OVERLORD_CHARGE_LOOP");
			npc.m_flmovedelay = GetGameTime(npc.index) + 0.5;
			npc.m_flJumpStartTime = GetGameTime(npc.index) + 2.0;
			npc.StopPathing();
			
		}

		if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index) && npc.m_flAngerDelay < GetGameTime(npc.index) || npc.m_fbRangedSpecialOn)
		{
		//	npc.FaceTowards(vecTarget, 2000.0);
			if(!npc.m_fbRangedSpecialOn)
			{
				npc.StopPathing();
				
				npc.AddGesture("ACT_LAST_OVERLORD_FIRE");
				npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 0.3;
				npc.m_fbRangedSpecialOn = true;
				npc.m_flReloadDelay = GetGameTime(npc.index) + 0.4;
			}
			if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
			{
				npc.m_fbRangedSpecialOn = false;
				npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 8.0;
				npc.PlayRangedAttackSecondarySound();

				npc.FaceTowards(vecTarget, 20000.0);
				
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				
				NPC_Ignite(PrimaryThreatIndex, npc.index,8.0, -1, 20.5);
			}
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
		{
			npc.StartPathing();
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
					npc.RemoveGesture(npc.m_flAngerDelay > GetGameTime(npc.index) ? "ACT_LAST_OVERLORD_ATTACK_CHARGE" : "ACT_LAST_OVERLORD_ATTACK");
					npc.AddGesture(npc.m_flAngerDelay > GetGameTime(npc.index) ? "ACT_LAST_OVERLORD_ATTACK_CHARGE" : "ACT_LAST_OVERLORD_ATTACK");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.44;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								KillFeed_SetKillIcon(npc.index, "sword");

								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 5000.0, DMG_CLUB, -1, _, vecHit);
								
								KillFeed_SetKillIcon(npc.index, "firedeath");

								Custom_Knockback(npc.index, target, 450.0);
								StartBleedingTimer(target, npc.index, 5.0, 20, -1, DMG_TRUEDAMAGE, 0);
								
								// Hit sound
								npc.PlayMeleeHitSound();
							} 
						}
					delete swingTrace;
					if(npc.m_flAngerDelay > GetGameTime(npc.index))
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
					}
					else
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.4;
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(npc.m_flAngerDelay > GetGameTime(npc.index))
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
					}
					else
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.4;
					}
				}
			}
		}
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			npc.StartPathing();
			
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action OverlordRogue_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;

	OverlordRogue npc = view_as<OverlordRogue>(victim);
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void OverlordRogue_NPCDeath(int entity)
{
	OverlordRogue npc = view_as<OverlordRogue>(entity);
	npc.PlayDeathSound();	

	if(i_RaidGrantExtra[npc.index] == 1 && GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		CPrintToChatAll("{crimson}최후의 대군주{default}: 아... 아무래도 난 틀린것 같군... 절대로 배풍등이 목적을 이루게 해서는 안 돼 ... 그 놈을 끝내고 {black}이 어둠을 끝내야해.");
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
			{
				Items_GiveNamedItem(client, "Overlords Final Wish");
				CPrintToChat(client,"{default}당신은 최후의 대군주를 퇴치했고, 그가 당신에게 준 것은...: {red}''대군주의 최후의 소원''{default}!");
			}
		}
	}
	CPrintToChatAll("{crimson}최후의 대군주{default}: 난 돌아간다... 네가 날 놓아준다면.");
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);

	RaidBossActive = INVALID_ENT_REFERENCE;
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}