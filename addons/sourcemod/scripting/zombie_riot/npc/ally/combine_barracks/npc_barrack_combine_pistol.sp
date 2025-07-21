#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/pistol/pistol_fire2.wav"
};

static const char g_RangedReloadSound[][] =
{
	"weapons/pistol/pistol_reload1.wav"
};

static const char g_IdleAlert[][] =
{
	"npc/metropolice/vo/airwatchsubjectis505.wav",
	"npc/metropolice/vo/allunitscloseonsuspect.wav",
	"npc/metropolice/vo/allunitsmovein.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/destroythatcover.wav"
};

void Barracks_Combine_Pistol_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_IdleAlert);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Metro Cop");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_combine_pistol");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}
static float fl_npc_basespeed;

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Combine_Pistol(client, vecPos, vecAng);
}

methodmap Barrack_Combine_Pistol < BarrackBody
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
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL- 10, _, NORMAL_ZOMBIE_VOLUME- 0.2, 100);
		

	}
	public void PlayPistolReload()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}

	public Barrack_Combine_Pistol(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Combine_Pistol npc = view_as<Barrack_Combine_Pistol>(BarrackBody(client, vecPos, vecAng, "100", COMBINE_CUSTOM_MODEL, STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Combine_Pistol_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Combine_Pistol_ClotThink;
		fl_npc_basespeed = 190.0;
		npc.m_flSpeed = 190.0;

		npc.m_iAttacksTillReload = 18;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		KillFeed_SetKillIcon(npc.index, "pistol");
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		return npc;
	}
}

public void Barrack_Combine_Pistol_ClotThink(int iNPC)
{
	Barrack_Combine_Pistol npc = view_as<Barrack_Combine_Pistol>(iNPC);
	float GameTime = GetGameTime(iNPC);
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

			if(flDistanceToTarget < 185000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_iAttacksTillReload < 1)
					{
						npc.AddGesture("ACT_RELOAD",_,_,_,0.5);
						npc.m_flNextMeleeAttack = GameTime + 2.7	;
						npc.m_iAttacksTillReload = 18;
						npc.PlayPistolReload();
					}
					if(npc.m_flNextRangedAttack < GameTime && npc.m_flNextMeleeAttack < GameTime)
					{
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL", false);
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
							
							npc.m_flNextRangedAttack = GameTime + (0.2 * npc.BonusFireRate);
							npc.m_iAttacksTillReload--;
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 54.0, 1), DMG_BULLET, -1, _, vecHit);
						} 		
						delete swingTrace;				
					}
					else
					{
						npc.m_flSpeed = 190.0;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 190.0, "ACT_IDLE_ANGRY_PISTOL", "ACT_RUN_PISTOL", 160000.0,_, true);

		if(npc.m_flNextRangedAttack > GameTime)
		{
			npc.m_flSpeed = 95.0;
		}
		else if(npc.m_flNextMeleeAttack > GameTime)
		{
			npc.m_flSpeed = 95.0;
		}
		else
		{
			npc.m_flSpeed = fl_npc_basespeed;
		}
	}
}

void Barrack_Combine_Pistol_NPCDeath(int entity)
{
	Barrack_Combine_Pistol npc = view_as<Barrack_Combine_Pistol>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}