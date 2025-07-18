#pragma semicolon 1
#pragma newdecls required

static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
static const char g_IdleSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static char g_PullSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav",
};

static int Ikunagae_BEAM_Laser;
static float fl_self_heal_timer[MAXENTITIES];

public void Barrack_Alt_Shwertkrieg_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++)			{ PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);  			}
	Ikunagae_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", true);
	Zero(fl_self_heal_timer);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks SchwertKrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_schwertkrieg");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Shwertkrieg(client, vecPos, vecAng);
}

methodmap Barrack_Alt_Shwertkrieg < BarrackBody
{
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
		

	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
		
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		NpcSpeechBubble(this.index, "", 5, {255,255,255,255}, {0.0,0.0,60.0}, "...");
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		NpcSpeechBubble(this.index, "", 5, {255,255,255,255}, {0.0,0.0,60.0}, "!!!");
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public Barrack_Alt_Shwertkrieg(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Shwertkrieg npc = view_as<Barrack_Alt_Shwertkrieg>(BarrackBody(client, vecPos, vecAng, "1250", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 2;

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Shwertkrieg_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Shwertkrieg_ClotThink;

		npc.m_flSpeed = 350.0;
				
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
		fl_self_heal_timer[npc.index] = GetGameTime(npc.index) + 1.0;
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Shwertkrieg_ClotThink(int iNPC)
{
	Barrack_Alt_Shwertkrieg npc = view_as<Barrack_Alt_Shwertkrieg>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		
		
		float Health =float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
		float MaxHealth =  float(ReturnEntityMaxHealth(npc.index));
			
		if(npc.m_flNextTeleport < GameTime)
		{
			float teleport_target_vec[3];
			float teletime;
			int type;
			bool teleport = false;
			
			int command = Command_Aggressive;
			int npc_owner = GetClientOfUserId(npc.OwnerUserId);
			if(!IsValidClient(npc_owner))
			{
				npc.m_flNextTeleport = GameTime + 300.0;
			}
			
			command = npc.CmdOverride == Command_Default ? Building_GetFollowerCommand(npc_owner) : npc.CmdOverride;
			if(command==Command_Aggressive)
			{
				type = 2;
			}
			else if(command==Command_Defensive)
			{
				type = 3;
			}
			else if(command==Command_Retreat || command==Command_RetreatPlayer)
			{
				type = 4;
			}
			if(command == Command_HoldPos || command == Command_HoldPosBarracks)
			{
				type = 5;
			}
			bool vaild = false;
			float vecTarget[3];
			if(PrimaryThreatIndex>0)
			{
				vaild = true;
				WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			}
			
			
			switch(type)
			{
				case 2:	//aggresive
				{
					if(vaild)
					{
						float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);		
						float target_dist = GetVectorDistance(WorldSpaceVec, vecTarget);
						if (target_dist < 2500.0)	//target is within range, Murder
						{
							teletime = 20.0;
							teleport = true;
							teleport_target_vec = vecTarget;
							//CPrintToChatAll("aggresive tele");
							teleport_target_vec[2] += 200.0;
						}
						else
						{
							teleport = false;
							npc.m_flNextTeleport = GameTime + 1.0;
						}
						
					}
					else
					{
						teleport = false;
						npc.m_flNextTeleport = GameTime + 1.0;
					}
				}
				case 3:	//defensive
				{
					if(vaild)
					{
						float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
						float target_dist = GetVectorDistance(WorldSpaceVec, vecTarget);
						if (target_dist < 300.0)	//target is within range, Murder
						{
							//CPrintToChatAll("Defensive tele");
							teletime = 20.0;
							teleport = true;
							teleport_target_vec = vecTarget;
							teleport_target_vec[2] += 200.0;
						}
						else	//not within range, ignore
						{
							teleport = false;
							npc.m_flNextTeleport = GameTime + 1.0;
						}
					}
					else
					{
						teleport = false;
						npc.m_flNextTeleport = GameTime + 1.0;
					}
				}
				case 4:	//retreat to player
				{
					
					//CPrintToChatAll("retreat tele");
					teletime = 20.0;
					teleport = true;
					WorldSpaceCenter(npc_owner, teleport_target_vec);
					
					teleport_target_vec[2] += 200.0;
				}
				case 5:	//if hold position, do nothing
				{
					teleport = false;
					npc.m_flNextTeleport = GameTime + 2.5;
				}
			}
			
			if(teleport)
			{
				
				
				npc.FaceTowards(teleport_target_vec);
				npc.FaceTowards(teleport_target_vec);
				float current_loc[3]; WorldSpaceCenter(npc.index, current_loc);
				npc.m_flNextTeleport = GameTime + teletime * npc.BonusFireRate;
				float Tele_Check = GetVectorDistance(current_loc, teleport_target_vec);
				
				//TE_SetupBeamPoints(current_loc, teleport_target_vec, Ikunagae_BEAM_Laser, 0, 0, 0, 2.5, 10.0, 10.0, 0, 1.0, {145, 47, 47, 255}, 3);
				//TE_SendToAll(0.0);
				
				if(Tele_Check > 120.0)
				{
					//CPrintToChatAll("tele checked");
					bool Succeed = NPC_Teleport(npc.index, teleport_target_vec);
					if(Succeed)
					{
						npc.PlayTeleportSound();
						
						float time = 1.0;
						WorldSpaceCenter(npc.index, current_loc);
						spawnRing_Vectors(current_loc, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, time, 4.0, 0.1, 1, 1.0);
						Explode_Logic_Custom(Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),6000.0, 1), GetClientOfUserId(npc.OwnerUserId), npc.index, -1, current_loc, 325*2.0 ,_,0.8, false);
						current_loc[2] -= 500.0;
						float sky_loc[3]; sky_loc = current_loc; sky_loc[2] += 5000.0;
						TE_SetupBeamPoints(current_loc, sky_loc, Ikunagae_BEAM_Laser, 0, 0, 0, 2.5, 10.0, 10.0, 0, 1.0, {145, 47, 47, 255}, 3);
						TE_SendToAll(0.0);
						
					}
					else
					{
						npc.m_flNextTeleport = GameTime + 0.5;
						//CPrintToChatAll("tele failed");
					}
				}
			}
		}
			
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.m_flAttackHappens = GameTime + (0.3 * npc.BonusFireRate);
						npc.m_flAttackHappens_bullshit = GameTime + (0.54 * npc.BonusFireRate);
						npc.m_flAttackHappenswillhappen = true;
						fl_self_heal_timer[npc.index] = GameTime + 1.0;
					}
						
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
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
								SDKHooks_TakeDamage(PrimaryThreatIndex, npc.index, GetClientOfUserId(npc.OwnerUserId), Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),7500.0, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + 0.8 * npc.BonusFireRate;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.8 * npc.BonusFireRate;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		
		}
		if(fl_self_heal_timer[npc.index]<GameTime)	//npc heal's for 1% of there hp per second
		{
				
				int Heal_Amt = RoundToFloor((MaxHealth / 100.0)*1.0);
				if(Health+Heal_Amt < MaxHealth)
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToFloor(Health) + Heal_Amt);
				}

				fl_self_heal_timer[npc.index] = GameTime + 1.0;
		}
		BarrackBody_ThinkMove(npc.index, 350.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 3000.0, _, false);
	}
}

void Barrack_Alt_Shwertkrieg_NPCDeath(int entity)
{	
	Barrack_Alt_Shwertkrieg npc = view_as<Barrack_Alt_Shwertkrieg>(entity);
		
	BarrackBody_NPCDeath(npc.index);
}