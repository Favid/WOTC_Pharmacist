class X2AbilityCharges_BonusStims extends X2AbilityCharges_GremlinHeal;

var bool bCountMedikits;
var name RequiredAbility;
var int BonusStimCharges;

function int GetInitialCharges(XComGameState_Ability Ability, XComGameState_Unit Unit)
{
	local int TotalCharges;
    local XComGameState_Item SecondaryItem;
    local X2WeaponTemplate SecondaryWeaponTemplate;

    if (bCountMedikits)
    {
	    TotalCharges = super.GetInitialCharges(Ability, Unit);
    }
    else
    {
        TotalCharges = InitialCharges;
    }

    if(Unit.HasSoldierAbility(RequiredAbility))
    {
        TotalCharges += BonusStimCharges;
    }

    SecondaryItem = Unit.GetItemInSlot(eInvSlot_SecondaryWeapon);
    SecondaryWeaponTemplate = X2WeaponTemplate(SecondaryItem.GetMyTemplate());
    // TODO config
    if(SecondaryWeaponTemplate != none)
    {
        if(SecondaryWeaponTemplate.WeaponTech == 'magnetic')
        {
            TotalCharges += 1;
        }
        else if(SecondaryWeaponTemplate.WeaponTech == 'beam')
        {
            TotalCharges += 2;
        }
    }

    return TotalCharges;
}

DefaultProperties
{
    bCountMedikits = true;
	RequiredAbility = "";
    BonusStimCharges = 0;
}