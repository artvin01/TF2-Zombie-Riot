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
	"weapons/rocket_shoot.wav",
};

static const char g_IdleAlert[][] =
{
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3"
};

void Barracks_Iberia_Rocketeer_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleAlert);
	PrecacheModel("models/player/soldier.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Rocketeer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_rocketeer");
	data.IconCustom = false;
	
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Iberia_Rocketeer(client, vecPos, vecAng);
}

methodmap Barrack_Iberia_Rocketeer < BarrackBody
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
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}

	public Barrack_Iberia_Rocketeer(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Iberia_Rocketeer npc = view_as<Barrack_Iberia_Rocketeer>(BarrackBody(client, vecPos, vecAng, "150", "models/player/soldier.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Rocketeer_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Rocketeer_ClotThink;
		npc.m_flSpeed = 100.0;

		npc.m_flNextRangedAttack = 0.0;

		
		KillFeed_SetKillIcon(npc.index, "pistol");
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_directhit/c_directhit.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/jul13_helicopter_helmet/jul13_helicopter_helmet.mdl");
		SetEntityRenderColor(npc.m_iWearable2, 100, 100, 100, 255);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/spr17_flakcatcher/spr17_flakcatcher.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/spr18_veterans_attire/spr18_veterans_attire.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2023_shortness_breath/hwn2023_shortness_breath.mdl");
		
		return npc;
	}
}

public void Barrack_Iberia_Rocketeer_ClotThink(int iNPC)
{
	Barrack_Iberia_Rocketeer npc = view_as<Barrack_Iberia_Rocketeer>(iNPC);
	float GameTime = GetGameTime(iNPC);
	
	GrantEntityArmor(iNPC, true, 0.5, 0.66, 0);
	
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		//int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;

		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 200000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if((npc.m_flNextRangedAttack < GameTime))
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 250000.0);
						float speed = 800.0;
						float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
						npc.FireRocket(vPredictedPos, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 675.0, 1), speed+100.0, "models/effects/combineball.mdl",0.5, _, _,GetClientOfUserId(npc.OwnerUserId));	
						//npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 300.0, 1) , speed+100.0 , 100.0 , "raygun_projectile_blue_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
						npc.m_flNextRangedAttack = GameTime + (3.0 * npc.BonusFireRate);		
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

		BarrackBody_ThinkMove(npc.index, 100.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_PRIMARY", 185000.0,_, true);
	}
}

void Barrack_Iberia_Rocketeer_NPCDeath(int entity)
{
	Barrack_Iberia_Rocketeer npc = view_as<Barrack_Iberia_Rocketeer>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}
