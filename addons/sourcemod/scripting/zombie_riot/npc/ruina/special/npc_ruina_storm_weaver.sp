#pragma semicolon 1
#pragma newdecls required

//this thing is *kinda* an npc, but also not really


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

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

#define RUINA_STORM_WEAVER_MODEL "models/props_borealis/bluebarrel001.mdl"

static int i_anchor_ids[MAXENTITIES][RUINA_ANCHOR_HARD_LIMIT+1];
bool b_storm_weaver_solo[MAXENTITIES];
static int i_traveling_to_anchor[MAXENTITIES];
static float fl_heading_angles[MAXENTITIES][2];

static int beam_model;


void Ruina_Storm_Weaver_MapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}

	Zero2(i_anchor_ids);

	PrecacheModel(RUINA_STORM_WEAVER_MODEL);

	beam_model = PrecacheModel(BLITZLIGHT_SPRITE);
}

methodmap Storm_Weaver < CClotBody
{
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
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public Storm_Weaver(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		Storm_Weaver npc = view_as<Storm_Weaver>(CClotBody(vecPos, vecAng, RUINA_STORM_WEAVER_MODEL, "1.0", "1250", ally));
		
		i_NpcInternalId[npc.index] = RUINA_STORM_WEAVER;
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");


		if(!ally)
		{
			b_thisNpcIsABoss[npc.index] = true;
		}
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		Ruina_Set_Heirarchy(npc.index, 2);

		Ruina_Set_No_Retreat(npc.index);

		
		
		SDKHook(npc.index, SDKHook_Think, Storm_Weaver_ClotThink);
		
		npc.m_flGetClosestTargetTime = 0.0;

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;

		Find_Anchors(npc);

		bool solo = StrContains(data, "solo") != -1;

		if(!solo)
		{
			b_storm_weaver_solo[npc.index]=false;
			int base_hp = 1000;
			int Health = Storm_Weaver_Health(npc, base_hp);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", Health);
		}
		else
		{
			b_storm_weaver_solo[npc.index]=true;
		}

		i_traveling_to_anchor[npc.index]=-1;
		//now the fun part, making him ignore all collisions...

		b_NoGravity[npc.index] = true;	//Found ya!

		float npc_vec[3]; npc_vec = GetAbsOrigin(npc.index);
		npc_vec[2] += 50.0;

		TeleportEntity(npc.index, npc_vec, NULL_VECTOR, NULL_VECTOR);

		ParticleEffectAt(npc_vec, "eyeboss_death_vortex", 5.0);

		
		return npc;
	}
	
}
static void Storm_Weaver_Pulse_Solo_Mode(Storm_Weaver npc)
{
	for(int i= 0 ; i <= 8 ; i++)
	{
		if(i_magia_anchors_active < 5)
		{
			Storm_Weaver_Force_Spawn_Anchors(npc);
		}	
	}

	Find_Anchors(npc);

	if(i_magia_anchors_active>=4)
	{
		b_storm_weaver_solo[npc.index]=false;
	}
	
}
static void Storm_Weaver_Force_Spawn_Anchors(Storm_Weaver npc)
{
	float AproxRandomSpaceToWalkTo[3];

	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 50.0;

	AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 800.0),(AproxRandomSpaceToWalkTo[0] + 800.0));
	AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 800.0),(AproxRandomSpaceToWalkTo[1] + 800.0));

	Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
	TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
	delete ToGroundTrace;

	CNavArea area = TheNavMesh.GetNearestNavArea(AproxRandomSpaceToWalkTo, true);
	if(area == NULL_AREA)
		return;

	int NavAttribs = area.GetAttributes();
	if(NavAttribs & NAV_MESH_AVOID)
	{
		return;
	}
			

	area.GetCenter(AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 18.0;
		
	static float hullcheckmaxs_Player_Again[3];
	static float hullcheckmins_Player_Again[3];

	hullcheckmaxs_Player_Again = view_as<float>( { 45.0, 45.0, 82.0 } ); //Fat. very fett indeed
	hullcheckmins_Player_Again = view_as<float>( { -45.0, -45.0, 0.0 } );	

	if(IsSpaceOccupiedIgnorePlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
	{
		return;
	}

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] += 18.0;
	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] += 18.0;
	AproxRandomSpaceToWalkTo[2] += 18.0;
		
	float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, WorldSpaceCenter(npc.index), true);
		
	if(flDistanceToBuild < (250.0 * 250.0))
	{
		return; //The building is too close, we want to retry! it is unfair otherwise.
	}
	//Retry.


	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"))+1.0;
	Health *=0.25;
	int spawn_index = Npc_Create(RUINA_MAGIA_ANCHOR, -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
	if(spawn_index > MaxClients)
	{
		int active_anchor = i_magia_anchors_active+1;
		i_anchor_ids[npc.index][active_anchor] = EntIndexToEntRef(spawn_index);
		if(!b_IsAlliedNpc[npc.index])
		{
			Zombies_Currently_Still_Ongoing += 1;
		}
		fl_ruina_battery[spawn_index]=255.0;	//force spawn them fully
		SetEntityRenderMode(spawn_index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(spawn_index, 255, 255, 255, 255);

		int i_health = RoundToFloor(Health);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", i_health);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", i_health);
	}
}

static int Storm_Weaver_Health(Storm_Weaver npc, int base_hp)
{
	int health = base_hp;	//baseline 1k
	for(int anchor=1 ; anchor <= i_magia_anchors_active ; anchor++ )
	{
		int Anchor_Id = EntRefToEntIndex(i_anchor_ids[npc.index][anchor]);
		if(IsValidEntity(Anchor_Id))
		{
			health+=GetEntProp(Anchor_Id, Prop_Data, "m_iHealth");
		}
	}
	return health;
}

static void Find_Anchors(Storm_Weaver npc)
{
	int anchor_current=1;
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			if(i_NpcInternalId[baseboss_index] == RUINA_MAGIA_ANCHOR)
			{
				i_anchor_ids[npc.index][anchor_current]= EntIndexToEntRef(baseboss_index);
				anchor_current++;
			}
		}
	}
}

public void Storm_Weaver_Share_With_Anchor_Damage(Storm_Weaver npc, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(damagetype & DMG_CLUB)	//if a person is brave enough to melee this thing, reward them handsomely
	{
		damage *=2.5;
	}
	else	//otherwise...
	{
		damage *= 0.75;
	}

	if(i_magia_anchors_active<=0)
	{
		return;
	}

	float ratio = damage / i_magia_anchors_active;
	for(int anchor=1 ; anchor <= i_magia_anchors_active ; anchor++ )
	{
		int Anchor_Id = EntRefToEntIndex(i_anchor_ids[npc.index][anchor]);
		if(IsEntityAlive(Anchor_Id) && !b_NpcIsInvulnerable[Anchor_Id])
		{
			SDKHooks_TakeDamage(Anchor_Id, attacker, inflictor, ratio, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
		}
	}
}

//TODO 
//Rewrite
public void Storm_Weaver_ClotThink(int iNPC)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
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

	if(b_storm_weaver_solo[npc.index])
	{
		Storm_Weaver_Pulse_Solo_Mode(npc);
	}
	else
	{
		if(i_magia_anchors_active<=0)
		{
			npc.m_bDissapearOnDeath = true;	
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
	}
	int PrimaryThreatIndex = npc.m_iTarget;

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		Storm_Weaver_Heading_Control(npc, PrimaryThreatIndex, GameTime);
	}
	else	//random-ish wandering
	{
		if(!b_storm_weaver_solo[npc.index])
		{
			float Npc_Vec[3]; Npc_Vec=GetAbsOrigin(npc.index);
			if(npc.m_flNextMeleeAttack < GameTime)
			{
				
				for(int anchor=1 ; anchor <= i_magia_anchors_active ; anchor++ )
				{
					int Anchor_Id = EntRefToEntIndex(i_anchor_ids[npc.index][anchor]);
					if(IsEntityAlive(Anchor_Id))
					{
						float target_vec[3]; target_vec = GetAbsOrigin(Anchor_Id);
						float Distance=GetVectorDistance(Npc_Vec, target_vec, true);
						if(Distance>(250.0*250.0))
						{
							npc.m_flNextMeleeAttack = GameTime + 5.0;
							i_traveling_to_anchor[npc.index] = EntIndexToEntRef(Anchor_Id);
						}
					}
				}
			}
			else
			{
				int Anchor_Id = EntRefToEntIndex(i_traveling_to_anchor[npc.index]);
				if(IsValidEntity(Anchor_Id))
				{
					float target_vec[3]; target_vec = GetAbsOrigin(Anchor_Id);
					float Distance=GetVectorDistance(Npc_Vec, target_vec, true);
					if(Distance<(250.0*250.0))
					{
						npc.m_flNextMeleeAttack = 0.0;
					}
				}
			}

			int Anchor_Id = EntRefToEntIndex(i_traveling_to_anchor[npc.index]);
			if(IsValidEntity(Anchor_Id))
			{
				Storm_Weaver_Heading_Control(npc, Anchor_Id, GameTime);
			}
		}
		else
		{
			
		}
	}


}
static void Storm_Weaver_Heading_Control(Storm_Weaver npc, int Target, float GameTime)
{
	float Npc_Vec[3]; Npc_Vec=GetAbsOrigin(npc.index);


	if(IsValidEnemy(npc.index, Target))
	{
		int New_Target = Storm_Weaver_Get_Target(npc);
		if(!IsValidEntity(New_Target))
		{
			npc.m_flSpeed = 250.0;
			b_NoGravity[npc.index] = false;
			npc.m_flGetClosestTargetTime = 0.0;
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(Target);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
									
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, Target);
							
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, Target);
			}
			npc.StartPathing();
			npc.m_bPathing = true;

			return;
		}

		if(npc.IsOnGround())
		{
			Npc_Vec[2] += 50.0;
			TeleportEntity(npc.index, Npc_Vec, NULL_VECTOR, NULL_VECTOR); 
		}
		b_NoGravity[npc.index] = true;	//Found ya!

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;

		float target_vec[3]; target_vec = GetAbsOrigin(New_Target);

		Storm_Weaver_Fly(npc, target_vec);

		

	}
	else
	{
		float target_vec[3]; target_vec = GetAbsOrigin(Target);
		Storm_Weaver_Fly(npc, target_vec);
	}


}
static void Storm_Weaver_Fly(Storm_Weaver npc, float target_vec[3])
{
	float npc_vec[3]; npc_vec=GetAbsOrigin(npc.index);
	//float Angles[3];
	//MakeVectorFromPoints(Npc_Vec, Target_Vec, Angles);
	//GetVectorAngles(Angles, Angles);

	//float ratio = GetVectorDistance(Npc_Vec, Target_Vec)/500.0;

	/*Storm_Weaver_Adjust_Heading_Angles(npc, Angles, ratio);

	Angles[1] = fl_heading_angles[npc.index][0];
	Angles[0] = fl_heading_angles[npc.index][1];

	float move_speed = 125.0;

	float vecFwd[3], vecVel[3];

	GetAngleVectors(Angles, vecFwd, NULL_VECTOR, NULL_VECTOR);
		
	Npc_Vec[0]+=vecFwd[0] * move_speed;
	Npc_Vec[1]+=vecFwd[1] * move_speed;
	Npc_Vec[2]+=vecFwd[2] * move_speed;
	
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vecFwd);
	
	SubtractVectors(Npc_Vec, vecFwd, vecVel);
	ScaleVector(vecVel, 1.5);*/

	float newVel[3];
	
	GetEntPropVector(npc.index, Prop_Data, "m_vecVelocity", newVel);

	for(int vec=0 ; vec <=2 ; vec++)
	{
		if(npc_vec[vec]<target_vec[vec])
		{
			if(Storm_Weaver_Check_Heading_Walls(npc, vec, 1))
			{
				newVel[vec] += 75.0;
			}
			else
			{
				newVel[vec] = 0.0;
			}
			
		}
		else
		{
			if(Storm_Weaver_Check_Heading_Walls(npc, vec, -1))
			{
				newVel[vec] -= 75.0;
			}
			else
			{
				newVel[vec] = 0.0;
			}
		}
		
		if(newVel[vec]>250.0 || newVel[vec] < -250.0)	//max speed
		{
			if(newVel[vec]<0)
			{
				newVel[vec] = -250.0;
			}
			else
			{
				newVel[vec] = 250.0;
			}
		}
	}

	npc.SetVelocity(newVel);

}
static bool Storm_Weaver_Check_Heading_Walls(Storm_Weaver npc, int vec, int type)
{
	
	float npc_vec[3]; npc_vec = GetAbsOrigin(npc.index);
	
	float tmp_vec[3]; tmp_vec = npc_vec;
	tmp_vec[vec] += 80.0 * type;
	float angles[3];
	
	MakeVectorFromPoints(npc_vec, tmp_vec, angles);
	GetVectorAngles(angles, angles);
		
	float ground_vec[3];
		
	Handle trace = TR_TraceRayFilterEx(npc_vec, angles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, npc.index);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(ground_vec, trace);
		delete trace;
		
		if(GetVectorDistance(npc_vec, ground_vec, true) <= (80.0*80.0))
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		delete trace;
		return false;
	}
}
static int Storm_Weaver_Get_Target(Storm_Weaver npc)
{
	float npc_vec[3]; npc_vec = GetAbsOrigin(npc.index);
	float last_dist = 3333333.0;
	int closest_yet = -1;
	for(int entity=0 ; entity < MAXENTITIES ; entity++)
	{
		if(IsValidEntity(entity))
		{
			if(IsValidEnemy(npc.index, entity))
			{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(entity);
		
				float flDistanceToTarget = GetVectorDistance(vecTarget, npc_vec, true);

				if(flDistanceToTarget < last_dist)
				{
					int Enemy_I_See;
						
					Enemy_I_See = Can_I_See_Enemy(npc.index, entity);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
					{
						last_dist=flDistanceToTarget;
						closest_yet=Enemy_I_See;
					}
				}
			}
		}
	}
	return closest_yet;
}
public Action Storm_Weaver_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(!b_storm_weaver_solo[npc.index])
	{
		Storm_Weaver_Share_With_Anchor_Damage(npc, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
		damage=0.0;	//storm weaver doesn't really take any damage, his "health bar" is just the combined health of all the towers

		int Health = Storm_Weaver_Health(npc, 1);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
	}
	else
	{
		if(damagetype & DMG_CLUB)	//if a person is brave enough to melee this thing, reward them handsomely
		{
			damage *=2.5;
			fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
		}
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Storm_Weaver_NPCDeath(int entity)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, Storm_Weaver_ClotThink);

}