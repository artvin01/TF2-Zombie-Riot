#pragma semicolon 1
#pragma newdecls required


static char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_DeathSounds[][] = {
	")vo/medic_niceshot01.mp3",
	")vo/medic_niceshot02.mp3",
};

static char g_charge_sound[][] = {
	"player/taunt_wormshhg.wav",
};

static char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};
static char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static char g_AngerSounds[][] = {
	"vo/medic_cartgoingforwardoffense01.mp3",
	"vo/medic_cartgoingforwardoffense02.mp3",
	"vo/medic_cartgoingforwardoffense03.mp3",
	"vo/medic_cartgoingforwardoffense06.mp3",
	"vo/medic_cartgoingforwardoffense07.mp3",
	"vo/medic_cartgoingforwardoffense08.mp3",
};
static char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

static char gExplosive1;



#define THEOCRACY_MELEE_DMG 100.0			//50%<hp%
#define THEOCRACY_ANGERED_MELEE_DMG 125.0	//50%>hp%

#define THEOCRACY_BARRAGE_DMG 50.0
#define THEOCRACY_ANGERED_BARRAGE_DMG 75.0

//String Theory

#define THEOCRACY_STRING_THEORY_RANGE 750.0	//range is auto turned into squared.
#define THEOCRACY_STRING_THEORY_DMG_MULTI 1.0 //damage multi per target, 1= norma, 0.5 = half damage, 2 = 2 times dmg.
#define THEOCRACY_STRING_THEORY_DURATION 10.0

#define THEOCRACY_STRING_THEORY_BATTERY_COST 3000.0

#define THEOCRACY_PASSIVE_GAIN 20.0				//how much power gained per think
#define THEOCRACY_ANGERED_PASSIVE_GAIN 30.0

public void Theocracy_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Theocracy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_theocracy");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "eisenhard"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;			//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_charge_sound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheModel(LASERBEAM);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Theocracy(vecPos, vecAng, team);
}

methodmap Theocracy < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(4.0, 7.0);
		
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	public void PlayChargeSound() {
		EmitSoundToAll(g_charge_sound[GetRandomInt(0, sizeof(g_charge_sound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		
	}
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public Theocracy(float vecPos[3], float vecAng[3], int ally)
	{
		Theocracy npc = view_as<Theocracy>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "15000", ally));
		
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		i_NpcWeight[npc.index] = 1;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/demo/sf14_demo_cyborg/sf14_demo_cyborg.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/brutal_hair/brutal_hair_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_ramses_regalia/hw2013_ramses_regalia.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		npc.m_flSpeed = 330.0;

		npc.StartPathing();
		
		Theocracy_Create_Wings(npc.index);
		
		Ruina_Set_Heirarchy(npc.index, RUINA_MELEE_NPC);	//is a melee npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_MELEE_NPC, true, 15, 3);
		
		fl_rally_timer[npc.index] = GetGameTime(npc.index) + 5.0;
		b_rally_active[npc.index] = false;
		
		b_ruina_battery_ability_active[npc.index] = false;
		
		npc.m_flDoingAnimation = 0.0;
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		
		fl_ruina_battery_max[npc.index] = THEOCRACY_STRING_THEORY_BATTERY_COST;
		fl_ruina_battery[npc.index] = 0.0;
		npc.PlayChargeSound();
		Theocracy_String_Theory(EntIndexToEntRef(npc.index));
		
		npc.Anger = false;
		
		return npc;
	}
	
	
}


static void ClotThink(int iNPC)
{
	Theocracy npc = view_as<Theocracy>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
		
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime || npc.m_flDoingAnimation > GetGameTime())
	{
		return;
	}
	
	if(!b_ruina_battery_ability_active[npc.index])
	{
		Ruina_Add_Battery(npc.index, (npc.Anger ? THEOCRACY_ANGERED_PASSIVE_GAIN : THEOCRACY_PASSIVE_GAIN));
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(npc.m_flDoingAnimation<=GetGameTime())
			Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement
		
		Master_Apply_Defense_Buff(npc.index, 250.0, 5.0, 0.8);	//20% resistances
		Master_Apply_Speed_Buff(npc.index, 250.0, 5.0, 1.15);	//15% speed bonus, going bellow 1.0 will make npc's slower
		Master_Apply_Attack_Buff(npc.index, 250.0, 5.0, 0.1);	//10% dmg bonus
		Master_Apply_Shield_Buff(npc.index, 250.0, 0.5);	//50% block shield
		
		if(fl_rally_timer[npc.index]<=GameTime && !b_rally_active[npc.index])
		{
			Ruina_Master_Rally(npc.index, true);	//start rally
			fl_rally_timer[npc.index] = GameTime + 15.0;
			b_rally_active[npc.index] = true;
		}
		if(b_rally_active[npc.index] && fl_rally_timer[npc.index]<=GameTime)
		{
			Ruina_Master_Rally(npc.index, false);	//end rally
			fl_rally_timer[npc.index] = GameTime + 10.0;
			b_rally_active[npc.index] = false;
		}
		
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(npc.m_flNextRangedBarrage_Spam < GameTime)
		{	
			
			npc.StopPathing();
			
			npc.m_flSpeed = 0.0;
			
			i_NpcWeight[npc.index] = 999;

			npc.SetPlaybackRate(1.0);	
			npc.SetCycle(0.0);
					
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_yetipunch");
			npc.m_flRangedArmor = 0.5;
			npc.m_flMeleeArmor = 0.5;
			npc.m_flDoingAnimation = GetGameTime() + 6.25;

			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", FAR_FUTURE);	

			CreateTimer(3.6, Theocracy_Barrage_Anim, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
			
			CreateTimer(6.25, Theocracy_Barrage_Anim2, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
			
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
		
			
			npc.m_flNextRangedBarrage_Spam = GameTime + 30.0;

		}
				
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
					npc.m_flAttackHappens = GameTime+0.4;
					npc.m_flAttackHappens_bullshit = GameTime+0.54;
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
							Theocracy_Melee_Hit(npc.index, target, vecHit);
							
							// Hit sound
							npc.PlayMeleeHitSound();
							
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GameTime + 0.8;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GameTime + 0.8;
				}
			}
		}
		else
		{
			npc.StartPathing();
			
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}
static Action Theocracy_Barrage_Anim2(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Theocracy npc = view_as<Theocracy>(client);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.0;

		i_NpcWeight[npc.index] = 1;
		
		npc.m_flSpeed = 300.0;
		

		RemoveSpecificBuff(npc.index, "Solid Stance");
		
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	return Plugin_Handled;
}
static Action Theocracy_Barrage_Anim(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Theocracy npc = view_as<Theocracy>(client);
		npc.PlayRangedSound();
		float dmg;
		if(npc.Anger)
		{
			dmg = THEOCRACY_ANGERED_BARRAGE_DMG;
		}
		else
		{
			dmg = THEOCRACY_BARRAGE_DMG;
		}
		
		float npc_vec[3]; GetAbsOrigin(client, npc_vec); npc_vec[2] += 45.0;
		Explode_Logic_Custom(dmg*2.5, client, client, -1, npc_vec, 300.0);
		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
		TE_SetupExplosion(flPos, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();

		UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
		int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT];
		GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false);
		for(int i; i < sizeof(enemy_2); i++)
		{
			if(!enemy_2[i])
				continue;
			
			float target_vec[3]; GetAbsOrigin(enemy_2[i], target_vec);
				
			target_vec[2] += 45.0;
			
			float projectile_speed = 400.0;
			
			npc.FireParticleRocket(target_vec, dmg , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);	//shot 1 at where there going, 1 at where they are exactly
			
			PredictSubjectPositionForProjectiles(npc, enemy_2[i], projectile_speed, _,target_vec);
			
			npc.FireParticleRocket(target_vec, dmg , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);
		}
		
	}
	return Plugin_Handled;
}

static int i_detected_ends[30];
static void GetEntitiesForStringTheory(int entity, int victim, float damage, int weapon)
{
	for(int i=0 ; i < sizeof(i_detected_ends) ; i++)
	{
		if(!i_detected_ends[i])
		{
			i_detected_ends[i] = victim;
			break;
		}
	}
}
static void Theocracy_Melee_Hit(int client, int target, float vecHit[3])
{	
	Theocracy npc = view_as<Theocracy>(client);
	
	float dmg = (npc.Anger ? THEOCRACY_ANGERED_MELEE_DMG : THEOCRACY_MELEE_DMG);
	
	SDKHooks_TakeDamage(target, npc.index, npc.index, (ShouldNpcDealBonusDamage(target) ? dmg * 2.0 : dmg), DMG_CLUB, -1, _, vecHit);

	if(!b_ruina_battery_ability_active[npc.index])
		return;

	

	float range = THEOCRACY_STRING_THEORY_RANGE;

	Zero(i_detected_ends);
	Explode_Logic_Custom(0.0, npc.index, npc.index, 0, _, range, _, _, true, sizeof(i_detected_ends), false, _, GetEntitiesForStringTheory);

	int looped_amt = 0;
	for(int i = 0 ; i < sizeof(i_detected_ends) ; i++)
	{
		if(!i_detected_ends[i])	
			break;
		
		//don't count the enemy we just smacked.
		if(i_detected_ends[i] == target)
			continue;

		looped_amt++;
	}
	//no valid targets exist, abort abort abort.
	if(looped_amt <=0)
		return;

	int color[4]; Ruina_Color(color);

	float Thick_Start = GetRandomFloat(8.0, 16.0);
	float Thick_End =  GetRandomFloat(Thick_Start*0.5, Thick_Start);
	int laser = ConnectWithBeam(npc.m_iWearable1, target, color[0], color[1], color[2], Thick_Start, Thick_End, 2.35, BEAM_COMBINE_BLUE);
	if(IsValidEntity(laser))
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

	float Dmg_deal =(dmg/looped_amt) * THEOCRACY_STRING_THEORY_DMG_MULTI;
	
	int Laser_Origin = target;

	int offset = 0;
	for(int i = 0 ; i < sizeof(i_detected_ends) ; i++)
	{
		if(!i_detected_ends[i])	
			break;
		
		//don't count the enemy we just smacked.
		if(i_detected_ends[i] == target)
			continue;

		if(offset > 2)
		{
			Laser_Origin = i_detected_ends[i];
			offset = 0;
		}
		offset++;
		
		SDKHooks_TakeDamage(i_detected_ends[i], npc.index, npc.index, (ShouldNpcDealBonusDamage(i_detected_ends[i]) ? Dmg_deal * 2.0 : Dmg_deal), DMG_CLUB, -1, _, vecHit);

		if(AtEdictLimit(EDICT_NPC))
			continue;

		Thick_Start = GetRandomFloat(8.0, 16.0);
		Thick_End =  GetRandomFloat(Thick_Start*0.5, Thick_Start);
		laser = ConnectWithBeam(Laser_Origin, i_detected_ends[i], color[0], color[1], color[2], Thick_Start, Thick_End, 2.35, BEAM_COMBINE_BLUE);
		if(IsValidEntity(laser))
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	}
}
static int i_particle_wings_index[MAXENTITIES][10];
static int i_laser_wings_index[MAXENTITIES][10];

static void Theocracy_Create_Wings(int client)
{
	float flPos[3];
	float flAng[3];
	GetAttachment(client, "flag", flPos, flAng);
	
	
	int r, g, b;
	float f_start, f_end, amp;
	r = 255;
	g = 1;
	b = 1;
	f_start = 1.0;
	f_end = 1.0;
	amp = 1.0;
	
	int particle_0 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	
	int particle_1 = InfoTargetParentAt({0.0,15.0,-12.5}, "", 0.0);
	
	SetParent(particle_0, particle_1);
	
	
	//X axis- Left, Right	//this one im almost fully sure of
	//Y axis - Up down, for once
	//Z axis - Forward backwards.????????
	
	//ALL OF THESE ARE RELATIVE TO THE BACKPACK POINT THINGY, or well the viewmodel, but its easier to visualise if using the back
	//Left?


	//Right? probably right?
	int particle_2 = InfoTargetParentAt({-35.0, 10.5, 2.5}, "", 0.0);
	int particle_2_1 = InfoTargetParentAt({-90.0, 35.0, -5.0}, "", 0.0);
	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_2, particle_2_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_0, flPos);
	SetEntPropVector(particle_0, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_0, "flag",_);

	i_laser_wings_index[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_2, particle_1, r, g, b, f_start, f_end, amp, LASERBEAM));
	i_laser_wings_index[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_2_1, particle_2, r, g, b, f_start, f_end, amp, LASERBEAM));
	i_laser_wings_index[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_1, particle_2_1, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	i_particle_wings_index[client][0] = EntIndexToEntRef(particle_0);
	i_particle_wings_index[client][1] = EntIndexToEntRef(particle_1);
	i_particle_wings_index[client][2] = EntIndexToEntRef(particle_2);
	i_particle_wings_index[client][3] = EntIndexToEntRef(particle_2_1);
	
}
static void Theocracy_Destroy_Wings(int client)
{
	for(int wing=1 ; wing<=3 ; wing++)
	{
		int entity = EntRefToEntIndex(i_laser_wings_index[client][wing]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
	for(int particle=0 ; particle<=3 ; particle++)
	{
		int entity = EntRefToEntIndex(i_particle_wings_index[client][particle]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
}
static void Theocracy_String_Theory(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Theocracy npc = view_as<Theocracy>(client);
		b_ruina_battery_ability_active[client] = true;

		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);	

		float flPos[3]; // original
		npc.GetAttachment("", flPos, NULL_VECTOR);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "utaunt_poweraura_yellow_parent", npc.index, "", {0.0,0.0,0.0});
		
		float duration = THEOCRACY_STRING_THEORY_DURATION;
		
		fl_ruina_battery[client] = 0.0;
		
		if(npc.Anger)
		{
			duration = duration + (duration / 2);
		}
		CreateTimer(duration, Theocracy_String_Theory_Timer, ref, TIMER_FLAG_NO_MAPCHANGE);
	}
}
static Action Theocracy_String_Theory_Timer(Handle timer, int ref)
{
	int client =  EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Theocracy npc = view_as<Theocracy>(client);
		b_ruina_battery_ability_active[npc.index] = false;

		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
	}
	return Plugin_Handled;
	
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	Theocracy npc = view_as<Theocracy>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	if(!b_ruina_battery_ability_active[npc.index] && damagetype & DMG_CLUB)
	{
		Ruina_Add_Battery(npc.index, damage);
	}
	if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index] && !b_ruina_battery_ability_active[npc.index])
	{
		npc.PlayChargeSound();
		fl_ruina_battery[npc.index] = 0.0;
		Theocracy_String_Theory(EntIndexToEntRef(npc.index));
	}
	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();

		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Theocracy npc = view_as<Theocracy>(entity);
	
	Theocracy_Destroy_Wings(entity);

	npc.PlayDeathSound();

	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}




	
	