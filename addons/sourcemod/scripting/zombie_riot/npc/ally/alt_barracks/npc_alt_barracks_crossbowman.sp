#pragma semicolon 1
#pragma newdecls required

static int i_overcharge[MAXENTITIES];

static const char g_IdleSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

public void Barrack_Alt_Crossbowmedic_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}
}

methodmap Barrack_Alt_Crossbowmedic < BarrackBody
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
	public Barrack_Alt_Crossbowmedic(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Barrack_Alt_Crossbowmedic npc = view_as<Barrack_Alt_Crossbowmedic>(BarrackBody(client, vecPos, vecAng, "145", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcInternalId[npc.index] = ALT_BARRACKS_CROSSBOW_MEDIC;
		i_NpcWeight[npc.index] = 1;
		
		SDKHook(npc.index, SDKHook_Think, Barrack_Alt_Crossbowmedic_ClotThink);

		npc.m_flSpeed = 125.0;
		
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow_xmas.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_medic.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_toowoomba_tunic/sbox2014_toowoomba_tunic_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop_partner/player/items/sniper/c_bet_brinkhood/c_bet_brinkhood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		
		
		
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		i_overcharge[npc.index] = 0;
		
		return npc;
	}
}

public void Barrack_Alt_Crossbowmedic_ClotThink(int iNPC)
{
	Barrack_Alt_Crossbowmedic npc = view_as<Barrack_Alt_Crossbowmedic>(iNPC);
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
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
						float flPos[3]; // original
						float flAng[3]; // original
						GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
						if(i_overcharge[npc.index]>=10)
						{
							i_overcharge[npc.index]=0;
							npc.PlayRangedSound();
							npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 750.0, 1)*2.0 , speed+100.0 , 100.0 , "spell_fireball_small_red", true, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
							npc.m_flNextMeleeAttack = GameTime + (4.25 * npc.BonusFireRate);
							npc.m_flReloadDelay = GameTime + (0.6 * npc.BonusFireRate);
						}
						else
						{
							
							npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 750.0, 1) , speed+100.0 , 100.0 , "raygun_projectile_red_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
							npc.m_flNextMeleeAttack = GameTime + (2.75 * npc.BonusFireRate);
							npc.m_flReloadDelay = GameTime + (0.6 * npc.BonusFireRate);
							i_overcharge[npc.index]++;
						}
						
						npc.PlayRangedSound();
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 125.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_RUN_PRIMARY", 1562500.0, _,false);
	}
}

void Barrack_Alt_Crossbowmedic_NPCDeath(int entity)
{
	Barrack_Alt_Crossbowmedic npc = view_as<Barrack_Alt_Crossbowmedic>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, Barrack_Alt_Crossbowmedic_ClotThink);
}