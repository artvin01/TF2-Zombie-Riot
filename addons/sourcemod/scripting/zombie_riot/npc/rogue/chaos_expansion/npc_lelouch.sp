#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
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
static const char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};

static const char g_AngerSounds[][] = {
	"vo/medic_cartgoingforwardoffense01.mp3",
	"vo/medic_cartgoingforwardoffense02.mp3",
	"vo/medic_cartgoingforwardoffense03.mp3",
	"vo/medic_cartgoingforwardoffense06.mp3",
	"vo/medic_cartgoingforwardoffense07.mp3",
	"vo/medic_cartgoingforwardoffense08.mp3",
};

/*
	Notepad:

	Base Model: Spy?

	Theme?: https://www.youtube.com/watch?v=AoSUEMYzusc

	

	Abilities in no order. just ones that I came up with on the spot.
	also some names are just uhh. pending.
	also also, some probably won't make it in. probably.

	1 - Spiral Fracture:
		Stand in spot. do anim.
		300~ HU's in 8 directions walls appear. touching said wall will kill you.
		the walls spin.

		Within 300 HU's players would be safe.

	2 - XX?
		
		Fire off projectiles in 16 directions.
		These projectiles slowdown slowly.
		Once X seconds pass. a beam of light appears on said projectiles.
		Every projectile that can see any other projectile connect with a small beam.
		then after a few seconds that beam becomes thicker and starts to deal damage.
		
		- Every 2nd proj has a different speed. would allow for special patterns.
		- also stagger firing them too.

		Stand in spot while firing proj.
		while the proj "charge" do anim.
		once lasers become thick and deal dmg, move normally

	//say happens on 90-75% hp?
	3 - Chaos CONTROL (actual name pending.)
		3 special points on the map appears using pre set vectors.
		Magia anchors spawn. chaos affected model smth like that.
		And a countdown begins.

		During this countdown the main boss is invulnerable. and stays in 1 spot.

		Red team have to destroy these anchors before the countdown finishes.
		
		if they fail. depending on the amount of alive anchors left upon the countdown finishing
		ION's spawn on those locations. being very near them makes the player take passive dmg (300-400~) hu?
		Anyone close to the pillars takes increased damage. 600~ hu

		if you royally fuck up and all 3 are still active, all 3 shoot a beam into the center of the arena and create a ORB that shoots 1 big ass death ray.
		following any targets it can see.
		The anchors also gain a lot of resistances, and all their hp is equalized.
		if you kill one of the anchors this breaks.

		If you kill all the anchors: Twirl summons her own anchors in those locations and creates a friendly beam of death.
		Solong as they can keep the anchors alive.

		the anchors also give buffs to red.

		The main boss's priority will switch from killing players to killing any one of the anchors first.
		
		(the idea is that keeping the anchors alive is one viable way to win)

	4 - Blade Related abilities:
		4.1 Does anim. creates a massive - huge as fuck - blade above himself and then a few seconds later slams it down forward dealing HUGE damage to anyone caught in it.
		4.2 Does Anim. big blade. it spawns forward of the npc. then after a few seconds it spins a few times around the npc very fast dealing dmg to anyone caught in the blades AOE


	5 - Frame-Shift-Cannon:
		Does anim, long charge up.
		Unleashes a fucking DEATH BEAM.
		anything caught in up in it just dies.
		
		In addition, ion strikes happen along the path of the cannon. on the sides.

		Forward facing.

	6 - Stellarararar
		happens at around 25% hp.

		A massive stellar weaver is summoned at the center of the arena. it cannot take damage, its simply a threat that exists.
		best you can do is distract it.

	7 - Crystal Shield:
		Creates 3 crystals that spin around the boss.
		While active each shield gives 25% dmg resist.
		Each crystal has its own health pool.

		Crystal Specific abilities:	

		7.1 Spiral.
			Does an animation.
			Crystals shoot lasers in their own direction while spining.

		7.2 Focus.
			The crystals start shooting the target the npc is attacking. they also move slightly upward.
			but they also only start blocking 10% dmg.

	
	8 - Crystal Teleport
		Spawns 16 crystals.
		these crystals randomly teleport from the npc. for X amount of times.
		A beam of light at each crystal is created into the sky.

		While active the boss gets battery.
		idk what else they could do.

	9 - Infinity Laser Works (get it?)
		Does anim. floats up.
		Several portals or somethingl ike that appears behind the npc in a circle/pattern.

		Seconds later lasers being shooting from said portals.

		Laser logic:
		Get Client Vector.
		Get client Velocity Vector.
		Vector1 :Get BEHIND said velocity, by 2.0
		Vector2: Then get the vector 2.0 Infront of the client.
		Then make the laser Travel from vector1 to vector2.
		Duration 2.0s?

		If the player sees this coming, they can simply walk sideways avoding the laser.

*/

void Lelouch_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lelouch");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_lelouch");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "lelouch"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_AngerSounds);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Lelouch(vecPos, vecAng, team);
}
static float fl_npc_basespeed;
methodmap Lelouch < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
		#endif
	}
	
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}

	public Lelouch(float vecPos[3], float vecAng[3], int ally)
	{
		Lelouch npc = view_as<Lelouch>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iChanged_WalkCycle = 1;
		
		
		/*
			


		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 330.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		static const char Items[][] = {	//temp
			"models/workshop/player/items/all_class/jogon/jogon_medic.mdl",
			"models/workshop_partner/player/items/all_class/brutal_hair/brutal_hair_medic.mdl",
			"models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl",
			"models/workshop/player/items/medic/sf14_vampire_makeover/sf14_vampire_makeover.mdl",
			"models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl",
			RUINA_CUSTOM_MODELS_3,
			RUINA_CUSTOM_MODELS_2
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5]);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_WINGS_3);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");
		SetVariantInt(RUINA_IMPACT_LANCE_4);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");	


		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
				
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		npc.Anger = false;

		Ruina_Set_Heirarchy(npc.index, RUINA_MELEE_NPC);	//is a melee npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_MELEE_NPC, true, 15, 15);

		return npc;
	}
	
	
}
static void ClotThink(int iNPC)
{
	Lelouch npc = view_as<Lelouch>(iNPC);
	
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

	npc.AdjustWalkCycle();

	Ruina_Add_Battery(npc.index, 5.0);

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	if(fl_ruina_battery[npc.index]>2500.0)
	{
		if(fl_ruina_battery_timeout[npc.index] < GameTime)
		{
			
		}
	}
	else
	{
		
	}
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))	//a final final failsafe
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_bAllowBackWalking = false;
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);	

	Body_Pitch(npc, Npc_Vec, vecTarget);
	

	if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*5.0)
	{
		npc.m_bAllowBackWalking = true;
		npc.FaceTowards(vecTarget, 1500.0);
	}
	else
	{
		npc.m_bAllowBackWalking = false;
	}

	npc.PlayIdleAlertSound();
}
static void Body_Pitch(Lelouch npc, float VecSelfNpc[3], float vecTarget[3])
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

/*
static float Modify_Damage(Lelouch npc, int Target, float damage)
{
	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	//if(NpcStats_IsEnemySilenced(npc.index))
	//	damage *=0.5;

	//if(npc.Anger)
	//	damage *=1.3;

	if(Target > MaxClients)
		return damage;

	int weapon = GetEntPropEnt(Target, Prop_Send, "m_hActiveWeapon");
						
	if(!IsValidEntity(weapon))
		return damage;

	char classname[32];
	GetEntityClassname(weapon, classname, 32);

	int weapon_slot = TF2_GetClassnameSlot(classname);

	if(weapon_slot != 2 || i_IsWandWeapon[weapon])
		damage *= 1.7;

	return damage;
}*/
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	Lelouch npc = view_as<Lelouch>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		

/*
	if(!npc.Anger && (ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //Anger after half hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();


		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
*/	
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Lelouch npc = view_as<Lelouch>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
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
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
}