#pragma semicolon 1
#pragma newdecls required

void Npc_OnTakeDamage_TheCollector(int attacker, int victim, float &damage) {
    int iHealth = GetEntProp(victim, Prop_Data, "m_iHealth");
    int iMaxHealth = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
    if (iHealth - damage > iMaxHealth*0.05)
        return;

    damage = iMaxHealth*2.0;
    PrintToChat(attacker, "the collector: damn, you're so skilled");
}