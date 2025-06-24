#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_IdleSounds[][] =
{
	"vo/engineer_standonthepoint01.mp3",
	"vo/engineer_standonthepoint02.mp3",
	"vo/engineer_standonthepoint03.mp3",
	"vo/engineer_standonthepoint04.mp3",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/widow_maker_shot_01.wav",
	"weapons/widow_maker_shot_02.wav",
	"weapons/widow_maker_shot_03.wav",
};

static const char g_RangedReloadSound[][] =
{
	"weapons/pistol/pistol_reload1.wav"
};

static const char g_IdleAlert[][] =
{
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3",
};

void Barracks_Iberia_Boomstick_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_IdleAlert);
	
	PrecacheModel("models/player/engineer.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberia Boomstick");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_boomstick");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Iberia_Boomstick(client, vecPos, vecAng);
}

methodmap Barrack_Iberia_Boomstick < BarrackBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlert[GetRandomInt(0, sizeof(g_IdleAlert) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayPistolReload()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}

	public Barrack_Iberia_Boomstick(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Iberia_Boomstick npc = view_as<Barrack_Iberia_Boomstick>(BarrackBody(client, vecPos, vecAng, "250", "models/player/engineer.mdl", STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Boomstick_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Boomstick_ClotThink;
		npc.m_flSpeed = 150.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 4;
		npc.Anger = true;
		
		KillFeed_SetKillIcon(npc.index, "sniperrifle");

		int skin = 1;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/invasion_corona_australis/invasion_corona_australis.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_engineer.mdl");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec23_sleuth_suit_style4/dec23_sleuth_suit_style4.mdl");

		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Barrack_Iberia_Boomstick_ClotThink(int iNPC)
{
	Barrack_Iberia_Boomstick npc = view_as<Barrack_Iberia_Boomstick>(iNPC);
	float GameTime = GetGameTime(iNPC);
	
	GrantEntityArmor(iNPC, true, 0.5, 0.66, 0);	
	
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 250000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_iAttacksTillReload < 1)//reloading?
					{
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
						npc.m_flNextRangedAttack = GameTime + (5.0 * npc.BonusFireRate);
						npc.m_iAttacksTillReload += 1;
						npc.PlayPistolReload();
					}
					if(npc.m_flNextRangedAttack < GameTime)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 250000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
							
							npc.m_iAttacksTillReload = 0;
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 3100.0, 1), DMG_BULLET, -1, _, vecHit);
						} 		
						delete swingTrace;			
					}
					else
					{
						npc.m_flSpeed = 100.0;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 125.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_PRIMARY", 175000.0,_, true);
	}
}

void Barrack_Iberia_Boomstick_NPCDeath(int entity)
{
	Barrack_Iberia_Boomstick npc = view_as<Barrack_Iberia_Boomstick>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}