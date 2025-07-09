#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/scout_paincrticialdeath01.mp3",
	"vo/scout_paincrticialdeath02.mp3",
	"vo/scout_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/scout_beingshotinvincible01.mp3",
	"vo/scout_beingshotinvincible02.mp3",
	"vo/scout_beingshotinvincible03.mp3",
	"vo/scout_beingshotinvincible04.mp3",
	"vo/scout_beingshotinvincible21.mp3",
	"vo/scout_beingshotinvincible05.mp3"
};

static const char g_IdleSounds[][] = {
	"vo/scout_standonthepoint01.mp3",
	"vo/scout_standonthepoint02.mp3",
	"vo/scout_standonthepoint03.mp3",
	"vo/scout_standonthepoint04.mp3",
	"vo/scout_standonthepoint05.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/scout_cartgoingbackdefense01.mp3",
	"vo/scout_cartgoingbackdefense02.mp3",
	"vo/scout_cartgoingbackdefense03.mp3",
	"vo/scout_cartgoingbackdefense04.mp3",
	"vo/scout_cartgoingbackdefense05.mp3",
	"vo/scout_cartgoingbackdefense06.mp3",
	"vo/scout_generic01.mp3"
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
static char g_AngerSounds[][] = {
	"vo/toughbreak/scout_quest_complete_easy_01.mp3",
	"vo/scout_apexofjump03.mp3",
	"vo/scout_autocappedintelligence02.mp3",
	"vo/scout_autodejectedtie04.mp3",
	"vo/scout_award05.mp3",				//LOOK AT ME!
	"vo/scout_domination17.mp3"
};

void Iana_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Iana");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_iana");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "iana"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
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
	PrecacheModel("models/player/scout.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Iana(vecPos, vecAng, team);
}

methodmap Iana < CClotBody
{
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

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

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
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
	
	public Iana(float vecPos[3], float vecAng[3], int ally)
	{
		Iana npc = view_as<Iana>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iChanged_WalkCycle = 1;

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		/*
			Bunsen Brave			"models/workshop/player/items/heavy/robo_heavy_chief/robo_heavy_chief.mdl"
			Dead of Night			"models/workshop/player/items/all_class/xms2013_jacket/xms2013_jacket_%s.mdl"
			Dr. gogglestache		"models/player/items/medic/hwn_medic_misc1.mdl"
			Hardium Helm			"models/workshop/player/items/soldier/hw2013_rocket_ranger/hw2013_rocket_ranger.mdl"
			Breakneck Baggies		"models/workshop/player/items/all_class/jogon/jogon_%s.mdl"
		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		static const char Items[][] = {
			"models/workshop/player/items/heavy/robo_heavy_chief/robo_heavy_chief.mdl",
			"models/workshop/player/items/all_class/xms2013_jacket/xms2013_jacket_scout.mdl",
			"models/player/items/medic/hwn_medic_misc1.mdl",
			"models/workshop/player/items/soldier/hw2013_rocket_ranger/hw2013_rocket_ranger.mdl",
			"models/workshop/player/items/all_class/jogon/jogon_scout.mdl",
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
		npc.m_iWearable6 = npc.EquipItemSeperate(Items[5],_,_,1.25,85.0);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_IANA_BLADE);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");

		SetVariantInt(RUINA_HALO_1);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");
				
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
		fl_ruina_battery_max[npc.index] = 3000.0;
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		npc.Anger = false;

		Ruina_Set_Heirarchy(npc.index, RUINA_MELEE_NPC);	//is a melee npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_MELEE_NPC, true, 15, 6);

		npc.m_iState = 0;
		
		return npc;
	}
	
	
}


static void ClotThink(int iNPC)
{
	Iana npc = view_as<Iana>(iNPC);
	
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
		float chargerPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", chargerPos);
		chargerPos[2] += 82.0;
		TE_ParticleInt(g_particleMissText, chargerPos);
		TE_SendToAll();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flDoingAnimation > GameTime)
		return;

	npc.AdjustWalkCycle();

	Ruina_Add_Battery(npc.index, 5.0);
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}

	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index])
	{
		fl_ruina_battery[npc.index] = 0.0;
		fl_ruina_battery_timer[npc.index] = GameTime + 5.0;
	}
	if(fl_ruina_battery_timer[npc.index]>GameTime)	//apply buffs
	{
		Master_Apply_Speed_Buff(npc.index, 130.0, 1.0, 1.3);
	}
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))	//a final final failsafe
	{
		Master_Apply_Defense_Buff(npc.index, 250.0, 5.0, 0.85);	//15% resistances
		Master_Apply_Attack_Buff(npc.index, 250.0, 5.0, 0.05);	//5% dmg bonus
		Master_Apply_Shield_Buff(npc.index, 250.0, 0.7);	//30% block shield

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

		float Range_Min = (npc.Anger ? (100.0*100.0) : (125.0*125.0));
		float Range_Max = (npc.Anger ? (2000.0*2000.0) : (1500.0*1500.0));

		if(Lanius_Teleport_Logic(npc.index, PrimaryThreatIndex, Range_Min, Range_Max, (npc.Anger ? 20.0 : 30.0), 100.0, 15.0, On_LaserHit))
			npc.PlayTeleportSound();

		if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				int amt_ion = (npc.Anger ? 20 : 10);
				if(npc.m_iState < amt_ion)
				{
					npc.m_flNextRangedBarrage_Singular = GameTime + (npc.Anger ? 0.5 : 0.8);
					npc.m_iState++;
					float Time = (npc.Anger ? 1.3 : 2.5);
					float Predicted_Pos[3],
					SubjectAbsVelocity[3];

					GetEntPropVector(Enemy_I_See, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);

					ScaleVector(SubjectAbsVelocity, Time);
					AddVectors(vecTarget, SubjectAbsVelocity, Predicted_Pos);

					//Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Predicted_Pos);

					float Radius = (npc.Anger ? 115.0 : 100.0);
					float dmg = (npc.Anger ? 300.0 : 250.0);
					int color[4]; Ruina_Color(color);

					float Thickness = 6.0;
					TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
					TE_SendToAll();
					TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.1, color, 1, 0);
					TE_SendToAll();
		
					Ruina_IonSoundInvoke(Predicted_Pos);
					
					DataPack pack;
					CreateDataTimer(Time, Ruina_Generic_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
					pack.WriteCell(EntIndexToEntRef(npc.index));
					pack.WriteFloatArray(Predicted_Pos, sizeof(Predicted_Pos));
					pack.WriteCellArray(color, sizeof(color));
					pack.WriteFloat(Radius);
					pack.WriteFloat(dmg);
					pack.WriteFloat(0.1);			//Sickness %
					pack.WriteCell(100);			//Sickness flat
					pack.WriteCell(false);			//Override sickness timeout

					if(!AtEdictLimit(EDICT_NPC))
					{
						if(!IsValidEntity(npc.m_iWearable8))
						{
							float flPos[3]; // original
							npc.GetAttachment("", flPos, NULL_VECTOR);
							npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "utaunt_poweraura_teamcolor_blue", npc.index, "", {0.0,0.0,0.0});
						}
						float Sky_Loc[3]; Sky_Loc = Predicted_Pos; Sky_Loc[2]+=500.0; Predicted_Pos[2]-=100.0;

						int laser;
						laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, Predicted_Pos, Sky_Loc);

						CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				else
				{
					if(IsValidEntity(npc.m_iWearable8))
						RemoveEntity(npc.m_iWearable8);

					npc.m_iState = 0;
					npc.m_flNextRangedBarrage_Spam = GameTime + (npc.Anger ? 20.0 : 30.0);
				}	
			}
		}

		Ruina_Self_Defense Melee;

		Melee.iNPC = npc.index;
		Melee.target = PrimaryThreatIndex;
		Melee.fl_distance_to_target = flDistanceToTarget;
		Melee.range = NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED;
		Melee.damage = (npc.Anger ? 300.0 : 200.0);			//heavy, but slow
		Melee.bonus_dmg = (npc.Anger ? 500.0 : 250.0);
		Melee.attack_anim = "ACT_MP_ATTACK_STAND_MELEE_ALLCLASS";
		Melee.swing_speed = (npc.Anger ? 3.0 : 4.0);
		Melee.swing_delay = 0.37;
		Melee.turn_speed = 20000.0;
		Melee.gameTime = GameTime;
		Melee.status = 0;
		Melee.Swing_Melee(OnRuina_MeleeAttack);

		switch(Melee.status)
		{
			case 1:	//we swung
				npc.PlayMeleeSound();
			case 2:	//we hit something
				npc.PlayMeleeHitSound();
			case 3:	//we missed
				npc.PlayMeleeMissSound();
			//0 means nothing.
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

static void OnRuina_MeleeAttack(int iNPC, int Target)
{
	Ruina_Add_Mana_Sickness(iNPC, Target, 0.1, 250);
}
static void On_LaserHit(int client, int Target, int damagetype, float damage)
{
	Ruina_Add_Mana_Sickness(client, Target, 0.25, 50);
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	Iana npc = view_as<Iana>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	int Health 		= GetEntProp(npc.index, Prop_Data, "m_iHealth"),
		MaxHealth 	= ReturnEntityMaxHealth(npc.index);
	
	float Ratio = (float(Health)/float(MaxHealth));

	if(!npc.Anger && Ratio < 0.5) 
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

static void NPC_Death(int entity)
{
	Iana npc = view_as<Iana>(entity);
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
}