#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/pistol/pistol_fire2.wav"
};

static const char g_RangedReloadSound[][] =
{
	"weapons/pistol/pistol_reload1.wav"
};

static const char g_IdleAlert[][] =
{
	"npc/metropolice/vo/airwatchsubjectis505.wav",
	"npc/metropolice/vo/allunitscloseonsuspect.wav",
	"npc/metropolice/vo/allunitsmovein.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/destroythatcover.wav"
};

static const char g_WarCry[][] = {
	"mvm/mvm_used_powerup.wav",
};

static float f_GlobalSoundCD;
bool buffing = false;

void Barracks_Combine_Commander_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_IdleAlert);
	PrecacheSoundArray(g_WarCry);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Combine Commander");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_combine_commander");
	data.IconCustom = false;
	
	data.Flags = 0;
	f_GlobalSoundCD = 0.0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Barrack_Combine_Commander(client, vecPos, vecAng, ally);
}

methodmap Barrack_Combine_Commander < BarrackBody
{
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
		
		EmitSoundToAll(g_IdleAlert[GetRandomInt(0, sizeof(g_IdleAlert) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayPistolReload()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayWarCry() 
	{
		if(f_GlobalSoundCD > GetGameTime())
			return;
			
		f_GlobalSoundCD = GetGameTime() + 5.0;

		EmitSoundToAll(g_WarCry[GetRandomInt(0, sizeof(g_WarCry) - 1)], this.index, _, 85, _, 0.8, 100);
	}

	public Barrack_Combine_Commander(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Barrack_Combine_Commander npc = view_as<Barrack_Combine_Commander>(BarrackBody(client, vecPos, vecAng, "100", COMBINE_CUSTOM_MODEL, STEPTYPE_COMBINE,"0.8",_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Combine_Commander_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Combine_Commander_ClotThink;
		npc.m_flSpeed = 220.0;

		npc.m_iAttacksTillReload = 6;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_commanderbufftime = 0.0;

		
		KillFeed_SetKillIcon(npc.index, "pistol");
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_helmet/tw_soldierbot_helmet.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2023_meancaptain/hwn2023_meancaptain_soldier.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_armor/tw_soldierbot_armor.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		return npc;
	}
}

public void Barrack_Combine_Commander_ClotThink(int iNPC)
{
	Barrack_Combine_Commander npc = view_as<Barrack_Combine_Commander>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			//Can we attack right now?
			if(buffing)
			{
				buffing = false;
				npc.AddGesture("ACT_SHOOTFLARE");
				npc.m_flNextRangedAttack = GameTime + 1.00;
				npc.m_flSpeed = 0.0;
			}

			if(flDistanceToTarget < 450000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iAttacksTillReload < 1 && !buffing)
					{
						npc.AddGesture("ACT_RELOAD_PISTOL");
						npc.m_flNextRangedAttack = GameTime + 1.00;
						npc.m_iAttacksTillReload = 6;
						npc.PlayPistolReload();
					}
					if(npc.m_flNextRangedAttack < GameTime && !buffing)
					{
						npc.AddGesture("ACT_DARIO_ATTACK_GUN_1", false);
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 450000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
							
							npc.m_flNextRangedAttack = GameTime + (1.25 * npc.BonusFireRate);
							npc.m_iAttacksTillReload -= 1.0;
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 17500.0, 1), DMG_CLUB, -1, _, vecHit);
						} 		
						delete swingTrace;				
					}
					else
					{
						npc.m_flSpeed = 210.0;
					}
				}
			}
			CommanderAOEBuff(npc,GetGameTime(npc.index));
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 210.0, "ACT_IDLE_BOBPRIME", "ACT_DARIO_1_WALK", 445000.0,_, true);
	}
}

void CommanderAOEBuff(Barrack_Combine_Commander npc, float gameTime)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_commanderbufftime < gameTime)
	{
		bool buffedAlly = false;
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (entitycount <= MaxClients || !b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetEntProp(entitycount, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (1000 * 1000))
					{
						f_GodAlaxiosBuff[entitycount] = GetGameTime() + 10.0; //allow buffing of players too if on red.
						//Buff this entity.
						f_GodAlaxiosBuff[npc.index] = GetGameTime() + 15.0;
						npc.m_commanderbufftime = GetGameTime() + 45.0;
						buffing = true;
						npc.PlayWarCry();
						if(entitycount != npc.index)
						{
							buffedAlly = true;
							float flPos[3]; // original
							Barrack_Combine_Commander npc1 = view_as<Barrack_Combine_Commander>(entitycount);
							GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", flPos);
							npc1.m_iWearable8 = ParticleEffectAt_Parent(flPos, "utaunt_glitter_parent_silver", npc1.index, "", {0.0,0.0,0.0});
							CreateTimer(10.0, Timer_RemoveEntity, EntIndexToEntRef(npc1.m_iWearable8), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
}

void Barrack_Combine_Commander_NPCDeath(int entity)
{
	Barrack_Combine_Commander npc = view_as<Barrack_Combine_Commander>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}