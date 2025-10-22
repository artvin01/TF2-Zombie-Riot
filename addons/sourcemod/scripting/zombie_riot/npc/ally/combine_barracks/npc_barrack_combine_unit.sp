#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = 
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSound[][] = 
{
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSound[][] = 
{
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};


static char g_IdleAlertedSounds[][] = 
{
	"npc/metropolice/vo/chuckle.wav",
};

static const char g_RangedAttackSounds[][] = 
{
	"weapons/capper_shoot.wav",
};

void Barracks_Combine_Chaos_Containment_Unit_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Chaos Containment Unit");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_chaos_containment_unit");
	data.Func = ClotSummon;
	data.Category = Type_Ally;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Chaos_Containment_Unit(client, vecPos, vecAng);
}

methodmap Barrack_Chaos_Containment_Unit < BarrackBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.4, 60);
		

	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	
	public Barrack_Chaos_Containment_Unit(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Chaos_Containment_Unit npc = view_as<Barrack_Chaos_Containment_Unit>(BarrackBody(client, vecPos, vecAng, "800", COMBINE_CUSTOM_MODEL, STEPTYPE_COMBINE, _, _,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "pistol");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		func_NPCDeath[npc.index] = Barrack_Chaos_Containment_Unit_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Barrack_Chaos_Containment_Unit_OnTakeDamage;
		func_NPCThink[npc.index] = Barrack_Chaos_Containment_Unit_ClotThink;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_pistol.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/hwn2015_iron_lung/hwn2015_iron_lung.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		return npc;
	}
	
}


public void Barrack_Chaos_Containment_Unit_ClotThink(int iNPC)
{
	Barrack_Chaos_Containment_Unit npc = view_as<Barrack_Chaos_Containment_Unit>(iNPC);
	float GameTime = GetGameTime(npc.index);
	
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(PrimaryThreatIndex > 0)
		{			
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
			if(flDistanceToTarget < 250000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Target close enough to hit
					if(npc.m_flNextRangedAttack < GameTime)
					{
						if(npc.CmdOverride != Command_HoldPos)
						{
							npc.SetActivity("ACT_WALK_AIM_PISTOL");
						}
						else
						{
							npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
						}
						float damage = 600.0;
						float speed = 750.0;
						
						int CustomBullet = GetRandomInt(1, 100);	
						npc.m_iTarget = Enemy_I_See;
						KillFeed_SetKillIcon(npc.index, "pistol");
						npc.FaceTowards(vecTarget, 250000.0); //Snap to the enemy.
						if(npc.m_flNextMeleeAttack < GameTime)
						{
							NpcSpeechBubble(npc.index, "Commencing Eradication.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
							npc.m_flNextMeleeAttack = GameTime + 30.0;
						}
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
								
							if(CustomBullet >= 95)
							{	
								switch(GetRandomInt(1,4))
								{
									case 1:
									{
										damage *= 2;	// Heavy bullets (2x dmg)
									}
									case 2:
									{
										NPC_Ignite(target, npc.index, 3.0, -1); // Burning bullets
									}
									case 3:
									{
										float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
										npc.FireRocket(vPredictedPos, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage*2, 1), speed+100.0, "models/effects/combineball.mdl",0.5, _, _,GetClientOfUserId(npc.OwnerUserId)); // Explosive bullets
									}
									case 4:
									{
										if(b_thisNpcIsARaid[target])
										{
											damage *= 2.5; // raids are immune to the stun but take more dmg
										}
										else
										{
											FreezeNpcInTime(target, 0.5); // Concussive bullets
										}
									}
								}
								TR_GetEndPosition(vecHit, swingTrace);
								float origin[3], angles[3];
								view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
								ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
								
								npc.m_flNextRangedAttack = GameTime + (0.15 * npc.BonusFireRate);
								
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage, 1), DMG_BULLET, -1, _, vecHit);
								npc.PlayRangedAttackSound();
							}
								
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
							
							npc.m_flNextRangedAttack = GameTime + (0.15 * npc.BonusFireRate);
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage, 1), DMG_BULLET, -1, _, vecHit);
							npc.PlayRangedAttackSound();
						}
					}
					else
					{
						npc.m_flSpeed = 150.0;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 150.0,"ACT_IDLE_ANGRY_PISTOL", "ACT_RUN_PISTOL", 225000.0,_, true);
	}
}


public Action Barrack_Chaos_Containment_Unit_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Barrack_Chaos_Containment_Unit npc = view_as<Barrack_Chaos_Containment_Unit>(victim);

	float GameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < GameTime)
	{
		npc.m_flHeadshotCooldown = GameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Barrack_Chaos_Containment_Unit_NPCDeath(int entity)
{
	Barrack_Chaos_Containment_Unit npc = view_as<Barrack_Chaos_Containment_Unit>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


