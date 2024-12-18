#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_IdleSounds[][] =
{
	"vo/spy_meleedare01.mp3",
	"vo/spy_meleedare02.mp3",
};


static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

void Barracks_Iberia_Headhunter_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheModel("models/player/spy.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberia Headhunter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_headhunter");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Barrack_Iberia_Headhunter(client, vecPos, vecAng, ally);
}

methodmap Barrack_Iberia_Headhunter < BarrackBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayNPCDeath() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public Barrack_Iberia_Headhunter(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Barrack_Iberia_Headhunter npc = view_as<Barrack_Iberia_Headhunter>(BarrackBody(client, vecPos, vecAng, "900", "models/player/spy.mdl", STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Headhunter_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Headhunter_ClotThink;
		npc.m_flSpeed = 300.0;
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;

		KillFeed_SetKillIcon(npc.index, "sword");
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/all_class/dex_belltower_spy.mdl", "", skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/sf14_nightmare_fedora/sf14_nightmare_fedora.mdl", "", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/sum22_night_vision_gawkers/sum22_night_vision_gawkers.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/spy/sum22_tactical_turtleneck/sum22_tactical_turtleneck.mdl", "", skin);
		return npc;
	}
}

public void Barrack_Iberia_Headhunter_ClotThink(int iNPC)
{
	Barrack_Iberia_Headhunter npc = view_as<Barrack_Iberia_Headhunter>(iNPC);
	float GameTime = GetGameTime(iNPC);
	GrantEntityArmor(iNPC, true, 0.5, 0.66, 0);
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
					float damage = 5000.0;

					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GameTime + 2.0;
						npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						npc.PlaySwordSound();
						npc.m_flAttackHappens = GameTime + 0.3;
						npc.m_flAttackHappens_bullshit = GameTime + 0.44;
						npc.m_flNextMeleeAttack = GameTime + (1.25 * npc.BonusFireRate);
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
								
								if(b_thisNpcIsABoss[target] ||
								b_thisNpcIsARaid[target] ||
								b_StaticNPC[target] ||
								b_thisNpcHasAnOutline[target] ||
								b_ThisNpcIsImmuneToNuke[target] ||
								b_IsGiant[target])
								{
									damage *= 2.5;
								}
								
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
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
		BarrackBody_ThinkMove(npc.index, 300.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_ITEM1", 8000.0,_, true);
	}
}

void Barrack_Iberia_Headhunter_NPCDeath(int entity)
{
	Barrack_Iberia_Headhunter npc = view_as<Barrack_Iberia_Headhunter>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}   