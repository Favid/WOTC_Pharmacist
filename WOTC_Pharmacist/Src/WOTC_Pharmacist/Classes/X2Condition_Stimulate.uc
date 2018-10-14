class X2Condition_Stimulate extends X2Condition_RevivalProtocol;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (TargetUnit.IsBleedingOut())
		return 'AA_Success';
        
	return super.CallMeetsCondition(kTarget);
}