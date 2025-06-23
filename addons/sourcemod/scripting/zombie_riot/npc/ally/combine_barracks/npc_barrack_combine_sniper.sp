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
	"weapons/csgo_awp_shoot.wav",
};

static const char g_RangedReloadSound[][] =
{
	"weapons/pistol/pistol_reload1.wav",
};

static const char g_IdleAlert[][] =
{
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
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
	strcopy(data.Name, sizeof(data.Name), "Barracks Peacekeeper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_combine_sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Combine_Sniper(client, vecPos, vecAng);
}

methodmap Barrack_Combine_Sniper < BarrackBody
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
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

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

	public Barrack_Combine_Sniper(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Combine_Sniper npc = view_as<Barrack_Combine_Sniper>(BarrackBody(client, vecPos, vecAng, "300", COMBINE_CUSTOM_MODEL, STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Combine_Sniper_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Combine_Sniper_ClotThink;
		npc.m_flSpeed = 250.0;

		npc.m_flNextRangedAttack = 0.0;
		
		KillFeed_SetKillIcon(npc.index, "sniperrifle");

		int skin = 1;
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		SetVariantString("1.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum24_aimframe/sum24_aimframe.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Barrack_Combine_Sniper_ClotThink(int iNPC)
{
	Barrack_Combine_Sniper npc = view_as<Barrack_Combine_Sniper>(iNPC);
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
			
			if(flDistanceToTarget < 700000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_flNextRangedAttack < GameTime)
					{
						npc.SetActivity("ACT_MP_STAND_PRIMARY");
						npc.m_flReloadDelay = GameTime + (2.0 * npc.BonusFireRate);
						npc.m_flNextRangedAttack = GameTime + (5.0 * npc.BonusFireRate);
						
						npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_RPG", false);
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 800000.0);
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
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 13600.0, 1), DMG_BULLET, -1, _, vecHit);
							ApplyStatusEffect(npc.index, target, "Silenced", 2.0);
						} 		
						delete swingTrace;		
						npc.m_flSpeed = 250.0;		
					}
					else
					{
						npc.m_flSpeed = 250.0;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_IDLE_ANGRY_RPG", "ACT_RUN_RPG", 550000.0,_, true);
	}
}

void Barrack_Combine_Sniper_NPCDeath(int entity)
{
	Barrack_Combine_Sniper npc = view_as<Barrack_Combine_Sniper>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}