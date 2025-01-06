static Handle TrueStrengthHandle[MAXPLAYERS+1][MAXENTITIES];
//a timer on each entity, private to each player

#define BLEED_TIMEOUT_DURATION 5.0
#define HITS_UNTILL_ENRAGE_NORM 6

static bool TrueStrength[MAXPLAYERS+1] = {false, ...};
//does the player have this item
static bool TrueStrength_Rage[MAXPLAYERS+1] = {false, ...};
//is the player enraged
static int i_BleedStackLogic[MAXPLAYERS+1][MAXENTITIES];
//How many bleedstacks does this entity have
static int i_BleedStackLogicMax[MAXPLAYERS+1];
//What is the max requires bleed stack needed to enrage
static float f_TimerBleedRemove[MAXENTITIES];
//Time untill the bleed or enrage timer removes itself
#define TRUE_STRENGTH_SOUND "items/powerup_pickup_strength.wav"

public void TrueStrengthUnequip(int client)
{
	TrueStrength[client] = false;
	TrueStrength_Rage[client] = false;
	if(TrueStrengthHandle[client][client] != INVALID_HANDLE)
		delete TrueStrengthHandle[client][client];
}

public void TrueStrengthEquip(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		PrecacheSound(TRUE_STRENGTH_SOUND, true);
		TrueStrength[client] = true;		
	}
}

void Abiltity_TrueStrength_PluginStart()
{
	Zero2(TrueStrengthHandle);
}

void NPC_Ability_TrueStrength_OnTakeDamage(int attacker, int victim, int weapon, int &damagetype, int damagezrcustom)
{
	if (attacker <= 0 || attacker > MaxClients)
		return;

	if (!TrueStrength[attacker])
		return;

	if(damagezrcustom & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	
	if(!(damagetype & DMG_CLUB))
		return;

	if(!IsValidEntity(weapon))
		return;

	float AttackspeedScaling = Attributes_Get(weapon, 6, 1.0);
	AttackspeedScaling = 1.0 / AttackspeedScaling;
	i_BleedStackLogicMax[attacker] = RoundToNearest(float(HITS_UNTILL_ENRAGE_NORM) * AttackspeedScaling);

	if(TrueStrengthHandle[attacker][victim] == INVALID_HANDLE)
	{
		//Give them Bleed Timer
		DataPack pack;
		TrueStrengthHandle[attacker][victim] = CreateDataTimer(0.5, TrueStrengthTimer, pack, TIMER_REPEAT);
		pack.WriteCell(attacker);	
		pack.WriteCell(victim);	
		pack.WriteCell(EntIndexToEntRef(victim));
	}
	if(TrueStength_ClientBuff(attacker))
	{
		i_BleedStackLogic[attacker][victim] += 9999;
	}
	i_BleedStackLogic[attacker][victim] += 1;
	f_TimerBleedRemove[victim] = GetGameTime() + BLEED_TIMEOUT_DURATION;
	if(i_BleedStackLogic[attacker][victim] >= i_BleedStackLogicMax[attacker])
	{
		i_BleedStackLogic[attacker][victim] = i_BleedStackLogicMax[attacker];
		//the npc has hit their bleed limit, enrage the melee player.
		f_TimerBleedRemove[attacker] = GetGameTime() + (BLEED_TIMEOUT_DURATION * 1.5);
		if(TrueStrengthHandle[attacker][attacker] == INVALID_HANDLE)
		{
			DataPack pack;
			TrueStrengthHandle[attacker][attacker] = CreateDataTimer(0.5, TrueStrengthTimer, pack, TIMER_REPEAT);
			pack.WriteCell(attacker);	
			pack.WriteCell(attacker);	
			pack.WriteCell(EntIndexToEntRef(attacker));	
			TrueStrength_Rage[attacker]	= true;
		//	ParticleEffectAt(powerup_pos, "utaunt_arcane_green_sparkle_start", 1.0);
			EmitSoundToAll(TRUE_STRENGTH_SOUND, attacker, SNDCHAN_STATIC, 100, _);
			TF2_AddCondition(attacker, TFCond_MegaHeal, 0.5, attacker);
		//	MakePlayerGiveResponseVoice(attacker, 1); //haha!
		}
	}
}

static Action TrueStrengthTimer(Handle dashHud, DataPack pack)
{
	pack.Reset();
	int o_attacker = pack.ReadCell();
	int o_victim = pack.ReadCell();
	int victim = EntRefToEntIndex(pack.ReadCell());
	if (!IsValidClient(o_attacker))
	{
		TrueStrength_Reset(dashHud, o_victim);
		return Plugin_Stop;
	}
	if (!IsValidEntity(victim))
	{
		TrueStrength_Reset(dashHud, o_victim);
		return Plugin_Stop;
	}
	if(o_attacker == o_victim)
	{
		//This is playercode, this ONLY can come if the client reached their max bleed stacks.
		if(f_TimerBleedRemove[o_attacker] < GetGameTime())
		{
			//Timer has expired, return them back to normal.
			TrueStrength_Rage[o_attacker] = false;
			TrueStrengthHandle[o_attacker][o_attacker] = null;
			return Plugin_Stop;
		}
		return Plugin_Continue;
	}
	else
	{
		if(f_TimerBleedRemove[o_victim] > GetGameTime())
		{
			if(i_BleedStackLogic[o_attacker][victim] >= i_BleedStackLogicMax[o_attacker])
			{
				i_BleedStackLogic[o_attacker][victim] = i_BleedStackLogicMax[o_attacker];
			}
			int StengthStats = Stats_Strength(o_attacker);
			float damageDelt = RPGStats_FlatDamageSetStats(o_attacker, 0, StengthStats);
			damageDelt *= 0.25;
			damageDelt *= 0.35;
			damageDelt *= (float(i_BleedStackLogic[o_attacker][victim]) + 0.001) / (float(i_BleedStackLogicMax[o_attacker]) + 0.001);
			float pos[3];
			WorldSpaceCenter(victim, pos);
			//it shall pierce abit of flat resistance.
			f_FlatDamagePiercing[o_attacker] = 0.35;
			SDKHooks_TakeDamage(victim, o_attacker, o_attacker, damageDelt, DMG_CLUB, _, _, pos, false, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
			f_FlatDamagePiercing[o_attacker] = 1.0;
			return Plugin_Continue;
		}
		else
		{
			//Timer has expired, bleed turns off.
			TrueStrengthHandle[o_attacker][victim] = null;
			i_BleedStackLogic[o_attacker][victim] = 0;
			return Plugin_Stop;
		}
	}
}

int TrueStrength_StacksOnEntity(int client, int entity)
{
	return i_BleedStackLogic[client][entity];
}
int TrueStrength_StacksOnEntityMax(int client)
{
	return i_BleedStackLogicMax[client];
}
bool TrueStength_ClientBuff(int client)
{
	return TrueStrength_Rage[client];
}
void TrueStrength_Reset(Handle dashHud = null, int entity)
{
	for(int client; client <= MaxClients; client++)
	{
		i_BleedStackLogic[client][entity] = 0;
		if(TrueStrengthHandle[client][entity] != INVALID_HANDLE && TrueStrengthHandle[client][entity] != dashHud)
			delete TrueStrengthHandle[client][entity];

		TrueStrengthHandle[client][entity] = null;
	}
}
