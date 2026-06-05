#pragma semicolon 1
#pragma newdecls required

static Handle h_Red_Mist_Timer[MAXPLAYERS] = {null, ...};
static Handle RM_Lastman_Timer[MAXPLAYERS] = {null, ...};
static Handle h_Red_Mist_Ego_Timer[MAXPLAYERS] = {null, ...};
static Handle h_Onrush_Check_Timer[MAXPLAYERS] = {null, ...};
static bool counter_timer_exists[MAXPLAYERS];
static bool savagery_timer_exists[MAXPLAYERS];
static bool Ego_Active[MAXPLAYERS];
static bool Special_Active[MAXPLAYERS];
static bool strength_active_1[MAXPLAYERS] = {false};
static bool strength_active_2[MAXPLAYERS] = {false};
static bool strength_active_3[MAXPLAYERS] = {false};
static bool lms_buffs_given[MAXPLAYERS] = {false};
static bool Prey_Mark_Cooldown[MAXPLAYERS];
static bool Ego_Cooldown_given[MAXPLAYERS] = {true};
static bool RM_Lastman_Buffs_applied[MAXPLAYERS] = {false};
static bool Special_Damage_Boost[MAXPLAYERS] = {false};
static int WeaponLevel[MAXPLAYERS];
static int ref_MeleeWeapon[MAXPLAYERS];
static int last_recorded_pap[MAXPLAYERS] = {0, ...};
static int current_card_selection[MAXPLAYERS] = {0, ...};
static int current_abno_card_selection[MAXPLAYERS] = {0, ...};
static int counter_dice_amount[MAXPLAYERS] = {15, ...};
static int absorption_counter[MAXPLAYERS] = {0, ...};
static int Strenght_Amount[MAXPLAYERS];
//static int Endurance_Amount[MAXPLAYERS]; only a single card gives this, not worth it making it its own thing
public int Abno_Pages[MAXPLAYERS];
static int Deep_Wound_Counter[MAXPLAYERS];
static int Ego_Energy[MAXPLAYERS];
static int redashes[MAXPLAYERS];
static int swing_type[MAXPLAYERS];
static float GradeWeaponAm[MAXPLAYERS];
static int RandomSeedDo[MAXPLAYERS];
static bool ValueGoUpOrDown[MAXPLAYERS];
static float Special_Cooldowns[MAXPLAYERS][4]; //IT WORKS :D, who needs premade cooldowns when you can make your own
// Note from artvin: this will not work with any cooldown reductions or any "on hit" cooldown reductions unless its specifically coded in.

static float Burst_Damage_Taken[MAXPLAYERS];
static float Onrush_Redash_Window[MAXPLAYERS];
//flags or smth, black magic if you ask me
#define ABNORMPAGE_PREY             (1 << 0)
#define ABNORMPAGE_VENGEANCE        (1 << 1)
#define ABNORMPAGE_SAVAGERY         (1 << 2)
#define ABNORMPAGE_ROLE_OF_WOLF     (1 << 3)
#define ABNORMPAGE_ABSORPTION       (1 << 4)
#define ABNORMPAGE_MOSB             (1 << 5)
#define ABNORMPAGE_VAMPIRISM        (1 << 6)
#define ABNORMPAGE_DEEP_WOUND       (1 << 7)

#define ABNORM_ENTER_SOUND "replay/enterperformancemode.wav"
#define ABNORM_EXIT_SOUND	"replay/exitperformancemode.wav"
#define PAGE_SELECT_SOUND	"passtime/scroll_open.wav"
#define PAGE_DESELECT_SOUND	"passtime/scroll_close.wav"
#define ONRUSH_START_SOUND	"player/taunt_yeti_standee_equipment_jingle4.wav"
#define ONRUSH_HIT_SOUND	"zombiesurvival/medieval_raid/special_mutation/arkantos_hurt_1.mp3"
#define COUNTER_SOUND_HIT	"zombiesurvival/medieval_raid/special_mutation/arkantos_hurt_2.mp3"
#define PREY_MARKED_SOUND "weapons/samurai/tf_marked_for_death_impact_03.wav"
#define VERTICAL_SLASH_SOUND "items/pumpkin_explode1.wav"
#define HORIZONTAL_SLASH_SOUND "npc/manhack/grind_flesh2.wav"

#define SWING_TYPE_NORMAL 0
#define SWING_TYPE_SPECIAL 1
#define MAX_EGO_CHARGE 1000

static int BeamWand_Laser;
static int BeamWand_Glow;
public void Enable_Red_Mist(int client, int weapon)
{
	DataPack pack = new DataPack();
	if(h_Red_Mist_Timer[client] != null)
	{
		if(IsValidHandle(h_Red_Mist_Timer[client]))
			delete h_Red_Mist_Timer[client];
		h_Red_Mist_Timer[client] = null;
	}
	if(h_Red_Mist_Ego_Timer[client] != null)
	{
		if(IsValidHandle(h_Red_Mist_Ego_Timer[client]))
			delete h_Red_Mist_Ego_Timer[client];
		h_Red_Mist_Ego_Timer[client] = null;
	}
	if(RM_Lastman_Timer[client] != null)
	{
		if(IsValidHandle(RM_Lastman_Timer[client]))
			delete RM_Lastman_Timer[client];
		RM_Lastman_Timer[client] = null;
	}
	WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
	ref_MeleeWeapon[client] = EntIndexToEntRef(weapon);
	h_Red_Mist_Timer[client] = CreateDataTimer(0.1, Timer_Red_Mist, pack, TIMER_REPEAT);
	h_Red_Mist_Ego_Timer[client] = CreateTimer(0.4, Timer_Red_Mist_Ego, client, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	PrecacheRedMistMusic();
	ApplyStatusEffect(client, client, "Red Mist Counter", 9999.0);//just visual
	if(Abno_Pages[client] & ABNORMPAGE_ROLE_OF_WOLF)
	{
		counter_dice_amount[client] = 30;
	}
	else
	{
		counter_dice_amount[client] = 15;
	}
	savagery_timer_exists[client] = false;
	Prey_Mark_Cooldown[client] = true;
}

bool IsDistorted(int client)//idk how this works
{
	if(h_Red_Mist_Timer[client] != null)
		return true;

	return false;
}

bool AnyClientHaveMOSB()
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && TeutonType[client] == TEUTON_NONE && IsEntityAlive(client) && IsDistorted(client))
		{
			if(Abno_Pages[client] & ABNORMPAGE_MOSB)
			{
				return true;
			}
		}
	}
	return false;
}

static Action Timer_Red_Mist(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientindx = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		//Heartbroken_ApplyCoffinBack(clientindx, true);
		h_Red_Mist_Timer[clientindx] = null;
		if(IsValidClient(client))
		{
			Disable_Everything_Red_Mist(client);
		}
		return Plugin_Stop;
	}
	if(dieingstate[client] || TeutonType[client] != TEUTON_NONE)
	{
		Disable_Everything_Red_Mist(client);
	}
	if(Abno_Pages[client] & ABNORMPAGE_VENGEANCE)
	{
		Vengeance_Logic(client);
	}
	
	if(!IsIn_HitDetectionCooldown(weapon,weapon, RedMist_AbnormSelect))
	{
		Set_HitDetectionCooldown(weapon,weapon, GetGameTime() + 0.5, RedMist_AbnormSelect);
		int EntityWeaponModel = EntRefToEntIndex(HandRef[client]);
		if(IsValidEntity(EntityWeaponModel))
		{
			float Value = GetRandomFloat(0.1, 0.2);
			if(ValueGoUpOrDown[client])
			{
				GradeWeaponAm[client] += Value;
				if(GradeWeaponAm[client] >= 1.0)
				{
					ValueGoUpOrDown[client] = false;
					GradeWeaponAm[client] = 1.0;
				}
			}
			else
			{
				GradeWeaponAm[client] -= Value;
				if(GradeWeaponAm[client] <= 0.0)
				{
					ValueGoUpOrDown[client] = true;
					GradeWeaponAm[client] = 0.0;
				}
			}
			Attributes_Set(weapon, 725, GradeWeaponAm[client]);
			ImportSkinAttribs(EntityWeaponModel, weapon);
			Attributes_Set(EntityWeaponModel, 866, float(CurrentGame + RandomSeedDo[client]++));
		}
	}
	
	if(WeaponLevel[client] >= 0)
	{
		ApplyStatusEffect(client, client, "Red Mist Vertical", 9999.0);
	}
	if(WeaponLevel[client] >= 3)
	{
		ApplyStatusEffect(client, client, "Red Mist Horrizontal", 9999.0);
	}
	if(Ego_Energy[client] <= 0)//if ego isnt active
	{
		Ego_Active[client] = false;
		Ego_Energy[client] = 0;
		//TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_SOUND, 0);
		if(!Ego_Cooldown_given[client])//give cooldown only once after it ends
		{
			if(WeaponLevel[client] > 2)
			{
				//lol get fucked
				FreezeNpcInTime(client, 2.0);
				ApplyStatusEffect(client, client, "Ragdolled", 2.0);
				EmitSoundToAll("weapons/buffed_off.wav", client, _, 70, _, 1.0, 100);
			}
			
			Special_Cooldowns[client][2] = GetGameTime() + (120.00 * CooldownReductionAmount(client));
			RemoveSpecificBuff(client, "Ego Manifestation");
			Ego_Cooldown_given[client] = true;
			current_card_selection[client] = 2;
			Special_Active[client] = false;
		}
	}
	if(Onrush_Redash_Window[client] < GetGameTime() && redashes[client] > 0)
	{
		if(h_Red_Mist_Timer[client] != null)
		{
			delete h_Onrush_Check_Timer[client];
			h_Onrush_Check_Timer[client] = null;
		}
		redashes[client] = 0;
		Ability_Apply_Cooldown(client, 2, 20.0, weapon);
	}
	if(LastMann)
	{
		if(!RM_Lastman_Buffs_applied[client])//give buffs once
		{
			if(Abno_Pages[client] & ABNORMPAGE_MOSB)//give bonus buffs if MOSB is picked
			{
				ApplyStatusEffect(client, client, "Red_Mist_Strength", 9999.0);
				Strenght_Amount[client] += 10;
				RM_Lastman_Timer[client] = CreateTimer(90.0, MOSB_Lastman_Execution, client);
				EmitCustomToAll("zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
			}
			Ego_Active[client] = true;
			Special_Cooldowns[client][2] = GetGameTime() + 999.00;
			Ego_Energy[client] = 1000;
			ApplyStatusEffect(client, client, "Ego Manifestation", 9999.0);
			ApplyStatusEffect(client, client, "Ego Grace", 30.0);
			//ego is easier to upkeep for 20 seconds
			//add no translations to this
			RM_Lastman_Buffs_applied[client] = true;
			//PrintToChatAll("enabled last man buffs");
			//PrintToChatAll("%b", Ego_Active[client]);
			Store_ApplyAttribs(client);
			//update client speed due to lastman shits
		}
	}
	if(!LastMann)
	{
		if(RM_Lastman_Buffs_applied[client])//take away buffs once
		{
			if(Abno_Pages[client] & ABNORMPAGE_MOSB)//give bonus buffs if MOSB is picked
			{
				Strenght_Amount[client] -= 10; //if it isnt lms but buffs were applied. aka lms ended, remove buffs and kill death timer
				delete RM_Lastman_Timer[client];
				RemoveSpecificBuff(client, "Influence of the bodies");
			}
			Ego_Active[client] = false;
			Special_Cooldowns[client][2] = GetGameTime() + (120.00 * CooldownReductionAmount(client));
			RemoveSpecificBuff(client, "Ego Manifestation");
			RM_Lastman_Buffs_applied[client] = false;
			Ego_Energy[client] = 0;
			//PrintToChatAll("disabled last man buffs");
			//PrintToChatAll("%b", Ego_Active[client]);

		}
	}
	int Active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int SecondaryWeap = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(Active == SecondaryWeap)
	{
		Abornmality_Page_Display(client);
	}	
	else if(IsIn_HitDetectionCooldown(client,client, RedMist_WasInAbnorm))
	{
		EmitSoundToClient(client, ABNORM_EXIT_SOUND, client, _, 70, _, 1.0, 90);
		EntityKilled_HitDetectionCooldown(client, RedMist_WasInAbnorm);
		UTIL_ScreenFade(client, 1, 1, FFADE_PURGE, 0, 0, 0, 233);
	//	UTIL_ScreenFade(client, 66, 66, FFADE_OUT, 0, 0, 0, 233);
	}
	b_IsCannibal[client] = true;
	//HeartBroken_HUD(client);
	return Plugin_Continue;

}

static Action Timer_Red_Mist_Ego(Handle timer, int client)
{
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		h_Red_Mist_Ego_Timer[client] = null;
		return Plugin_Stop;
	}
	if(Ego_Active[client] && !LastMann)//only lose charge if ego is active and it ISNT lms
	{
		//PrintToChatAll("ego energy [%d]", Ego_Energy[client]);
		if(!LastMann)
		{
			if(HasSpecificBuff(client, "Ego Grace"))
				Ego_Energy[client] -= 25;
			else
				Ego_Energy[client] -= 35;

			if(Ego_Energy[client] <= 0)
				Ego_Energy[client] = 0;
		}
		PrintHintText(client,"Ego Active(Charge: [%i/%i])", Ego_Energy[client], MAX_EGO_CHARGE);
	}
	return Plugin_Continue;
}

void Disable_Everything_Red_Mist(int client)
{
	Ego_Energy[client] = 0;
	RemoveSpecificBuff(client, "Ego Manifestation");
	RemoveSpecificBuff(client, "Influence of the bodies");
	RemoveSpecificBuff(client, "Red_Mist_Strength");
	Ego_Active[client] = false;
}

void Red_Mist_Horizontal_Slash_DoSwingTrace(int client, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	switch(swing_type[client])
	{
		case SWING_TYPE_NORMAL:
		{
			CustomMeleeRange = MELEE_RANGE;
			CustomMeleeWide = MELEE_BOUNDS;
			enemies_hit_aoe = 1;
			ignore_walls = false;
		}
		case SWING_TYPE_SPECIAL:
		{
			CustomMeleeRange = MELEE_RANGE * 1.8;
			CustomMeleeWide = MELEE_BOUNDS * 5.0;
			enemies_hit_aoe = 25; //lol
			ignore_walls = false;
			Special_Active[client] = false;
		}	
	}
}
bool RM_Precached = false;

public void RedMist_ResetAbnorms()
{
	Zero(Abno_Pages);
	Zero(last_recorded_pap);
}
public void Red_Mist_OnMapStart()
{
	PrecacheSound(ABNORM_ENTER_SOUND);
	PrecacheSound(ABNORM_EXIT_SOUND);
	PrecacheSound(PAGE_SELECT_SOUND);
	PrecacheSound(PAGE_DESELECT_SOUND);
	PrecacheSound(ONRUSH_START_SOUND);
	PrecacheSound(PREY_MARKED_SOUND);
	PrecacheSound("weapons/buffed_on.wav");
	PrecacheSound("weapons/buffed_off.wav");
	PrecacheSound("weapons/debris4.wav");
	PrecacheSound("physics/nearmiss/whoosh_large1.wav");

    //precache stuff
	Zero(Abno_Pages);
	Zero2(Special_Cooldowns);
	Zero(strength_active_1);
	Zero(strength_active_2);
	Zero(strength_active_3);
	Zero(Strenght_Amount);
	Zero(absorption_counter);
	Zero(Deep_Wound_Counter);
	Zero(Burst_Damage_Taken);
	Zero(current_abno_card_selection);
	Zero(current_card_selection);
	Zero(last_recorded_pap);
	Zero(counter_timer_exists);
	Zero(savagery_timer_exists);
	Zero(lms_buffs_given);
	Zero(Ego_Active);
	Zero(Special_Active);
	Zero(Prey_Mark_Cooldown);
	Zero(redashes);
	Zero(Onrush_Redash_Window);
	Zero(swing_type);
	Zero(Special_Damage_Boost);
	Zero(b_WeaponAttackSpeedModified);
	RM_Precached = false;
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
	PrecacheSound("physics/glass/glass_cup_break2.wav");
	if(!FileNetwork_Enabled())
		PrecacheRedMistMusic();
}
public void Red_Mist_SwitchToMeleeWeapon(int client, int weapon)
{
	int MeleeWeapon = EntRefToEntIndex(ref_MeleeWeapon[client]);
	if(!IsValidEntity(MeleeWeapon))
		return;
	SetEntPropFloat(MeleeWeapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.25);
	SetPlayerActiveWeapon(client, MeleeWeapon);
}

public void Vengeance_Logic(int client)
{
	
	float MaxHealth = float(SDKCall_GetMaxHealth(client));
	int Health = GetEntProp(client, Prop_Send, "m_iHealth");
	
	if(Health < MaxHealth / 2 && !strength_active_1[client])
	{
		Strenght_Amount[client] += 1;
		strength_active_1[client] = true;
		ApplyStatusEffect(client, client, "Red_Mist_Strength", 9999.0);
	}
	if(Health < MaxHealth / 3 && !strength_active_2[client])
	{
		Strenght_Amount[client] += 2;
		strength_active_2[client] = true;
		ApplyStatusEffect(client, client, "Red_Mist_Strength", 9999.0);
	}
	if(Health < MaxHealth / 4 && !strength_active_3[client])
	{
		Strenght_Amount[client] += 4;
		strength_active_3[client] = true;
		ApplyStatusEffect(client, client, "Red_Mist_Strength", 9999.0);
	}

	if(Health > MaxHealth / 2 && strength_active_1[client])
	{
		Strenght_Amount[client] -= 1;
		strength_active_1[client] = false;
	}
	if(Health > MaxHealth / 3 && strength_active_2[client])
	{
		Strenght_Amount[client] -= 2;
		strength_active_2[client] = false;
	}
	if(Health > MaxHealth / 4 && strength_active_3[client])
	{
		Strenght_Amount[client] -= 4;
		strength_active_3[client] = false;
	}

	//a bit convoluted but with this each boost can only trigger once, same with removal of it, soooo it should never go above the cap or below 0(hopefully)
}

void PrecacheRedMistMusic()
{
	if(!RM_Precached)
	{
        //TODO
		PrecacheSoundCustom("zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3");
		PrecacheSoundCustom(ONRUSH_HIT_SOUND);
		PrecacheSoundCustom(COUNTER_SOUND_HIT);
		RM_Precached = true;
	}
}

public void Red_Mist_OnTakeDamage_Take_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, int equipped_weapon, float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
		
	if(Abno_Pages[victim] & ABNORMPAGE_SAVAGERY)
	{
		float MaxHealth = float(SDKCall_GetMaxHealth(victim));
		Burst_Damage_Taken[victim] += damage;
		//PrintToChat(victim, "damage taken: [%.1f]", Burst_Damage_Taken[victim]);
		if(Burst_Damage_Taken[victim] > MaxHealth / 2)
		{
			ApplyStatusEffect(victim, victim, "Savagery Buff", 4.0);
			EmitSoundToClient(victim, "physics/nearmiss/whoosh_large1.wav", victim, _, 70, _, 1.0, 100);
			EmitSoundToClient(victim, "physics/nearmiss/whoosh_large1.wav", victim, _, 70, _, 1.0, 100);
		}
		if(!savagery_timer_exists[victim])
		{
			CreateTimer(2.0, Savagery_Reset_damage, victim);
			//PrintToChat(victim, "dmg timer started");
			savagery_timer_exists[victim] = true;
		}
	}
}
public void Red_Mist_OnTakeDamage_Take(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	

	float RMC_damage_cap = 0.0;
	float current = GetEntPropFloat(equipped_weapon, Prop_Send, "m_flNextPrimaryAttack");
	if(current < GetGameTime()) //only counter if not attacking
	{
		float VecMe[3];
		WorldSpaceCenter(victim, VecMe);
		float VecAttacker[3];
		WorldSpaceCenter(attacker, VecAttacker);
		float dist = GetVectorDistance(VecMe, VecAttacker, true);
		if(dist < (300.0 * 300.0))
		{
			if(!Special_Active[victim])
			{
				int DmgCapLvl = WeaponLevel[victim];
				if(DmgCapLvl <= 0)
					DmgCapLvl = 0;
				if(Abno_Pages[victim] & ABNORMPAGE_ROLE_OF_WOLF)
				{
					RMC_damage_cap = 100.0 * (DmgCapLvl + 1);
				}
				else
				{
					RMC_damage_cap = 50.0 * (DmgCapLvl + 1);
				}
				bool StopCounters = false;
				
				if(damage > RMC_damage_cap || counter_dice_amount[victim] <= 0)
				{
					if(!counter_timer_exists[victim])
					{
						StopCounters = true;
					}
				}
				else //counter normally
				{
					float CounterDamage = 65.0;
					CounterDamage *= WeaponDamageAttributeMultipliers(equipped_weapon,_,victim);
					CounterDamage *= 0.5; //1-1 swing damage is too strong
					static float angles[3];
					GetEntPropVector(victim, Prop_Send, "m_angRotation", angles);
					float vecForward[3];
					GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
					static float Entity_Position[3];
					WorldSpaceCenter(attacker, Entity_Position );
					float ReflectPosVec[3]; CalculateDamageForce(vecForward, 10000.0, ReflectPosVec);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(attacker));
					pack.WriteCell(EntIndexToEntRef(victim));
					pack.WriteCell(EntIndexToEntRef(victim));
					pack.WriteFloat(CounterDamage);
					pack.WriteCell(DMG_CLUB);
					pack.WriteCell(EntIndexToEntRef(equipped_weapon));
					pack.WriteFloat(ReflectPosVec[0]);
					pack.WriteFloat(ReflectPosVec[1]);
					pack.WriteFloat(ReflectPosVec[2]);
					pack.WriteFloat(Entity_Position[0]);
					pack.WriteFloat(Entity_Position[1]);
					pack.WriteFloat(Entity_Position[2]);
					pack.WriteCell(ZR_DAMAGE_REFLECT_LOGIC);
					RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
					damage *= 0.5;
					
					int Colour[3];
					int r = 255; //reeedd.
					int g = 25;
					int b = 25;
					if(Colour[0] != 0)
					{
						r = Colour[0];
						g = Colour[1];
						b = Colour[2];
					}
					int colorLayer4[4];
					SetColorRGBA(colorLayer4, r, g, b, 200);

					float player_pos[3];
					WorldSpaceCenter(victim, player_pos );

					TE_SetupBeamPoints(player_pos, Entity_Position, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(10.0 * 1.0 * 1.28), ClampBeamWidth(5.0 * 0.2 * 1.28), 0, 0.2, colorLayer4, 3);
					TE_SendToAll(0.0);

					EmitCustomToAll(COUNTER_SOUND_HIT, victim, _, 70, _, 0.6, 100);

					counter_dice_amount[victim] -= 1;
					AddEgoEnergy(victim, 3);
				}
				if(counter_dice_amount[victim] <= 0)
				{
					if(!counter_timer_exists[victim])
					{
						StopCounters = true;
					}
				}
				if(StopCounters)
				{
					
					CreateTimer(15.0, Timer_RM_CD_Restore, victim);
					
					//PrintToChat(victim, "damage taken: [%.1f]", damage);
					//PrintToChatAll("dice broke");
					counter_timer_exists[victim] = true;
					counter_dice_amount[victim] = 0;
					RemoveSpecificBuff(victim, "Red Mist Counter");//remove visual buff
					EmitSoundToClient(victim, "physics/glass/glass_cup_break2.wav", victim, _, 70, _, 1.0, 100);
					EmitSoundToClient(victim, "physics/glass/glass_cup_break2.wav", victim, _, 70, _, 1.0, 100);
					EmitSoundToClient(victim, "physics/glass/glass_cup_break2.wav", victim, _, 70, _, 1.0, 100);
				}
			}
		}
		
	}
	if(LastMann)
	{
		if(Abno_Pages[victim] & ABNORMPAGE_MOSB)
		{
			damage *= 0.5;
		}
	}

}

public Action Timer_RM_CD_Restore(Handle timer, int client)
{
	if(Abno_Pages[client] & ABNORMPAGE_ROLE_OF_WOLF)
	{
		counter_dice_amount[client] = 30;
		if(IsValidClient(client))
		{
			ApplyStatusEffect(client, client, "Red Mist Counter", 9999.0);//just visual
		}
	}
	else
	{
		counter_dice_amount[client] = 15;
		if(IsValidClient(client))
		{
			ApplyStatusEffect(client, client, "Red Mist Counter", 9999.0);//just visual
		}
	}
	counter_timer_exists[client] = false;
	//PrintToChatAll("dice Recovered");
	return Plugin_Handled;
}

void Func_RM_StrengthDisplay(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar, "⬆(%i)", Strenght_Amount[victim]);
	if(h_Red_Mist_Timer[victim] == null)
	{
		int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
		Apply_StatusEffect.TimeUntillOver = 0.0;
		E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
	}
}

void Func_RM_CounterAmount_Display(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	Format(HudToDisplay, SizeOfChar, "⚔(%i)", counter_dice_amount[victim]);
	if(h_Red_Mist_Timer[victim] == null)
	{
		int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
		Apply_StatusEffect.TimeUntillOver = 0.0;
		E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
	}
}
void Func_HorrizontalSlashCD(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	if(Ego_Active[victim])
	{
		if(Special_Cooldowns[victim][3] > GetGameTime())
			Format(HudToDisplay, SizeOfChar, "M2(%.1f)", Special_Cooldowns[victim][3] - GetGameTime());
		else
			Format(HudToDisplay, SizeOfChar, "M2(✔)");
	}
	else
	{
		if(Special_Cooldowns[victim][2] > GetGameTime())
			Format(HudToDisplay, SizeOfChar, "M2(%.1f)", Special_Cooldowns[victim][2] - GetGameTime());
		else
			Format(HudToDisplay, SizeOfChar, "M2(✔)");
	}
	if(h_Red_Mist_Timer[victim] == null)
	{
		int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
		Apply_StatusEffect.TimeUntillOver = 0.0;
		E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
	}
}
void Func_Ego_VerticalSlashCD(int attacker, int victim, StatusEffect Apply_MasterStatusEffect, E_StatusEffect Apply_StatusEffect, int SizeOfChar, char[] HudToDisplay)
{
	if(Special_Cooldowns[victim][1] > GetGameTime())
		Format(HudToDisplay, SizeOfChar, "M1(%.1f)", Special_Cooldowns[victim][1] - GetGameTime());
	else
		Format(HudToDisplay, SizeOfChar, "M1(✔)");

		
	if(h_Red_Mist_Timer[victim] == null)
	{
		int ArrayPosition = E_AL_StatusEffects[victim].FindValue(Apply_StatusEffect.BuffIndex, E_StatusEffect::BuffIndex);
		Apply_StatusEffect.TimeUntillOver = 0.0;
		E_AL_StatusEffects[victim].SetArray(ArrayPosition, Apply_StatusEffect);
	}
}


public Action Savagery_Reset_damage(Handle timer, int client)
{
	//PrintToChat(client, "dmg burst timer");
	Burst_Damage_Taken[client] = 0.0;
	savagery_timer_exists[client] = false;
	return Plugin_Handled;
}

public Action Absorption_Remove_Strength(Handle timer, int client)
{
	Strenght_Amount[client] -= 1;
	//PrintToChat(client, "Absorption strenght removed");
	return Plugin_Handled;
}

public Action RM_Prey_Cooldown(Handle timer, int client)
{
	Prey_Mark_Cooldown[client] = true;
	return Plugin_Handled;
}

public void UnFreeze_Onrush(int client)
{
	if(IsValidClient(client))
		SetEntityMoveType(client, MOVETYPE_WALK);
}

public Action MOSB_Lastman_Execution(Handle timer, int client)
{
	//kill client
	ApplyStatusEffect(client, client, "Nightmare Terror", 0.1);
	HealEntityGlobal(client, client, -9999999.9, _, _, HEAL_ABSOLUTE);
	ApplyStatusEffect(client, client, "Vuntulum Bomb EMP Death", 99999.9);
	CPrintToChatAll("{maroon}The bodies fully consumed {darkgrey}%N...",client);
	f_OneShotProtectionTimer[client] = GetGameTime() + 2.0;
	Special_Cooldowns[client][2] = GetGameTime() + (120.00 * CooldownReductionAmount(client));
	RemoveSpecificBuff(client, "Ego Manifestation");
	RemoveSpecificBuff(client, "Influence of the bodies");
	Ego_Active[client] = false;
	ForcePlayerSuicide(client);
	return Plugin_Handled;
}

public void Red_Mist_OnTakeDamage_Deal(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	
	//dmg nerf overall
	damage *= 0.95;


	float Strenght_boost;
	Strenght_boost = 1.0 + (0.05 * Strenght_Amount[attacker]);
	damage *= Strenght_boost;
	if(Abno_Pages[attacker] & ABNORMPAGE_DEEP_WOUND)
	{
		Deep_Wound_Counter[attacker] += 1;
		if(Deep_Wound_Counter[attacker] >= 5)
		{
			StartBleedingTimer(victim, attacker, damage / 8, 20, weapon, DMG_CLUB);
			Deep_Wound_Counter[attacker] = 0;
		}
	}
	if(Abno_Pages[attacker] & ABNORMPAGE_VAMPIRISM)
	{
		float HealByThis = (7.5 * WeaponLevel[attacker]);
		HealEntityGlobal(attacker, attacker, HealByThis, 1.0, 2.0, HEAL_SELFHEAL);
	}
	if(Abno_Pages[attacker] & ABNORMPAGE_PREY)
	{
		//PrintToChatAll("prey code works");
		if(Prey_Mark_Cooldown[attacker])//if cooldown is over
		{
			//PrintToChatAll("applied mark");
			ApplyStatusEffect(attacker, victim, "Mark Of Prey", 30.0);
			Prey_Mark_Cooldown[attacker] = false;
			EmitSoundToClient(attacker, "weapons/samurai/tf_marked_for_death_indicator.wav", attacker, _, 70, _, 1.0, 60);
			CreateTimer(20.0, RM_Prey_Cooldown, attacker);
		}
		if(HasSpecificBuff(victim, "Mark Of Prey"))
		{
			EmitSoundToClient(attacker, PREY_MARKED_SOUND, attacker, _, 70, _, 1.0, 60);
			//PrintToChatAll("enemy debuffed");
			if(b_thisNpcIsARaid[victim])
			{
				damage *= 1.15;
			}	
			else if(b_thisNpcIsABoss[victim])
			{
				damage *= 1.35;
			}
			else
			{
				damage *= 1.5;
			}	
		}
	}
	
	if(Special_Active[attacker])
	{
		if(current_card_selection[attacker] == 1)//vertical slash, single target, m1 ability
		{
			EmitSoundToAll(VERTICAL_SLASH_SOUND, attacker, _, 70, _, 1.0, 50);
			damage *= 11.0;
			Special_Active[attacker] = false;
			Rogue_OnAbilityUse(attacker, weapon);
			Special_Cooldowns[attacker][1] = GetGameTime() + (60.00 * CooldownReductionAmount(attacker));
			WeaponSpawnGibForce(victim, weapon);
			WeaponSpawnGibForce(victim, weapon);
		}
	}
	if(Special_Damage_Boost[attacker]) //Horrizontal Slash, multi target, m2 ability
	{
		damage *= 6.0;
		WeaponSpawnGibForce(victim, weapon);
	}
	AddEgoEnergy(attacker);
}
void AddEgoEnergy(int client, int dividing = 1)
{
	if(Ego_Active[client])
	{
		Ego_Energy[client] += (75 / dividing);
		if(Ego_Energy[client] > 1000)
		{
			Ego_Energy[client] = 1000;
		}	
	}
}

public void Red_Mist_On_Kill(int victim, int killer, int weapon)
{
	if(Abno_Pages[killer] & ABNORMPAGE_ABSORPTION)
	{
		//PrintToChatAll("absorption works");
		float MaxHealth = float(SDKCall_GetMaxHealth(killer));
		float HealByThis = (MaxHealth * 0.05);
		HealEntityGlobal(killer, killer, HealByThis, 1.0, 2.0, HEAL_SELFHEAL);
		absorption_counter[killer] += 1;
		//PrintToChat(killer, "Absorption heal triggered");
		if(absorption_counter[killer] >= 4)
		{
			absorption_counter[killer] = 0;
			Strenght_Amount[killer] += 1;
			ApplyStatusEffect(killer, killer, "Red_Mist_Strength", 9999.0);
			//PrintToChat(killer, "Absorption strenght trigered");
			CreateTimer(15.0, Absorption_Remove_Strength, killer);
		}
	}
	if(HasSpecificBuff(victim, "Mark Of Prey"))
	{
		float MaxHealth = float(SDKCall_GetMaxHealth(killer));
		HealEntityGlobal(killer, killer, MaxHealth * 0.2, 1.0, 2.0, HEAL_SELFHEAL);
		//PrintToChatAll("Marked Enemy Died");
	}
}

public void Red_Mist_Main_Attack(int client, int weapon)
{
	if(Special_Active[client])
	{
		//PrintToChatAll("Special attack");
		if(current_card_selection[client] == 1)//vertical
		{
			DataPack pack = new DataPack();
			pack.WriteCell(EntIndexToEntRef(client));
			pack.WriteFloat(GetGameTime() + 0.07);	
			RequestFrame(Greather_Split_Effect, pack);
		}
		if(current_card_selection[client] == 2)//ego
		{
			if(!Ego_Active[client])
			{
				Ego_Energy[client] = 1000;
				Ego_Active[client] = true;
				Ego_Cooldown_given[client] = false;
				Special_Cooldowns[client][2] = GetGameTime() + 999.00;
				Rogue_OnAbilityUse(client, weapon);
				ApplyStatusEffect(client, client, "Ego Manifestation", 9999.0);
				ApplyStatusEffect(client, client, "Ego Grace", 30.0);
				EmitSoundToAll("weapons/buffed_on.wav", client, _, 70, _, 1.0, 100);
				EmitSoundToAll("weapons/debris4.wav", client, _, 70, _, 1.0, 100);
				Special_Active[client] = false;
			}
			//Special_Cooldowns[client][2] = GetGameTime() + 20.00;
		}
		if(current_card_selection[client] == 3)//horizontal
		{
			swing_type[client] = SWING_TYPE_SPECIAL;
			Special_Damage_Boost[client] = true;
			Special_Cooldowns[client][3] = GetGameTime() + (90.00 * CooldownReductionAmount(client));
			Rogue_OnAbilityUse(client, weapon);
			EmitSoundToAll(HORIZONTAL_SLASH_SOUND, client, _, 70, _, 1.0, 50);
			DoHorrizontalSlashEffect(client);
			return;
		}
		
	}
	else
	{
		float attackspeed = Attributes_Get(weapon, 6, 1.0); //thanks judgement of iberia :D
		if(!b_WeaponAttackSpeedModified[weapon]) //The attackspeed is right now not modified, lets save it for later and then apply our faster attackspeed.
		{
			b_WeaponAttackSpeedModified[weapon] = true;
			attackspeed = (attackspeed * 0.25);
			Attributes_Set(weapon, 6, attackspeed);
		}
		else
		{
			b_WeaponAttackSpeedModified[weapon] = false;
			attackspeed = (attackspeed / 0.25);
			Attributes_Set(weapon, 6, attackspeed); //Make it really fast for 1 hit!
		}
	}
	if(Special_Damage_Boost[client])//we do this cuz "special_active" gets disabled before this function gets called, so this is a small workaround
	{
		Special_Damage_Boost[client] = false;
	}
	swing_type[client] = SWING_TYPE_NORMAL;
}

public void Red_Mist_Onrush(int client, int weapon)
{

	if(Ability_Check_Cooldown(client, 2) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, 2);

		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	if(h_Onrush_Check_Timer[client] != null)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	if(redashes[client] >= 3)//allow for 3 dashes
	{
		Ability_Apply_Cooldown(client, 2, 20.0);
		//PrintToChatAll("too many redashes");
		redashes[client] = 0;
		return;
	}
	Handle swingTrace;
	b_LagCompNPC_No_Layers = true;
	float vecSwingForward[3];
	StartLagCompensation_Base_Boss(client);
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 300.0, false, 35.0, true); //infinite range, and ignore walls!
	FinishLagCompensation_Base_boss();

	int target = TR_GetEntityIndex(swingTrace);
	delete swingTrace;
	if(!IsValidEnemy(client, target, true))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	if(redashes[client] < 3)
	{
		redashes[client] += 1;
	}
	
	Ability_Apply_Cooldown(client, 2, 0.5);
	if(redashes[client] >= 3)
	{
		Ability_Apply_Cooldown(client, 2, 20.0);
		redashes[client] = 0;
	}
	Rogue_OnAbilityUse(client, weapon);
	EmitSoundToAll(ONRUSH_START_SOUND, client, _, 70, _, 1.0, 90);
	EmitSoundToAll(ONRUSH_START_SOUND, client, _, 70, _, 1.0, 90);
	EmitSoundToAll(ONRUSH_START_SOUND, client, _, 70, _, 1.0, 90);
	Onrush_Redash_Window[client] = GetGameTime() + 1.5;
	SetEntityMoveType(client, MOVETYPE_WALK);
	TF2_AddCondition(client, TFCond_LostFooting, 0.35);
	TF2_AddCondition(client, TFCond_AirCurrent, 0.35);
	ApplyStatusEffect(client, client, "Intangible", 0.5);
	//ApplyStatusEffect(client, client, "Touch Ingored", 0.3);

	int trail = Trail_Attach(client, ARROW_TRAIL_RED, 125, 0.45, 40.0, 3.0, 5);
	SetEntityRenderColor(trail, 175, 25, 25, 125);
	SDKCall_SetLocalOrigin(trail, {0.0,0.0,50.0});
	CreateTimer(0.25, Timer_RemoveEntityParent, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.8, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
	DataPack Onrush_pack = new DataPack();
	Onrush_pack.WriteCell(client);
	Onrush_pack.WriteCell(EntIndexToEntRef(client));
	Onrush_pack.WriteCell(EntIndexToEntRef(weapon));
	Onrush_pack.WriteCell(EntIndexToEntRef(target));
	if(h_Onrush_Check_Timer[client] != null)
	{
		if(IsValidHandle(h_Onrush_Check_Timer[client]))
			delete h_Onrush_Check_Timer[client];
		h_Onrush_Check_Timer[client] = null;
	}
	h_Onrush_Check_Timer[client] = CreateTimer(0.1, Onrush_Check_Distance, Onrush_pack, TIMER_REPEAT);


	float MePos[3];
	WorldSpaceCenter(client, MePos);
	float TargPos[3];
	WorldSpaceCenter(target, TargPos);
	float flPos[3];
	MakeVectorFromPoints(MePos, TargPos, flPos);
	GetVectorAngles(flPos, flPos);
	static float velocity[3];
	GetAngleVectors(flPos, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 900.0;
	ScaleVector(velocity, knockback);
	velocity[2] += 150.0;    // a little boost to alleviate arcing issues

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}

public Action Onrush_Check_Distance(Handle timer, DataPack Onrush_pack)
{
	Onrush_pack.Reset();
	int clientindx = Onrush_pack.ReadCell();
	int client = EntRefToEntIndex(Onrush_pack.ReadCell());
	int weapon = EntRefToEntIndex(Onrush_pack.ReadCell());
	int target = EntRefToEntIndex(Onrush_pack.ReadCell());

	if(!IsEntityAlive(target) || !IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_Onrush_Check_Timer[clientindx] = null;
		return Plugin_Stop;
	}
	ApplyStatusEffect(client, client, "Red Mist Onrush", 0.5);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
	float VecMe[3];
	WorldSpaceCenter(client, VecMe);
	float VecVictim[3];
	WorldSpaceCenter(target, VecVictim);
	float dist = GetVectorDistance(VecMe, VecVictim, true);
	float DistanceMin = 125.0;
	if(b_IsGiant[target])
		DistanceMin = 150.0;
	if(dist < (DistanceMin * DistanceMin))
	{
		float OnrushDamage = 65.0;
		OnrushDamage *= WeaponDamageAttributeMultipliers(weapon,_,client);
		float Strenght_boost;
		Strenght_boost = 1.0 + (0.05 * Strenght_Amount[client]);
		OnrushDamage *= Strenght_boost;
		OnrushDamage *= 2.5; //yes
		static float angles[3];
		GetEntPropVector(client, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position );
		float ReflectPosVec[3]; CalculateDamageForce(vecForward, 10000.0, ReflectPosVec);
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(target));
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteFloat(OnrushDamage);
		pack.WriteCell(DMG_CLUB);
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteFloat(ReflectPosVec[0]);
		pack.WriteFloat(ReflectPosVec[1]);
		pack.WriteFloat(ReflectPosVec[2]);
		pack.WriteFloat(Entity_Position[0]);
		pack.WriteFloat(Entity_Position[1]);
		pack.WriteFloat(Entity_Position[2]);
		pack.WriteCell(ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
		RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);

		SetEntityMoveType(client, MOVETYPE_NONE);
		RequestFrames(UnFreeze_Onrush, 5, client);

		EmitCustomToAll(ONRUSH_HIT_SOUND, client, _, 70, _, 1.75, 100);

		float vAngles[3];
		float vOrigin[3];
		
		WorldSpaceCenter(client, vOrigin );

		GetVectorAnglesTwoPoints(vOrigin, Entity_Position, vAngles);

		float vecSwingForward[3];
		float vecSwingEnd[3];
		GetAngleVectors(vAngles, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
		vecSwingEnd[0] = vOrigin[0] - vecSwingForward[0] * 100.0;
		vecSwingEnd[1] = vOrigin[1] - vecSwingForward[1] * 100.0;
		vecSwingEnd[2] = vOrigin[2] - vecSwingForward[2] * 100.0;
		RedMistSlashEffect(vecSwingEnd, VecVictim, 15.0, {255,25,25});
		
		h_Onrush_Check_Timer[clientindx] = null;
		Onrush_Redash_Window[clientindx] = GetGameTime() + 1.5;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void Red_Mist_Special_M1(int client, int weapon)//for activating currently selected special
{
    if(last_recorded_pap[client] < WeaponLevel[client]) //abno page picking
    {
		switch (last_recorded_pap[client])//checks current pap
		{
			case 0://abno pages for 1st pap
			{
				Abno_Pages[client] |= ABNORMPAGE_PREY;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				//PrintToChatAll("pray 1");
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
			case 1://abno pages for 2nd pap
			{
				Abno_Pages[client] |= ABNORMPAGE_SAVAGERY;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				//PrintToChatAll("savagery 1");
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
			case 2://abno pages for 3rd pap
			{
				Abno_Pages[client] |= ABNORMPAGE_ABSORPTION;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				//PrintToChatAll("absorption 1");
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
			case 3://abno pages for 4th pap
			{
				Abno_Pages[client] |= ABNORMPAGE_VAMPIRISM;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				//PrintToChatAll("vampirism 1");
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
		}
    }
	else //normal function
	{
		if(Special_Active[client])//dont allow selection if special is already selected
		{
			Special_Active[client] = false; //disable special attack
			EmitSoundToClient(client, PAGE_DESELECT_SOUND, client, _, 70, _, 1.0, 90);
			//PrintToChatAll("Special off");
		}
		else
		{
			if(Special_Cooldowns[client][1] < GetGameTime())
			{
				Special_Active[client] = true;
				current_card_selection[client] = 1;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				Red_Mist_SwitchToMeleeWeapon(client, weapon);
				//PrintToChatAll("Special 1 on");
			}
		}
		//PrintToChat(client, "Current Card [%d]", current_card_selection[client]);
	}
}

public void Red_Mist_Special_M2(int client, int weapon)
{
	if(last_recorded_pap[client] < WeaponLevel[client]) //abno page picking
    {
		switch (last_recorded_pap[client])//checks current pap
		{
			case 0:
			{
				Abno_Pages[client] |= ABNORMPAGE_VENGEANCE;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
			case 1:
			{
				Abno_Pages[client] |= ABNORMPAGE_ROLE_OF_WOLF;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
			case 2:
			{
				Abno_Pages[client] |= ABNORMPAGE_MOSB;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
			case 3:
			{
				Abno_Pages[client] |= ABNORMPAGE_DEEP_WOUND;
				EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
				last_recorded_pap[client] += 1; //add +1 so you cant skip upgrades if you mass pap
			}
			
		}
	}
	else //normal function
	{
		if(Special_Active[client])
		{
			Special_Active[client] = false; //disable special attack
			EmitSoundToClient(client, PAGE_DESELECT_SOUND, client, _, 70, _, 1.0, 90);
			//PrintToChatAll("Special off");
		}
		else
		{
			if(WeaponLevel[client] >= 3)//only unlock those 2 after 5th pap
			{
				if(Ego_Active[client])
				{
					if(Special_Cooldowns[client][3] < GetGameTime() && Ego_Active[client])//horizontal slash
					{
						Special_Active[client] = true;
						current_card_selection[client] = 3;
						EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
						Red_Mist_SwitchToMeleeWeapon(client, weapon);
						//PrintToChatAll("Special 3 on");
					}
				}
				else
				{
					if(Special_Cooldowns[client][2] < GetGameTime() && !Ego_Active[client])//ego manifestation
					{
						Special_Active[client] = true;
						current_card_selection[client] = 2;
						EmitSoundToClient(client, PAGE_SELECT_SOUND, client, _, 70, _, 1.0, 90);
						Red_Mist_SwitchToMeleeWeapon(client, weapon);
						//PrintToChatAll("Special 2 on");
					}
				}
				
				
			}
		}
		//PrintToChat(client, "Current Card [%d]", current_card_selection[client]);
	}
}

void Abornmality_Page_Display(int client)
{

	if(IsIn_HitDetectionCooldown(client,client, RedMist_AbnormSelect))
	{
		return;
	}
	Set_HitDetectionCooldown(client,client, GetGameTime() + 0.25, RedMist_AbnormSelect);
	if(!IsIn_HitDetectionCooldown(client,client, RedMist_WasInAbnorm))
	{
		EmitSoundToClient(client, ABNORM_ENTER_SOUND, client, _, 70, _, 1.0, 90);
	}
	Set_HitDetectionCooldown(client,client, FAR_FUTURE, RedMist_WasInAbnorm);
	int red = 255;
	int green = 50;
	int blue = 50;
	//For each abnorm page, each side.
	SetHudTextParams(0.15 + GetRandomFloat(-0.01, 0.01), 0.5 + GetRandomFloat(-0.01, 0.01), 0.25, red, green, blue, 255);
	//ShowSyncHudText(client, SyncHud_WandMana, "%T\n [M1]","Ability has cooldown", client, 5.0);
	if(last_recorded_pap[client] < WeaponLevel[client])
	{
		if(last_recorded_pap[client] == 0)
		{
			ShowSyncHudText(client, SyncHud_WandMana, "%t", "Prey", "\n [M1]");
		}
		if(last_recorded_pap[client] == 1)
		{
			ShowSyncHudText(client, SyncHud_WandMana, "%t", "Claws of Savagery", "\n [M1]");
		}
		if(last_recorded_pap[client] == 2)
		{
			ShowSyncHudText(client, SyncHud_WandMana, "%t", "Absorption", "\n [M1]");
		}
		if(last_recorded_pap[client] == 3)
		{
			ShowSyncHudText(client, SyncHud_WandMana, "%t", "Vampirism", "\n [M1]");
		}
	}
	else//show normal pages
	{
		if(Special_Cooldowns[client][1] > GetGameTime())//cooldown not finished
		{
			float Ability_CD = Special_Cooldowns[client][1] - GetGameTime();
			if(Ability_CD < 0.0)
				Ability_CD = 0.0;
			ShowSyncHudText(client, SyncHud_WandMana, "%t", "Red Mist cooldown", Ability_CD);
		}
		else if(Special_Active[client] && current_card_selection[client] == 1)
		{
			ShowSyncHudText(client, SyncHud_WandMana, "%t", "Red Mist Card Selected");
		}
		else
		{
			ShowSyncHudText(client, SyncHud_WandMana, "%t", "Greater Slash Vertical", "\n [M1]");
		}
	}
	
	//ShowSyncHudText(client, SyncHud_WandMana, "The big kill\nHoly shit is that the red mist?\n [M1]");

	SetHudTextParams(0.65 + GetRandomFloat(-0.01, 0.01), 0.5 + GetRandomFloat(-0.01, 0.01), 0.25, red, green, blue, 255);
	//ShowSyncHudText(client, SyncHud_ArmorCounter, "%T\n [M2]", "Ability has cooldown", client, 5.0);
	if(last_recorded_pap[client] < WeaponLevel[client])
	{
		if(last_recorded_pap[client] == 0)
		{
			ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Vengeance", "\n [M2]");
		}
		if(last_recorded_pap[client] == 1)
		{
			ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "The Role of the Wolf", "\n [M2]");
		}
		if(last_recorded_pap[client] == 2)
		{
			ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Mountain of Corpses", "\n [M2]");
		}
		if(last_recorded_pap[client] == 3)
		{
			ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Deep Wound", "\n [M2]");
		}
	}
	else//show normal pages
	{
		if(WeaponLevel[client] < 3)
		{
			ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Red Mist Card Locked");
		}
		else
		{
			if(Ego_Active[client])
			{
				if(Special_Cooldowns[client][3] > GetGameTime())//cooldown not finished
				{
					float Ability_CD = Special_Cooldowns[client][3] - GetGameTime();
					if(Ability_CD < 0.0)
						Ability_CD = 0.0;
					ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Red Mist cooldown", Ability_CD);
				}
				else if(Special_Active[client] && current_card_selection[client] == 3)
				{
					ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Red Mist Card Selected");
				}
				else
				{
					ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Greater Slash Horizontal", "\n [M2]");
				}
			}
			else
			{
				if(Special_Cooldowns[client][2] > GetGameTime())//cooldown not finished
				{
					float Ability_CD = Special_Cooldowns[client][2] - GetGameTime();
					if(Ability_CD < 0.0)
						Ability_CD = 0.0;
					ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Red Mist cooldown", Ability_CD);
				}
				else if(Special_Active[client] && current_card_selection[client] == 2)
				{
					ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Red Mist Card Selected");
				}
				else
				{
					ShowSyncHudText(client, SyncHud_ArmorCounter, "%t", "Red Mist Ego", "\n [M2]");
				}
			}
		}
	}
	//ShowSyncHudText(client, SyncHud_ArmorCounter, "Absorbtion\nGain health on kill\n [M2]");
	//hide the huds used for this
	delay_hud[client] = GetGameTime() + 0.4;
	Mana_Hud_Delay[client] = GetGameTime() + 0.4;
	f_DisplayDamageHudCooldown[client] = GetGameTime() + 0.4;
	Set_HitDetectionCooldown(client,client, GetGameTime() + 0.4, DontUpdateHudClient);
	UTIL_ScreenFade(client, 33, 9999999, FFADE_IN, 0, 0, 0, 233);

}

void Greather_Split_Effect(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client))
	{
		delete pack;
		return;
	}
	float TimeUntillEnd = pack.ReadFloat();
	float TimeUntillSnap = TimeUntillEnd - GetGameTime();
	TimeUntillSnap *= 20.0;
	static float belowBossEyes[3];
	belowBossEyes[0] = 0.0;
	belowBossEyes[1] = 0.0;
	belowBossEyes[2] = 0.0;
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	if(GetGameTime() >= TimeUntillEnd)
	{
		//do final slash on the floor where they look  and them delete.
		Draw_Greather_Slash_Effect(Angles, client, belowBossEyes, 0.0);
		delete pack;
		return;
	}
	Draw_Greather_Slash_Effect(Angles, client, belowBossEyes, TimeUntillSnap);
	RequestFrame(Greather_Split_Effect, pack);
}

void Draw_Greather_Slash_Effect(float Angles[3], int client, float belowBossEyes[3], float AngleDeviation = 1.0)
{
	Angles[0] -= (30.0 * AngleDeviation);
	float vecForward[3];
	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float LaserFatness = 10.0;
	
	int Colour[3];
	Colour = {255,25,25};
	float VectorTarget_2[3];
	float VectorForward = 300.0; //a really high number.
	
	GetBeamDrawStartPoint_Stock(client, belowBossEyes,{0.0,0.0,0.0}, Angles);
	VectorTarget_2[0] = belowBossEyes[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = belowBossEyes[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = belowBossEyes[2] + vecForward[2] * VectorForward;
	RedMistSlashEffect(belowBossEyes, VectorTarget_2, LaserFatness, Colour);
}

void DoHorrizontalSlashEffect(int client)
{
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteFloat(GetGameTime() + 0.07);	
	RequestFrame(Horrizontal_Greather_Split_Effect, pack);
}

void Horrizontal_Greather_Split_Effect(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client))
	{
		delete pack;
		return;
	}
	float TimeUntillEnd = pack.ReadFloat();
	float TimeUntillSnap = TimeUntillEnd - GetGameTime();
	TimeUntillSnap *= 20.0;
	static float belowBossEyes[3];
	belowBossEyes[0] = 0.0;
	belowBossEyes[1] = 0.0;
	belowBossEyes[2] = 0.0;
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	if(GetGameTime() >= TimeUntillEnd)
	{
		//do final slash on the floor where they look  and them delete.
		Horrizontal_Draw_Greather_Slash_Effect(Angles, client, belowBossEyes, 0.0);
		delete pack;
		return;
	}
	Horrizontal_Draw_Greather_Slash_Effect(Angles, client, belowBossEyes, TimeUntillSnap);
	RequestFrame(Horrizontal_Greather_Split_Effect, pack);
}

void Horrizontal_Draw_Greather_Slash_Effect(float Angles[3], int client, float belowBossEyes[3], float AngleDeviation = 1.0)
{
	Angles[1] += 40.0;
	Angles[1] -= (40.0 * AngleDeviation);
	float vecForward[3];
	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float LaserFatness = 30.0;
	
	int Colour[3];
	Colour = {255,25,25};
	float VectorTarget_2[3];
	float VectorForward = 600.0; //a really high number.
	
	GetBeamDrawStartPoint_Stock(client, belowBossEyes,{0.0,0.0,0.0}, Angles);
	VectorTarget_2[0] = belowBossEyes[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = belowBossEyes[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = belowBossEyes[2] + vecForward[2] * VectorForward;
	RedMistSlashEffect(belowBossEyes, VectorTarget_2, LaserFatness, Colour);
}

void RedMistSlashEffect(float belowBossEyes[3], float vecHit[3], float diameter = 0.0, int color[3] = {0,0,0})
{	
	
	int r = 255; //Yellow.
	int g = 255;
	int b = 65;
	if(color[0] != 0)
	{
		r = color[0]; //Yellow.
		g = color[1];
		b = color[2];
	}

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, r, g, b, 200);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, r, g, b, 150);

	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter  * 0.4 * 1.28), 0, 0.3, colorLayer4, 3);
	TE_SendToAll(0.0);

	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.0 * 1.28), ClampBeamWidth(diameter * 0.2 * 1.28), 0, 0.2, colorLayer4, 3);
	TE_SendToAll(0.0);

	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.0 * 1.28), ClampBeamWidth(diameter * 0.2 * 1.28), 0, 0.3, colorLayer4, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.4 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	

	int glowColor[4];
	SetColorRGBA(glowColor, r, g, b, 30);
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 2.0 * 1.28), ClampBeamWidth(diameter * 1.4 * 1.28), 0, 1.0, glowColor, 0);
	TE_SendToAll(0.0);
}