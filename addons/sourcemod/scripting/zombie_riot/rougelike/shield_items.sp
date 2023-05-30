
//This is shield charges
int i_MalfunctionShield[MAXENTITIES]; 
void OnTakeDamage_ShieldLogic(int victim, int holding_weapon)
{
    if(b_MalfunctionShield)
    {
        if(i_MalfunctionShield[victim] > 0)
        {
            i_MalfunctionShield[victim] -= 1;
            return true;
        }
    }
    return false;
}