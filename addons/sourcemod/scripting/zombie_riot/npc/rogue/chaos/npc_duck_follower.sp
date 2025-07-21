#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSounds[][] =
{
	"ambient_mp3/bumper_car_quack1.mp3",
	"ambient_mp3/bumper_car_quack2.mp3",
	"ambient_mp3/bumper_car_quack3.mp3",
	"ambient_mp3/bumper_car_quack4.mp3",
	"ambient_mp3/bumper_car_quack5.mp3",
	"ambient_mp3/bumper_car_quack9.mp3",
	"ambient_mp3/bumper_car_quack11.mp3",
};

static int NPCId;

void DuckFollower_Setup()
{
	PrecacheModel("models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl");

	for (int i = 0; i < (sizeof(g_IdleSounds)); i++) { PrecacheSound(g_IdleSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob's Duck ''Dubby''");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_duck_follower");
	strcopy(data.Icon, sizeof(data.Icon), "goggles");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int DuckFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return DuckFollower(vecPos, vecAng);
}

methodmap DuckFollower < CClotBody
{
	public void PlayIdleSound()
 	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public DuckFollower( float vecPos[3], float vecAng[3])
	{
		DuckFollower npc = view_as<DuckFollower>(CClotBody(vecPos, vecAng, "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl", "1.0", "50000", TFTeam_Red, true, false));
		
		i_NpcWeight[npc.index] = 2100000000;
        //fat
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = false;
		npc.SetPlaybackRate(1.0);
		
		npc.m_flSpeed = 400.0;
		npc.m_flGetClosestTargetTime = 0.0;

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	DuckFollower npc = view_as<DuckFollower>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int ally = npc.m_iTargetWalkTo;
	
	if(i_TargetToWalkTo[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		ally = GetClosestAllyPlayer(npc.index, ally);
		npc.m_iTargetWalkTo = ally;
		npc.m_flGetClosestTargetTime = gameTime + 10.0;
	}

	float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);

	if(ally > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

		if(flDistanceToTarget < 25000.0)
		{
			// Close enough
			npc.StopPathing();
			ApplyStatusEffect(npc.index, ally, "Bobs Duck Dubby", 3.0);
		}
		else
		{
			// Walk to ally target
			npc.SetGoalEntity(ally);
			npc.StartPathing();
		}
	}
	else
	{
		// No ally target
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}
