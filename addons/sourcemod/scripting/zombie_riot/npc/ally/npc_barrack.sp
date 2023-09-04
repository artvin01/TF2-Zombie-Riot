#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};
	
static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/shovel_swing.wav",
};

static const char g_MeleeMissSounds[][] =
{
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/bow_shoot.wav",
};

static const char g_SwordHitSounds[][] =
{
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_SwordAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_SpawnSounds[][] = {
	"weapons/draw_sword.wav",
};

enum
{
	Command_Default = -1,
	Command_Defensive = 0,
	Command_Aggressive,
	Command_Retreat,
	Command_HoldPosBarracks,
	Command_DefensivePlayer,
	Command_RetreatPlayer,
	Command_HoldPos,
	Command_MAX
}

int BarrackOwner[MAXENTITIES];
static float FireRateBonus[MAXENTITIES];
static float DamageBonus[MAXENTITIES];
static int CommandOverride[MAXENTITIES];
static bool NpcSpecialCommand[MAXENTITIES];
static bool FreeToSelect[MAXENTITIES];
static int SupplyCount[MAXENTITIES];
static bool b_WalkToPosition[MAXENTITIES];
int i_NormalBarracks_HexBarracksUpgrades[MAXENTITIES];
int i_NormalBarracks_HexBarracksUpgrades_2[MAXENTITIES];
int i_EntityRecievedUpgrades[MAXENTITIES];
int i_EntityRecievedUpgrades_2[MAXENTITIES];
bool i_BuildingRecievedHordings[MAXENTITIES];
float f_NextHealTime[MAXENTITIES];

//Barracks smith things:


#define ZR_UNIT_UPGRADES_NONE					0

//MELEE PERKS
#define ZR_UNIT_UPGRADES_COPPER_SMITH			(1 << 1) //done :)
#define ZR_UNIT_UPGRADES_IRON_CASTING			(1 << 2) //done :)
#define ZR_UNIT_UPGRADES_STEEL_CASTING			(1 << 3) //done :)
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_REFINED_STEEL			(1 << 4) //done :)
//in the end this should grant 1.5x damage

//RANGED PERKS
#define ZR_UNIT_UPGRADES_FLETCHING				(1 << 5) //done :)
#define ZR_UNIT_UPGRADES_STEEL_ARROWS			(1 << 6) //done :)
#define ZR_UNIT_UPGRADES_BRACER					(1 << 7) //done :)
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_OBSIDIAN_REFINED_TIPS	(1 << 8) //done :)
//in the end this should grant 1.35x the damage and 25% more range

//ARMOR PERKS affects all units.
#define ZR_UNIT_UPGRADES_COPPER_PLATE_ARMOR		(1 << 9) //done :)
#define ZR_UNIT_UPGRADES_IRON_PLATE_ARMOR		(1 << 10) //done :)
#define ZR_UNIT_UPGRADES_CHAINMAIL_ARMOR		(1 << 11) //done :)
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_REFORGED_STEEL_ARMOR	(1 << 12) //done :)
//in the end this should grant 5 flat armor reduction and 25% damage resistance, no health so medics are amazing

#define ZR_UNIT_UPGRADES_HERBAL_MEDICINE		(1 << 13) //done :)
//this will heal units very slowly overtime
//NEED DONJON MINUMUM:
#define ZR_UNIT_UPGRADES_REFINED_MEDICINE		(1 << 14) //done :)
//this will make units heal faster and give more max health (10%+ max health)

//UPGRADES TO BUILDINGS
//these should be very expensive, allows building to attack with arrows
//the building will also now gain abit of health, so it can be used as a weak barricade
#define ZR_BARRACKS_UPGRADES_TOWER				(1 << 15) //done :)
#define ZR_BARRACKS_UPGRADES_GUARD_TOWER		(1 << 16) //done :)
#define ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER		(1 << 17) //done :)
#define ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER	(1 << 18) //done :)
//going below this will lower your deployment slots to 2
//BELOW HERE will allow to garrison units (they will be given 0 gravity and teleported off the map and flagged so they dont get deleted)
//they will add extra arrows and heal the units overtime
//garrison will also work if you mount the building, allowing you to save your units in the most dire of situations.
#define ZR_BARRACKS_UPGRADES_DONJON				(1 << 19) //done :)
#define ZR_BARRACKS_UPGRADES_KREPOST			(1 << 20) //done :)
//at this point, the building will have 75% HP of a barricade, but getting this is very lategame, about wave 50 or so
#define ZR_BARRACKS_UPGRADES_CASTLE				(1 << 21) //done :)
//getting here will allow you to make teutonic knights, replacing the champion line.

//Have a toggle option to fire the arrows of your turret manually when you mount it
//it will give a boost in firepower as you do it manually!
#define ZR_BARRACKS_UPGRADES_MANUAL_FIRE		(1 << 22) //done :)
//Allows the building to attack units directly near it
#define ZR_BARRACKS_UPGRADES_MURDERHOLES		(1 << 23) //done :)
//allows the building to predict enemies
#define ZR_BARRACKS_UPGRADES_BALLISTICS			(1 << 24) //done :)
//inflict burning onto enemy and also get abit extra damage
#define ZR_BARRACKS_UPGRADES_CHEMISTY			(1 << 25) //done :)

//only vaiable once reaching donjon:

#define ZR_BARRACKS_UPGRADES_CONSCRIPTION		(1 << 26) //done :)
//allows to make units faster, you also gain resources faster, doesnt affect gold.
#define ZR_BARRACKS_UPGRADES_GOLDMINERS			(1 << 27) //done :)
//THIS is only aviable once you have the gold crown.
//this will allow you to gain gold faster if you have units in your building
//but it will also give you a 25% increace on gold gain passively.
#define ZR_BARRACKS_UPGRADES_CRENELLATIONS		(1 << 28) //done :)
//The castle will have a huge boost in range, allowing to snipe at great ranges
//it will also increace the speed of the arrows by alot.
#define ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER	(1 << 29)
//This will allow you to make one villager, this villager will try to make a building near you, or whereever you tell it to make one
//This building will only fire arrows, its max upgrade limit is another donjon, it cannot be a krepost or castle.
//This villager will try to repair all buildings around it for free, although, it will always prioritise repairing its own buildings
//When it notices its health is too low, then it will automatically run away and garrison inside its own building for safety
//it wont try to garrison inside your building and you cannot manually assign it a tast to repair stuff, only assign it where to build
//its building, but i t can only make one if its directly on a nav mesh to prevent abuse
//This villager will take away one ally spot and 1 barricade limit
//meaning if you have a castle and this villager, then you can only make 1 unit and 1 barricade
//its repair power derives from your repair upgrades.
//it is also unable to attack at all, its not fragile but it just cant defend itself
//garrisoning this unit wont increace the damage of the building it hides inside.
//unless....
#define ZR_BARRACKS_UPGRADES_ASSIANT_VILLAGER_EDUCATION	(1 << 30)
//this upgrade will make the villager free and wont consume slots, this means you can have 2 units and 2 barricades when you get this.


//only vaiable once reaching Krepost:

#define ZR_BARRACKS_UPGRADES_STRONGHOLDS	(1 << 31) //done :)
//The building will attack 33% faster, it will also heal any nearby MELEE player or unit slowly, weaker song of ocean minus buff.


#define ZR_BARRACKS_UPGRADES_HOARDINGS		(1 << 1) //Done :)
//ALL your buildings will gain 25% more health. This is to encurage camping with the building when you get upto middle.
//but making this building again will limit you to not make units and such, and have less barricades out
//this upgrade will only work when the castle is out, the moment the building breaks, the HP of all your buidlings will go down once more.

//i ran out of space...
#define ZR_BARRACKS_UPGRADES_EXQUISITE_HOUSING		(1 << 2) //Done :)
//allow to get 3 deployment slots again.

#define ZR_BARRACKS_TROOP_CLASSES			(1 << 3) //Allows training of units, although will limit support buildings to 1.


//in the end, this should be stronger then a sentry with full upgrades by 2x
//but i will make it eat up barricade slots so if you have this fully upgrades, you can only make 2 barricades at max
//but it wont affect barracks supply limit unless you get some upgrades that change this.

//mounting this building will cause it to deal half the damage, or attack half as fast, whatever works.
//just nerf the building overall, so its more advantagous to have it placed down.
//none of these upgrades cost gold (or should)

methodmap BarrackBody < CClotBody
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
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySwordSound()
	{
		EmitSoundToAll(g_SwordAttackSounds[GetRandomInt(0, sizeof(g_SwordAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySwordHitSound()
	{
		EmitSoundToAll(g_SwordHitSounds[GetRandomInt(0, sizeof(g_SwordHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySpawnSound()
	{
		EmitSoundToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	
	property float BonusFireRate
	{
		public get()
		{
			return FireRateBonus[view_as<int>(this)];
		}
		public set(float value)
		{
			FireRateBonus[view_as<int>(this)] = value;
		}
	}
	property float BonusDamageBonus
	{
		public get()
		{
			return DamageBonus[view_as<int>(this)];
		}
		public set(float value)
		{
			DamageBonus[view_as<int>(this)] = value;
		}
	}
	property int CmdOverride
	{
		public get()
		{
			return CommandOverride[view_as<int>(this)];
		}
		public set(int value)
		{
			CommandOverride[view_as<int>(this)] = value;
		}
	}
	property bool b_NpcSpecialCommand
	{
		public get()
		{
			return NpcSpecialCommand[view_as<int>(this)];
		}
		public set(bool value)
		{
			NpcSpecialCommand[view_as<int>(this)] = value;
		}
	}
	property bool m_bSelectableByAll
	{
		public get()
		{
			return FreeToSelect[view_as<int>(this)];
		}
		public set(bool value)
		{
			FreeToSelect[view_as<int>(this)] = value;
		}
	}
	property int m_iSupplyCount
	{
		public get()
		{
			return SupplyCount[view_as<int>(this)];
		}
		public set(int value)
		{
			SupplyCount[view_as<int>(this)] = value;
		}
	}
	property int m_iTargetRally
	{
		public get()
		{
			return i_OverlordComboAttack[this.index];
		}
		public set(int value)
		{
			i_OverlordComboAttack[this.index] = value;
		}
	}
	property int OwnerUserId
	{
		public get()
		{
			return BarrackOwner[view_as<int>(this)];
		}
	}
	
	public BarrackBody(int client, float vecPos[3], float vecAng[3],
	 const char[] health, const char[] modelpath = COMBINE_CUSTOM_MODEL,
	  int steptype = STEPTYPE_COMBINE_METRO, const char[] size_of_npc = "0.575",
	   float ExtraOffset = 0.0, const char[] ParticleModelPath = "models/pickups/pickup_powerup_supernova.mdl", bool IsInvuln = false)
	{
		BarrackBody npc = view_as<BarrackBody>(CClotBody(vecPos, vecAng, modelpath, size_of_npc, health, true, IsInvuln, .Ally_Collideeachother = !IsInvuln));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		BarrackOwner[npc.index] = client > 0 ? GetClientUserId(client) : 0;
		FireRateBonus[npc.index] = 1.0;
		DamageBonus[npc.index] = 1.0;
		CommandOverride[npc.index] = -1;
		NpcSpecialCommand[npc.index] = false;
		FreeToSelect[npc.index] = false;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = steptype;
		f_NextHealTime[npc.index] = 0.0;

		npc.m_iState = 0;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flComeToMe = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		b_NpcIsInvulnerable[npc.index] = IsInvuln;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		if(!IsInvuln)
		{
			if(IsValidEntity(npc.m_iTeamGlow))
			{
				RemoveEntity(npc.m_iTeamGlow);
			}

			npc.m_iWearable7 = npc.EquipItemSeperate("partyhat", ParticleModelPath,"spin",_,_,60.0 + ExtraOffset);
			SetVariantString("0.65");
			AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
			BarrackOwner[npc.m_iWearable7] = client > 0 ? client : 0;
			SDKHook(npc.m_iWearable7, SDKHook_SetTransmit, BarrackBody_Transmit);

			npc.m_iTeamGlow = TF2_CreateGlow(npc.m_iWearable7);
			SetVariantColor(view_as<int>({255, 255, 255, 200}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			
			int Textentity = BarrackBody_HealthHud(npc, ExtraOffset);
			BarrackOwner[Textentity] = client > 0 ? client : 0;
		}

		npc.StartPathing();
		Barracks_UpdateEntityUpgrades(npc.index,client > 0 ? client : 0,true, true);
		return npc;
	}
}

int BarrackBody_HealthHud(BarrackBody npc, float ExtraOffset = 0.0)
{
	char HealthText[32];
	int HealthColour[4];
	int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	for(int i=0; i<10; i++)
	{
		if(Health >= MaxHealth*(i*0.1))
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, "|");
		}
		else
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, ".");
		}
	}

	HealthColour[0] = 255;
	HealthColour[1] = 255;
	HealthColour[2] = 0;
	if(Health <= MaxHealth)
	{
		HealthColour[0] = Health * 255  / MaxHealth;
		HealthColour[1] = Health * 255  / MaxHealth;
		
		HealthColour[0] = 255 - HealthColour[0];
	}
	else
	{
		HealthColour[0] = 0;
		HealthColour[1] = 0;
		HealthColour[2] = 255;
	}	
	HealthColour[3] = 255;

	if(IsValidEntity(npc.m_iWearable6))
	{
		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
		DispatchKeyValue(npc.m_iWearable6,     "color", sColor);
		DispatchKeyValue(npc.m_iWearable6, "message", HealthText);
	}
	else
	{
		float offesetExtra[3];
		offesetExtra[2] += 50.0;
		offesetExtra[2] += ExtraOffset;
		int TextEntity = SpawnFormattedWorldText(HealthText,offesetExtra, 13, HealthColour, npc.index);
	//	SDKHook(TextEntity, SDKHook_SetTransmit, BarrackBody_Transmit);
		DispatchKeyValue(TextEntity, "font", "1");
		npc.m_iWearable6 = TextEntity;	
	}
	return npc.m_iWearable6;
}

public Action BarrackBody_Transmit(int entity, int client)
{
	if(client == BarrackOwner[entity])
		return Plugin_Continue;
	
	return Plugin_Handled;
}

bool BarrackBody_ThinkStart(int iNPC, float GameTime, float offsetHealth = 0.0)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);
	if(npc.m_flNextDelayTime > GameTime)
		return false;
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	
	if(npc.m_flNextThinkTime > GameTime)
		return false;
		

	BarrackBody_HealthHud(npc,offsetHealth);
	if(f_NextHealTime[npc.index] < GameTime && !i_NpcIsABuilding[npc.index])
	{
		f_NextHealTime[npc.index] = GameTime + 0.5;
		int HealingAmount;
		int client = GetClientOfUserId(npc.OwnerUserId);
		if(client > 0)
		{
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_HERBAL_MEDICINE))
			{
				HealingAmount += 1;
				if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_REFINED_MEDICINE))
				{
					HealingAmount += 1;
				}
			}
			if(HealingAmount > 0)
			{
				if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + HealingAmount);
					if(GetEntProp(npc.index, Prop_Data, "m_iHealth") >= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
					{
						SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
					}
				}
			}
		}
			
	}
	npc.m_flNextThinkTime = GameTime + 0.1;
	return true;
}

int BarrackBody_ThinkTarget(int iNPC, bool camo, float GameTime, bool passive = false)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);

	int client = GetClientOfUserId(npc.OwnerUserId);
	bool newTarget = npc.m_flGetClosestTargetTime < GameTime;

	if(!newTarget)
		newTarget = !IsValidEnemy(npc.index, npc.m_iTarget);

	if(!newTarget)
		newTarget = !IsValidEnemy(npc.index, npc.m_iTargetRally);

	if(newTarget)
	{
		int command = Command_Aggressive;

		if(client)
		{
			command = npc.CmdOverride == Command_Default ? Building_GetFollowerCommand(client) : npc.CmdOverride;
			if(command == Command_HoldPos || command == Command_HoldPosBarracks)
			{
				npc.m_iTargetAlly = npc.index;
			}
			else if(command == Command_DefensivePlayer || command == Command_RetreatPlayer)
			{
				npc.m_iTargetAlly = client;
			}
			else
			{
				npc.m_iTargetAlly = Building_GetFollowerEntity(client);
			}
		}
		else
		{
			npc.m_iTargetAlly = 0;
		}
		
		if(!passive)
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _, command == Command_Aggressive ? FAR_FUTURE : 900.0, camo);	
		}
		
		if(npc.m_iTargetAlly > 0 && !passive)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			npc.m_iTargetRally = GetClosestTarget(npc.index, _, command == Command_Aggressive ? FAR_FUTURE : 900.0, camo, _, _, vecTarget, command != Command_Aggressive);
		}
		else
		{
			npc.m_iTargetRally = 0;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
			{
				if(BarrackOwner[entity] == BarrackOwner[npc.index] && GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2)
				{
					BarrackBody ally = view_as<BarrackBody>(entity);
					if(ally.m_iTargetRally > 0 && IsValidEnemy(npc.index, ally.m_iTargetRally))
					{
						npc.m_iTargetRally = ally.m_iTargetRally;
					}
				}
			}
			if(!passive)
			{
				if(npc.m_iTargetRally < 1)
					npc.m_iTargetRally = npc.m_iTarget;
			}
		}

		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}
	return client;
}

void BarrackBody_ThinkMove(int iNPC, float speed, const char[] idleAnim = "", const char[] moveAnim = "", float canRetreat = 0.0, bool move = true, bool sound=true)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);

	bool pathed;
	float gameTime = GetGameTime(npc.index);
	if(move && npc.m_flReloadDelay < gameTime)
	{
		int client = GetClientOfUserId(npc.OwnerUserId);
		int command = client ? (npc.CmdOverride == Command_Default ? Building_GetFollowerCommand(client) : npc.CmdOverride) : Command_Aggressive;

		float myPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", myPos);

		if(f3_SpawnPosition[client][0] && (command == Command_HoldPosBarracks && command != Command_HoldPos))
		{
			f3_SpawnPosition[npc.index] = f3_SpawnPosition[client];
		}
		
		bool retreating = (command == Command_Retreat || command == Command_RetreatPlayer);

		if(IsValidEntity(npc.m_iTarget) && canRetreat > 0.0 && command != Command_HoldPos && !retreating)
		{
			float vecTarget[3];
			GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", vecTarget);
			float flDistanceToTarget;
			if(command == Command_HoldPosBarracks)
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, f3_SpawnPosition[npc.index], true);
			}
			else
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, myPos, true);
			}
			if(flDistanceToTarget < canRetreat)
			{
				vecTarget = BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vecTarget);
				
				npc.StartPathing();
				pathed = true;
			}
		}

		if(!pathed && IsValidEntity(npc.m_iTargetRally) && npc.m_iTargetRally > 0 && command != Command_HoldPos && !retreating)
		{
			float vecTarget[3];
			GetEntPropVector(npc.m_iTargetRally, Prop_Data, "m_vecAbsOrigin", vecTarget);

			float flDistanceToTarget;
			if(command == Command_HoldPosBarracks)
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, f3_SpawnPosition[npc.index], true);
			}
			else
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, myPos, true);
			}
			if(flDistanceToTarget < npc.GetLeadRadius())
			{
				//Predict their pos.
				vecTarget = PredictSubjectPosition(npc, npc.m_iTargetRally);
				NPC_SetGoalVector(npc.index, vecTarget);

				npc.StartPathing();
				pathed = true;
			}
			else
			{
				NPC_SetGoalEntity(npc.index, npc.m_iTargetRally);

				npc.StartPathing();
				pathed = true;
			}
		}
		
		if(!pathed && IsValidEntity(npc.m_iTargetAlly) && command != Command_Aggressive)
		{
			if(command != Command_HoldPos && command != Command_HoldPosBarracks)
			{
				float vecTarget[3];
				if(npc.m_iTargetAlly <= MaxClients && f3_SpawnPosition[npc.index][0] && npc.m_flComeToMe >= (gameTime + 0.6))
				{
					GetEntPropVector(npc.m_iTargetAlly, Prop_Data, "m_vecAbsOrigin", vecTarget);
					if(GetVectorDistance(myPos, vecTarget, true) > (100.0 * 100.0))
					{
						// Too far away from the mounter
						npc.m_flComeToMe = gameTime + 0.5;
					}
				}

				if(npc.m_flComeToMe < gameTime)
				{
					npc.m_flComeToMe = gameTime + 0.5;

					float originalVec[3];
					GetEntPropVector(npc.m_iTargetAlly, Prop_Data, "m_vecAbsOrigin", originalVec);
					vecTarget = originalVec;

					if(npc.m_iTargetAlly <= MaxClients)
					{
						vecTarget[0] += GetRandomFloat(-50.0, 50.0);
						vecTarget[1] += GetRandomFloat(-50.0, 50.0);
					}
					else
					{
						vecTarget[0] += GetRandomFloat(-300.0, 300.0);
						vecTarget[1] += GetRandomFloat(-300.0, 300.0);
					}
					vecTarget[2] += 50.0;
					Handle trace = TR_TraceRayFilterEx(vecTarget, view_as<float>({90.0, 0.0, 0.0}), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
					TR_GetEndPosition(vecTarget, trace);
					delete trace;
					vecTarget[2] += 18.0;
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
							
					hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	
					if(!IsSpaceOccupiedRTSBuilding(vecTarget, hullcheckmins, hullcheckmaxs, npc.index))
					{
						if(!IsPointHazard(vecTarget))
						{
							if(GetVectorDistance(originalVec, vecTarget, true) <= (npc.m_iTargetAlly <= MaxClients ? (100.0 * 100.0) : (350.0 * 350.0)) && GetVectorDistance(originalVec, vecTarget, true) > (30.0 * 30.0))
							{
								npc.m_flComeToMe = gameTime + 10.0;
								f3_SpawnPosition[npc.index] = vecTarget;
							}
						}
					}
				}
			}
			
			if(f3_SpawnPosition[npc.index][0])
			{
				if(command == Command_HoldPosBarracks && !pathed)
				{
					if(GetVectorDistance(f3_SpawnPosition[npc.index], myPos, true) > (50.0 * 50.0))
					{
						NPC_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
						npc.StartPathing();
						pathed = true;
					}
				}
				else if(GetVectorDistance(f3_SpawnPosition[npc.index], myPos, true) > (25.0 * 25.0))
				{
					NPC_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
					npc.StartPathing();
					pathed = true;
				}
			}
		}
	}
	
	if(pathed)
	{
		if(npc.m_iChanged_WalkCycle != 5)
		{
			npc.m_iChanged_WalkCycle = 5;
			npc.m_bisWalking = true;
			npc.m_flSpeed = speed;
			
			if(moveAnim[0])
				npc.SetActivity(moveAnim);
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_iChanged_WalkCycle = 4;
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;

			if(idleAnim[0])
				npc.SetActivity(idleAnim);
			
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			b_WalkToPosition[npc.index] = false;
		}
	}

	if(sound)
	{
		if(npc.m_iTarget > 0)
		{
			npc.PlayIdleAlertSound();
		}
		else
		{
			npc.PlayIdleSound();
		}
	}
}

public Action BarrackBody_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
	
	if(i_NpcIsABuilding[victim])
		return Plugin_Continue;
		
	if(!IsValidEntity(EntRefToEntIndex(RaidBossActive)))
	{
		damage *= 0.5;
	}
	else if(damagetype & (DMG_CLUB))
	{
		if(CurrentPlayers == 1)
		{
			damage *= 0.65;
		}
		else if(CurrentPlayers <= 4)
		{
			damage *= 0.6;
		}
		else
		{
			damage *= 0.75;
		}
	}
	BarrackBody npc = view_as<BarrackBody>(victim);
	int client = GetClientOfUserId(npc.OwnerUserId);
	if(client > 0)
	{
		damage = Barracks_UnitOnTakeDamage(npc.index, client, damage);
	}
	damage -= Rogue_Barracks_FlatArmor();
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

bool BarrackBody_Interact(int client, int entity)
{
	if(!IsValidClient(client))
		return false;

	if(i_NpcInternalId[entity] != BARRACKS_BUILDING)
	{
		BarrackBody npc = view_as<BarrackBody>(entity);
		if(npc.OwnerUserId)
		{
			if(npc.m_bSelectableByAll)
			{
				//if(IsValidEntity(i_HasSentryGunAlive[client]))
					ShowMenu(client, entity);
			}
			else if(npc.OwnerUserId == GetClientUserId(client))
			{
				ShowMenu(client, entity);
			}
		}
		return true;
	}
	return false;
}

void BarracksEntityCreated(int entity)
{
	BarrackOwner[entity] = 0;
}

static void ShowMenu(int client, int entity)
{
	BarrackBody npc = view_as<BarrackBody>(entity);

	Menu menu = new Menu(BarrackBody_MenuH);
	menu.SetTitle("%t\n \n%t\n ", "TF2: Zombie Riot", NPC_Names[i_NpcInternalId[entity]]);

	char num[16];
	IntToString(EntIndexToEntRef(entity), num, sizeof(num));
	menu.AddItem(num, "Barrack Default", npc.CmdOverride == Command_Default ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Aggressive", npc.CmdOverride == Command_Aggressive ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Defend Barrack", npc.CmdOverride == Command_Defensive ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Defend Me", npc.CmdOverride == Command_DefensivePlayer ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Retreat to Barrack", npc.CmdOverride == Command_Retreat ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Retreat to Me\n ", npc.CmdOverride == Command_RetreatPlayer ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
//	menu.AddItem(num, "Hold Position", npc.CmdOverride == Command_HoldPos ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Walk to Position and Hold\n ");
	menu.AddItem(num, "Npc Special Commands\n ", npc.b_NpcSpecialCommand ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem(num, "Sacrifice\n ", npc.m_bSelectableByAll ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.Pagination = 0;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int BarrackBody_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));

			int entity = EntRefToEntIndex(StringToInt(num));
			if(entity != INVALID_ENT_REFERENCE)
			{
				BarrackBody npc = view_as<BarrackBody>(entity);
				npc.m_flComeToMe = GetGameTime();

				if(npc.m_bSelectableByAll)
					BarrackOwner[npc.index] = GetClientUserId(client);

				switch(choice)
				{
					case 0:
					{
						npc.CmdOverride = Command_Default;
					}
					case 1:
					{
						npc.CmdOverride = Command_Aggressive;
						f3_SpawnPosition[npc.index][0] = 0.0;
						f3_SpawnPosition[npc.index][1] = 0.0;
						f3_SpawnPosition[npc.index][2] = 0.0;
					}
					case 2:
					{
						npc.CmdOverride = Command_Defensive;
						f3_SpawnPosition[npc.index][0] = 0.0;
						f3_SpawnPosition[npc.index][1] = 0.0;
						f3_SpawnPosition[npc.index][2] = 0.0;
					}
					case 3:
					{
						npc.CmdOverride = Command_DefensivePlayer;
						f3_SpawnPosition[npc.index][0] = 0.0;
						f3_SpawnPosition[npc.index][1] = 0.0;
						f3_SpawnPosition[npc.index][2] = 0.0;
					}
					case 4:
					{
						npc.CmdOverride = Command_Retreat;
						f3_SpawnPosition[npc.index][0] = 0.0;
						f3_SpawnPosition[npc.index][1] = 0.0;
						f3_SpawnPosition[npc.index][2] = 0.0;
					}
					case 5:
					{
						npc.CmdOverride = Command_RetreatPlayer;
						f3_SpawnPosition[npc.index][0] = 0.0;
						f3_SpawnPosition[npc.index][1] = 0.0;
						f3_SpawnPosition[npc.index][2] = 0.0;
					}
					case 6:
					{
						float StartOrigin[3], Angles[3], vecPos[3];
						GetClientEyeAngles(client, Angles);
						GetClientEyePosition(client, StartOrigin);
						Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (MASK_NPCSOLID_BRUSHONLY), RayType_Infinite, HitOnlyWorld);
						if (TR_DidHit(TraceRay))
							TR_GetEndPosition(vecPos, TraceRay);
							
						delete TraceRay;
						
						npc.FaceTowards(vecPos, 10000.0);
						CreateParticle("ping_circle", vecPos, NULL_VECTOR);
						f3_SpawnPosition[npc.index] = vecPos;
						b_WalkToPosition[npc.index] = true;
						npc.CmdOverride = Command_HoldPos;
					}
					case 7:
					{
						if(i_NpcInternalId[npc.index] == BARRACKS_VILLAGER)
						{
							BarracksVillager_MenuSpecial(client, npc.index);
							return 0;
						}
					}
					case 8:
					{
						SDKHooks_TakeDamage(npc.index, 0, 0, 9999999.9);
						return 0;
					}
				}

				ShowMenu(client, entity);
			}
		}
	}
	return 0;
}

void BarrackBody_NPCDeath(int entity)
{
	BarrackOwner[entity] = 0;

	BarrackBody npc = view_as<BarrackBody>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	
	
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


float Barracks_UnitExtraDamageCalc(int entity, int client, float damage, int damagetype)
{
	BarrackBody npc = view_as<BarrackBody>(entity);
	if(client < 1) //Incase the client somehow isnt real, then we revert to just taking it from the entity directly.
	{
		client = entity;
	}
	float DmgMulti = 1.0;
	if(damagetype == 0) //0 means melee
	{
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_COPPER_SMITH))
			DmgMulti *= 1.10;
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_IRON_CASTING))
			DmgMulti *= 1.2;
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_STEEL_CASTING))
			DmgMulti *= 1.20;
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_REFINED_STEEL))
			DmgMulti *= 1.35;
	}
	else //Rest is treated as ranged.
	{
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_FLETCHING))
			DmgMulti *= 1.10;
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_STEEL_ARROWS))
			DmgMulti *= 1.10;
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_BRACER))
			DmgMulti *= 1.20;
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_OBSIDIAN_REFINED_TIPS))
			DmgMulti *= 1.35;	
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CHEMISTY))
			DmgMulti *= 1.2;
	}

	damage *= npc.BonusDamageBonus;
	damage *= DmgMulti;
	
	return damage;
}

float Barracks_UnitExtraRangeCalc(int entity, int client, float range, bool building)
{
	if(client < 1) //Incase the client somehow isnt real, then we revert to just taking it from the entity directly.
	{
		client = entity;
	}
	float RangeMulti = 1.0;

	if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_FLETCHING))
		RangeMulti *= 1.1;
	if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_STEEL_ARROWS))
		RangeMulti *= 1.1;
	if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_BRACER))
		RangeMulti *= 1.1;

	if(building && (i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CRENELLATIONS))
		RangeMulti *= 2.0;

	
	range *= RangeMulti;
	return range;
}

float Barracks_UnitOnTakeDamage(int entity, int client, float damage)
{
	if(client < 1) //Incase the client somehow isnt real, then we revert to just taking it from the entity directly.
	{
		client = entity;
	}
	float DamageResisted = 1.0;

	if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_COPPER_PLATE_ARMOR))
	{
		DamageResisted *= 0.97;
	}
	if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_IRON_PLATE_ARMOR))
	{
		DamageResisted *= 0.97;
	}
	if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_COPPER_PLATE_ARMOR))
	{
		DamageResisted *= 0.97;
	}
	if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_REFORGED_STEEL_ARMOR))
	{
		DamageResisted *= 0.97;
		damage -= 1;
	}

	damage *= DamageResisted;

	if(damage < 0.0)
	{
		damage = 0.0;
	}
	return damage;
}

void Barracks_UpdateAllEntityUpgrades(int client, bool first_upgrade = false, bool first_barracks = false)
{
	for (int i = 0; i < MAXENTITIES; i++)
	{
		if(IsValidEntity(i) && (i_IsABuilding[i] || !b_NpcHasDied[i])) //This isnt expensive.
		{
			BarrackBody npc = view_as<BarrackBody>(i);
			if(GetClientOfUserId(npc.OwnerUserId) == client && !b_NpcHasDied[i])
			{
				Barracks_UpdateEntityUpgrades(i, client,first_upgrade,first_barracks);
			}
			else if(i_IsABuilding[i] && GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client)
			{
				Barracks_UpdateEntityUpgrades(i, client,first_upgrade,first_barracks);
			}
		}
	}
}

void Barracks_UpdateEntityUpgrades(int entity, int client, bool firstbuild = false, bool BarracksUpgrade = false)
{
	if(i_IsABuilding[entity] && b_NpcHasDied[entity])
	{
		if(!GlassBuilder[entity] && b_HasGlassBuilder[client])
		{
			GlassBuilder[entity] = true;
			SetBuildingMaxHealth(entity, 0.25, false, true,true);
		}
		if(GlassBuilder[entity] && !b_HasGlassBuilder[client])
		{
			GlassBuilder[entity] = false;
			if(firstbuild)
				SetBuildingMaxHealth(entity, 0.25, true, true ,true);
			else
				SetBuildingMaxHealth(entity, 0.25, true, _ ,true);

		}
		if(!HasMechanic[entity] && b_HasMechanic[client])
		{
			HasMechanic[entity] = true;

			if(firstbuild)
				SetBuildingMaxHealth(entity, 1.15, false, true);
			else
				SetBuildingMaxHealth(entity, 1.15, false);

		}
		if(HasMechanic[entity] && !b_HasMechanic[client])
		{
			HasMechanic[entity] = false;
			SetBuildingMaxHealth(entity, 1.15, true, false);
		}
		if(i_WhatBuilding[entity] == BuildingSummoner)
		{
			
			float healthMult = 1.0;
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_TOWER) && !(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_TOWER))
			{
				healthMult *= 1.3;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_TOWER;
				int prop1 = EntRefToEntIndex(Building_Hidden_Prop[entity][1]);
				
				if(IsValidEntity(prop1))
				{
					SetEntityModel(prop1, "models/props_manor/clocktower_01.mdl");
					//"0.65" default
					SetEntPropFloat(prop1, Prop_Send, "m_flModelScale", 0.11); 
				}
			}

			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_GUARD_TOWER) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_GUARD_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_GUARD_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_IMPERIAL_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER)))
			{
				healthMult *= 1.15;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_BALLISTICAL_TOWER;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_DONJON)&& (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_DONJON)))
			{
				healthMult *= 1.3;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_DONJON;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_KREPOST) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_KREPOST)))
			{
				healthMult *= 1.4;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_KREPOST;
			}
			if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CASTLE) && (!(i_EntityRecievedUpgrades[entity] & ZR_BARRACKS_UPGRADES_CASTLE)))
			{
				healthMult *= 1.6;
				i_EntityRecievedUpgrades[entity] |= ZR_BARRACKS_UPGRADES_CASTLE;
			}
			if(healthMult > 1.0)
			{
				SetBuildingMaxHealth(entity, healthMult, false, true);
			}
		}
	}
	if(!b_NpcHasDied[entity] && !i_IsABuilding[entity])
	{
		if(!FinalBuilder[entity] && FinalBuilder[client])
		{
			FinalBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.35;
			view_as<BarrackBody>(entity).BonusFireRate *= 0.8;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.35));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 1.35));
		}
		if(FinalBuilder[entity] && !FinalBuilder[client])
		{
			FinalBuilder[entity] = false;
			view_as<BarrackBody>(entity).BonusDamageBonus /= 1.35;			
			view_as<BarrackBody>(entity).BonusFireRate /= 0.8;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 1.35));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) / 1.35));
		}
		if(!GlassBuilder[entity] && GlassBuilder[client])
		{
			GlassBuilder[entity] = true;
			view_as<BarrackBody>(entity).BonusDamageBonus *= 1.15;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 0.8));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 0.8));
		}
		if(GlassBuilder[entity] && !GlassBuilder[client])
		{
			GlassBuilder[entity] = false;
			view_as<BarrackBody>(entity).BonusDamageBonus /= 1.15;
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 0.8));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) / 0.8));
		}

		/*
			//FOR PERK MACHINE!
			public const char PerkNames[][] =
			{
				"No Perk", //unused
				"Quick Revive", //get extra healing, see heal code?
				"Juggernog",	
				"Double Tap",
				"Speed Cola",
				"Deadshot Daiquiri",
				"Widows Wine",
				"Recycle Poire"
			};
		*/
		//double tap
		if(i_CurrentEquippedPerk[entity] != 3 && i_CurrentEquippedPerk[client] == 3)
		{
			view_as<BarrackBody>(entity).BonusFireRate *= 0.85;
		}
		if(i_CurrentEquippedPerk[entity] == 3 && i_CurrentEquippedPerk[client] != 3)
		{
			view_as<BarrackBody>(entity).BonusFireRate /= 0.85;
		}
		//juggernog
		if(i_CurrentEquippedPerk[entity] != 2 && i_CurrentEquippedPerk[client] == 2)
		{
			if(BarracksUpgrade)
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.15));

			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 1.15));
		}
		if(i_CurrentEquippedPerk[entity] == 2 && i_CurrentEquippedPerk[client] != 2)
		{
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / 1.15));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) / 1.15));
		}
		if((i_NormalBarracks_HexBarracksUpgrades[client] & ZR_UNIT_UPGRADES_REFINED_MEDICINE) &&!(i_EntityRecievedUpgrades[entity] & ZR_UNIT_UPGRADES_REFINED_MEDICINE))
		{
			i_EntityRecievedUpgrades[entity] |= ZR_UNIT_UPGRADES_REFINED_MEDICINE;
			SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * 1.1));
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * 1.1));
		}
		i_CurrentEquippedPerk[entity] = i_CurrentEquippedPerk[client];
	}
}


void SetBuildingMaxHealth(int entity, float Multi, bool reduce, bool initial = false, bool inversehealth = false)
{
	if(reduce)
	{
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) / Multi));

		int HealthToSet = RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) / Multi);

		int HealthToSetPost = HealthToSet - GetEntProp(entity, Prop_Data, "m_iHealth");

		if(HealthToSetPost < 0)
		{
			HealthToSetPost = GetEntProp(entity, Prop_Data, "m_iHealth") - HealthToSet;
		}
		SetVariantInt(HealthToSetPost);
		if(initial)
		{
			if(!inversehealth)
				AcceptEntityInput(entity, "RemoveHealth");
			else
				AcceptEntityInput(entity, "AddHealth");
		}

		Building_Repair_Health[entity] = RoundToCeil(float(Building_Repair_Health[entity]) / Multi);
		Building_Max_Health[entity] = RoundToCeil(float(Building_Max_Health[entity]) / Multi);	
	}
	else
	{
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * Multi));
		
		if(initial)
		{
			int HealthToSet = RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * Multi);
			if(!inversehealth)
			{
				HealthToSet = HealthToSet - GetEntProp(entity, Prop_Data, "m_iHealth");
			}
			else
			{
				HealthToSet = GetEntProp(entity, Prop_Data, "m_iHealth") - HealthToSet;
			}
			SetVariantInt(HealthToSet);
			
			if(!inversehealth)
				AcceptEntityInput(entity, "AddHealth");
			else
				AcceptEntityInput(entity, "RemoveHealth");
		}
		Building_Repair_Health[entity] = RoundToCeil(float(Building_Repair_Health[entity]) * Multi);
		Building_Max_Health[entity] = RoundToCeil(float(Building_Max_Health[entity]) * Multi);			
	}
}
