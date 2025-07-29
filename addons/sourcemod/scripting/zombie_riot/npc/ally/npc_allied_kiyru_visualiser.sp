#pragma semicolon 1
#pragma newdecls required


static char g_InitiateSound[][] = {
	"npc/scanner/combat_scan5.wav",
};
static char g_InitiateSound2[][] = {
	"items/pumpkin_drop.wav",
};

static char g_HitSound1[][] = {
	"ambient/rottenburg/portcullis_slam.wav",
};
static char g_HitSound2[][] = {
	"player/taunt_knuckle_crack.wav",
};
void AlliedKiryuVisualiserAbility_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_InitiateSound));   i++) { PrecacheSound(g_InitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_InitiateSound2));   i++) { PrecacheSound(g_InitiateSound2[i]);   }
	for (int i = 0; i < (sizeof(g_HitSound1));   i++) { PrecacheSound(g_HitSound1[i]);   }
	for (int i = 0; i < (sizeof(g_HitSound2));   i++) { PrecacheSound(g_HitSound2[i]);   }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Allied Kiryu Afterimage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_allied_kiryu_visualiser");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

		
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return AlliedKiryuVisualiserAbility(client, vecPos, vecAng, ally, data);
}
methodmap AlliedKiryuVisualiserAbility < CClotBody
{
	public void PlayInitSound() 
	{
		EmitSoundToAll(g_InitiateSound[GetRandomInt(0, sizeof(g_InitiateSound) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 80);
		EmitSoundToAll(g_InitiateSound[GetRandomInt(0, sizeof(g_InitiateSound) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 80);
		EmitSoundToAll(g_InitiateSound[GetRandomInt(0, sizeof(g_InitiateSound) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 80);
		EmitSoundToAll(g_InitiateSound[GetRandomInt(0, sizeof(g_InitiateSound) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 80);
		EmitSoundToAll(g_InitiateSound2[GetRandomInt(0, sizeof(g_InitiateSound2) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 60);
		EmitSoundToAll(g_InitiateSound2[GetRandomInt(0, sizeof(g_InitiateSound2) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 60);
	}
	public void PlayHitSound() 
	{
		EmitSoundToAll(g_HitSound1[GetRandomInt(0, sizeof(g_HitSound1) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 110);
		EmitSoundToAll(g_HitSound1[GetRandomInt(0, sizeof(g_HitSound1) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 110);
	}
	public void PlayHitSound2() 
	{
		EmitSoundToAll(g_HitSound2[GetRandomInt(0, sizeof(g_HitSound2) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 90);
		EmitSoundToAll(g_HitSound2[GetRandomInt(0, sizeof(g_HitSound2) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 90);
	}
	//Incode defines which animation or action is used
	property int m_iKiryuActionWhich
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}

	property float m_flKiryuTimeUntillDone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float f_OffsetVertical
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property bool b_NoLongerResetVel
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	property float f_SpeedAcelerateAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float f_DamageDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}

	property int m_iWearablePlayerModel
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_MedkitAnnoyance[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_MedkitAnnoyance[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_MedkitAnnoyance[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iAttachmentWhichDo
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	//ally in this case is used to see which enemy should be attached to the kill animation!
	public AlliedKiryuVisualiserAbility(int client, float vecPos[3], float vecAng[3], int enemyattach, const char[] data)
	{
		//The model seen here entirely depends on what action we want to do.
		char ModelUse[256];
		int WhichStateUse = -1;
		//What type
		if(!StrContains(data, "brawler_heat_1"))
		{
			//This is action 1 as an example.
			/*
				heavy model:
				taunt_cheers_heavy frame 5 out of 195fex
				lasts untill frame 37
				->
				taunt_yetipunch frame 87 out of 156
				lasts untill frame 133
			*/
			WhichStateUse = 1;
			ModelUse = "models/player/heavy.mdl";
		}
		if(!StrContains(data, "brawler_heat_2"))
		{
			//This is action 1 as an example.
			/*
				heavy model:
				taunt_headbutt_success
			*/
			WhichStateUse = 2;
			ModelUse = "models/player/soldier.mdl";
		}
		if(!StrContains(data, "brawler_heat_3"))
		{
			//This is action 1 as an example.
			/*
				heavy model:
				taunt_headbutt_success
			*/
			WhichStateUse = 3;
			ModelUse = "models/player/soldier.mdl";
		}
		if(!StrContains(data, "brawler_heat_4"))
		{
			//This is action 1 as an example.
			/*
				heavy model:
				taunt_headbutt_success
			*/
			WhichStateUse = 4;
			ModelUse = "models/player/medic.mdl";
		}
		if(!StrContains(data, "beast_heat_building_1"))
		{
			//This is action 1 as an example.
			/*
				heavy model:
				taunt_headbutt_success
			*/
			WhichStateUse = 5;
			ModelUse = "models/player/engineer.mdl";
		}

		if(!ModelUse[0])
		{
			PrintToChatAll("failed AlliedKiryuVisualiserAbility Gen, Data:[%s]",data);
		}

		AlliedKiryuVisualiserAbility npc = view_as<AlliedKiryuVisualiserAbility>(CClotBody(vecPos, vecAng, ModelUse, "1.0", "100", TFTeam_Red, true));
		npc.m_iKiryuActionWhich = -1;
		
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
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
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

			for(int Repeat=0; Repeat<6; Repeat++)
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
							npc.m_iWearablePlayerModel = WearablePostIndex;
						}
						SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 255);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		npc.m_bisWalking = false;

		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		
		func_NPCDeath[npc.index] = AlliedKiryuVisualiserAbility_NPCDeath;
		func_NPCThink[npc.index] = AlliedKiryuVisaluser_ClotThink;

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		npc.m_iTarget = enemyattach;

		npc.StopPathing();
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		npc.m_iKiryuActionWhich = WhichStateUse;
		npc.b_NoLongerResetVel = false;
		npc.f_SpeedAcelerateAnim = Yakuza_DurationDoEnemy(enemyattach);
		switch(npc.m_iKiryuActionWhich)
		{
			case 1:
			{
				npc.AddActivityViaSequence("taunt_cheers_heavy");
				npc.SetCycle(0.025);
				npc.SetPlaybackRate(1.0 * (1.0 / npc.f_SpeedAcelerateAnim));
				npc.m_flKiryuTimeUntillDone = GetGameTime() + (2.0 * npc.f_SpeedAcelerateAnim);
				npc.f_OffsetVertical = -50.0;
				npc.m_iAttachmentWhichDo = 1;
				if(!VIPBuilding_Active())
				{
					FreezeNpcInTime(npc.m_iTarget, (1.55 * npc.f_SpeedAcelerateAnim), true);
					if(!HasSpecificBuff(npc.m_iTarget, "Solid Stance"))
						SetAirtimeNpc(npc.m_iTarget, (1.55 * npc.f_SpeedAcelerateAnim));
				}
			}
			case 2:
			{
				npc.AddActivityViaSequence("taunt_headbutt_success");
				// frame 20 out of 135
				npc.SetCycle(0.02);
				npc.SetPlaybackRate(1.0 * (1.0 / npc.f_SpeedAcelerateAnim));
				npc.m_flKiryuTimeUntillDone = GetGameTime() + (2.1 * npc.f_SpeedAcelerateAnim);
				npc.f_OffsetVertical = -50.0;
				npc.m_iAttachmentWhichDo = 1;
				if(!VIPBuilding_Active())
				{
					FreezeNpcInTime(npc.m_iTarget, (1.9 * npc.f_SpeedAcelerateAnim), true);
					if(!HasSpecificBuff(npc.m_iTarget, "Solid Stance"))
						SetAirtimeNpc(npc.m_iTarget, (1.9 * npc.f_SpeedAcelerateAnim));
				}
			}
			case 3:
			{
				npc.f_SpeedAcelerateAnim *= 0.75;
				npc.AddActivityViaSequence("taunt_unleashed_rage_soldier");
				npc.SetCycle(0.014);
				npc.SetPlaybackRate(1.0 * (1.0 / npc.f_SpeedAcelerateAnim));
				npc.m_flKiryuTimeUntillDone = GetGameTime() + (2.5 * npc.f_SpeedAcelerateAnim);
				npc.f_OffsetVertical = 0.0;
				npc.m_iAttachmentWhichDo = 1;
				if(!VIPBuilding_Active())
				{
					FreezeNpcInTime(npc.m_iTarget, (2.5 * npc.f_SpeedAcelerateAnim), true);
					if(!HasSpecificBuff(npc.m_iTarget, "Solid Stance"))
						SetAirtimeNpc(npc.m_iTarget, (2.5 * npc.f_SpeedAcelerateAnim));
				}
			}
			case 4:
			{
				npc.f_SpeedAcelerateAnim = 1.0;
				npc.AddActivityViaSequence("taunt_vehicle_allclass_end");
				npc.SetCycle(0.1);
				npc.SetPlaybackRate(0.01);
				npc.m_flKiryuTimeUntillDone = GetGameTime() + 0.75;
				npc.f_OffsetVertical = 0.0;
				npc.m_iAttachmentWhichDo = -1;
			}
			case 5:
			{
				npc.AddActivityViaSequence("taunt07");
				npc.SetCycle(0.82);
				npc.SetPlaybackRate(0.5 * (1.0 / npc.f_SpeedAcelerateAnim));
				npc.m_flKiryuTimeUntillDone = GetGameTime() + (1.35 * npc.f_SpeedAcelerateAnim);
				npc.f_OffsetVertical = 0.0;
				npc.m_iAttachmentWhichDo = 0;
				if(!VIPBuilding_Active())
				{
					FreezeNpcInTime(npc.m_iTarget, (1.35 * npc.f_SpeedAcelerateAnim), true);
					if(!HasSpecificBuff(npc.m_iTarget, "Solid Stance"))
						SetAirtimeNpc(npc.m_iTarget, (1.35 * npc.f_SpeedAcelerateAnim));
				}
			}
		}
		npc.PlayInitSound();

		return npc;
	}
}

public void AlliedKiryuVisaluser_ClotThink(int iNPC)
{
	AlliedKiryuVisualiserAbility npc = view_as<AlliedKiryuVisualiserAbility>(iNPC);

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	int owner = GetEntPropEnt(npc.index, Prop_Data, "m_hOwnerEntity");
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flKiryuTimeUntillDone)
	{
		if(npc.m_flKiryuTimeUntillDone < GetGameTime())
		{
			int ExtraDo = 0;
			if(npc.m_iKiryuActionWhich == 3)	
				ExtraDo = 1;
			LeperReturnToNormal(owner, npc.m_iWearable9, ExtraDo);
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
	}
	if(IsValidEntity(npc.m_iWearable9))
	{
		if(IsValidEntity(npc.m_iTarget))
		{
			float flPosSelf[3]; // original
			float flPosEnemy[3]; // original
			float ResultStuff[3]; // original
			float flAngles[3]; // original
			
			WorldSpaceCenter(npc.m_iWearable9, flPosSelf);
			WorldSpaceCenter(npc.m_iTarget, flPosEnemy);
			MakeVectorFromPoints(flPosSelf, flPosEnemy, ResultStuff); 
			GetVectorAngles(ResultStuff, flAngles); 
			TeleportEntity(npc.m_iWearable9, NULL_VECTOR, flAngles, NULL_VECTOR);
		}
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget) && !VIPBuilding_Active() && !HasSpecificBuff(npc.m_iTarget, "Solid Stance"))
	{	
		bool AllowStandStill = true;
		if(npc.m_iKiryuActionWhich == 4)
			if(b_thisNpcIsARaid[npc.m_iTarget])
				AllowStandStill = false;
		
		if(AllowStandStill)
		{
			if(f_NoUnstuckVariousReasons[npc.m_iTarget] < GetGameTime() + 0.5)
				f_NoUnstuckVariousReasons[npc.m_iTarget] = GetGameTime() + 0.5;

			if(f_TankGrabbedStandStill[npc.m_iTarget] < GetGameTime() + 0.1)
				f_TankGrabbedStandStill[npc.m_iTarget] = GetGameTime() + 0.1;
		}

		AlliedKiryuVisualiserAbility npc3 = view_as<AlliedKiryuVisualiserAbility>(npc.m_iTarget);
		
				
		if(npc.m_iAttachmentWhichDo != -1)
		{
			float flPos[3]; // original
			float flAng[3]; // original
			if(npc.m_iAttachmentWhichDo == 0)
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);	
				float direction[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", direction);
				float VecForward[3];
				float vecRight[3];
				float vecUp[3];
				float vecSwingEnd[3];
						
				GetAngleVectors(direction, VecForward, vecRight, vecUp);
				
				vecSwingEnd[0] = flPos[0] + VecForward[0] * (60.0);
				vecSwingEnd[1] = flPos[1] + VecForward[1] * (60.0);
				vecSwingEnd[2] = flPos[2];/*+ VecForward[2] * (100);*/
				flPos = vecSwingEnd;
			}
			else
			{
				switch(npc.m_iAttachmentWhichDo)
				{
					case 1:
					{
						npc.GetAttachment("effect_hand_r", flPos, flAng);
					}
					case 2:
					{
						npc.GetAttachment("effect_hand_l", flPos, flAng);
					}
				}
			}

			flPos[2] += npc.f_OffsetVertical;
			SDKCall_SetLocalOrigin(npc.m_iTarget, flPos);
		//	TeleportEntity(npc.m_iTarget, flPos, NULL_VECTOR, NULL_VECTOR);
			if(!npc.b_NoLongerResetVel)
			{
				npc3.SetVelocity({0.0,0.0,0.0});
			}
		}
		else
		{
			if(!npc.b_NoLongerResetVel)
			{
				npc3.SetVelocity({0.0,0.0,0.0});
			}
		}
	}
	switch(npc.m_iKiryuActionWhich)
	{
		case 1:
		{
			BrawlerHeat1(owner, npc, GameTime);
		}
		case 2:
		{
			BrawlerHeat2(owner, npc, GameTime);
		}
		case 3:
		{
			BrawlerHeat3(owner, npc, GameTime);
		}
		case 4:
		{
			BrawlerHeat4(owner, npc, GameTime);
		}
		case 5:
		{
			BeastBuildingHeat1(owner, npc, GameTime);
		}
	}
}

void BrawlerHeat1(int owner, AlliedKiryuVisualiserAbility npc, float GameTime)
{
	if(npc.m_flKiryuTimeUntillDone)
	{
		float TimeLeft = npc.m_flKiryuTimeUntillDone - GameTime;
		if(TimeLeft < (1.25 * npc.f_SpeedAcelerateAnim))
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				npc.m_iChanged_WalkCycle = 3;
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
				
					SensalCauseKnockback(npc.index, npc.m_iTarget,_,_);
					npc.PlayHitSound();
					npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
					CauseKiyruDamageLogic(owner, npc.m_iTarget, npc.f_DamageDo);
					npc.b_NoLongerResetVel = true;
				}
			}
		}
		else if(TimeLeft < (1.75 * npc.f_SpeedAcelerateAnim))
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_iChanged_WalkCycle = 2;
				npc.AddActivityViaSequence("taunt_yetipunch");
				npc.SetCycle(0.60);
				npc.SetPlaybackRate(1.0 * (1.0 / npc.f_SpeedAcelerateAnim));
				npc.m_iAttachmentWhichDo = -1;
			}
		}
	}
}

void BrawlerHeat2(int owner, AlliedKiryuVisualiserAbility npc, float GameTime)
{
	if(npc.m_flKiryuTimeUntillDone)
	{
		float TimeLeft = npc.m_flKiryuTimeUntillDone - GameTime;
		if(TimeLeft < (0.45 * npc.f_SpeedAcelerateAnim))
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				npc.m_iChanged_WalkCycle = 3;
				float EnemyVecPos[3]; 
				if(IsValidEnemy(npc.index, npc.m_iTarget))
					WorldSpaceCenter(npc.m_iTarget, EnemyVecPos);
				else
					WorldSpaceCenter(npc.index, EnemyVecPos);

				npc.PlayHitSound();
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
			//	CauseKiyruDamageLogic(owner, npc.m_iTarget, npc.f_DamageDo);
				i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
				i_ExplosiveProjectileHexArray[npc.index] |= EP_GIBS_REGARDLESS;
				Explode_Logic_Custom(npc.f_DamageDo, owner, npc.index, -1, EnemyVecPos, 300.0, .maxtargetshit = 6, .FunctionToCallOnHit = DealAoeKnockbackBeastMode);
				i_ExplosiveProjectileHexArray[npc.index] == 0;
				npc.m_iAttachmentWhichDo = -1;
				npc.b_NoLongerResetVel = true;
			}
		}
	}
}


void BrawlerHeat3(int owner, AlliedKiryuVisualiserAbility npc, float GameTime)
{
	if(npc.m_flKiryuTimeUntillDone)
	{
		float TimeLeft = npc.m_flKiryuTimeUntillDone - GameTime;
		if(TimeLeft < (0.45 * npc.f_SpeedAcelerateAnim))
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				npc.m_iChanged_WalkCycle = 3;
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
				//	SensalCauseKnockback(npc.index, npc.m_iTarget);
					npc.PlayHitSound2();
					npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
					CauseKiyruDamageLogic(owner, npc.m_iTarget, npc.f_DamageDo);
					npc.m_iAttachmentWhichDo = -1;
					npc.b_NoLongerResetVel = true;
				}
			}
		}
		else if(TimeLeft < (1.5 * npc.f_SpeedAcelerateAnim))
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_iChanged_WalkCycle = 2;
				npc.AddActivityViaSequence("taunt_neck_snap_soldier_initiate");
				// frame 27 out of 192
				npc.SetCycle(0.25);
				npc.SetPlaybackRate(1.0 * (1.0 / npc.f_SpeedAcelerateAnim));
				npc.m_iAttachmentWhichDo = 2;
				npc.f_OffsetVertical = -75.0;
			}
		}
	}
}


void BrawlerHeat4(int owner, AlliedKiryuVisualiserAbility npc, float GameTime)
{
	if(npc.m_flKiryuTimeUntillDone)
	{
		float TimeLeft = npc.m_flKiryuTimeUntillDone - GameTime;
		if(TimeLeft < (0.65 * npc.f_SpeedAcelerateAnim))
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				npc.m_iChanged_WalkCycle = 3;
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					if(!b_thisNpcIsARaid[npc.m_iTarget])
						SensalCauseKnockback(npc.index, npc.m_iTarget,_,false);

					npc.PlayHitSound();
					npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
					CauseKiyruDamageLogic(owner, npc.m_iTarget, npc.f_DamageDo);
					npc.m_iAttachmentWhichDo = -1;
					npc.b_NoLongerResetVel = true;
				}
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_iChanged_WalkCycle = 2;
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.2);
			}
		}
	}
}
void BeastBuildingHeat1(int owner, AlliedKiryuVisualiserAbility npc, float GameTime)
{
	if(npc.m_flKiryuTimeUntillDone)
	{
		float TimeLeft = npc.m_flKiryuTimeUntillDone - GameTime;
		if(TimeLeft < (0.55 * npc.f_SpeedAcelerateAnim))
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				npc.m_iChanged_WalkCycle = 3;
				float EnemyVecPos[3]; 
				if(IsValidEnemy(npc.index, npc.m_iTarget))
					WorldSpaceCenter(npc.m_iTarget, EnemyVecPos);
				else
					WorldSpaceCenter(npc.index, EnemyVecPos);

				npc.PlayHitSound();
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
			//	CauseKiyruDamageLogic(owner, npc.m_iTarget, npc.f_DamageDo);
				i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
				i_ExplosiveProjectileHexArray[npc.index] |= EP_GIBS_REGARDLESS;
				Explode_Logic_Custom(npc.f_DamageDo, owner, npc.index, -1, EnemyVecPos, 300.0, .maxtargetshit = 6);
				i_ExplosiveProjectileHexArray[npc.index] == 0;
				npc.m_iAttachmentWhichDo = -1; 	
				npc.b_NoLongerResetVel = true;
				if(IsValidEntity(npc.m_iWearable8))
					DestroyBuildingDo(npc.m_iWearable8);

				npc.SetPlaybackRate(0.25);
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_iChanged_WalkCycle = 2;
				if(IsValidEntity(npc.m_iWearable8))
				{
					char WhichAttachmentDo[32];
					WhichAttachmentDo = "effect_hand_r";
					float flPos[3];
					float flAng[3];
					
					GetAttachment(npc.index, WhichAttachmentDo, flPos, flAng);

					int InfoTarget = InfoTargetParentAt(flPos,"", 0.0);
					SetParent(npc.index, InfoTarget, WhichAttachmentDo,_);
					SDKCall_SetLocalOrigin(npc.m_iWearable8, flPos);	
					SetEntPropVector(npc.m_iWearable8, Prop_Data, "m_angRotation", flAng);
					SetParent(InfoTarget, npc.m_iWearable8, _, _, _);
					npc.m_iWearable7 = InfoTarget;
				}
			}
		}
	}
}

void CauseKiyruDamageLogic(int owner, int target, float damage)
{
	float vecForward[3];
	static float angles[3];
	GetEntPropVector(owner, Prop_Data, "m_angRotation", angles);
	GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float damage_force[3]; CalculateDamageForce(vecForward, 40000.0, damage_force);
	float EnemyVecPos[3]; WorldSpaceCenter(target, EnemyVecPos);
	SDKHooks_TakeDamage(target, owner, owner, damage, DMG_CLUB, -1, damage_force, EnemyVecPos, _ , ZR_DAMAGE_CANNOTGIB_REGARDLESS);	// 2048 is DMG_NOGIB?
}

public void AlliedKiryuVisualiserAbility_NPCDeath(int entity)
{
	AlliedKiryuVisualiserAbility npc = view_as<AlliedKiryuVisualiserAbility>(entity);

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

	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);

	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
}


void DealAoeKnockbackBeastMode(int entity, int victim, float damage, int weapon)
{
	SensalCauseKnockback(entity, victim,_,_);
}