#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"ambient/water/water_splash1.wav",
	"ambient/water/water_splash2.wav",
	"ambient/water/water_splash3.wav",
};

static const char g_HurtSounds[][] =
{
	"physics/surfaces/underwater_impact_bullet1.wav",
	"physics/surfaces/underwater_impact_bullet2.wav",
	"physics/surfaces/underwater_impact_bullet3.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"misc/octosteps/octosteps_01.wav",
	"misc/octosteps/octosteps_02.wav",
	"misc/octosteps/octosteps_03.wav",
	"misc/octosteps/octosteps_04.wav",
	"misc/octosteps/octosteps_05.wav",
	"misc/octosteps/octosteps_06.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"misc/high_five.wav",
};

static const char g_JumpSound[][] =
{
	"misc/ks_tier_01_death.wav",
};
static const char g_JumpSoundPrepare[][] =
{
	"misc/ks_tier_01_kill.wav",
};

void GlugOnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_JumpSound);
	PrecacheSoundArray(g_JumpSoundPrepare);
	PrecacheModel("models/props_coalmines/boulder3.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Glug");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_glug");
	strcopy(data.Icon, sizeof(data.Icon), "glug_slime");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Glug(vecPos, vecAng, team, data);
}

methodmap Glug < CClotBody
{
	property float m_flSpincooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flSpinDoAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property bool m_bAggressive
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 7.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayJumpSound()
 	{
		EmitSoundToAll(g_JumpSound[GetRandomInt(0, sizeof(g_JumpSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL - 5, _, NORMAL_ZOMBIE_VOLUME - 0.3, 100, .soundtime = GetGameTime() - 0.5);
	}
	public void PlayJumpPreapre()
 	{
		EmitSoundToAll(g_JumpSoundPrepare[GetRandomInt(0, sizeof(g_JumpSoundPrepare) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL - 5, _, NORMAL_ZOMBIE_VOLUME - 0.15, 100);
	}

	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, .soundtime = GetGameTime() - 1.35);
	}
	
	public Glug(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		float SizeDo = 1.0;
		Glug npc;
		if(StrContains(data, "small") != -1)
		{
			npc = view_as<Glug>(CClotBody(vecPos, vecAng, "models/props_coalmines/boulder3.mdl", "0.7", "1000", ally));
			SizeDo = 0.7;
			npc.Anger = true;
		}
		else
			npc = view_as<Glug>(CClotBody(vecPos, vecAng, "models/props_coalmines/boulder3.mdl", "1.0", "1000", ally));
		
		if (StrContains(data, "randomspawn") != -1)
			TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0);
		
		if (StrContains(data, "aggressive") != -1)
			npc.m_bAggressive = true;
		
		i_NpcWeight[npc.index] = 2;
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = 0;
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
	

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 0.0;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 165, 25, 200);
	//	SetEntityRenderColor(npc.index, GetRandomInt(0,255), GetRandomInt(0,255), GetRandomInt(0,255), 200);

		npc.m_iWearable1 = npc.EquipItemSeperate("models/workshop/player/items/all_class/jul13_sweet_shades/jul13_sweet_shades_heavy.mdl",_,_, 3.0 * SizeDo);
		float RandFloat[3];
		RandFloat[0] = -20.0 * SizeDo;
		RandFloat[1] = 0.0;
		RandFloat[2] = (13.0 * (1.0 / SizeDo));
		SDKCall_SetLocalOrigin(npc.m_iWearable1, RandFloat);	
		RandFloat[0] = 0.0;
		RandFloat[1] = 0.0;
		RandFloat[2] = GetRandomFloat(-15.0,15.0);
		SDKCall_SetLocalAngles(npc.m_iWearable1, RandFloat);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable1, GetRandomInt(0,16777215));

		npc.m_iWearable2 = npc.EquipItemSeperate("models/props_moonbase/moon_gravel_crystal_red.mdl",_,_, 1.75 * SizeDo);
		RandFloat[0] = 0.0;
		RandFloat[1] = 0.0;
		RandFloat[2] = (25.0 * SizeDo);
		SDKCall_SetLocalOrigin(npc.m_iWearable2, RandFloat);	
		RandFloat[0] = GetRandomFloat(-180.0,180.0);
		RandFloat[1] = GetRandomFloat(-180.0,180.0);
		RandFloat[2] = GetRandomFloat(-180.0,180.0);
		SDKCall_SetLocalAngles(npc.m_iWearable2, RandFloat);
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Glug npc = view_as<Glug>(iNPC);

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
		Clot_SelfDefense(npc, distance, vecTarget, gameTime); 
	}

	npc.PlayIdleSound();
}

static void Clot_SelfDefense(Glug npc, float distance, float vecTarget[3], float gameTime)
{
	if(npc.m_flSpincooldown < gameTime)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.0))
		{
			npc.m_flSpinDoAnim = gameTime + 0.25;
			npc.m_flSpincooldown = gameTime + 2.5;
			npc.PlayMeleeHitSound();
		}
	}
	if(npc.m_flSpinDoAnim)
	{
		npc.m_flNextThinkTime = gameTime + 0.03;
		float angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		angles[1] += 80.0;
		SDKCall_SetLocalAngles(npc.index, angles);
		if(npc.m_flSpinDoAnim < gameTime)
		{
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			Explode_Logic_Custom(200.0, 0, npc.index, 0, VecSelfNpc, 90.0);
			npc.m_flSpinDoAnim = 0.0;
			npc.FaceTowards(vecTarget, 15000.0);
		}
		return;
	}

	if(npc.m_flAttackHappens)
	{
		//lemme jump
		npc.FaceTowards(vecTarget, 15000.0);
		//ready to pounce
		float angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		angles[1] -= GetRandomFloat(-10.0, 10.0);
		SDKCall_SetLocalAngles(npc.index, angles);
		if(npc.m_flAttackHappens < gameTime)
		{
			float vecJumpTo[3];
			vecJumpTo = vecTarget;
			
			if (npc.m_bAggressive)
			{
				// Increase jump height based on distance, because being further away means it jumps straight ahead, which means less air time, which means shitty jumps
				vecJumpTo[2] += 70.0 * (distance / (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0));
				
				// As of time of writing, this should never happen, but if the npc is changed in the future, this prevents jumps from being weaker than they are supposed to be
				if (vecJumpTo[2] < vecTarget[2])
					vecJumpTo[2] = vecTarget[2];
			}
			
			PluginBot_Jump(npc.index, vecJumpTo, 600.0);
			npc.m_flAttackHappens = 0.0;
			npc.PlayJumpSound();
		}

	}
	
	// Always target somebody if the glug is aggressive
	if(npc.m_bAggressive || distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			int target;
			
			if (!npc.m_bAggressive)
				target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			else
				target = npc.m_iTarget;
			
			if(IsValidEnemy(npc.index, target, false, true))
			{
				npc.m_iTarget = target;

			//	npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 3.5;
				npc.PlayJumpPreapre();
			}
		}
	}
	else
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			float vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			vecPos[2] += 175.0;
			vecPos[0] += GetRandomFloat(-300.0, 300.0);
			vecPos[1] += GetRandomFloat(-300.0, 300.0);
			PluginBot_Jump(npc.index, vecPos);
			npc.m_flNextMeleeAttack = gameTime + 3.0;
			npc.FaceTowards(vecPos, 15000.0);
			npc.PlayJumpSound();
		}
	}
}
static void ClotDeath(int entity)
{
	Glug npc = view_as<Glug>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	if(!npc.Anger)
	{

		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		pos[2] += 20.0; //over stepheight
		//fix so they can jump
		for(int loop; loop < 3; loop++)
		{
			int spawn_index = NPC_CreateByName("npc_glug", -1, pos, ang, GetTeam(npc.index), "small");
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				Glug npc1 = view_as<Glug>(spawn_index);
				npc1.m_flNextThinkTime = GetGameTime() + 1.0;
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				int health = ReturnEntityMaxHealth(npc.index);

				fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
				fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", health / 2);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health / 2);

				float flPos[3];
				flPos = pos;
				flPos[2] += 250.0;
				flPos[0] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(100.0, 200.0);
				flPos[1] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(100.0, 200.0);
				npc1.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(spawn_index, flPos);
				
				npc1.m_bAggressive = npc.m_bAggressive;
			}
		}
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
	if(attacker > 0)
	{
		Huirgrajo npc = view_as<Huirgrajo>(victim);

		float gameTime = GetGameTime(npc.index);
		if(npc.m_flHeadshotCooldown < gameTime)
		{
			npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}
	}
}