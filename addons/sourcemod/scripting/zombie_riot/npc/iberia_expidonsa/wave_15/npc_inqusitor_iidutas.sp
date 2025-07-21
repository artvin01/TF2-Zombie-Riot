#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/ambassador_shoot.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};
void Iberia_inqusitor_iidutas_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Inquisitor IIdutas");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_inqusitor_iidutas");
	strcopy(data.Icon, sizeof(data.Icon), "shattertide");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Iberiainqusitor_iidutas(vecPos, vecAng, team);
}
methodmap Iberiainqusitor_iidutas < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
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
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	
	public Iberiainqusitor_iidutas(float vecPos[3], float vecAng[3], int ally)
	{
		Iberiainqusitor_iidutas npc = view_as<Iberiainqusitor_iidutas>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "15000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.m_iChanged_WalkCycle = 2;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Iberiainqusitor_iidutas_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Iberiainqusitor_iidutas_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Iberiainqusitor_iidutas_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 320.0;
		npc.m_iAttacksTillReload = 0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/spy/spy_charmers_chapeau.mdl");
		SetEntityRenderColor(npc.m_iWearable1, 125, 125, 125, 255);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_spy.mdl");
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/dec23_strasbourg_scholar/dec23_strasbourg_scholar.mdl");
		SetEntityRenderColor(npc.m_iWearable4, 125, 125, 125, 255);
		SetEntityRenderColor(npc.index, 125, 125, 125, 255);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

public void Iberiainqusitor_iidutas_ClotThink(int iNPC)
{
	Iberiainqusitor_iidutas npc = view_as<Iberiainqusitor_iidutas>(iNPC);
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
		int ActionDo = Iberiainqusitor_iidutasSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(ActionDo)
		{
			case 0:
			{
				npc.StartPathing();
				//We run at them.
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
				npc.m_flSpeed = 320.0;
				npc.m_bAllowBackWalking = false;
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
				npc.m_flSpeed = 250.0;
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

public Action Iberiainqusitor_iidutas_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Iberiainqusitor_iidutas npc = view_as<Iberiainqusitor_iidutas>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Iberiainqusitor_iidutas_NPCDeath(int entity)
{
	Iberiainqusitor_iidutas npc = view_as<Iberiainqusitor_iidutas>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
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

int Iberiainqusitor_iidutasSelfDefense(Iberiainqusitor_iidutas npc, float gameTime, int target, float distance)
{
	if(npc.m_iAttacksTillReload >= 1)
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);

			npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.StartPathing();
		}	
		npc.Anger = false;

		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
					npc.m_iTarget = Enemy_I_See;
					npc.PlayRangedSound();
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.m_iWearable3).GetAttachment("muzzle", origin, angles);
						ShootLaser(npc.m_iWearable3, "bullet_tracer02_blue", origin, vecHit, false );
						npc.m_flNextMeleeAttack = gameTime + 0.75;
						npc.m_iAttacksTillReload --;
						if(NpcStats_IberiaIsEnemyMarked(target))
						{
							npc.m_flNextMeleeAttack = gameTime + 0.2;
						}

						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 35.5;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 6.5;


							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						}
					}
					delete swingTrace;
				}
				else
				{
					//cant see.
					return 0;
				}
			}
		}
		else
		{
			//too far away.
			return 0;
		}
		//they have more then 1 bullet, use gunmode.
		//Do backoff code, but only on wave 16+
		return 1;
	}
	//we use our melee.
	if(npc.m_iChanged_WalkCycle != 2)
	{
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl");
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 2;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.StartPathing();
	}	
	
	if(npc.m_flDoingAnimation < gameTime)
	{
		if(IsValidEntity(npc.m_iWearable3))
		{
			if(!npc.Anger)
			{
				IgniteTargetEffect(npc.m_iWearable3);
				npc.Anger = true;
			}
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable3))
		{
			if(npc.Anger)
			{
				ExtinguishTarget(npc.m_iWearable3);
				npc.Anger = false;
			}
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				npc.m_flNextMeleeAttack = gameTime + 0.5;
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 65.0;
					
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 4.0;

					int DamageType = DMG_CLUB;
					if(!NpcStats_IsEnemySilenced(npc.index))
						DamageType |= DMG_PREVENT_PHYSICS_FORCE;

					//prevents knockback!
					//gimic of new wavetype, but silenceable.
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DamageType, -1, _, vecHit);
					npc.m_iAttacksTillReload += 6;
					npc.m_flNextMeleeAttack = gameTime + 0.2;

					bool DoEffect = false;
					if(npc.m_flDoingAnimation < gameTime)
					{
						if(target <= MaxClients)
						{
							vecHit[0] = 0.0;
							vecHit[1] = 0.0;
							vecHit[2] = 500.0;
							TeleportEntity(target, _, _, vecHit, true);
							EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);
							DoEffect = true;
						}
						else if(!b_NpcHasDied[target])
						{
							if(!HasSpecificBuff(target, "Solid Stance"))
							{
								FreezeNpcInTime(target, 2.0);
								
								WorldSpaceCenter(target, vecHit);
								vecHit[2] += 250.0; //Jump up.
								PluginBot_Jump(target, vecHit);
								EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);
								DoEffect = true;
							}
						}
						if(DoEffect)
						{
							npc.m_flDoingAnimation = gameTime + 10.0;
							float NewPos[3]; 
							GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", NewPos);
							spawnRing_Vectors(NewPos, 50.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 8.0, 8.0, 2);
							spawnRing_Vectors(NewPos, 50.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 8.0, 8.0, 2);
							spawnRing_Vectors(NewPos, 50.0 * 2.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.5, 8.0, 8.0, 2);
							ApplyStatusEffect(npc.index, target, "Marked", 12.0);
						}
						
					}
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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);
						
				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	return 0;
}