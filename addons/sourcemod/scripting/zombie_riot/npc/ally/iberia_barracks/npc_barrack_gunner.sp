#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3"
};

static const char g_IdleSounds[][] =
{
	"vo/taunts/soldier_taunts01.mp3",
	"vo/taunts/soldier_taunts09.mp3",
	"vo/taunts/soldier_taunts14.mp3",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/shotgun_shoot.wav",
};

static const char g_IdleAlert[][] =
{
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3"
};

void Barracks_Iberia_Gunner_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleAlert);
	PrecacheModel("models/player/soldier.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Gunner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_gunner");
	data.IconCustom = false;
	
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Iberia_Gunner(client, vecPos, vecAng);
}

methodmap Barrack_Iberia_Gunner < BarrackBody
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
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}

	public Barrack_Iberia_Gunner(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Iberia_Gunner npc = view_as<Barrack_Iberia_Gunner>(BarrackBody(client, vecPos, vecAng, "120", "models/player/soldier.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Gunner_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Gunner_ClotThink;
		npc.m_flSpeed = 100.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flRangedSpecialDelay = 0.0;

		
		KillFeed_SetKillIcon(npc.index, "pistol");
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/soldier/grfs_soldier.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/demo/demo_scotchbonnet.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum24_pathfinder_style2/sum24_pathfinder_style2.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Barrack_Iberia_Gunner_ClotThink(int iNPC)
{
	Barrack_Iberia_Gunner npc = view_as<Barrack_Iberia_Gunner>(iNPC);
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

			if(flDistanceToTarget < 100000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if((npc.m_flNextRangedAttack < GameTime))
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
							
							npc.m_flNextRangedAttack = GameTime + (1.00 * npc.BonusFireRate);
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 160.0, 1), DMG_BULLET, -1, _, vecHit);
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

		BarrackBody_ThinkMove(npc.index, 100.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_SECONDARY", 85000.0,_, true);
	}
}

void Barrack_Iberia_Gunner_NPCDeath(int entity)
{
	Barrack_Iberia_Gunner npc = view_as<Barrack_Iberia_Gunner>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}
