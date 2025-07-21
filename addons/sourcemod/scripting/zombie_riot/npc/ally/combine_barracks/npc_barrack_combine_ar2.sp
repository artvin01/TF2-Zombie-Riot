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
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/ar2/fire1.wav",
};

static const char g_RangedReloadSound[][] =
{
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_IdleAlert[][] =
{
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

void Barracks_Combine_Ar2_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_IdleAlert);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Soldier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_combine_ar2");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}
static float fl_npc_basespeed;

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Combine_AR2(client, vecPos, vecAng);
}

methodmap Barrack_Combine_AR2 < BarrackBody
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

	public Barrack_Combine_AR2(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Combine_AR2 npc = view_as<Barrack_Combine_AR2>(BarrackBody(client, vecPos, vecAng, "150", "models/combine_soldier.mdl", STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Combine_AR2_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Combine_AR2_ClotThink;
		fl_npc_basespeed = 235.0;
		npc.m_flSpeed = 235.0;

		npc.m_iAttacksTillReload = 31;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		KillFeed_SetKillIcon(npc.index, "smg");
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		return npc;
	}
}

public void Barrack_Combine_AR2_ClotThink(int iNPC)
{
	Barrack_Combine_AR2 npc = view_as<Barrack_Combine_AR2>(iNPC);
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
						npc.m_flNextMeleeAttack = GameTime + 3.7;
						npc.m_iAttacksTillReload = 31;
						npc.PlayPistolReload();
					}
					if(npc.m_flNextRangedAttack < GameTime && npc.m_flNextMeleeAttack < GameTime)
					{
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2", false);
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 300000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
							
							npc.m_flNextRangedAttack = GameTime + (0.12 * npc.BonusFireRate);
							npc.m_iAttacksTillReload--;
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 67.5, 1), DMG_BULLET, -1, _, vecHit);
						} 		
						delete swingTrace;			
					}
					else
					{
						npc.m_flSpeed = 235.0;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 235.0, "ACT_IDLE", "ACT_WALK_AIM_RIFLE", 160000.0,_, true);

		if(npc.m_flNextRangedAttack > GameTime)
		{
			npc.m_flSpeed = 117.5;
		}
		else if(npc.m_flNextMeleeAttack > GameTime)
		{
			npc.m_flSpeed = 117.5;
		}
		else
		{
			npc.m_flSpeed = fl_npc_basespeed;
		}
	}
}

void Barrack_Combine_AR2_NPCDeath(int entity)
{
	Barrack_Combine_AR2 npc = view_as<Barrack_Combine_AR2>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}