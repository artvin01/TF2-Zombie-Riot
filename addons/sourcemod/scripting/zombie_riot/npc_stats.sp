
//#define COMBINE_CUSTOM_MODEL "models/zombie_riot/combine_attachment_police_59.mdl"

#define COMBINE_CUSTOM_MODEL "models/zombie_riot/combine_attachment_police_159.mdl"

#define DEFAULT_UPDATE_DELAY_FLOAT 0.02 //Make it 0 for now

#define DEFAULT_HURTDELAY 0.35 //Make it 0 for now

float f_ArrowDamage[MAXENTITIES];
int f_ArrowTrailParticle[MAXENTITIES]={INVALID_ENT_REFERENCE, ...};

//Arrays for npcs!
bool b_DissapearOnDeath[MAXENTITIES];
bool b_IsGiant[MAXENTITIES];
bool b_Pathing[MAXENTITIES];
bool b_Jumping[MAXENTITIES];
float fl_JumpStartTime[MAXENTITIES];
float fl_JumpCooldown[MAXENTITIES];
float fl_NextThinkTime[MAXENTITIES];
float fl_NextMeleeAttack[MAXENTITIES];
float fl_Speed[MAXENTITIES];
int i_Target[MAXENTITIES];
float fl_GetClosestTargetTime[MAXENTITIES];
float fl_NextHurtSound[MAXENTITIES];
float fl_HeadshotCooldown[MAXENTITIES];
bool b_CantCollidie[MAXENTITIES];
bool b_CantCollidieAlly[MAXENTITIES];
bool b_BuildingIsStacked[MAXENTITIES];
bool b_bBuildingIsPlaced[MAXENTITIES];
bool b_XenoInfectedSpecialHurt[MAXENTITIES];
float fl_XenoInfectedSpecialHurtTime[MAXENTITIES];
bool b_DoGibThisNpc[MAXENTITIES];
int i_Wearable1[MAXENTITIES]={-1, ...};
int i_Wearable2[MAXENTITIES]={-1, ...};
int i_Wearable3[MAXENTITIES]={-1, ...};
int i_Wearable4[MAXENTITIES]={-1, ...};
int i_Wearable5[MAXENTITIES]={-1, ...};
int i_Wearable6[MAXENTITIES]={-1, ...};
int i_TeamGlow[MAXENTITIES]={-1, ...};

int i_SpawnProtectionEntity[MAXENTITIES]={-1, ...};
float f3_VecPunchForce[MAXENTITIES][3];
float fl_NextDelayTime[MAXENTITIES];
bool b_ThisEntityIgnored[MAXENTITIES];
float fl_NextIdleSound[MAXENTITIES];
float fl_AttackHappensMinimum[MAXENTITIES];
float fl_AttackHappensMaximum[MAXENTITIES];
bool b_AttackHappenswillhappen[MAXENTITIES];
bool b_thisNpcIsABoss[MAXENTITIES];
float f3_VecTeleportBackSave[MAXENTITIES][3];
float f3_VecTeleportBackSaveJump[MAXENTITIES][3];
bool b_NPCVelocityCancel[MAXENTITIES];
float fl_DoSpawnGesture[MAXENTITIES];
bool b_isWalking[MAXENTITIES];
int i_StepNoiseType[MAXENTITIES];
int i_NpcStepVariation[MAXENTITIES];
int i_BleedType[MAXENTITIES];
int i_State[MAXENTITIES];
bool b_movedelay[MAXENTITIES];
float fl_NextRangedAttack[MAXENTITIES];
int i_AttacksTillReload[MAXENTITIES];
bool b_Gunout[MAXENTITIES];
float fl_ReloadDelay[MAXENTITIES];
float fl_InJump[MAXENTITIES];
float fl_DoingAnimation[MAXENTITIES];
float fl_NextRangedBarrage_Spam[MAXENTITIES];
float fl_NextRangedBarrage_Singular[MAXENTITIES];
bool b_NextRangedBarrage_OnGoing[MAXENTITIES];
float fl_NextTeleport[MAXENTITIES];
bool b_Anger[MAXENTITIES];
float fl_NextRangedSpecialAttack[MAXENTITIES];
bool b_RangedSpecialOn[MAXENTITIES];
float fl_RangedSpecialDelay[MAXENTITIES];
float fl_movedelay[MAXENTITIES];
float fl_NextChargeSpecialAttack[MAXENTITIES];
float fl_AngerDelay[MAXENTITIES];
bool b_FUCKYOU[MAXENTITIES];
bool b_FUCKYOU_move_anim[MAXENTITIES];
bool b_healing[MAXENTITIES];
bool b_new_target[MAXENTITIES];
float fl_ReloadIn[MAXENTITIES];
int i_TimesSummoned[MAXENTITIES];
float fl_AttackHappens_2[MAXENTITIES];
float fl_Charge_delay[MAXENTITIES];
float fl_Charge_Duration[MAXENTITIES];
bool b_movedelay_gun[MAXENTITIES];
bool b_Half_Life_Regen[MAXENTITIES];
float fl_Dead_Ringer_Invis[MAXENTITIES];
float fl_Dead_Ringer[MAXENTITIES];
bool b_Dead_Ringer_Invis_bool[MAXENTITIES];
int i_AttacksTillMegahit[MAXENTITIES];

float fl_NextFlameSound[MAXENTITIES];
float fl_FlamerActive[MAXENTITIES];
bool b_DoSpawnGesture[MAXENTITIES];
bool b_LostHalfHealth[MAXENTITIES];
bool b_LostHalfHealthAnim[MAXENTITIES];
bool b_DuringHighFlight[MAXENTITIES];
bool b_DuringHook[MAXENTITIES];
bool b_GrabbedSomeone[MAXENTITIES];
bool b_UseDefaultAnim[MAXENTITIES];
bool b_FlamerToggled[MAXENTITIES];
float fl_WaveScale[MAXENTITIES];
float fl_StandStill[MAXENTITIES];
float fl_GrappleCooldown[MAXENTITIES];
float fl_HookDamageTaken[MAXENTITIES];

bool b_PlayHurtAnimation[MAXENTITIES];
bool b_follow[MAXENTITIES];
bool b_movedelay_walk[MAXENTITIES];
bool b_movedelay_run[MAXENTITIES];
bool b_IsFriendly[MAXENTITIES];
bool b_stand_still[MAXENTITIES];
bool b_Reloaded[MAXENTITIES];
float fl_Following_Master_Now[MAXENTITIES];
float fl_DoingSpecial[MAXENTITIES];
float fl_ComeToMe[MAXENTITIES];
int i_MedkitAnnoyance[MAXENTITIES];
float fl_idle_talk[MAXENTITIES];
float fl_heal_cooldown[MAXENTITIES];
float fl_Hurtie[MAXENTITIES];
float fl_ExtraDamage[MAXENTITIES];
int i_Changed_WalkCycle[MAXENTITIES];
bool b_WasSadAlready[MAXENTITIES];
int i_TargetAlly[MAXENTITIES];
bool b_GetClosestTargetTimeAlly[MAXENTITIES];
float fl_Duration[MAXENTITIES];
int i_OverlordComboAttack[MAXENTITIES];

int i_Activity[MAXENTITIES];
int i_PoseMoveX[MAXENTITIES];
int i_PoseMoveY[MAXENTITIES];
//Arrays for npcs!
bool b_bThisNpcGotDefaultStats_INVERTED[MAXENTITIES];
float b_isGiantWalkCycle[MAXENTITIES];

bool Is_a_Medic[MAXENTITIES]; //THIS WAS INSIDE THE NPCS!
int i_CreditsOnKill[MAXENTITIES];

int i_InSafeZone[MAXENTITIES];
float fl_MeleeArmor[MAXENTITIES];
float fl_RangedArmor[MAXENTITIES];





#define RAD2DEG(%1) ((%1) * (180.0 / FLOAT_PI))
#define DEG2RAD(%1) ((%1) * FLOAT_PI / 180.0)

#define EF_BONEMERGE		(1 << 0)
#define EF_PARENT_ANIMATES	(1 << 9)

#define	SHAKE_START					0			// Starts the screen shake for all players within the radius.
#define	SHAKE_STOP					1			// Stops the screen shake for all players within the radius.
#define	SHAKE_AMPLITUDE				2			// Modifies the amplitude of an active screen shake for all players within the radius.
#define	SHAKE_FREQUENCY				3			// Modifies the frequency of an active screen shake for all players within the radius.
#define	SHAKE_START_RUMBLEONLY		4			// Starts a shake effect that only rumbles the controller, no screen effect.
#define	SHAKE_START_NORUMBLE		5			// Starts a shake that does NOT rumble the controller.

#define GORE_ABDOMEN	  (1 << 0)
#define GORE_FOREARMLEFT  (1 << 1)
#define GORE_HANDRIGHT	(1 << 2)
#define GORE_FOREARMRIGHT (1 << 3)
#define GORE_HEAD		 (1 << 4)
#define GORE_HEADLEFT	 (1 << 5)
#define GORE_HEADRIGHT	(1 << 6)
#define GORE_UPARMLEFT	(1 << 7)
#define GORE_UPARMRIGHT   (1 << 8)
#define GORE_HANDLEFT	 (1 << 9)

#define MAXENTITIES	2048
static const float OFF_THE_MAP[3] = { 16383.0, 16383.0, -16383.0 };
bool EscapeModeMap;
static int g_particleImpactMetal;
static int g_particleImpactFlesh;
static int g_particleImpactRubber;
static int g_modelArrow;
//I put these here so we can change them on fly if we need to, cus zombies can be really loud, or quiet.

#define NORMAL_ZOMBIE_SOUNDLEVEL	 80
#define NORMAL_ZOMBIE_VOLUME	 0.9

#define BOSS_ZOMBIE_SOUNDLEVEL	 90
#define BOSS_ZOMBIE_VOLUME	 1.0

#define RAIDBOSS_ZOMBIE_SOUNDLEVEL	 95
#define RAIDBOSSBOSS_ZOMBIE_VOLUME	 1.0

#define ARROW_TRAIL "effects/arrowtrail_blu.vmt"

char g_ArrowHitSoundSuccess[][] = {
	"weapons/fx/rics/arrow_impact_flesh.wav",
	"weapons/fx/rics/arrow_impact_flesh2.wav",
	"weapons/fx/rics/arrow_impact_flesh3.wav",
	"weapons/fx/rics/arrow_impact_flesh4.wav",
};

char g_ArrowHitSoundMiss[][] = {
	"weapons/fx/rics/arrow_impact_concrete.wav",
	"weapons/fx/rics/arrow_impact_concrete2.wav",
	"weapons/fx/rics/arrow_impact_concrete4.wav",
};

char g_GibSound[][] = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav",
	"physics/flesh/flesh_bloody_break.wav",
};

char g_GibSoundMetal[][] = {
	"ui/item_metal_pot_drop.wav",
	"ui/item_metal_scrap_drop.wav",
	"ui/item_metal_scrap_pickup.wav",
	"ui/item_metal_scrap_pickup.wav",
	"ui/item_metal_weapon_drop.wav",
};

char g_CombineSoldierStepSound[][] = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav",
};

char g_CombineMetroStepSound[][] = {
	"npc/metropolice/gear1.wav",
	"npc/metropolice/gear2.wav",
	"npc/metropolice/gear3.wav",
	"npc/metropolice/gear4.wav",
	"npc/metropolice/gear5.wav",
	"npc/metropolice/gear6.wav",
};

char g_PanzerStepSound[][] = {
	"mvm/giant_common/giant_common_step_01.wav",
	"mvm/giant_common/giant_common_step_02.wav",
	"mvm/giant_common/giant_common_step_03.wav",
	"mvm/giant_common/giant_common_step_04.wav",
	"mvm/giant_common/giant_common_step_05.wav",
	"mvm/giant_common/giant_common_step_06.wav",
	"mvm/giant_common/giant_common_step_07.wav",
	"mvm/giant_common/giant_common_step_08.wav",
};


public Action Command_PetMenu(int client, int argc)
{
	//What are you.
	if(!(client > 0 && client <= MaxClients && IsClientInGame(client)))
		return Plugin_Handled;
	
	if(argc < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_spawn_npc <index> [data] [ally]");
		return Plugin_Handled;
	}
	
	float flPos[3], flAng[3];
	GetClientAbsAngles(client, flAng);
	if(!SetTeleportEndPoint(client, flPos))
	{
		PrintToChat(client, "Could not find place.");
		return Plugin_Handled;
	}
	
	char buffer[16];
	GetCmdArg(2, buffer, sizeof(buffer));
	
	bool ally;
	if(argc > 2)
		ally = view_as<bool>(GetCmdArgInt(3));
	
	if(IsValidEntity(Npc_Create(GetCmdArgInt(1), client, flPos, flAng, ally, buffer)))
	{
		Zombies_Currently_Still_Ongoing += 1;
	}
	return Plugin_Handled;
}

enum
{
	STEPTYPE_NORMAL = 1,	
	STEPTYPE_COMBINE = 2,	
	STEPTYPE_PANZER = 3,
	STEPTYPE_COMBINE_METRO = 4,
}

enum
{
	STEPSOUND_NORMAL = 1,	
	STEPSOUND_GIANT = 2,	
}

enum
{
	BLEEDTYPE_NORMAL = 1,	
	BLEEDTYPE_METAL = 2,	
	BLEEDTYPE_RUBBER = 3,	
}

int GetIndexByPluginName(const char[] name)
{
	for(int i; i<sizeof(NPC_Plugin_Names_Converted); i++)
	{
		if(StrEqual(name, NPC_Plugin_Names_Converted[i], false))
			return i;
	}
	return 0;
}

any Npc_Create(int Index_Of_Npc, int client, float vecPos[3], float vecAng[3], bool ally, const char[] data="") //dmg mult only used for summonings
{
	any entity = -1;
	switch(Index_Of_Npc)
	{
		case HEADCRAB_ZOMBIE:
		{
			entity = HeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_HEADCRAB_ZOMBIE:
		{
			entity = FortifiedHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case FASTZOMBIE:
		{
			entity = FastZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_FASTZOMBIE:
		{
			entity = FortifiedFastZombie(client, vecPos, vecAng, ally);
		}
		case TORSOLESS_HEADCRAB_ZOMBIE:
		{
			entity = TorsolessHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			entity = FortifiedGiantPoisonZombie(client, vecPos, vecAng, ally);
		}
		case POISON_ZOMBIE:
		{
			entity = PoisonZombie(client, vecPos, vecAng, ally);
		}
		case FORTIFIED_POISON_ZOMBIE:
		{
			entity = FortifiedPoisonZombie(client, vecPos, vecAng, ally);
		}
		case FATHER_GRIGORI:
		{
			entity = FatherGrigori(client, vecPos, vecAng, ally);
		}
		case COMBINE_POLICE_PISTOL:
		{
			entity = Combine_Police_Pistol(client, vecPos, vecAng, ally);
		}
		case COMBINE_POLICE_SMG:
		{
			entity = CombinePoliceSmg(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_AR2:
		{
			entity = CombineSoldierAr2(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_SHOTGUN:
		{
			entity = CombineSoldierShotgun(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_SWORDSMAN:
		{
			entity = CombineSwordsman(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_ELITE:
		{
			entity = CombineElite(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			entity = CombineGaint(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_DDT:
		{
			entity = CombineDDT(client, vecPos, vecAng, ally);
		}
		case COMBINE_SOLDIER_COLLOSS:
		{
			entity = CombineCollos(client, vecPos, vecAng, ally);
		}
		case COMBINE_OVERLORD:
		{
			entity = CombineOverlord(client, vecPos, vecAng, ally);
		}
		case SCOUT_ZOMBIE:
		{
			entity = Scout(client, vecPos, vecAng, ally);
		}
		case ENGINEER_ZOMBIE:
		{
			entity = Engineer(client, vecPos, vecAng, ally);
		}
		case HEAVY_ZOMBIE:
		{
			entity = Heavy(client, vecPos, vecAng, ally);
		}
		case FLYINGARMOR_ZOMBIE:
		{
			entity = FlyingArmor(client, vecPos, vecAng, ally);
		}
		case FLYINGARMOR_TINY_ZOMBIE:
		{
			entity = FlyingArmorTiny(client, vecPos, vecAng, ally);
		}
		case KAMIKAZE_DEMO:
		{
			entity = Kamikaze(client, vecPos, vecAng, ally);
		}
		case MEDIC_HEALER:
		{
			entity = MedicHealer(client, vecPos, vecAng, ally);
		}
		case HEAVY_ZOMBIE_GIANT:
		{
			entity = HeavyGiant(client, vecPos, vecAng, ally);
		}
		case SPY_FACESTABBER:
		{
			entity = Spy(client, vecPos, vecAng, ally);
		}
		case SOLDIER_ROCKET_ZOMBIE:
		{
			entity = Soldier(client, vecPos, vecAng, ally);
		}
		case SOLDIER_ZOMBIE_MINION:
		{
			entity = SoldierMinion(client, vecPos, vecAng, ally);
		}
		case SOLDIER_ZOMBIE_BOSS:
		{
			entity = SoldierGiant(client, vecPos, vecAng, ally);
		}
		case SPY_THIEF:
		{
			entity = SpyThief(client, vecPos, vecAng, ally);
		}
		case SPY_TRICKSTABBER:
		{
			entity = SpyTrickstabber(client, vecPos, vecAng, ally);
		}
		case SPY_HALF_CLOACKED:
		{
			entity = SpyCloaked(client, vecPos, vecAng, ally);
		}
		case SNIPER_MAIN:
		{
			entity = SniperMain(client, vecPos, vecAng, ally);
		}
		case DEMO_MAIN:
		{
			entity = DemoMain(client, vecPos, vecAng, ally);
		}
		case BATTLE_MEDIC_MAIN:
		{
			entity = MedicMain(client, vecPos, vecAng, ally);
		}
		case GIANT_PYRO_MAIN:
		{
			entity = PyroGiant(client, vecPos, vecAng, ally);
		}
		case COMBINE_DEUTSCH_RITTER:
		{
			entity = CombineDeutsch(client, vecPos, vecAng, ally);
		}
		case SPY_MAIN_BOSS:
		{
			entity = SpyMainBoss(client, vecPos, vecAng, ally);
		}
		//XENO
		case XENO_HEADCRAB_ZOMBIE:
		{
			entity = XenoHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
		{
			entity = XenoFortifiedHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FASTZOMBIE:
		{
			entity = XenoFastZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_FASTZOMBIE:
		{
			entity = XenoFortifiedFastZombie(client, vecPos, vecAng, ally);
		}
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
		{
			entity = XenoTorsolessHeadcrabZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			entity = XenoFortifiedGiantPoisonZombie(client, vecPos, vecAng, ally);
		}
		case XENO_POISON_ZOMBIE:
		{
			entity = XenoPoisonZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FORTIFIED_POISON_ZOMBIE:
		{
			entity = XenoFortifiedPoisonZombie(client, vecPos, vecAng, ally);
		}
		case XENO_FATHER_GRIGORI:
		{
			entity = XenoFatherGrigori(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_POLICE_PISTOL:
		{
			entity = XenoCombinePolicePistol(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_POLICE_SMG:
		{
			entity = XenoCombinePoliceSmg(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_AR2:
		{
			entity = XenoCombineSoldierAr2(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_SHOTGUN:
		{
			entity = XenoCombineSoldierShotgun(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
		{
			entity = XenoCombineSwordsman(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_ELITE:
		{
			entity = XenoCombineElite(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			entity = XenoCombineGaint(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_DDT:
		{
			entity = XenoCombineDDT(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_SOLDIER_COLLOSS:
		{
			entity = XenoCombineCollos(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_OVERLORD:
		{
			entity = XenoCombineOverlord(client, vecPos, vecAng, ally);
		}
		case XENO_SCOUT_ZOMBIE:
		{
			entity = XenoScout(client, vecPos, vecAng, ally);
		}
		case XENO_ENGINEER_ZOMBIE:
		{
			entity = XenoEngineer(client, vecPos, vecAng, ally);
		}
		case XENO_HEAVY_ZOMBIE:
		{
			entity = XenoHeavy(client, vecPos, vecAng, ally);
		}
		case XENO_FLYINGARMOR_ZOMBIE:
		{
			entity = XenoFlyingArmor(client, vecPos, vecAng, ally);
		}
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
		{
			entity = XenoFlyingArmorTiny(client, vecPos, vecAng, ally);
		}
		case XENO_KAMIKAZE_DEMO:
		{
			entity = XenoKamikaze(client, vecPos, vecAng, ally);
		}
		case XENO_MEDIC_HEALER:
		{
			entity = XenoMedicHealer(client, vecPos, vecAng, ally);
		}
		case XENO_HEAVY_ZOMBIE_GIANT:
		{
			entity = XenoHeavyGiant(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_FACESTABBER:
		{
			entity = XenoSpy(client, vecPos, vecAng, ally);
		}
		case XENO_SOLDIER_ROCKET_ZOMBIE:
		{
			entity = XenoSoldier(client, vecPos, vecAng, ally);
		}
		case XENO_SOLDIER_ZOMBIE_MINION:
		{
			entity = XenoSoldierMinion(client, vecPos, vecAng, ally);
		}
		case XENO_SOLDIER_ZOMBIE_BOSS:
		{
			entity = XenoSoldierGiant(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_THIEF:
		{
			entity = XenoSpyThief(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_TRICKSTABBER:
		{
			entity = XenoSpyTrickstabber(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_HALF_CLOACKED:
		{
			entity = XenoSpyCloaked(client, vecPos, vecAng, ally);
		}
		case XENO_SNIPER_MAIN:
		{
			entity = XenoSniperMain(client, vecPos, vecAng, ally);
		}
		case XENO_DEMO_MAIN:
		{
			entity = XenoDemoMain(client, vecPos, vecAng, ally);
		}
		case XENO_BATTLE_MEDIC_MAIN:
		{
			entity = XenoMedicMain(client, vecPos, vecAng, ally);
		}
		case XENO_GIANT_PYRO_MAIN:
		{
			entity = XenoPyroGiant(client, vecPos, vecAng, ally);
		}
		case XENO_COMBINE_DEUTSCH_RITTER:
		{
			entity = XenoCombineDeutsch(client, vecPos, vecAng, ally);
		}
		case XENO_SPY_MAIN_BOSS:
		{
			entity = XenoSpyMainBoss(client, vecPos, vecAng, ally);
		}
		case NAZI_PANZER:
		{
			entity = NaziPanzer(client, vecPos, vecAng, ally);
		}
		case BOB_THE_GOD_OF_GODS:
		{
			entity = BobTheGod(client, vecPos, vecAng);
		}
		case NECRO_COMBINE:
		{
			entity = NecroCombine(client, vecPos, vecAng, StringToFloat(data));
		}
		case NECRO_CALCIUM:
		{
			entity = NecroCalcium(client, vecPos, vecAng, StringToFloat(data));
		}
		case CURED_FATHER_GRIGORI:
		{
			entity = CuredFatherGrigori(client, vecPos, vecAng);
		}
		case ALT_COMBINE_MAGE:
		{
			entity = AltCombineMage(client, vecPos, vecAng, ally);
		}
		case BTD_BLOON:
		{
			entity = Bloon(client, vecPos, vecAng, ally, data);
		}
		case BTD_MOAB:
		{
			entity = Moab(client, vecPos, vecAng, ally, data);
		}
		case BTD_BFB:
		{
			entity = BFB(client, vecPos, vecAng, ally, data);
		}
		case BTD_ZOMG:
		{
			entity = Zomg(client, vecPos, vecAng, ally, data);
		}
		case BTD_DDT:
		{
			entity = DDT(client, vecPos, vecAng, ally, data);
		}
		case BTD_BAD:
		{
			entity = Bad(client, vecPos, vecAng, ally, data);
		}
		case ALT_MEDIC_APPRENTICE_MAGE:
		{
			entity = AltMedicApprenticeMage(client, vecPos, vecAng, ally);
		}
		case SAWRUNNER:
		{
			entity = SawRunner(client, vecPos, vecAng, ally);
		}
		case RAIDMODE_TRUE_FUSION_WARRIOR:
		{
			entity = TrueFusionWarrior(client, vecPos, vecAng, ally);
		}
		case ALT_MEDIC_CHARGER:
        {
            entity = AltMedicCharger(client, vecPos, vecAng, ally);
        }
        case ALT_MEDIC_BERSERKER:
		{
			entity = AltMedicBerseker(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_MILITIA:
		{
			entity = MedivalMilitia(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_ARCHER:
		{
			entity = MedivalArcher(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_MAN_AT_ARMS:
		{
			entity = MedivalManAtArms(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_SKIRMISHER:
		{
			entity = MedivalSkirmisher(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_SWORDSMAN:
		{
			entity = MedivalSwordsman(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_TWOHANDED_SWORDSMAN:
		{
			entity = MedivalTwoHandedSwordsman(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_CROSSBOW_MAN:
		{
			entity = MedivalCrossbowMan(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_SPEARMEN:
		{
			entity = MedivalSpearMan(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_HANDCANNONEER:
		{
			entity = MedivalHandCannoneer(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_ELITE_SKIRMISHER:
		{
			entity = MedivalEliteSkirmisher(client, vecPos, vecAng, ally);
		}
		case RAIDMODE_BLITZKRIEG:
		{
			entity = Blitzkrieg(client, vecPos, vecAng, ally);
		}
		case MEDIVAL_PIKEMAN:
		{
			entity = MedivalPikeman(client, vecPos, vecAng, ally);
		}
		case ALT_MEDIC_SUPPERIOR_MAGE:
		{
			entity = NPC_ALT_MEDIC_SUPPERIOR_MAGE(client, vecPos, vecAng, ally);
		}
		case CITIZEN:
		{
			entity = Citizen(client, vecPos, vecAng);
		}
		default:
		{
			PrintToChatAll("Please Spawn the NPC via plugin or select which npcs you want! ID:[%i] Is not a valid npc!", Index_Of_Npc);
		}
	}
	
	return entity;
}	
public void NPCDeath(int entity)
{
	switch(i_NpcInternalId[entity])
	{
		case HEADCRAB_ZOMBIE:
		{
			HeadcrabZombie_NPCDeath(entity);
		}
		case FORTIFIED_HEADCRAB_ZOMBIE:
		{
			FortifiedHeadcrabZombie_NPCDeath(entity);
		}
		case FASTZOMBIE:
		{
			FastZombie_NPCDeath(entity);
		}
		case FORTIFIED_FASTZOMBIE:
		{
			FortifiedFastZombie_NPCDeath(entity);
		}
		case TORSOLESS_HEADCRAB_ZOMBIE:
		{
			TorsolessHeadcrabZombie_NPCDeath(entity);
		}
		case FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			FortifiedGiantPoisonZombie_NPCDeath(entity);
		}
		case POISON_ZOMBIE:
		{
			PoisonZombie_NPCDeath(entity);
		}
		case FORTIFIED_POISON_ZOMBIE:
		{
			FortifiedPoisonZombie_NPCDeath(entity);
		}
		case FATHER_GRIGORI:
		{
			FatherGrigori_NPCDeath(entity);
		}
		case COMBINE_POLICE_PISTOL:
		{
			CombinePolicePistol_NPCDeath(entity);
		}
		case COMBINE_POLICE_SMG:
		{
			CombinePoliceSmg_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_AR2:
		{
			CombineSoldierAr2_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_SHOTGUN:
		{
			CombineSoldierShotgun_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_SWORDSMAN:
		{
			CombineSwordsman_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_ELITE:
		{
			CombineElite_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			CombineGaint_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_DDT:
		{
			CombineDDT_NPCDeath(entity);
		}
		case COMBINE_SOLDIER_COLLOSS:
		{
			CombineCollos_NPCDeath(entity);
		}
		case COMBINE_OVERLORD:
		{
			CombineOverlord_NPCDeath(entity);
		}
		case SCOUT_ZOMBIE:
		{
			Scout_NPCDeath(entity);
		}
		case ENGINEER_ZOMBIE:
		{
			Engineer_NPCDeath(entity);
		}
		case HEAVY_ZOMBIE:
		{
			Heavy_NPCDeath(entity);
		}
		case FLYINGARMOR_ZOMBIE:
		{
			FlyingArmor_NPCDeath(entity);
		}
		case FLYINGARMOR_TINY_ZOMBIE:
		{
			FlyingArmorTiny_NPCDeath(entity);
		}
		case KAMIKAZE_DEMO:
		{
			Kamikaze_NPCDeath(entity);
		}
		case MEDIC_HEALER:
		{
			MedicHealer_NPCDeath(entity);
		}
		case HEAVY_ZOMBIE_GIANT:
		{
			HeavyGiant_NPCDeath(entity);
		}
		case SPY_FACESTABBER:
		{
			Spy_NPCDeath(entity);
		}
		case SOLDIER_ROCKET_ZOMBIE:
		{
			Soldier_NPCDeath(entity);
		}
		case SOLDIER_ZOMBIE_MINION:
		{
			SoldierMinion_NPCDeath(entity);
		}
		case SOLDIER_ZOMBIE_BOSS:
		{
			SoldierGiant_NPCDeath(entity);
		}
		case SPY_THIEF:
		{
			SpyThief_NPCDeath(entity);
		}
		case SPY_TRICKSTABBER:
		{
			SpyTrickstabber_NPCDeath(entity);
		}
		case SPY_HALF_CLOACKED:
		{
			SpyCloaked_NPCDeath(entity);
		}
		case SNIPER_MAIN:
		{
			SniperMain_NPCDeath(entity);
		}
		case DEMO_MAIN:
		{
			DemoMain_NPCDeath(entity);
		}
		case BATTLE_MEDIC_MAIN:
		{
			MedicMain_NPCDeath(entity);
		}
		case GIANT_PYRO_MAIN:
		{
			PyroGiant_NPCDeath(entity);
		}
		case COMBINE_DEUTSCH_RITTER:
		{
			CombineDeutsch_NPCDeath(entity);
		}
		case SPY_MAIN_BOSS:
		{
			SpyMainBoss_NPCDeath(entity);
		}
		//XENO
		case XENO_HEADCRAB_ZOMBIE:
		{
			XenoHeadcrabZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_HEADCRAB_ZOMBIE:
		{
			XenoFortifiedHeadcrabZombie_NPCDeath(entity);
		}
		case XENO_FASTZOMBIE:
		{
			XenoFastZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_FASTZOMBIE:
		{
			XenoFortifiedFastZombie_NPCDeath(entity);
		}
		case XENO_TORSOLESS_HEADCRAB_ZOMBIE:
		{
			XenoTorsolessHeadcrabZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_GIANT_POISON_ZOMBIE:
		{
			XenoFortifiedGiantPoisonZombie_NPCDeath(entity);
		}
		case XENO_POISON_ZOMBIE:
		{
			XenoPoisonZombie_NPCDeath(entity);
		}
		case XENO_FORTIFIED_POISON_ZOMBIE:
		{
			XenoFortifiedPoisonZombie_NPCDeath(entity);
		}
		case XENO_FATHER_GRIGORI:
		{
			XenoFatherGrigori_NPCDeath(entity);
		}
		case XENO_COMBINE_POLICE_PISTOL:
		{
			XenoCombinePolicePistol_NPCDeath(entity);
		}
		case XENO_COMBINE_POLICE_SMG:
		{
			XenoCombinePoliceSmg_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_AR2:
		{
			XenoCombineSoldierAr2_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_SHOTGUN:
		{
			XenoCombineSoldierShotgun_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_SWORDSMAN:
		{
			XenoCombineSwordsman_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_ELITE:
		{
			XenoCombineElite_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN:
		{
			XenoCombineGaint_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_DDT:
		{
			XenoCombineDDT_NPCDeath(entity);
		}
		case XENO_COMBINE_SOLDIER_COLLOSS:
		{
			XenoCombineCollos_NPCDeath(entity);
		}
		case XENO_COMBINE_OVERLORD:
		{
			XenoCombineOverlord_NPCDeath(entity);
		}
		case XENO_SCOUT_ZOMBIE:
		{
			XenoScout_NPCDeath(entity);
		}
		case XENO_ENGINEER_ZOMBIE:
		{
			XenoEngineer_NPCDeath(entity);
		}
		case XENO_HEAVY_ZOMBIE:
		{
			XenoHeavy_NPCDeath(entity);
		}
		case XENO_FLYINGARMOR_ZOMBIE:
		{
			XenoFlyingArmor_NPCDeath(entity);
		}
		case XENO_FLYINGARMOR_TINY_ZOMBIE:
		{
			XenoFlyingArmorTiny_NPCDeath(entity);
		}
		case XENO_KAMIKAZE_DEMO:
		{
			XenoKamikaze_NPCDeath(entity);
		}
		case XENO_MEDIC_HEALER:
		{
			XenoMedicHealer_NPCDeath(entity);
		}
		case XENO_HEAVY_ZOMBIE_GIANT:
		{
			XenoHeavyGiant_NPCDeath(entity);
		}
		case XENO_SPY_FACESTABBER:
		{
			XenoSpy_NPCDeath(entity);
		}
		case XENO_SOLDIER_ROCKET_ZOMBIE:
		{
			XenoSoldier_NPCDeath(entity);
		}
		case XENO_SOLDIER_ZOMBIE_MINION:
		{
			XenoSoldierMinion_NPCDeath(entity);
		}
		case XENO_SOLDIER_ZOMBIE_BOSS:
		{
			XenoSoldierGiant_NPCDeath(entity);
		}
		case XENO_SPY_THIEF:
		{
			XenoSpyThief_NPCDeath(entity);
		}
		case XENO_SPY_TRICKSTABBER:
		{
			XenoSpyTrickstabber_NPCDeath(entity);
		}
		case XENO_SPY_HALF_CLOACKED:
		{
			XenoSpyCloaked_NPCDeath(entity);
		}
		case XENO_SNIPER_MAIN:
		{
			XenoSniperMain_NPCDeath(entity);
		}
		case XENO_DEMO_MAIN:
		{
			XenoDemoMain_NPCDeath(entity);
		}
		case XENO_BATTLE_MEDIC_MAIN:
		{
			XenoMedicMain_NPCDeath(entity);
		}
		case XENO_GIANT_PYRO_MAIN:
		{
			XenoPyroGiant_NPCDeath(entity);
		}
		case XENO_COMBINE_DEUTSCH_RITTER:
		{
			XenoCombineDeutsch_NPCDeath(entity);
		}
		case XENO_SPY_MAIN_BOSS:
		{
			XenoSpyMainBoss_NPCDeath(entity);
		}
		case NAZI_PANZER:
		{
			NaziPanzer_NPCDeath(entity);
		}
		case BOB_THE_GOD_OF_GODS:
		{
			BobTheGod_NPCDeath(entity);
		}
		case NECRO_COMBINE:
		{
			NecroCombine_NPCDeath(entity);
		}
		case NECRO_CALCIUM:
		{
			NecroCalcium_NPCDeath(entity);
		}
		case CURED_FATHER_GRIGORI:
		{
			CuredFatherGrigori_NPCDeath(entity);
		}
		case ALT_COMBINE_MAGE:
		{
			AltCombineMage_NPCDeath(entity);
		}
		case BTD_BLOON:
		{
			Bloon_NPCDeath(entity);
		}
		case BTD_MOAB:
		{
			Moab_NPCDeath(entity);
		}
		case BTD_BFB:
		{
			Bfb_NPCDeath(entity);
		}
		case BTD_ZOMG:
		{
			Zomg_NPCDeath(entity);
		}
		case BTD_DDT:
		{
			DDT_NPCDeath(entity);
		}
		case BTD_BAD:
		{
			Bad_NPCDeath(entity);
		}
		case ALT_MEDIC_APPRENTICE_MAGE:
		{
			AltMedicApprenticeMage_NPCDeath(entity);
		}
		case SAWRUNNER:
		{
			SawRunner_NPCDeath(entity);
		}
		case RAIDMODE_TRUE_FUSION_WARRIOR:
		{
			TrueFusionWarrior_NPCDeath(entity);
		}
		case ALT_MEDIC_CHARGER:
        {
            AltMedicCharger_NPCDeath(entity);
        }
        case ALT_MEDIC_BERSERKER:
		{
			AltMedicBerseker_NPCDeath(entity);
		}
		case MEDIVAL_MILITIA:
		{
			MedivalMilitia_NPCDeath(entity);
		}
		case MEDIVAL_ARCHER:
		{
			MedivalArcher_NPCDeath(entity);
		}
		case MEDIVAL_MAN_AT_ARMS:
		{
			MedivalManAtArms_NPCDeath(entity);
		}
		case MEDIVAL_SKIRMISHER:
		{
			MedivalSkirmisher_NPCDeath(entity);
		}
		case MEDIVAL_SWORDSMAN:
		{
			MedivalSwordsman_NPCDeath(entity);
		}
		case MEDIVAL_TWOHANDED_SWORDSMAN:
		{
			MedivalTwoHandedSwordsman_NPCDeath(entity);
		}
		case MEDIVAL_CROSSBOW_MAN:
		{
			MedivalCrossbowMan_NPCDeath(entity);
		}
		case MEDIVAL_SPEARMEN:
		{
			MedivalSpearMan_NPCDeath(entity);
		}
		case MEDIVAL_HANDCANNONEER:
		{
			MedivalHandCannoneer_NPCDeath(entity);
		}
		case MEDIVAL_ELITE_SKIRMISHER:
		{
			MedivalEliteSkirmisher_NPCDeath(entity);
		}
		case RAIDMODE_BLITZKRIEG:
		{
			Blitzkrieg_NPCDeath(entity);
		}
		case MEDIVAL_PIKEMAN:
		{
			MedivalPikeman_NPCDeath(entity);
		}
		case ALT_MEDIC_SUPPERIOR_MAGE:
		{
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_NPCDeath(entity);
		}
		case CITIZEN:
		{
			Citizen_NPCDeath(entity);
		}
		default:
		{
			PrintToChatAll("This Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
		}
	}
	
	if(view_as<CClotBody>(entity).m_iCreditsOnKill)
		CurrentCash += view_as<CClotBody>(entity).m_iCreditsOnKill;
}

public void OnMapStart_NPC_Base()
{
	for (int i = 0; i < (sizeof(g_GibSound));   i++) { PrecacheSound(g_GibSound[i]);   }
	for (int i = 0; i < (sizeof(g_GibSoundMetal));   i++) { PrecacheSound(g_GibSoundMetal[i]);   }
	for (int i = 0; i < (sizeof(g_CombineSoldierStepSound));   i++) { PrecacheSound(g_CombineSoldierStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_CombineMetroStepSound));   i++) { PrecacheSound(g_CombineMetroStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_ArrowHitSoundSuccess));	   i++) { PrecacheSound(g_ArrowHitSoundSuccess[i]);	   }
	for (int i = 0; i < (sizeof(g_ArrowHitSoundMiss));	   i++) { PrecacheSound(g_ArrowHitSoundMiss[i]);	   }
	for (int i = 0; i < (sizeof(g_PanzerStepSound));   i++) { PrecacheSound(g_PanzerStepSound[i]);   }
	
	EscapeModeMap = false;
	
	char buffer[16];
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "info_target")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(!StrEqual(buffer, "zr_escapemode", false))
			continue;
		
		EscapeModeMap = true;
		break;
	}
	
	g_particleImpactMetal = PrecacheParticleSystem("bot_impact_heavy");
	g_particleImpactFlesh = PrecacheParticleSystem("blood_impact_red_01_goop");
	g_particleImpactRubber = PrecacheParticleSystem("halloween_explosion_bits");
	g_modelArrow = PrecacheModel("models/weapons/w_models/w_arrow.mdl");
	PrecacheModel(ARROW_TRAIL);
	PrecacheDecal(ARROW_TRAIL, true);
	InitNavGamedata();
	
	HeadcrabZombie_OnMapStart_NPC();
	Fortified_HeadcrabZombie_OnMapStart_NPC();
	FastZombie_OnMapStart_NPC();
	FortifiedFastZombie_OnMapStart_NPC();
	TorsolessHeadcrabZombie_OnMapStart_NPC();
	FortifiedGiantPoisonZombie_OnMapStart_NPC();
	PoisonZombie_OnMapStart_NPC();
	FortifiedPoisonZombie_OnMapStart_NPC();
	FatherGrigori_OnMapStart_NPC();
	
	Combine_Police_Pistol_OnMapStart_NPC();
	CombinePoliceSmg_OnMapStart_NPC();
	CombineSoldierAr2_OnMapStart_NPC();
	CombineSoldierShotgun_OnMapStart_NPC();
	CombineSwordsman_OnMapStart_NPC();
	CombineElite_OnMapStart_NPC();
	CombineGaint_OnMapStart_NPC();
	CombineDDT_OnMapStart_NPC();
	CombineCollos_OnMapStart_NPC();
	CombineOverlord_OnMapStart_NPC();
	
	Scout_OnMapStart_NPC();
	Engineer_OnMapStart_NPC();
	Heavy_OnMapStart_NPC();
	FlyingArmor_OnMapStart_NPC();
	FlyingArmorTiny_OnMapStart_NPC();
	Kamikaze_OnMapStart_NPC();
	MedicHealer_OnMapStart_NPC();
	HeavyGiant_OnMapStart_NPC();
	Spy_OnMapStart_NPC();
	Soldier_OnMapStart_NPC();
	SoldierMinion_OnMapStart_NPC();
	SoldierGiant_OnMapStart_NPC();
	
	SpyThief_OnMapStart_NPC();
	SpyTrickstabber_OnMapStart_NPC();
	SpyCloaked_OnMapStart_NPC();
	SniperMain_OnMapStart_NPC();
	DemoMain_OnMapStart_NPC();
	MedicMain_OnMapStart_NPC();
	PyroGiant_OnMapStart_NPC();
	CombineDeutsch_OnMapStart_NPC();
	SpyMainBoss_OnMapStart_NPC();
	/*
	XenoHeadcrabZombie_OnMapStart_NPC();
	XenoFortified_HeadcrabZombie_OnMapStart_NPC();
	XenoFastZombie_OnMapStart_NPC();
	XenoFortifiedFastZombie_OnMapStart_NPC();
	XenoTorsolessHeadcrabZombie_OnMapStart_NPC();
	XenoFortifiedGiantPoisonZombie_OnMapStart_NPC();
	XenoPoisonZombie_OnMapStart_NPC();
	XenoFortifiedPoisonZombie_OnMapStart_NPC();
	*/
	XenoFatherGrigori_OnMapStart_NPC();
	/*
	XenoCombine_Police_Pistol_OnMapStart_NPC();
	XenoCombinePoliceSmg_OnMapStart_NPC();
	XenoCombineSoldierAr2_OnMapStart_NPC();
	XenoCombineSoldierShotgun_OnMapStart_NPC();
	XenoCombineSwordsman_OnMapStart_NPC();
	XenoCombineElite_OnMapStart_NPC();
	XenoCombineGaint_OnMapStart_NPC();
	XenoCombineDDT_OnMapStart_NPC();
	XenoCombineCollos_OnMapStart_NPC();
	XenoCombineOverlord_OnMapStart_NPC();
	
	XenoScout_OnMapStart_NPC();
	XenoEngineer_OnMapStart_NPC();
	XenoHeavy_OnMapStart_NPC();
	XenoFlyingArmor_OnMapStart_NPC();
	XenoFlyingArmorTiny_OnMapStart_NPC();
	XenoKamikaze_OnMapStart_NPC();
	MedicHealer_OnMapStart_NPC();
	XenoHeavyGiant_OnMapStart_NPC();
	XenoSpy_OnMapStart_NPC();
	XenoSoldier_OnMapStart_NPC();
	XenoSoldierMinion_OnMapStart_NPC();
	XenoSoldierGiant_OnMapStart_NPC();
	*/
	
	/*
	XenoSpyThief_OnMapStart_NPC();
	XenoSpyTrickstabber_OnMapStart_NPC();
	XenoSpyCloaked_OnMapStart_NPC();
	XenoSniperMain_OnMapStart_NPC();
	XenoDemoMain_OnMapStart_NPC();
	XenoMedicMain_OnMapStart_NPC();
	XenoPyroGiant_OnMapStart_NPC();
	XenoCombineDeutsch_OnMapStart_NPC();
	XenoSpyMainBoss_OnMapStart_NPC();
	*/
	NaziPanzer_OnMapStart_NPC();
	BobTheGod_OnMapStart_NPC();
	NecroCombine_OnMapStart_NPC();
	NecroCalcium_OnMapStart_NPC();
	CuredFatherGrigori_OnMapStart_NPC();
	
	Bloon_MapStart();
	Moab_MapStart();
	Bfb_MapStart();
	Zomg_MapStart();
	DDT_MapStart();
	Bad_MapStart();
	AltMedicApprenticeMage_OnMapStart_NPC();
	SawRunner_OnMapStart_NPC();
	TrueFusionWarrior_OnMapStart();
	AltMedicCharger_OnMapStart_NPC();
	AltMedicBerseker_OnMapStart_NPC();
	
	MedivalMilitia_OnMapStart_NPC();
	MedivalArcher_OnMapStart_NPC();
	MedivalManAtArms_OnMapStart_NPC();
	MedivalSkirmisher_OnMapStart_NPC();
	MedivalSwordsman_OnMapStart_NPC();
	MedivalTwoHandedSwordsman_OnMapStart_NPC();
	MedivalCrossbowMan_OnMapStart_NPC();
	MedivalSpearMan_OnMapStart_NPC();
	MedivalHandCannoneer_OnMapStart_NPC();
	MedivalEliteSkirmisher_OnMapStart_NPC();
	Blitzkrieg_OnMapStart();
	MedivalPikeman_OnMapStart_NPC();
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnMapStart_NPC();
	Citizen_OnMapStart();
}


native void ZR_ApplyKillEffects(int npc);
native int ZR_GetWaveCount();

StringMap HookIdMap;
StringMap HookListMap;

//Handle g_hSDKIsClimbingOrJumping;
//SDKCalls
Handle g_hUpdateCollisionBox;
Handle g_hMyNextBotPointer;
Handle g_hGetLocomotionInterface;
Handle g_hGetIntentionInterface;
Handle g_hGetBodyInterface;
//Handle g_hGetVisionInterface;
//Handle g_hGetPrimaryKnownThreat;
//Handle g_hAddKnownEntity;
//Handle g_hGetKnownEntity;
//Handle g_hGetKnown;
//Handle g_hUpdatePosition;
//Handle g_hUpdateVisibilityStatus;
Handle g_hRun;
Handle g_hApproach;
Handle g_hFaceTowards
Handle g_hGetVelocity;
Handle g_hSetVelocity;
Handle g_hStudioFrameAdvance;
Handle g_hJump;
Handle g_hSDKIsOnGround;
//DynamicHook g_hAlwaysTransmit;
// Handle g_hJumpAcrossGap;
Handle g_hDispatchAnimEvents;
Handle g_hGetMaxAcceleration;
Handle g_hGetGroundSpeed;
Handle g_hGetVectors;
Handle g_hGetGroundMotionVector;
Handle g_hLookupPoseParameter;
Handle g_hSetPoseParameter;
Handle g_hGetPoseParameter;
Handle g_hLookupActivity;
Handle g_hSDKWorldSpaceCenter;
Handle g_hStudio_FindAttachment;
Handle g_hGetAttachment;
Handle g_hAddGesture;
Handle g_hRestartGesture;
Handle g_hIsPlayingGesture;
Handle g_hFindBodygroupByName;
Handle g_hSetBodyGroup;
Handle g_hSelectWeightedSequence;
Handle g_hResetSequenceInfo;

//Death
Handle g_hNextBotCombatCharacter_Event_Killed;
Handle g_hCBaseCombatCharacter_Event_Killed;

//PluginBot SDKCalls
Handle g_hGetEntity;
Handle g_hGetBot;

//DHooks
//Handle g_hGetCurrencyValue;
Handle g_hEvent_Killed;
Handle g_hEvent_Ragdoll;
Handle g_hHandleAnimEvent;
Handle g_hGetFrictionSideways;
Handle g_hGetStepHeight;
Handle g_hGetGravity;
Handle g_hGetRunSpeed;
Handle g_hGetGroundNormal;
Handle g_hShouldCollideWithAlly;
Handle g_hShouldCollideWithAllyInvince;
Handle g_hShouldCollideWithAllyEnemy;
Handle g_hShouldCollideWithAllyEnemyIngoreBuilding;
Handle g_hGetSolidMask;
Handle g_hStartActivity;
Handle g_hGetActivity;
Handle g_hIsActivity;
Handle g_hGetHullWidth;
Handle g_hGetHullHeight;
Handle g_hGetStandHullHeight;
Handle g_hGetHullWidthGiant;
Handle g_hGetHullHeightGiant;
Handle g_hGetStandHullHeightGiant;

//NavAreas
Address TheNavAreas;
Address navarea_count;

public void NPC_Base_OnEntityDestroyed(int entity)
{
	//	OnEntityDestroyed_NPC(entity);
	RequestFrame(DHookCleanIds);
}

public void DHookCleanIds()
{
	StringMapSnapshot snap = HookIdMap.Snapshot();
	if(snap)
	{
		char buffer[12];
		int length2 = snap.Length;
		for(int a; a<length2; a++)
		{
			snap.GetKey(a, buffer, sizeof(buffer));
			if(EntRefToEntIndex(StringToInt(buffer)) <= MaxClients)
			{
				ArrayList list;
				
				HookIdMap.GetValue(buffer, list);
				HookIdMap.Remove(buffer);
				
				if(list)
				{
					/*
					static const char HookName[][] =
					{
						"g_hGetStepHeight",
						"g_hGetGravity",
						"g_hShouldCollideWith",
						"g_hGetMaxAcceleration",
						"g_hGetFrictionSideways",
						"g_hGetRunSpeed",
						"g_hGetGroundNormal",
						"g_hGetHullWidth",
						"g_hGetHullHeight",
						"g_hGetStandHullHeight",
						"g_hGetActivity",
						"g_hIsActivity",
						"g_hGetSolidMask",
						"g_hStartActivity"
					};
					*/
					int length = list.Length;
					for(int i; i<length; i++)
					{
						int id2 = list.Get(i);
						if(id2 != INVALID_HOOK_ID)
						{
							int value = 1;
							IntToString(id2, buffer, sizeof(buffer));
							if(HookListMap.GetValue(buffer, value) && value > 1)
							{
								HookListMap.SetValue(buffer, value-1);
							//	LogError("Raw hook %d removed dupe (%s %d)", id2, HookName[i], i);
							}
							else
							{
								if(!DHookRemoveHookID(id2))
								{
								//		LogError("Raw hook %d somehow was removed (%s %d)", id2, HookName[i], i);	
								}
								
								HookListMap.Remove(buffer);
							}
						}
					}
					
					delete list;
				}
			}
		}
		delete snap;
	}
}


methodmap CClotBody
{
	public CClotBody(float vecPos[3], float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool Ally = false,
						bool Ally_Invince = false,
						bool isGiant = false,
						bool IgnoreBuildings = false,
						bool IsRaidBoss = false)
	{
		int npc = CreateEntityByName("base_boss");
		DispatchKeyValueVector(npc, "origin",	 vecPos);
		DispatchKeyValueVector(npc, "angles",	 vecAng);
		DispatchKeyValue(npc,	   "model",	  model);
		DispatchKeyValue(npc,	   "modelscale", modelscale);
		DispatchKeyValue(npc,	   "health",	 health);
		
		if(Ally)
		{
			if(Ally_Invince)
			{
				b_ThisEntityIgnored[npc] = true;
			}
			SetEntProp(npc, Prop_Send, "m_iTeamNum", TFTeam_Red);
		}
		else
		{
			SetEntProp(npc, Prop_Send, "m_iTeamNum", TFTeam_Blue);
		}
		b_bThisNpcGotDefaultStats_INVERTED[npc] = true;
		
		DispatchSpawn(npc); //Do this at the end :)
		
		if(Ally)
		{
			SetEntityCollisionGroup(npc, 24);
		}
		
		//Enable Harder zombies once in freeplay.
		if(!EscapeModeForNpc)
		{
			if(Waves_InFreeplay())
			{
				EscapeModeForNpc = true;
			}
		}
		
		Address pNB =		 SDKCall(g_hMyNextBotPointer,	   npc);
		Address pLocomotion = SDKCall(g_hGetLocomotionInterface, pNB);
		if(pLocomotion < view_as<Address>(0x10000))
			PrintToServer("Invalid pLocomotion %x", pLocomotion);
		
		ArrayList list = new ArrayList();
//		g_hAlwaysTransmit.HookEntity(Hook_Pre, npc, DHook_AlwaysTransmit);	
		
		list.Push(DHookRaw(g_hGetStepHeight,	   true, pLocomotion));
		list.Push(DHookRaw(g_hGetGravity,		  true, pLocomotion));
		
		
		if(!Ally)
		{
			NPC_AddToArray(npc);
			if(IgnoreBuildings || IsValidEntity(EntRefToEntIndex(RaidBossActive))) //During an active raidboss, make sure that they ignore barricades
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemyIngoreBuilding,   false, pLocomotion);
			}
			else
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemy,   false, pLocomotion);
			}
		}
		else
		{
			if(Ally_Invince)
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyInvince,   false, pLocomotion);
			}
			else
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAlly,   false, pLocomotion);
			}
		}
		
		
		list.Push(h_NpcCollissionHookType[npc]);
		list.Push(DHookRaw(g_hGetMaxAcceleration,  true, pLocomotion));
		list.Push(DHookRaw(g_hGetFrictionSideways, true, pLocomotion));
		list.Push(DHookRaw(g_hGetRunSpeed,		 true, pLocomotion));
		
		//if(bGroundNormal)
		list.Push(DHookRaw(g_hGetGroundNormal, true, pLocomotion));
		
		//TOP GET AUTO DELETED
		
		//BOTTOM DO NOT, BEACUSE ITS TO AN ADRESS?
		Address pBody = SDKCall(g_hGetBodyInterface, pNB);
		//if(pBody < view_as<Address>(0x10000))
		//	ThrowError("Invalid pBody %x", pBody); //what the fuck. This shit gets called 90% of the time.......................
		
		if(!isGiant)
		{
			list.Push(DHookRaw(g_hGetHullWidth,		true, pBody));
			list.Push(DHookRaw(g_hGetHullHeight,	   true, pBody));
			list.Push(DHookRaw(g_hGetStandHullHeight,  true, pBody));
		}
		else
		{
			b_IsGiant[npc] = true;
			list.Push(DHookRaw(g_hGetHullWidthGiant,		true, pBody));
			list.Push(DHookRaw(g_hGetHullHeightGiant,	   true, pBody));
			list.Push(DHookRaw(g_hGetStandHullHeightGiant,  true, pBody));			
		}
		list.Push(DHookRaw(g_hGetActivity,		 true, pBody));
		list.Push(DHookRaw(g_hIsActivity,		  true, pBody));

		//Collide with the correct stuff
		list.Push(DHookRaw(g_hGetSolidMask,		true, pBody));
		
		//Allow jumping
	//	list.Push(DHookRaw(g_hStartActivity,		true, pBody));
		
		//Don't drop money.
		//DHookEntity(g_hGetCurrencyValue, true, npc);
		
		char buffer[12];
		int id = list.Length;
		for(int i; i<id; i++)
		{
			int hook = list.Get(i);
			IntToString(hook, buffer, sizeof(buffer));
			int value = 0;
			if(HookListMap.GetValue(buffer, value))
			{
		//		LogError("Duplicate raw hook found %d", hook); Yeah we get it, just dont do this.		
			}
			
			HookListMap.SetValue(buffer, value+1);
		}
		
		IntToString(EntIndexToEntRef(npc), buffer, sizeof(buffer));
		HookIdMap.SetValue(buffer, list);
		
		//Ragdoll, hopefully
		DHookEntity(g_hEvent_Killed,	 false, npc);
		
		//Animevents 
		DHookEntity(g_hHandleAnimEvent,  true, npc);
		DHookEntity(g_hEvent_Ragdoll,  false, npc);
		
		//so map makers can choose between NPCs and Clients
		SetEntityFlags(npc, FL_NPC);
		
		//Don't ResolvePlayerCollisions.
		SetEntData(npc, FindSendPropInfo("CTFBaseBoss", "m_lastHealthPercentage") + 28, false, 4, true);
		
		SetEntProp(npc, Prop_Data, "m_nSolidType", 2); 
		
		
		
		//Don't bleed.
		SetEntProp(npc, Prop_Data, "m_bloodColor", -1); //Don't bleed
		
		b_BoundingBoxVariant[npc] = 0; //This will tell lag compensation what to revert to once the calculations are done.
		static float m_vecMaxs[3];
		static float m_vecMins[3];
		if(isGiant)
		{
			b_BoundingBoxVariant[npc] = 1;
			m_vecMaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
			m_vecMins = view_as<float>( { -30.0, -30.0, 0.0 } );	
		}			
		else
		{
			m_vecMaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
			m_vecMins = view_as<float>( { -24.0, -24.0, 0.0 } );		
		}
		
		//Fix collisions
		SetEntPropVector(npc, Prop_Send, "m_vecMaxs", m_vecMaxs);
		SetEntPropVector(npc, Prop_Data, "m_vecMaxs", m_vecMaxs);
		
		SetEntPropVector(npc, Prop_Send, "m_vecMins", m_vecMins);
		SetEntPropVector(npc, Prop_Data, "m_vecMins", m_vecMins);
		
		//Fixed wierd clientside issue or something
		static float m_vecMaxsNothing[3];
		static float m_vecMinsNothing[3];
		m_vecMaxsNothing = view_as<float>( { 1.0, 1.0, 2.0 } );
		m_vecMinsNothing = view_as<float>( { -1.0, -1.0, 0.0 } );		
		SetEntPropVector(npc, Prop_Send, "m_vecMaxsPreScaled", m_vecMaxsNothing);
		SetEntPropVector(npc, Prop_Data, "m_vecMaxsPreScaled", m_vecMaxsNothing);
		SetEntPropVector(npc, Prop_Send, "m_vecMinsPreScaled", m_vecMinsNothing);
		SetEntPropVector(npc, Prop_Data, "m_vecMinsPreScaled", m_vecMinsNothing);
		
		if(Ally)
		{
			CClotBody npcstats = view_as<CClotBody>(npc);
			npcstats.m_iTeamGlow = TF2_CreateGlow(npc);
			
			SetVariantColor(view_as<int>({184, 56, 59, 200}));
			AcceptEntityInput(npcstats.m_iTeamGlow, "SetGlowColor");
		}
		
		SDKHook(npc, SDKHook_OnTakeDamage, NPC_OnTakeDamage_Base);
		SDKHook(npc, SDKHook_Think, Check_If_Stuck);
		SDKHook(npc, SDKHook_SetTransmit, SDKHook_Settransmit_Baseboss);
		
		HeadcrabZombie CreatePathfinderIndex = view_as<HeadcrabZombie>(npc);
		
		if(IsRaidBoss)
			CreatePathfinderIndex.CreatePather(16.0, CreatePathfinderIndex.GetMaxJumpHeight(), 1000.0, CreatePathfinderIndex.GetSolidMask(), 100.0, 0.1, 1.75); //Global.
		else
			CreatePathfinderIndex.CreatePather(16.0, CreatePathfinderIndex.GetMaxJumpHeight(), 1000.0, CreatePathfinderIndex.GetSolidMask(), 100.0, 0.29, 1.75); //Global.
		
		return view_as<CClotBody>(npc);
	}
		property int index 
	{ 
		public get() { return view_as<int>(this); } 
	}
	public void PlayGibSound() { //ehehee this sound is funny 
		int sound = GetRandomInt(0, sizeof(g_GibSound) - 1);
	
		EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
		EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
		EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	}
	public void PlayGibSoundMetal() { //ehehee this sound is funny 
		int sound = GetRandomInt(0, sizeof(g_GibSoundMetal) - 1);
	
		EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
		EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
		EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	}
	public void PlayStepSound(const char[] sound, float volume = 1.0, int Npc_Type = 1)
	{
		switch(Npc_Type)
		{
			case 1: //normal
			{
				EmitSoundToAll(sound, this.index, SNDCHAN_AUTO, 80, _, volume, 100, _);
			}
			case 2: //giant
			{
				EmitSoundToAll(sound, this.index, SNDCHAN_AUTO, 80, _, volume, 80, _);
			}
			
		}
	//	PrintToServer("%i PlayStepSound(\"%s\")", this.index, sound);
	}
	
	property int m_iOverlordComboAttack
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iTargetAlly
	{
		public get()							{ return i_TargetAlly[this.index]; }
		public set(int TempValueForProperty) 	{ i_TargetAlly[this.index] = TempValueForProperty; }
	}
	property bool m_bGetClosestTargetTimeAlly
	{
		public get()							{ return b_GetClosestTargetTimeAlly[this.index]; }
		public set(bool TempValueForProperty) 	{ b_GetClosestTargetTimeAlly[this.index] = TempValueForProperty; }
	}
	property bool m_bWasSadAlready
	{
		public get()							{ return b_WasSadAlready[this.index]; }
		public set(bool TempValueForProperty) 	{ b_WasSadAlready[this.index] = TempValueForProperty; }
	}
	property int m_iChanged_WalkCycle
	{
		public get()							{ return i_Changed_WalkCycle[this.index]; }
		public set(int TempValueForProperty) 	{ i_Changed_WalkCycle[this.index] = TempValueForProperty; }
	}
	property float m_flDuration
	{
		public get()							{ return fl_Duration[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Duration[this.index] = TempValueForProperty; }
	}
	property float m_flExtraDamage
	{
		public get()							{ return fl_ExtraDamage[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ExtraDamage[this.index] = TempValueForProperty; }
	}
	property float m_flHurtie
	{
		public get()							{ return fl_Hurtie[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Hurtie[this.index] = TempValueForProperty; }
	}
	property float m_flheal_cooldown
	{
		public get()							{ return fl_heal_cooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_heal_cooldown[this.index] = TempValueForProperty; }
	}
	property float m_flidle_talk
	{
		public get()							{ return fl_idle_talk[this.index]; }
		public set(float TempValueForProperty) 	{ fl_idle_talk[this.index] = TempValueForProperty; }
	}
	property float m_flDoingSpecial
	{
		public get()							{ return fl_DoingSpecial[this.index]; }
		public set(float TempValueForProperty) 	{ fl_DoingSpecial[this.index] = TempValueForProperty; }
	}
	property float m_flComeToMe
	{
		public get()							{ return fl_ComeToMe[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ComeToMe[this.index] = TempValueForProperty; }
	}
	property int m_iMedkitAnnoyance
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property bool m_b_stand_still
	{
		public get()							{ return b_stand_still[this.index]; }
		public set(bool TempValueForProperty) 	{ b_stand_still[this.index] = TempValueForProperty; }
	}
	
	
	property bool m_b_follow
	{
		public get()							{ return b_follow[this.index]; }
		public set(bool TempValueForProperty) 	{ b_follow[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay_walk
	{
		public get()							{ return b_movedelay_walk[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_walk[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay_run
	{
		public get()							{ return b_movedelay_run[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_run[this.index] = TempValueForProperty; }
	}
	property bool m_bIsFriendly
	{
		public get()							{ return b_IsFriendly[this.index]; }
		public set(bool TempValueForProperty) 	{ b_IsFriendly[this.index] = TempValueForProperty; }
	}
	property bool m_bReloaded
	{
		public get()							{ return b_Reloaded[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Reloaded[this.index] = TempValueForProperty; }
	}
	
	property float m_flFollowing_Master_Now
	{
		public get()							{ return fl_Following_Master_Now[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Following_Master_Now[this.index] = TempValueForProperty; }
	}
	property float m_flHookDamageTaken
	{
		public get()							{ return fl_HookDamageTaken[this.index]; }
		public set(float TempValueForProperty) 	{ fl_HookDamageTaken[this.index] = TempValueForProperty; }
	}
	property float m_flGrappleCooldown
	{
		public get()							{ return fl_GrappleCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GrappleCooldown[this.index] = TempValueForProperty; }
	}
	property float m_flStandStill
	{
		public get()							{ return fl_StandStill[this.index]; }
		public set(float TempValueForProperty) 	{ fl_StandStill[this.index] = TempValueForProperty; }
	}
	property float m_flNextFlameSound
	{
		public get()							{ return fl_NextFlameSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextFlameSound[this.index] = TempValueForProperty; }
	}
	property float m_flFlamerActive
	{
		public get()							{ return fl_FlamerActive[this.index]; }
		public set(float TempValueForProperty) 	{ fl_FlamerActive[this.index] = TempValueForProperty; }
	}
	property float m_flWaveScale
	{
		public get()							{ return fl_WaveScale[this.index]; }
		public set(float TempValueForProperty) 	{ fl_WaveScale[this.index] = TempValueForProperty; }
	}
	
	property bool m_bDoSpawnGesture
	{
		public get()							{ return b_DoSpawnGesture[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DoSpawnGesture[this.index] = TempValueForProperty; }
	}
	property bool m_bLostHalfHealth
	{
		public get()							{ return b_LostHalfHealth[this.index]; }
		public set(bool TempValueForProperty) 	{ b_LostHalfHealth[this.index] = TempValueForProperty; }
	}
	property bool m_bLostHalfHealthAnim
	{
		public get()							{ return b_LostHalfHealthAnim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_LostHalfHealthAnim[this.index] = TempValueForProperty; }
	}
	property bool m_bDuringHighFlight
	{
		public get()							{ return b_DuringHighFlight[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DuringHighFlight[this.index] = TempValueForProperty; }
	}
	property bool m_bDuringHook
	{
		public get()							{ return b_DuringHook[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DuringHook[this.index] = TempValueForProperty; }
	}
	property bool m_bGrabbedSomeone
	{
		public get()							{ return b_GrabbedSomeone[this.index]; }
		public set(bool TempValueForProperty) 	{ b_GrabbedSomeone[this.index] = TempValueForProperty; }
	}
	property bool m_bUseDefaultAnim
	{
		public get()							{ return b_UseDefaultAnim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_UseDefaultAnim[this.index] = TempValueForProperty; }
	}
	property bool m_bFlamerToggled
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
	}
	property bool m_bCamo
	{
		public get()							{ return b_IsCamoNPC[this.index]; }
		public set(bool TempValueForProperty) 	{ b_IsCamoNPC[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay_gun
	{
		public get()							{ return b_movedelay_gun[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_gun[this.index] = TempValueForProperty; }
	}
	property bool m_flHalf_Life_Regen
	{
		public get()							{ return b_Half_Life_Regen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Half_Life_Regen[this.index] = TempValueForProperty; }
	}
	property float m_flDead_Ringer_Invis
	{
		public get()							{ return fl_Dead_Ringer_Invis[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Dead_Ringer_Invis[this.index] = TempValueForProperty; }
	}
	property float m_flDead_Ringer
	{
		public get()							{ return fl_Dead_Ringer[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Dead_Ringer[this.index] = TempValueForProperty; }
	}
	property bool m_flDead_Ringer_Invis_bool
	{
		public get()							{ return b_Dead_Ringer_Invis_bool[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Dead_Ringer_Invis_bool[this.index] = TempValueForProperty; }
	}
	property int m_iAttacksTillMegahit
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property float m_flCharge_Duration
	{
		public get()							{ return fl_Charge_Duration[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_Duration[this.index] = TempValueForProperty; }
	}
	property float m_flCharge_delay
	{
		public get()							{ return fl_Charge_delay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_delay[this.index] = TempValueForProperty; }
	}
	property int g_TimesSummoned
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flAttackHappens_2
	{
		public get()							{ return fl_AttackHappens_2[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappens_2[this.index] = TempValueForProperty; }
	}
	property bool m_bFUCKYOU
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	property bool m_bFUCKYOU_move_anim
	{
		public get()							{ return b_FUCKYOU_move_anim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU_move_anim[this.index] = TempValueForProperty; }
	}
	property bool Healing
	{
		public get()							{ return b_healing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_healing[this.index] = TempValueForProperty; }
	}
	property bool m_bnew_target
	{
		public get()							{ return b_new_target[this.index]; }
		public set(bool TempValueForProperty) 	{ b_new_target[this.index] = TempValueForProperty; }
	}
	property float m_flReloadIn
	{
		public get()							{ return fl_ReloadIn[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ReloadIn[this.index] = TempValueForProperty; }
	}
	property float m_flAngerDelay
	{
		public get()							{ return fl_AngerDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AngerDelay[this.index] = TempValueForProperty; }
	}
	property float m_flmovedelay
	{
		public get()							{ return fl_movedelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_movedelay[this.index] = TempValueForProperty; }
	}
	property float m_flNextChargeSpecialAttack
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedSpecialAttack
	{
		public get()							{ return fl_NextRangedSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float m_flRangedSpecialDelay
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property bool m_fbRangedSpecialOn
	{
		public get()							{ return b_RangedSpecialOn[this.index]; }
		public set(bool TempValueForProperty) 	{ b_RangedSpecialOn[this.index] = TempValueForProperty; }
	}
	property float m_flNextIdleSound
	{
		public get()							{ return fl_NextIdleSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextIdleSound[this.index] = TempValueForProperty; }
	}
	property float m_flInJump
	{
		public get()							{ return fl_InJump[this.index]; }
		public set(float TempValueForProperty) 	{ fl_InJump[this.index] = TempValueForProperty; }
	}
	property bool m_bDissapearOnDeath
	{
		public get()							{ return b_DissapearOnDeath[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DissapearOnDeath[this.index] = TempValueForProperty; }
	}

	property bool m_bIsGiant
	{
		public get()							{ return b_IsGiant[this.index]; }
		public set(bool TempValueForProperty) 	{ b_IsGiant[this.index] = TempValueForProperty; }
	}
	property bool Anger
	{
		public get()							{ return b_Anger[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Anger[this.index] = TempValueForProperty; }
	}
	property bool m_bPathing
	{
		public get()							{ return b_Pathing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Pathing[this.index] = TempValueForProperty; }
	}

	property bool m_bThisEntityIgnored
	{
		public get()							{ return b_ThisEntityIgnored[this.index]; }
		public set(bool TempValueForProperty) 	{ b_ThisEntityIgnored[this.index] = TempValueForProperty; }
	}
	
	property bool m_bJumping
	{
		public get()							{ return b_Pathing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Pathing[this.index] = TempValueForProperty; }
	}
	property float m_flDoingAnimation
	{
		public get()							{ return fl_DoingAnimation[this.index]; }
		public set(float TempValueForProperty) 	{ fl_DoingAnimation[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedBarrage_Spam
	{
		public get()							{ return fl_NextRangedBarrage_Spam[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Spam[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedBarrage_Singular
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property bool m_bNextRangedBarrage_OnGoing
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}

	property float m_flJumpStartTime
	{
		public get()							{ return fl_JumpStartTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_JumpStartTime[this.index] = TempValueForProperty; }
	}
	property float m_flNextTeleport
	{
		public get()							{ return fl_NextTeleport[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextTeleport[this.index] = TempValueForProperty; }
	}
	property float m_flJumpCooldown
	{
		public get()							{ return fl_JumpCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_JumpCooldown[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextThinkTime
	{
		public get()							{ return fl_NextThinkTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextThinkTime[this.index] = TempValueForProperty; }
	}
	property float m_flNextDelayTime
	{
		public get()							{ return fl_NextDelayTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextDelayTime[this.index] = TempValueForProperty; }
	}

	property float m_flNextMeleeAttack
	{
		public get()							{ return fl_NextMeleeAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextMeleeAttack[this.index] = TempValueForProperty; }
	}
	property float m_flAttackHappens
	{
		public get()							{ return fl_AttackHappensMinimum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMinimum[this.index] = TempValueForProperty; }
	}
	property float m_flAttackHappens_bullshit
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool m_flAttackHappenswillhappen
	{
		public get()							{ return b_AttackHappenswillhappen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_AttackHappenswillhappen[this.index] = TempValueForProperty; }
	}
	
	
	property float m_flMeleeArmor
	{
		public get()							{ return fl_MeleeArmor[this.index]; }
		public set(float TempValueForProperty) 	{ fl_MeleeArmor[this.index] = TempValueForProperty; }
	}
	property float m_flRangedArmor
	{
		public get()							{ return fl_RangedArmor[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedArmor[this.index] = TempValueForProperty; }
	}
	
	property float m_flSpeed
	{
		public get()							{ return fl_Speed[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Speed[this.index] = TempValueForProperty; }
	}
	property int m_iTarget
	{
		public get()							{ return i_Target[this.index]; }
		public set(int TempValueForProperty) 	{ i_Target[this.index] = TempValueForProperty; }
	}
	property int m_iBleedType
	{
		public get()							{ return i_BleedType[this.index]; }
		public set(int TempValueForProperty) 	{ i_BleedType[this.index] = TempValueForProperty; }
	}
	property int m_iState
	{
		public get()							{ return i_State[this.index]; }
		public set(int TempValueForProperty) 	{ i_State[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay
	{
		public get()							{ return b_movedelay[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay[this.index] = TempValueForProperty; }
	}
	property int m_iStepNoiseType
	{
		public get()							{ return i_StepNoiseType[this.index]; }
		public set(int TempValueForProperty) 	{ i_StepNoiseType[this.index] = TempValueForProperty; }
	}
	property int m_iNpcStepVariation
	{
		public get()							{ return i_NpcStepVariation[this.index]; }
		public set(int TempValueForProperty) 	{ i_NpcStepVariation[this.index] = TempValueForProperty; }
	}
	property int m_iCreditsOnKill
	{
		public get()							{ return i_CreditsOnKill[this.index]; }
		public set(int TempValueForProperty) 	{ i_CreditsOnKill[this.index] = TempValueForProperty; }
	}
	
	property float m_flGetClosestTargetTime
	{
		public get()							{ return fl_GetClosestTargetTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GetClosestTargetTime[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedAttack
	{
		public get()							{ return fl_NextRangedAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttack[this.index] = TempValueForProperty; }
	}
	property int m_iAttacksTillReload
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	property float m_flNextHurtSound
	{
		public get()							{ return fl_NextHurtSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextHurtSound[this.index] = TempValueForProperty; }
	}
	property float m_flHeadshotCooldown
	{
		public get()							{ return fl_HeadshotCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_HeadshotCooldown[this.index] = TempValueForProperty; }
	}
	property bool m_blPlayHurtAnimation
	{
		public get()							{ return b_PlayHurtAnimation[this.index]; }
		public set(bool TempValueForProperty) 	{ b_PlayHurtAnimation[this.index] = TempValueForProperty; }
	}
	property bool m_fbGunout
	{
		public get()							{ return b_Gunout[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Gunout[this.index] = TempValueForProperty; }
	}
	property bool bCantCollidie
	{
		public get()							{ return b_CantCollidie[this.index]; }
		public set(bool TempValueForProperty) 	{ b_CantCollidie[this.index] = TempValueForProperty; }
	}
	property bool bCantCollidieAlly
	{
		public get()							{ return b_CantCollidieAlly[this.index]; }
		public set(bool TempValueForProperty) 	{ b_CantCollidieAlly[this.index] = TempValueForProperty; }
	}
	property bool bBuildingIsStacked
	{
		public get()							{ return b_BuildingIsStacked[this.index]; }
		public set(bool TempValueForProperty) 	{ b_BuildingIsStacked[this.index] = TempValueForProperty; }
	}
	property bool bBuildingIsPlaced
	{
		public get()							{ return b_bBuildingIsPlaced[this.index]; }
		public set(bool TempValueForProperty) 	{ b_bBuildingIsPlaced[this.index] = TempValueForProperty; }
	}
	property bool bXenoInfectedSpecialHurt
	{
		public get()							{ return b_XenoInfectedSpecialHurt[this.index]; }
		public set(bool TempValueForProperty) 	{ b_XenoInfectedSpecialHurt[this.index] = TempValueForProperty; }
	}
	property float flXenoInfectedSpecialHurtTime
	{
		public get()							{ return fl_XenoInfectedSpecialHurtTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_XenoInfectedSpecialHurtTime[this.index] = TempValueForProperty; }
	}
	property bool m_bThisNpcIsABoss
	{
		public get()							{ return b_thisNpcIsABoss[this.index]; }
		public set(bool TempValueForProperty) 	{ b_thisNpcIsABoss[this.index] = TempValueForProperty; }
	}
	
	property bool m_bThisNpcGotDefaultStats_INVERTED //This is the only one, reasoning is that is that i kinda need to check globablly if any base_boss spawned outside of this plugin and apply stuff accordingly.
	{
		public get()							{ return b_bThisNpcGotDefaultStats_INVERTED[this.index]; }
		public set(bool TempValueForProperty) 	{ b_bThisNpcGotDefaultStats_INVERTED[this.index] = TempValueForProperty; }
	}
	property bool m_bInSafeZone
	{
		public get()							{ return view_as<bool>(i_InSafeZone[this.index]); }
	}
	property float m_fHighTeslarDebuff 
	{
		public get()							{ return f_HighTeslarDebuff[this.index]; }
		public set(float TempValueForProperty) 	{ f_HighTeslarDebuff[this.index] = TempValueForProperty; }
	}
	property float m_fLowTeslarDebuff 
	{
		public get()							{ return f_LowTeslarDebuff[this.index]; }
		public set(float TempValueForProperty) 	{ f_LowTeslarDebuff[this.index] = TempValueForProperty; }
	}
	
	property float mf_WidowsWineDebuff 
	{
		public get()							{ return f_WidowsWineDebuff[this.index]; }
		public set(float TempValueForProperty) 	{ f_WidowsWineDebuff[this.index] = TempValueForProperty; }
	}

	public float GetRunSpeed()//For the future incase we want to alter it easier
	{
		float speed_for_return;
		
		speed_for_return = this.m_flSpeed;
		
		float Gametime = GetGameTime();
		
		bool Is_Boss = true;
		if(!this.m_bThisNpcIsABoss && EntRefToEntIndex(RaidBossActive) != this.index)
		{
			Is_Boss = false;
		}
		
		if(!Is_Boss) //Make sure that any slow debuffs dont affect these.
		{
			if(this.m_fHighTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.65;
			}
			else if(this.m_fLowTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.75;
			}
		}
		else
		{
			if(this.m_fHighTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.9;
			}
			else if(this.m_fLowTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.95;
			}			
			
		}
		if(this.mf_WidowsWineDebuff > Gametime)
		{
			float slowdown_amount = this.mf_WidowsWineDebuff - Gametime;
			
			float max_amount = FL_WIDOWS_WINE_DURATION;
			
			slowdown_amount = slowdown_amount / max_amount;
			
			slowdown_amount -= 1.0;
			
			slowdown_amount *= -1.0;
			
			if(!Is_Boss)
			{
				if(slowdown_amount < 0.1)
				{
					slowdown_amount = 0.1;
				}
				else if(slowdown_amount > 1.0)
				{
					slowdown_amount = 1.0;
				}	
			}
			else
			{
				if(slowdown_amount < 0.8)
				{
					slowdown_amount = 0.8;
				}
				else if(slowdown_amount > 1.0)
				{
					slowdown_amount = 1.0;
				}	
			}
			speed_for_return *= slowdown_amount;
		}
		return speed_for_return; 
	}
	public void m_vecLastValidPos(float pos[3], bool set)
	{
		if(set)
		{
			f3_VecTeleportBackSave[this.index][0] = pos[0];
			f3_VecTeleportBackSave[this.index][1] = pos[1];
			f3_VecTeleportBackSave[this.index][2] = pos[2];
		}
		else
		{
			pos[0] = f3_VecTeleportBackSave[this.index][0];
			pos[1] = f3_VecTeleportBackSave[this.index][1];
			pos[2] = f3_VecTeleportBackSave[this.index][2];
		}
	}
	
	public void m_vecLastValidPosJump(float pos[3], bool set)
	{
		if(set)
		{
			f3_VecTeleportBackSaveJump[this.index][0] = pos[0];
			f3_VecTeleportBackSaveJump[this.index][1] = pos[1];
			f3_VecTeleportBackSaveJump[this.index][2] = pos[2];
		}
		else
		{
			pos[0] = f3_VecTeleportBackSaveJump[this.index][0];
			pos[1] = f3_VecTeleportBackSaveJump[this.index][1];
			pos[2] = f3_VecTeleportBackSaveJump[this.index][2];
		}
	}
	public void m_vecpunchforce(float pos[3], bool set)
	{
		if(set)
		{
			f3_VecPunchForce[this.index][0] = pos[0];
			f3_VecPunchForce[this.index][1] = pos[1];
			f3_VecPunchForce[this.index][2] = pos[2];
		}
		else
		{
			pos[0] = f3_VecPunchForce[this.index][0];
			pos[1] = f3_VecPunchForce[this.index][1];
			pos[2] = f3_VecPunchForce[this.index][2];
		}
	}
	property bool m_bGib
	{
		public get()							{ return b_DoGibThisNpc[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DoGibThisNpc[this.index] = TempValueForProperty; }
	}
	property bool g_bNPCVelocityCancel
	{
		public get()							{ return b_NPCVelocityCancel[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NPCVelocityCancel[this.index] = TempValueForProperty; }
	}
	property float m_flDoSpawnGesture
	{
		public get()							{ return fl_DoSpawnGesture[this.index]; }
		public set(float TempValueForProperty) 	{ fl_DoSpawnGesture[this.index] = TempValueForProperty; }
	}
	property float m_flReloadDelay
	{
		public get()							{ return fl_ReloadDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ReloadDelay[this.index] = TempValueForProperty; }
	}
	property bool m_bisWalking
	{
		public get()							{ return b_isWalking[this.index]; }
		public set(bool TempValueForProperty) 	{ b_isWalking[this.index] = TempValueForProperty; }
	}
	property float m_bisGiantWalkCycle
	{
		public get()							{ return b_isGiantWalkCycle[this.index]; }
		public set(float TempValueForProperty) 	{ b_isGiantWalkCycle[this.index] = TempValueForProperty; }
	}
	
	property int m_iSpawnProtectionEntity
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_SpawnProtectionEntity[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_SpawnProtectionEntity[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_SpawnProtectionEntity[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iTeamGlow
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_TeamGlow[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_TeamGlow[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TeamGlow[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable1
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable1[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable1[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable1[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable2
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable2[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable2[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable2[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable3
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable3[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable3[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable3[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable4
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable4[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable4[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable4[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable5
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable5[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable5[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable5[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable6
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable5[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable6[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable6[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	public float GetMaxJumpHeight() { return 250.0; }
	public float GetLeadRadius()	{ return 90000.0; }
	
	public Address GetLocomotionInterface() { return SDKCall(g_hGetLocomotionInterface, SDKCall(g_hMyNextBotPointer, this.index)); }
	
	public Address GetIntentionInterface()  { return SDKCall(g_hGetIntentionInterface,  SDKCall(g_hMyNextBotPointer, this.index)); }
	public Address GetBodyInterface()	   { return SDKCall(g_hGetBodyInterface,	   SDKCall(g_hMyNextBotPointer, this.index)); }
	
	
	public int GetTeam()  { return GetEntProp(this.index, Prop_Send, "m_iTeamNum"); }
	
	public Address GetModelPtr()
	{
		//const int offset = FindSendPropInfo("CBaseAnimating", "m_flFadeScale ") + 28;
		
		if(IsValidEntity(this.index)) {
			return view_as<Address>(GetEntData(this.index, 283 * 4));
		}
		
		return Address_Null;
	}	
	public void SetPoseParameter(int iParameter, float value)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return;
			
		SDKCall(g_hSetPoseParameter, this.index, pStudioHdr, iParameter, value);
	}	
	public int FindAttachment(const char[] pAttachmentName)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hStudio_FindAttachment, pStudioHdr, pAttachmentName) + 1;
	}
	public void DispatchParticleEffect(int entity, const char[] strParticle, float flStartPos[3], float vecAngles[3], float flEndPos[3], 
									   int iAttachmentPointIndex = 0, ParticleAttachment_t iAttachType = PATTACH_CUSTOMORIGIN, bool bResetAllParticlesOnEntity = false)
	{
		int tblidx = FindStringTable("ParticleEffectNames");
		if (tblidx == INVALID_STRING_TABLE) 
		{
			LogError("Could not find string table: ParticleEffectNames");
			return;
		}
		char tmp[256];
		int count = GetStringTableNumStrings(tblidx);
		int stridx = INVALID_STRING_INDEX;
		for (int i = 0; i < count; i++)
		{
			ReadStringTable(tblidx, i, tmp, sizeof(tmp));
			if (StrEqual(tmp, strParticle, false))
			{
				stridx = i;
				break;
			}
		}
		if (stridx == INVALID_STRING_INDEX)
		{
			LogError("Could not find particle: %s", strParticle);
			return;
		}
	
		TE_Start("TFParticleEffect");
		TE_WriteFloat("m_vecOrigin[0]", flStartPos[0]);
		TE_WriteFloat("m_vecOrigin[1]", flStartPos[1]);
		TE_WriteFloat("m_vecOrigin[2]", flStartPos[2]);
		TE_WriteVector("m_vecAngles", vecAngles);
		TE_WriteNum("m_iParticleSystemIndex", stridx);
		TE_WriteNum("entindex", entity);
		TE_WriteNum("m_iAttachType", view_as<int>(iAttachType));
		TE_WriteNum("m_iAttachmentPointIndex", iAttachmentPointIndex);
		TE_WriteNum("m_bResetParticles", bResetAllParticlesOnEntity);	
		TE_WriteNum("m_bControlPoint1", 0);	
		TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", 0);  
		TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", flEndPos[0]);
		TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", flEndPos[1]);
		TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", flEndPos[2]);
		TE_SendToAll();
	}
	public int LookupPoseParameter(const char[] szName)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hLookupPoseParameter, this.index, pStudioHdr, szName);
	}	
	public int LookupActivity(const char[] activity)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hLookupActivity, pStudioHdr, activity);
	}
	public void AddGesture(const char[] anim, bool cancel_animation = true)
	{
		int iSequence = this.LookupActivity(anim);
		if(iSequence < 0)
			return;
			
		if(cancel_animation)
		{
			SDKCall(g_hRestartGesture, this.index, iSequence, true, true); //This is better, it just restarts the sequence instead, if its there or already playing, basically like below but better
		}
		else
		{
			SDKCall(g_hAddGesture, this.index, iSequence, true);
		}
	}
	public bool IsPlayingGesture(const char[] anim)
	{
		int iSequence = this.LookupActivity(anim);
		if(iSequence < 0)
			return;
		
		SDKCall(g_hIsPlayingGesture, this.index, iSequence);
	}
	public bool IsOnGround()
	{
		return SDKCall(g_hSDKIsOnGround, this.GetLocomotionInterface());
	}
	public void SetDefaultStats()
	{
		//npc got his stats by plugins.
		this.m_bThisNpcGotDefaultStats_INVERTED = true;
	}
	/*
	public bool IsClimbingOrJumping()
	{
		if (g_hSDKIsClimbingOrJumping != null)
			return SDKCall(g_hSDKIsClimbingOrJumping, this.GetLocomotionInterface());
		return false;
	}
	*/
	public void CreatePather(float flStep, float flJump, float flDrop, int iSolid, float flAhead, float flRePath, float flHull)
	{
		PF_Create(this.index, flStep, flJump, flDrop, 0.6, iSolid, flAhead, flRePath, flHull);
		PF_EnableCallback(this.index, PFCB_Approach,			PluginBot_Approach);
		PF_EnableCallback(this.index, PFCB_IsEntityTraversable, PluginBot_IsEntityTraversable);
		PF_EnableCallback(this.index, PFCB_GetPathCost,		 PluginBot_PathCost);
	//	PF_EnableCallback(this.index, PFCB_ClimbUpToLedge, 		PluginBot_NormalJump);
	//	PF_EnableCallback(this.index, PFCB_PathSuccess,			PluginBot_PathSuccess);
		PF_EnableCallback(this.index, PFCB_OnMoveToSuccess,	 PluginBot_MoveToSuccess);
		PF_EnableCallback(this.index, PFCB_PathFailed,		  PluginBot_MoveToFailure);
		PF_EnableCallback(this.index, PFCB_OnMoveToFailure,	 PluginBot_MoveToFailure);
		
		PF_EnableCallback(this.index, PFCB_OnActorEmoted, PluginBot_OnActorEmoted);
		
		this.SetDefaultStats(); // we'll use this so we can set all the default stuff we need!
	}	
	public void RemovePather(int entity)
	{
		PF_DisableCallback(entity, PFCB_Approach);
		PF_DisableCallback(entity, PFCB_IsEntityTraversable);
		PF_DisableCallback(entity, PFCB_GetPathCost);
	//	PF_DisableCallback(entity, PFCB_ClimbUpToLedge);
		PF_DisableCallback(entity, PFCB_OnMoveToSuccess);
		PF_DisableCallback(entity, PFCB_PathFailed);
		PF_DisableCallback(entity, PFCB_OnMoveToFailure);
		PF_DisableCallback(entity, PFCB_OnActorEmoted);
		PF_Destroy(entity);
	}	
	public void StartPathing()
	{
		if(!CvarDisableThink.BoolValue)
		{
			PF_StartPathing(this.index);
			this.m_bPathing = true;
		}
	}
	public void FaceTowards(const float vecGoal[3] , const float turnrate = 250.0)
	{
		
		//Sad!
		ConVar flTurnRate = FindConVar("tf_base_boss_max_turn_rate");
		float flPrevValue = flTurnRate.FloatValue;
		
		flTurnRate.FloatValue = turnrate;
		SDKCall(g_hFaceTowards, this.GetLocomotionInterface(), vecGoal);
		flTurnRate.FloatValue = flPrevValue;
	}	
		
	public float GetGroundSpeed()									{ return SDKCall(g_hGetGroundSpeed, this.GetLocomotionInterface()); }
	public float GetPoseParameter(int iParameter)					{ return SDKCall(g_hGetPoseParameter, this.index, iParameter);									   }
	public int FindBodygroupByName(const char[] name)				{ return SDKCall(g_hFindBodygroupByName, this.index, name);										  }
	public int SelectWeightedSequence(int activity, int curSequence) { return SDKCall(g_hSelectWeightedSequence, this.index, this.GetModelPtr(), activity, curSequence); }
	
	public void GetAttachment(const char[] szName, float absOrigin[3], float absAngles[3]) { SDKCall(g_hGetAttachment, this.index, this.FindAttachment(szName), absOrigin, absAngles); }
	public void SetBodygroup(int iGroup, int iValue)									   { SDKCall(g_hSetBodyGroup, this.index, iGroup, iValue);									 }
	public void Approach(const float vecGoal[3])										   { SDKCall(g_hApproach, this.GetLocomotionInterface(), vecGoal, 0.1);						}
	public void Jump()																	 { SDKCall(g_hJump, this.GetLocomotionInterface());										  }
	// public void JumpAcrossGap(const float landingGoal[3], const float landingForward[3])   { SDKCall(g_hJumpAcrossGap, this.GetLocomotionInterface(), landingGoal, landingForward);	}
	public void GetVelocity(float vecOut[3])											   { SDKCall(g_hGetVelocity, this.GetLocomotionInterface(), vecOut);						   }	
	public void SetVelocity(const float vec[3])											{ SDKCall(g_hSetVelocity, this.GetLocomotionInterface(), vec);							  }	
	
	public void SetOrigin(const float vec[3])											
	{
		SetEntPropVector(this.index, Prop_Data, "m_vecOrigin",vec);
	
	}	
	
	public void SetSequence(int iSequence)	{ SetEntProp(this.index, Prop_Send, "m_nSequence", iSequence); }
	public void SetPlaybackRate(float flRate) { SetEntPropFloat(this.index, Prop_Send, "m_flPlaybackRate", flRate); }
	public void SetCycle(float flCycle)	   { SetEntPropFloat(this.index, Prop_Send, "m_flCycle", flCycle); }
	
	public void GetVectors(float pForward[3], float pRight[3], float pUp[3]) { SDKCall(g_hGetVectors, this.index, pForward, pRight, pUp); }
	
	public void GetGroundMotionVector(float vecMotion[3])					{ SDKCall(g_hGetGroundMotionVector, this.GetLocomotionInterface(), vecMotion); }
	
	public void UpdateCollisionBox() { SDKCall(g_hUpdateCollisionBox,  this.index); }
	public void ResetSequenceInfo()  { SDKCall(g_hResetSequenceInfo,  this.index); }
	public void StudioFrameAdvance() { SDKCall(g_hStudioFrameAdvance, this.index); }
	public void DispatchAnimEvents() { SDKCall(g_hDispatchAnimEvents, this.index, this.index); }
	
	public int EquipItem(const char[] attachment, const char[] model, const char[] anim = "", int skin = 0)
	{
		int item = CreateEntityByName("prop_dynamic");
		DispatchKeyValue(item, "model", model);
		DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(this.index, Prop_Send, "m_flModelScale"));
		DispatchSpawn(item);
		
		SetEntProp(item, Prop_Send, "m_nSkin", skin);
		SetEntProp(item, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES);
	
		if(!StrEqual(anim, ""))
		{
			SetVariantString(anim);
			AcceptEntityInput(item, "SetAnimation");
		}
	
		SetVariantString("!activator");
		AcceptEntityInput(item, "SetParent", this.index);
		
		SetVariantString(attachment);
		AcceptEntityInput(item, "SetParentAttachmentMaintainOffset"); 
		
		SetEntityCollisionGroup(item, 1);
		/*
		if(GetEntProp(this.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue))
		{
			b_Is_Blue_Npc[item] = true; //make sure they dont collide with stuff
		}
		else if(GetEntProp(this.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
		{
			b_IsAlliedNpc[item] = true; //make sure they dont collide with stuff
		}
		*/
		return item;
	}
	public bool DoSwingTrace(Handle &trace, int target, float vecSwingMaxs[3] = { 64.0, 64.0, 128.0 }, float vecSwingMins[3] = { -64.0, -64.0, -128.0 }, float vecSwingStartOffset = 44.0, int Npc_type = 0, int Ignore_Buildings = 0)
	{
		switch(Npc_type)
		{
			case 1: //giants
			{
				vecSwingMaxs = { 100.0, 100.0, 150.0 };
				vecSwingMins = { -100.0, -100.0, -150.0 };
			}
			case 2: //Ally Invinceable 
			{
				vecSwingMaxs = { 250.0, 250.0, 250.0 };
				vecSwingMins = { -250.0, -250.0, -250.0 };
			}
		}
		
		float eyePitch[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);
		
		float vecForward[3], vecRight[3], vecTarget[3];
		
		vecTarget = WorldSpaceCenter(target);
		MakeVectorFromPoints(WorldSpaceCenter(this.index), vecTarget, vecForward);
		GetVectorAngles(vecForward, vecForward);
		vecForward[1] = eyePitch[1];
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
		
		float vecSwingStart[3]; vecSwingStart = GetAbsOrigin(this.index);
		
		vecSwingStart[2] += vecSwingStartOffset;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * vecSwingMaxs[0];
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * vecSwingMaxs[1];
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * vecSwingMaxs[2];
		
	//	TE_SetupBeamPoints(vecSwingStart, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	//	TE_SendToAll();
		
		bool ingore_buildings = false;
		if(Ignore_Buildings || IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			ingore_buildings = true;
		}
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, ingore_buildings ? BulletAndMeleeTracePlayerAndBaseBossOnly : BulletAndMeleeTrace, this.index );
		if ( TR_GetFraction(trace) >= 1.0 || TR_GetEntityIndex(trace) == 0)
		{
			delete trace;
			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, ( MASK_SOLID | CONTENTS_SOLID ), ingore_buildings ? BulletAndMeleeTracePlayerAndBaseBossOnly : BulletAndMeleeTrace, this.index );
			if ( TR_GetFraction(trace) < 1.0)
			{
				// This is the point on the actual surface (the hull could have hit space)
				TR_GetEndPosition(vecSwingEnd, trace);	
			}
		}
		return ( TR_GetFraction(trace) < 1.0 );
	}
	public bool DoAimbotTrace(Handle &trace, int target, float vecSwingMaxs[3] = { 64.0, 64.0, 128.0 }, float vecSwingMins[3] = { -64.0, -64.0, -128.0 }, float vecSwingStartOffset = 44.0)
	{
		float vecSwingStart[3]; vecSwingStart = GetAbsOrigin(this.index);
		
		vecSwingStart[2] += vecSwingStartOffset;
		
		float vecSwingEnd[3]; vecSwingEnd = GetAbsOrigin(target);
		
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, this.index );
		/*
		if ( TR_GetFraction(trace) >= 1.0 || TR_GetEntityIndex(trace) == 0)
		{
			delete trace;
			
			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, ( MASK_SOLID | CONTENTS_SOLID ), BulletAndMeleeTrace, this.index );
			if ( TR_GetFraction(trace) < 1.0)
			{
				// This is the point on the actual surface (the hull could have hit space)
				TR_GetEndPosition(vecSwingEnd, trace);	
			}
			
		}
		*/
		return ( TR_GetFraction(trace) < 1.0 );
	}
	public void FireRocket(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0, int flags = 0) //No defaults, otherwise i cant even judge.
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		this.GetVectors(vecForward, vecSwingStart, vecAngles);

		vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

	//	vecSwingStart[0] += vecForward[0] * 64;
	//	vecSwingStart[1] += vecForward[1] * 64;
	//	vecSwingStart[2] += vecForward[2] * 64;
	// 	this isnt needed anymore 


		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;

		int entity = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(entity))
		{
			i_ExplosiveProjectileHexArray[entity] = flags;
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, rocket_damage, true);	// Damage
			SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(this.index, Prop_Send, "m_iTeamNum"));
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			if(rocket_model[0])
			{
				int g_ProjectileModelRocket = PrecacheModel(rocket_model);
				for(int i; i<4; i++)
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
				}
			}
			if(model_scale != 1.0)
			{
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale); // ZZZZ i sleep
			}
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			SetEntityCollisionGroup(entity, 19); //our savior
			See_Projectile_Team(entity);
		}
	}
	public void FireArrow(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0) //No defaults, otherwise i cant even judge.
	{
		//ITS NOT actually an arrow, because of an ANNOOOOOOOOOOOYING sound.
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		this.GetVectors(vecForward, vecSwingStart, vecAngles);

		vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

	//	vecSwingStart[0] += vecForward[0] * 64;
	//	vecSwingStart[1] += vecForward[1] * 64;
	//	vecSwingStart[2] += vecForward[2] * 64;
	// 	this isnt needed anymore 


		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;

		int entity = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(entity))
		{
			b_EntityIsArrow[entity] = true;
			f_ArrowDamage[entity] = rocket_damage;
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			if(rocket_model[0])
			{
				int g_ProjectileModelRocket = PrecacheModel(rocket_model);
				for(int i; i<4; i++)
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
				}
			}
			else
			{
				for(int i; i<4; i++)
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_modelArrow, _, i);
					
				//	int trail = Trail_Attach(entity, "effects/arrowtrail_blue.vmt", 255, 1.5, 12.0, 0.0, 4);
					int trail = Trail_Attach(entity, ARROW_TRAIL, 255, 0.3, 3.0, 3.0, 5);
					
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(trail);
					
					//Just use a timer tbh.
					
					CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			if(model_scale != 1.0)
			{
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale); // ZZZZ i sleep
			}
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			SetEntityCollisionGroup(entity, 19); //our savior
			See_Projectile_Team(entity);
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Arrow_DHook_RocketExplodePre); //im lazy so ill reuse stuff that already works *yawn*
			SDKHook(entity, SDKHook_StartTouch, ArrowStartTouch);
		}
	}
	/*
	public void FireBolt(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "" , float model_scale = 1.0) //No defaults, otherwise i cant even judge.
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		this.GetVectors(vecForward, vecSwingStart, vecAngles);

		vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

	//	vecSwingStart[0] += vecForward[0] * 64;
	//	vecSwingStart[1] += vecForward[1] * 64;
	//	vecSwingStart[2] += vecForward[2] * 64;
	// 	this isnt needed anymore 


		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;

		int entity = CreateEntityByName("tf_projectile_energy_ball");
		if(IsValidEntity(entity))
		{
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, rocket_damage, true);	// Damage
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			if(rocket_model[0])
			{
				SetEntityModel(entity, rocket_model);
			}
			if(model_scale != 1.0)
			{
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale); // ZZZZ i sleep
			}
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			SetEntityCollisionGroup(entity, 19); //our savior
		}
	}
	*/
	property int m_iActivity
	{
		public get()							{ return i_Activity[this.index]; }
		public set(int TempValueForProperty) 	{ i_Activity[this.index] = TempValueForProperty; }
	}
	
	property int m_iPoseMoveX 
	{
		public get()							{ return i_PoseMoveX[this.index]; }
		public set(int TempValueForProperty) 	{ i_PoseMoveX[this.index] = TempValueForProperty; }
	}
	
	property int m_iPoseMoveY
	{
		public get()							{ return i_PoseMoveY[this.index]; }
		public set(int TempValueForProperty) 	{ i_PoseMoveY[this.index] = TempValueForProperty; }
	}
	/*
	
		property int m_iActivity
	{
		public get()              { return this.ExtractStringValueAsInt("m_iActivity"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iActivity", buff, true); }
	}
	
	property int m_iPoseMoveX 
	{
		public get()              { return this.ExtractStringValueAsInt("m_iPoseMoveX"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iPoseMoveX", buff, true); }
	}
	
	property int m_iPoseMoveY
	{
		public get()              { return this.ExtractStringValueAsInt("m_iPoseMoveY"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iPoseMoveY", buff, true); }
	}
	*/

	//Begin an animation activity, return false if we cant do that right now.
	public bool StartActivity(int iActivity, int flags = 0)
	{
		//Translate jump anim
		if(iActivity == 29)
			iActivity = this.LookupActivity("ACT_MP_JUMP_START_MELEE");
		
		int nSequence = this.SelectWeightedSequence(iActivity, GetEntProp(this.index, Prop_Send, "m_nSequence"));
		if (nSequence == 0) 
			return false;
		
		this.m_iActivity = iActivity;
		
		this.SetSequence(nSequence);
		this.SetPlaybackRate(1.0);
		this.SetCycle(0.0);
		
		this.ResetSequenceInfo();
		
		return true;
	}
	
	public void Update()
	{
		
		if (this.m_iPoseMoveX < 0) {
			this.m_iPoseMoveX = this.LookupPoseParameter("move_x");
		}
		if (this.m_iPoseMoveY < 0) {
			this.m_iPoseMoveY = this.LookupPoseParameter("move_y");
		}
		
		float flNextBotGroundSpeed = this.GetGroundSpeed();
		
		if (flNextBotGroundSpeed < 0.01) {
			if (this.m_iPoseMoveX >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveX, 0.0);
			}
			if (this.m_iPoseMoveY >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveY, 0.0);
			}
		} else {
			float vecFwd[3], vecRight[3], vecUp[3];
			this.GetVectors(vecFwd, vecRight, vecUp);
			
			float vecMotion[3]; this.GetGroundMotionVector(vecMotion);
			
			if (this.m_iPoseMoveX >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveX, GetVectorDotProduct(vecMotion, vecFwd));
			}
			if (this.m_iPoseMoveY >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveY, GetVectorDotProduct(vecMotion, vecRight));
			}
			
		}
		if(this.m_bisWalking) //This exists to make sure that if there is any idle animation played, it wont alter the playback rate and keep it at a flat 1, or anything altered that the user desires.
		{
			float m_flGroundSpeed = GetEntPropFloat(this.index, Prop_Data, "m_flGroundSpeed");
			if (m_flGroundSpeed != 0.0) {
				float PlaybackSpeed = clamp((flNextBotGroundSpeed / m_flGroundSpeed), -4.0, 12.0);
				PlaybackSpeed *= this.m_bisGiantWalkCycle;
				if(PlaybackSpeed > 2.0)
					PlaybackSpeed = 2.0;
				this.SetPlaybackRate(PlaybackSpeed);
			}
		}
		
		this.StudioFrameAdvance();
		this.DispatchAnimEvents();
		
		//Run and StuckMonitor
		SDKCall(g_hRun,          this.GetLocomotionInterface());	
		
		/*
		
		SDKCall(g_hStuckMonitor, this.GetLocomotionInterface());
		
		bool bStuck = this.IsStuck();
		if(bStuck)
		{
			float there[3];
			bool bYes = false;
			
			for (int i = 1; i <= 2; i++)
			{
				if (PF_GetFutureSegment(this.index, i, there)) 
				{
					bYes = true; 
					break;
				}
			}
			
			if(bYes) 
			{
				NavArea RandomArea = PickRandomArea();	
			
				if(RandomArea == NavArea_Null) 
				{
				
				}
				else
				{
					
					float vecGoal[3]; RandomArea.GetCenter(vecGoal);
					
					if(!PF_IsPathToVectorPossible(this.index, vecGoal))
					{
					
					}
					else
					{
						PF_SetGoalVector(this.index, vecGoal);
						SDKCall(g_hClearStuckStatus, this.GetLocomotionInterface(), "Un-Stuck");//  Sauce code :)
					}
				}
				
			} 
			
			
			else 
			{
				NavArea area = TheNavMesh.GetNearestNavArea_Vec(WorldSpaceCenter(this.index), true);
				if(area == NavArea_Null)
					return;
			
				float center[3]; area.GetCenter(center); center[2] += 18.0;
		//		PrintToChatAll("stuck2");
				TeleportEntity(this.index, center, NULL_VECTOR, NULL_VECTOR);
			}
		}
		
		*/
		
		
	}

	 	
	
	//return currently animating activity
	public int GetActivity()
	{
		return this.m_iActivity;
	}
	
	//return true if currently animating activity matches the given one
	public bool IsActivity(int iActivity)
	{
	
		return (iActivity == this.m_iActivity);
	}

	//return the bot's collision mask
	public int GetSolidMask()
	{
		//0x202400B L4D2
		return (MASK_NPCSOLID);
	}
	
	public void RestartMainSequence()
	{
	
		SetEntPropFloat(this.index, Prop_Data, "m_flAnimTime", GetGameTime());
		
		this.SetCycle(0.0);
	}
	
	public bool IsSequenceFinished()
	{
		return !!GetEntProp(this.index, Prop_Data, "m_bSequenceFinished");
	}
	public void SetDefaultStatsZombieRiot(int Team)
	{
		CClotBody npc = view_as<CClotBody>(this.index);
		npc.m_bThisNpcGotDefaultStats_INVERTED = true;
		if(Team == view_as<int>(TFTeam_Red)) //ANY NPC THATS AN ALLY AND THAT HAS NO DEFAULT STATS WILL GET THIS.
		{
			npc.m_bThisEntityIgnored = false;
			npc.m_bThisNpcIsABoss = false;
			npc.bCantCollidie = false;
		}
	}
}

enum ActivityType 
{ 
	MOTION_CONTROLLED_XY	= 0x0001,	// XY position and orientation of the bot is driven by the animation.
	MOTION_CONTROLLED_Z		= 0x0002,	// Z position of the bot is driven by the animation.
	ACTIVITY_UNINTERRUPTIBLE= 0x0004,	// activity can't be changed until animation finishes
	ACTIVITY_TRANSITORY		= 0x0008,	// a short animation that takes over from the underlying animation momentarily, resuming it upon completion
	ENTINDEX_PLAYBACK_RATE	= 0x0010,	// played back at different rates based on entindex
};


//Trash below!


public void NPC_Base_InitGamedata()
{
	
	RegAdminCmd("sm_spawn_npc", Command_PetMenu, ADMFLAG_ROOT);
	
	Handle hConf = LoadGameConfigFile("tf2.pets");
	
	//SDKCalls
	//This call is used to get an entitys center position
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::WorldSpaceCenter");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if ((g_hSDKWorldSpaceCenter = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBaseEntity::WorldSpaceCenter offset!");
	
	//=========================================================
	// StudioFrameAdvance - advance the animation frame up some interval (default 0.1) into the future
	//=========================================================
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseAnimating::StudioFrameAdvance");
	if ((g_hStudioFrameAdvance = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::StudioFrameAdvance offset!"); 	


//	CBaseAnimatingOverlay::StudioFrameAdvance()
	
	//CBaseAnimating::ResetSequenceInfo( );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::ResetSequenceInfo");
	if ((g_hResetSequenceInfo = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::ResetSequenceInfo signature!"); 
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::MyNextBotPointer");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hMyNextBotPointer = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseEntity::MyNextBotPointer offset!"); 
	
	/*
	void CBaseAnimating::RefreshCollisionBounds( void )
	{
		CollisionProp()->RefreshScaledCollisionBounds();
	}
	*/
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseAnimating::RefreshCollisionBounds");
	if ((g_hUpdateCollisionBox = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::RefreshCollisionBounds offset!"); 
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetLocomotionInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetLocomotionInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetLocomotionInterface!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetIntentionInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetIntentionInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetIntentionInterface!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetBodyInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetBodyInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetBodyInterface!");
/*		
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetVisionInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetVisionInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetVisionInterface!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "IVision::GetPrimaryKnownThreat");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetPrimaryKnownThreat = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for IVision::GetPrimaryKnownThreat!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "IVision::GetKnown");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);	//CBaseEntity - Entity to check for
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//CKnownEntity
	if((g_hGetKnown = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for IVision::GetKnown!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "IVision::AddKnownEntity");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if((g_hAddKnownEntity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for IVision::AddKnownEntity!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CKnownEntity::GetEntity");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if((g_hGetKnownEntity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CKnownEntity::GetEntity!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CKnownEntity::UpdatePosition");
	if((g_hUpdatePosition = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CKnownEntity::UpdatePosition!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CKnownEntity::UpdateVisibilityStatus");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);	//bool visible now
	if((g_hUpdateVisibilityStatus = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CKnownEntity::UpdateVisibilityStatus!");
*/
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::Run");
	if((g_hRun = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::Run!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::Approach");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	if((g_hApproach = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::Approach!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::FaceTowards");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	if((g_hFaceTowards = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::FaceTowards!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::Jump");
	if((g_hJump = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::Jump!");
/*	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::JumpAcrossGap");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	if((g_hJumpAcrossGap = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::JumpAcrossGap!");
	*/
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::GetVelocity");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if((g_hGetVelocity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::GetVelocity!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::SetVelocity");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	if((g_hSetVelocity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::SetVelocity!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseAnimating::DispatchAnimEvents");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hDispatchAnimEvents = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::DispatchAnimEvents offset!"); 
	
	//ILocomotion::GetGroundSpeed() 
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::GetGroundSpeed");
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if((g_hGetGroundSpeed = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::GetGroundSpeed!");
	
	//ILocomotion::GetGroundMotionVector() 
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::GetGroundMotionVector");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if((g_hGetGroundMotionVector = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::GetGroundMotionVector!");
	
	//CBaseEntity::GetVectors(Vector*, Vector*, Vector*) 
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::GetVectors");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if((g_hGetVectors = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CBaseEntity::GetVectors!");

	//CBaseAnimating::GetPoseParameter(int iParameter)
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::GetPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if((g_hGetPoseParameter = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::GetPoseParameter");
	
	//CBaseAnimating::FindBodygroupByName(const char* name)
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::FindBodygroupByName");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hFindBodygroupByName = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::FindBodygroupByName");
	
	//CBaseAnimating::SetBodygroup( int iGroup, int iValue )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::SetBodygroup");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hSetBodyGroup = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::SetBodygroup");
	
	//int SelectWeightedSequence( CStudioHdr *pstudiohdr, int activity, int curSequence );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "SelectWeightedSequence");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pstudiohdr
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//activity
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//curSequence
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return sequence
	if((g_hSelectWeightedSequence = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for SelectWeightedSequence");
	
	//SetPoseParameter( CStudioHdr *pStudioHdr, int iParameter, float flValue );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::SetPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if((g_hSetPoseParameter = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::SetPoseParameter");
	
	//LookupPoseParameter( CStudioHdr *pStudioHdr, const char *szName );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::LookupPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hLookupPoseParameter = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::LookupPoseParameter");
	
	//CBaseAnimatingOverlay::AddGesture( Activity activity, bool autokill )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::AddGesture");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain); 
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hAddGesture = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::AddGesture");
	
	//( Activity activity, bool addifmissing /*=true*/, bool autokill /*=true*/ )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::RestartGesture");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);	
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hRestartGesture = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::RestartGesture");
	
	
	//CBaseAnimatingOverlay::IsPlayingGesture( Activity activity )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::IsPlayingGesture");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if((g_hIsPlayingGesture = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::IsPlayingGesture");
	/*
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::IsClimbingOrJumping");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
	g_hSDKIsClimbingOrJumping = EndPrepSDKCall();
	if (g_hSDKIsClimbingOrJumping == null)
	{
		PrintToServer("Failed to retrieve ILocomotion::IsClimbingOrJumping offset from SF2 gamedata!");
	}
	*/
	//-----------------------------------------------------------------------------
	
	//-----------------------------------------------------------------------------
	// Purpose: Looks up an activity by name.
	// Input  : label - Name of the activity to look up, ie "ACT_IDLE"
	// Output : Activity index or ACT_INVALID if not found.
	//-----------------------------------------------------------------------------
	//int LookupActivity( CStudioHdr *pstudiohdr, const char *label )
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "LookupActivity");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//label
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hLookupActivity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for LookupActivity");
	
	
	//-----------------------------------------------------------------------------
	// Purpose: lookup attachment by name
	//-----------------------------------------------------------------------------
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "Studio_FindAttachment");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//pAttachmentName
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hStudio_FindAttachment = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for Studio_FindAttachment");
	
	//-----------------------------------------------------------------------------
	// Purpose: Returns the world location and world angles of an attachment
	// Input  : attachment name
	// Output :	location and angles
	//-----------------------------------------------------------------------------
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::GetAttachment");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//iAttachment
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK); //absOrigin
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK); //absAngles
	if((g_hGetAttachment = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::GetAttachment");
	
	//PluginBot SDKCalls
	//Get NextBot pointer
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBotComponent::GetBot");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetBot = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBotComponent::GetBot!");
	
	//Get NextBot entity index
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBotComponent::GetEntity");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if((g_hGetEntity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBotComponent::GetEntity!");
	
	//
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "NextBotCombatCharacter::Event_Killed");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer);
	if((g_hNextBotCombatCharacter_Event_Killed = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for NextBotCombatCharacter::Event_Killed!");

	//Get NextBot entity index
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseCombatCharacter::Event_Killed");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer);
	if((g_hCBaseCombatCharacter_Event_Killed = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CBaseCombatCharacter::Event_Killed!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::IsOnGround");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
	g_hSDKIsOnGround = EndPrepSDKCall();
	if (g_hSDKIsOnGround == null)
	{
		PrintToServer("Failed to retrieve ILocomotion::IsOnGround offset from SF2 gamedata!");
	}
	
	//DHooks
	g_hHandleAnimEvent = DHookCreateEx(hConf, "CBaseAnimating::HandleAnimEvent",  HookType_Entity, ReturnType_Void,   ThisPointer_CBaseEntity, CBaseAnimating_HandleAnimEvent);
	DHookAddParam(g_hHandleAnimEvent, HookParamType_ObjectPtr);
	
	g_hGetFrictionSideways = DHookCreateEx(hConf, "ILocomotion::GetFrictionSideways",HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetFrictionSideways);
	g_hGetStepHeight	   = DHookCreateEx(hConf, "ILocomotion::GetStepHeight",	  HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetStepHeight);	
	g_hGetGravity		  = DHookCreateEx(hConf, "ILocomotion::GetGravity",		 HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetGravity);	
	g_hGetRunSpeed		 = DHookCreateEx(hConf, "ILocomotion::GetRunSpeed",		HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetRunSpeed);
	g_hGetGroundNormal	 = DHookCreateEx(hConf, "ILocomotion::GetGroundNormal",	HookType_Raw, ReturnType_VectorPtr, ThisPointer_Address, ILocomotion_GetGroundNormal);
	g_hGetMaxAcceleration  = DHookCreateEx(hConf, "ILocomotion::GetMaxAcceleration", HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetMaxAcceleration);
	
	g_hShouldCollideWithAlly = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithAlly);
	DHookAddParam(g_hShouldCollideWithAlly, HookParamType_CBaseEntity);
	
	g_hShouldCollideWithAllyInvince = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithAllyInvince);
	DHookAddParam(g_hShouldCollideWithAllyInvince, HookParamType_CBaseEntity);
	
	g_hShouldCollideWithAllyEnemy = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithEnemy);
	DHookAddParam(g_hShouldCollideWithAllyEnemy, HookParamType_CBaseEntity);

	g_hShouldCollideWithAllyEnemyIngoreBuilding = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithEnemyIngoreBuilding);
	DHookAddParam(g_hShouldCollideWithAllyEnemyIngoreBuilding, HookParamType_CBaseEntity);
	
	g_hGetSolidMask		= DHookCreateEx(hConf, "IBody::GetSolidMask",	   HookType_Raw, ReturnType_Int,   ThisPointer_Address, IBody_GetSolidMask);
	g_hGetActivity		 = DHookCreateEx(hConf, "IBody::GetActivity",		HookType_Raw, ReturnType_Int,   ThisPointer_Address, IBody_GetActivity);
	
	g_hGetHullWidthGiant		= DHookCreateEx(hConf, "IBody::GetHullWidth",	   HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullWidth_ISGIANT);
	g_hGetHullHeightGiant	   = DHookCreateEx(hConf, "IBody::GetHullHeight",	  HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullHeight_ISGIANT);
	g_hGetStandHullHeightGiant  = DHookCreateEx(hConf, "IBody::GetStandHullHeight", HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetStandHullHeight_ISGIANT);
	
	
	
	g_hGetHullWidth		= DHookCreateEx(hConf, "IBody::GetHullWidth",	   HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullWidth);
	g_hGetHullHeight	   = DHookCreateEx(hConf, "IBody::GetHullHeight",	  HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullHeight);
	g_hGetStandHullHeight  = DHookCreateEx(hConf, "IBody::GetStandHullHeight", HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetStandHullHeight);
	
	g_hIsActivity   = DHookCreateEx(hConf, "IBody::IsActivity",   HookType_Raw, ReturnType_Bool, ThisPointer_Address, IBody_IsActivity);
	DHookAddParam(g_hIsActivity, HookParamType_Int);
	
	g_hStartActivity = DHookCreateEx(hConf, "IBody::StartActivity", HookType_Raw, ReturnType_Bool, ThisPointer_Address, IBody_StartActivity);
	DHookAddParam(g_hStartActivity, HookParamType_Int);
	DHookAddParam(g_hStartActivity, HookParamType_Int);

	g_hEvent_Killed = DHookCreateEx(hConf, "CTFBaseBoss::Event_Killed", HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, CTFBaseBoss_Event_Killed);
	DHookAddParam(g_hEvent_Killed, HookParamType_Int); //( const CTakeDamageInfo &info )
	
//	g_hAlwaysTransmit = DynamicHook.FromConf(hConf, "CTFBaseBoss::UpdateTransmitState()");
	
	g_hEvent_Ragdoll = DHookCreateEx(hConf, "CBaseCombatCharacter::BecomeRagdoll", HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, CTFBaseBoss_Ragdoll);
	
	DHookAddParam(g_hEvent_Ragdoll, HookParamType_Int); //( const CTakeDamageInfo &info )
	DHookAddParam(g_hEvent_Ragdoll, HookParamType_VectorPtr); //( const vector )

	Address iAddr = GameConfGetAddress(hConf, "GetAnimationEvent");
	if(iAddr == Address_Null) SetFailState("Can't find GetAnimationEvent address for patch.");
	
	StoreToAddress(iAddr += view_as<Address>(131), 9999, NumberType_Int16);
	
	delete hConf;
	
	HookIdMap = new StringMap();
	HookListMap = new StringMap();
	
	BobTheGod_OnPluginStart();
}

Handle DHookCreateEx(Handle gc, const char[] key, HookType hooktype, ReturnType returntype, ThisPointerType thistype, DHookCallback callback)
{
	int iOffset = GameConfGetOffset(gc, key);
	if(iOffset == -1)
	{
		SetFailState("Failed to get offset of %s", key);
		return null;
	}
	
	return DHookCreate(iOffset, hooktype, returntype, thistype, callback);
}

//Ragdoll.
public MRESReturn CTFBaseBoss_Event_Killed(int pThis, Handle hParams)
{	
//	CreateTimer(5.0, Check_Emergency_Reload, EntIndexToEntRef(pThis), TIMER_FLAG_NO_MAPCHANGE);
	
	Address CTakeDamageInfo = DHookGetParam(hParams, 1);
	
	CTakeDamageInfo -= view_as<Address>(16*4);
	if(!b_NpcHasDied[pThis])
	{
		int index = NPCList.FindValue(EntIndexToEntRef(pThis), NPCData::Ref);
		if(index != -1)
		{
			NPCData npc;
			NPCList.GetArray(index, npc);
			int client = GetClientOfUserId(npc.LastHitId);
			int Health = GetEntProp(pThis, Prop_Data, "m_iHealth");
			Health *= -1;
			
			int overkill = RoundToNearest(npc.Damage - float(Health));
			
			if(client && IsClientInGame(client))
			{
				Calculate_And_Display_hp(client, pThis, npc.Damage, true, overkill);
			}
		}
		b_NpcHasDied[pThis] = true;
		ZR_ApplyKillEffects(pThis); //Do kill attribute stuff
		CClotBody npc = view_as<CClotBody>(pThis);
		SDKUnhook(pThis, SDKHook_OnTakeDamage, NPC_OnTakeDamage_Base);
		SDKUnhook(pThis, SDKHook_Think, Check_If_Stuck);
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
		
		if(IsValidEntity(npc.m_iSpawnProtectionEntity))
			RemoveEntity(npc.m_iSpawnProtectionEntity);
			
		if (EntRefToEntIndex(RaidBossActive) == pThis)
		{
			Raidboss_Clean_Everyone();
		}
		NPCDeath(pThis);
		/*
		#if defined ISSPECIALDEATHANIMATION
			RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));
			return MRES_Supercede;
		#else
		*/
		if(!npc.m_bDissapearOnDeath)
		{
			if(!npc.m_bGib)
			{
				SDKCall(g_hNextBotCombatCharacter_Event_Killed, pThis, CTakeDamageInfo);
				SDKCall(g_hCBaseCombatCharacter_Event_Killed,   pThis, CTakeDamageInfo);
			}
			else
			{
				float startPosition[3];
				float damageForce[3];
				npc.m_vecpunchforce(damageForce, false);
				
				
				if(npc.m_iBleedType == 1)
				{
					npc.PlayGibSound();
					if(npc.m_bIsGiant)
					{
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
						startPosition[2] += 64;
						Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, damageForce, true, true);
						startPosition[2] -= 15;
						Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, damageForce, false, true);
						startPosition[2] += 44;
						Place_Gib("models/Gibs/HGIBS.mdl", startPosition, damageForce, false, true);	
					}
					else
					{
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
						startPosition[2] += 42;
						Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, damageForce, true);
						startPosition[2] -= 10;
						Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, damageForce);
						startPosition[2] += 34;
						Place_Gib("models/Gibs/HGIBS.mdl", startPosition, damageForce);	
					}	
				}	
				else if(npc.m_iBleedType == 2)
				{
					npc.PlayGibSoundMetal();
					if(npc.m_bIsGiant)
					{
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
						startPosition[2] += 64;
						Place_Gib("models/gibs/helicopter_brokenpiece_03.mdl", startPosition, damageForce, true, false, true, true); //dont gigantify this one.
						startPosition[2] -= 15;
						Place_Gib("models/gibs/scanner_gib01.mdl", startPosition, damageForce, false, true);
						startPosition[2] += 44;
						Place_Gib("models/gibs/metal_gib2.mdl", startPosition, damageForce, false, true);	
					}
					else
					{
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
						startPosition[2] += 42;
						Place_Gib("models/gibs/helicopter_brokenpiece_03.mdl", startPosition, damageForce, true, false, true, true, true);
						startPosition[2] -= 10;
						Place_Gib("models/gibs/scanner_gib01.mdl", startPosition, damageForce, false, false, true);
						startPosition[2] += 34;
						Place_Gib("models/gibs/metal_gib2.mdl", startPosition, damageForce, false, false, true);	
					}	
				}	
			//	#endif					
				Do_Death_Frame_Later(EntIndexToEntRef(pThis));
				//RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));						
			}
		}
		else
		{	
			Do_Death_Frame_Later(EntIndexToEntRef(pThis));
			//RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));		
		}
	}
	else
	{	
		Do_Death_Frame_Later(EntIndexToEntRef(pThis));
		//RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));	
	}
	return MRES_Supercede;
}

public void Do_Death_Frame_Later(int ref)
{
	int pThis = EntRefToEntIndex(ref);
	if(IsValidEntity(pThis) && pThis > 0)
	{
		RemoveEntity(pThis);
	}
}
/*
public Action Check_Emergency_Reload(Handle Timer_Handle, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		//SOMETHING TERRIBLE HAPPEND!!! PLUGIN MUST RELOAD ITSELF AND KILL ALL EXISTING BASE_BOSSES THAT ARE FROM THIS PLUGIN INSTANTLY!!!
		//This can happen due to the plugin failing to correctly hook upton server restart, rendering winning/advancing IMPOSSIBLE.
		char buffer[64];
		for(int i=MAXENTITIES; i>MaxClients; i--)
		{
			if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
			{
				if(StrEqual(buffer, "base_boss"))
				{
					GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer))
					if(!StrContains(this_plugin_name, buffer))
					{
						RemoveEntity(i);
					}
				}
			}
		}
		static char plugin_name[256];
		GetPluginFilename(INVALID_HANDLE, plugin_name, sizeof(plugin_name));
		ServerCommand("sm plugins reload %s", plugin_name);
	}
	return Plugin_Handled;
}
*/

/*
//	models/Gibs/HGIBS.mdl
//	models/Gibs/HGIBS_scapula.mdl
//	models/Gibs/HGIBS_spine.mdl
//	models/Gibs/HGIBS_rib.mdl
//	models/gibs/antlion_gib_large_1.mdl //COLOR RED!
*/

public MRESReturn CTFBaseBoss_Ragdoll(int pThis, Handle hReturn, Handle hParams)  
{
	CClotBody npc = view_as<CClotBody>(pThis);
	float Push[3];
	npc.m_vecpunchforce(Push, false);
	ScaleVector(Push, 2.0);
	DHookSetParamVector(hParams, 2, view_as<float>(Push));
//	RequestFrames(Kill_Npc, 5, EntIndexToEntRef(pThis));		
	//Play Ragdolls correctly.
		
	DHookSetReturn(hReturn, true);
	return MRES_ChangedOverride;
}


public void Kill_Npc(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity) && entity > 0)
	{
		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); 	//Teleport them very far away as to not just stand and eat bullets.
																		//Dont do this too soon or else it MIGHT cause ragdolls and other stuff to actually
																		//not even apear, so just do it when they actually despawn, just to be safe.
	}
}

bool IsWalkEvent(int event)
{
	if (event == 7001 || event == 59 || event == 58 || event == 66 || event == 65 || event == 6004 || event == 6005 || event == 7005 || event == 7004 || event || 7001)
		return true;
		
	return false;
	
}

public MRESReturn CBaseAnimating_HandleAnimEvent(int pThis, Handle hParams)
{
	int event = DHookGetParamObjectPtrVar(hParams, 1, 0, ObjectValueType_Int);
//	PrintToChatAll("CBaseAnimating_HandleAnimEvent(%i, %i)", pThis, event);
	CClotBody npc = view_as<CClotBody>(pThis);
	
	
	switch(i_NpcInternalId[pThis])
	{
		case MEDIVAL_ARCHER:
		{
			HandleAnimEventMedival_Archer(pThis, event);
		}
		case MEDIVAL_SKIRMISHER:
		{
			HandleAnimEvent_MedivalSkirmisher(pThis, event);
		}	
		case MEDIVAL_CROSSBOW_MAN:
		{
			HandleAnimEventMedival_CrossbowMan(pThis, event);
		}
		case MEDIVAL_HANDCANNONEER:
		{
			HandleAnimEventMedival_HandCannoneer(pThis, event);
		}
		case MEDIVAL_ELITE_SKIRMISHER:
		{
			HandleAnimEvent_MedivalEliteSkirmisher(pThis, event);
		}
	}
	
	switch(npc.m_iNpcStepVariation)
	{
		case 1:
		{
			if(IsWalkEvent(event))
			{
				char strSound[64];
				float vSoundPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vSoundPos);
				vSoundPos[2] += 1.0;
				
				TR_TraceRayFilter(vSoundPos, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
				char material[PLATFORM_MAX_PATH]; TR_GetSurfaceName(null, material, PLATFORM_MAX_PATH);
				
				Format(strSound, sizeof(strSound), "player/footsteps/%s%i.wav", GetStepSoundForMaterial(material), GetRandomInt(1,4));
				
				npc.PlayStepSound(strSound,0.8, npc.m_iStepNoiseType);
			}
		}
		case 2:
		{
			if(IsWalkEvent(event))
			{
				npc.PlayStepSound(g_CombineSoldierStepSound[GetRandomInt(0, sizeof(g_CombineSoldierStepSound) - 1)], 0.8, npc.m_iStepNoiseType);
			}
		}
		case 3:
		{
			if(IsWalkEvent(event))
			{
				if(npc.m_flDoSpawnGesture < GetGameTime())
				{
					npc.PlayStepSound(g_PanzerStepSound[GetRandomInt(0, sizeof(g_PanzerStepSound) - 1)], 1.0, npc.m_iStepNoiseType);
				}
			}
		}
		case 4:
		{
			if(IsWalkEvent(event))
			{
				if(npc.m_flDoSpawnGesture < GetGameTime())
				{
					npc.PlayStepSound(g_CombineMetroStepSound[GetRandomInt(0, sizeof(g_CombineMetroStepSound) - 1)], 0.65, npc.m_iStepNoiseType);
				}
			}
		}
	}
	return MRES_Ignored;
}

public MRESReturn ILocomotion_GetGroundNormal(Address pThis, Handle hReturn, Handle hParams)	 { DHookSetReturnVector(hReturn,	view_as<float>( { 0.0, 0.0, 1.0 } ));  return MRES_Supercede; }
public MRESReturn ILocomotion_GetStepHeight(Address pThis, Handle hReturn, Handle hParams)	   { DHookSetReturn(hReturn, 17.0);	return MRES_Supercede; }
public MRESReturn ILocomotion_GetMaxAcceleration(Address pThis, Handle hReturn, Handle hParams)  { DHookSetReturn(hReturn, 5000.0); return MRES_Supercede; }
public MRESReturn ILocomotion_GetFrictionSideways(Address pThis, Handle hReturn, Handle hParams) { DHookSetReturn(hReturn, 3.0);	return MRES_Supercede; }
public MRESReturn ILocomotion_GetGravity(Address pThis, Handle hReturn, Handle hParams)		  { DHookSetReturn(hReturn, 800.0); return MRES_Supercede; }
public MRESReturn ILocomotion_ShouldCollideWithAlly(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	CClotBody npc = view_as<CClotBody>(otherindex);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede; 
	}	
	 //OPTIMISEEEEEEEEE!!!!!!!!
	 
	if(npc.bCantCollidieAlly) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	if(otherindex == 0)
	{
		DHookSetReturn(hReturn, true); 
		return MRES_Supercede;
	}

	
	DHookSetReturn(hReturn, true); 
	return MRES_Supercede;
}
public MRESReturn ILocomotion_ShouldCollideWithAllyInvince(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	CClotBody npc = view_as<CClotBody>(otherindex);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede; 
	}	
	 //OPTIMISEEEEEEEEE!!!!!!!!
	 
	if(npc.bCantCollidie) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	if(npc.bCantCollidieAlly) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	if(otherindex == 0)
	{
		DHookSetReturn(hReturn, true); 
		return MRES_Supercede;
	}

	
	DHookSetReturn(hReturn, true); 
	return MRES_Supercede;
}

public MRESReturn ILocomotion_ShouldCollideWithEnemy(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	CClotBody npc = view_as<CClotBody>(otherindex);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		if(npc.m_bThisEntityIgnored)
		{
			DHookSetReturn(hReturn, false); 
			return MRES_Supercede;
		}
		DHookSetReturn(hReturn, true); 
		return MRES_Supercede; 
	}
	 
	if(npc.bCantCollidie) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	if(otherindex == 0)
	{
		DHookSetReturn(hReturn, true); 
		return MRES_Supercede;
	}

	
	DHookSetReturn(hReturn, true); 
	return MRES_Supercede;
}

public MRESReturn ILocomotion_ShouldCollideWithEnemyIngoreBuilding(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	CClotBody npc = view_as<CClotBody>(otherindex);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		if(npc.m_bThisEntityIgnored)
		{
			DHookSetReturn(hReturn, false); 
			return MRES_Supercede;
		}
		DHookSetReturn(hReturn, true); 
		return MRES_Supercede; 
	}
	 
	if(npc.bCantCollidie) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	if(npc.bCantCollidieAlly) //no change in performance..., almost.
	{
		if(i_IsABuilding[otherindex])
		{
			DHookSetReturn(hReturn, false); 
			return MRES_Supercede;
		}
		DHookSetReturn(hReturn, true); 
		return MRES_Supercede;
	}
	if(otherindex == 0)
	{
		DHookSetReturn(hReturn, true); 
		return MRES_Supercede;
	}

	
	DHookSetReturn(hReturn, true); 
	return MRES_Supercede;
}
//2 * m_vecMaxs
public MRESReturn IBody_GetHullWidth_ISGIANT(Address pThis, Handle hReturn, Handle hParams)			  { DHookSetReturn(hReturn, 60.0); return MRES_Supercede; }
public MRESReturn IBody_GetHullHeight_ISGIANT(Address pThis, Handle hReturn, Handle hParams)			 { DHookSetReturn(hReturn, 120.0); return MRES_Supercede; }
public MRESReturn IBody_GetStandHullHeight_ISGIANT(Address pThis, Handle hReturn, Handle hParams)		{ DHookSetReturn(hReturn, 120.0); return MRES_Supercede; }

public MRESReturn IBody_GetHullWidth(Address pThis, Handle hReturn, Handle hParams)			  { DHookSetReturn(hReturn, 48.0); return MRES_Supercede; }
public MRESReturn IBody_GetHullHeight(Address pThis, Handle hReturn, Handle hParams)			 { DHookSetReturn(hReturn, 82.0); return MRES_Supercede; }
public MRESReturn IBody_GetStandHullHeight(Address pThis, Handle hReturn, Handle hParams)		{ DHookSetReturn(hReturn, 82.0); return MRES_Supercede; }
//npc.m_bISGIANT
//BOUNDING BOX FOR ENEMY TO RESPECT

stock bool IsLengthGreaterThan(float vector[3], float length)
{
	return (SquareRoot(GetVectorLength(vector, false)) > length * length);
}

public float clamp(float a, float b, float c) { return (a > c ? c : (a < b ? b : a)); }

stock float[] WorldSpaceCenter(int entity)
{
	float vecPos[3];
	SDKCall(g_hSDKWorldSpaceCenter, entity, vecPos);
	
	return vecPos;
}

public void InitNavGamedata()
{
	Handle hConf = LoadGameConfigFile("tf2.pets");

	navarea_count = GameConfGetAddress(hConf, "navarea_count");
	//PrintToServer("[CClotBody] Found \"navarea_count\" @ 0x%X", navarea_count);
	
	if(LoadFromAddress(navarea_count, NumberType_Int32) <= 0)
	{
		SetFailState("[CClotBody] No nav mesh!");
		return;
	}
	
	//TheNavAreas is nicely above navarea_count
	TheNavAreas = view_as<Address>(LoadFromAddress(navarea_count + view_as<Address>(0x4), NumberType_Int32));
	//PrintToServer("[CClotBody] Found \"TheNavAreas\" @ 0x%X", TheNavAreas);
	
	delete hConf;
}

stock NavArea PickRandomArea()
{
	int iAreaCount = LoadFromAddress(navarea_count, NumberType_Int32);
	
	//Pick a random goal area
	return view_as<NavArea>(LoadFromAddress(TheNavAreas + view_as<Address>(4 * GetRandomInt(0, iAreaCount - 1)), NumberType_Int32));
}

public bool FilterBaseActorsAndData(int entity, int contentsMask, any data)
{
	static char class[12];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(StrEqual(class, "base_boss")) return true;
	
	return !(entity == data);
}


public bool PluginBot_IsEntityTraversable(int bot_entidx, int other_entidx, TraverseWhenType when)
{
	if(other_entidx == 0) {
		return false;
	}
	
	if(other_entidx > 0 && other_entidx <= MaxClients) 
	{
		return true;
	}	
	
	CClotBody npc = view_as<CClotBody>(other_entidx);

	#if defined ISINVINCEABLEALLY || defined ISALLY
	if(npc.bCantCollidieAlly) //no change in performance..., almost.
	{
		return true;
	}
	#else
	if(npc.bCantCollidie) //no change in performance..., almost.
	{
		return true;
	}
	#endif
	
	if(when == IMMEDIATELY) {
		return false;
	}
	
	return false;
}

public void PluginBot_Approach(int bot_entidx, const float vec[3])
{
	CClotBody npc = view_as<CClotBody>(bot_entidx);
	npc.Approach(vec);	
	npc.FaceTowards(vec);
}

public bool BulletAndMeleeTrace(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(entity > 0 && entity <= MaxClients) 
	{
		if(TeutonType[entity])
		{
			return false;
		}
	}
	
	CClotBody npc = view_as<CClotBody>(entity);
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}	
	else if(StrEqual(class, "base_boss"))
	{
			//Yes its double but i need it here too for npc vs npc, sorry.
		if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		{
			return false;				
		}
		else if (npc.bCantCollidie && npc.bCantCollidieAlly) //If both are on, then that means the npc shouldnt be invis and stuff
		{
			return false;
		}
	}
	
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	
	//if anything else is team
	
	if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	
	if(npc.m_bThisEntityIgnored)
	{
		return false;
	}
	return !(entity == iExclude);
}

public bool BulletAndMeleeTracePlayerAndBaseBossOnly(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(entity > 0 && entity <= MaxClients) 
	{
		if(TeutonType[entity])
		{
			return false;
		}
	}
	
	CClotBody npc = view_as<CClotBody>(entity);
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}	
	else if(StrContains(class, "obj_", false) != -1)
	{
		return false;
	}
	
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	
	//if anything else is team
	
	if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	
	if(npc.m_bThisEntityIgnored)
	{
		return false;
	}
	if(StrEqual(class, "base_boss"))
	{
		return true;
	}
	return !(entity == iExclude);
}

public bool BulletAndMeleeTraceDontIgnoreBaseBoss(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	/*
	if(other_entidx > 0 && other_entidx <= MaxClients) 
	{
		return true;
	}
	*/
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}
	
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	
	else if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
		
	
	return !(entity == iExclude);
}

public float PluginBot_PathCost(int bot_entidx, NavArea area, NavArea from_area, float length)
{
	float dist;
	if (length != 0.0) 
	{
		dist = length;
	}
	else 
	{
		float vecCenter[3], vecFromCenter[3];
		area.GetCenter(vecCenter);
		from_area.GetCenter(vecFromCenter);
		
		float vecSubtracted[3]
		SubtractVectors(vecCenter, vecFromCenter, vecSubtracted)
		
		dist = GetVectorLength(vecSubtracted);
	}
	
	/*
	float multiplier = 1.0;
	
	 very similar to CTFBot::TransientlyConsistentRandomValue 
	
	int seed = RoundToFloor(GetGameTime() * 0.1) + 1;
	seed *= area.GetID();
	seed *= bot_entidx;
	
	 huge random cost modifier [0, 100] for non-ISGIANT bots! 
	
	multiplier += (GetRandomFloat(0.0, 1.0)) + 1.0) * 25.0;
	*/
	
	float cost = dist * ((1.0 + (GetRandomFloat(0.0, 1.0)) + 1.0) * 25.0);
	
	return from_area.GetCostSoFar() + cost;
}

public bool PluginBot_Jump(int bot_entidx, float vecPos[3])
{
	float Jump_1_frame[3];
	GetEntPropVector(bot_entidx, Prop_Data, "m_vecOrigin", Jump_1_frame);
	Jump_1_frame[2] += 20.0;
	
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	if(b_IsGiant[bot_entidx])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}			
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );		
	}

	if (!IsSpaceOccupiedDontIgnorePlayers(Jump_1_frame, hullcheckmins, hullcheckmaxs, bot_entidx))//The boss will start to merge with shits, cancel out velocity.
	{
		float vecNPC[3], vecJumpVel[3];
		GetEntPropVector(bot_entidx, Prop_Data, "m_vecOrigin", vecNPC);
		
		vecNPC[2] -= 20.0;
		float gravity = GetEntPropFloat(bot_entidx, Prop_Data, "m_flGravity");
		if(gravity <= 0.0)
			gravity = FindConVar("sv_gravity").FloatValue;
		
		// How fast does the headcrab need to travel to reach the position given gravity?
		float flActualHeight = vecPos[2] - vecNPC[2];
		float height = flActualHeight;
		if ( height < 72 )
		{
			height = 72.0;
		}
		float additionalHeight = 0.0;
		
		if ( height < 35 )
		{
			additionalHeight = 50.0;
		}
		
		height += additionalHeight;
		
		float speed = SquareRoot( 2 * gravity * height );
		float time = speed / gravity;
	
		time += SquareRoot( (2 * additionalHeight) / gravity );
		
		// Scale the sideways velocity to get there at the right time
		SubtractVectors( vecPos, vecNPC, vecJumpVel );
		vecJumpVel[0] /= time;
		vecJumpVel[1] /= time;
		vecJumpVel[2] /= time;
	
		// Speed to offset gravity at the desired height.
		vecJumpVel[2] = speed;
		
		// Don't jump too far/fast.
		float flJumpSpeed = GetVectorLength(vecJumpVel);
		float flMaxSpeed = 1250.0;
		if ( flJumpSpeed > flMaxSpeed )
		{
			vecJumpVel[0] *= flMaxSpeed / flJumpSpeed;
			vecJumpVel[1] *= flMaxSpeed / flJumpSpeed;
			vecJumpVel[2] *= flMaxSpeed / flJumpSpeed;
		}
		CClotBody npc = view_as<CClotBody>(bot_entidx);
		//npc.SetOrigin(Jump_1_frame);
		//float No_Vel[3];
		//npc.SetVelocity(No_Vel);
		TeleportEntity(npc.index, Jump_1_frame, NULL_VECTOR, NULL_VECTOR);
		npc.Jump();
		npc.SetVelocity(vecJumpVel);
		
		/*char JumpAnim[32];
		npc.JumpAnim(JumpAnim, sizeof(JumpAnim));
		
		if(!StrEqual(JumpAnim, ""))
		{
			npc.SetAnimation(JumpAnim);
		}
		*/
		
		return true;
	}
	return false;
}

public void PluginBot_PathSuccess(int bot_entidx, Address path)
{
	PF_StopPathing(bot_entidx);
	view_as<CClotBody>(bot_entidx).m_bPathing = true;
	//view_as<CClotBody>(bot_entidx).m_flNextTargetTime = GetGameTime() + GetRandomFloat(1.0, 4.0);
}

public void PluginBot_MoveToSuccess(int bot_entidx, Address path)
{
	PF_StopPathing(bot_entidx);
	view_as<CClotBody>(bot_entidx).m_bPathing = false;
	//view_as<CClotBody>(bot_entidx).m_flNextTargetTime = GetGameTime() + GetRandomFloat(1.0, 4.0);
}

public void PluginBot_MoveToFailure(int bot_entidx, Address path, MoveToFailureType type)
{
	PF_StopPathing(bot_entidx);
	view_as<CClotBody>(bot_entidx).m_bPathing = false;
	//view_as<CClotBody>(bot_entidx).m_flNextTargetTime = GetGameTime() + GetRandomFloat(1.0, 4.0);
}

stock bool IsEntityAlive(int index)
{
	if(IsValidEntity(index) && index > 0)
	{
		if(index > MaxClients)
		{
			if(GetEntProp(index, Prop_Data, "m_iHealth") > 0)
			{
				return true;	
			}
			else
			{
				return false;
			}	
		}
		else
		{
			if(!IsPlayerAlive(index))
			{
				return false;	
			}
			else
			{
				return true;
			}
		}
	}
	else
	{
		return false;
	}
}
stock bool IsValidEnemy(int index, int enemy, bool camoDetection=false)
{
	if(IsValidEntity(enemy))
	{
		static char strClassname[16];
		GetEntityClassname(enemy, strClassname, sizeof(strClassname));
		if(StrEqual(strClassname, "player") || StrEqual(strClassname, "base_boss"))
		{
			CClotBody npc = view_as<CClotBody>(enemy);
			if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(enemy, Prop_Send, "m_iTeamNum"))
			{
				return false;
			}
			if(camoDetection)
			{
				if(npc.m_bThisEntityIgnored)
				{
					return false;
				}
				else
				{
					return IsEntityAlive(enemy);
				}
			}
			else
			{
				if(npc.m_bThisEntityIgnored || npc.m_bCamo)
				{
					return false;
				}
				else
				{
					return IsEntityAlive(enemy);
				}
			}	
		}
		else if(StrEqual(strClassname, "obj_dispenser") || StrEqual(strClassname, "obj_teleporter") || StrEqual(strClassname, "obj_sentrygun"))
		{
			CClotBody npc = view_as<CClotBody>(enemy);
			if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(enemy, Prop_Send, "m_iTeamNum"))
			{
				return false;
			}
			
			else if(npc.bBuildingIsStacked)
			{
				return false;
			}
			
			else if(npc.bBuildingIsPlaced)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	
	return false;
}

stock bool IsValidAllyPlayer(int index, int Ally)
{
	if(IsValidClient(Ally))
	{
		CClotBody npc = view_as<CClotBody>(Ally);
		if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(Ally, Prop_Send, "m_iTeamNum"))
		{
			if(npc.m_bThisEntityIgnored)
			{
				return false;
			}
			else
			{
				return IsEntityAlive(Ally);
			}
		}
	}
	
	return false;
}


stock int GetClosestTarget(int entity, bool Onlyplayers = false, float fldistancelimit = 999999.9, bool camoDetection=false)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = -1; 
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if (IsValidClient(i))
		{
			CClotBody npc = view_as<CClotBody>(i);
			if (TF2_GetClientTeam(i)!=view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum")) && !npc.m_bThisEntityIgnored && IsEntityAlive(i)) //&& CheckForSee(i)) we dont even use this rn and probably never will.
			{
				if(camoDetection)
				{
					float EntityLocation[3], TargetLocation[3]; 
					GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
					GetClientAbsOrigin( i, TargetLocation ); 
					
					
					float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
					if(distance < fldistancelimit)
					{
						if( TargetDistance ) 
						{
							if( distance < TargetDistance ) 
							{
								ClosestTarget = i; 
								TargetDistance = distance;		  
							}
						} 
						else 
						{
							ClosestTarget = i; 
							TargetDistance = distance;
						}	
					}	
				}
				else if (!npc.m_bCamo)
				{
					float EntityLocation[3], TargetLocation[3]; 
					GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
					GetClientAbsOrigin( i, TargetLocation ); 
					
					
					float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
					if(distance < fldistancelimit)
					{
						if( TargetDistance ) 
						{
							if( distance < TargetDistance ) 
							{
								ClosestTarget = i; 
								TargetDistance = distance;		  
							}
						} 
						else 
						{
							ClosestTarget = i; 
							TargetDistance = distance;
						}	
					}	
				}			
			}
		}
	}
	if(!Onlyplayers) //Make sure that they completly ignore barricades during raids
	{
		for (int pass = 0; pass <= 2; pass++)
		{
			static char classname[1024];
			if (pass == 0) classname = "obj_sentrygun";
			else if (pass == 1) classname = "obj_dispenser";
		//	else if (pass == 2) classname = "obj_teleporter";
			else if (pass == 2) classname = "base_boss";
	
			int i = MaxClients + 1;
			while ((i = FindEntityByClassname(i, classname)) != -1)
			{
				if (GetEntProp(entity, Prop_Send, "m_iTeamNum")!=GetEntProp(i, Prop_Send, "m_iTeamNum")) 
				{
					CClotBody npc = view_as<CClotBody>(i);
					if(pass != 2)
					{
						if(!npc.bBuildingIsStacked && npc.bBuildingIsPlaced && !IsValidEntity(EntRefToEntIndex(RaidBossActive))) //make sure it doesnt target buildings that are picked up and special cases with special building types that arent ment to be targeted
						{
							float EntityLocation[3], TargetLocation[3]; 
							GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
							GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
								
								
							float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
							if(distance < fldistancelimit)
							{
								if( TargetDistance ) 
								{
									if( distance < TargetDistance ) 
									{
										ClosestTarget = i; 
										TargetDistance = distance;		  
									}
								} 
								else 
								{
									ClosestTarget = i; 
									TargetDistance = distance;
								}	
							}
	
						}			
					}		
					else
					{
						if(!npc.m_bThisEntityIgnored && GetEntProp(i, Prop_Data, "m_iHealth") > 0) //Check if dead or even targetable
						{
							if(camoDetection)
							{
								float EntityLocation[3], TargetLocation[3]; 
								GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
								GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
								float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
								if(distance < fldistancelimit)
								{
									if( TargetDistance ) 
									{
										if( distance < TargetDistance ) 
										{
											ClosestTarget = i; 
											TargetDistance = distance;		  
										}
									} 
									else 
									{
										ClosestTarget = i; 
										TargetDistance = distance;
									}	
								}	
							}
							else if (!npc.m_bCamo)
							{
								float EntityLocation[3], TargetLocation[3]; 
								GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
								GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
								float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
								if(distance < fldistancelimit)
								{
									if( TargetDistance ) 
									{
										if( distance < TargetDistance ) 
										{
											ClosestTarget = i; 
											TargetDistance = distance;		  
										}
									} 
									else 
									{
										ClosestTarget = i; 
										TargetDistance = distance;
									}	
								}	
							}
						}
					}
				}
			}
		}
	}
	return ClosestTarget; 
}

stock int GetClosestAllyPlayer(int entity, bool Onlyplayers = false)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if (IsValidClient(i))
		{
			CClotBody npc = view_as<CClotBody>(i);
			if (TF2_GetClientTeam(i)==view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum")) && !npc.m_bThisEntityIgnored && IsEntityAlive(i)) //&& CheckForSee(i)) we dont even use this rn and probably never will.
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetClientAbsOrigin( i, TargetLocation ); 
				
				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						ClosestTarget = i; 
						TargetDistance = distance;		  
					}
				} 
				else 
				{
					ClosestTarget = i; 
					TargetDistance = distance;
				}					
			}
		}
	}
	return ClosestTarget; 
}
/*
stock bool CheckForSee(int client)
{
	if (TF2_IsPlayerInCondition(client,TFCond_Cloaked) || TF2_IsPlayerInCondition(client,TFCond_Disguised) || TF2_IsPlayerInCondition(client,TFCond_Stealthed) || TF2_IsPlayerInCondition(client,TFCond_StealthedUserBuffFade))
		return false;
		
	return true;
}
*/

stock bool IsSpaceOccupiedIgnorePlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayDontHitPlayersOrEntity, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

stock bool IsSpaceOccupiedDontIgnorePlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayHitPlayers, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

public bool TraceRayHitPlayers(int entity,int mask,any data)
{
	if (entity == 0) return true;
	
	if (entity <= MaxClients) return true;
	
	return false;
}

public bool TraceRayDontHitPlayersOrEntity(int entity,int mask,any data)
{
	if (entity == 0) return true;
	
	return false;
}

public void Check_If_Stuck(int iNPC)
{
//	PrintToChatAll("%i",GetEdictFlags(iNPC));
//	SetEdictFlags(iNPC, 133); //Remove this if it causes lag
//	PrintToChatAll("%i"GetEdictFlags(iNPC));
	CClotBody npc = view_as<CClotBody>(iNPC);
	/*
	if(npc.m_flCheckNavCooldown < GetGameTime() && npc.m_flJumpCooldown < GetGameTime())
	{
		npc.m_flCheckNavCooldown = GetGameTime() + 0.1; //A little delay to ease server performance
		NavArea area = TheNavMesh.GetNearestNavArea_Vec(WorldSpaceCenter(npc.index), true);
		if(area != NavArea_Null)
		{
			//NavArea.HasAttributes(NavAttributeType bits);
			NavArea nav_area_property = view_as<NavArea>(area);
			
			if(nav_area_property.HasAttributes(NAV_MESH_JUMP))
			{
				npc.m_flJumpStartTime = GetGameTime() + 1.0;
				PluginBot_Jump_Now(npc.index);
			}
		}
	}
	
	*/
	if (!npc.IsOnGround())
	{
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];
		if(b_IsGiant[iNPC])
		{
		 	hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
			hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
		}
		else
		{
			
			hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
		}
		
		//invert to save 1 frame per 3 minutes
	
		hullcheckmins[0] -= 10.0;
		hullcheckmins[1] -= 10.0;
		
		hullcheckmaxs[0] += 10.0;
		hullcheckmaxs[1] += 10.0;
		
		hullcheckmins[2] -= 16.0; //STEP HEIGHT
		hullcheckmaxs[2] += 16.0;
		
		float flMyPos[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecOrigin",flMyPos);
		
		if (!npc.g_bNPCVelocityCancel && IsSpaceOccupiedIgnorePlayers(flMyPos, hullcheckmins, hullcheckmaxs, iNPC))//The boss will start to merge with shits, cancel out velocity.
		{
			float vec3Origin[3];
			npc.SetVelocity(vec3Origin);
			npc.g_bNPCVelocityCancel = true;
		}
	}
	else
	{
		npc.g_bNPCVelocityCancel = false;
	}
}

//using normal ontakedamage will make it abit more inaccurate but it will work
//Using post will make it too late and it wont even get called as the npc has already died, resulting in post not calling anymore
//Have to use this, for now, if that one bug still happens with unhooks and dhooks then i will revert back.

static float f_CooldownForHurtParticle[MAXENTITIES];	

public Action NPC_OnTakeDamage_Base(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	/*
	if(attacker < MaxClients && attacker > 0) //make sure players cannot hurt allied npcs.
	//Do not use team checks, they actually lag alot...
	{
		return Plugin_Handled;
	}
	*/
	CClotBody npc = view_as<CClotBody>(victim);
	npc.m_vecpunchforce(damageForce, true);
	npc.m_bGib = false;
	
	if(f_IsThisExplosiveHitscan[attacker] == GetGameTime())
	{
		npc.m_vecpunchforce(CalculateDamageForceSelfCalculated(attacker, 10000.0), true);
		damagetype |= DMG_BULLET; //add bullet logic
		damagetype &= ~DMG_BLAST; //remove blast logic			
	}
	
	if((damagetype & DMG_CLUB)) //Needs to be here because it already gets it from the top.
	{
		if(Medival_Difficulty_Level != 0.0)
		{
			damage *= Medival_Difficulty_Level;
		}
		damage *= fl_MeleeArmor[victim];
	}
	else if(!(damagetype & DMG_SLASH))
	{
		if(Medival_Difficulty_Level != 0.0)
		{
			damage *= Medival_Difficulty_Level;
		}
		damage *= fl_RangedArmor[victim];
	}
	//No resistances towards slash as its internal.
	
	
	
	if(!npc.m_bDissapearOnDeath) //Make sure that if they just vanish, its always false. so their deathsound plays.
	{
		if((damagetype & DMG_BLAST))
		{
			npc.m_bGib = true;
		}
		else if(damage > (GetEntProp(victim, Prop_Data, "m_iMaxHealth") * 1.5))
		{
			npc.m_bGib = true;
		}
	}
	if(damagePosition[0] != 0.0) //If there is no pos, then dont.
	{
		if(!(damagetype & (DMG_SHOCK)))
		{
			if (f_CooldownForHurtParticle[victim] < GetGameTime())
			{
				f_CooldownForHurtParticle[victim] = GetGameTime() + 0.1;
				if(npc.m_iBleedType == 1)
				{
					TE_ParticleInt(g_particleImpactFlesh, damagePosition);
					TE_SendToAll();
				}
				else if (npc.m_iBleedType == 2)
				{
					damagePosition[2] -= 40.0;
					TE_ParticleInt(g_particleImpactMetal, damagePosition);
					TE_SendToAll();
				}
				else if (npc.m_iBleedType == 3)
				{
					TE_ParticleInt(g_particleImpactRubber, damagePosition);
					TE_SendToAll();
				}
			}
		}
	}
	return Plugin_Continue;
	//return CClotBodyDamaged_flare(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

public void Custom_Knockback(int attacker, int enemy, float knockback)
{
	if(enemy <= MaxClients)
	{							
		float vAngles[3], vDirection[3];
										
		GetEntPropVector(attacker, Prop_Data, "m_angRotation", vAngles); 
										
		if(vAngles[0] > -45.0)
		{
			vAngles[0] = -45.0;
		}
										
		GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
			
		float Attribute_Knockback = Attributes_FindOnPlayer(enemy, 252, true, 1.0);	
		
		knockback *= Attribute_Knockback;
		
		knockback *= 0.75; //oops, too much knockback now!
						
		ScaleVector(vDirection, knockback);
		
		float newVel[3];
		
		newVel[0] = GetEntPropFloat(enemy, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(enemy, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(enemy, Prop_Send, "m_vecVelocity[2]");
						
		for (new i = 0; i < 3; i++)
		{
			vDirection[i] += newVel[i];
		}
															
		TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, vDirection); 
	}
}

public int Can_I_See_Enemy(int attacker, int enemy)
{
	Handle trace; 
	float pos_npc[3]; GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", pos_npc);
	float pos_enemy[3]; GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", pos_enemy);
	pos_npc[2] += 45.0;
	pos_enemy[2] += 35.0;
	
	trace = TR_TraceRayFilterEx(pos_npc, pos_enemy, MASK_NPCSOLID, RayType_EndPoint, BulletAndMeleeTrace, attacker);
	int Traced_Target;
		
//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//	TE_SetupBeamPoints(pos_npc, pos_enemy, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//	TE_SendToAll();
		
	Traced_Target = TR_GetEntityIndex(trace);
	delete trace;
	return Traced_Target;
}

/*
void RequestFrames(RequestFrameCallback func, int frames, any data=0)
{
	DataPack pack = new DataPack();
	pack.WriteFunction(func);
	pack.WriteCell(data);
	pack.WriteCell(frames);
	RequestFrame(RequestFramesCallback, pack);
}

public void RequestFramesCallback(DataPack pack)
{
	pack.Reset();
	RequestFrameCallback func = view_as<RequestFrameCallback>(pack.ReadFunction());
	any data = pack.ReadCell();

	int frames = pack.ReadCell();
	if(frames < 2)
	{
		RequestFrame(func, data);
		delete pack;
	}
	else
	{
		pack.Position--;
		pack.WriteCell(frames-1, false);
		RequestFrame(RequestFramesCallback, pack);
	}
}
*/


//	models/Gibs/HGIBS.mdl
//	models/Gibs/HGIBS_scapula.mdl
//	models/Gibs/HGIBS_spine.mdl
//	models/Gibs/HGIBS_rib.mdl
//	models/gibs/antlion_gib_large_1.mdl //COLOR RED!



static void Place_Gib(const char[] model, float pos[3], float vel[3], bool Reduce_masively = false, bool big_gibs = false, bool metal_colour = false, bool Rotate = false, bool smaller_gibs = false)
{
	int prop = CreateEntityByName("prop_physics_multiplayer");
	if(!IsValidEntity(prop))
		return;
	CClotBody npc = view_as<CClotBody>(prop);
	DispatchKeyValue(prop, "model", model);
	DispatchKeyValue(prop, "physicsmode", "2");
	DispatchKeyValue(prop, "massScale", "1.0");
	DispatchKeyValue(prop, "spawnflags", "6");
/*
	TF2_CreateGlow(prop, model, client, color);

	char buffer[16];
	FormatEx(buffer, sizeof(buffer), "rpg_item_%d", index);
	DispatchKeyValue(prop, "targetname", buffer);

	static float vel[3];
	vel[0] = GetRandomFloat(-160.0, 160.0);
	vel[1] = GetRandomFloat(-160.0, 160.0);
	vel[2] = GetRandomFloat(0.0, 160.0);
	pos[2] += 20.0;
	*/
	/*
	Pow(vel[0], 0.5);
	Pow(vel[1], 0.5);
	Pow(vel[2], 0.5);
	*/
	if(big_gibs)
	{
		DispatchKeyValue(prop, "modelscale", "1.5");
	}
	if(smaller_gibs)
	{
		DispatchKeyValue(prop, "modelscale", "0.8");
	}
	if(Reduce_masively)
		ScaleVector(vel, 0.02);
		
	if(!Rotate)
	{
		TeleportEntity(prop, pos, NULL_VECTOR, NULL_VECTOR);
	}
	else
	{
		TeleportEntity(prop, pos, {90.0,0.0,0.0}, NULL_VECTOR);
	}
	DispatchSpawn(prop);
	TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);
//	SetEntProp(prop, Prop_Send, "m_CollisionGroup", 2);

	SetEntityCollisionGroup(prop, 2); //COLLISION_GROUP_DEBRIS_TRIGGER
	SDKHook(prop, SDKHook_ShouldCollide, Gib_ShouldCollide);
	if(!metal_colour)
	{
		npc.DispatchParticleEffect(prop, "blood_impact_backscatter", pos, NULL_VECTOR, NULL_VECTOR, 1,PATTACH_ABSORIGIN_FOLLOW);
		SetEntityRenderColor(prop, 255, 0, 0, 255);
	}
	else
	{
		pos[2] -= 40.0;
		npc.DispatchParticleEffect(prop, "bot_impact_heavy", pos, NULL_VECTOR, NULL_VECTOR, 1,PATTACH_ABSORIGIN_FOLLOW);	
	}
	CreateTimer(GetRandomFloat(2.0, 3.0), Timer_RemoveEntity_Prop, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
//	CreateTimer(1.5, Timer_DisableMotion, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RemoveEntity_Prop(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		SDKUnhook(entity, SDKHook_ShouldCollide, Gib_ShouldCollide);
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public Action Timer_RemoveEntityPanzer(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		float angles[3];
		view_as<CClotBody>(entity).GetAttachment("jetpack_R", pos, angles);
		
		TE_Particle("rd_robot_explosion", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
		
		view_as<CClotBody>(entity).GetAttachment("jetpack_L", pos, angles);
		
		TE_Particle("rd_robot_explosion", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public Action Timer_RemoveEntityOverlord(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		float angles[3];
		view_as<CClotBody>(entity).GetAttachment("middle_body_part", pos, angles);
		
		TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}

public bool Gib_ShouldCollide(int client, int collisiongroup, int contentsmask, bool originalResult)
{
	return false;
} 

stock char[] GetStepSoundForMaterial(const char[] material)
{
	char sound[32]; sound = "concrete";
	
	if (StrContains(material, "wood", false) != -1)
	{
		sound = "wood";
	}
	else if (StrContains(material, "Metal", false) != -1)
	{
		sound = "metal";
	}
	else if (StrContains(material, "Tile", false) != -1)
	{
		sound = "tile";
	}
	else if (StrContains(material, "Concrete", false) != -1)
	{
		sound = "concrete";
	}
	else if (StrContains(material, "Gravel", false) != -1)
	{
		sound = "sravel";
	}
	else if (StrContains(material, "ChainLink", false) != -1)
	{
		sound = "chainlink";
	}
	else if (StrContains(material, "Flesh", false) != -1)
	{
		sound = "flesh";
	}
	else if (StrContains(material, "Grass", false) != -1)
	{
		sound = "grass";
	}
	
	return sound;
}
/*
public bool PluginBot_NormalJump(int bot_entidx, float vecPos[3], const float dir[3])
{
	return view_as<CClotBody>(bot_entidx).PluginBot_Jump_Now(vecPos, dir);
}
*/

public bool PluginBot_Jump_Now(int bot_index)
{
	CClotBody npc = view_as<CClotBody>(bot_index);
	float Jump_1_frame[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Jump_1_frame);
	Jump_1_frame[2] += 20.0;
	
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	if(b_IsGiant[bot_index])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}			
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );		
	}
	
	if (!IsSpaceOccupiedDontIgnorePlayers(Jump_1_frame, hullcheckmins, hullcheckmaxs, npc.index))//The boss will start to merge with shits, cancel out velocity.
	{
		float Save_Old_Pos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Save_Old_Pos);
		npc.m_vecLastValidPosJump(Save_Old_Pos, true);
		float vecJumpVel[3];
		npc.m_flJumpCooldown = GetGameTime() + 1.5;
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsVelocity", vecJumpVel);
		
		vecJumpVel[2] = 350.0;
		
		npc.Jump();
		vecJumpVel[0] = 0.0;
		vecJumpVel[1] = 0.0;
		SetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Jump_1_frame);
		CreateTimer(0.1, Did_They_Get_Suck, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		npc.SetVelocity(vecJumpVel);
		
	}
	return true;
}

public Action Did_They_Get_Suck(Handle cut_timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		if (npc.m_flJumpStartTime < GetGameTime() + 0.1)
		{
			float Jump_1_frame[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Jump_1_frame);
			
			static float hullcheckmaxs[3];
			static float hullcheckmins[3];
			if(b_IsGiant[entity])
			{
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
			}			
			else
			{
				hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );		
			}
			
			if (IsSpaceOccupiedDontIgnorePlayers(Jump_1_frame, hullcheckmins, hullcheckmaxs, npc.index))//The boss will start to merge with shits, cancel out velocity.
			{
				float Save_Old_Pos[3];
				npc.m_vecLastValidPosJump(Save_Old_Pos, false);
				if(!IsSpaceOccupiedDontIgnorePlayers(Save_Old_Pos, hullcheckmins, hullcheckmaxs, npc.index))
				{
					SetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Save_Old_Pos);
					KillTimer(cut_timer);
				}
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


stock void TE_Particle(const char[] Name, float origin[3]=NULL_VECTOR, float start[3]=NULL_VECTOR, float angles[3]=NULL_VECTOR, int entindex=-1, int attachtype=-1, int attachpoint=-1, bool resetParticles=true, int customcolors=0, float color1[3]=NULL_VECTOR, float color2[3]=NULL_VECTOR, int controlpoint=-1, int controlpointattachment=-1, float controlpointoffset[3]=NULL_VECTOR, float delay=0.0)
{
	// find string table
	int tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE)
	{
//		LogError2("[Plugin] Could not find string table: ParticleEffectNames");
		return;
	}

	// find particle index
	static char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	for(int i; i<count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}

	if(stridx == INVALID_STRING_INDEX)
	{
//		LogError2("[Boss] Could not find particle: %s", Name);
		return;
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);

	if(entindex != -1)
		TE_WriteNum("entindex", entindex);

	if(attachtype != -1)
		TE_WriteNum("m_iAttachType", attachtype);

	if(attachpoint != -1)
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);

	TE_WriteNum("m_bResetParticles", resetParticles ? 1:0);
	if(customcolors)
	{
		TE_WriteNum("m_bCustomColors", customcolors);
		TE_WriteVector("m_CustomColors.m_vecColor1", color1);
		if(customcolors == 2)
			TE_WriteVector("m_CustomColors.m_vecColor2", color2);
	}

	if(controlpoint != -1)
	{
		TE_WriteNum("m_bControlPoint1", controlpoint);
		if(controlpointattachment != -1)
		{
			TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", controlpointattachment);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", controlpointoffset[0]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", controlpointoffset[1]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", controlpointoffset[2]);
		}
	}

	TE_SendToAll(delay);
}

stock int FireBullet(int m_pAttacker, int iWeapon, float m_vecSrc[3], float m_vecDirShooting[3], float m_flDamage, float m_flDistance, int nDamageType, const char[] tracerEffect, int client = -1, float bonus_entity_damage = 5.0, const char[] szAttachment = "muzzle")
{
	float vecEnd[3];
	vecEnd[0] = m_vecSrc[0] + m_vecDirShooting[0] * m_flDistance; 
	vecEnd[1] = m_vecSrc[1] + m_vecDirShooting[1] * m_flDistance;
	vecEnd[2] = m_vecSrc[2] + m_vecDirShooting[2] * m_flDistance;
	
	// Fire a bullet (ignoring the shooter).
	Handle trace = TR_TraceRayFilterEx(m_vecSrc, vecEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, m_pAttacker);


	if ( TR_GetFraction(trace) < 1.0 )
	{
		// Verify we have an entity at the point of impact.
		if(TR_GetEntityIndex(trace) == -1)
		{
			delete trace;
			return -1;
		}
		
		float endpos[3];	TR_GetEndPosition(endpos, trace);
		
		if(TR_GetEntityIndex(trace) <= 0 || TR_GetEntityIndex(trace) > MaxClients)
		{
			float vecNormal[3];	TR_GetPlaneNormal(trace, vecNormal);
			GetVectorAngles(vecNormal, vecNormal);
			static char class[12];
			GetEntityClassname(TR_GetEntityIndex(trace), class, sizeof(class));
			
			if(StrEqual(class, "base_boss"))
			{
				CreateParticle("blood_impact_backscatter", endpos, vecNormal);
			}
			else
			{
				CreateParticle("impact_concrete", endpos, vecNormal);
			}
		}
		
		// Regular impact effects.
		char effect[PLATFORM_MAX_PATH];
		Format(effect, PLATFORM_MAX_PATH, "%s", tracerEffect);
		
		if (tracerEffect[0])
		{
			if ( nDamageType & DMG_CRIT )
			{
				Format( effect, sizeof(effect), "%s_crit", tracerEffect );
			}

			float origin[3], angles[3];
			view_as<CClotBody>(iWeapon).GetAttachment(szAttachment, origin, angles);
			ShootLaser(iWeapon, effect, origin, endpos, false );
		}
		
	//	TE_SetupBeamPoints(m_vecSrc, endpos, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 0.1, 0.1, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	//	TE_SendToAll();
		if(client != -1)
		{
			if(IsValidEnemy(m_pAttacker, TR_GetEntityIndex(trace)))
				SDKHooks_TakeDamage(TR_GetEntityIndex(trace), m_pAttacker, client, m_flDamage, nDamageType, -1, CalculateBulletDamageForce(m_vecDirShooting, 1.0), endpos); //any bullet type will deal 5x the damage, usually
		}
		else
		{
			if(IsValidEnemy(m_pAttacker, TR_GetEntityIndex(trace)) && TR_GetEntityIndex(trace) <= MaxClients)
				SDKHooks_TakeDamage(TR_GetEntityIndex(trace), m_pAttacker, m_pAttacker, m_flDamage, nDamageType, -1, CalculateBulletDamageForce(m_vecDirShooting, 1.0), endpos);
			else if(IsValidEnemy(m_pAttacker, TR_GetEntityIndex(trace)) && TR_GetEntityIndex(trace) > MaxClients)
				SDKHooks_TakeDamage(TR_GetEntityIndex(trace), m_pAttacker, m_pAttacker, m_flDamage * bonus_entity_damage, nDamageType, -1, CalculateBulletDamageForce(m_vecDirShooting, 1.0), endpos); //any bullet type will deal 5x the damage, usually
		}
		
	}
	int hurt_who = TR_GetEntityIndex(trace);
	delete trace;
	return hurt_who;
}

float[] CalculateBulletDamageForce( const float vecBulletDir[3], float flScale )
{
	float vecForce[3]; vecForce = vecBulletDir;
	NormalizeVector( vecForce, vecForce );
	ScaleVector(vecForce, FindConVar("phys_pushscale").FloatValue);
	ScaleVector(vecForce, flScale);
	return vecForce;
}

stock bool makeexplosion(int attacker = 0, int inflictor = -1, float attackposition[3],  char[] weaponname = "", int magnitude = 200, int radiusoverride = 200, float damageforce = 200.0, int flags = 0)
{

		
		int explosion = CreateEntityByName("env_explosion");
		
		if(explosion != -1)
		{
			DispatchKeyValueVector(explosion, "Origin", attackposition);
			
			char intbuffer[64];
			IntToString(magnitude, intbuffer, 64);
			DispatchKeyValue(explosion,"iMagnitude", intbuffer);
			if(radiusoverride > 0)
			{
				IntToString(radiusoverride, intbuffer, 64);
				DispatchKeyValue(explosion,"iRadiusOverride", intbuffer);
			}
			
			if(damageforce > 0.0)
				DispatchKeyValueFloat(explosion,"DamageForce", damageforce);
	
			if(flags != 0)
			{
				IntToString(flags, intbuffer, 64);
				DispatchKeyValue(explosion,"spawnflags", intbuffer);
			}
	
			if(!StrEqual(weaponname, "", false))
				DispatchKeyValue(explosion,"classname", weaponname);
	
			DispatchSpawn(explosion);
			SetEntPropEnt(explosion, Prop_Send, "m_hOwnerEntity", attacker);
	
			if(inflictor != -1)
				SetEntPropEnt(explosion, Prop_Data, "m_hInflictor", inflictor);
				
			AcceptEntityInput(explosion, "Explode");
			RemoveEntity(explosion);
			
			return (true);
		}
		else
			return (false);
	}	
	
	
stock void CreateParticle(char[] particle, float pos[3], float ang[3])
{
	int tblidx = FindStringTable("ParticleEffectNames");
	char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	
	for(int i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, particle, false))
		{
			stridx = i;
			break;
		}
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", pos[0]);
	TE_WriteFloat("m_vecOrigin[1]", pos[1]);
	TE_WriteFloat("m_vecOrigin[2]", pos[2]);
	TE_WriteVector("m_vecAngles", ang);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", -1);
	TE_WriteNum("m_iAttachType", 5);	//Dont associate with any entity
	TE_SendToAll();
}

stock void ShootLaser(int weapon, const char[] strParticle, float flStartPos[3], float flEndPos[3], bool bResetParticles = false)
{
	int tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE) 
	{
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}
	char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	for (int i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, strParticle, false))
		{
			stridx = i;
			break;
		}
	}
	if (stridx == INVALID_STRING_INDEX)
	{
		LogError("Could not find particle: %s", strParticle);
		return;
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", flStartPos[0]);
	TE_WriteFloat("m_vecOrigin[1]", flStartPos[1]);
	TE_WriteFloat("m_vecOrigin[2]", flStartPos[2]);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", weapon);
	TE_WriteNum("m_iAttachType", 2);
	TE_WriteNum("m_iAttachmentPointIndex", 0);
	TE_WriteNum("m_bResetParticles", bResetParticles);	
	TE_WriteNum("m_bControlPoint1", 1);	
	TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", 5);  
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", flEndPos[0]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", flEndPos[1]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", flEndPos[2]);
	TE_SendToAll();
}

public bool TraceEntityFilterPlayer2(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
}

bool SetTeleportEndPoint(int client, float Position[3])
{
	float vAngles[3];
	float vOrigin[3];
	float vBuffer[3];
	float vStart[3];
	float Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	//get endpoint for teleport
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer2);

	if(TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		Position[0] = vStart[0] + (vBuffer[0]*Distance);
		Position[1] = vStart[1] + (vBuffer[1]*Distance);
		Position[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		CloseHandle(trace);
		return false;
	}
	
	CloseHandle(trace);
	return true;
}

public MRESReturn ILocomotion_GetRunSpeed(Address pThis, Handle hReturn, Handle hParams)			  
{ 
	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).GetRunSpeed()); 
	return MRES_Supercede; 
}

public MRESReturn IBody_GetSolidMask(Address pThis, Handle hReturn, Handle hParams)			  
{ 
	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).GetSolidMask()); 
	return MRES_Supercede; 
}

public MRESReturn IBody_GetActivity(Address pThis, Handle hReturn, Handle hParams)			  
{ 
	#if defined DEBUG_ANIMATION
	PrintToServer("IBody_GetActivity");	
	#endif

	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).GetActivity()); 
	return MRES_Supercede; 
}

public MRESReturn IBody_IsActivity(Address pThis, Handle hReturn, Handle hParams)			  
{
	int iActivity = DHookGetParam(hParams, 1);
	
	#if defined DEBUG_ANIMATION
	PrintToServer("IBody_IsActivity %i", iActivity);	
	#endif

	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).IsActivity(iActivity));
	return MRES_Supercede; 
}

public MRESReturn IBody_StartActivity(Address pThis, Handle hReturn, Handle hParams)			 
{ 
	int iActivity = DHookGetParam(hParams, 1);
	int fFlags	= DHookGetParam(hParams, 2);
	
	#if defined DEBUG_ANIMATION
	PrintToServer("IBody_StartActivity %i %i", iActivity, fFlags);	
	#endif
	
	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).StartActivity(iActivity, fFlags)); 
	
	return MRES_Supercede; 
}

stock float[] PredictSubjectPosition(CClotBody npc, int subject, float Extra_lead = 0.0)
{
	float botPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", botPos);
	
	float subjectPos[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsOrigin", subjectPos);
	
	botPos[2] += 1.0;
	subjectPos[2] += 1.0;
	
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);

	// don't lead if subject is very far away
	float flLeadRadiusSq = npc.GetLeadRadius(); 
	
	if ( flRangeSq > flLeadRadiusSq )
		return subjectPos;
	
	// Normalize in place
	float range = SquareRoot( flRangeSq );
	to[0] /= ( range + 0.0001 );	// avoid divide by zero
	to[1] /= ( range + 0.0001 );	// avoid divide by zero
	to[2] /= ( range + 0.0001 );	// avoid divide by zero
	
	// estimate time to reach subject, assuming maximum speed
	float leadTime = (0.1 + Extra_lead) + ( range / ( npc.GetRunSpeed() + 0.0001 ) );
	
	// estimate amount to lead the subject	
	float SubjectAbsVelocity[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
	float lead[3];	
	lead[0] = leadTime * SubjectAbsVelocity[0];
	lead[1] = leadTime * SubjectAbsVelocity[1];
	lead[2] = 0.0;	

	if(GetVectorDotProduct(to, lead) < 0.0)
	{
		// the subject is moving towards us - only pay attention 
		// to his perpendicular velocity for leading
		float to2D[3]; to2D = to;
		to2D[2] = 0.0;
		NormalizeVector(to2D, to2D);
		
		float perp[2];
		perp[0] = -to2D[1];
		perp[1] = to2D[0];

		float enemyGroundSpeed = lead[0] * perp[0] + lead[1] * perp[1];

		lead[0] = enemyGroundSpeed * perp[0];
		lead[1] = enemyGroundSpeed * perp[1];
	}

	// compute our desired destination
	float pathTarget[3];
	AddVectors(subjectPos, lead, pathTarget);

	// validate this destination

	// don't lead through walls
	if (GetVectorLength(lead, true) > 36.0)
	{
		float fraction;
		if (!PF_IsPotentiallyTraversable( npc.index, subjectPos, pathTarget, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	

	NavArea leadArea = TheNavMesh.GetNearestNavArea_Vec( pathTarget );
	
	
	if (leadArea == NavArea_Null || leadArea.GetZ(pathTarget[0], pathTarget[1]) < pathTarget[2] - npc.GetMaxJumpHeight())
	{
		// would fall off a cliff
		return subjectPos;	
	}

	pathTarget[2] += 20.0; //Clip them up, minimum crouch level preferred, or else the bots get really confused and sometimees go otther ways if the player goes up or down somewhere, very thin stairs break these bots.

/*	
	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	TE_SetupBeamPoints(botPos, pathTarget, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	TE_SendToAll();
*/
	/*
	//Extra check on if they try to follow through a wall again, double check is always good. Specficially check for only COLLIDING WITH THE WORLD.
	
	int Looking_At_This; 
	Looking_At_This = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
	if(IsValidEntity(Looking_At_This) && IsValidEnemy(sentry, Looking_At_This))
	{
		Handle trace; 
		float pos_sentry[3]; GetEntPropVector(sentry, Prop_Data, "m_vecAbsOrigin", pos_sentry);
		float pos_enemy[3]; GetEntPropVector(Looking_At_This, Prop_Data, "m_vecAbsOrigin", pos_enemy);
		pos_sentry[2] += 25.0;
		pos_enemy[2] += 45.0;
		
		trace = TR_TraceRayFilterEx(pos_sentry, pos_enemy, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, Base_Boss_Hit, sentry);
		int Traced_Target;
		
//		int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//		TE_SetupBeamPoints(pos_sentry, pos_enemy, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//		TE_SendToAll();
		
		Traced_Target = TR_GetEntityIndex(trace);
		delete trace;
		
		if(IsValidEntity(Traced_Target) && IsValidEnemy(sentry, Traced_Target))
		{
			DHookSetReturn(hReturn, true); 
			return MRES_Supercede;		
		}
	}
	*/
	
	return pathTarget;
}

public Action SDKHook_Settransmit_Baseboss(int entity, int client)
{
	if(Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
	{
		if(b_thisNpcIsABoss[entity] || b_thisNpcHasAnOutline[entity] || EntRefToEntIndex(RaidBossActive) == entity)
		{
			return Plugin_Continue;
		}
		return Plugin_Continue;
	}
	else
	{
		SetEdictFlags(entity, (GetEdictFlags(entity) & ~FL_EDICT_ALWAYS));
	}
	
	return Plugin_Continue;
}

stock float[] PredictSubjectPositionHook(CClotBody npc, int subject)
{
	float botPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", botPos);
	
	float subjectPos[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsOrigin", subjectPos);
	
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);

	// don't lead if subject is very far away
	float flLeadRadiusSq = npc.GetLeadRadius(); 
	
	if ( flRangeSq > flLeadRadiusSq )
		return subjectPos;
	
	// Normalize in place
	float range = SquareRoot( flRangeSq );
	to[0] /= ( range + 0.0001 );	// avoid divide by zero
	to[1] /= ( range + 0.0001 );	// avoid divide by zero
	to[2] /= ( range + 0.0001 );	// avoid divide by zero
	
	// estimate time to reach subject, assuming maximum speed
	float leadTime = 0.1 + ( range / ( npc.GetRunSpeed() + 0.0001 ) );
	
	// estimate amount to lead the subject	
	float SubjectAbsVelocity[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
	float lead[3];	
	lead[0] = leadTime * SubjectAbsVelocity[0];
	lead[1] = leadTime * SubjectAbsVelocity[1];
	lead[2] = 0.0;	

	if(GetVectorDotProduct(to, lead) < 0.0)
	{
		// the subject is moving towards us - only pay attention 
		// to his perpendicular velocity for leading
		float to2D[3]; to2D = to;
		to2D[2] = 0.0;
		NormalizeVector(to2D, to2D);
		
		float perp[2];
		perp[0] = -to2D[1];
		perp[1] = to2D[0];

		float enemyGroundSpeed = lead[0] * perp[0] + lead[1] * perp[1];

		lead[0] = enemyGroundSpeed * perp[0];
		lead[1] = enemyGroundSpeed * perp[1];
	}

	// compute our desired destination
	float pathTarget[3];
	AddVectors(subjectPos, lead, pathTarget);

	// validate this destination

	// don't lead through walls
	if (GetVectorLength(lead, true) > 36.0)
	{
		float fraction;
		if (!PF_IsPotentiallyTraversable( npc.index, subjectPos, pathTarget, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	

	NavArea leadArea = TheNavMesh.GetNearestNavArea_Vec( pathTarget );
	
	
	if (leadArea == NavArea_Null || leadArea.GetZ(pathTarget[0], pathTarget[1]) < pathTarget[2] - npc.GetMaxJumpHeight())
	{
		// would fall off a cliff
		return subjectPos;	
	}

	
	return pathTarget;
}


stock int Trace_Test(int m_pAttacker, float m_vecSrc[3], float m_vecDirShooting[3], float m_flDistance)
{
	float vecEnd[3];
	vecEnd[0] = m_vecSrc[0] + m_vecDirShooting[0] * m_flDistance; 
	vecEnd[1] = m_vecSrc[1] + m_vecDirShooting[1] * m_flDistance;
	vecEnd[2] = m_vecSrc[2] + m_vecDirShooting[2] * m_flDistance;
	
	// Fire a bullet (ignoring the shooter).
	Handle trace = TR_TraceRayFilterEx(m_vecSrc, vecEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, m_pAttacker);
	
	int enemy = TR_GetEntityIndex(trace);
	delete trace;
	
	return enemy;
}

stock float Custom_Explosion(int clientIdx, float distance, float SS_DamageDecayExponent, float SS_MaxDamage, float SS_Radius) // ty Sarysa.
{
	float damage;
	if (SS_DamageDecayExponent <= 0.0)
		damage = SS_MaxDamage;
	else if (SS_DamageDecayExponent == 1.0)
		damage = SS_MaxDamage * (1.0 - (distance / SS_Radius));
	
	else
	{
		damage = SS_MaxDamage - (SS_MaxDamage * (Pow(Pow(SS_Radius, SS_DamageDecayExponent) -
			Pow(SS_Radius - distance, SS_DamageDecayExponent), 1.0 / SS_DamageDecayExponent) / SS_Radius));
	}
	return fmax(1.0, damage);
}

stock int PrecacheParticleSystem(const char[] particleSystem)
{
	static int particleEffectNames = INVALID_STRING_TABLE;
	if (particleEffectNames == INVALID_STRING_TABLE)
	{
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE)
		{
			return INVALID_STRING_INDEX;
		}
	}
	
	int index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX)
	{
		int numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames))
		{
			return INVALID_STRING_INDEX;
		}
		
		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}
	
	return index;
}

stock int FindStringIndex2(int tableidx, const char[] str)
{
	char buf[1024];
	int numStrings = GetStringTableNumStrings(tableidx);
	for (int idx = 0; idx < numStrings; idx++)
	{
		ReadStringTable(tableidx, idx, buf, sizeof(buf));
		if (strcmp(buf, str) == 0)
		{
			return idx;
		}
	}
	
	return INVALID_STRING_INDEX;
}

void TE_ParticleInt(int iParticleIndex, const float origin[3] = NULL_VECTOR, const float start[3] = NULL_VECTOR, const float angles[3] = NULL_VECTOR, int entindex = -1, int attachtype = -1, int attachpoint = -1, bool resetParticles = true)
{
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", iParticleIndex);
	TE_WriteNum("entindex", entindex);
	
	if (attachtype != -1)
	{
		TE_WriteNum("m_iAttachType", attachtype);
	}
	
	if (attachpoint != -1)
	{
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);
	}
	TE_WriteNum("m_bResetParticles", resetParticles ? 1 : 0);
}


stock int ConnectWithBeam(int iEnt, int iEnt2, int iRed=255, int iGreen=255, int iBlue=255,
							float fStartWidth=NORMAL_ZOMBIE_VOLUME, float fEndWidth=NORMAL_ZOMBIE_VOLUME, float fAmp=1.35, char[] Model = "sprites/laserbeam.vmt")
{
	int iBeam = CreateEntityByName("env_beam");
	if(iBeam <= MaxClients)
		return -1;

	if(!IsValidEntity(iBeam))
		return -1;

	SetEntityModel(iBeam, Model);
	char sColor[16];
	Format(sColor, sizeof(sColor), "%d %d %d", iRed, iGreen, iBlue);

	DispatchKeyValue(iBeam, "rendercolor", sColor);
	DispatchKeyValue(iBeam, "life", "0");

	DispatchSpawn(iBeam);

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt));
	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt2), 1);

	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	SetEntPropFloat(iBeam, Prop_Data, "m_fAmplitude", fAmp);

	SetVariantFloat(32.0);
	AcceptEntityInput(iBeam, "Amplitude");
	AcceptEntityInput(iBeam, "TurnOn");
	return iBeam;
}

stock int TF2_CreateParticle(int iEnt, const char[] attachment, const char[] particle)
{
	int b = CreateEntityByName("info_particle_system");
	DispatchKeyValue(b, "effect_name", particle);
	DispatchSpawn(b);
	
	SetVariantString("!activator");
	AcceptEntityInput(b, "SetParent", iEnt);
	
	SetVariantString(attachment);
	AcceptEntityInput(b, "SetParentAttachment", iEnt);
	
	ActivateEntity(b);
	AcceptEntityInput(b, "Start");	
	
	return b;
}


stock int GetClosestAlly(int entity)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 

	int i = MaxClients + 1;
	while ((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if (GetEntProp(entity, Prop_Send, "m_iTeamNum")==GetEntProp(i, Prop_Send, "m_iTeamNum") && !Is_a_Medic[i] && GetEntProp(i, Prop_Data, "m_iHealth") > 0)  //The is a medic thing is really needed
		{
			float EntityLocation[3], TargetLocation[3]; 
			GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
			GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				
				
			float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
			if( TargetDistance ) 
			{
				if( distance < TargetDistance ) 
				{
					ClosestTarget = i; 
					TargetDistance = distance;		  
				}
			} 
			else 
			{
				ClosestTarget = i; 
				TargetDistance = distance;
			}			
		}
	}
	return ClosestTarget; 
}

stock bool IsValidAlly(int index, int ally)
{
	if(IsValidEntity(ally))
	{
		static char strClassname[16];
		GetEntityClassname(ally, strClassname, sizeof(strClassname));
		if(StrEqual(strClassname, "base_boss"))
		{
			if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(ally, Prop_Send, "m_iTeamNum") && GetEntProp(ally, Prop_Data, "m_iHealth") > 0) 
			{
				return true;
			}
		}
	}
	
	return false;
}

public void PluginBot_OnActorEmoted(int bot_entidx, int who, int concept)
{
	switch(i_NpcInternalId[bot_entidx])
	{
		case BOB_THE_GOD_OF_GODS:
		{
			BobTheGod_PluginBot_OnActorEmoted(bot_entidx, who, concept);
		}
	}
}

stock float ApproachAngle( float target, float value, float speed )
{
	float delta = AngleDiff_Change(target, value);
	
	// Speed is assumed to be positive
	if ( speed < 0 )
		speed = -speed;
	
	if ( delta < -180 )
		delta += 360;
	else if ( delta > 180 )
		delta -= 360;
	
	if ( delta > speed )
		value += speed;
	else if ( delta < -speed )
		value -= speed;
	else 
		value = target;
	
	return value;
}

stock float AngleDiff_Change( float destAngle, float srcAngle )
{
	float delta = fmodf(destAngle - srcAngle, 360.0);
	if ( destAngle > srcAngle )
	{
		if ( delta >= 180 )
			delta -= 360;
	}
	else
	{
		if ( delta <= -180 )
			delta += 360;
	}
	
	return delta;
}

stock float fmodf(float num, float denom)
{
	return num - denom * RoundToFloor(num / denom);
}

public void SetDefaultValuesToZeroNPC(int entity)
{
	i_Wearable1[entity] = -1;
	i_Wearable2[entity] = -1;
	i_Wearable3[entity] = -1;
	i_Wearable4[entity] = -1;
	i_Wearable5[entity] = -1;
	i_Wearable6[entity] = -1;
	i_TeamGlow[entity] = -1;
	i_SpawnProtectionEntity[entity] = -1;
	b_DissapearOnDeath[entity] = false;
	b_IsGiant[entity] = false;
	b_Pathing[entity] = false;
	b_Jumping[entity] = false;
	fl_JumpStartTime[entity] = 0.0;
	fl_JumpCooldown[entity] = 0.0;
	fl_NextDelayTime[entity] = 0.0;
	fl_NextThinkTime[entity] = 0.0;
	fl_NextMeleeAttack[entity] = 0.0;
	fl_Speed[entity] = 0.0;
	i_Target[entity] = -1;
	fl_GetClosestTargetTime[entity] = 0.0;
	fl_NextHurtSound[entity] = 0.0;
	fl_HeadshotCooldown[entity] = 0.0;
	b_CantCollidie[entity] = false;
	b_CantCollidieAlly[entity] = false;
	b_BuildingIsStacked[entity] = false;
	b_bBuildingIsPlaced[entity] = false;
	b_XenoInfectedSpecialHurt[entity] = false;
	fl_XenoInfectedSpecialHurtTime[entity] = 0.0;
	b_DoGibThisNpc[entity] = true;
	b_ThisEntityIgnored[entity] = false;
	fl_NextIdleSound[entity] = 0.0;
	fl_AttackHappensMinimum[entity] = 0.0;
	fl_AttackHappensMaximum[entity] = 0.0;
	b_AttackHappenswillhappen[entity] = false;
	b_thisNpcIsABoss[entity] = false;
	b_thisNpcHasAnOutline[entity] = false;
	b_ThisNpcIsImmuneToNuke[entity] = false;
	b_NPCVelocityCancel[entity] = false;
	fl_DoSpawnGesture[entity] = 0.0;
	b_isWalking[entity] = true;
	i_StepNoiseType[entity] = 0;
	i_NpcStepVariation[entity] = 0;
	i_BleedType[entity] = 0;
	i_State[entity] = 0;
	b_movedelay[entity] = false;
	fl_NextRangedAttack[entity] = 0.0;
	i_AttacksTillReload[entity] = 0;
	b_Gunout[entity] = false;
	fl_ReloadDelay[entity] = 0.0;
	fl_InJump[entity] = 0.0;
	fl_DoingAnimation[entity] = 0.0;
	fl_NextRangedBarrage_Spam[entity] = 0.0;
	fl_NextRangedBarrage_Singular[entity] = 0.0;
	b_NextRangedBarrage_OnGoing[entity] = false;
	fl_NextTeleport[entity] = 0.0;
	b_Anger[entity] = false;
	fl_NextRangedSpecialAttack[entity] = 0.0;
	b_RangedSpecialOn[entity] = false;
	fl_RangedSpecialDelay[entity] = 0.0;
	fl_movedelay[entity] = 0.0;
	fl_NextChargeSpecialAttack[entity] = 0.0;
	fl_AngerDelay[entity] = 0.0;
	b_FUCKYOU[entity] = false;
	b_FUCKYOU_move_anim[entity] = false;
	b_healing[entity] = false;
	b_new_target[entity] = false;
	fl_ReloadIn[entity] = 0.0;
	i_TimesSummoned[entity] = 0;
	fl_AttackHappens_2[entity] = 0.0;
	fl_Charge_delay[entity] = 0.0;
	fl_Charge_Duration[entity] = 0.0;
	b_movedelay_gun[entity] = false;
	b_Half_Life_Regen[entity] = false;
	fl_Dead_Ringer_Invis[entity] = 0.0;
	fl_Dead_Ringer[entity] = 0.0;
	b_Dead_Ringer_Invis_bool[entity] = false;
	i_AttacksTillMegahit[entity] = 0;
	fl_NextFlameSound[entity] = 0.0;
	fl_FlamerActive[entity] = 0.0;
	b_DoSpawnGesture[entity] = false;
	b_LostHalfHealth[entity] = false;
	b_LostHalfHealthAnim[entity] = false;
	b_DuringHighFlight[entity] = false;
	b_DuringHook[entity] = false;
	b_GrabbedSomeone[entity] = false;
	b_UseDefaultAnim[entity] = false;
	b_FlamerToggled[entity] = false;
	fl_WaveScale[entity] = 0.0;
	fl_StandStill[entity] = 0.0;
	fl_GrappleCooldown[entity] = 0.0;
	fl_HookDamageTaken[entity] = 0.0;
	b_IsCamoNPC[entity] = false;
	b_bThisNpcGotDefaultStats_INVERTED[entity] = false;
	b_isGiantWalkCycle[entity] = 1.0;
	i_Activity[entity] = -1;
	i_PoseMoveX[entity] = -1;
	i_PoseMoveY[entity] = -1;
	b_NpcHasDied[entity] = false;
	b_PlayHurtAnimation[entity] = false;
	i_CreditsOnKill[entity] = 0;
	b_npcspawnprotection[entity] = false;
	f_CooldownForHurtParticle[entity] = 0.0;
	b_ThisNpcIsSawrunner[entity] = false;
	f_LowTeslarDebuff[entity] = 0.0;
	f_HighTeslarDebuff[entity] = 0.0;
	f_WidowsWineDebuff[entity] = 0.0;
	
	fl_MeleeArmor[entity] = 1.0; //yeppers.
	fl_RangedArmor[entity] = 1.0;
}

public void Raidboss_Clean_Everyone()
{
	int base_boss;
	while((base_boss=FindEntityByClassname(base_boss, "base_boss")) != -1)
	{
		if(IsValidEntity(base_boss) && base_boss > 0)
		{
			if(GetEntProp(base_boss, Prop_Data, "m_iTeamNum") != view_as<int>(TFTeam_Red))
			{
				if(!b_Map_BaseBoss_No_Layers[base_boss] && EntRefToEntIndex(RaidBossActive) != base_boss) //Make sure it doesnt actually kill map base_bosses
				{
					SDKHooks_TakeDamage(base_boss, 0, 0, 99999999.0, DMG_BLAST); //Kill it so it triggers the neccecary shit.
					SDKHooks_TakeDamage(base_boss, 0, 0, 99999999.0, DMG_BLAST); //Kill it so it triggers the neccecary shit.
				}
			}
		}
	}
}

public void ArrowStartTouch(int arrow, int entity)
{
	if(entity > 0 && entity < MAXENTITIES)
	{
		SDKHooks_TakeDamage(entity, arrow, arrow, f_ArrowDamage[arrow], DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		EmitSoundToAll(g_ArrowHitSoundSuccess[GetRandomInt(0, sizeof(g_ArrowHitSoundSuccess) - 1)], arrow, _, 80, _, 0.8, 100);
		if(IsValidEntity(EntRefToEntIndex(f_ArrowTrailParticle[arrow])))
		{
			RemoveEntity(EntRefToEntIndex(f_ArrowTrailParticle[arrow]));
		}
	}
	else
	{
		EmitSoundToAll(g_ArrowHitSoundMiss[GetRandomInt(0, sizeof(g_ArrowHitSoundMiss) - 1)], arrow, _, 80, _, 0.8, 100);
		if(IsValidEntity(EntRefToEntIndex(f_ArrowTrailParticle[arrow])))
		{
			RemoveEntity(EntRefToEntIndex(f_ArrowTrailParticle[arrow]));
		}
	}
//	PrintToChatAll("touched");
	RemoveEntity(arrow);
}

public MRESReturn Arrow_DHook_RocketExplodePre(int arrow)
{
//	PrintToChatAll("boom!");
	RemoveEntity(arrow);
	if(IsValidEntity(EntRefToEntIndex(f_ArrowTrailParticle[arrow])))
	{
		RemoveEntity(EntRefToEntIndex(f_ArrowTrailParticle[arrow]));
	}
	return MRES_Supercede;
}

public void Change_Npc_Collision(int npc, int CollisionType)
{
	if(IsValidEntity(npc))
	{
		Address pNB =		 SDKCall(g_hMyNextBotPointer,	   npc);
		Address pLocomotion = SDKCall(g_hGetLocomotionInterface, pNB);
		if(!DHookRemoveHookID(h_NpcCollissionHookType[npc]))
		{
			PrintToChatAll("FAILED HOOK REMOVAL");
		}
		else
		{
			switch(CollisionType)
			{
				case 1:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemyIngoreBuilding,   false, pLocomotion);
				}
				case 2:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemy,   false, pLocomotion);
				}
				case 3:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyInvince,   false, pLocomotion);
				}
				case 4:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAlly,   false, pLocomotion);
				}
			}	
		}
	}
}

//NORMAL

#include "zombie_riot/npc/normal/npc_headcrabzombie.sp"
#include "zombie_riot/npc/normal/npc_headcrabzombie_fortified.sp"
#include "zombie_riot/npc/normal/npc_fastzombie.sp"
#include "zombie_riot/npc/normal/npc_fastzombie_fortified.sp"
#include "zombie_riot/npc/normal/npc_torsoless_headcrabzombie.sp"
#include "zombie_riot/npc/normal/npc_poisonzombie_fortified_giant.sp"
#include "zombie_riot/npc/normal/npc_poisonzombie.sp"
#include "zombie_riot/npc/normal/npc_poisonzombie_fortified.sp"
#include "zombie_riot/npc/normal/npc_last_survivor.sp"
#include "zombie_riot/npc/normal/npc_combine_police_pistol.sp"
#include "zombie_riot/npc/normal/npc_combine_police_smg.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_ar2.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_shotgun.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_swordsman.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_elite.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_giant_swordsman.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_swordsman_ddt.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_collos_swordsman.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_overlord.sp"
#include "zombie_riot/npc/normal/npc_zombie_scout_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_engineer_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_heavy_grave.sp"
#include "zombie_riot/npc/normal/npc_flying_armor.sp"
#include "zombie_riot/npc/normal/npc_flying_armor_tiny_swords.sp"
#include "zombie_riot/npc/normal/npc_kamikaze_demo.sp"
#include "zombie_riot/npc/normal/npc_medic_healer.sp"
#include "zombie_riot/npc/normal/npc_zombie_heavy_giant_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_spy_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_soldier_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_soldier_minion_grave.sp"
#include "zombie_riot/npc/normal/npc_zombie_soldier_giant_grave.sp"
#include "zombie_riot/npc/normal/npc_spy_thief.sp"
#include "zombie_riot/npc/normal/npc_spy_trickstabber.sp"
#include "zombie_riot/npc/normal/npc_spy_half_cloacked_main.sp"
#include "zombie_riot/npc/normal/npc_sniper_main.sp"
#include "zombie_riot/npc/normal/npc_zombie_demo_main.sp"
#include "zombie_riot/npc/normal/npc_medic_main.sp"
#include "zombie_riot/npc/normal/npc_zombie_pyro_giant_main.sp"
#include "zombie_riot/npc/normal/npc_combine_soldier_deutsch_ritter.sp"
#include "zombie_riot/npc/normal/npc_spy_boss.sp"

//XENO

#include "zombie_riot/npc/xeno/npc_xeno_headcrabzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_headcrabzombie_fortified.sp"
#include "zombie_riot/npc/xeno/npc_xeno_fastzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_fastzombie_fortified.sp"
#include "zombie_riot/npc/xeno/npc_xeno_torsoless_headcrabzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_poisonzombie_fortified_giant.sp"
#include "zombie_riot/npc/xeno/npc_xeno_poisonzombie.sp"
#include "zombie_riot/npc/xeno/npc_xeno_poisonzombie_fortified.sp"
#include "zombie_riot/npc/xeno/npc_xeno_last_survivor.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_police_pistol.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_police_smg.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_ar2.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_shotgun.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_swordsman.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_elite.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_giant_swordsman.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_swordsman_ddt.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_collos_swordsman.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_overlord.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_scout_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_engineer_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_heavy_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_flying_armor.sp"
#include "zombie_riot/npc/xeno/npc_xeno_flying_armor_tiny_swords.sp"
#include "zombie_riot/npc/xeno/npc_xeno_kamikaze_demo.sp"
#include "zombie_riot/npc/xeno/npc_xeno_medic_healer.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_heavy_giant_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_spy_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_soldier_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_soldier_minion_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_soldier_giant_grave.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_thief.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_trickstabber.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_half_cloacked_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_sniper_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_demo_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_medic_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_zombie_pyro_giant_main.sp"
#include "zombie_riot/npc/xeno/npc_xeno_combine_soldier_deutsch_ritter.sp"
#include "zombie_riot/npc/xeno/npc_xeno_spy_boss.sp"

#include "zombie_riot/npc/special/npc_panzer.sp"
#include "zombie_riot/npc/special/npc_sawrunner.sp"

#include "zombie_riot/npc/btd/npc_bloon.sp"
#include "zombie_riot/npc/btd/npc_moab.sp"
#include "zombie_riot/npc/btd/npc_bfb.sp"
#include "zombie_riot/npc/btd/npc_zomg.sp"
#include "zombie_riot/npc/btd/npc_ddt.sp"
#include "zombie_riot/npc/btd/npc_bad.sp"

#include "zombie_riot/npc/ally/npc_bob_the_overlord.sp"
#include "zombie_riot/npc/ally/npc_necromancy_combine.sp"
#include "zombie_riot/npc/ally/npc_necromancy_calcium.sp"
#include "zombie_riot/npc/ally/npc_cured_last_survivor.sp"
#include "zombie_riot/npc/ally/npc_citizen.sp"

#include "zombie_riot/npc/alt/npc_alt_combine_soldier_mage.sp"
#include "zombie_riot/npc/alt/npc_alt_medic_apprentice_mage.sp"

#include "zombie_riot/npc/raidmode_bosses/npc_true_fusion_warrior.sp"
#include "zombie_riot/npc/raidmode_bosses/npc_blitzkrieg.sp"

#include "zombie_riot/npc/alt/npc_alt_medic_charger.sp"
#include "zombie_riot/npc/alt/npc_alt_medic_berserker.sp"

#include "zombie_riot/npc/medival/npc_medival_militia.sp"
#include "zombie_riot/npc/medival/npc_medival_archer.sp"
#include "zombie_riot/npc/medival/npc_medival_man_at_arms.sp"
#include "zombie_riot/npc/medival/npc_medival_skirmisher.sp"
#include "zombie_riot/npc/medival/npc_medival_swordsman.sp"
#include "zombie_riot/npc/medival/npc_medival_twohanded_swordsman.sp"
#include "zombie_riot/npc/medival/npc_medival_crossbow.sp"
#include "zombie_riot/npc/medival/npc_medival_spearmen.sp"
#include "zombie_riot/npc/medival/npc_medival_handcannoneer.sp"
#include "zombie_riot/npc/medival/npc_medival_elite_skirmisher.sp"
#include "zombie_riot/npc/medival/npc_medival_pikeman.sp"
#include "zombie_riot/npc/alt/npc_alt_medic_supperior_mage.sp"