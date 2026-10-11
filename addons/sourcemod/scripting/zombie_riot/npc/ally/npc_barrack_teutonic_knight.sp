#pragma semicolon 1
#pragma newdecls required

// Balanced around Mid Spy

static float Revive[MAXENTITIES];
static int IsDowned[MAXENTITIES];

public void BarrackTeutonOnMapStart()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Teutonic Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_teutonic_knight");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackTeuton(client, vecPos, vecAng);
}

methodmap BarrackTeuton < BarrackBody
{
	property float m_flBurstDamage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flBurstTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flDefBackupCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flValiantCharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	public BarrackTeuton(int client, float vecPos[3], float vecAng[3])
	{
		BarrackTeuton npc = view_as<BarrackTeuton>(BarrackBody(client, vecPos, vecAng, "2600",COMBINE_CUSTOM_2_MODEL,_,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackTeuton_NPCDeath;
		func_NPCThink[npc.index] = BarrackTeuton_ClotThink;
		func_NPCOnTakeDamage[npc.index] = BarrackTeuton_OnTakeDamage;
		npc.m_flSpeed = 250.0;
		b_NpcUnableToDie[npc.index] = true;
		
		npc.Anger = false;	//	Used to tell whether the Teutonic Knight is using "Valiant Charge" or not
		
		npc.m_flBurstDamage = 0.0;	//	Used for damage calculation
		npc.m_flBurstTimer = 0.0;	//	Used for the time frame within the teutonic knight has the anti-burst ability active
		npc.m_flDefBackupCooldown = 0.0;	// Used for the effective cooldown of the ability
		npc.m_flValiantCharge = 0.0;	// Used for the cooldown of his charge ability
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/dec17_brass_bucket/dec17_brass_bucket.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		return npc;
	}
}

public void BarrackTeuton_ClotThink(int iNPC)
{
	BarrackTeuton npc = view_as<BarrackTeuton>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(IsDowned[npc.index] && Revive[npc.index] && Revive[npc.index] < GameTime)	// Revive
	{
		SetDownedState_Teutonic(npc.index, false);
		DesertYadeamDoHealEffect(npc.index, 200.0);
	}
	if(npc.m_flValiantCharge < GameTime && !npc.Anger)	// If the cooldown is ready and he's not already pissed (cause otherwise it's just a permanent loop) trigger his charge ability
	{
		if(!IsDowned[npc.index])
		{
			npc.Anger = true;
			IgniteTargetEffect(npc.m_iWearable1);
			npc.AddGesture("ACT_WF_OVERLORD_RAGE_START");
			NpcSpeechBubble(npc.index, "Now you've done it", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			npc.m_flNextMeleeAttack = GameTime + 2.0;
			npc.m_flReloadDelay = GameTime + 2.0;
			npc.m_iChanged_WalkCycle = 0;
		}
	}
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(npc.Anger)	// Is he pissed?
			{
				if(npc.CmdOverride == Command_HoldPos && npc.m_flNextMeleeAttack < GameTime)	// Remove the lock in position (also prevent him going in hold position, he's charging not holding a parade ffs)
				{
					npc.CmdOverride == Command_Default;
				}
				if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
				{
					if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
					{
						if(!npc.m_flAttackHappenswillhappen)
						{
							npc.m_flNextRangedSpecialAttack = GameTime + 2.0;
							npc.AddGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_RAGE", _,_,_, 1.1);
							npc.PlaySwordSound();
							npc.m_flAttackHappens = GameTime + 0.3;
							npc.m_flAttackHappens_bullshit = GameTime + 0.44;
							npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
							npc.m_flAttackHappenswillhappen = true;
						}
							
						if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
						{
							Handle swingTrace;
							npc.FaceTowards(vecTarget, 20000.0);
							if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
							{
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								float RageDamage = Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 27000.0, 0);
								
								if(target > 0) 
								{
									if(b_thisNpcIsARaid[target])	// 33% more damage to raid but won't burn
										RageDamage *= 1.33;
										
									Explode_Logic_Custom(RageDamage, GetClientOfUserId(npc.OwnerUserId), npc.index, -1, vecTarget , 250.0, 1.0, _, true, .FunctionToCallBeforeHit = RaidOrNot);	// Aoe but small range
									npc.PlaySwordHitSound();
									NpcSpeechBubble(npc.index, "...die", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
									
									npc.Anger = false;
									npc.m_iChanged_WalkCycle = 0;
									ExtinguishTarget(npc.m_iWearable1);
									npc.m_flValiantCharge = GameTime + 30.0;	// Can't be reduced by attack speed, intentionally for these skills
								} 
							}
							delete swingTrace;
							npc.m_flAttackHappenswillhappen = false;
						}
						else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
						{
							npc.m_flAttackHappenswillhappen = false;
						}
					}
				}
			}
			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GameTime + 2.0;
						if(!ShouldNpcDealBonusDamage(npc.m_iTarget))
							npc.AddGesture("ACT_TEUTON_ATTACK_NEW", _,_,_, 1.1);
						else
							npc.AddGesture("ACT_TEUTON_ATTACK_CADE_NEW", _,_,_, 1.1);
						npc.PlaySwordSound();
						npc.m_flAttackHappens = GameTime + 0.3;
						npc.m_flAttackHappens_bullshit = GameTime + 0.44;
						npc.m_flNextMeleeAttack = GameTime + (1.0 * npc.BonusFireRate);
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							float damage = 13500.0;
							
							if(target > 0) 
							{
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}
		if(!npc.Anger)
			BarrackBody_ThinkMove(npc.index, 200.0, "ACT_TEUTON_IDLE_NEW", "ACT_TEUTON_WALK_NEW");
		else
			BarrackBody_ThinkMove(npc.index, 200.0, "ACT_WF_OVERLORD_RUN", "ACT_WF_OVERLORD_RUN_RAGE");
	}
}

void BarrackTeuton_NPCDeath(int entity)
{
	BarrackTeuton npc = view_as<BarrackTeuton>(entity);
	BarrackBody_NPCDeath(npc.index);
}

public Action BarrackTeuton_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	BarrackTeuton npc = view_as<BarrackTeuton>(victim);
	
	float Maxhealth = ReturnEntityMaxHealth(npc.index) + 0.0;
	float GameTime = GetGameTime();
	
	if(npc.m_flBurstTimer < GameTime)
	{
		npc.m_flBurstDamage = 0.0;
		npc.m_flBurstTimer = GameTime + 3.0;
	}
	if (npc.m_flBurstTimer > GameTime)
	{
		npc.m_flBurstDamage += damage;
	}
	
	if(npc.m_flBurstDamage >= Maxhealth * 0.5)
	{
		if(npc.m_flDefBackupCooldown < GameTime)
		{
			ApplyStatusEffect(npc.index, npc.index, "Savagery Buff", 5.0);

			npc.m_flDefBackupCooldown = GameTime + 30.0;

			NpcSpeechBubble(npc.index, "In HIS name, I shall not fall", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");

			npc.m_flBurstDamage = 0.0;
			npc.m_flBurstTimer = 30.0;
		}
	}
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	if (damage >= health)
	{
		damage = 0.0;
		IsDowned[npc.index] = 1;
		Revive[npc.index] = GetGameTime() + 90.0; // 90 seconds to revive

		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;

		SetEntProp(npc.index, Prop_Data, "m_iHealth", Maxhealth);
		SetDownedState_Teutonic(npc.index, true);
	}

	return Plugin_Changed;
}
void SetDownedState_Teutonic(int iNpc, bool StateDo)
{
	BarrackThorns npc = view_as<BarrackThorns>(iNpc);
	if(StateDo) // Make him go KO
	{
		npc.m_flNextMeleeAttack = FAR_FUTURE;
		npc.m_flAttackHappens = 0.0;
		IsDowned[iNpc] = 1;
		Revive[iNpc] = GetGameTime() + 90.0;
		b_ThisEntityIgnored[iNpc] = true;
		b_NpcIsInvulnerable[iNpc] = true;
		NpcSpeechBubble(npc.index, "Ugh... YOU DARE!", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
		npc.CmdOverride = Command_RetreatPlayer;	// Make him retreat to barrack user
	}
	else // Get him back up
	{
		if(IsDowned[iNpc])
		{
			IsDowned[iNpc] = 0;
		}
		npc.m_flNextMeleeAttack = GetGameTime() + 1.0;
		npc.m_flAttackHappens = 0.0;
		Revive[iNpc] = 0.0;
		b_ThisEntityIgnored[iNpc] = false;
		b_NpcIsInvulnerable[iNpc] = false;
		SetEntProp(iNpc, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(iNpc));	// Heal him back to full
		DesertYadeamDoHealEffect(iNpc, 200.0);
		NpcSpeechBubble(npc.index, "I feel better and now they'll pay for that.", 7, {50,205,50,255}, {0.0,0.0,120.0}, "");
		npc.CmdOverride = Command_Default;	// And now get back to default, no need for retreat anymore
	}
}
void RaidOrNot(int attacker, int victim)
{
	if(b_thisNpcIsARaid[victim])
	{
		Custom_Knockback(attacker, victim, 600.0, true);
		return;
	}
	
	BarrackTeuton npc = view_as<BarrackTeuton>(attacker);
	int owner = GetClientOfUserId(npc.OwnerUserId);
	float ChargeDamage = Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 36000.0, 0);
	float burnDamage = ChargeDamage * 0.1;	// 10% of the damage is translated into a burn (ONLY happens to non-raids)
	NPC_Ignite(victim, owner, 5.0, -1, burnDamage);
}
