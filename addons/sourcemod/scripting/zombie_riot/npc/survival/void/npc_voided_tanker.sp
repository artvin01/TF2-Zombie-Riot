#pragma semicolon 1 //passivly gains expi shield. attacks give void affliction
#pragma newdecls required //done

static const char g_DeathSounds[][] = {
	"vo/heavy_negativevocalization01.mp3",
	"vo/heavy_negativevocalization02.mp3",
	"vo/heavy_negativevocalization03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/heavy_helpmedefend01.mp3",
	"vo/heavy_helpmedefend02.mp3",
	"vo/heavy_helpmedefend03.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3"
};

static const char g_RangeAttackSounds[] = "weapons/shotgun_shoot.wav";

void VoidedTanker_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Voided Tanker");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_voided_tanker");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_tanker");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Void; 
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/heavy.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VoidedTanker(vecPos, vecAng, ally, data);
}

methodmap VoidedTanker < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound() 
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 85);
	}
	
	property float m_flTrueArmor
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flShieldRegenCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public VoidedTanker(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VoidedTanker npc = view_as<VoidedTanker>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "22000", ally));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = VoidedTanker_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VoidedTanker_OnTakeDamage;
		func_NPCThink[npc.index] = VoidedTanker_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "reserve_shooter");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flSpeed = 220.0;
		npc.m_flTrueArmor = 0.5;
		
		npc.m_flMeleeArmor = 0.9;
		npc.m_flRangedArmor = 0.9;
		
		npc.StartPathing();
		
		if(StrContains(data, "extraarmor") != -1)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "extraarmor", "");
			npc.m_flTrueArmor = StringToFloat(buffers[0]);
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 200, 0, 200, 255);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/pyro/bio_fireman.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum23_hog_heels/sum23_hog_heels.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/Robo_Heavy_Chief/Robo_Heavy_Chief.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/fall17_siberian_tigerstripe/fall17_siberian_tigerstripe.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);
		
		npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,1,1.1);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 200, 0, 200, 100);

		return npc;
	}
}

static void VoidedTanker_ClotThink(int iNPC)
{
	VoidedTanker npc = view_as<VoidedTanker>(iNPC);
	if(NpcStats_StrongVoidBuff(iNPC))
	{
		npc.m_flSpeed = 200.0;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 200, 0, 200, 125);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 125);
		}
		if(IsValidEntity(npc.m_iWearable2))
		{
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 125);
		}
		if(IsValidEntity(npc.m_iWearable3))
		{
			SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 125);
		}
		if(IsValidEntity(npc.m_iWearable4))
		{
			SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 125);
		}
		if(IsValidEntity(npc.m_iWearable5))
		{
			SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 125);
		}
		if(IsValidEntity(npc.m_iWearable6))
		{
			SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable6, 200, 0, 200, 125);
		}
		if(GetGameTime(npc.index) >= npc.m_flShieldRegenCD)
		{
		    npc.m_flShieldRegenCD = GetGameTime(npc.index) + 5.0;
			SensalGiveShield(npc.index, 2);
		}
	}
	if(NpcStats_WeakVoidBuff(iNPC))
	{
		npc.m_flSpeed = 210.0;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 200, 0, 200, 190);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 190);
		}
		if(IsValidEntity(npc.m_iWearable2))
		{
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 190);
		}
		if(IsValidEntity(npc.m_iWearable3))
		{
			SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 190);
		}
		if(IsValidEntity(npc.m_iWearable4))
		{
			SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 190);
		}
		if(IsValidEntity(npc.m_iWearable5))
		{
			SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 190);
		}
		if(IsValidEntity(npc.m_iWearable6))
		{
			SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable6, 200, 0, 200, 190);
		}
		if(GetGameTime(npc.index) >= npc.m_flShieldRegenCD)
		{
		    npc.m_flShieldRegenCD = GetGameTime(npc.index) + 5.0;
			SensalGiveShield(npc.index, 2);
		}
	}
	else
	{
		npc.m_flSpeed = 220.0;
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 200, 0, 200, 255);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
		}
		if(IsValidEntity(npc.m_iWearable2))
		{
			SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		}
		if(IsValidEntity(npc.m_iWearable3))
		{
			SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
		}
		if(IsValidEntity(npc.m_iWearable4))
		{
			SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
		}
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

	float TrueArmor = 1.0;
	if(NpcStats_VestanCallToArms(npc.index))
		TrueArmor *= npc.m_flTrueArmor;
	fl_TotalArmor[npc.index] = TrueArmor;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VoidedTankerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget))
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VoidedTanker_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VoidedTanker npc = view_as<VoidedTanker>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	int health = ReturnEntityMaxHealth(npc.index) / 5;

	if(damage > float(health))
	{
		damage = float(health);
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VoidedTanker_NPCDeath(int entity)
{
	VoidedTanker npc = view_as<VoidedTanker>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static int VoidedTankerSelfDefense(VoidedTanker npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangeSound();
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
					npc.m_flNextMeleeAttack = gameTime + 1.0;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 150.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						Elemental_AddVoidDamage(target, npc.index, 150, true, true);
					}
				}
				delete swingTrace;
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
			return 0;
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	return 0;
}
