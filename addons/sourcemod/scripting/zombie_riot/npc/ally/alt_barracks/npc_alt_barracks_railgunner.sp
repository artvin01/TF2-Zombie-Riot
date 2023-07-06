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
	for (int i = 0; i < (sizeof(g_alt_Sniper_Railgunner_Shoot));   i++)	{ PrecacheSound(g_alt_Sniper_Railgunner_Shoot[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}
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
	public Barrack_Alt_Raigunner(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Barrack_Alt_Raigunner npc = view_as<Barrack_Alt_Raigunner>(BarrackBody(client, vecPos, vecAng, "175", "models/player/sniper.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcInternalId[npc.index] = ALT_BARRACK_RAILGUNNER;
		i_NpcWeight[npc.index] = 1;
		
		SDKHook(npc.index, SDKHook_Think, Barrack_Alt_Raigunner_ClotThink);

		npc.m_flSpeed = 150.0;
		
		
		
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
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

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
							vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, speed);
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
							npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),2600.0, 1) , speed+100.0 , 100.0 , "spell_fireball_small_red", true, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
							npc.m_flNextMeleeAttack = GameTime + (3.5 * npc.BonusFireRate);
							npc.m_flReloadDelay = GameTime + (0.6 * npc.BonusFireRate);
							npc.ALT_Play_Railgunner_Shoot();
						}
						else
						{
							
							npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),1300.0, 1) , speed+100.0 , 100.0 , "raygun_projectile_red_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
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
	}
}

void Barrack_Alt_Raigunner_NPCDeath(int entity)
{
	Barrack_Alt_Raigunner npc = view_as<Barrack_Alt_Raigunner>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, Barrack_Alt_Raigunner_ClotThink);
}