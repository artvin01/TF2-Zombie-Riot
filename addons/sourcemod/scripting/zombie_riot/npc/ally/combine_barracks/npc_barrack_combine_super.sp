#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav"
};


static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};
static const char g_IdleAlertedSounds[][] =
{
	"npc/metropolice/vo/airwatchsubjectis505.wav",
	"npc/metropolice/vo/allunitscloseonsuspect.wav",
	"npc/metropolice/vo/allunitsmovein.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/destroythatcover.wav"
};

static const char g_MeleeDeflectAttack[][] = {
	"physics/metal/metal_box_impact_bullet1.wav",
};

void Barracks_Combine_Super_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeDeflectAttack);
	
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Super");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_combine_super");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Combine_Super(client, vecPos, vecAng);
}

methodmap Barrack_Combine_Super < BarrackBody
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayDeflectSound() 
	{
		EmitSoundToAll(g_MeleeDeflectAttack[GetRandomInt(0, sizeof(g_MeleeDeflectAttack) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_MeleeDeflectAttack[GetRandomInt(0, sizeof(g_MeleeDeflectAttack) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
	}

	public Barrack_Combine_Super(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Combine_Super npc = view_as<Barrack_Combine_Super>(BarrackBody(client, vecPos, vecAng, "1100", COMBINE_CUSTOM_MODEL, STEPTYPE_COMBINE,"0.7",_,"models/pickups/pickup_powerup_knockout.mdl"));
		
		i_NpcWeight[npc.index] = 2;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Combine_Super_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Combine_Super_ClotThink;
		npc.m_flSpeed = 250.0;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_iAttacksTillReload = 0;

		KillFeed_SetKillIcon(npc.index, "fists");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/riflemans_rallycap/riflemans_rallycap_soldier.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 180, 180, 180, 255);
		
		return npc;
	}
}

public void Barrack_Combine_Super_ClotThink(int iNPC)
{
	Barrack_Combine_Super npc = view_as<Barrack_Combine_Super>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			//Target close enough to hit
			if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_iAttacksTillReload >= 27)
				{
					float damage = 3750.0;
					if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
					{					
						if(!npc.m_flAttackHappenswillhappen && npc.m_iAttacksTillReload == 27)
						{
							npc.AddGesture("ACT_COMBO1_BOBPRIME");
							npc.PlaySwordSound();
							npc.m_flReloadDelay = GameTime + (1.2 * npc.BonusFireRate);
							npc.m_flAttackHappens = GameTime + 0.5;
							npc.m_flAttackHappens_bullshit = GameTime + 0.7;
							npc.m_flNextMeleeAttack = GameTime + (1.2 * npc.BonusFireRate);
							npc.m_flAttackHappenswillhappen = true;
						}
						else if(!npc.m_flAttackHappenswillhappen && npc.m_iAttacksTillReload == 28)
						{
							npc.AddGesture("ACT_COMBO2_BOBPRIME");
							npc.PlaySwordSound();
							npc.m_flReloadDelay = GameTime + (1.2 * npc.BonusFireRate);
							npc.m_flAttackHappens = GameTime + 0.5;
							npc.m_flAttackHappens_bullshit = GameTime + 0.7;
							npc.m_flNextMeleeAttack = GameTime + (1.2 * npc.BonusFireRate);
							npc.m_flAttackHappenswillhappen = true;
						}
						else if(!npc.m_flAttackHappenswillhappen && npc.m_iAttacksTillReload == 29)
						{
							npc.AddGesture("ACT_COMBO3_BOBPRIME",_,_,_,1.5);
							npc.PlaySwordSound();
							npc.m_flReloadDelay = GameTime + (2.0 * npc.BonusFireRate);
							npc.m_flAttackHappens = GameTime + 1.0;
							npc.m_flAttackHappens_bullshit = GameTime + 1.2;
							npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
							npc.m_flAttackHappenswillhappen = true;
						}
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
								float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
								if(npc.m_iAttacksTillReload == 28)
								{
									damage *= 1.25;
								}
								else if(npc.m_iAttacksTillReload == 29)
								{
									damage *= 1.5;
								}
								Explode_Logic_Custom(Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 1), GetClientOfUserId(npc.OwnerUserId), npc.index, -1, vecMe, 100*2.0 ,_,0.8, false);
								npc.PlaySwordHitSound();
								npc.m_iAttacksTillReload ++;
								if(npc.m_iAttacksTillReload >=30)
								{
									npc.m_iAttacksTillReload = 0;
								}
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
				else
				{
					if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
					{
						if(!npc.m_flAttackHappenswillhappen)
						{
							switch(GetRandomInt(0,1))
							{
								case 0:
								{
									npc.AddGesture("ACT_BRAWLER_ATTACK_LEFT");
								}
								case 1:
								{
									npc.AddGesture("ACT_BRAWLER_ATTACK_RIGHT");
								}
							}
							npc.PlaySwordSound();
							npc.m_flAttackHappens = GameTime + 0.075;
							npc.m_flAttackHappens_bullshit = GameTime + 0.24;
							npc.m_flNextMeleeAttack = GameTime + (0.1 * npc.BonusFireRate);
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
									SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),1100.0, 0), DMG_CLUB, -1, _, vecHit);
									npc.PlaySwordHitSound();
									npc.m_iAttacksTillReload ++;
									if(npc.CmdOverride == Command_HoldPos) // If he's in position hold he cannot gain "points" towards the combo to avoid abuse
									{
										npc.m_iAttacksTillReload --;
									}
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
		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_BRAWLER_IDLE", "ACT_BRAWLER_RUN", 17500.0, _, false);
	}
}

void Barrack_Combine_Super_NPCDeath(int entity)
{
	Barrack_Combine_Super npc = view_as<Barrack_Combine_Super>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}