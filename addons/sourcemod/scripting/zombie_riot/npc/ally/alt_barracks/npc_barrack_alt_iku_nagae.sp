#pragma semicolon 1
#pragma newdecls required

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
enum struct Basic_Barracks_Laser
{
	BarrackBody npc;
	float Radius;
	float Range;
	float Close_Dps;
	float Long_Dps;
	bool DoEffects;
	int Color[4];
}
void Basic_Barracks_Laser_Logic(Basic_Barracks_Laser Data)
{
	BarrackBody npc = Data.npc;
	float Radius = Data.Radius;
	float diameter = Radius*2.0;
	float Range = Data.Range;
	float Close_Dps =  Data.Close_Dps;
	float Long_Dps =  Data.Long_Dps;
	float Max_Dist = Range*Range;
	float TargetsHitFallOff = 1.0;
	int inflictor = GetClientOfUserId(npc.OwnerUserId);
	if(inflictor==-1)
		inflictor=npc.index;
	
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(Range);
	Laser.Radius = Radius;
	Laser.Enumerate_Simple();
	for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
	{
		//get victims from the "Enumerate_Simple"
		int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
		if(!victim)
			break;	//no more targets are left, break the loop!

		float playerPos[3];
		GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
		float Dist = GetVectorDistance(Laser.Start_Point, playerPos, true);	//make is squared for optimisation sake

		float Ratio = Dist / Max_Dist;
		float damage = Close_Dps + (Long_Dps-Close_Dps) * Ratio;

		//somehow negative damage. invert.
		if (damage < 0)
			damage *= -1.0;

		float Base_Damage = (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage, 1));
		
		SDKHooks_TakeDamage(victim, npc.index, inflictor, Base_Damage*TargetsHitFallOff, DMG_PLASMA);	// 2048 is DMG_NOGIB?
		TargetsHitFallOff *= LASER_AOE_DAMAGE_FALLOFF;
	}

	if(!Data.DoEffects)
		return;

	if(IsValidEntity(npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.FaceTowards(vecTarget, 20000.0);
		}
	}
	
	GetAttachment(npc.index, "effect_hand_r", Laser.Start_Point, NULL_VECTOR);
	
	BeamEffects(Laser.Start_Point, Laser.End_Point,  Data.Color, diameter);
}

static void BeamEffects(float startPoint[3], float endPoint[3], int color[4], float diameter)
{
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[3]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, color[3]);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, color[0], color[1], color[2], color[3]);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
	TE_SendToAll(0.0);
}
void Barracks_Body_Pitch(CClotBody npc, float VecSelfNpc[3], float vecTarget[3])
{
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;		

	//Body pitch
	float v[3], ang[3];
	SubtractVectors(VecSelfNpc, vecTarget, v); 
	NormalizeVector(v, v);
	GetVectorAngles(v, ang); 
	
	float flPitch = npc.GetPoseParameter(iPitch);
	
	npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
}

void Barrack_Alt_Ikunagae_MapStart()
{
	PrecacheSoundArray(g_DefaultCapperShootSound);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Ikunagae");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_ikunagae");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Ikunagae(client, vecPos, vecAng);
}

static float fl_npc_basespeed;

methodmap Barrack_Alt_Ikunagae < BarrackBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property float m_flNorm_Attack_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
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
		EmitSoundToAll(g_DefaultCapperShootSound[GetRandomInt(0, sizeof(g_DefaultCapperShootSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public Barrack_Alt_Ikunagae(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Ikunagae npc = view_as<Barrack_Alt_Ikunagae>(BarrackBody(client, vecPos, vecAng, "450", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Ikunagae_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Ikunagae_ClotThink;

		fl_npc_basespeed = 250.0;
		npc.m_flSpeed = 250.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
	
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_vampiric_vesture/sf14_vampiric_vesture.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable1, 7, 255, 255, 255);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		npc.m_flNorm_Attack_Duration = 0.0;
		return npc;
	}
}

static void Barrack_Alt_Ikunagae_ClotThink(int iNPC)
{
	Barrack_Alt_Ikunagae npc = view_as<Barrack_Alt_Ikunagae>(iNPC);
	float GameTime = GetGameTime(iNPC);

	if(npc.m_flNorm_Attack_Duration>GameTime)
	{
		IkuNormAttackTick(npc);
	}

	if(!BarrackBody_ThinkStart(npc.index, GameTime))
		return;

	int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
	int PrimaryThreatIndex = npc.m_iTarget;

	if(PrimaryThreatIndex < 0)
	{
		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 225000.0, _, false);
		npc.PlayIdleSound();
		return;
	}

	npc.PlayIdleAlertSound();
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

	Barracks_Body_Pitch(npc, VecSelfNpc, vecTarget);

	if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		BarrackBody_ThinkMove(npc.index, 275.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 9999.0, _, false);
		//Look at target so we hit.
	//	npc.FaceTowards(vecTarget, 1000.0);
		
		//Can we attack right now?
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			//Play attack ani
			if (!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
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
						SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),4000.0, 0), DMG_CLUB, -1, _, vecHit);
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
	else
	{
		if(npc.m_bAllowBackWalking)
			npc.FaceTowards(vecTarget);

		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 290000.0, _, false);
		if(flDistanceToTarget < 300000)
		{
			npc.m_bAllowBackWalking = true;
			if(npc.m_flNextMeleeAttack < GameTime)
			{
				npc.PlayPullSound();
				npc.m_flNextMeleeAttack = GameTime + 2.0 * npc.BonusFireRate;
				npc.AddGesture("ACT_MP_THROW");
				npc.FaceTowards(vecTarget, 40000.0);
				npc.m_flNorm_Attack_Duration = GameTime + 0.25;
			}
		}
		else
		{
			npc.m_bAllowBackWalking = false;
		}

		npc.StartPathing();
	}
	int Enemy_I_See;		
	Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
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
			npc.m_flSpeed = 0.0;
			npc.FaceTowards(vecTarget, 30000.0);
			//Play attack anim
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
			npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),3000.0, 1) , speed+100.0 , 100.0 , "raygun_projectile_blue_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
			if (npc.m_iAmountProjectiles >= 10)
			{
				npc.m_iAmountProjectiles = 0;
				npc.m_flNextRangedBarrage_Spam = GameTime + 10.0 * npc.BonusFireRate;
			}
		}
	}

	if(npc.m_flNextMeleeAttack > GameTime)
	{
		npc.m_flSpeed = 10.0;
	}
	else
	{
		npc.m_flSpeed = fl_npc_basespeed;
	}
	
}

void Barrack_Alt_Ikunagae_NPCDeath(int entity)
{
	Barrack_Alt_Ikunagae npc = view_as<Barrack_Alt_Ikunagae>(entity);
	BarrackBody_NPCDeath(npc.index);
}
static void IkuNormAttackTick(Barrack_Alt_Ikunagae npc)
{
	Basic_Barracks_Laser Data;
	Data.npc = npc;
	Data.Radius = 4.0;
	Data.Range = 800.0;
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = 3000.0 / 6.0 / TickrateModify;
	Data.Long_Dps = 1500.0 / 6.0 / TickrateModify;
	Data.Color = {171, 218, 247, 30};
	Data.DoEffects = true;
	Basic_Barracks_Laser_Logic(Data);
}
