#pragma semicolon 1
#pragma newdecls required

//static Handle syncdashhud;
static int Has_a_bob[MAXPLAYERS+1]={0, ...};
static int bob_owner_id[MAXPLAYERS+1]={0, ...};
static int who_owns_this_bob[2048]={0, ...};

static char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};


static char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/metropolice/vo/putitinthetrash1.wav",
	"npc/metropolice/vo/putitinthetrash2.wav",
	
};

static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav",
};

static char g_Moving_Sound[][] = {
	"npc/metropolice/vo/readytojudge.wav",
};

static char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


static char g_RangedAttackSounds[][] = {
	"weapons/pistol/pistol_fire2.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/pistol/pistol_reload1.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/stunstick/spark1.wav",
	"weapons/stunstick/spark2.wav",
	"weapons/stunstick/spark3.wav",
};

public void BobTheGod_OnPluginStart()
{
	return;
//	syncdashhud = CreateHudSynchronizer();
}
public void BobTheGod_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_Moving_Sound)); i++) { PrecacheSound(g_Moving_Sound[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("items/smallmedkit1.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	
	for(int client = 1; client <= MaxClients; client++)
	{
		Has_a_bob[client] = 0;
	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob the Second");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_the_overlord");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BobTheGod(client, vecPos, vecAng, ally);
}

methodmap BobTheGod < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, 80, _, 1.0);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, 80, _, 1.0);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, 80, _, 1.0);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
		
		
	}
	
	public void PlayMovingSound() {
		
		EmitSoundToAll(g_Moving_Sound[GetRandomInt(0, sizeof(g_Moving_Sound) - 1)], this.index, SNDCHAN_VOICE, 80, _, 1.0);
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, 80, _, 1.0);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, 80, _, 1.0);
		
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, 80, _, 0.7);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, 80, _, 1.0);
		

	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, 80, _, 1.0);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, 80, _, 1.0);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, 80, _, 1.0);
		
		
	}


	public BobTheGod(int client, float vecPos[3], float vecAng[3], int ally)
	{
		
		BobTheGod npc = view_as<BobTheGod>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "0.7", "9999999", ally, true));
		
		i_NpcWeight[npc.index] = 999;

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;	
		
		SetEntProp(npc.index, Prop_Send, "m_iTeamNum", TFTeam_Red);
		
	//	SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		
		func_NPCDeath[npc.index] = BobTheGod_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = BobTheGod_OnTakeDamage;
		func_NPCThink[npc.index] = BobTheGod_ClotThink;
		func_NPCActorEmoted[npc.index] = BobTheGod_PluginBot_OnActorEmoted;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 50000001);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 50000001);
					
		
		npc.m_bThisEntityIgnored = true;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		
		
		SDKHook(npc.index, SDKHook_Think, BobTheGod_ClotThink);
		
		SDKHook(client, SDKHook_OnTakeDamageAlive, BobTheGod_Owner_Hurt);
		
		SetEntProp(npc.index, Prop_Send, "m_iTeamNum", GetClientTeam(client));
		
		Has_a_bob[client] = npc.index;
		
		npc.m_b_follow = true;
		
		npc.m_b_stand_still = false;
		bob_owner_id[client] = npc.index;
		who_owns_this_bob[npc.index] = client;
		
		npc.m_fbGunout = false;
		npc.m_bIsFriendly = false;
		npc.m_bReloaded = true;
		npc.m_iAttacksTillReload = 24;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_bmovedelay_walk = false;
		npc.m_bmovedelay = false;
		npc.m_bmovedelay_run = false;
		
		npc.m_iMedkitAnnoyance = 0;
				
		npc.m_iState = 0;
		npc.m_flSpeed = 180.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_bScalesWithWaves = true;

		npc.m_iWearable2 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntityCollisionGroup(npc.m_iWearable1, 27);
		
		SetEntityCollisionGroup(npc.m_iWearable2, 27);
		
		SetEntityCollisionGroup(npc.m_iWearable3, 27);
		
		SetEntityCollisionGroup(npc.index, 27);
		
		
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable1, "Enable");
					
		return npc;
		
	}
	
	
}


public void BobTheGod_ClotThink(int iNPC)
{
	BobTheGod npc = view_as<BobTheGod>(iNPC);
	
	
	//Don't let clients decide the bodygroups :angry:
	
	int client = who_owns_this_bob[npc.index];
	
	if(!IsValidClient(client))
	{
		SmiteNpcToDeath(iNPC);
		return;
	}
	
	if(npc.m_flNextThinkTime < GetGameTime(npc.index))
	{
		if (IsValidClient(client))
		{
			/*
			SetGlobalTransTarget(client);
			if(!npc.m_bIsFriendly && npc.m_b_follow && !npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is not friendly and follows you!", "Use voice Commands to command him!");
			}
			else if (npc.m_bIsFriendly && npc.m_b_follow && !npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is friendly and follows you!", "Use voice Commands to command him!");
			}
			else if(!npc.m_bIsFriendly && !npc.m_b_follow && !npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is not friendly and doesn't follow you!", "Use voice Commands to command him!");
			}
			else if (npc.m_bIsFriendly && !npc.m_b_follow && !npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is friendly and doesn't follow you!", "Use voice Commands to command him!");
			}
			else if(!npc.m_bIsFriendly && npc.m_b_follow && npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is not friendly and follows you! BUT stands still.", "Use voice Commands to command him!");
			}
			else if (npc.m_bIsFriendly && npc.m_b_follow && npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is friendly and follows you! BUT stands still", "Use voice Commands to command him!");
			}
			else if(!npc.m_bIsFriendly && !npc.m_b_follow && npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is not friendly and doesn't follow you! BUT stands still", "Use voice Commands to command him!");
			}
			else if (npc.m_bIsFriendly && !npc.m_b_follow && npc.m_b_stand_still)
			{
				SetHudTextParams(0.9, 0.72, 0.15, 180, 180, 180, 180);
				ShowSyncHudText(client, syncdashhud, "%t\n%t [%i/24]\n%t\n%t", "Bob The Second", "Pistol Ammo", npc.m_iAttacksTillReload, "Bob The Second is friendly and doesn't follow you! BUT stands still", "Use voice Commands to command him!");
			}
			*/
			npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.04;
			npc.Update();
		}
		else
		{
			npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.04;
			npc.Update();
		}
	}
	else
		return;
		
	float flDistanceToOwner;
	if(IsValidClient(client))
	{
		if(IsPlayerAlive(client) && npc.m_b_follow)
		{
			float vecTarget[3]; WorldSpaceCenter(client, vecTarget );
			float Vecself[3]; WorldSpaceCenter(npc.index, Vecself );
			flDistanceToOwner = GetVectorDistance(vecTarget, Vecself, true);
		}
		else
		{
			flDistanceToOwner = 0.0;
		}
	}
	else
	{
		SDKHooks_TakeDamage(iNPC, 0, 0, 999999999.0, DMG_GENERIC); //Kill it so it triggers the neccecary shit.
		return;
	}
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		int attacker;
		if(IsPlayerAlive(client))
		{
			attacker = GetClosestTarget(client, _, _, true);
		}
		else
		{
			attacker = GetClosestTarget(npc.index, _, _, true);
		}
		if(IsValidEnemy(npc.index, attacker, true))
		{
			
			float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget );
			float Vecself[3]; WorldSpaceCenter(npc.index, Vecself);	
			float flDistanceToTarget = GetVectorDistance(vecTarget, Vecself, true);
			
			if(!IsPlayerAlive(client))
			{
			//	NPCDeath(npc.index);
				// Just kill him off, makes it easier on us.
				flDistanceToTarget = 0.0;
			}
			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
			{
				npc.m_iTarget = attacker;
			}
			else
			{
				npc.m_iTarget = 0;
			}
		}
	}
	
	
	if(npc.m_iTarget != 0 && npc.m_flComeToMe < GetGameTime(npc.index) && npc.m_flDoingSpecial < GetGameTime(npc.index) && !npc.m_bIsFriendly && (flDistanceToOwner < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0) || !npc.m_b_stand_still))
	{
		npc.m_iState = 1;
		
		if(!IsValidEnemy(npc.index, npc.m_iTarget, true))
		{
			//Stop chasing dead target.
			npc.m_iTarget = 0;
			npc.StopPathing();
			
			npc.PlayIdleSound();
		}
		else
		{
			int PrimaryThreatIndex = npc.m_iTarget;
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
					
			float Vecself[3]; WorldSpaceCenter(client, Vecself);	
			float flDistanceToTarget = GetVectorDistance(vecTarget, Vecself, true);
			if (npc.m_fbGunout == false && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				if (!npc.m_bmovedelay)
				{
					int iActivity_melee = npc.LookupActivity("ACT_RUN");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay = true;
					npc.m_flSpeed = 260.0;
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
				}

				npc.FaceTowards(vecTarget);
				
			}
			else if (npc.m_fbGunout == true && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				int iActivity_melee = npc.LookupActivity("ACT_IDLE_ANGRY_PISTOL");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay = false;
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				npc.FaceTowards(vecTarget, 1000.0);
				npc.StopPathing();
				
			}
			
			
			if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
			{
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			else
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			
			if((!npc.m_b_stand_still && npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0) && npc.m_flReloadDelay < GetGameTime(npc.index)) || (npc.m_b_stand_still && npc.m_flNextRangedAttack < GetGameTime(npc.index) && npc.m_flReloadDelay < GetGameTime(npc.index) && flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0)))
			{
	
				float vecSpread = 0.1;
				
				float npc_pos[3];
				GetAbsOrigin(npc.index, npc_pos);
					
				npc_pos[2] += 30.0;
					
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float m_vecSrc[3];
				
				m_vecSrc = npc_pos;
				
				float vecEnd[3];
				vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
				vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
				vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
				
				//add the spray
				float vecbro[3];
				vecbro[0] = vecDirShooting[0] + 0.0 * vecSpread * vecRight[0] + 0.0 * vecSpread * vecUp[0]; 
				vecbro[1] = vecDirShooting[1] + 0.0 * vecSpread * vecRight[1] + 0.0 * vecSpread * vecUp[1]; 
				vecbro[2] = vecDirShooting[2] + 0.0 * vecSpread * vecRight[2] + 0.0 * vecSpread * vecUp[2]; 
				NormalizeVector(vecbro, vecbro);
				
				int target = Trace_Test(npc.index, npc_pos, vecbro, 9000.0);
				
				if(!IsValidEnemy(npc.index, target, true))
				{
					if (!npc.m_bmovedelay)
					{
						int iActivity_melee = npc.LookupActivity("ACT_RUN");
						if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
						npc.m_bmovedelay = true;
						npc.m_flSpeed = 260.0;
					}
	
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
					npc.FaceTowards(vecTarget);
					npc.StartPathing();
					
					npc.m_fbGunout = false;
				}
				else
				{
					npc.m_fbGunout = true;
					
					npc.m_bmovedelay = false;
					
					npc.FaceTowards(vecTarget, 1000.0);
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.1;
					npc.m_iAttacksTillReload -= 1;
					
					if (npc.m_iAttacksTillReload == 0)
					{
						npc.AddGesture("ACT_RELOAD_PISTOL");
						npc.m_flReloadDelay = GetGameTime(npc.index) + 1.4;
						npc.m_iAttacksTillReload = 24;
						npc.PlayRangedReloadSound();
						npc.m_bReloaded = true;
					//	//PrintHintText(client, "Bob The Second: Reloading!");
					}
					
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
					//add the spray
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					FireBullet(npc.index, npc.m_iWearable2, npc_pos, vecDir, 12.0, 9000.0, DMG_BULLET, "bullet_tracer01_red", _, _ , "muzzle");
					npc.PlayRangedSound();
					npc.m_bReloaded = false;
				}
			}
			else if((!npc.m_b_stand_still && (flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0) || flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)) && npc.m_flReloadDelay < GetGameTime(npc.index)) || (npc.m_b_stand_still && flDistanceToTarget < 100 && npc.m_flReloadDelay < GetGameTime(npc.index)))
			{
				if(!npc.m_b_stand_still && flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
				{
					npc.StartPathing();
					
					npc.m_fbGunout = false;
					//Look at target so we hit.
					npc.FaceTowards(vecTarget, 1500.0);
				}
				if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.4) || (!npc.m_flAttackHappenswillhappen && npc.m_fbRangedSpecialOn))
				{
					npc.FaceTowards(vecTarget, 2000.0);
					if(!npc.m_fbRangedSpecialOn)
					{
						npc.StopPathing();
						
						npc.AddGesture("ACT_PUSH_PLAYER");
						npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 0.3;
						npc.m_fbRangedSpecialOn = true;
						npc.m_flReloadDelay = GetGameTime(npc.index) + 0.3;
						npc.m_flNextMeleeAttack += 0.5;
					}
					if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
					{
						npc.m_fbRangedSpecialOn = false;
						npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 3.0;
						npc.PlayRangedAttackSecondarySound();
	
						float vecSpread = 0.1;
						float npc_pos[3];
						GetAbsOrigin(npc.index, npc_pos);
							
						npc_pos[2] += 30.0;
						npc.FaceTowards(vecTarget, 15000.0);
						
						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
								
						//
						//
						
						
						float x, y;
						x = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
						y = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
						
						float vecDirShooting[3], vecRight[3], vecUp[3];
						//GetAngleVectors(eyePitch, vecDirShooting, vecRight, vecUp);
						
						vecTarget[2] += 15.0;
						MakeVectorFromPoints(npc_pos, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						//add the spray
						float vecDir[3];
						vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
						vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
						vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
						NormalizeVector(vecDir, vecDir);
						
						npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
						FireBullet(npc.index, npc.index, npc_pos, vecDir, 125.0, 9999.0, DMG_BULLET, "bullet_tracer02_blue", _);
					}
				}
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0) && !npc.m_fbRangedSpecialOn || (npc.m_flAttackHappenswillhappen && !npc.m_fbRangedSpecialOn))
				{
					npc.StopPathing();
					
					npc.m_fbGunout = false;
					//Look at target so we hit.
					npc.FaceTowards(vecTarget, 1500.0);
					
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.51;
						npc.m_flAttackHappenswillhappen = true;
						npc.m_flNextRangedSpecialAttack += 0.5;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 15000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,2))
							{
								
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DMG_CLUB, -1, _, vecHit);

									// Hit particle
									
									
									// Hit sound
									npc.PlayMeleeHitSound();
									
									//Did we kill them?
									int iHealthPost = GetEntProp(target, Prop_Data, "m_iHealth");
									if(iHealthPost <= 0) 
									{
									//	int client = who_owns_this_bob[npc.index];
										SetGlobalTransTarget(client);
										//PrintHintText(client, "%t %t","Bob The Second:", "I got them!");
										
									}
									else
									{
									//	int client = who_owns_this_bob[npc.index];
										SetGlobalTransTarget(client);
										//PrintHintText(client, "%t %t","Bob The Second:", "Take This!");
										
										
										float vAngles[3], vDirection[3];
									
										GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles); 
									
										if(vAngles[0] > -45.0)
										{
											vAngles[0] = -45.0;
										}
										
										if(target <= MaxClients)
											Client_Shake(target, 0, 75.0, 75.0, 0.5);
										
										GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
										
										ScaleVector(vDirection, 350.0);
															
										TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, vDirection); 
									}
								}
							}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.65;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flNextMeleeAttack < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.65;
					}
				}
			}
		}
	}
	
	else if (!npc.m_b_stand_still && npc.m_b_follow && IsValidClient(client) && IsPlayerAlive(client))
	{
		if (npc.m_flDoingSpecial < GetGameTime(npc.index) && npc.m_iState == 1)
		{
			npc.StopPathing();
			
			npc.m_iState = 0;
			int iActivity = npc.LookupActivity("ACT_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_flFollowing_Master_Now = GetGameTime(npc.index) + 1.0;
			AcceptEntityInput(npc.m_iWearable2, "Disable");
			AcceptEntityInput(npc.m_iWearable1, "Enable");
		}
		else if ((npc.m_iState == 0 || npc.m_iState == 2) && npc.m_flFollowing_Master_Now < GetGameTime(npc.index))
		{
			
			float vecTarget[3]; WorldSpaceCenter(client, vecTarget );
			
			float Vecself[3]; WorldSpaceCenter(npc.index, Vecself);	
			float flDistanceToTarget = GetVectorDistance(vecTarget, Vecself, true);
			
			if (flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				npc.StartPathing();
				
				npc.SetGoalEntity(client);
				if (!npc.m_bmovedelay_run)
				{
					int iActivity_melee = npc.LookupActivity("ACT_RUN");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay_run = true;
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
					npc.m_fbGunout = false;
					npc.m_flSpeed = 260.0;
					npc.m_bmovedelay_walk = false;
					npc.m_bmovedelay = false;
				//	//PrintHintText(client, "Bob The Second: I'm coming towards you, sir!");
				}
				npc.m_iState = 0;
			}
			else if (flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5) && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				npc.StartPathing();
				
				npc.SetGoalEntity(client);
				if (!npc.m_bmovedelay_walk)
				{
					int iActivity_melee = npc.LookupActivity("ACT_WALK");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay_walk = true;
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
					npc.m_fbGunout = false;
					npc.m_flSpeed = 90.0;
					npc.m_bmovedelay_run = false;
					npc.m_bmovedelay = false;
				//	//PrintHintText(client, "Bob The Second: Hello, sir!");
					npc.m_flidle_talk = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
				}
				npc.m_iState = 0;
			}
			else if (npc.m_flReloadDelay > GetGameTime(npc.index))
			{
				npc.m_bmovedelay_walk = false;
				npc.m_bmovedelay = false;
				npc.m_bmovedelay_run = false;
				npc.StopPathing();
				
			}
			
			else if (npc.m_iState != 2)
			{
				npc.m_bmovedelay_walk = false;
				npc.m_bmovedelay = false;
				npc.m_bmovedelay_run = false;
				npc.StopPathing();
				
				npc.m_iState = 2;
				int iActivity_melee = npc.LookupActivity("ACT_IDLE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				if(npc.m_bIsFriendly)
				{
					SetGlobalTransTarget(client);
					//PrintHintText(client, "%t %t","Bob The Second:", "I'll stand beside you, sir!");
										
					
				}
				else if(!npc.m_bIsFriendly)
				{
					SetGlobalTransTarget(client);
					//PrintHintText(client, "%t %t","Bob The Second:", "I'll guard you, sir!");
					
				}
				npc.m_flidle_talk = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
			}
			
			if (flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && npc.m_iAttacksTillReload != 24)
			{
				npc.AddGesture("ACT_RELOAD_PISTOL");
				npc.m_flReloadDelay = GetGameTime(npc.index) + 1.4;
				npc.m_iAttacksTillReload = 24;
				npc.PlayRangedReloadSound();
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				
				npc.m_fbGunout = true;
				npc.m_bReloaded = false;
				SetGlobalTransTarget(client);
				//PrintHintText(client, "%t %t","Bob The Second:", "Reloading near you, sir!");
				
			}
			else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && npc.m_flReloadDelay < GetGameTime(npc.index) && npc.m_iAttacksTillReload == 24)
			{
				if (!npc.m_bReloaded)
				{
					AcceptEntityInput(npc.m_iWearable2, "Disable");
					AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
				npc.m_bReloaded = true;
				
				npc.m_fbGunout = false;
				if (npc.m_flidle_talk < GetGameTime(npc.index)/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") >= 500*/)
				{
					npc.m_flidle_talk = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
					SetGlobalTransTarget(client);
					switch(GetRandomInt(1, 8))
					{
						case 1:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "I'm pretty bored...");
						}
						case 2:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "I hope your day is going well!");
						}
						case 3:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "Sometimes i wonder why this war exists.");
						}
						case 4:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "I'm pretty bored...");
						}
						case 5:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "Just saying, never give up!");
						}
						case 6:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "Could i borrow your gun perhaps?");
						}
						case 7:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "Im pretty confident in my abilities!");
						}
						case 8:
						{
							//PrintHintText(client, "%t %t","Bob The Second:", "Pick up that can.");
						}
					}
						
					Citizen_LiveCitizenReaction(npc.index);			
				}
				/*
				else if (npc.m_flidle_talk < GetGameTime(npc.index) && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
				{
					npc.m_flidle_talk = GetGameTime(npc.index) + GetRandomFloat(10.0, 20.0);
					switch(GetRandomInt(1, 7))
					{
						case 1:
						{
							//PrintHintText(client, "Bob The Second: I don't feel good..");
						}
						case 2:
						{
							//PrintHintText(client, "Bob The Second: I'm hurt...");
						}
						case 3:
						{
							//PrintHintText(client, "Bob The Second: I hate this..");
						}
						case 4:
						{
							//PrintHintText(client, "Bob The Second: I'm pretty exhausted...");
						}
						case 5:
						{
							//PrintHintText(client, "Bob The Second: I'm tired...");
						}
						case 6:
						{
							//PrintHintText(client, "Bob The Second: Can we relax, please?");
						}
						case 7:
						{
							//PrintHintText(client, "Bob The Second: I might be a goner soon..");
						}
					}	
					
				}
				*/
			}
		}
	}
	
	npc.PlayIdleAlertSound();
}


public void roundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			Has_a_bob[client] = 0;
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, BobTheGod_Owner_Hurt);
		}
	}
}

public int BobTheGod_PluginBot_OnActorEmoted(NextBotAction action, CBaseCombatCharacter actor, CBaseCombatCharacter emoter, int emote)
{
//	PrintToServer(">>>>>>>>>> PluginBot_OnActorEmoted %i who %i concept %i", bot_entidx, who, concept);


	//justbocks.
	if(actor.index != 9999999)
		return 9;
	int bot_entidx = actor.index;
	int who = emoter.index;
	int concept = emote;
	
	if (concept == 13)
	{
		//"Go go go!"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		SetGlobalTransTarget(client);
		//PrintHintText(client, "%t %t","Bob The Second:", "On my way, sir!");
		npc.m_flidle_talk += 2.0;
		float StartOrigin[3], Angles[3], vecPos[3];
		GetClientEyeAngles(who, Angles);
		GetClientEyePosition(who, StartOrigin);
		
		Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
		if (TR_DidHit(TraceRay))
			TR_GetEndPosition(vecPos, TraceRay);
			
		delete TraceRay;
		
		
		npc.StartPathing();
		npc.m_fbGunout = false;
		
		npc.SetGoalVector(vecPos);
		
		
		
		npc.FaceTowards(vecPos, 500.0);
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 3.5;
		
		npc.m_iState = 1;
		
		int iActivity_melee = npc.LookupActivity("ACT_RUN");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		npc.m_flSpeed = 260.0;

		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		npc.PlayMovingSound();
				
		CreateParticle("ping_circle", vecPos, NULL_VECTOR);
	}
	else if (concept == 19)
	{
		//"Incomming!"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			npc.AddGesture("ACT_METROPOLICE_POINT");
			
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Im watching there, dont worry!");
			npc.m_flidle_talk += 2.0;
			float StartOrigin[3], Angles[3], vecPos[3];
			GetClientEyeAngles(who, Angles);
			GetClientEyePosition(who, StartOrigin);
			
			Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
			if (TR_DidHit(TraceRay))
				TR_GetEndPosition(vecPos, TraceRay);
				
			delete TraceRay;
			
			npc.FaceTowards(vecPos, 10000.0);
			CreateParticle("ping_circle", vecPos, NULL_VECTOR);
		}
	}
	else if (concept == 20)
	{
		//"spy!"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Spy? I'm keeping my eye there.");
			npc.m_flidle_talk += 2.0;
			float StartOrigin[3], Angles[3], vecPos[3];
			GetClientEyeAngles(who, Angles);
			GetClientEyePosition(who, StartOrigin);
			
			Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
			if (TR_DidHit(TraceRay))
				TR_GetEndPosition(vecPos, TraceRay);
				
			delete TraceRay;
			
			int iActivity_melee = npc.LookupActivity("ACT_IDLE_ANGRY_PISTOL");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			npc.m_fbGunout = true;
			AcceptEntityInput(npc.m_iWearable2, "Enable");
			AcceptEntityInput(npc.m_iWearable1, "Disable");
					
			npc.FaceTowards(vecPos, 10000.0);
			CreateParticle("ping_circle", vecPos, NULL_VECTOR);
		}
	}
	else if (concept == 21)
	{
		//"Sentry Ahead"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Sentry here? Its better to wait for teammates to engage so i'll look.");
			npc.m_flidle_talk += 2.0;
			float StartOrigin[3], Angles[3], vecPos[3];
			GetClientEyeAngles(who, Angles);
			GetClientEyePosition(who, StartOrigin);
			
			Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE), RayType_Infinite, TraceRayProp);
			if (TR_DidHit(TraceRay))
				TR_GetEndPosition(vecPos, TraceRay);
				
			delete TraceRay;
			
			int iActivity_melee = npc.LookupActivity("ACT_IDLE_ANGRY_PISTOL");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			npc.m_fbGunout = true;
			AcceptEntityInput(npc.m_iWearable2, "Enable");
			AcceptEntityInput(npc.m_iWearable1, "Disable");
					
			npc.FaceTowards(vecPos, 10000.0);
			CreateParticle("ping_circle", vecPos, NULL_VECTOR);
		}
	}
	else if (concept == 22)
	{
		//"Build teleporter!"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I cant build a teleporter, sorry.");
			npc.m_flidle_talk += 2.0;
		}
	}
	else if (concept == 23)
	{
		//"Build dispenser"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I cant build a teleporter, sorry.");
			npc.m_flidle_talk += 2.0;
		}
	}
	else if (concept == 24)
	{
		//"build sentry"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I cant build a sentry, sorry.");
			npc.m_flidle_talk += 2.0;
		}
	}
	else if (concept == 25)
	{
		//"Charge me!"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I can't give you ubercharge...");
			npc.m_flidle_talk += 2.0;
		}
	}
	
	else if (concept == 14)
	{
		//"Move Up!"	
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
			
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		if(!npc.m_b_stand_still) //Already moving, geez!
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Standing right here!");
			npc.m_flidle_talk += 2.0;
			npc.m_b_stand_still = true;
			return 0;
		}
		
		else if(npc.m_b_stand_still) //Already moving, geez!
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I'm on my move again!");
			npc.m_flidle_talk += 2.0;
			npc.m_b_stand_still = false;
			return 0;
		}
		
	}
	else if (concept == 12)
	{
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		//"Help me!"
		
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget > 300)
		{
			CreateParticle("ping_circle", pos, NULL_VECTOR);
			
			int iActivity_melee = npc.LookupActivity("ACT_RUN");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			npc.m_bmovedelay_run = false;
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			npc.m_fbGunout = false;
			npc.m_flSpeed = 260.0;
			npc.m_bmovedelay_walk = false;
			npc.m_bmovedelay = false;
					
			npc.SetGoalEntity(client);
			
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I am coming !");
			npc.m_flidle_talk += 2.0;
			
			npc.m_bIsFriendly = false;
			
			npc.m_flComeToMe = GetGameTime(npc.index) + 3.0; 
			
		}
		else
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I'm already here!");
			npc.m_flidle_talk += 2.0;
		}	
		TeleportEntity(npc.index, pos, NULL_VECTOR, NULL_VECTOR); 
		return 0;

	}
	else if (concept == 58)
	{
		//"thanks!"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		if(flDistanceToTarget < 300)
		{
			int iActivity_melee = npc.LookupActivity("ACT_BUSY_THREAT");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I'm glad to help!");
			npc.m_flidle_talk += 2.0;
		}
		
		return 0;

	}
	else if (concept == 17)
	{
		//"yes"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		SetGlobalTransTarget(client);
		//PrintHintText(client, "%t %t","Bob The Second:", "Follow? Sure!");
		npc.m_flidle_talk += 2.0;
		npc.m_b_follow = true;
		
		return 0;

	}
	else if (concept == 15)
	{
		//"left"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "My left or yours?");
			npc.m_flidle_talk += 2.0;
		}
		
		return 0;

	}
	else if (concept == 16)
	{
		//"right"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "My right or yours?");
			npc.m_flidle_talk += 2.0;
		}
		
		return 0;

	}
	else if (concept == 29)
	{
		//"cheers"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_MELEE_ATTACK_THRUST");
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Cheers to you too, like a drink, get it?");
			
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			npc.AddGesture("ACT_PICKUP_GROUND");
			//PrintHintText(client, "Bob The Second: Its more of a jeer, hurt here...");
			
			npc.m_flidle_talk += 2.0;
		}
		*/
		
		return 0;

	}
	else if (concept == 30)
	{
		//"jeers"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Ah come on, lighten your mood!");
			
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			//PrintHintText(client, "Bob The Second: Yeah agreed...");
			
			npc.m_flidle_talk += 2.0;
		}
		*/
		return 0;

	}
	else if (concept == 31)
	{
		//"positive"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Positivity is the way to go!");
			
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			//PrintHintText(client, "Bob The Second: Not the time for it...");
			
			npc.m_flidle_talk += 2.0;
		}
		*/
		return 0;

	}
	else if (concept == 32)
	{
		//"negative"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300/* && GetEntProp(npc.index, Prop_Data, "m_iHealth") > 500*/)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Why negative? Nothing to worry about!");
			
			npc.m_flidle_talk += 2.0;
		}
		/*
		else if (flDistanceToTarget < 300 && GetEntProp(npc.index, Prop_Data, "m_iHealth") < 500)
		{
			//PrintHintText(client, "Bob The Second: Yeah its not looking great, but lets try to feel better...");
			
			npc.m_flidle_talk += 2.0;
		}
		*/
		return 0;

	}
	else if (concept == 18)
	{
		//"no"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
		
		SetGlobalTransTarget(client);
		//PrintHintText(client, "%t %t","Bob The Second:", "Not Follow? Sure!");
		
		npc.m_flidle_talk += 2.0;
		npc.m_b_follow = false;
		
		return 0;

	}
	else if (concept == 28)
	{
		//Battle Cry
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		if(!npc.m_bIsFriendly) //Already moving, geez!
		{
			//npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_DEACTIVATE_BATON");
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I'll hurt no one!");
			
			npc.m_flidle_talk += 2.0;
			npc.m_bIsFriendly = true;
			return 0;
		}
		else if(npc.m_bIsFriendly) //Already moving, geez!
		{
			npc.AddGesture("ACT_ACTIVATE_BATON");
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I'll attack once more!");
			
			npc.m_flidle_talk += 2.0;
			npc.m_bIsFriendly = false;
			return 0;
		}
		return 0;
	}
	else if (concept == 33)
	{
		//"Nice shot"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I try my best to aim well!");
			
			npc.m_flidle_talk += 2.0;
		}
		
		return 0;

	}
	else if (concept == 34)
	{
		//"Good job"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 300)
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "You are doing a good job aswell!");
			
			npc.m_flidle_talk += 2.0;
		}
		
		return 0;

	}
	else if (concept == 5)
	{
		//"medic!"
		BobTheGod npc = view_as<BobTheGod>(bot_entidx);
		
		int client = who_owns_this_bob[npc.index];
			
		if(client != who) //You are not my dad!
			return 0;
			
		float pos[3]; GetEntPropVector(who, Prop_Data, "m_vecAbsOrigin", pos);
		
		float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
		float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
		
		if(flDistanceToTarget < 100 && npc.m_flheal_cooldown < GetGameTime(npc.index))
		{
			npc.m_iMedkitAnnoyance = 0;
			npc.m_flheal_cooldown = GetGameTime(npc.index) + GetRandomFloat(20.0, 30.0);
			npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_PUSH_PLAYER");
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Here, have this medkit!");
			
			npc.m_flidle_talk += 2.0;
			CreateTimer(0.3, BobTheGod_showHud, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else if (npc.m_iMedkitAnnoyance == 0 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime(npc.index))
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Sorry, i dont have a medkit on me...");
			
			npc.m_flidle_talk += 2.0;
		}
		else if (npc.m_iMedkitAnnoyance == 1 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime(npc.index))
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Sorry, i dont have a medkit on me, please wait.");
			
			npc.m_flidle_talk += 2.0;
		}
		else if (npc.m_iMedkitAnnoyance == 2 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime(npc.index))
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I do not have a medkit.");
			
			npc.m_flidle_talk += 2.0;
		}
		else if (npc.m_iMedkitAnnoyance == 3 && flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime(npc.index))
		{
			npc.m_iMedkitAnnoyance += 1;
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I dont have a medkit, have patience.");
			
			npc.m_flidle_talk += 2.0;
		}
		else if (flDistanceToTarget < 100 && npc.m_flheal_cooldown > GetGameTime(npc.index))
		{
			npc.m_iMedkitAnnoyance = 0;
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "I told you i do not have a medikit!!!");
			
			npc.m_flidle_talk += 2.0;
			npc.FaceTowards(pos, 10000.0);
			npc.AddGesture("ACT_PUSH_PLAYER");
			npc.PlayMeleeSound();
			CreateTimer(0.4, BobTheGod_anger_medkit, npc.index, TIMER_FLAG_NO_MAPCHANGE);		
		}
		else
		{
			SetGlobalTransTarget(client);
			//PrintHintText(client, "%t %t","Bob The Second:", "Youre too far away!");
			
			npc.m_flidle_talk += 2.0;
		}
		return 0;
	}
	return 0;
}

public Action BobTheGod_showHud(Handle dashHud, int client)
{
	if (IsValidClient(client))
	{
		EmitSoundToAll("items/smallmedkit1.wav", client, _, 90, _, 1.0);
		HealEntityGlobal(client, client, 25.0, _, 1.0, _);
	}
	return Plugin_Handled;
}

public Action BobTheGod_anger_medkit(Handle dashHud, int entity)
{
	if (IsValidEntity(entity))
	{
		BobTheGod npc = view_as<BobTheGod>(entity);
		
		int client = who_owns_this_bob[npc.index];
		
		if (IsValidClient(client) && IsPlayerAlive(client))
		{
			float pos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
			
			float PosNpc[3]; WorldSpaceCenter(npc.index, PosNpc);
			float flDistanceToTarget = GetVectorDistance(pos, PosNpc);	
			if(flDistanceToTarget < 150)
			{
				SDKHooks_TakeDamage(client, npc.index, client, 35.0, DMG_CLUB);
												
				float vAngles[3], vDirection[3];
											
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles); 
												
				if(vAngles[0] > -45.0)
				{
					vAngles[0] = -45.0;
				}
									
				npc.PlayMeleeHitSound();	
			
				if(client <= MaxClients)
					Client_Shake(client, 0, 75.0, 75.0, 0.5);
												
				GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
													
				ScaleVector(vDirection, 500.0);
																		
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vDirection); 
			}
		}
		else
		{
			npc.PlayMeleeMissSound();		
		}
	}
	return Plugin_Handled;
}

public bool TraceRayProp(int entityhit, int mask, any entity)
{
	if (entityhit > MaxClients && entityhit != entity)
	{
		return true;
	}
	
	return false;
}

public Action Bob_player_killed(Event hEvent, const char[] sEvName, bool bDontBroadcast) //Controls what happens when a player dies. 
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	if (IsValidClient(victim))
	{
		if(Has_a_bob[victim])
		{
			BobTheGod npc = view_as<BobTheGod>(Has_a_bob[victim]);
			
			npc.m_b_stand_still = false;
			npc.m_b_follow = true;
			npc.m_bIsFriendly = false;
		//	NPCDeath(npc.index);
			SetGlobalTransTarget(victim);
			//PrintHintText(victim, "%t %t","Bob The Second:", "This can't be...");
			
		}
	}
	return Plugin_Handled;
}


public Action BobTheGod_Owner_Hurt(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(attacker > MaxClients && !IsValidEnemy(victim, attacker, true))
		return Plugin_Continue;
		
	if (!Has_a_bob[victim])
	{
		SDKUnhook(victim, SDKHook_OnTakeDamageAlive, BobTheGod_Owner_Hurt);
		return Plugin_Continue;
	}
	
	BobTheGod npc = view_as<BobTheGod>(Has_a_bob[victim]);
	
	npc.m_iTarget = attacker;
	
	if(npc.m_flHurtie < GetGameTime(npc.index) && !npc.m_bIsFriendly)
	{
		npc.m_flHurtie = GetGameTime(npc.index) + 0.50;
		SetGlobalTransTarget(victim);
		//PrintHintText(victim, "%t %t","Bob The Second:", "I will protect you!");
	}
	else if(npc.m_flHurtie < GetGameTime(npc.index) && npc.m_bIsFriendly)
	{
		npc.m_flHurtie = GetGameTime(npc.index) + 0.50;
		SetGlobalTransTarget(victim);
		//PrintHintText(victim, "%t %t","Bob The Second:", "You told me to be friendly.");
	}
	return Plugin_Changed;
}


public Action BobTheGod_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (damage < 9999999.0)	//So they can be slayed.
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	else
		return Plugin_Continue;
}

public void BobTheGod_NPCDeath(int entity)
{
	BobTheGod npc = view_as<BobTheGod>(entity);
	int client = who_owns_this_bob[npc.index];
	if(IsValidClient(client))
	{
	//	//PrintHintText(client, "Bob has died :(");
	//	
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, BobTheGod_Owner_Hurt);
	}
	
	SDKUnhook(npc.index, SDKHook_Think, BobTheGod_ClotThink);
	Has_a_bob[client] = 0;
	/*
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	*/
	//He cant die. He just goes away.
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
