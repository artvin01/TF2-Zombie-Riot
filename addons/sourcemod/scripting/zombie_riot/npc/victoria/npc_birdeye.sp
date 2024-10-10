#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] =
{
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/sniper_railgun_single_crit.wav",
	"weapons/sniper_railgun_single_crit_02.wav"
};

void Birdeye_OnMapStart_NPC()
{
	PrecacheSoundArray(g_MeleeAttackSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Wildingen Hitman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_Birdeye");
	strcopy(data.Icon, sizeof(data.Icon), "sniper_headshot");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MISSION;
	data.Category = Type_BlueParadox;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Birdeye(client, vecPos, vecAng, ally);
}

methodmap Birdeye < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public Birdeye(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Birdeye npc = view_as<Birdeye>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "50000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_PRIMARY");

		KillFeed_SetKillIcon(npc.index, "headshot");

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = view_as<Function>(Birdeye_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Birdeye_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Birdeye_ClotThink);
		
		npc.m_iChanged_WalkCycle = 0;

		npc.m_flNextMeleeAttack = GetGameTime() + 5.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		Is_a_Medic[npc.index] = true;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bStaticNPC = true;
		npc.g_TimesSummoned = 0;

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Birdeye_ClotDamaged_Post);
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/cc_summer2015_the_rotation_sensation_style2/cc_summer2015_the_rotation_sensation_style2_sniper.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/spr17_down_under_duster/spr17_down_under_duster.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2020_gourd_grin/hwn2020_gourd_grin_sniper.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, _, _, _, 1.0);	
				for(int client_check=1; client_check<=MaxClients; client_check++)
				{
					if(IsClientInGame(client_check) && !IsFakeClient(client_check))
					{
						SetGlobalTransTarget(client_check);
						ShowGameText(client_check, "voice_player", 1, "%t", "Elite sniper has appeared");
					}
				}
			}
			LastSpawnDiversio = GetGameTime() + 20.0;
			TeleportDiversioToRandLocation(npc.index,_,1750.0, 1250.0);
		}
		
		return npc;
	}
}

public void Birdeye_ClotThink(int iNPC)
{
	Birdeye npc = view_as<Birdeye>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

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

	if(Rogue_InSetup())
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
		}
		return;
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ExtraBehavior = BirdeyeSelfDefense(npc,GetGameTime(npc.index)); 

		switch(ExtraBehavior)
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
					npc.m_flSpeed = 100.0;
				}	
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}
			}
		}

		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
	}
}

public Action Birdeye_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Birdeye npc = view_as<Birdeye>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Birdeye_NPCDeath(int entity)
{
	Birdeye npc = view_as<Birdeye>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Birdeye_ClotDamaged_Post);
		
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

public void Birdeye_ClotDamaged_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Birdeye npc = view_as<Birdeye>(victim);
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		
		float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
		if(0.5-(npc.g_TimesSummoned*0.2) > ratio)
		{
			TeleportDiversioToRandLocation(npc.index,_,1750.0, 1250.0);
			npc.g_TimesSummoned++;
		}
	}
	else
	{
		fl_TotalArmor[npc.index] = 1.0;
	}
}

int BirdeyeSelfDefense(Birdeye npc, float gameTime)
{
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
			{
				return 0;
			}		
		}
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			return 0;
		}
	}
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 15000.0);

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3], angles[3];
	view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			 WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			/*
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			*/
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, {255,0,0,255}, 3);
		TE_SendToAll(0.0);
	}
			
	npc.FaceTowards(ThrowPos[npc.index], 15000.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, ThrowPos[npc.index], false );
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;	
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			if(IsValidEnemy(npc.index, target))
			{
				SDKHooks_TakeDamage(target, npc.index, npc.index, 500.0, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				if(!dieingstate[target] && IsPlayerAlive(target))
					TF2_AddCondition(target, TFCond_MarkedForDeath, 60.0);
			} 
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.m_flAttackHappens = gameTime + 1.25;
		npc.m_flDoingAnimation = gameTime + 1.25;
		npc.m_flNextMeleeAttack = gameTime + 6.0;
	}
	return 1;
}