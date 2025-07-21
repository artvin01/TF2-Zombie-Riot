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
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/ambassador_shoot.wav",
};

static const char g_IdleAlert[][] =
{
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"ambient/medieval_falcon.wav",
};

void Barracks_Iberia_Elite_Gunner_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleAlert);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
	PrecacheModel("models/player/spy.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Elite Gunner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_elite_gunner");
	data.IconCustom = false;
	
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Iberia_Elite_Gunner(client, vecPos, vecAng);
}

methodmap Barrack_Iberia_Elite_Gunner < BarrackBody
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
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayPistolReload()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL - 10 , _, NORMAL_ZOMBIE_VOLUME - 0.2);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedAttackSecondarySound() 
	{
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL - 10 , _, NORMAL_ZOMBIE_VOLUME - 0.2);
		

	}

	public Barrack_Iberia_Elite_Gunner(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Iberia_Elite_Gunner npc = view_as<Barrack_Iberia_Elite_Gunner>(BarrackBody(client, vecPos, vecAng, "350", "models/player/spy.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Elite_Gunner_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Elite_Gunner_ClotThink;
		npc.m_flSpeed = 150.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flRangedSpecialDelay = 0.0;
		npc.m_iAttacksTillReload = 6;

		
		KillFeed_SetKillIcon(npc.index, "pistol");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_letranger/c_letranger.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/hw2013_feathered_freedom/hw2013_feathered_freedom.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2022_turncoat/hwn2022_turncoat.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/engineer/engineer_cowboy_hat.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		return npc;
	}
}

public void Barrack_Iberia_Elite_Gunner_ClotThink(int iNPC)
{
	Barrack_Iberia_Elite_Gunner npc = view_as<Barrack_Iberia_Elite_Gunner>(iNPC);
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

			if(flDistanceToTarget < 250000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iAttacksTillReload < 1)
					{
						npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY",_,_,_,0.5);
						npc.m_flNextRangedAttack = GameTime + (6.00 * npc.BonusFireRate);
						npc.m_iAttacksTillReload = 6;
						npc.PlayPistolReload();
					}
					if((npc.m_flNextRangedAttack < GameTime && !npc.Anger))
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
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
							
							npc.m_flNextRangedAttack = GameTime + (0.15 * npc.BonusFireRate);
							
							npc.m_iAttacksTillReload --;
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 2100.0, 1), DMG_BULLET, -1, _, vecHit);
						} 		
						delete swingTrace;				
					}
				}
			}
			npc.m_flSpeed = 150.0;
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 150.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_SECONDARY", 225000.0,_, true);
	}
}

void Barrack_Iberia_Elite_Gunner_NPCDeath(int entity)
{
	Barrack_Iberia_Elite_Gunner npc = view_as<Barrack_Iberia_Elite_Gunner>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}