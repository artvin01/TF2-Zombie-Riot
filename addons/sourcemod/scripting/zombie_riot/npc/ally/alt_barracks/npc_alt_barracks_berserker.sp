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

public void Barrack_Alt_Berserker_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_TeleportSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Berserker");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_barrack_berserker");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Barrack_Alt_Berserker(client, vecPos, vecAng, ally);
}

methodmap Barrack_Alt_Berserker < BarrackBody
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
		

	}
	public Barrack_Alt_Berserker(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Barrack_Alt_Berserker npc = view_as<Barrack_Alt_Berserker>(BarrackBody(client, vecPos, vecAng, "600", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		
		i_NpcWeight[npc.index] = 2;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Berserker_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Berserker_ClotThink;

		npc.m_flSpeed = 250.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 7, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);	
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
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

public void Barrack_Alt_Berserker_ClotThink(int iNPC)
{
	Barrack_Alt_Berserker npc = view_as<Barrack_Alt_Berserker>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
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
					float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
					float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
					
					float damage = (800.0) * (1.0+(1-(Health/MaxHealth)));
					float speed = (0.25*npc.BonusFireRate) * (Health / MaxHealth)+0.2;
					/*
						Asuming:
						max hp: 1k
						current hp: 1.
						BonusFireRate: 0.25.

						total dps: 7993.502031
					*/
					//Play attack ani
					
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.m_flAttackHappens = GameTime+speed;
						npc.m_flAttackHappens_bullshit = GameTime+speed+0.1;
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
								SDKHooks_TakeDamage(target, npc.index, GetClientOfUserId(npc.OwnerUserId), Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + speed;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + speed;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE", "ACT_MP_RUN_MELEE", 7500.0, _, false);
	}
}

void Barrack_Alt_Berserker_NPCDeath(int entity)
{	
	Barrack_Alt_Berserker npc = view_as<Barrack_Alt_Berserker>(entity);
		
	BarrackBody_NPCDeath(npc.index);
}