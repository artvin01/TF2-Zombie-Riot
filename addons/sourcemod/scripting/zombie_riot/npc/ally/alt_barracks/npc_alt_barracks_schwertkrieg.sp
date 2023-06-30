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
}

methodmap Barrack_Alt_Shwertkrieg < BarrackBody
{
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPullSound()");
		#endif
	}
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
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public Barrack_Alt_Shwertkrieg(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Barrack_Alt_Shwertkrieg npc = view_as<Barrack_Alt_Shwertkrieg>(BarrackBody(client, vecPos, vecAng, "1750", "models/player/medic.mdl", STEPTYPE_NORMAL));
		
		i_NpcInternalId[npc.index] = ALT_BARRACKS_SCHWERTKRIEG;
		i_NpcWeight[npc.index] = 2;
		
		SDKHook(npc.index, SDKHook_Think, Barrack_Alt_Shwertkrieg_ClotThink);

		npc.m_flSpeed = 350.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("root", flPos, flAng);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		/*SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);*/
		
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
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(npc.m_flNextTeleport < GameTime && flDistanceToTarget < Pow(1250.0, 2.0))
			{
					npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					float current_loc[3]; current_loc = WorldSpaceCenter(npc.index);
					npc.m_flNextTeleport = GameTime + 5.0 * npc.BonusFireRate;
					float Tele_Check = GetVectorDistance(current_loc, vecTarget);
					
					if(Tele_Check > 100.0)
					{
						bool Succeed = NPC_Teleport(npc.index, vecTarget);
						if(Succeed)
						{
							npc.PlayTeleportSound();
							
							float time = 1.0;
							current_loc = WorldSpaceCenter(npc.index);
							spawnRing_Vectors(current_loc, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, time, 4.0, 0.1, 1, 1.0);
							Explode_Logic_Custom(Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),15000.0, 1), GetClientOfUserId(npc.OwnerUserId), npc.index, -1, current_loc, 1250*2.0 ,_,0.8, false);
							current_loc[2] -= 500.0;
							float sky_loc[3]; sky_loc = current_loc; sky_loc[2] += 5000.0;
							TE_SetupBeamPoints(current_loc, sky_loc, Ikunagae_BEAM_Laser, 0, 0, 0, 2.5, 10.0, 10.0, 0, 1.0, {145, 47, 47, 255}, 3);
							TE_SendToAll(0.0);
							
						}
						else
						{
							npc.m_flNextTeleport = GameTime + 0.1;
						}
					}
			}
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
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
						npc.m_flAttackHappens = GameTime+0.4 * npc.BonusFireRate;
						npc.m_flAttackHappens_bullshit = GameTime+0.54 * npc.BonusFireRate;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							
							if(target > 0) 
							{
								SDKHooks_TakeDamage(PrimaryThreatIndex, npc.index, GetClientOfUserId(npc.OwnerUserId), Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),17500.0, 0), DMG_CLUB, -1, _, vecHit);
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
			
			if(fl_self_heal_timer[npc.index]<GameTime)	//if the npc is idle they heal for 1% of there hp per second
			{
				int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
				int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
				
				int Heal_Amt = RoundToFloor((MaxHealth / 100.0)*1.0);
				if(Health+Heal_Amt < MaxHealth)
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", Health + Heal_Amt);
				}

				fl_self_heal_timer[npc.index] = GameTime + 1.0;
			}
		}
		BarrackBody_ThinkMove(npc.index, 350.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 7500.0, _, false);
	}
}

void Barrack_Alt_Shwertkrieg_NPCDeath(int entity)
{	
	Barrack_Alt_Shwertkrieg npc = view_as<Barrack_Alt_Shwertkrieg>(entity);
		
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, Barrack_Alt_Shwertkrieg_ClotThink);
}
static void spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}