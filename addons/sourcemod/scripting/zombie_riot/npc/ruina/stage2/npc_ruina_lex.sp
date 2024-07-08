#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
	"vo/medic_painsharp05.mp3",
	"vo/medic_painsharp06.mp3",
	"vo/medic_painsharp07.mp3",
	"vo/medic_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/medic_standonthepoint01.mp3",
	"vo/medic_standonthepoint02.mp3",
	"vo/medic_standonthepoint03.mp3",
	"vo/medic_standonthepoint04.mp3",
	"vo/medic_standonthepoint05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
	"vo/medic_battlecry05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};
static char g_AngerSounds[][] = {	//todo: make it different!
	"vo/medic_cartgoingforwardoffense01.mp3",
	"vo/medic_cartgoingforwardoffense02.mp3",
	"vo/medic_cartgoingforwardoffense03.mp3",
	"vo/medic_cartgoingforwardoffense06.mp3",
	"vo/medic_cartgoingforwardoffense07.mp3",
	"vo/medic_cartgoingforwardoffense08.mp3",
};

#define LEX_LASER_LOOP_SOUND	"player/taunt_rocket_hover_loop.wav"//"weapons/gauss/chargeloop.wav"
#define LEX_LASER_LOOP_SOUND1	"ambient/machines/combine_shield_touch_loop1.wav"
#define LEX_LASER_ENDSOUND		"weapons/physcannon/physcannon_drop.wav"

void Lex_OnMapStart_NPC()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lex");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_lex");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "medic"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;			//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_AngerSounds);

	PrecacheSound(LEX_LASER_LOOP_SOUND);
	PrecacheSound(LEX_LASER_LOOP_SOUND1);
	PrecacheSound(LEX_LASER_ENDSOUND);

	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Lex(client, vecPos, vecAng, ally, data);
}

static float fl_npc_basespeed;


static int Fire_Beacon(CClotBody npc, float vecTarget[3], float Origin[3], float projectile_speed)
{
	Ruina_Projectiles Projectile;

	float GameTime = GetGameTime();

	Projectile.iNPC = npc.index;
	Projectile.Start_Loc = Origin;
	float Ang[3];
	MakeVectorFromPoints(Origin, vecTarget, Ang);
	GetVectorAngles(Ang, Ang);
	Projectile.Angles = Ang;
	Projectile.speed = projectile_speed;
	Projectile.Time = fl_ruina_battery_timer[npc.index] - GameTime;

	return Projectile.Launch_Projectile(Func_On_Proj_Touch);	
}

static void Func_On_Proj_Touch(int projectile, int other)
{
	//Do Jack Shit!
	/*
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
	{
		owner = 0;
	}

	Ruina_Add_Mana_Sickness(owner, other, 0.0, 500);	//very heavy FLAT amount of mana sickness
		
	float ProjectileLoc[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	Explode_Logic_Custom(fl_ruina_Projectile_dmg[projectile] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[projectile] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[projectile]);

	Ruina_Remove_Projectile(projectile);*/
}

#define RUINA_LEX_LASER_BEACON_AMT 9
static int i_laser_beacons[MAXENTITIES][RUINA_LEX_LASER_BEACON_AMT];

static void Delete_Beacons(int iNPC)
{
	for(int i=0 ; i < RUINA_LEX_LASER_BEACON_AMT ; i++)
	{
		int entity = EntRefToEntIndex(i_laser_beacons[iNPC][i]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);

		i_laser_beacons[iNPC][i] = INVALID_ENT_REFERENCE;
	}
}
static bool b_solo[MAXENTITIES];
methodmap Lex < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
		#endif
	}

	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}

	property int m_ially
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property float m_flRange
	{
		public get()			{	return this.m_flCharge_delay;	}
		public set(float value) 	{	this.m_flCharge_delay = value;	}
	}
	property bool m_bRetreating
	{
		public get()							{ return b_Gunout[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Gunout[this.index] = TempValueForProperty; }
	}
	property bool m_bSolo
	{
		public get()							{ return b_solo[this.index]; }
		public set(bool TempValueForProperty) 	{ b_solo[this.index] = TempValueForProperty; }
	}

	public void Do_Default()
	{
		if(!this.IsAlive())
			return;
		
		bool close = this.IsClose();

		if(close)
		{
			if(this.IsLowHealth())
			{
				this.Fuse();
			}
			else	//Initiate a buff between the 2.
			{
				this.m_bRetreating = false;
			}
		}
		
	}
	public void Initiate_Follow()	//set pathing towards ally.
	{
		int Ally = EntRefToEntIndex(this.m_ially);
		this.m_bRetreating = true;
		NPC_SetGoalEntity(this.index, Ally);
		Ruina_Special_Logic(this.index, Ally);
		this.StartPathing();
	}
	public bool IsClose()			//check if we are close enough to initate fusion
	{
		int Ally = EntRefToEntIndex(this.m_ially);
		float victimPos[3];
		float partnerPos[3];
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", partnerPos);
		GetEntPropVector(Ally, Prop_Data, "m_vecAbsOrigin", victimPos); 
		float Distance = GetVectorDistance(victimPos, partnerPos, true);
		if(Distance < (this.m_flRange) && Can_I_See_Enemy_Only(this.index, Ally))
		{
			return true;
		}
		return false;
	}
	public bool IsLowHealth()		//only allow walking close if both npc's are bellow 50% hp.
	{
		int Ally = EntRefToEntIndex(this.m_ially);
		int Health 		= GetEntProp(Ally, Prop_Data, "m_iHealth"),
			MaxHealth 	= GetEntProp(Ally, Prop_Data, "m_iMaxHealth");

		float Ratio = (float(Health)/float(MaxHealth));

		if(Ratio > 0.5)
			return false;
		
		Health 		= GetEntProp(this.index, Prop_Data, "m_iHealth"),
		MaxHealth 	= GetEntProp(this.index, Prop_Data, "m_iMaxHealth");

		if(Ratio > 0.5)
			return false;

		this.Initiate_Follow();

		return true;
	}
	public bool IsAlive()
	{
		if(this.m_bSolo)
			return false;
		
		return IsValidAlly(this.index, EntRefToEntIndex(this.m_ially));
	}
	public void Fuse()
	{

	}
	public void Share_Damage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)	//share the damage taken across both. but it will still do 25%? more dmg to the on being attacked.
	{
		if(!this.IsAlive())
			return;
		
		if(this.IsClose())
		{	
			int Ally = EntRefToEntIndex(this.m_ially);
			damage *= 0.65;
			SDKHooks_TakeDamage(Ally, attacker, inflictor, damage * 0.75, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
			damage *= 0.25;
		}
	}
	public void Spawn_Ally()
	{
		this.m_ially = -1;

		float pos[3]; GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(this.index, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(this.index, Prop_Data, "m_iHealth");
		
		maxhealth = RoundToFloor(maxhealth*1.5);

		int spawn_index = NPC_CreateByName("npc_ruina_iana", this.index, pos, ang, GetTeam(this.index));
		if(spawn_index > MaxClients)
		{
			this.m_ially = EntIndexToEntRef(spawn_index);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
	public int Get_Target()
	{
		float GameTime = GetGameTime();
		if(!this.IsAlive())
		{
			if(this.m_flGetClosestTargetTime < GameTime)
			{
				this.m_iTarget = GetClosestTarget(this.index);
				this.m_flGetClosestTargetTime = GameTime + 1.0;
			}
		}
		else
		{
			Iana ally = view_as<Iana>(EntRefToEntIndex(this.m_ially));

			int Old_Target = this.m_iTarget;

			this.m_iTarget = ally.m_iTarget;

			if(!IsValidEnemy(this.index, this.m_iTarget))
			{
				this.m_iTarget = Old_Target;

				if(!IsValidEnemy(this.index, this.m_iTarget) || this.m_flGetClosestTargetTime < GameTime)
				{
					if(this.m_flGetClosestTargetTime < GameTime)
					{
						this.m_iTarget = GetClosestTarget(this.index);
						this.m_flGetClosestTargetTime = GameTime + 1.0;
					}
				}
			}
		}
		return this.m_iTarget;
	}
	
	public Lex(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Lex npc = view_as<Lex>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		//now all thats left is the, wings, and 2nd boss + fusing with 2nd boss!
		/*
			Berliner					"models/player/items/medic/berliners_bucket_helm.mdl"
			Hong kong cone				"models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_medic.mdl"
			lo-grav loafers				//Hw2013_Moon_Boots
			Der Wintermantel			"models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl"
			medical monarch				"models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem2/dec15_medic_winter_jacket2_emblem2.mdl"
		
		*/
		static const char Items[][] = {
			"models/player/items/medic/berliners_bucket_helm.mdl",
			"models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_medic.mdl",
			"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl",
			"models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl",
			"models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem2/dec15_medic_winter_jacket2_emblem2.mdl",
			RUINA_CUSTOM_MODELS_1,
			RUINA_CUSTOM_MODELS_1
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItemSeperate("head", Items[5],_,_,1.25,85.0);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_W30_HAND_CREST);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");

		SetVariantInt(RUINA_HALO_1);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		fl_npc_basespeed = 300.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();	

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		fl_ruina_battery_timeout[npc.index] = 0.0;

		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc		
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_RANGED_NPC, true, 15, 6);

		Delete_Beacons(npc.index);

		fl_multi_attack_delay[npc.index] = 0.0;

		npc.m_iState = 0;

		Ruina_Clean_Particles(npc.index);

		Create_Wings(npc);

		npc.Anger = false;

		npc.m_bSolo =  StrContains(data, "solo") != -1;

		if(!npc.m_bSolo)
			RequestFrame(Do_OnSpawn, npc.index);
		
		return npc;
	}
}
static void Do_OnSpawn(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		Lex npc = view_as<Lex>(entity);
		npc.m_flRange = (300.0*300.0);
		npc.m_bRetreating = false;
		npc.Spawn_Ally();
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Lex npc = view_as<Lex>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flDoingAnimation > GameTime)
		Ruina_Add_Battery(npc.index, 5.0);	//10
	else
		Ruina_Add_Battery(npc.index, 10.0);	//10

	int PrimaryThreatIndex = npc.Get_Target();

	npc.Do_Default();

	if(!npc.m_bRetreating)
		Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	if(fl_ruina_battery[npc.index]>3000.0 && npc.m_flDoingAnimation < GameTime-1.0)	//every 30 seconds.
	{
		b_ruina_battery_ability_active[npc.index] = true;
		Master_Apply_Shield_Buff(npc.index, 100.0, 0.1);	//90% shield to all but itself. tiny radius tho
		fl_ruina_shield_break_timeout[npc.index] = 0.0;		//make 100% sure he WILL get the shield.
		Ruina_Npc_Give_Shield(npc.index, 0.1);				//give the shield to itself.
		fl_ruina_battery[npc.index] = 0.0;
		npc.m_flNextMeleeAttack = 0.0;		
	}

	if(npc.m_flDoingAnimation > GameTime)
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;

		if(fl_ruina_battery_timer[npc.index] > GameTime)
		{
			npc.m_iState = 0;
			Delete_Beacons(npc.index);
			npc.m_flNextMeleeAttack = GameTime + 9.0;

			fl_ruina_battery_timer[npc.index] = 0.0;
		}

		return;
	}
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

		if(b_ruina_battery_ability_active[npc.index] && fl_ruina_battery_timeout[npc.index] < GameTime)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				float new_vec[3]; WorldSpaceCenter(Enemy_I_See, new_vec);
				float Difference = FloatAbs(Npc_Vec[2]-new_vec[2]);
				if(Difference < 45.0)	//make sure its more or less the same height as the npc
				{
					Initiate_Laser(npc);
					b_ruina_battery_ability_active[npc.index] = false;
					fl_ruina_battery_timeout[npc.index] = GameTime + 15.0;
					
					npc.FaceTowards(new_vec, 40000.0);	//we turn, veri fast indeed
					npc.FaceTowards(new_vec, 40000.0);	//we turn, veri fast indeed

					EmitSoundToAll(LEX_LASER_LOOP_SOUND, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);
					EmitSoundToAll(LEX_LASER_LOOP_SOUND, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);
					EmitSoundToAll(LEX_LASER_LOOP_SOUND1, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);
					EmitSoundToAll(LEX_LASER_LOOP_SOUND1, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);

					return;
				}
			}
		}
		if(flDistanceToTarget < 100000)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (75000))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
					npc.m_bAllowBackWalking=true;
				}
				else
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bAllowBackWalking=false;
				}
			}
			else
			{
				npc.StartPathing();
				npc.m_bPathing = true;
				npc.m_bAllowBackWalking=false;
			}		
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_bAllowBackWalking=false;
		}

		if(npc.m_bAllowBackWalking)
		{
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENATLY;	
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED);
		}
		else
			npc.m_flSpeed = fl_npc_basespeed;

		if(fl_ruina_battery_timer[npc.index] > GameTime)
		{
			if(npc.m_iState > 0)
			{
				int Previous_Proj = EntRefToEntIndex(i_laser_beacons[iNPC][0]);
				for(int i=1 ; i < npc.m_iState ; i++)
				{
					int Proj = EntRefToEntIndex(i_laser_beacons[iNPC][i]);

					if(!IsValidEntity(Proj))
						continue;

					if(!IsValidEntity(Previous_Proj))
					{
						Previous_Proj = Proj;
						continue;
					}
					float Vec1[3], Vec2[3];
					GetEntPropVector(Proj, Prop_Data, "m_vecAbsOrigin", Vec1);
					GetEntPropVector(Previous_Proj, Prop_Data, "m_vecAbsOrigin", Vec2);

					if(GetVectorDistance(Vec1, Vec2, true) > 90000.0)
						TeleportEntity(Proj, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});

					Ruina_Laser_Logic Laser;

					Laser.client = npc.index;
					Laser.Start_Point = Vec1;
					Laser.End_Point = Vec2;

					Laser.Radius = 5.0;
					Laser.Damage = 10.0;
					Laser.Bonus_Damage = 60.0;
					Laser.damagetype = DMG_PLASMA;

					Laser.Deal_Damage(On_LaserHit);
	
					Previous_Proj = Proj;
				}
			}
		}		

		//Target close enough to hit
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*17)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					if(fl_ruina_battery_timer[npc.index] > GameTime + 1.0)
					{
						if(npc.m_iState < RUINA_LEX_LASER_BEACON_AMT && fl_multi_attack_delay[npc.index] < GameTime)
						{
							fl_ruina_in_combat_timer[npc.index]=GameTime+5.0;

							fl_multi_attack_delay[npc.index] = GameTime + 0.2;

							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							npc.PlayMeleeSound();

							float Min,Max;

							Min = (npc.Anger ? 800.0 : 400.0);
							Max = (npc.Anger ? 1200.0 : 800.0);

							float projectile_speed = GetRandomFloat(Min, Max);

							int RNG = GetRandomInt(0, 3);
							float fRNG = GetRandomFloat(0.1, 1.0);
							switch(RNG)
							{
								case 0:
								{
									for(int i=0 ; i < 3 ; i ++)
									{
										vecTarget[i]+=((RNG*250.0)*fRNG);
									}
								}
								case 1:
								{
									for(int i=0 ; i < 3 ; i ++)
									{
										vecTarget[i]-=((RNG*250.0)*fRNG);
									}
								}
								default:
								{
									PredictSubjectPositionForProjectiles(npc, Enemy_I_See, projectile_speed, _,vecTarget);
									RNG-=2;
									switch(RNG)
									{
										case 1:
										{
											for(int i=0 ; i < 3 ; i ++)
											{
												vecTarget[i]-=((RNG*250.0)*fRNG);
											}
										}
										case 2:
										{
											for(int i=0 ; i < 3 ; i ++)
											{
												vecTarget[i]+=((RNG*250.0)*fRNG);
											}
										}
										
									}
								}
							}

							float flPos[3], flAng[3]; // original
							GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

							int Proj = Fire_Beacon(npc, vecTarget, flPos, projectile_speed);

							i_laser_beacons[npc.index][npc.m_iState] = EntIndexToEntRef(Proj);

							CreateTimer(0.1, Lex_Slow_Projectiles, EntIndexToEntRef(Proj), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

							if(npc.m_iState > 0)
							{
								int Last_Proj = EntRefToEntIndex(i_laser_beacons[npc.index][npc.m_iState-1]);
								int color[3] = {255, 255, 255};
								int Laser = ConnectWithBeam(Proj, Last_Proj, color[0], color[1], color[2], 4.0, 4.0, 0.1, BEAM_COMBINE_BLACK);

								CreateTimer((fl_ruina_battery_timer[npc.index] - GameTime)-0.1, Timer_RemoveEntity, EntIndexToEntRef(Laser), TIMER_FLAG_NO_MAPCHANGE);
							}

							npc.m_iState++;
						}
					}
					else
					{
						npc.m_iState = 0;
						Delete_Beacons(npc.index);
						npc.m_flNextMeleeAttack = GameTime + 9.0;
					}
				}
				else
				{
					npc.m_iState = 0;
					fl_ruina_battery_timer[npc.index] = GameTime + 12.0;
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
static void On_LaserHit(int client, int target, int damagetype, float damage)
{
	Ruina_Add_Mana_Sickness(client, target, 0.01, 10);
}
static Action Lex_Slow_Projectiles(Handle Timer, int ref)
{
	int Proj = EntRefToEntIndex(ref);

	if(!IsValidEntity(Proj))
		return Plugin_Stop;

	float CurrentVel[3];
	GetEntPropVector(Proj, Prop_Data, "m_vecVelocity", CurrentVel);
	float Speed = FloatAbs(CurrentVel[0]) + FloatAbs(CurrentVel[1]) + FloatAbs(CurrentVel[2]);

	if(Speed > 10.0)	//slow the projectile until it reaches our desired speed, then nuke the timer!
	{
		for(int i=0 ; i < 3 ; i ++)
		{
			if(CurrentVel[i] > 10.0)
			{
				if(CurrentVel[i] > 100.0)
				{
					CurrentVel[i]*=0.95;
				}
				else
				{
					CurrentVel[i]-=10.0;
				}
			}
			else if(CurrentVel[i] < -10.0)
			{
				if(CurrentVel[i] < -100.0)
				{
					CurrentVel[i]*=0.95;
				}
				else
				{
					CurrentVel[i]+=10.0;
				}
			}
		}
		TeleportEntity(Proj, NULL_VECTOR, NULL_VECTOR, CurrentVel);
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Lex npc = view_as<Lex>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	npc.Share_Damage(attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	int Health 		= GetEntProp(npc.index, Prop_Data, "m_iHealth"),
		MaxHealth 	= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	
	float Ratio = (float(Health)/float(MaxHealth));

	if(Ratio < 0.1 && npc.m_flDoingAnimation > GetGameTime())	//tl;dr, can't let him die during laser.
	{
		damage = 0.0;
	}

	if(!npc.Anger && Ratio < 0.75) 
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();

		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static int i_ring_dots[MAXENTITIES][3];

static void NPC_Death(int entity)
{
	Lex npc = view_as<Lex>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Ruina_Clean_Particles(npc.index);

	Delete_Beacons(npc.index);

	Ruina_NPCDeath_Override(npc.index);

	StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
	StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);

	StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
	StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
	StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);

	SDKUnhook(npc.index, SDKHook_Think, Laser_Tick);

	for(int i= 0 ; i < 3 ; i++)
	{
		int dot = EntRefToEntIndex(i_ring_dots[npc.index][i]);
		if(IsValidEntity(dot))
		{
			RemoveEntity(dot);
		}
		i_ring_dots[npc.index][i] = INVALID_ENT_REFERENCE;
	}
	
		
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

static Action Laser_Revert(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Lex npc = view_as<Lex>(client);
		npc.m_flSpeed = fl_npc_basespeed;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iWearable7 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_1);

		SetVariantInt(RUINA_W30_HAND_CREST);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");

		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.0;
	}

	return Plugin_Stop;
}

static int i_effect_amt[MAXENTITIES];

static void Initiate_Laser(Lex npc)
{
	int iActivity = npc.LookupActivity("ACT_MP_CROUCH_SECONDARY");
	if(iActivity > 0) npc.StartActivity(iActivity);

	npc.m_flRangedArmor = 0.5;
	npc.m_flMeleeArmor = 0.5;

	float Duration = 5.5;

	float GameTime = GetGameTime();

	npc.m_flDoingAnimation = GameTime + Duration;

	for(int i=0 ; i < 3 ; i++)
	{
		int dot = EntRefToEntIndex(i_ring_dots[npc.index][i]);
		if(IsValidEntity(dot))
		{
			RemoveEntity(dot);
		}
		i_ring_dots[npc.index][i] = INVALID_ENT_REFERENCE;
	}
	
	CreateTimer(Duration, Laser_Revert, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);

	fl_ruina_throttle[npc.index] = 0.0;
	i_effect_amt[npc.index] = 0;
	npc.m_flReloadIn = GameTime + 0.75;

	float npc_vec[3];
	GetAbsOrigin(npc.index, npc_vec);

	for(int i=0 ; i < 2 ; i ++)
	{
		int dot = Ruina_Create_Entity(npc_vec, 0.0, true);

		if(IsValidEntity(dot))
		{
			i_ring_dots[npc.index][i] = EntIndexToEntRef(dot);
		}
	}

	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	npc_vec[2]-=30.0;

	int Hand_Thing = Ruina_Create_Entity(npc_vec, 0.0, true);
	if(IsValidEntity(Hand_Thing))	//now then, I could just simply go into blender and rotate this thing, and honestly thats a simple thing to do. BUT, im far too lazy right now to open blender, rotate a bit, recompile and then replace the models. so Im doing this far far stupider and harder method
	{
		//but I still did it this way and so I saved 1 body group for the model pack!
		//Also I thought at first doing this would be easy....
		i_ring_dots[npc.index][2] = EntIndexToEntRef(Hand_Thing);
		int ModelApply = ApplyCustomModelToWandProjectile(Hand_Thing, RUINA_CUSTOM_MODELS_1, 1.0, "");
		SetVariantInt(RUINA_W30_HAND_CREST);
		AcceptEntityInput(ModelApply, "SetBodyGroup");

		float flPos[3], flAng[3];
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			float vecAngles[3];
			MakeVectorFromPoints(npc_vec, vecTarget, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
			vecAngles[0] = 0.0;
			TeleportEntity(Hand_Thing, NULL_VECTOR, vecAngles, NULL_VECTOR);
		}	

		GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
		GetEntPropVector(Hand_Thing, Prop_Data, "m_angRotation", flAng);
		flAng[0]+=90.0;

		TeleportEntity(Hand_Thing, NULL_VECTOR, flAng, NULL_VECTOR);

	}

	
	SDKHook(npc.index, SDKHook_Think, Laser_Tick);
}

static Action Laser_Tick(int client)
{
	Lex npc = view_as<Lex>(client);

	float GameTime = GetGameTime();

	if(npc.m_flDoingAnimation < GameTime)
	{
		SDKUnhook(npc.index, SDKHook_Think, Laser_Tick);

		EmitSoundToAll(LEX_LASER_ENDSOUND, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);
		EmitSoundToAll(LEX_LASER_ENDSOUND, npc.index, SNDCHAN_STATIC, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);

		StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
		StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
		StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);

		StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
		StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
		StopSound(npc.index, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);

		for(int i=0 ; i < 3 ; i++)
		{
			int dot = EntRefToEntIndex(i_ring_dots[npc.index][i]);
			if(IsValidEntity(dot))
			{
				RemoveEntity(dot);
			}
			i_ring_dots[npc.index][i] = INVALID_ENT_REFERENCE;
		}

		return Plugin_Stop;
	}

	if(fl_ruina_throttle[npc.index] > GameTime)
		return Plugin_Continue;

	if(npc.m_flReloadIn > GameTime)
	{
		return Plugin_Continue;
	}
	
	fl_ruina_throttle[npc.index] = GameTime + 0.1;

	Ruina_Laser_Logic Laser;

	float Radius = 25.0;

	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(2500.0);
	Laser.Radius = Radius;
	Laser.Damage = 100.0;
	Laser.Bonus_Damage = 200.0;
	Laser.damagetype = DMG_PLASMA;
	Laser.Deal_Damage(On_LaserHit_Big);

	if(i_effect_amt[npc.index] < 5)
	{
		float Start_Vec[3], End_Vec[3];
		float flPos[3]; // original
		float flAng[3]; // original
		GetAttachment(client, "effect_hand_r", flPos, flAng);
		End_Vec = Laser.End_Point;
		Start_Vec = flPos;

		i_effect_amt[npc.index] ++;

		float diameter = ClampBeamWidth(Radius * 2.0);

		Do_Laser_Effects(npc, Start_Vec, End_Vec, diameter);

	}
	return Plugin_Continue;
}
static void On_LaserHit_Big(int client, int target, int damagetype, float damage)
{
	Ruina_Add_Mana_Sickness(client, target, 0.05, 12);
}
static void Do_Laser_Effects(Lex npc, float Start[3], float End[3], float diameter)
{
	float GameTime = GetGameTime();
	float TE_Duration = npc.m_flDoingAnimation - GameTime;

	int color[4];
	Ruina_Color(color);

	color[3] = 75;

	int dots[2];
	bool valid = true;

	float vecAngles[3];
	MakeVectorFromPoints(Start, End, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);

	float Offset_Start[3];

	Get_Fake_Forward_Vec(100.0, vecAngles, Offset_Start, Start);

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[3]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);



	TE_SetupBeamPoints(Offset_Start, End, g_Ruina_BEAM_lightning, 0, 0, 0, TE_Duration, diameter, diameter, 0, 0.25, colorLayer1, 24);
	TE_SendToAll();
	TE_SetupBeamPoints(Start, End, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, diameter*0.4, diameter*0.8, 1, 0.25, colorLayer2, 3);
	TE_SendToAll();
	colorLayer3[3]+=100;
	if(colorLayer3[3]>255)
		colorLayer3[3] = 255;
	TE_SetupBeamPoints(Offset_Start, End, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, diameter*0.5, diameter*0.5, 1, 2.0, colorLayer3, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(Start, End, g_Ruina_BEAM_Combine_Blue, 0, 0, 66, TE_Duration, diameter*0.2, diameter*0.4, 1, 1.0, colorLayer4, 3);
	TE_SendToAll();

	diameter *=0.8;

	TE_SetupBeamPoints(Start, Offset_Start, g_Ruina_BEAM_lightning, 0, 0, 0, TE_Duration, 0.0, diameter, 0, 0.1, colorLayer1, 24);
	TE_SendToAll();
	TE_SetupBeamPoints(Start, Offset_Start, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, 0.0, diameter*0.8, 1, 0.1, colorLayer2, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(Start, Offset_Start, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, 0.0, diameter*0.6, 1, 1.0, colorLayer3, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(Start, Offset_Start, g_Ruina_BEAM_Laser, 0, 0, 0, TE_Duration, 0.0, diameter*0.4, 1, 5.0, colorLayer4, 3);
	TE_SendToAll();

	int Hand = EntRefToEntIndex(i_ring_dots[npc.index][2]);
	if(IsValidEntity(Hand))
	{
		Start[2]-=2.0;	//very slightly offset it.
		TeleportEntity(Hand, Start, NULL_VECTOR, NULL_VECTOR);
		Start[2]+=2.0;
	}

	float Dist = 30.0;
	for(int i=0 ; i < 2 ; i++)
	{
		int dot = EntRefToEntIndex(i_ring_dots[npc.index][i]);

		float Ring_Loc[3]; Ring_Loc = Offset_Start;
		if(IsValidEntity(dot))
		{
			dots[i] = dot;

			float tmp[3];
			float actualBeamOffset[3];
			float BEAM_BeamOffset[3];
			BEAM_BeamOffset[0] = 0.0;
			BEAM_BeamOffset[1] = 0.0;
			BEAM_BeamOffset[2] = 0.0;
			switch(i)
			{	
				case 0:
				{	
					BEAM_BeamOffset[0] = -12.0;
					//BEAM_BeamOffset[1] = -0.1;
					BEAM_BeamOffset[2] = -Dist;
				}
				case 1:
				{
					BEAM_BeamOffset[0] = 12.0;
					//BEAM_BeamOffset[1] = 0.1;
					BEAM_BeamOffset[2] = Dist;
				}
				
			}

			tmp[0] = BEAM_BeamOffset[0];
			tmp[1] = BEAM_BeamOffset[1];
			tmp[2] = 0.0;
			VectorRotate(BEAM_BeamOffset, vecAngles, actualBeamOffset);
			actualBeamOffset[2] = BEAM_BeamOffset[2];
			Ring_Loc[0] += actualBeamOffset[0];
			Ring_Loc[1] += actualBeamOffset[1];
			Ring_Loc[2] += actualBeamOffset[2];

			TeleportEntity(dot, Ring_Loc, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			valid = false;
		}
	}
	if(valid)
	{
		TE_SetupBeamRing(dots[0], dots[1], g_Ruina_BEAM_Combine_Black, g_Ruina_BEAM_Laser, 0, 10, TE_Duration, 7.5, 1.0, color, 10, 0);	
		TE_SendToAll();
	}

	
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static void Create_Wings(Lex npc)	//temp until real ones can be made
{

	if(AtEdictLimit(EDICT_NPC))
		return;

	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];

	int ParticleOffsetMain = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetAttachment(npc.index, "back_lower", flPos, flAng);
	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(npc.index, ParticleOffsetMain, "back_lower",_);

	float core_loc[3] = {0.0, 15.0, -20.0};

	float Offset[3];
	Offset[0] = 15.0;
	Offset[2] = 15.0;		//+foroward, -back

	
	float start_1 = 2.0;
	float end_1 = 0.5;
	float amp =0.1;

	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	int Wing_Ints = 6;

	float Wing_Loc[2][6][3];

	Wing_Loc[0][0] = {7.5, 0.0, -9.5};
	Wing_Loc[0][1] = {20.5, 10.0, -15.0};
	Wing_Loc[0][2] = {5.0, -25.0, 0.0};
	Wing_Loc[0][3] = {50.0, -15.0, 5.0};
	Wing_Loc[0][4] = {60.0, -10.0, 10.0};
	Wing_Loc[0][5] = {55.0, 0.0, 2.5};

	//Add the offsets and core values
	for(int i=0; i < Wing_Ints ; i ++) {AddVectors(Wing_Loc[0][i], core_loc, Wing_Loc[0][i]);}
	for(int i=0; i < Wing_Ints ; i ++) {AddVectors(Wing_Loc[0][i], Offset, Wing_Loc[0][i]);}

	//Copy over the vectors from left to right and invert the "direction"
	for(int i=0; i < Wing_Ints ; i ++) {Wing_Loc[1][i] = Wing_Loc[0][i];}
	for(int i=0; i < Wing_Ints ; i ++) {Wing_Loc[1][i][0]*=-1.0;}

	int Particle_Core = InfoTargetParentAt(core_loc, "", 0.0);

	i_particle_ref_id[npc.index][0] = EntIndexToEntRef(Particle_Core);
	i_particle_ref_id[npc.index][1] = EntIndexToEntRef(ParticleOffsetMain);

	int Particle_Wings[2][6];

	for(int i=0 ; i < 2 ; i++)
	{
		//CPrintToChatAll("We are making wing nr: %i", i);
		for(int y= 0 ; y < Wing_Ints ; y++)
		{
			Particle_Wings[i][y] = InfoTargetParentAt(Wing_Loc[i][y], "", 0.0);
			SetParent(Particle_Core, Particle_Wings[i][y], "",_, true);
			//CPrintToChatAll("Loc:%f\n%f\n%f", Wing_Loc[i][y][0], Wing_Loc[i][y][1], Wing_Loc[i][y][2]);

			i_particle_ref_id[npc.index][Wing_Ints*i+y+2] = EntIndexToEntRef(Particle_Wings[i][y]);
			//CPrintToChatAll("Index loop %i", Wing_Ints*i+y+2);
		}
		//Now, this part can't be automated unfortunately :( or well not fully
		/*
		if(i==1)
		{
			red= 255;
			green =0;
			blue = 0;
		}
		else
		{
			red= 0;
			green =0;
			blue = 255;
		}*/

		int Lasers_Int = 7;
		int Lasers[7];
		Lasers[0] = ConnectWithBeamClient(Particle_Wings[i][0], Particle_Wings[i][1], red, green, blue, start_1, start_1, amp, LASERBEAM);
		Lasers[1] = ConnectWithBeamClient(Particle_Wings[i][0], Particle_Wings[i][2], red, green, blue, start_1, start_1, amp, LASERBEAM);
		Lasers[2] = ConnectWithBeamClient(Particle_Wings[i][4], Particle_Wings[i][3], red, green, blue, end_1, end_1, amp, LASERBEAM);
		Lasers[3] = ConnectWithBeamClient(Particle_Wings[i][4], Particle_Wings[i][5], red, green, blue, end_1, end_1, amp, LASERBEAM);
		Lasers[4] = ConnectWithBeamClient(Particle_Wings[i][2], Particle_Wings[i][3], red, green, blue, start_1, end_1, amp, LASERBEAM);
		Lasers[5] = ConnectWithBeamClient(Particle_Wings[i][1], Particle_Wings[i][5], red, green, blue, start_1, end_1, amp, LASERBEAM);
		Lasers[6] = ConnectWithBeamClient(Particle_Wings[i][3], Particle_Wings[i][5], red, green, blue, end_1, end_1, amp, LASERBEAM);

		for(int x=0 ; x < Lasers_Int ; x++)
		{
			i_laser_ref_id[npc.index][x+Lasers_Int*i] = EntIndexToEntRef(Lasers[x]);
			//CPrintToChatAll("Laser loop %i", x+Lasers_Int*i);
		}
	}
	Custom_SDKCall_SetLocalOrigin(Particle_Core, flPos);
	SetEntPropVector(Particle_Core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, Particle_Core, "",_);
}