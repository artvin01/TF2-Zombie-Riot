#pragma semicolon 1
#pragma newdecls required


static const char g_LaserLoop[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3"
};

static float fl_nightmare_cannon_core_sound_timer[MAXENTITIES];

void Kit_Fractal_NPC_MapStart()
{
	PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fractal Cannon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_fractal_cannon_animation");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
	Zero(fl_nightmare_cannon_core_sound_timer);
}
static float fl_magia_angle[MAXENTITIES];
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Fracatal_Kit_Animation(client, vecPos, vecAng, ally);
}
methodmap Fracatal_Kit_Animation < CClotBody
{
	public void PlayLaserLoopSound() {
		if(fl_nightmare_cannon_core_sound_timer[this.index] > GetGameTime())
			return;
		EmitCustomToAll(g_LaserLoop[GetRandomInt(0, sizeof(g_LaserLoop) - 1)], _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		fl_nightmare_cannon_core_sound_timer[this.index] = GetGameTime() + 2.25;
	}

	
	public Fracatal_Kit_Animation(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "100", TFTeam_Red, true));
		
		i_NpcWeight[npc.index] = 999;
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		
		int ModelIndex;
		char ModelPath[255];
		int entity, i;
			
		if((i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		}
		else
		{
			//SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			//SetEntityRenderColor(npc.index, 255, 255, 255, 125);
		}


		SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
		AcceptEntityInput(npc.index, "SetBodyGroup");

		while(TF2U_GetWearable(client, entity, i, "tf_wearable"))
		{

			if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
				continue;
				
			if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) != entity || (i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
			{
				ModelIndex = GetEntProp(entity, Prop_Data, "m_nModelIndex");
				if(ModelIndex < 0)
				{
					GetEntPropString(entity, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
				}
				else
				{
					ModelIndexToString(ModelIndex, ModelPath, sizeof(ModelPath));
				}
			}
			if(!ModelPath[0])
				continue;

			for(int Repeat=0; Repeat<7; Repeat++)
			{
				int WearableIndex = i_Wearable[npc.index][Repeat];
				if(!IsValidEntity(WearableIndex))
				{	
					int WearablePostIndex = npc.EquipItem("head", ModelPath);
					if(IsValidEntity(WearablePostIndex))
					{	
						if(entity == EntRefToEntIndex(i_Viewmodel_PlayerModel[client]))
						{
							SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
							AcceptEntityInput(WearablePostIndex, "SetBodyGroup");
						}
						//SetEntityRenderMode(WearablePostIndex, RENDER_TRANSCOLOR); //Make it half invis.
						//SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 125);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		npc.m_bisWalking = false;
	
		npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
		npc.SetPlaybackRate(1.0);	
		npc.SetCycle(0.01);
		npc.m_flNextRangedBarrage_Spam = GetGameTime() + 0.7;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		func_NPCDeath[npc.index] = NPC_Death;
		func_NPCThink[npc.index] = Cloth_Think;

		//f_NpcTurnPenalty[npc.index] = 0.0;
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		NPC_StopPathing(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		SetEntityCollisionGroup(npc.index, 1); //Dont Touch Anything.
		SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12); 
		SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6); 
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		fl_magia_angle[npc.index] = GetRandomFloat(0.0, 360.0);

		return npc;
	}
}
//the npc' itself doesn't turn, instead the main plugin turns it.
static void Cloth_Think(int iNPC)
{
	Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Spam !=FAR_FUTURE)
	{
		npc.m_flNextRangedBarrage_Spam = FAR_FUTURE;
		npc.SetPlaybackRate(0.0);
	}

	if(npc.m_flNextRangedBarrage_Spam != FAR_FUTURE)
		return;

	//stupidly temp stuff

	float Radius = 30.0;
	float diameter = Radius*2.0;
	Ruina_Laser_Logic Laser;
	int owner = GetEntPropEnt(npc.index, Prop_Data, "m_hOwnerEntity");
	Laser.client = owner;
	float 	flPos[3], // original
			flAng[3]; // original
	float Angles[3];

	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);

	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;

	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	if(flPitch>15.0)	//limit the pitch. by a lot
		flPitch=15.0;
	if(flPitch <-15.0)
		flPitch = -15.0;
	Angles[0] = flPitch;
	GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
	//flPos[2]+=37.0;
	Get_Fake_Forward_Vec(15.0, Angles, flPos, flPos);

	float tmp[3];
	float actualBeamOffset[3];
	float BEAM_BeamOffset[3];
	BEAM_BeamOffset[0] = 0.0;
	BEAM_BeamOffset[1] = -0.0;//5
	BEAM_BeamOffset[2] = 0.0;

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(BEAM_BeamOffset, Angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	flPos[0] += actualBeamOffset[0];
	flPos[1] += actualBeamOffset[1];
	flPos[2] += actualBeamOffset[2];

	Laser.DoForwardTrace_Custom(Angles, flPos, -1.0);
	Laser.Damage = 10.0;
	Laser.Radius = Radius;
	Laser.Bonus_Damage = 10.0;
	Laser.damagetype = DMG_PLASMA;
	Laser.Deal_Damage();

	
	float TE_Duration = 0.2;
	float EndLoc[3]; EndLoc = Laser.End_Point;

	int color[4];
	color[0] = 0;
	color[1] = 250;
	color[2] = 237;	
	color[3] = 255;

	float Offset_Loc[3];
	Get_Fake_Forward_Vec(100.0, Angles, Offset_Loc, flPos);

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);

	float 	Rng_Start = GetRandomFloat(diameter*0.5, diameter*0.7);

	float 	Start_Diameter1 = ClampBeamWidth(Rng_Start*0.7),
			Start_Diameter2 = ClampBeamWidth(Rng_Start*0.9),
			Start_Diameter3 = ClampBeamWidth(Rng_Start);
		
	float 	End_Diameter1 = ClampBeamWidth(diameter*0.7),
			End_Diameter2 = ClampBeamWidth(diameter*0.9),
			End_Diameter3 = ClampBeamWidth(diameter);

	int Beam_Index = g_Ruina_BEAM_Combine_Blue;

	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter1, 0, 10.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter2, 0, 10.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index,	0, 0, 66, TE_Duration, 0.0, Start_Diameter3, 0, 10.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter1*0.9, End_Diameter1, 0, 0.1, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter2*0.9, End_Diameter2, 0, 0.1, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, End_Diameter3, 0, 0.1, colorLayer4, 3);
	TE_SendToAll(0.0);

	if(fl_magia_angle[npc.index]>360.0)
		fl_magia_angle[npc.index] -=360.0;
	
	fl_magia_angle[npc.index]+=7.5/TickrateModify;

	Twirl_Magia_Rings(npc, Offset_Loc, Angles, 3, true, 50.0, 1.0, TE_Duration, color, EndLoc);

	npc.PlayLaserLoopSound();

	if(npc.m_iState == 1)
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
	}
}
static void Twirl_Magia_Rings(Fracatal_Kit_Animation npc, float Origin[3], float Angles[3], int loop_for, bool Type=true, float distance_stuff, float ang_multi, float TE_Duration, int color[4], float drill_loc[3])
{
	float buffer_vec[3][3];
		
	for(int i=0 ; i<loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3];
		tempAngles[0] = Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = (fl_magia_angle[npc.index]+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
		/*
			Using this method we can actuall keep proper pitch/yaw angles on the turning, unlike say fantasy blade or mlynar newspaper's special swing thingy.
		*/
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, distance_stuff);
		AddVectors(Origin, Direction, endLoc);
		
		buffer_vec[i] = endLoc;
		
		if(Type)
		{
			int r=175, g=175, b=175, a=175;
			float diameter = 15.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
										
			TE_SetupBeamPoints(endLoc, drill_loc, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			TE_SendToAll();
		}
		
	}
	
	TE_SetupBeamPoints(buffer_vec[0], buffer_vec[loop_for-1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
	TE_SendToAll(0.0);
	for(int i=0 ; i<(loop_for-1) ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}
	
}

static void NPC_Death(int entity)
{
	Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(entity);

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
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}