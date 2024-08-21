#pragma semicolon 1
#pragma newdecls required

static int i_overcharge[MAXENTITIES];


static const char g_alt_Sniper_Railgunner_Shoot[][] =
{
	"weapons/sniper_railgun_charged_shot_01.wav",
	"weapons/sniper_railgun_charged_shot_02.wav",
};
static const char g_IdleSounds[][] =
{
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

public void Barrack_Railgunner_MapStart()
{
	PrecacheModel("models/player/sniper.mdl");
	PrecacheSoundArray(g_alt_Sniper_Railgunner_Shoot);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Railgunner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_barrack_railgunner");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static float fl_npc_basespeed;
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Barrack_Alt_Raigunner(client, vecPos, vecAng, ally);
}

methodmap Barrack_Alt_Raigunner < BarrackBody
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
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void ALT_Play_Railgunner_Shoot()
	{
		EmitSoundToAll(g_alt_Sniper_Railgunner_Shoot[GetRandomInt(0, sizeof(g_alt_Sniper_Railgunner_Shoot) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5, 100);
	}
	public Barrack_Alt_Raigunner(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Barrack_Alt_Raigunner npc = view_as<Barrack_Alt_Raigunner>(BarrackBody(client, vecPos, vecAng, "175", "models/player/sniper.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		i_NpcWeight[npc.index] = 1;

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Raigunner_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Raigunner_ClotThink;

		npc.m_flSpeed = 150.0;
		fl_npc_basespeed = 150.0;
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_sniper.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_toowoomba_tunic/sbox2014_toowoomba_tunic_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		
		
		i_overcharge[npc.index] = 0;
		
		return npc;
	}
}

public void Barrack_Alt_Raigunner_ClotThink(int iNPC)
{
	Barrack_Alt_Raigunner npc = view_as<Barrack_Alt_Raigunner>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 1562500.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GameTime)
					{
						float speed = 750.0;
						if(flDistanceToTarget < 562500)	//Doesn't predict over 750 hu
						{
							PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, speed,_,vecTarget);
						}
						npc.m_flSpeed = 0.0;
						npc.FaceTowards(vecTarget, 30000.0);
						//Play attack anim
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						float flPos[3]; // original
						float flAng[3]; // original
						GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
						if(i_overcharge[npc.index]>=5)
						{
							i_overcharge[npc.index]=0;
							npc.PlayMeleeSound();
							npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),1950.0, 1) , speed+100.0 , 100.0 , "spell_fireball_small_red", true, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
							npc.m_flNextMeleeAttack = GameTime + (3.5 * npc.BonusFireRate);
							npc.m_flReloadDelay = GameTime + (0.6 * npc.BonusFireRate);
							npc.ALT_Play_Railgunner_Shoot();
						}
						else
						{
							
							npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),975.0, 1) , speed+100.0 , 100.0 , "raygun_projectile_red_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
							npc.m_flNextMeleeAttack = GameTime + (1.75 * npc.BonusFireRate);
							npc.m_flReloadDelay = GameTime + (0.6 * npc.BonusFireRate);
							i_overcharge[npc.index]++;
						}
						npc.ALT_Play_Railgunner_Shoot();
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 150.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_RUN_PRIMARY", 1562500.0, _,false);

		if(npc.m_flNextMeleeAttack > GameTime)
		{
			npc.m_flSpeed = 10.0;
		}
		else
		{
			npc.m_flSpeed = fl_npc_basespeed;
		}
	}
}

void Barrack_Alt_Raigunner_NPCDeath(int entity)
{
	Barrack_Alt_Raigunner npc = view_as<Barrack_Alt_Raigunner>(entity);
	BarrackBody_NPCDeath(npc.index);
}