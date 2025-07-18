#pragma semicolon 1
#pragma newdecls required

#define ALTBOTSOLDIERMODEL	"models/bots/soldier/bot_soldier.mdl"

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsevere01.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere02.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere03.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere04.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere05.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/mvm/norm/taunts/soldier_mvm_taunts01.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts09.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts14.mp3",
	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/soldier_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts19.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts20.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts21.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bat_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/bison_main_shot_01.wav",
	"weapons/bison_main_shot_02.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/bison_reload.wav",
};

void MechaSoldier_Barrager_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheModel(ALTBOTSOLDIERMODEL);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Soldier Barrager");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_mecha_soldier_barrager");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "soldier"); 		//leaderboard_class_(insert the name)
	data.IconCustom = false;													//download needed?
	data.Flags = 0;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return MechaSoldier_Barrager(vecPos, vecAng, team);
}

methodmap MechaSoldier_Barrager < CClotBody
{
	property int m_iAmmo
	{
		public get()							{ return i_ammo_count[this.index]; }
		public set(int TempValueForProperty) 	{ i_ammo_count[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;	
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 80, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public MechaSoldier_Barrager(float vecPos[3], float vecAng[3], int ally)
	{
		MechaSoldier_Barrager npc = view_as<MechaSoldier_Barrager>(CClotBody(vecPos, vecAng, ALTBOTSOLDIERMODEL, "1.0", "2000", ally));

		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY2");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 270.0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iAmmo=10;
		b_we_are_reloading[npc.index]=false;
		fl_ruina_in_combat_timer[npc.index] = 2.0 + GetGameTime(npc.index);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/soldier/soldier_officer.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		SetEntityRenderColor(npc.m_iWearable3, 125, 100, 100, 255);
		
		
		npc.StartPathing();
		
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	MechaSoldier_Barrager npc = view_as<MechaSoldier_Barrager>(iNPC);

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
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.PlayIdleAlertSound();
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

	bool close = (flDistanceToTarget < 60000);
	int max_ammo = 10;
	
	if(npc.m_iAmmo<=0 && !b_we_are_reloading[npc.index] && !close)	//the npc will prefer to fully reload the clip before attacking, unless the target is too close.
	{
		b_we_are_reloading[npc.index]=true;
	}
	if((b_we_are_reloading[npc.index] || (close && npc.m_iAmmo<=0)) && npc.m_flReloadIn<GameTime)	//Reload IF. Target too close. Empty clip.
	{
		npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY2");
		npc.m_flReloadIn = 0.75 + GameTime;
		npc.m_iAmmo++;
		npc.PlayRangedReloadSound();
	}
	if(fl_ruina_in_combat_timer[npc.index] <= GameTime && npc.m_flReloadIn<GameTime && !b_we_are_reloading[npc.index] && !close && npc.m_iAmmo<max_ammo)	//reload if not attacking/idle for long
	{
		npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY2");
		npc.m_flReloadIn = 0.75 + GameTime;
		npc.m_iAmmo++;
		npc.PlayRangedReloadSound();
	}
	if(npc.m_iAmmo>=max_ammo)	//npc will stop reloading once clip size is full.
	{
		b_we_are_reloading[npc.index]=false;
	}
	if((npc.m_iAmmo<=0 || b_we_are_reloading[npc.index]) && !close)	//Run away if ammo is 0 or we are reloading. Don't run if target is too close
	{
		npc.StartPathing();
		
		npc.m_flSpeed = 250.0;	//reloading is a hard job.
		
		int Enemy_I_See;
		
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			float vBackoffPos[3];
			
			BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
			
			npc.SetGoalVector(vBackoffPos, true);
		}
	}
	else if(flDistanceToTarget < 120000 && npc.m_iAmmo>0)
	{
		npc.m_flSpeed = 270.0;
		int Enemy_I_See;
		
		fl_ruina_in_combat_timer[npc.index] = 2.5 + GameTime;
		
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{	
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GameTime && npc.m_iAmmo >=0)
			{
				//Play attack anim
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 750.0, _,vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.PlayMeleeSound();
				float dmg = 13.5;
				npc.FireParticleRocket(vecTarget, dmg , 750.0 , 1.0 , "raygun_projectile_blue");
				npc.m_flNextMeleeAttack = GameTime + 0.5;
				npc.m_flReloadIn = GameTime + 1.75;
				npc.m_iAmmo--;
			}
		}
		else
		{
			npc.StartPathing();
		}
	}
	else
	{
		npc.StartPathing();
	}
	//Predict their pos.
	if(flDistanceToTarget < npc.GetLeadRadius())
	{
		
		float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
		/*
		int color[4];
		color[0] = 255;
		color[1] = 255;
		color[2] = 0;
		color[3] = 255;
		
		int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
	
		TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
		TE_SendToAllInRange(vecTarget, RangeType_Visibility);
		*/
		
		npc.SetGoalVector(vPredictedPos);
	}
	else
	{
		npc.SetGoalEntity(PrimaryThreatIndex);
	}
}


static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	MechaSoldier_Barrager npc = view_as<MechaSoldier_Barrager>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	MechaSoldier_Barrager npc = view_as<MechaSoldier_Barrager>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}