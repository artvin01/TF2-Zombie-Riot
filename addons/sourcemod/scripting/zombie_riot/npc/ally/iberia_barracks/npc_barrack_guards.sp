#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3",
};

static const char g_IdleSounds[][] =
{
	"vo/demoman_helpmedefend01.mp3",
	"vo/demoman_helpmedefend02.mp3",
	"vo/demoman_helpmedefend03.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/demoman_battlecry01.mp3",
	"vo/demoman_battlecry02.mp3",
	"vo/demoman_battlecry03.mp3",
	"vo/demoman_battlecry04.mp3",
};

void Barracks_Iberia_Guards_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheModel("models/player/demo.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Guards");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_guards");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barracks_Iberia_Guards(client, vecPos, vecAng);
}

methodmap  Barracks_Iberia_Guards < BarrackBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		

	}
	
	public void PlayNPCDeath() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public Barracks_Iberia_Guards(int client, float vecPos[3], float vecAng[3])
	{
		Barracks_Iberia_Guards npc = view_as<Barracks_Iberia_Guards>(BarrackBody(client, vecPos, vecAng, "900", "models/player/demo.mdl", STEPTYPE_COMBINE,"0.55",_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barracks_Iberia_Guards_NPCDeath;
		func_NPCThink[npc.index] = Barracks_Iberia_Guards_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Barrack_Iberia_Guards_OnTakeDamage;
		npc.m_flSpeed = 200.0;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextRangedAttack = 0.0;

		KillFeed_SetKillIcon(npc.index, "bat");

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bat.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_persian_shield/c_persian_shield.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/spr17_blast_defense/spr17_blast_defense.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/dec17_blast_blocker/dec17_blast_blocker.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_stunt_suit_style2/hwn2023_stunt_suit_style2.mdl", "" , skin);

		SetEntityRenderColor(npc.m_iWearable1, 120, 120, 255, 255);
		SetEntityRenderColor(npc.m_iWearable2, 128, 148, 255, 255);

		return npc;
	}
}

public void Barracks_Iberia_Guards_ClotThink(int iNPC)
{
	Barracks_Iberia_Guards npc = view_as<Barracks_Iberia_Guards>(iNPC);
	float GameTime = GetGameTime(iNPC);

	GrantEntityArmor(iNPC, true, 0.25, 0.66, 0);

	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime + 0.3;
						npc.m_flAttackHappens_bullshit = GameTime + 0.44;
						npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
						npc.m_flAttackHappenswillhappen = true;
					}
					if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);

							if(target > 0) 
							{
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),9000.0, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlayMeleeHitSound();
								ExpidonsaGroupHeal(npc.index, 150.0, 4, (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),337.0, 0)), 1.0, true, IberiaBarracks_HealSelfLimitCD);
								DesertYadeamDoHealEffect(npc.index, 150.0);
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_ITEM1", "ACT_MP_RUN_ITEM1");
	}
}

public Action Barrack_Iberia_Guards_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Barracks_Iberia_Guards npc = view_as<Barracks_Iberia_Guards>(victim);
	
	if(npc.m_flNextRangedAttack < GetGameTime(npc.index))
	{
		GrantEntityArmor(npc.index, false, 0.2, 0.66, 0);
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;
	}

	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

void Barracks_Iberia_Guards_NPCDeath(int entity)
{
	Barracks_Iberia_Guards npc = view_as<Barracks_Iberia_Guards>(entity);
	BarrackBody_NPCDeath(npc.index);
	ExpidonsaGroupHeal(npc.index, 300.0, 4, (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),600.0, 0)), 1.0, true, IberiaBarracks_HealSelfLimitCD);
	DesertYadeamDoHealEffect(npc.index, 300.0);
	npc.PlayNPCDeath();
}