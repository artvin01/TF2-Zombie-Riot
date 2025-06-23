#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_IdleSounds[][] =
{
	"vo/spy_meleedare01.mp3",
	"vo/spy_meleedare02.mp3",
};


static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/ambassador_shoot.wav",
};
static const char g_IdleAlertedSounds[][] =
{
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

void Barrack_Iberia_Inquisitor_Lynsen_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheModel("models/player/spy.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberia Inquisitor Lynsen");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_inquisitor");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Iberia_Inquisitor_Lynsen(client, vecPos, vecAng);
}

methodmap Barrack_Iberia_Inquisitor_Lynsen < BarrackBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		

	}
	
	public void PlayNPCDeath() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public Barrack_Iberia_Inquisitor_Lynsen(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Iberia_Inquisitor_Lynsen npc = view_as<Barrack_Iberia_Inquisitor_Lynsen>(BarrackBody(client, vecPos, vecAng, "750", "models/player/spy.mdl", STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Inquisitor_Lynsen_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Inquisitor_Lynsen_ClotThink;
		npc.m_flSpeed = 300.0;
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_iAttacksTillReload = 0;

		KillFeed_SetKillIcon(npc.index, "revolver");
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_spiral.mdl", "", skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2022_turncoat/hwn2022_turncoat.mdl", "", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/short2014_all_mercs_mask/short2014_all_mercs_mask_spy.mdl");
		return npc;
	}
}

public void Barrack_Iberia_Inquisitor_Lynsen_ClotThink(int iNPC)
{
	Barrack_Iberia_Inquisitor_Lynsen npc = view_as<Barrack_Iberia_Inquisitor_Lynsen>(iNPC);
	float GameTime = GetGameTime(iNPC);
	GrantEntityArmor(iNPC, true, 0.5, 0.66, 0);
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
			
			if(npc.m_iAttacksTillReload < 30) //	Combo attack not ready
			{
				if(flDistanceToTarget < 200000.0)	// Ranged mode
				{
					int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See))
					{
						if(npc.m_flNextRangedAttack < GameTime)
						{
							npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
							npc.m_iTarget = Enemy_I_See;
							npc.PlayRangedSound();
							npc.FaceTowards(vecTarget, 150000.0);
							Handle swingTrace;
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
							{
								int target = TR_GetEntityIndex(swingTrace);	
							
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								float origin[3], angles[3];
								view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
								ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
						
								npc.m_flNextRangedAttack = GameTime + (1.0 * npc.BonusFireRate);
								npc.m_iAttacksTillReload ++;
								if(NpcStats_IberiaIsEnemyMarked(target))
								{
									npc.m_flNextRangedAttack = GameTime + (0.5 * npc.BonusFireRate);
									npc.m_iAttacksTillReload --;
								}
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 4000.0, 1), DMG_BULLET, -1, _, vecHit);
							} 		
							delete swingTrace;				
						}
					}
				}
			}
			else	// The inquisitor special attack is ready
			{
				BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_MELEE", 4000.0,_, true); // Run at higher speed and go for melee, "I'm not going to stab you"
				ResetInquisitorWeapon(npc, 1);
				if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
				{
					if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
					{
						if(!npc.m_flAttackHappenswillhappen)
						{
							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							npc.PlayMeleeSound();
							npc.m_flAttackHappens = GameTime + 0.3;
							npc.m_flAttackHappens_bullshit = GameTime + 0.44;
							npc.m_flNextMeleeAttack = GameTime + (1.5 * npc.BonusFireRate);
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
							
								if(target > 0) 
								{
									SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),7500.0, 0), DMG_CLUB, -1, _, vecHit);
									npc.PlayMeleeHitSound();
									
									npc.m_iAttacksTillReload = 0;
									ResetInquisitorWeapon(npc, 0);
									Custom_Knockback(npc.index, target, 500.0, true);
									EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);
									ApplyStatusEffect(npc.index, target, "Marked", 4.0);
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
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_SECONDARY", 175000.0,_, true);
	}
}

void Barrack_Iberia_Inquisitor_Lynsen_NPCDeath(int entity)
{
	Barrack_Iberia_Inquisitor_Lynsen npc = view_as<Barrack_Iberia_Inquisitor_Lynsen>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}   

void ResetInquisitorWeapon(Barrack_Iberia_Inquisitor_Lynsen npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 0:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		}
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
		}
	}
}