#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3"
};
static const char g_DeathSounds_Armor[][] =
{
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] =
{
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3",
};

static const char g_HurtSounds_Armor[][] =
{
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/demoman_battlecry01.mp3",
	"vo/demoman_battlecry02.mp3",
	"vo/demoman_battlecry03.mp3",
	"vo/demoman_battlecry04.mp3",
};
static const char g_IdleAlertedSounds_Armor[][] =
{
	")physics/metal/metal_box_strain1.wav",
	")physics/metal/metal_box_strain2.wav",
	")physics/metal/metal_box_strain3.wav",
	")physics/metal/metal_box_strain4.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav"
};
static const char g_RageOut[][] =
{
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3",
};
static const char g_ExplodeSound[][] =
{
	"weapons/bombinomicon_explode1.wav",
};
void DemonPossesedArmorOnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_DeathSounds_Armor);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_HurtSounds_Armor);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_IdleAlertedSounds_Armor);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RageOut);
	PrecacheSoundArray(g_ExplodeSound);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Demon Possesed Armor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_demon_possesed_armor");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return DemonPossesedArmor(vecPos, vecAng, team, data);
}

methodmap DemonPossesedArmor < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(this.m_iBleedType != BLEEDTYPE_METAL)
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);
		else
			EmitSoundToAll(g_IdleAlertedSounds_Armor[GetRandomInt(0, sizeof(g_IdleAlertedSounds_Armor) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_iBleedType != BLEEDTYPE_METAL)
			EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);
		else
			EmitSoundToAll(g_HurtSounds_Armor[GetRandomInt(0, sizeof(g_HurtSounds_Armor) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		if(this.m_iBleedType != BLEEDTYPE_METAL)
			EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);
		else
			EmitSoundToAll(g_DeathSounds_Armor[GetRandomInt(0, sizeof(g_DeathSounds_Armor) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayRageOut()
 	{
		EmitSoundToAll(g_RageOut[GetRandomInt(0, sizeof(g_RageOut) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
		EmitSoundToAll(g_ExplodeSound[GetRandomInt(0, sizeof(g_ExplodeSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}

	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	property float m_flResumeAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public DemonPossesedArmor(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		DemonPossesedArmor npc;
		if(StrContains(data, "armor_only") != -1)
			npc = view_as<DemonPossesedArmor>(CClotBody(vecPos, vecAng, "models/bots/demo/bot_demo.mdl", "1.3", "1000", ally, false, true));
		else
			npc = view_as<DemonPossesedArmor>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.3", "1000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_MP_RUN_ITEM1");
		KillFeed_SetKillIcon(npc.index, "pickaxe");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_iHealthBar = 1;
		npc.m_flSpeed = 290.0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_armor_shoes/sbox2014_armor_shoes_demo.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/tw_demobot_helmet/tw_demobot_helmet.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/tw_demobot_armor/tw_demobot_armor.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);


		if(StrContains(data, "armor_only") != -1)
		{
			npc.m_bDissapearOnDeath = true;
			npc.m_iHealthBar = 0;
			npc.Anger = true;
			npc.m_iBleedType = BLEEDTYPE_METAL;
			npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 0, 0, 0, 0);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 0, 125, 0, 125);
			npc.m_flSpeed = 310.0;
		}
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.StartPathing();
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	DemonPossesedArmor npc = view_as<DemonPossesedArmor>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(!npc.Anger)
	{
		if(!npc.m_iHealthBar)
		{
			//No more healthbars remain. anger.
			npc.Anger = true;

			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			pos[2] += 20.0; //over stepheight
			//fix so they can jump
			int spawn_index = NPC_CreateByName("npc_demon_possesed_armor", -1, pos, ang, GetTeam(npc.index), "armor_only");
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				CClotBody npc1 = view_as<CClotBody>(spawn_index);
				npc1.m_flNextThinkTime = GetGameTime() + 0.5;
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				int health = ReturnEntityMaxHealth(npc.index);

				fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
				fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);

				float flPos[3];
				flPos = pos;
				flPos[2] += 250.0;
				flPos[0] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(100.0, 200.0);
				flPos[1] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(100.0, 200.0);
				npc1.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(spawn_index, flPos);

				if(IsValidEntity(npc.m_iWearable2))
					RemoveEntity(npc.m_iWearable2);
				
				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
				
				if(IsValidEntity(npc.m_iWearable4))
					RemoveEntity(npc.m_iWearable4);
			}

			npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/demo/demo_zombie.mdl");
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
			SetEntProp(npc.index, Prop_Send, "m_nSkin", 5);
			npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2024_defaced_style1/hwn2024_defaced_style1.mdl");
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

			npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2024_defaced_style2/hwn2024_defaced_style2.mdl");
			SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

			npc.m_flResumeAttack = gameTime + 1.0;
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			npc.SetActivity("ACT_DIEVIOLENT");
			npc.PlayRageOut();
			float vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			vecPos[2] -= 25.0;
			TE_Particle("mvm_hatch_destroy_smoke", vecPos, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);
			return;
		}
	}
	if(npc.m_flResumeAttack)
	{
		if(npc.m_flResumeAttack < gameTime)
		{
			npc.m_flResumeAttack = 0.0;
			npc.m_bisWalking = true;
			npc.m_flSpeed = 300.0;
			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_ITEM1");

		}
		return;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}
		Clot_SelfDefense(npc, distance, vecTarget, gameTime); 
	}

	npc.PlayIdleSound();
}

static void Clot_SelfDefense(DemonPossesedArmor npc, float distance, float vecTarget[3], float gameTime)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			npc.FaceTowards(vecTarget, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
			{
				int target = TR_GetEntityIndex(swingTrace);
				if(target > 0)
				{
					float damage = 170.0;
					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 2.0;
					}

					npc.PlayMeleeHitSound();
					SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

				}
			}

			delete swingTrace;
		}
	}

	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && npc.m_flNextMeleeAttack < gameTime)
	{
		int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, target, false, true))
		{
			npc.m_iTarget = target;

			if(npc.m_iBleedType != BLEEDTYPE_METAL)
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1",_,_,_, 0.85);
			else
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
			npc.PlayMeleeSound();
			
			npc.m_flAttackHappens = gameTime + 0.25;
			npc.m_flNextMeleeAttack = gameTime + 0.75;
		}
	}
}
static void ClotDeath(int entity)
{
	DemonPossesedArmor npc = view_as<DemonPossesedArmor>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(npc.m_iBleedType == BLEEDTYPE_METAL)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		makeexplosion(-1, pos, 0, 0);
	}
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
}



static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	DemonPossesedArmor npc = view_as<DemonPossesedArmor>(victim);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}