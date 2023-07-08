#pragma semicolon 1
#pragma newdecls required

static const char g_RangedAttackSounds[][] = {
	"weapons/rocket_shoot.wav",
};
static const char g_IdleSounds[][] =
{
	"vo/taunts/Soldier_taunts01.mp3",
	"vo/taunts/Soldier_taunts09.mp3",
	"vo/taunts/Soldier_taunts14.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/taunts/Soldier_taunts19.mp3",
	"vo/taunts/Soldier_taunts20.mp3",
	"vo/taunts/Soldier_taunts21.mp3",
	"vo/taunts/Soldier_taunts18.mp3",
};
static const char g_RangedReloadSound[][] = {
	"weapons/dumpster_rocket_reload.wav",
};


public void Barrack_Alt_Barrager_MapStart()
{
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++)			{ PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) 			{ PrecacheSound(g_RangedReloadSound[i]);	}
	
	PrecacheModel("models/player/Soldier.mdl");
}

static int i_ammo_count[MAXENTITIES];
static bool b_we_are_reloading[MAXENTITIES];
static float fl_idle_timer[MAXENTITIES];

methodmap Barrack_Alt_Barrager < BarrackBody
{

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
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public Barrack_Alt_Barrager(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Barrack_Alt_Barrager npc = view_as<Barrack_Alt_Barrager>(BarrackBody(client, vecPos, vecAng, "250", "models/player/Soldier.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcInternalId[npc.index] = ALT_BARRACK_BARRAGER;
		i_NpcWeight[npc.index] = 1;
		
		SDKHook(npc.index, SDKHook_Think, Barrack_Alt_Barrager_ClotThink);

		npc.m_flSpeed = 175.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		i_ammo_count[npc.index]=10;
		b_we_are_reloading[npc.index]=false;
		fl_idle_timer[npc.index] = 2.0 + GetGameTime(npc.index);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/soldier/soldier_officer.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 125, 100, 100, 255);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Barrager_ClotThink(int iNPC)
{
	Barrack_Alt_Barrager npc = view_as<Barrack_Alt_Barrager>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(i_ammo_count[npc.index]==0 && !b_we_are_reloading[npc.index])	//the npc will prefer to fully reload the clip before attacking, unless the target is too close.
		{
			b_we_are_reloading[npc.index]=true;
		}
		if(fl_idle_timer[npc.index] <= GameTime && npc.m_flReloadIn<GameTime && !b_we_are_reloading[npc.index] && i_ammo_count[npc.index]<25)	//reload if not attacking/idle for long
		{
			npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
			npc.m_flReloadIn = 0.5* npc.BonusFireRate + GameTime;
			i_ammo_count[npc.index]++;
			npc.PlayRangedReloadSound();
		}
		if(i_ammo_count[npc.index]>=25)	//npc will stop reloading once clip size is full.
		{
			b_we_are_reloading[npc.index]=false;
		}
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(i_ammo_count[npc.index]==0 || b_we_are_reloading[npc.index])	//Run away if ammo is 0 or we are reloading. Don't run if target is too close
			{
				
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
				{
					BarrackBody_ThinkMove(npc.index, 175.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_RUN_PRIMARY", 999999.0, _, false);
				}
			}
			else if(flDistanceToTarget < 750000 && i_ammo_count[npc.index]>0)
			{
				BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_RUN_PRIMARY", 700000.0, _, false);
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				fl_idle_timer[npc.index] = 2.5 + GameTime;
				//Can we attack right now?
				int Enemy_I_See;		
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_flNextMeleeAttack < GameTime && i_ammo_count[npc.index] >0)
					{
						float flPos[3]; // original
						float flAng[3]; // original
						GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
						//Play attack anim
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1200.0);
						npc.FaceTowards(vecTarget, 20000.0);
						npc.PlayRangedSound();
						//npc.FireRocket(vecTarget, 500.0 * npc.BonusDamageBonus, 1200.0, _, _, _, _, GetClientOfUserId(npc.OwnerUserId));
						npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 375.0, 1) ,  1200.0, 200.0 , "raygun_projectile_blue", true , false, true, flPos,_, GetClientOfUserId(npc.OwnerUserId));
						npc.m_flNextMeleeAttack = GameTime + 0.45* npc.BonusFireRate;
						npc.m_flReloadIn = GameTime + 1.25* npc.BonusFireRate;
						i_ammo_count[npc.index]--;
					}
				}
			}
			else
			{
				BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_RUN_PRIMARY", 700000.0, _, false);
			}
		}
		else
		{
			BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_RUN_PRIMARY", 700000.0, _, false);
			npc.PlayIdleSound();
		}
	}
}

void Barrack_Alt_Barrager_NPCDeath(int entity)
{
	Barrack_Alt_Barrager npc = view_as<Barrack_Alt_Barrager>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, Barrack_Alt_Barrager_ClotThink);
}
