class X2Condition_UnitAffectedByPhysicalEffect extends X2Condition;

function name MeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameStateHistory History;
    local XComGameState_Unit TargetUnit;
    local XComGameState_Unit PrevTargetUnit;

	History = `XCOMHISTORY;

	TargetUnit = XComGameState_Unit(kTarget);

	if (TargetUnit == none)
    {
		return 'AA_NotAUnit';
    }

    // Get the state of the target before this action, because we don't want this to return true if this action is what caused the status effect
    PrevTargetUnit = XComGameState_Unit( History.GetPreviousGameStateForObject(TargetUnit));

	if (PrevTargetUnit == none)
    {
		return 'AA_NotAUnit';
    }

	if (PrevTargetUnit.IsBurning() || PrevTargetUnit.IsPoisoned() || PrevTargetUnit.IsAcidBurning())
    {
		return 'AA_Success';
    }

    if (PrevTargetUnit.AffectedByEffectNames.Find(class'X2StatusEffects'.default.BleedingName) != INDEX_NONE)
    {
        return 'AA_Success';
    }

	return 'AA_UnitIsNotImpaired';
}