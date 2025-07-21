#pragma semicolon 1
#pragma newdecls required

static int i_overcharge[MAXENTITIES];


static const char g_RangedAttackSounds[][] =
{
	"weapons/csgo_awp_shoot.wav",
};
static const char g_ICastFuckYou[][] = // Caber see?
{
	"vo/demoman_no01.mp3",
};
static const char g_DeathSounds[][] =
{
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath05.mp3",
};
static const char g_IdleSounds[][] =
{
	"vo/demoman_autocappedcontrolpoint01.mp3",
	"vo/demoman_autocappedcontrolpoint02.mp3",
	"vo/demoman_item_unicorn_uber03.mp3",
	"vo/demoman_autodejectedtie04.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/demoman_autoonfire01.mp3",
	"vo/demoman_sf13_bosses05.mp3",
	"vo/demoman_sf13_bosses06.mp3",
	"vo/demoman_autoonfire03.mp3",
};

public void Barracks_Iberia_Commando_Precache() // Arrivati qui
{
	PrecacheModel("models/player/demo.mdl");
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_ICastFuckYou);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Iberian Commando");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_commando");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Iberia_Commando(client, vecPos, vecAng);
}

methodmap Barrack_Iberia_Commando < BarrackBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.2, 100);
	}
	public void Iberia_Play_Demo_Fuck_You()
	{
		EmitSoundToAll(g_ICastFuckYou[GetRandomInt(0, sizeof(g_ICastFuckYou) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5, 100);
	}
	public Barrack_Iberia_Commando(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Iberia_Commando npc = view_as<Barrack_Iberia_Commando>(BarrackBody(client, vecPos, vecAng, "400", "models/player/demo.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		i_NpcWeight[npc.index] = 1;

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Iberia_Commando_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Iberia_Commando_ClotThink;

		npc.m_flSpeed = 150.0;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/spr17_blast_defense/spr17_blast_defense.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/dec17_blast_blocker/dec17_blast_blocker.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/demo/demo_chest_back.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
	
		i_overcharge[npc.index] = 0;
		
		return npc;
	}
}

public void Barrack_Iberia_Commando_ClotThink(int iNPC)
{
	Barrack_Iberia_Commando npc = view_as<Barrack_Iberia_Commando>(iNPC);
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
			
			if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen) // If there's an enemy nearby and the caber isn't on cooldown, it's caber time
			{
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 9999.0, _, false);
					ResetCommandoWeapon(npc, 1);
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.Iberia_Play_Demo_Fuck_You();  // NO!
						npc.m_flNextRangedAttack = GameTime + 1.0;
						npc.m_flAttackHappens = GameTime + (0.3 * npc.BonusFireRate);
						npc.m_flAttackHappens_bullshit = GameTime + (0.54 * npc.BonusFireRate);
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
								
							float damage = 7500.0;

							if(target > 0) 
							{			
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 0), DMG_CLUB, -1, _, vecHit);	
								EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);
								npc.m_flNextMeleeAttack = GameTime + (30.0 * npc.BonusFireRate); // Caber cooldown, can be reduced with atk speed
								ResetCommandoWeapon(npc, 0);
								
								if(b_thisNpcIsARaid[target])
								{
									Custom_Knockback(npc.index, target, 450.0, true);  // Raids are less affected from the knockback and won't get stunned
								}
								else
								{
									Custom_Knockback(npc.index, target, 600.0, true);
									FreezeNpcInTime(target, 1.0); // Stuns normal enemies
								}
							}
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						ResetCommandoWeapon(npc, 0);
					}
				}
			}
			if(flDistanceToTarget < 175000.0)
			{
				//Can we attack right now?
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				{
				//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See))
					{
						if(npc.m_flNextRangedAttack < GameTime)
						{
							npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2", false);
							npc.m_iTarget = Enemy_I_See;
							npc.PlayRangedSound();
							npc.FaceTowards(vecTarget, 200000.0);
							Handle swingTrace;
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
							{
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								float origin[3], angles[3];
								view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
								ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
							
								npc.m_flNextRangedAttack = GameTime + (0.2 * npc.BonusFireRate);
							
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 800.0, 1), DMG_BULLET, -1, _, vecHit);
							} 		
							delete swingTrace;				
						}
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 150.0, "ACT_MP_COMPETITIVE_WINNERSTATE", "ACT_MP_RUN_PRIMARY", 150000.0,_, true);
		if(npc.m_flNextRangedAttack > GameTime)
		{
			npc.m_flSpeed = 100.0;
		}
		else
		{
			npc.m_flSpeed = 150.0;
		}
	}
}

void Barrack_Iberia_Commando_NPCDeath(int entity)
{
	Barrack_Iberia_Commando npc = view_as<Barrack_Iberia_Commando>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayDeathSound();
}

void ResetCommandoWeapon(Barrack_Iberia_Commando npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 0:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl");
			SetVariantString("1.5");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_caber/c_caber.mdl");
			SetVariantString("4.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
	}
}