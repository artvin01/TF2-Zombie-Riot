#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSound[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};


static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/chuckle.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static char g_MeleeHitSounds[][] = {
	
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};
static char g_RangedAttackSoundsSecondary[][] = {
	"common/wpn_hudoff.wav",
};
static char g_RocketSound[][] = {
	"weapons/rpg/rocketfire1.wav",
};
static const char g_HealSound[][] = {
	"items/medshot4.wav",
};

int WhiteflowerID;
static bool b_TouchedEnemyTarget[MAXENTITIES];
public void Whiteflower_Boss_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RocketSound));	i++) { PrecacheSound(g_RocketSound[i]);	}
	for (int i = 0; i < (sizeof(g_HealSound)); i++) { PrecacheSound(g_HealSound[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Whiteflower The Traitor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_boss");
	strcopy(data.Icon, sizeof(data.Icon), "whiteflower");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_WhiteflowerSpecial;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	WhiteflowerID = NPC_Add(data);
	PrecacheSound("plats/tram_hit4.wav");
	PrecacheModel("models/props_lakeside_event/bomb_temp.mdl");
	PrecacheSound("ambient/machines/teleport3.wav");
}

static void ClotPrecache()
{
	PrecacheSoundCustom("rpg_fortress/enemy/whiteflower_dash.mp3");
	PrecacheSoundCustom("#rpg_fortress/music/combine_elite_iberia_grandpabard.mp3");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Whiteflower_Boss(vecPos, vecAng, team, data);
}

methodmap Whiteflower_Boss < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,150);
		

	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);

	}
	public void PlayRocketSound()
 	{
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound(int target) 
	{
		int Health = GetEntProp(target, Prop_Data, "m_iHealth");
		
		if(Health <= 0)
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "Traitor!", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "Begone!", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "In my way!", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	
	property float m_flThrowSupportGrenadeHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flThrowSupportGrenadeHappeningCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flJumpCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flJumpHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flWasAirbornInJump
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flKickUpHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flKickUpCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flHitKickDoInstaDash
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flCooldownSay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flGetClosestTargetAllyTime
	{
		public get()							{ return fl_GetClosestTargetNoResetTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GetClosestTargetNoResetTime[this.index] = TempValueForProperty; }
	}
	public int FireGrenade(float vecTarget[3])
	{
		int entity = CreateEntityByName("tf_projectile_pipe_remote");
		if(IsValidEntity(entity))
		{
			float vecForward[3], vecSwingStart[3], vecAngles[3];
			this.GetVectors(vecForward, vecSwingStart, vecAngles);
	
			GetAbsOrigin(this.index, vecSwingStart);
			vecSwingStart[2] += 90.0;
	
			MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
	
			vecSwingStart[0] += vecForward[0] * 64;
			vecSwingStart[1] += vecForward[1] * 64;
			vecSwingStart[2] += vecForward[2] * 64;
	
			vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*800.0;
			vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*800.0;
			vecForward[2] = Sine(DegToRad(vecAngles[0]))*-800.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntProp(entity, Prop_Send, "m_iType", 1);
			
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 75.0); 
			f_CustomGrenadeDamage[entity] = 75.0;	
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			SetEntityModel(entity, "models/props_lakeside_event/bomb_temp.mdl");
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.4);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			b_StickyIsSticking[entity] = true;
			
	//		SetEntProp(entity, Prop_Send, "m_bTouched", true);
			SetEntityCollisionGroup(entity, 1);
			return entity;
		}
		return -1;
	}
	public Whiteflower_Boss(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Whiteflower_Boss npc = view_as<Whiteflower_Boss>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.15", "300", ally, false,_,_,_,_));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
		i_NpcWeight[npc.index] = 5;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");

		npc.SetActivity("ACT_WHITEFLOWER_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	
		npc.m_flGetClosestTargetAllyTime = 0.0;

		

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}

		EmitSoundToAll("ambient/machines/teleport3.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("ambient/machines/teleport3.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Whiteflower The leader");
			}
		}
		RaidModeTime = GetGameTime() + ((200.0) * (1.0 + (MultiGlobalEnemy * 0.4)));
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#rpg_fortress/music/combine_elite_iberia_grandpabard.mp3");
		music.Time = 187;
		music.Volume = 1.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Iberia's Last Stand");
		strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
		Music_SetRaidMusic(music);

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}

		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff

		RaidModeScaling *= 0.7;
		RaidModeScaling *= 1.85;

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		Citizen_MiniBossSpawn();

		func_NPCDeath[npc.index] = Whiteflower_Boss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_Boss_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_Boss_ClotThink;
		func_NPCDeathForward[npc.index] = Whiteflower_Boss_NPCDeathAlly;
		fl_TotalArmor[npc.index] = 0.35;
		b_thisNpcIsARaid[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		npc.m_flJumpCooldown = GetGameTime() + 10.0;
		npc.m_flThrowSupportGrenadeHappeningCD = GetGameTime() + 15.0;
		func_NPCFuncWin[npc.index] = view_as<Function>(WhiteflowerWinLine);
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/sbox2014_knight_helmet/sbox2014_knight_helmet_spy.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/hw2013_demo_cape/hw2013_demo_cape.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.StartPathing();
		AlreadySaidWin = false;
		
		return npc;
	}
	
}

public void WhiteflowerWinLine(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	CPrintToChatAll("{crimson}Whiteflower{default}: Now all thats left.\nIs Bob.");	
}

public void Whiteflower_Boss_ClotThink(int iNPC)
{
	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_HURT", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(IsValidEntity(RaidBossActive))
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		npc.StopPathing();
		npc.m_flNextThinkTime = FAR_FUTURE;
		i_RaidGrantExtra[npc.index] = 0;
		CPrintToChatAll("{crimson}Whiteflower{default}: Out of time, youre entirely surrounded.\nYou now belong to me.\nSubmit.\nHelp me kill Bob, and we will rule it all.");	
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		if(npc.m_flThrowSupportGrenadeHappeningCD < gameTime)
		{
			npc.m_iTargetWalkTo = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetAllyTime = GetGameTime(npc.index) + 1.0;
			//he will try to go to one of his allies.
		}
	}
	if(npc.m_flThrowSupportGrenadeHappeningCD < gameTime)
	{
		if(!IsValidAlly(npc.index, npc.m_iTargetWalkTo))
		{
			//Try again
			npc.m_iTargetWalkTo = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetAllyTime = GetGameTime(npc.index) + 1.0;
		}
		if(!IsValidAlly(npc.index, npc.m_iTargetWalkTo))
		{
			//if fail...
			npc.m_iTargetWalkTo = npc.m_iTarget;
		}
	}
	else
	{
		npc.m_iTargetWalkTo = npc.m_iTarget;
	}
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 40.0;
					damage *= 0.50;
					damage *= RaidModeScaling;
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();
						if(target <= MaxClients)
							Client_Shake(target, 0, 25.0, 25.0, 0.5, false);

						npc.PlayKilledEnemySound(npc.m_iTarget);
					}
				}
				delete swingTrace;
			}
		}
	}
	if(npc.m_flKickUpHappening)
	{
		if(npc.m_flKickUpHappening < gameTime)
		{
			npc.m_flKickUpHappening = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, .Npc_type = 1))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 45.0;
					damage *= 0.50;
					damage *= RaidModeScaling;
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						npc.m_flJumpCooldown = 0.0;
						npc.m_flHitKickDoInstaDash = 1.0;
						// Hit sound
						npc.PlayMeleeHitSound();
						
						if(b_ThisWasAnNpc[target])
							PluginBot_Jump(target, {0.0,0.0,300.0});
						else
							TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,300.0});

						Custom_Knockback(iNPC, target, 400.0, true);
						

						npc.PlayKilledEnemySound(npc.m_iTarget);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(npc.m_flJumpHappening)
	{
		int WhichEnemyToJump = 0;
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			WhichEnemyToJump = npc.m_iTarget;

		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo))
			WhichEnemyToJump = npc.m_iTargetWalkTo;

		if(IsValidEntity(WhichEnemyToJump))
		{
			float WorldSpaceCenterVec[3]; 
			WorldSpaceCenter(WhichEnemyToJump, WorldSpaceCenterVec);
			npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
		}
		//We want to jump at the enemy the moment we are allowed to!
		if(npc.m_flJumpHappening < gameTime)
		{
			npc.m_flJumpHappening = 0.0;
			if(IsValidEntity(WhichEnemyToJump))
			{
				float WorldSpaceCenterVec[3]; 
				float WorldSpaceCenterVecSelf[3]; 
				WorldSpaceCenter(WhichEnemyToJump, WorldSpaceCenterVec);
				WorldSpaceCenter(npc.index, WorldSpaceCenterVecSelf);

				float flDistanceToTarget = GetVectorDistance(WorldSpaceCenterVecSelf, WorldSpaceCenterVec);
				float SpeedToPredict = flDistanceToTarget * 2.0;
				if(npc.m_flHitKickDoInstaDash)
				{
					SpeedToPredict *= 0.15;
				}

				PredictSubjectPositionForProjectiles(npc, WhichEnemyToJump, SpeedToPredict, _,WorldSpaceCenterVec);
				//da jump!
				npc.m_flDoingAnimation = gameTime + 0.45;
				WorldSpaceCenterVec[2] += 15.0;
				PluginBot_Jump(npc.index, WorldSpaceCenterVec);
				f_CheckIfStuckPlayerDelay[npc.index] = GetGameTime() + 1.0;
				b_ThisEntityIgnoredBeingCarried[npc.index] = true;
				ApplyStatusEffect(npc.index, npc.index, "Intangible", 1.0);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				npc.m_flWasAirbornInJump = gameTime + 0.5;
				Zero(b_TouchedEnemyTarget);
				EmitCustomToAll("rpg_fortress/enemy/whiteflower_dash.mp3", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0, 100);
				IgniteTargetEffect(npc.index);
				if(npc.m_iChanged_WalkCycle != 7) 	
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_WHITEFLOWER_DASH_FLOAT");
					npc.AddGesture("ACT_WHITEFLOWER_DASH_START");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
		return;
	}
	if (!npc.m_flJumpHappening && npc.m_flWasAirbornInJump)
	{
		if(npc.IsOnGround() && npc.m_flWasAirbornInJump < gameTime)
		{
			b_ThisEntityIgnoredBeingCarried[npc.index] = false;
			npc.AddGesture("ACT_WHITEFLOWER_DASH_LAND", .SetGestureSpeed = 2.0);
			npc.m_flWasAirbornInJump = 0.0;
			npc.m_flHitKickDoInstaDash = 0.0;
			ExtinguishTarget(npc.index);
		}
		else
		{
			WhiteflowerKickLogic(npc.index);
		}
	}
	WF_ThrowGrenadeHappening(npc);

//always check!
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float flDistanceToTargetWalk;
		float flDistanceToTarget;
		float vecSelf[3];
		float vecTarget[3];
		float vecTargetWalk[3];
		WorldSpaceCenter(npc.index, vecSelf);
		if(IsValidEntity(npc.m_iTargetWalkTo))
		{
			WorldSpaceCenter(npc.m_iTargetWalkTo, vecTargetWalk);
			flDistanceToTargetWalk = GetVectorDistance(vecTargetWalk, vecSelf, true);
				
			//Predict their pos.
			if(flDistanceToTargetWalk < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3]; 
				PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_,vPredictedPos);
				
				npc.SetGoalVector(vPredictedPos);
			}
			else
			{
				npc.SetGoalEntity(npc.m_iTargetWalkTo);
			}
		}
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);


		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(npc.m_flThrowSupportGrenadeHappeningCD < gameTime && flDistanceToTargetWalk <= (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0))
		{
			npc.m_iState = 2;
		}
		else if (npc.m_flJumpCooldown < gameTime)
		{
			//We jump, no matter if far or close, see state to see more logic.
			//we melee them!
			npc.m_iState = 3; //enemy is abit further away.
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.65) && npc.m_flKickUpCD < gameTime)
		{
			npc.m_iState = 4; //Engage in Close Range Destruction.
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WHITEFLOWER_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
			}
			case 1:
			{			
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WHITEFLOWER_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					switch(GetRandomInt(0,1))
					{
						case 0:
							npc.AddGesture("ACT_WHITEFLOWER_ATTACK_LEFT", _,_,_,1.0);
						case 1:
							npc.AddGesture("ACT_WHITEFLOWER_ATTACK_RIGHT", _,_,_,1.0);
					}

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
				}
			}
			case 4:
			{			
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WHITEFLOWER_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;


					npc.PlayMeleeSound();
					
					npc.m_flKickUpHappening = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.45;
					npc.m_flKickUpCD = gameTime + 4.0;
					if(npc.m_iChanged_WalkCycle != 8) 	
					{
						npc.m_iChanged_WalkCycle = 8;
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
						
						npc.m_bisWalking = false;
						npc.SetActivity("ACT_WHITEFLOWER_KICK_GROUND");
						npc.SetPlaybackRate(2.0);
					}
				}
			}
			case 2:
			{			
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				//make sure to be close!
				if(flDistanceToTargetWalk <= (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0))
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_WHITEFLOWER_BOMB");
						npc.StopPathing();
							
					}
					npc.m_flAttackHappens = 0.0;
					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
					npc.m_flThrowSupportGrenadeHappeningCD = gameTime + 25.0;
					npc.m_flThrowSupportGrenadeHappening = gameTime + 1.0;
				}
			}
			case 3:
			{		
				//Jump at enemy	
				int WhichEnemyToJump = 0;
				if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					WhichEnemyToJump = npc.m_iTarget;

				if(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo))
					WhichEnemyToJump = npc.m_iTargetWalkTo;

				if(WhichEnemyToJump)
				{
					npc.FaceTowards(vecTargetWalk, 15000.0);
					npc.m_flAttackHappens = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextMeleeAttack = 0.0;
					npc.m_flJumpCooldown = gameTime + 5.0;
					if(!b_thisNpcIsABoss[npc.index])
						npc.m_flJumpCooldown = gameTime + 8.0;

					if(npc.m_iOverlordComboAttack == 1)
					{
						npc.m_flJumpCooldown = gameTime + 4.0;
					}
					//if enemy 
					npc.PlayRocketSound();
					if(b_thisNpcIsABoss[npc.index])
					{
						for(float loopDo = 1.0; loopDo <= 2.0; loopDo += 0.5)
						{
							float vecSelf2[3];
							WorldSpaceCenter(npc.index, vecSelf2);
							vecSelf2[2] += 50.0;
							vecSelf2[0] += GetRandomFloat(-10.0, 10.0);
							vecSelf2[1] += GetRandomFloat(-10.0, 10.0);
							float damage = 80.0;
							damage *= 0.50;
							damage *= RaidModeScaling;
							int RocketGet = npc.FireRocket(vecSelf2, damage, 200.0);
							int EnemySearch = GetClosestTarget(RocketGet, true, _, true, _, _, _, true, .UseVectorDistance = true);
							if(IsValidEnemy(npc.index, EnemySearch))
							{
								DataPack pack;
								CreateDataTimer(loopDo, WhiteflowerTank_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);
								pack.WriteCell(EntIndexToEntRef(RocketGet));
								pack.WriteCell(EntIndexToEntRef(EnemySearch));
							}
						}
					}
					/*
					if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
					*/
					{
						//enemy is indeed to far away, jump at them
						if(!npc.m_flHitKickDoInstaDash)
							npc.m_flJumpHappening = gameTime + 0.25;
						else
							npc.m_flJumpHappening = 1.0;

						float flPos[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
						flPos[2] += 70.0;
						int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 1.0);
						SetParent(npc.index, particler);
						if(npc.m_iChanged_WalkCycle != 6) 	
						{
							IgniteTargetEffect(npc.index);
							npc.m_bisWalking = false;
							npc.m_iChanged_WalkCycle = 6;
							npc.SetActivity("ACT_WHITEFLOWER_IDLE");
							npc.SetPlaybackRate(0.0);
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
						}
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_WHITEFLOWER_RUN");
						npc.m_flSpeed = 350.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}


public Action Whiteflower_Boss_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	if(RoundToCeil(damage) > Health)
	{	
		if(i_RaidGrantExtra[npc.index] == 1)
			CPrintToChatAll("{crimson}Whiteflower{default}: Y-You... fucking rats... Rot in hell Bob...\n...\nWhiteflower Perishes.\nHis army scatteres.");	
		
		npc.StopPathing();
		ApplyStatusEffect(victim, victim, "Infinite Will", 5.0);
		RequestFrames(KillNpc, 66 * 2, EntIndexToEntRef(npc.index));
		//2 seconds.
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_WHITEFLOWER_DEATH");
		SetEntProp(victim, Prop_Data, "m_bSequenceLoops", false);
		func_NPCDeath[npc.index] = Whiteflower_Boss_NPCDeath_After;
		func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
		func_NPCDeathForward[npc.index] = INVALID_FUNCTION;
		npc.m_flNextThinkTime = FAR_FUTURE;
		b_OnDeathExtraLogicNpc[npc.index] |= ZRNPC_DEATH_NOGIB;
		RaidModeTime = FAR_FUTURE;
		return Plugin_Changed;
	}
	return Plugin_Changed;
}

public void Whiteflower_Boss_NPCDeath(int entity)
{
	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	if(i_RaidGrantExtra[npc.index] == 1)
		CPrintToChatAll("{crimson}Whiteflower{default}: Y-You... fucking rats... Rot in hell Bob...\n...\nWhiteflower Perishes.\nHis army scatteres.");	
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

public void Whiteflower_Boss_NPCDeath_After(int entity)
{
	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}



void WF_ThrowGrenadeHappening(Whiteflower_Boss npc)
{
	if(npc.m_flThrowSupportGrenadeHappening)
	{
		if(npc.m_flThrowSupportGrenadeHappening < GetGameTime())
		{
			npc.m_flThrowSupportGrenadeHappening = 0.0;
			float vecTarget[3];
			float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );

			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				PredictSubjectPositionForProjectiles(npc, npc.index, 800.0,_,vecTarget);
			}
			else
			{
				WorldSpaceCenter(npc.index, vecTarget);
				//incase theres no valid enemy, throw onto ourselves instead.
			}
			//damage doesnt matter.
			int Grenade = npc.FireGrenade(vecTarget);
			float GrenadeRangeSupport = 250.0;
			float damage = 60.0;
			damage *= 0.50;
			damage *= RaidModeScaling;
			float HealDo = 5000.0;
			HealDo *= RaidModeScaling;
			WF_GrenadeSupportDo(npc.index, Grenade, damage, GrenadeRangeSupport, HealDo);
			float SpeedReturn[3];
			ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 1.75, 1.0);
			TeleportEntity(Grenade, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
			//Throw a grenade towards the target!
		}
	}
}

void WF_GrenadeSupportDo(int entity, int grenade, float damage, float RangeSupport, float HealDo)
{
	DataPack pack;
	CreateDataTimer(1.5, Timer_WF_SupportGrenade, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(grenade));
	pack.WriteFloat(damage);
	pack.WriteFloat(RangeSupport * 0.9);
	pack.WriteFloat(HealDo);

	
	DataPack pack2;
	CreateDataTimer(0.25, Timer_WF_SupportGrenadeIndication, pack2, TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(entity));
	pack2.WriteCell(EntIndexToEntRef(grenade));
	pack2.WriteFloat(damage);
	pack2.WriteFloat(RangeSupport);
}

public Action Timer_WF_SupportGrenadeIndication(Handle timer, DataPack pack)
{
	pack.Reset();
	int OwnerNpc = EntRefToEntIndex(pack.ReadCell());
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(OwnerNpc))
	{
		if(IsValidEntity(Projectile))
		{
			//Cancel.
			RemoveEntity(Projectile);
		}
		return Plugin_Stop;
	}
	else
	{
		if(!IsEntityAlive(OwnerNpc))
		{
			if(IsValidEntity(Projectile))
			{
				//Cancel.
				RemoveEntity(Projectile);
			}
			return Plugin_Stop;
		}
	}
	if(!IsValidEntity(Projectile))
		return Plugin_Stop;
		
	float DamageDeal = pack.ReadFloat();
	float RangeSupport = pack.ReadFloat();
	float RangeSupport2 = RangeSupport * 0.25; 
	

	float pos[3]; GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 5.0;
	if(DamageDeal >= 1.0)
	{
		spawnRing_Vectors(pos, RangeSupport * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.3, 2.0, 2.0, 2);
		spawnRing_Vectors(pos, RangeSupport2 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.3, 2.0, 2.0, 2);
	}
	else
	{
		spawnRing_Vectors(pos, RangeSupport * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, 0.3, 2.0, 2.0, 2);
		spawnRing_Vectors(pos, RangeSupport2 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, 0.3, 2.0, 2.0, 2);
	}
	return Plugin_Continue;
}

public Action Timer_WF_SupportGrenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int OwnerNpc = EntRefToEntIndex(pack.ReadCell());
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(OwnerNpc))
	{
		if(IsValidEntity(Projectile))
		{
			//Cancel.
			RemoveEntity(Projectile);
		}
		return Plugin_Stop;
	}
	else
	{
		if(!IsEntityAlive(OwnerNpc))
		{
			if(IsValidEntity(Projectile))
			{
				//Cancel.
				RemoveEntity(Projectile);
			}
			return Plugin_Stop;
		}
	}
	
	if(!IsValidEntity(Projectile))
		return Plugin_Stop;
		
	float DamageDeal = pack.ReadFloat();
	float RangeSupport = pack.ReadFloat();
	float HealDo = pack.ReadFloat();

	if(DamageDeal >= 1.0)
	{
		float pos[3]; GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 5.0;

		spawnRing_Vectors(pos, 2.0 /*startin range*/, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.5, 2.0, 2.0, 2, RangeSupport * 2.0);
		Explode_Logic_Custom(DamageDeal , OwnerNpc , OwnerNpc , -1 , pos , RangeSupport);	//acts like a rocket
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(pos[0]);
		pack_boom.WriteFloat(pos[1]);
		pack_boom.WriteFloat(pos[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
	}
	if(HealDo >= 1.0)
	{
		ExpidonsaGroupHeal(Projectile, RangeSupport, 99, HealDo, 1.15, false);
		DesertYadeamDoHealEffect(Projectile, RangeSupport);
	}
	return Plugin_Continue;

}



public void Whiteflower_Boss_NPCDeathAlly(int self, int ally)
{
	
	if(GetTeam(ally) != GetTeam(self))
	{
		return;
	}

	int speech = GetRandomInt(1,10);
	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(self);
	float ReduceEnemyCountLogic = 1.0 / MultiGlobalEnemy;
	if(!Waves_InFreeplay())
	{
		fl_TotalArmor[self] *= (1.0 + (0.005 * ReduceEnemyCountLogic));
		if(fl_TotalArmor[self] >= 1.0)
		{
			fl_TotalArmor[self] = 1.0;
		}
	}
	
	RaidModeScaling *= (1.0- (0.0025 * ReduceEnemyCountLogic));
	if(npc.m_flCooldownSay > GetGameTime())
	{
		return;
	}
	npc.m_flCooldownSay = GetGameTime() + 20.0;
	switch(speech)
	{
		case 1:
		{
			CPrintToChatAll("{crimson}Whiteflower{default}: Argk... Youre next.");
		}
		case 2:
		{
			CPrintToChatAll("{crimson}Whiteflower{default}: Why are you running?");	
		}
		case 3:
		{
			if(!Waves_InFreeplay())
			{
				CPrintToChatAll("{crimson}Whiteflower{default}: First my army so im alone? Pah!");
			}
			else
			{
				CPrintToChatAll("{crimson}Whiteflower{default}: From one maniac to another huh?");
			}
			
		}
		case 4:
		{
			CPrintToChatAll("{crimson}Whiteflower{default}: You are dirty.");	
		}
		case 5:
		{
			CPrintToChatAll("{crimson}Whiteflower{default}: From one maniac to another huh?");	
		}
		case 6:
		{
			CPrintToChatAll("{crimson}Whiteflower{default}: You are just like them, weak.");	
		}
		case 7:
		{
			CPrintToChatAll("{crimson}Whiteflower{default}: You are a fool.");	
		}
		case 8:
		{
			CPrintToChatAll("{crimson}Whiteflower{default}: Such ignorance.");	
		}
		case 9:
		{
			if(!Waves_InFreeplay())
			{
				CPrintToChatAll("{crimson}Whiteflower{default}: They atleast believe in their leader, do you?");	
			}
			else
			{
				CPrintToChatAll("{crimson}Whiteflower{default}: Argk... Youre next.");
			}	
		}
		case 10:
		{
			if(!Waves_InFreeplay())
			{
				CPrintToChatAll("{crimson}Whiteflower{default}: I actually care for them, do you care for your own army?");	
			}
			else
			{
				CPrintToChatAll("{crimson}Whiteflower{default}: You are dirty.");
			}
		}
	}
	if(!Waves_InFreeplay())
	{
		CPrintToChatAll("He weakens as you defeat his army.");	
	}
}


static void Whiteflower_KickTouched(int entity, int enemy)
{
	if(!IsValidEnemy(entity, enemy))
		return;

	if(b_TouchedEnemyTarget[enemy])
		return;

	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(entity);
	b_TouchedEnemyTarget[enemy] = true;
	npc.AddGesture("ACT_WHITEFLOWER_DASH_KICK", .SetGestureSpeed = 2.0);
	
	float targPos[3];
	WorldSpaceCenter(enemy, targPos);
	float damage = 60.0;
	damage *= 0.50;
	damage *= RaidModeScaling;
	SDKHooks_TakeDamage(enemy, entity, entity, damage, DMG_CLUB, -1, NULL_VECTOR, targPos);
	ParticleEffectAt(targPos, "skull_island_embers", 2.0);
	npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);

	if(enemy <= MaxClients)
	{
		f_AntiStuckPhaseThrough[enemy] = GetGameTime() + 1.0;
		ApplyStatusEffect(enemy, enemy, "Intangible", 1.0);
		Custom_Knockback(entity, enemy, 1500.0, true, true);
		TF2_AddCondition(enemy, TFCond_LostFooting, 0.5);
		TF2_AddCondition(enemy, TFCond_AirCurrent, 0.5);
	}
	else
	{
		Custom_Knockback(entity, enemy, 800.0, true, true);
	}
}

void WhiteflowerKickLogic(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	static float vel[3];
	static float flMyPos[3];
	npc.GetVelocity(vel);
	fClamp(vel[0], -300.0, 300.0);
	fClamp(vel[1], -300.0, 300.0);
	fClamp(vel[2], -300.0, 300.0);
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
	static float hullcheckmins[3];
	static float hullcheckmaxs[3];
	if(b_IsGiant[iNPC])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else if(f3_CustomMinMaxBoundingBox[iNPC][1] != 0.0)
	{
		hullcheckmaxs[0] = f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmaxs[1] = f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmaxs[2] = f3_CustomMinMaxBoundingBox[iNPC][2];

		hullcheckmins[0] = -f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmins[1] = -f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmins[2] = 0.0;	
	}
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
	}
	
	static float flPosEnd[3];
	flPosEnd = flMyPos;
	ScaleVector(vel, 0.1);
	AddVectors(flMyPos, vel, flPosEnd);
	
	ResetTouchedentityResolve();
	ResolvePlayerCollisions_Npc_Internal(flMyPos, flPosEnd, hullcheckmins, hullcheckmaxs, iNPC);

	for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
	{
		if(!TouchedNpcResolve(entity_traced))
			break;

		if(i_IsABuilding[ConvertTouchedResolve(entity_traced)])
			continue;
		
		Whiteflower_KickTouched(iNPC,ConvertTouchedResolve(entity_traced));
	}
	ResetTouchedentityResolve();
}



public Action WhiteflowerTank_Rocket_Stand(Handle timer, DataPack pack)
{
	pack.Reset();
	int RocketEnt = EntRefToEntIndex(pack.ReadCell());
	int EnemyEnt = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(RocketEnt))
		return Plugin_Stop;
		
	if(!IsValidEntity(EnemyEnt))
	{
		RemoveEntity(RocketEnt);
		return Plugin_Stop;
	}
	bool PlaySound = true;
	int Owner = GetEntPropEnt(RocketEnt, Prop_Send, "m_hOwnerEntity");
	int SpecialLogic = 0;
	if(IsValidEntity(Owner))
	{
		if(i_NpcInternalId[Owner] != WhiteflowerID && b_thisNpcIsARaid[Owner])
		{
			PlaySound = false;
		}
		if(i_NpcInternalId[Owner] == SensalNPCID())
		{
			SpecialLogic = 1;
		}
	}
	if(PlaySound)
		EmitSoundToAll("weapons/sentry_spot_client.wav", RocketEnt, SNDCHAN_AUTO, 80, _, 0.7,_);	

	float vecSelf[3];
	WorldSpaceCenter(RocketEnt, vecSelf);
	float vecEnemy[3];
	WorldSpaceCenter(EnemyEnt, vecEnemy);
	
	TE_SetupBeamPoints(vecSelf, vecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {0,0,255,255}, 3);
	TE_SendToAll(0.0);
	float vecAngles[3];
	MakeVectorFromPoints(vecSelf, vecEnemy, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	if(SpecialLogic == 1)
	{
		vecAngles[0] += 90.0;
		vecAngles[1] += 90.0;
		vecAngles[2] += 180.0;
	}
	TeleportEntity(RocketEnt, NULL_VECTOR, vecAngles, {0.0,0.0,0.0});
	//look at target constantly.
	DataPack pack2;
	CreateDataTimer(0.1, WhiteflowerTank_Rocket_Stand_Fire, pack2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(RocketEnt));
	pack2.WriteCell(EntIndexToEntRef(EnemyEnt));
	pack2.WriteFloat(GetGameTime() + 1.0); //time till rocketing to enemy
	return Plugin_Stop;
}


public Action WhiteflowerTank_Rocket_Stand_Fire(Handle timer, DataPack pack)
{
	pack.Reset();
	int RocketEnt = EntRefToEntIndex(pack.ReadCell());
	int EnemyEnt = EntRefToEntIndex(pack.ReadCell());
	float TimeTillRocketing = pack.ReadFloat();
	if(!IsValidEntity(RocketEnt))
		return Plugin_Stop;
		
	if(!IsValidEntity(EnemyEnt))
	{
		RemoveEntity(RocketEnt);
		return Plugin_Stop;
	}

	//keep looking at them
	float vecSelf[3];
	WorldSpaceCenter(RocketEnt, vecSelf);
	float vecEnemy[3];
	WorldSpaceCenter(EnemyEnt, vecEnemy);
	int SpecialLogic = 0;
	int Owner = GetEntPropEnt(RocketEnt, Prop_Send, "m_hOwnerEntity");
	if(IsValidEntity(Owner))
	{
		if(i_NpcInternalId[Owner] == SensalNPCID())
		{
			SpecialLogic = 1;
		}
	}
	float VecSpeedToDo[3];
	float vecAngles[3];
	MakeVectorFromPoints(vecSelf, vecEnemy, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	if(TimeTillRocketing < GetGameTime())
	{
		float SpeedApply = 1000.0;
		VecSpeedToDo[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*SpeedApply;
		VecSpeedToDo[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*SpeedApply;
		VecSpeedToDo[2] = Sine(DegToRad(vecAngles[0]))*-SpeedApply;
		TE_SetupBeamPoints(vecSelf, vecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {255,0,0,255}, 3);
		TE_SendToAll(0.0);
		
		bool PlaySound = true;
		if(IsValidEntity(Owner))
		{
			if(i_NpcInternalId[Owner] != WhiteflowerID && b_thisNpcIsARaid[Owner])
			{
				PlaySound = false;
			}
		}
		if(PlaySound)
			EmitSoundToAll("weapons/sentry_rocket.wav", RocketEnt, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.5,_);	
		else
			EmitSoundToAll("weapons/airstrike_fire_01.wav", RocketEnt, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.9,GetRandomInt(70,80));	
	}
	else
	{
		
		TE_SetupBeamPoints(vecSelf, vecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.11, 3.0, 3.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
	if(SpecialLogic == 1)
	{
		vecAngles[0] += 90.0;
		vecAngles[1] += 90.0;
		vecAngles[2] += 180.0;
	}
	TeleportEntity(RocketEnt, NULL_VECTOR, vecAngles, VecSpeedToDo);
	if(TimeTillRocketing < GetGameTime())
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
