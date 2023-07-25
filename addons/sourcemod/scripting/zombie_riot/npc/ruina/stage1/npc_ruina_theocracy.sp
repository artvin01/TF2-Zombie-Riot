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

static int i_LaserEntityIndex[MAXENTITIES+1]={-1, ...};


#define LASERBEAM "sprites/laserbeam.vmt"


#define THEOCRACY_MELEE_DMG 100.0			//50%<hp%
#define THEOCRACY_ANGERED_MELEE_DMG 125.0	//50%>hp%

#define THEOCRACY_BARRAGE_DMG 50.0
#define THEOCRACY_ANGERED_BARRAGE_DMG 75.0

//String Theory

#define THEOCRACY_STRING_THEORY_RANGE 750.0	//range is auto turned into squared.
#define THEOCRACY_STRING_THEORY_DMG_MULTI 1.0 //damage multi per target, 1= norma, 0.5 = half damage, 2 = 2 times dmg.
#define THEOCRACY_STRING_THEORY_DURATION 10.0

#define THEOCRACY_STRING_THEORY_BATTERY_COST 3000	//how much *in ticks* until the npc can use the ability. NOTE: each time the npc takes melee damage, the amount they took gets added to the battery

#define THEOCRACY_PASSIVE_GAIN 4				//how much power gained per think
#define THEOCRACY_ANGERED_PASSIVE_GAIN 6


static bool bl_string_theory_active[MAXENTITIES];
static int i_string_Theory_battery[MAXENTITIES];


public void Theocracy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));			i++) { PrecacheSound(g_HurtSounds[i]);			}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); 	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_charge_sound));		i++) { PrecacheSound(g_charge_sound[i]); 		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));		i++) { PrecacheSound(g_MeleeHitSounds[i]);		}
	for (int i = 0; i < (sizeof(g_AngerSounds));   		i++) { PrecacheSound(g_AngerSounds[i]);  		}
	for (int i = 0; i < (sizeof(g_DeathSounds));		i++) { PrecacheSound(g_DeathSounds[i]);			}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	PrecacheModel(LASERBEAM);
}

methodmap Theocracy < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(4.0, 7.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayChargeSound() {
		EmitSoundToAll(g_charge_sound[GetRandomInt(0, sizeof(g_charge_sound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
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
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public Theocracy(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Theocracy npc = view_as<Theocracy>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "15000", ally));
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		i_NpcInternalId[npc.index] = RUINA_THEOCRACY;
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Theocracy_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Theocracy_ClotThink);				
		
		
		
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
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		npc.m_flSpeed = 300.0;

		npc.StartPathing();
		
		Theocracy_Create_Wings(npc.index);
		
		Ruina_Set_Heirarchy(npc.index, 1);	//is a melee npc
		Ruina_Set_Master_Heirarchy(npc.index, true, false, true, 15, 3);
		
		fl_rally_timer[npc.index] = GetGameTime(npc.index) + 5.0;
		b_rally_active[npc.index] = false;
		
		bl_string_theory_active[npc.index] = false;
		
		npc.m_flDoingAnimation = 0.0;
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		
		i_string_Theory_battery[npc.index] = 0;
		npc.PlayChargeSound();
		Theocracy_String_Theory(EntIndexToEntRef(npc.index));
		
		npc.Anger = false;
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Theocracy_ClotThink(int iNPC)
{
	Theocracy npc = view_as<Theocracy>(iNPC);
	
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
		
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index) || npc.m_flDoingAnimation > GetGameTime(npc.index))
	{
		return;
	}
	
	if(!bl_string_theory_active[npc.index])
	{
		if(npc.Anger)
		{
			i_string_Theory_battery[npc.index] += THEOCRACY_ANGERED_PASSIVE_GAIN;
		}
		else
		{
			i_string_Theory_battery[npc.index] += THEOCRACY_PASSIVE_GAIN;
		}
		
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			
			if(npc.m_flDoingAnimation<=GetGameTime(npc.index))
				Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex);	//handles movement
			
			bool buff_array[3];
			buff_array[0] = true;
			buff_array[1] = true;
			buff_array[2] = true;
			float buff_array_amt[3];
			buff_array_amt[0] = 0.1;	//10% dmg bonus
			buff_array_amt[1] = 1.25;	//going bellow 1.0 will reduce speed
			buff_array_amt[2] = 0.1;	//10% dmg resist
			Apply_Master_Buff(npc.index, buff_array, 250.0, 5.0, buff_array_amt);
			
			if(fl_rally_timer[npc.index]<=GetGameTime(npc.index) && !b_rally_active[npc.index])
			{
				Ruina_Master_Rally(npc.index, true);	//start rally
				fl_rally_timer[npc.index] = GetGameTime(npc.index) + 15.0;
				b_rally_active[npc.index] = true;
			}
			if(b_rally_active[npc.index] && fl_rally_timer[npc.index]<=GetGameTime(npc.index))
			{
				Ruina_Master_Rally(npc.index, false);	//end rally
				fl_rally_timer[npc.index] = GetGameTime(npc.index) + 10.0;
				b_rally_active[npc.index] = false;
			}
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index))
			{	
				
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_flSpeed = 0.0;
				
				npc.SetPlaybackRate(1.0);	
				npc.SetCycle(0.0);
						
				npc.AddActivityViaSequence("taunt_yetipunch");
				npc.m_flRangedArmor = 0.5;
				npc.m_flMeleeArmor = 0.5;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 6.25;
				CreateTimer(3.6, Theocracy_Barrage_Anim, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
				
				CreateTimer(6.25, Theocracy_Barrage_Anim2, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
				
				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
			
				
				npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 30.0;

			}
					
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
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
								
								Theocracy_Melee_Hit(EntIndexToEntRef(npc.index), EntIndexToEntRef(target), vecHit);
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
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
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
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
		
		npc.m_flSpeed = 300.0;
		npc.m_bPathing = true;
		
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
		
		float npc_vec[3]; npc_vec = GetAbsOrigin(client); npc_vec[2] += 45.0;
		Explode_Logic_Custom(dmg*2.5, client, client, -1, npc_vec, 300.0);
		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
		TE_SetupExplosion(flPos, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
		
		for(int player=1 ; player<MAXTF2PLAYERS ; player++)	//get valid/within range players
		{
			if(IsValidClient(player) && IsClientInGame(player) && GetClientTeam(player)==2 && IsPlayerAlive(player) && TeutonType[player] == TEUTON_NONE && dieingstate[player] == 0)	//filter out: offline, blue/spec, dead, teuton, downed players!
			{
				float target_vec[3]; target_vec = GetAbsOrigin(player);
				
				target_vec[2] += 45.0;
				
				float projectile_speed = 400.0;
				
				npc.FireParticleRocket(target_vec, dmg , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);	//shot 1 at where there going, 1 at where they are exactly
				
				target_vec = PredictSubjectPositionForProjectiles(npc, player, projectile_speed);
				
				npc.FireParticleRocket(target_vec, dmg , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally])
			{
				float target_vec[3]; target_vec = GetAbsOrigin(ally);
					
				target_vec[2] += 45.0;
				
				float projectile_speed = 400.0;
				
				npc.FireParticleRocket(target_vec, dmg , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);
				
				target_vec = PredictSubjectPositionForProjectiles(npc, ally, projectile_speed);
				
				npc.FireParticleRocket(target_vec, dmg , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);
	
			}
		}
	}
	return Plugin_Handled;
}

static void Theocracy_Melee_Hit(int ref, int enemy, float vecHit[3])
{
	int client = EntRefToEntIndex(ref);
	int target = EntRefToEntIndex(enemy);
	
	Theocracy npc = view_as<Theocracy>(client);
	
	float dmg = THEOCRACY_MELEE_DMG;
	if(npc.Anger)
	{
		dmg = THEOCRACY_ANGERED_MELEE_DMG;
	}
	
	if(bl_string_theory_active[client])
	{
		float range = THEOCRACY_STRING_THEORY_RANGE;
		float damage_multi = THEOCRACY_STRING_THEORY_DMG_MULTI;
		range *= range; //turn into square.
		
		int valid_entity = 0;
		bool valid_target[MAXENTITIES];	//what?
		bool red_npc = false;
		float flAng[3]; // original
		float npc_loc[3];
		GetAttachment(client, "effect_hand_r", npc_loc, flAng);
		
		for(int player=1 ; player<MAXTF2PLAYERS ; player++)	//get valid/within range players
		{
			if(IsValidClient(player) && IsClientInGame(player) && GetClientTeam(player)==2 && IsPlayerAlive(player) && TeutonType[player] == TEUTON_NONE && dieingstate[player] == 0)	//filter out: offline, blue/spec, dead, teuton, downed players!
			{
				float target_vec[3]; target_vec = GetAbsOrigin(player);
				float dist=GetVectorDistance(npc_loc, target_vec, true);
				
				if(dist<=range)
				{
					valid_entity++;
					valid_target[player] = true;
				}
				else
				{
					valid_target[player] = false;
				}
			}
		}
		for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
		{
			int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
			if (IsValidEntity(ally) && !b_NpcHasDied[ally])
			{
				float target_vec[3]; target_vec = GetAbsOrigin(ally);
				float dist=GetVectorDistance(npc_loc, target_vec, true);
				
				if(dist<=range)
				{
					red_npc = true;
					valid_entity++;
					valid_target[ally] = true;
				}
				else
				{
					valid_target[ally] = false;
				}
			}
		}
		int last_entity=npc.m_iWearable1;
		int looped = 1;
		int buffer;
		if(valid_entity>0)	//incase of fuckup, default to normal melee
		{
			float damage = (dmg / valid_entity)*damage_multi;
			int loop_for;
			if(red_npc)	//might be dumb, might not save any preformance, but heck..
			{
				loop_for=MAXENTITIES;
			}
			else
			{
				loop_for=MAXTF2PLAYERS;
			}
			for(int entity=1 ; entity<loop_for ; entity++)	//deal damage/do effect to vaild targets. 
			{
				if(valid_target[entity])
				{
					int r, g, b;
					r = 250;
					g = 0;
					b = 0;
					
					if(looped>1)	//slightly alternate the effect for fancyness!
					{
						if(looped>2)
						{
							last_entity = buffer;
							looped = 1;
						}
						buffer = entity;
					}
					
					looped++;
					
					if(!ShouldNpcDealBonusDamage(entity))
					{
						SDKHooks_TakeDamage(entity, client, client, damage, DMG_CLUB, -1, _, vecHit);	//kill!
					}
					else
					{
						SDKHooks_TakeDamage(entity, client, client, damage*1.25, DMG_CLUB, -1, _, vecHit);	//kill!
					}
					
					int laser_entity = EntRefToEntIndex(i_LaserEntityIndex[entity]);
					if(!IsValidEntity(laser_entity))
					{
						int red = r;
						int green = g;
						int blue = b;
						if(IsValidEntity(laser_entity))
						{
							RemoveEntity(laser_entity);
						}

						int laser;
						
						laser = ConnectWithBeam(last_entity, entity, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
			
						i_LaserEntityIndex[entity] = EntIndexToEntRef(laser);

						CreateTimer(0.5, Theocracy_String_Theory_Remove_Laser, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
		else
		{
			
			//CPrintToChatAll("it somehow got 0 vaild targets even though it tried to hit something, unless it hit a fucking barricade without any players/red npc's nearby");
			if(!ShouldNpcDealBonusDamage(target))
			{
				SDKHooks_TakeDamage(target, client, client, dmg, DMG_CLUB, -1, _, vecHit);
			}
			else
			{
				SDKHooks_TakeDamage(target, client, client, dmg*1.25, DMG_CLUB, -1, _, vecHit);
			}
		}
	}
	else
	{
		if(!ShouldNpcDealBonusDamage(target))
		{
			SDKHooks_TakeDamage(target, client, client, dmg, DMG_CLUB, -1, _, vecHit);
		}
		else
		{
			SDKHooks_TakeDamage(target, client, client, dmg*1.25, DMG_CLUB, -1, _, vecHit);
		}
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
	
	int particle_0 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	
	int particle_1 = ParticleEffectAt({0.0,15.0,-12.5}, "", 0.0);
	
	SetParent(particle_0, particle_1);
	
	
	//X axis- Left, Right	//this one im almost fully sure of
	//Y axis - Up down, for once
	//Z axis - Forward backwards.????????
	
	//ALL OF THESE ARE RELATIVE TO THE BACKPACK POINT THINGY, or well the viewmodel, but its easier to visualise if using the back
	//Left?


	//Right? probably right?
	int particle_2 = ParticleEffectAt({-35.0, 10.5, 2.5}, "", 0.0);
	int particle_2_1 = ParticleEffectAt({-90.0, 35.0, -5.0}, "", 0.0);
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
static Action Theocracy_String_Theory_Remove_Laser(Handle timer, int ref)
{
	int laser = EntRefToEntIndex(ref);
	if(IsValidEntity(laser))
	{
		RemoveEntity(laser);
	}
	return Plugin_Handled;
}

static void Theocracy_String_Theory(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Theocracy npc = view_as<Theocracy>(client);
		bl_string_theory_active[client] = true;
		
		float duration = THEOCRACY_STRING_THEORY_DURATION;
		
		i_string_Theory_battery[client] = 0;
		
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
		bl_string_theory_active[client] = false;
	}
	return Plugin_Handled;
	
}

public Action Theocracy_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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
	
	if(!bl_string_theory_active[npc.index] && damagetype & DMG_CLUB)
	{
		i_string_Theory_battery[npc.index] += RoundToFloor(damage);
	}
	if(i_string_Theory_battery[npc.index]>3000 && !bl_string_theory_active[npc.index])
	{
		npc.PlayChargeSound();
		i_string_Theory_battery[npc.index] = 0;
		Theocracy_String_Theory(EntIndexToEntRef(npc.index));
	}
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //Anger after half hp/400 hp
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

public void Theocracy_NPCDeath(int entity)
{
	Theocracy npc = view_as<Theocracy>(entity);
	
	Theocracy_Destroy_Wings(entity);
	
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Theocracy_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Theocracy_ClotThink);	
		
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
		
	for(int entity1=1 ; entity1<=MAXENTITIES ; entity1++)
	{
		int laser_entity = EntRefToEntIndex(i_LaserEntityIndex[entity1]);
		if(IsValidEntity(laser_entity))
		{
			RemoveEntity(laser_entity);
		}
	}
}




	
	