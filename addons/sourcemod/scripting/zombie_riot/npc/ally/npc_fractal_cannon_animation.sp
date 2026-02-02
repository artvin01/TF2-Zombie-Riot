#pragma semicolon 1
#pragma newdecls required



static const char g_LaserStart[][] = {
	"npc/combine_gunship/attack_start2.wav"
};





void Kit_Fractal_NPC_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fractal Cannon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_fractal_cannon_animation");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
	Zero(fl_RuinaLaserSoundTimer);
	PrecacheSoundArray(g_LaserStart);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Fracatal_Kit_Animation(client, vecPos, vecAng);
}
methodmap Fracatal_Kit_Animation < CClotBody
{
	public void PlayLaserLoopSound() {
		if(fl_RuinaLaserSoundTimer[this.index] > GetGameTime())
			return;
		
		EmitCustomToAll(g_RuinaLaserLoop[GetRandomInt(0, sizeof(g_RuinaLaserLoop) - 1)], this.index, SNDCHAN_STATIC, 75, _, 0.85);
		fl_RuinaLaserSoundTimer[this.index] = GetGameTime() + 2.25;
	}
	public void PlayLaserStart() {

		EmitSoundToAll(g_LaserStart[GetRandomInt(0, sizeof(g_LaserStart) - 1)], this.index, SNDCHAN_STATIC, 75, _, 0.85, 110);
		
	}
	
	property int m_iWingSlot
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_wingslot[this.index]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_wingslot[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_wingslot[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iHaloSlot
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_haloslot[this.index]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_haloslot[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_haloslot[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}

	
	public Fracatal_Kit_Animation(int client, float vecPos[3], float vecAng[3])
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
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		if(IsValidEntity(Cosmetic_WearableExtra[client]))
		{
			int SettingDo;
			if(MagiaWingsDo(client))	//do we even have the wings item?
				SettingDo = MagiaWingsType(client);	//we do, what type of wings do we want?
			if(SilvesterWingsDo(client))
				SettingDo = WINGS_FUSION;

			if(SettingDo != 0)
			{
				npc.m_iWingSlot = npc.EquipItem("head", WINGS_MODELS_1);
				SetVariantInt(SettingDo);
				AcceptEntityInput(npc.m_iWingSlot, "SetBodyGroup");
			}
		}
		npc.PlayLaserStart();
		if(MagiaWingsDo(client))
		{
			float flPos[3], flAng[3];
			npc.GetAttachment("head", flPos, flAng);	
			npc.m_iHaloSlot = ParticleEffectAt_Parent(flPos, "unusual_invasion_boogaloop_2", npc.index, "head", {0.0,0.0,0.0});
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

		npc.StopPathing();
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		SetEntityCollisionGroup(npc.index, 1); //Dont Touch Anything.
		SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12); 
		SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6); 
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

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

	if(npc.m_iState == 1)
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
	}
}

static void NPC_Death(int entity)
{
	Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(entity);

	StopCustomSound(npc.index, SNDCHAN_STATIC, g_RuinaLaserLoop[GetRandomInt(0, sizeof(g_RuinaLaserLoop) - 1)]);
	
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

	if(IsValidEntity(npc.m_iWingSlot))
		RemoveEntity(npc.m_iWingSlot);

	if(IsValidEntity(npc.m_iHaloSlot))
		RemoveEntity(npc.m_iHaloSlot);
}