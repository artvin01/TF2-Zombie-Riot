#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};


//static j1

static bool b_enraged=false;

void Donnerkrieg_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_DefaultMedic_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_DefaultCapperShootSound);
	PrecacheSoundArray(g_DefaultLaserLaunchSound);
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	
	PrecacheSound("player/flow.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_ping.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Donnerkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_donnerkrieg");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "donner"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Donnerkrieg(vecPos, vecAng, team, data);
}

methodmap Donnerkrieg < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	property float m_flNorm_Attack_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flNCWindup
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property int m_iCannonActive
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_DefaultMedic_IdleAlertedSounds[GetRandomInt(0, sizeof(g_DefaultMedic_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_DefaultCapperShootSound[GetRandomInt(0, sizeof(g_DefaultCapperShootSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	
	public Donnerkrieg(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Donnerkrieg npc = view_as<Donnerkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		bool final = StrContains(data, "raid_ally") != -1;
		
		if(final)
		{
			if(g_b_item_allowed)
				b_NpcUnableToDie[npc.index] = true;

			i_RaidGrantExtra[npc.index] = 1;
		}
		else
		{
			if(!IsValidEntity(RaidBossActive))
			{
				RaidModeScaling = 0.0;
				RaidBossActive = EntIndexToEntRef(npc.index);
				RaidModeTime = GetGameTime(npc.index) + 9000.0;
				RaidAllowsBuildings = true;
			}
		}
		
		TwirlEarsApply(npc.index,_,0.75);

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
			
		g_b_donner_died=false;

		b_enraged=false;
		//IDLE
		npc.m_flSpeed = 300.0;
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
					
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		
		//SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		npc.StartPathing();
		
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		npc.m_iCannonActive = false;
		fl_BEAM_ChargeUpTime[npc.index] = 0.0;
		
		
		fl_BEAM_DurationTime[npc.index]= GetGameTime(npc.index) + 10.0;
		fl_BEAM_RechargeTime[npc.index]= GetGameTime(npc.index) + 10.0;
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		CPrintToChatAll("{crimson}도너크리그{default}: 심판을 내리기 위해 이 곳에 왔다.");
		
		g_b_angered=false;

		npc.m_bThisNpcIsABoss = true;

		//b_Begin_Dialogue = true;
		
	//	b_Schwertkrieg_Alive = false;
		
		//RaidModeTime = GetGameTime() + 100.0;
		ApplyStatusEffect(npc.index, npc.index, "Ruina Battery Charge", 9999.0);
		fl_ruina_battery_max[npc.index] = 1000000.0; //so high itll never be reached.
		fl_ruina_battery[npc.index] = 0.0;

		npc.m_flNorm_Attack_Duration = 0.0;
		
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(iNPC);
	
	CheckChargeTimeDonnerKrieg(npc);
	float GameTime = GetGameTime(npc.index);
	if(EntRefToEntIndex(RaidBossActive)==npc.index && i_RaidGrantExtra[npc.index] == 1)	//donnerkrieg handles the timer if its the same index
	{
		if(RaidModeTime < GameTime)
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
		}
	}
	if(npc.m_flNorm_Attack_Duration > GameTime)
	{
		if(!npc.m_iCannonActive)
			DonnerNormAttack(npc);
	}
		

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	if(!IsValidEntity(RaidBossActive) && !g_b_donner_died && i_RaidGrantExtra[npc.index] == 1)
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}
	else
	{
		if(EntRefToEntIndex(RaidBossActive)==npc.index && g_b_donner_died && i_RaidGrantExtra[npc.index] == 1)
		{
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(g_b_angered && !b_enraged)
	{
		if(!npc.m_iCannonActive)
		{
			fl_BEAM_RechargeTime[npc.index]=0.0;
			b_enraged=true;
		}
	}
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	if(g_b_donner_died && g_b_item_allowed && i_RaidGrantExtra[npc.index] == 1)
	{
		npc.m_flNextThinkTime = 0.0;
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_CROUCH_MELEE");
		npc.m_bisWalking = false;
		if(g_b_schwert_died && !IsValidEntity(RaidBossActive))
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
					{
						Music_Stop_All(client); //This is actually more expensive then i thought.
					}
					SetMusicTimer(client, GetTime() + 6);
					fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
				}
			}
			if(GameTime > g_f_blitz_dialogue_timesincehasbeenhurt)
			{
				CPrintToChatAll("{crimson}도너크리그{default}: 우릴 전부 구해줘서 고마워... 정말로.");
				npc.m_bDissapearOnDeath = true;

				CPrintToChatAll("{aqua}스텔라{snow}: 아, 그리고 우리의 진짜 이름은, {aqua}스텔라{snow}, 내 이름이다.");
				CPrintToChatAll("{aqua}스텔라{snow}: 그리고 이쪽은, {crimson}카를라스{snow}.");
				
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				for (int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
					{
						Items_GiveNamedItem(client, "Blitzkrieg's Army");
						CPrintToChat(client,"{default}이제 당신은 새로운 세력을 배럭으로 호출할 수 있게 되었습니다...: {crimson}''블리츠크리그의 군대''{default}!");
					}
				}
			}
			else if(GameTime + 3.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 8)
			{
				i_SaidLineAlready[npc.index] = 8;
				CPrintToChatAll("{crimson}도너크리그{default}: 블리츠크리그도 사라졌으니, 그의 수하들도 전부 자유의 몸이 됐어...");
			}
			else if(GameTime + 5.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 7)
			{
				i_SaidLineAlready[npc.index] = 7;
				CPrintToChatAll("{crimson}도너크리그{default}: 하지만, 이제 아무 상관 없어졌어.");
			}
			else if(GameTime + 8.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 6)
			{
				i_SaidLineAlready[npc.index] = 6;
				CPrintToChatAll("{crimson}도너크리그{default}: 혼돈의 영향이, 저 기계에게도 큰 영향을 미쳤기 때문이었다.");
			}
			else if(GameTime + 10.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 5)
			{
				i_SaidLineAlready[npc.index] = 5;
				CPrintToChatAll("{crimson}도너크리그{default}: 저 놈을 멈추지 않았다면, 우린 저 놈에게 죽었을 거다.");
			}
			else if(GameTime + 12.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 4)
			{
				i_SaidLineAlready[npc.index] = 4;
				CPrintToChatAll("{crimson}도너크리그{default}: 선택의 여지가 없었다고.");
			}
			else if(GameTime + 14.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 3)
			{
				i_SaidLineAlready[npc.index] = 3;
				CPrintToChatAll("{crimson}도너크리그{default}: 우린 이제 싸울 필요가 없어... 우리는...");
			}
			else if(GameTime + 16.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 2)
			{
				i_SaidLineAlready[npc.index] = 2;
				CPrintToChatAll("{crimson}도너크리그{default}: 네가 저 미친 기계를 드디어 저지해냈어.");
			}
			else if(GameTime + 18.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 1)
			{
				i_SaidLineAlready[npc.index] = 1;
				CPrintToChatAll("{crimson}도너크리그{default}: 아니, 잠깐! 멈춰!");
				ReviveAll(true);
			}
		}
		if(npc.m_bInKame)
		{
			npc.m_bInKame = false;
			
			npc.m_flRangedArmor = 1.0;
	
			if(IsValidEntity(npc.m_iWearable5))
				RemoveEntity(npc.m_iWearable5);
			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				
			
			fl_BEAM_DurationTime[npc.index] = 0.0;
			
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", npc.index, SNDCHAN_STATIC, 80, _, 1.0);
		}
		return; //He is trying to help.
	}
	if(fl_BEAM_DurationTime[npc.index] < GameTime && npc.m_iCannonActive)
	{	
		npc.m_flRangedArmor = 1.0;
		npc.m_iCannonActive = false;
		
		if(g_b_angered)
		{
			fl_BEAM_RechargeTime[npc.index] = GameTime + 30.0;
		}
		else		
		{		
			fl_BEAM_RechargeTime[npc.index] = GameTime + 90.0;
		}
		npc.m_flSpeed = 300.0;
		
		f_NpcTurnPenalty[npc.index] = 1.0;	//:)
		
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
		
	}
	int PrimaryThreatIndex = npc.m_iTarget;
		
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(fl_BEAM_RechargeTime[npc.index]<GameTime && !npc.m_iCannonActive)
		{
			fl_BEAM_DurationTime[npc.index] = GameTime + 20.0;
			Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
		}
		if(!npc.m_iCannonActive)
		{	
	
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
				
			if(g_b_angered)	//thanks to the loss of his companion donner has gained A NECK
			{
				int iPitch = npc.LookupPoseParameter("body_pitch");
				if(iPitch >= 0)
				{

					//Body pitch
					float v[3], ang[3];
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					float WorldSpaceVec2[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec2);
					SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
					NormalizeVector(v, v);
					GetVectorAngles(v, ang); 
							
					float flPitch = npc.GetPoseParameter(iPitch);
							
					npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
					
				}	
			}
			if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime && flDistanceToTarget > (110.0 * 110.0) && flDistanceToTarget < (500.0 * 500.0))
			{	

				npc.FaceTowards(vecTarget);
				float projectile_speed = 400.0;
				PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed,_,vecTarget);
				if(g_b_angered)
				{
					npc.FireParticleRocket(vecTarget, 1250.0 , 400.0 , 100.0 , "raygun_projectile_blue");
				}
				else
				{
					npc.FireParticleRocket(vecTarget, 250.0 , 400.0 , 100.0 , "raygun_projectile_blue");
				}
					
				//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)

				npc.m_iAmountProjectiles += 1;
				npc.PlayRangedSound();
				npc.AddGesture("ACT_MP_THROW");
				npc.m_flNextRangedBarrage_Singular = GameTime + 0.15;
				if (npc.m_iAmountProjectiles >= 15.0)
				{
					npc.m_iAmountProjectiles = 0;
					npc.m_flNextRangedBarrage_Spam = GameTime + 45.0;
				}
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime+0.4;
						npc.m_flAttackHappens_bullshit = GameTime+0.54;
						npc.m_flAttackHappenswillhappen = true;
						npc.FaceTowards(vecTarget);

						npc.PlayLaserLaunchSound();
						npc.m_flNorm_Attack_Duration = GameTime + 0.25;
						
						if(flDistanceToTarget < 100.0*100.0)	//to prevent players from sitting ontop of donnerkrieg and just stabing his head
						{
							Handle swingTrace;
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1))
							{
								int target = TR_GetEntityIndex(swingTrace);	
							
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, 300.0, DMG_CLUB, -1, _, vecHit);						
								} 
							}
							delete swingTrace;
						}
					}
					if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.6;
					}
				}
			}
			else
			{
				npc.StartPathing();
			}
		}
		else
		{
			Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
		}
		
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(!npc.m_bInKame && !npc.m_iCannonActive)
	{
		npc.StartPathing();
	}
	npc.PlayIdleAlertSound();
}

static void Donnerkrieg_Nightmare_Logic(int ref, int PrimaryThreatIndex)
{		
	Donnerkrieg npc = view_as<Donnerkrieg>(ref);

	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float GameTime = GetGameTime(npc.index);
	if(!npc.m_bInKame)
	{
		if(!npc.m_iCannonActive)
		{
			if(g_b_angered)
			{
				fl_BEAM_ChargeUpTime[npc.index] = GameTime + 1.0;	//how long until the npc fires the cannon, basically for how long will the npc run away for
			}
			else
			{
				fl_BEAM_ChargeUpTime[npc.index] = GameTime + 10.0;	//how long until the npc fires the cannon, basically for how long will the npc run away for
			}
			
			npc.m_iCannonActive = true;
			
			switch(GetRandomInt(1,6))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}도너크리그{default}: {crimson}이제 끝내야지. {default}안 그래?");	
				}
				case 2:
				{
					CPrintToChatAll("{crimson}도너크리그{default}: {crimson}흠, {default}어떻게 끝날지 참 기대되는군...");	
				}
				case 3:
				{
					CPrintToChatAll("{crimson}도너크리그{default}: {crimson}각오해라, {yellow}심판이 {default}멀지 않았다.");	
				}
				case 4:
				{
					switch(GetRandomInt(0,10))
					{
						case 5:
						{
							CPrintToChatAll("{crimson}도너크리그{default}: 이것도 다시 쓰려면 기다려야한다니..");	
							npc.m_bFUCKYOU_move_anim = true;
						}				
						default:
						{
							CPrintToChatAll("{crimson}도너크리그{default}: 내 포는 다시 {crimson}충전{default}해야한다.");	
						}
							
					}
				}
				case 5:
				{
					CPrintToChatAll("{crimson}도너크리그{default}: 이 무기로 조준하는건 사실 꽤 {crimson}어려운 {default}일이라고.");	
					npc.m_bFUCKYOU = true;
				}
				case 6:
				{
					CPrintToChatAll("{crimson}도너크리그{default}: 그거 알고 있나? 이 싸움이 점점 {crimson}지겨워지고 있는걸.");	
				}
			}
			
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
		}
		else
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				npc.StartPathing();
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
				
				if(fl_BEAM_ChargeUpTime[npc.index]<GameTime)
				{
					fl_BEAM_ChargeUpTime[npc.index] = GameTime + 99.0;
					if(!npc.m_bFUCKYOU && !npc.m_bFUCKYOU_move_anim)
					{	
						switch(GetRandomInt(1,3))
						{
							case 1:
							{
								CPrintToChatAll("{crimson}도너크리그{default}: {crimson}악몽포 발사!");
							}
							case 2:
							{
								CPrintToChatAll("{crimson}도너크리그{default}: {crimson}저들에게 죽음을!");
							}
							case 3:
							{
								CPrintToChatAll("{crimson}도너크리그{default}: {crimson}섬멸 개시!");	
							}
						}
					}
					else
					{
						if(npc.m_bFUCKYOU_move_anim)
						{
							CPrintToChatAll("{crimson}도너크리그{default}: {crimson}여전히, 너희를 섬멸하기엔 충분하다...");	
							npc.m_bFUCKYOU_move_anim = false;
						}
						else if(npc.m_bFUCKYOU)
						{
							npc.m_bFUCKYOU = false;
							CPrintToChatAll("{crimson}도너크리그{default}: 그러나, 너흴 상대로는 여전히 {crimson}사용 가치가 있다.");	
						}
						
					}
					
					f_NpcTurnPenalty[npc.index] = 0.01;	//:)
					
					npc.m_bInKame = true;
					
					npc.m_flRangedArmor = 0.5;
						
					float flPos[3]; // original
					float flAng[3]; // original
						
					npc.GetAttachment("", flPos, flAng);
					npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "utaunt_portalswirl_purple_parent", npc.index, "", {0.0,0.0,0.0});
					npc.GetAttachment("", flPos, flAng);
					npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_runeprison_yellow_parent", npc.index, "", {0.0,0.0,0.0});
						
					npc.FaceTowards(vecTarget, 20000.0);	//TURN DAMMIT
						
						
					npc.m_bisWalking = false;
					if(g_b_angered)
					{
						//npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
						npc.AddActivityViaSequence("taunt_the_fist_bump");
					}
					else
					{
						npc.AddActivityViaSequence("taunt_the_fist_bump");
					}
					
					EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
					CreateTimer(1.0, Donner_Nightmare_Offset, EntRefToEntIndex(npc.index), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				npc.StartPathing();
				
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
		}
		
	}
	else
	{
		
		if(g_b_angered)	//thanks to the loss of his companion donner has gained A NECK
		{
			int iPitch = npc.LookupPoseParameter("body_pitch");
			if(iPitch >= 0)
			{
				//Body pitch
				float v[3], ang[3];
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec2);
				SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
				NormalizeVector(v, v);
				GetVectorAngles(v, ang); 
								
				float flPitch = npc.GetPoseParameter(iPitch);
								
				npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
				
			}	
		}
				
		npc.StartPathing();
		
		npc.SetGoalEntity(PrimaryThreatIndex);
		
		float WorldSpaceVec[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec);
		if(g_b_angered)
		{
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
		else
		{
			npc.FaceTowards(WorldSpaceVec, 5.0);
		}
		
		npc.StopPathing();
		
		npc.m_flSpeed = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
	}
}

static Action Donner_Nightmare_Offset(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Donnerkrieg npc = view_as<Donnerkrieg>(client);
		fl_BEAM_DurationTime[npc.index] = GetGameTime(npc.index) + 15.0;
		Invoke_NightmareCannon(npc);
	}
	return Plugin_Handled;
}
static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");	//npc becomes imortal when at 1 hp and when its a valid wave	//warp_item
	if(RoundToCeil(damage)>=Health && i_RaidGrantExtra[npc.index] == 1)
	{
		if(g_b_item_allowed)
		{
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(20.0);


			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
		}
		if(!g_b_donner_died)
		{
			g_b_donner_died=true;
			g_b_angered=true;
			RaidModeTime += 22.5;
			npc.m_bThisNpcIsABoss = false;
			if(EntRefToEntIndex(RaidBossActive)==npc.index)
				RaidBossActive = INVALID_ENT_REFERENCE;
			g_f_blitz_dialogue_timesincehasbeenhurt = GetGameTime(npc.index)+20.0;
		}
		if(npc.m_bInKame)
		{
			npc.m_bInKame = false;
			
			npc.m_flRangedArmor = 1.0;
	
			if(IsValidEntity(npc.m_iWearable5))
				RemoveEntity(npc.m_iWearable5);
			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				

			
			fl_BEAM_DurationTime[npc.index] = 0.0;
			
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", npc.index, SNDCHAN_STATIC, 80, _, 1.0);
		}
		return Plugin_Handled;
	}
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
	b_NpcIsInvulnerable[npc.index] = false;
	ExpidonsaRemoveEffects(entity);
			
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))	//particles
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))	//temp particles
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))	//temp particles
		RemoveEntity(npc.m_iWearable6);
}
static void DonnerNormAttack(Donnerkrieg npc)
{
	Basic_NPC_Laser Data;
	Data.npc = npc;
	Data.Radius = 10.0;
	Data.Range = 1000.0;
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = 200.0 / 6.0 / TickrateModify / ReturnEntityAttackspeed(npc.index);
	Data.Long_Dps = 100.0 / 6.0 / TickrateModify / ReturnEntityAttackspeed(npc.index);
	Data.Color = {255, 255, 255, 30};
	Data.DoEffects = true;
	GetAttachment(npc.index, "effect_hand_r", Data.EffectsStartLoc, NULL_VECTOR);
	Basic_NPC_Laser_Logic(Data);

}
static void Invoke_NightmareCannon(Donnerkrieg npc)
{
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "eyeboss_death_vortex", 2.0);
	EmitSoundToAll("mvm/mvm_tank_ping.wav");

	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 75);
	
	npc.PlayLaserLaunchSound();

	npc.m_flNCWindup = GetGameTime() + 1.5;

	SDKUnhook(npc.index, SDKHook_Think, NightmareCannon_TBB_Tick);
	SDKHook(npc.index, SDKHook_Think, NightmareCannon_TBB_Tick);
	
}
public Action NightmareCannon_TBB_Tick(int client)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(client);
	float GameTime = GetGameTime(npc.index);
	if(!IsValidEntity(client) || fl_BEAM_DurationTime[npc.index] < GameTime)
	{
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);

		SDKUnhook(client, SDKHook_Think, NightmareCannon_TBB_Tick);
		npc.m_bInKame = false;
		return Plugin_Stop;
	}

	if(npc.m_flNCWindup > GameTime)
		return Plugin_Continue;

	Basic_NPC_Laser Data;
	Data.npc = npc;
	Data.Radius = 150.0;
	Data.Range = -1.0;
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = 750.0 / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Long_Dps = 450.0 / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Color = {255, 3, 3, 60};
	Data.DoEffects = true;
	Data.RelativeOffset = true;
	Data.EffectsStartLoc[0] = 0.0;	//forward/back
	Data.EffectsStartLoc[1] = -1.0;	//left right
	Data.EffectsStartLoc[2] = 25.0;	//up down
	Basic_NPC_Laser_Logic(Data);
	
	return Plugin_Continue;
}


static void CheckChargeTimeDonnerKrieg(Donnerkrieg npc)
{
	float GameTime = GetGameTime(npc.index);
	float PercentageCharge = 0.0;
	float TimeUntillTeleLeft = fl_BEAM_RechargeTime[npc.index] - GameTime;

	PercentageCharge = (TimeUntillTeleLeft  / (90.0));
	
	if(PercentageCharge <= 0.0)
		PercentageCharge = 0.0;

	if(PercentageCharge >= 1.0)
		PercentageCharge = 1.0;

	PercentageCharge -= 1.0;
	PercentageCharge *= -1.0;

	TwirlSetBatteryPercentage(npc.index, PercentageCharge);
}