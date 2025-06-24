#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3"
};

static const char g_HurtSound[][] =
{
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3"
};

static const char g_IdleSound[][] =
{
	"vo/soldier_item_maggot_idle01.mp3",
	"vo/soldier_item_maggot_idle02.mp3",
	"vo/soldier_item_maggot_idle03.mp3",
	"vo/soldier_item_maggot_idle04.mp3",
	"vo/soldier_item_maggot_idle05.mp3",
	"vo/soldier_item_maggot_idle06.mp3",
	"vo/soldier_item_maggot_idle07.mp3",
	"vo/soldier_item_maggot_idle08.mp3",
	"vo/soldier_item_maggot_idle09.mp3",
	"vo/soldier_item_maggot_idle10.mp3"
};

static const char g_WinSounds[][] =
{
	"vo/soldier_mvm_collect_credits01.mp3"
};

static const char g_ReloadSounds[][] =
{
	"weapons/dumpster_rocket_reload.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/doom_rocket_launcher.wav"
};

void TrashMan_Setup()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_WinSounds);
	PrecacheSoundArray(g_ReloadSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Trash Mann");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_trashman");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TrashMan(client, vecPos, vecAng, team);
}

methodmap TrashMan < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetURandomInt() % sizeof(g_IdleSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetURandomInt() % sizeof(g_HurtSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{	
		EmitSoundToAll(g_DeathSounds[GetURandomInt() % sizeof(g_DeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayWinSound() 
	{
		EmitSoundToAll(g_WinSounds[GetURandomInt() % sizeof(g_WinSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + 12.0;
	}
	public void PlayReloadSound()
 	{
		EmitSoundToAll(g_ReloadSounds[GetURandomInt() % sizeof(g_ReloadSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public TrashMan(int client, float vecPos[3], float vecAng[3], int team)
	{
		TrashMan npc = view_as<TrashMan>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.1", "300", team));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_MP_STAND_PRIMARY");
		KillFeed_SetKillIcon(npc.index, "dumpster_device");
		i_NpcWeight[npc.index] = 4;

		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iAttacksTillReload = 0;
		npc.g_TimesSummoned = 0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[npc.index] = vecPos;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		int skin = GetURandomInt() % 2;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2019_racc_mann/hwn2019_racc_mann.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum24_justice_johns_style2/sum24_justice_johns_style2.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum24_pathfinder_style2/sum24_pathfinder_style2.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2020_trappers_hat/hwn2020_trappers_hat.mdl", _, skin);
		
		return npc;
	}
	
}

static void ClotThink(int iNPC)
{
	TrashMan npc = view_as<TrashMan>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.m_flDoingAnimation < gameTime)
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(npc.index, 350.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_STAND_PRIMARY", 240.0, gameTime);

	int target = npc.m_iTarget;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_iAttacksTillReload--;

			if(npc.m_iAttacksTillReload > 0)
			{
				npc.m_flAttackHappens = gameTime + 0.25;
			}
			else
			{
				npc.m_flAttackHappens = 0.0;
			}
			
			float vecTarget[3];
			bool targeted = IsValidEnemy(npc.index, target);
			
			if(targeted)
			{
				PredictSubjectPositionForProjectiles(npc, target, 600.0, _, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
			}
			else
			{
				WorldSpaceCenter(npc.index, vecTarget);
			}

			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", _, _, _, 3.0);
			npc.PlayMeleeSound();

			if(npc.g_TimesSummoned > 4 || (targeted && (GetURandomInt() % 7)))
			{
				npc.FireRocket(vecTarget, CasinoShared_GetDamage(npc, 0.8), 600.0);
			}
			else
			{
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				pos[2] += 30.0;
				
				int summon = NPC_CreateByName("npc_casinoratboom", -1, pos, ang, GetTeam(npc.index));
				if(summon > MaxClients)
				{
					Level[summon] = 6500;
					i_OwnerToGoTo[summon] = EntIndexToEntRef(npc.index);
					i_HpRegenInBattle[summon] = 6000;

					Apply_Text_Above_Npc(summon, 0, 2000000);
					CreateTimer(0.1, TimerHeavyBearBossInitiateStuff, EntIndexToEntRef(summon), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					SetEntProp(summon, Prop_Data, "m_iHealth", 2000000);
					SetEntProp(summon, Prop_Data, "m_iMaxHealth", 2000000);
					npc.g_TimesSummoned++;

					if(targeted)
						PluginBot_Jump(summon, vecTarget);
				}
			}
		}
	}

	if(target > 0)
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
		if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		npc.m_bisWalking = true;

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(npc.m_iAttacksTillReload < 3)
			{
				npc.PlayReloadSound();
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", _, _, _, 1.8);
				npc.m_iAttacksTillReload++;
				npc.m_flDoingAnimation = gameTime + 0.4;
				npc.m_flNextMeleeAttack = gameTime + 0.45;
			}
			else
			{
				npc.m_flAttackHappens = gameTime;
				npc.m_flNextMeleeAttack = gameTime + 1.15;
			}
		}
	}
	else if(npc.m_iAttacksTillReload > 0)
	{
		npc.m_flAttackHappens = gameTime;
		npc.m_flNextMeleeAttack = gameTime + 0.85;

		npc.PlayWinSound();
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	TrashMan npc = view_as<TrashMan>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}