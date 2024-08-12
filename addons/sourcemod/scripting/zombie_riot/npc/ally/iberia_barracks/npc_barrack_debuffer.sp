#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3"
};

static const char g_IdleSounds[][] =
{
	"vo/taunts/sniper/sniper_taunt_admire_02.mp3",
	"vo/compmode/cm_sniper_pregamefirst_6s_05.mp3",
	"vo/compmode/cm_sniper_matchwon_02.mp3",
	"vo/compmode/cm_sniper_matchwon_07.mp3",
	"vo/compmode/cm_sniper_matchwon_10.mp3",
	"vo/compmode/cm_sniper_matchwon_11.mp3",
	"vo/compmode/cm_sniper_matchwon_14.mp3"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/csgo_awp_shoot.wav",
};

static const char g_IdleAlert[][] =
{
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3"
};

void Barracks_Combine_Sniper_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_IdleAlert);
	
	PrecacheModel("models/player/hwm/sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberia Debuffer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_iberia_debuffer");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Barrack_Iberia_Debuffer(client, vecPos, vecAng, ally);
}

methodmap Barrack_Iberia_Debuffer < BarrackBody
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
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}

	public Barrack_Iberia_Debuffer(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Barrack_Iberia_Debuffer npc = view_as<Barrack_Iberia_Debuffer>(BarrackBody(client, vecPos, vecAng, "100", COMBINE_CUSTOM_MODEL, STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Debuffer_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Debuffer_ClotThink;
		npc.m_flSpeed = 150.0;

		npc.m_flNextRangedAttack = 0.0;
		
		KillFeed_SetKillIcon(npc.index, "sniperrifle");

		int skin = 1;
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		SetVariantString("1.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum24_aimframe/sum24_aimframe.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Barrack_Iberia_Debuffer_ClotThink(int iNPC)
{
	Barrack_Iberia_Debuffer npc = view_as<Barrack_Iberia_Debuffer>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 1200000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_flNextRangedAttack < GameTime)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 1200000.0);
						npc.m_flSpeed = 0.0;
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
							
							npc.m_flNextRangedAttack = GameTime + (5.0 * npc.BonusFireRate);
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 1500.0, 1), DMG_BULLET, -1, _, vecHit);
						} 		
						delete swingTrace;		
						npc.m_flSpeed = 100.0;		
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

		BarrackBody_ThinkMove(npc.index, 100.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_PRIMARY", 1150000.0,_, true);
	}
}

void Barrack_Iberia_Debuffer_NPCDeath(int entity)
{
	Barrack_Iberia_Debuffer npc = view_as<Barrack_Iberia_Debuffer>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}