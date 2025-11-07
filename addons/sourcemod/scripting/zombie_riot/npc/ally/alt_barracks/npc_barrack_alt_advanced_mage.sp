#pragma semicolon 1
#pragma newdecls required

static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

static int i_barrage[MAXENTITIES];
static float fl_barragetimer[MAXENTITIES];
static float fl_singularbarrage[MAXENTITIES];

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

static float fl_npc_basespeed;

public void Barrack_Alt_Advanced_Mage_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Advanced Mage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_advanced_mage");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Advanced_Mage(client, vecPos, vecAng);
}

methodmap Barrack_Alt_Advanced_Mage < BarrackBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
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
	public Barrack_Alt_Advanced_Mage(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Advanced_Mage npc = view_as<Barrack_Alt_Advanced_Mage>(BarrackBody(client, vecPos, vecAng, "250", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Advanced_Mage_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Advanced_Mage_ClotThink;

		npc.m_flSpeed = 200.0;
		fl_npc_basespeed = 200.0;
		
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/C_Crossing_Guard/C_Crossing_Guard.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Robe/Xms2013_Medic_Robe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Hood/Xms2013_Medic_Hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Advanced_Mage_ClotThink(int iNPC)
{
	
	Barrack_Alt_Advanced_Mage npc = view_as<Barrack_Alt_Advanced_Mage>(iNPC);
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


			int Enemy_I_See;		
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			
			if(fl_barragetimer[npc.index] <= GetGameTime(npc.index) && fl_singularbarrage[npc.index] <= GetGameTime(npc.index))
			{	
				SetEntityRenderMode(npc.m_iWearable3, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable3, 1, 1, 1, 1);

				i_barrage[npc.index]++;
				
				float Angles[3], distance = 100.0, UserLoc[3];
				
				
				GetAbsOrigin(npc.index, UserLoc);
				
				MakeVectorFromPoints(UserLoc, vecTarget, Angles);
				GetVectorAngles(Angles, Angles);
				
				
				if(flDistanceToTarget < 70000 && IsValidEnemy(npc.index, Enemy_I_See))	//Target is close, we do wide attack
				{
					Angles[1]-=22.5;
					
					for(int alpha=1 ; alpha<=5 ; alpha++)	//Shoot 5 rockets dependant on the stuff above this
					{
							
					float tempAngles[3], endLoc[3], Direction[3];
					tempAngles[0] = -32.5;
					tempAngles[1] = Angles[1] + 9 * alpha;
					tempAngles[2] = 0.0;
							
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, distance);
					AddVectors(UserLoc, Direction, endLoc);
					npc.FaceTowards(vecTarget, 30000.0);
					//Play attack anim
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					npc.FireParticleRocket(endLoc, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 1750.0, 1) , 850.0 , 100.0 , "raygun_projectile_blue", _ , false, _,_,_, GetClientOfUserId(npc.OwnerUserId));
					npc.PlayRangedSound();
					fl_barragetimer[npc.index] = GameTime + 10.0 * npc.BonusFireRate;
					}
				}
			}
			if(flDistanceToTarget < 300000 && IsValidEnemy(npc.index, Enemy_I_See))
			{
				if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime)
				{	
					npc.m_iAmountProjectiles += 1;
					npc.m_flNextRangedBarrage_Singular = GameTime + 0.1;
					npc.PlayRangedSound();
							
					float flPos[3]; // original
					float flAng[3]; // original
					GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
					
					float speed = 750.0;
					PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, speed,_,vecTarget);
					npc.m_flSpeed = 0.0;
					npc.FaceTowards(vecTarget, 30000.0);
					//Play attack anim
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),475.0, 1) , speed+100.0 , 100.0 , "raygun_projectile_blue_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
					if (npc.m_iAmountProjectiles >= 10)
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GameTime + 6.0 * npc.BonusFireRate;
						npc.m_flReloadDelay = GameTime + (1.0 * npc.BonusFireRate);
					}
				}
			}
			
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 225000.0, _, false);

		if(npc.m_flNextRangedBarrage_Spam > GameTime)
		{
			npc.m_flSpeed = 10.0;
		}
		else
		{
			npc.m_flSpeed = fl_npc_basespeed;
		}
	}
}

void Barrack_Alt_Advanced_Mage_NPCDeath(int entity)
{
	Barrack_Alt_Advanced_Mage npc = view_as<Barrack_Alt_Advanced_Mage>(entity);
	BarrackBody_NPCDeath(npc.index);
}
