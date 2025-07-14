#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_IdleSounds[][] =
{
	"vo/medic_specialcompleted11.mp3",
	"vo/medic_specialcompleted12.mp3",
	"vo/medic_specialcompleted08.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

void Barracks_Iberia_Healer_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Healer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_healer");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Iberia_Healer(client, vecPos, vecAng);
}

methodmap Barrack_Iberia_Healer < BarrackBody
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

	public Barrack_Iberia_Healer(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Iberia_Healer npc = view_as<Barrack_Iberia_Healer>(BarrackBody(client, vecPos, vecAng, "350", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Healer_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Healer_ClotThink;
		npc.m_flSpeed = 180.0;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;


		KillFeed_SetKillIcon(npc.index, "bat");

		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl", "", 1);
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/bak_hood_of_sorrows/bak_hood_of_sorrows.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem/dec15_medic_winter_jacket2_emblem.mdl");

		SetEntityRenderColor(npc.m_iWearable1, 200, 200, 255, 255);

		return npc;
	}
}

public void Barrack_Iberia_Healer_ClotThink(int iNPC)
{
	Barrack_Iberia_Healer npc = view_as<Barrack_Iberia_Healer>(iNPC);
	float GameTime = GetGameTime(iNPC);

	GrantEntityArmor(iNPC, true, 0.3, 0.66, 0);

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
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime + 0.3;
						npc.m_flAttackHappens_bullshit = GameTime + 0.44;
						npc.m_flNextMeleeAttack = GameTime + (1.0 * npc.BonusFireRate);
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
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),650.0, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlayMeleeHitSound();
								ExpidonsaGroupHeal(npc.index, 150.0, 3, 200.0, 1.0, true, IberiaBarracks_HealSelfLimitCD);
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
		BarrackBody_ThinkMove(npc.index, 180.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS");
	}
}

void Barrack_Iberia_Healer_NPCDeath(int entity)
{
	Barrack_Iberia_Healer npc = view_as<Barrack_Iberia_Healer>(entity);
	BarrackBody_NPCDeath(npc.index);
	ExpidonsaGroupHeal(npc.index, 300.0, 3, 600.0, 1.0, true, IberiaBarracks_HealSelfLimitCD);
	DesertYadeamDoHealEffect(npc.index, 300.0);
	npc.PlayNPCDeath();
}