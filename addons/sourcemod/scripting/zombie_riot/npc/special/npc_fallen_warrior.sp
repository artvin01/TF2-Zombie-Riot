#pragma semicolon 1
#pragma newdecls required

static char g_HurtSounds[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static char g_KillSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav"
};
static float i_ClosestAllyCDTarget[MAXENTITIES];


void FallenWarrior_OnMapStart()
{
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fallen Warrior");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_fallen_warrior");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight_samurai");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return FallenWarrior(client, vecPos, vecAng, ally, data);
}

static char[] GetPanzerHealth()
{
	int health = 110;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(ZR_GetWaveCount()+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.20));
	}
	else if(ZR_GetWaveCount()+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 1.5;
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}
methodmap FallenWarrior < CClotBody
{
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0, 70);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("misc/outer_space_transition_01.wav", _, _, _, _, 2.0, 70);
	}
	public void PlayIntroSound()
	{
		EmitCustomToAll("misc/rd_spaceship01.wav", _, _, _, _, 3.0, 80);
	}
	public void PlayFriendlySound()
	{
		EmitCustomToAll("npc/metropolice/vo/infection.wav",, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0, 80);
	}
	public void PlayMeleeSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll("weapons/samurai/tf_katana_slice_03.wav", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0, 70);
	}
	public void PlayKillSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 2.0;
		EmitCustomToAll(g_KillSounds[GetRandomInt(0, sizeof(g_KillSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0, 70);
	}

	public FallenWarrior(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		FallenWarrior npc = view_as<FallenWarrior>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.0", GetPanzerHealth(), ally));
        
		i_NpcWeight[npc.index] = 4;
        FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

        int iActivity = npc.LookupActivity("ACT_CUSTOM_WALK_SAMURAI");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		if(ally == TFTeam_Red)
		{
			npc.PlayFriendlySound();
		}
		else
		{
			npc.PlayIntroSound();
		}
		
        npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(FallenWarrior_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(FallenWarrior_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(FallenWarrior_ClotThink);
		
		npc.m_bLostHalfHealth = false;
        npc.m_bThisNpcIsABoss = true;

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedAttack = GetGameTime();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/angsty_hood/angsty_hood_soldier.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_soldier.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/scout/hwn2019_fuel_injector_style3/hwn2019_fuel_injector_style3.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/scout/hwn2019_fuel_injector_style3/hwn2019_fuel_injector_style3.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl");

		npc.m_iWearable6 = npc.EquipItem("head", "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
        SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		float wave = float(ZR_GetWaveCount()+1);
		wave *= 0.1;
		npc.m_flWaveScale = wave;

		Citizen_MiniBossSpawn();
		return npc;
	}
}

public void FallenWarrior_ClotThink(int iNPC)
{
	FallenWarrior npc = view_as<FallenWarrior>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	float TrueArmor = 1.0;

    if(npc.m_bLostHalfHealth)
    {
        npc.m_flSpeed *= 1.5;
        TrueArmor *= 0.5;
        SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 2);
        IgniteTargetEffect(npc.m_iWearable6);
    }
	else
	{
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
	}
	fl_TotalArmor[npc.index] = TrueArmor;

	

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		AnarchyRunoverSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action DesertKhazaan_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	FallenWarrior npc = view_as<FallenWarrior>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void FallenWarrior_NPCDeath(int entity)
{
	FallenWarrior npc = view_as<FallenWarrior>(entity);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	
	npc.PlayDeathSound();

	Citizen_MiniBossDeath(entity);
}


void DesertAtillaSelfDefense(DesertAtilla npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 125.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;
                    if(npc.m_bLostHalfHealth)
                        damageDealt *= 2.0;
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
                float fasterattack = 2.0;
                if(npc.m_bLostHalfHealth)
                {
                    npc.AddGesture("ACT_CUSTOM_ATTACK_SAMURAI_ANGRY");
                    fasterattack /= 2;
                }
                else
                {
                    npc.AddGesture("ACT_CUSTOM_ATTACK_SAMURAI_CALM");
                }
				
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + fasterattack;
			}
		}
	}
}