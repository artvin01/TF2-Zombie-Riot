#pragma semicolon 1
#pragma newdecls required

static const char g_SingingSound[][] = {
	"player/taunt_v01.wav",
	"player/taunt_v02.wav",
	"player/taunt_v03.wav",
	"player/taunt_v04.wav",
	"player/taunt_v05.wav",
	"player/taunt_v06.wav",
	"player/taunt_v07.wav",
};
static const char g_Dancesound[][] = {
	"player/taunt_surgeons_squeezebox_draw_accordion.wav",
};
static const char g_DancesoundMusic[][] = {
	"player/taunt_surgeons_squeezebox_music.wav",
};

void AlliedRitualistAbility_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_SingingSound));	   i++) { PrecacheSound(g_SingingSound[i]);	   }
	for (int i = 0; i < (sizeof(g_Dancesound));	   i++) { PrecacheSound(g_Dancesound[i]);	   }
	for (int i = 0; i < (sizeof(g_DancesoundMusic));	   i++) { PrecacheSound(g_DancesoundMusic[i]);	   }
	PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_allied_ritualist_afterimage");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3],int team, const char[] data)
{
	return AlliedRitualistAbility(client, vecPos, vecAng, team, data);
}
methodmap AlliedRitualistAbility < CClotBody
{
	public void PlaySingingSound() 
	{
		EmitSoundToAll(g_SingingSound[GetRandomInt(0, sizeof(g_SingingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.9, GetRandomInt(85,95));
	}
	public void PlayDanceSound() 
	{
		EmitSoundToAll(g_Dancesound[GetRandomInt(0, sizeof(g_Dancesound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.9, GetRandomInt(90,95));
	}
	public void PlayDanceSoundMusic() 
	{
		EmitSoundToAll(g_DancesoundMusic[GetRandomInt(0, sizeof(g_DancesoundMusic) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.9, GetRandomInt(90,95));
	}
	property int m_iForward
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	
	public AlliedRitualistAbility(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
	{
		AlliedRitualistAbility npc = view_as<AlliedRitualistAbility>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "100", team, true));
		
		i_NpcWeight[npc.index] = 999;
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		f_PreventMovementClient[client] = GetGameTime() + 0.35;
		Store_ApplyAttribs(client); //update.
		
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
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
		}
		TF2_RemoveCondition(client, TFCond_Taunting);


		SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
		AcceptEntityInput(npc.index, "SetBodyGroup");

		bool LongDance = StrContains(data, "longdance") != -1;

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

			if(LongDance && StrContains(ModelPath, "weapon") != -1)
			{
				if(!IsValidEntity(npc.m_iWearable1))
					npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/taunt_surgeons_squeezebox/taunt_surgeons_squeezebox.mdl", _, 2);

				continue;
			}

			for(int Repeat=1; Repeat<7; Repeat++)
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
						SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 255);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		npc.m_bisWalking = false;
	
		if(LongDance)
		{
			npc.m_iState = 1;
			npc.AddActivityViaSequence("layer_taunt_surgeons_squeezebox");
			npc.SetPlaybackRate(1.3);	
			npc.SetCycle(0.01);
			npc.m_flAttackHappens_2 = GetGameTime() + 0.1;
			npc.m_flRangedSpecialDelay = GetGameTime() + 7.8;
			npc.m_flNextRangedBarrage_Singular = GetGameTime() + 10.0;
			//despawn
			npc.m_iForward = 1; //we are right now forward in time
			npc.PlayDanceSound();
		}
		else
		{
			npc.m_iState = 0;
			npc.AddActivityViaSequence("layer_taunt03");
			npc.SetPlaybackRate(1.0);	
			npc.SetCycle(0.05);
			npc.m_flAttackHappens_2 = GetGameTime() + 1.5;
			npc.m_flRangedSpecialDelay = GetGameTime() + 6.0;
			npc.m_flNextRangedBarrage_Singular = GetGameTime() + 7.0;
			//despawn
			npc.m_iForward = 1; //we are right now forward in time
			npc.PlaySingingSound();
			//max of 5 seconds?
		}
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		func_NPCDeath[npc.index] = AlliedRitualistAbility_NPCDeath;
		func_NPCThink[npc.index] = AlliedRitualistAbility_ClotThink;
		func_NPCActorEmoted[npc.index] = RitualistCancelMe;

		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		npc.StopPathing();
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		npc.m_flAttackHappens = 1.0;
		SetEntityCollisionGroup(npc.index, 1); //Dont Touch Anything.
		SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12); 
		SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6); 
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		return npc;
	}
}

public int RitualistCancelMe(NextBotAction action, CBaseCombatCharacter actor, CBaseCombatCharacter emoter, int emote)
{
	int bot_entidx = actor.index;
	int Owner = GetEntPropEnt(bot_entidx, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		return 9;
	}
	int who = emoter.index;
	if(Owner != who)
		return 9;

	int concept = emote;
	if (concept != 5)
		return 9;
	RitualistInternalCancel(bot_entidx);
	return 9;
}
public void RitualistInternalCancel(int iNPC)
{
	AlliedRitualistAbility npc = view_as<AlliedRitualistAbility>(iNPC);
	if(npc.m_iState != 0)
		return;
	if(!npc.m_flRangedSpecialDelay)
		return;
	//cancel!
	npc.m_flRangedSpecialDelay = 1.0;
}
public void AlliedRitualistAbility_ClotThink(int iNPC)
{
	AlliedRitualistAbility npc = view_as<AlliedRitualistAbility>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	int Owner = GetEntPropEnt(iNPC, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	if(!IsPlayerAlive(Owner))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	f_PreventMovementClient[Owner] = GetGameTime() + 0.35;
	float origin_owner[3];
	GetEntPropVector(Owner, Prop_Data, "m_vecAbsOrigin", origin_owner);
	SDKCall_SetLocalOrigin(iNPC, origin_owner);
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	switch(npc.m_iState)
	{
		case 0:
		{
			if(npc.m_flAttackHappens && npc.m_flAttackHappens < GetGameTime())
			{
				npc.m_flAttackHappens = GetGameTime() + 0.5;
				SetDefaultHudPosition(Owner);
				SetGlobalTransTarget(Owner);
				ShowSyncHudText(Owner, SyncHud_Notifaction, "%t", "Call for medic to cancel!");
			}
			if(npc.m_flAttackHappens_2 && npc.m_flAttackHappens_2 < GetGameTime())
			{
				if(npc.m_iForward)
				{
					npc.m_flAttackHappens_2 = GetGameTime() + 1.0;
					npc.SetPlaybackRate(-1.0);	
					npc.SetCycle(0.77);
					npc.m_iForward = 0;
				}
				else
				{
					npc.PlaySingingSound();
					npc.m_flAttackHappens_2 = GetGameTime() + 1.0;
					npc.SetPlaybackRate(1.0);	
					npc.SetCycle(0.303);
					npc.m_iForward = 1;
				}
			}
		}
		case 1:
		{
			if(npc.m_flAttackHappens && npc.m_flAttackHappens < GetGameTime())
			{
				npc.m_flAttackHappens = GetGameTime() + 0.5;
		//		spawnRing_Vectors(origin_owner, 600.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", /*R*/204, /*G*/50, /*B*/50, /*alpha*/50, 1, /*duration*/ 0.5, 10.0, 3.0, 1);
		//		spawnRing_Vectors(origin_owner, 1.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", /*R*/204, /*G*/50, /*B*/50, /*alpha*/50, 1, /*duration*/ 0.5, 10.0, 3.0, 1, 600.0 * 2.0);
				b_NpcIsTeamkiller[Owner] = true;
				b_AllowSelfTarget[Owner] = true;
				Explode_Logic_Custom(0.0, Owner, Owner, -1, origin_owner, 600.0, _, _, false, 99, _, _, RitualistApplyBuff);
				b_NpcIsTeamkiller[Owner] = false;
				b_AllowSelfTarget[Owner] = false;
			}

			if(npc.m_flAttackHappens_2 && npc.m_flAttackHappens_2 < GetGameTime())
			{
				npc.PlayDanceSoundMusic();
				npc.m_flAttackHappens_2 = 0.0;
			}
		}
	}
	if(npc.m_flRangedSpecialDelay)
	{
		if(npc.m_flRangedSpecialDelay < GetGameTime())
		{
			switch(npc.m_iState)
			{
				case 0:
				{
					npc.m_flRangedSpecialDelay = 0.0;
					npc.m_flAttackHappens_2 = 0.0;
					npc.SetPlaybackRate(1.0);	
					npc.SetCycle(0.77);
					npc.m_flNextRangedBarrage_Singular = GetGameTime() + 0.75;
				}
				case 1:
				{
					npc.AddActivityViaSequence("layer_taunt_surgeons_squeezebox_outro");
					npc.m_flRangedSpecialDelay = 0.0;
					npc.m_flAttackHappens_2 = 0.0;
					npc.SetPlaybackRate(1.0);	
					npc.m_flNextRangedBarrage_Singular = GetGameTime() + 0.9;
					StopSound(npc.index, SNDCHAN_AUTO, "player/taunt_surgeons_squeezebox_music.wav");
				}
			}
		}
	}
	if(npc.m_flNextRangedBarrage_Singular)
	{
		if(npc.m_flNextRangedBarrage_Singular < GetGameTime())
		{
			npc.m_flNextRangedBarrage_Singular = 0.0;
			LeperReturnToNormal(Owner, -1, 0);
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			f_PreventMovementClient[Owner] = 0.0;
			Store_ApplyAttribs(Owner); //update.
		}
	}
}

public void AlliedRitualistAbility_NPCDeath(int entity)
{
	AlliedRitualistAbility npc = view_as<AlliedRitualistAbility>(entity);

	StopSound(npc.index, SNDCHAN_AUTO, "player/taunt_surgeons_squeezebox_music.wav");
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
