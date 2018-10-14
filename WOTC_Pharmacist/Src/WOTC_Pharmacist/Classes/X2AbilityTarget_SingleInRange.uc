class X2AbilityTarget_SingleInRange extends X2AbilityTarget_Single;

var int RangeInTiles;

simulated function name GetPrimaryTargetOptions(const XComGameState_Ability Ability, out array<AvailableTarget> Targets)
{
	local XComGameState_Unit	SourceUnit, TargetUnit;
	local int					i;
	local name					Code;
	local int					Distance;
		
	Code = super.GetPrimaryTargetOptions(Ability,Targets);
	//`LOG("X2AbilityTarget_SingleInRange: Code from super is " $ Code);
	//`LOG("X2AbilityTarget_SingleInRange: RangeInTiles " $ string(RangeInTiles));
	//`LOG("X2AbilityTarget_SingleInRange: Targets.Length " $ string(Targets.Length));

	SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));

	for (i = Targets.Length - 1; i >= 0; --i)
	{
		TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Targets[i].PrimaryTarget.ObjectID));
	    Distance = SourceUnit.TileDistanceBetween(TargetUnit);
		//`LOG("X2AbilityTarget_SingleInRange: TargetUnit.GetFullName(): " $ TargetUnit.GetFullName());
		//`LOG("X2AbilityTarget_SingleInRange: Distance: " $ string(Distance));

		if (Distance > RangeInTiles)
		{
			Targets.Remove(i,1);
			//`LOG("X2AbilityTarget_SingleInRange: Removing a target");
		}
	}
	if ((Code == 'AA_Success') && (Targets.Length < 1))
	{
		//`LOG("X2AbilityTarget_SingleInRange: No targets");
		return 'AA_NoTargets';
	}
	return Code;
}

simulated function bool ValidatePrimaryTargetOption(const XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_BaseObject TargetObject)
{
	local bool					b_valid;
	local XComGameState_Unit	TargetUnit;

	b_valid = Super.ValidatePrimaryTargetOption(Ability, SourceUnit, TargetObject);
	TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetObject.ObjectID));
	if (TargetUnit == none)
	{
		//`LOG("X2AbilityTarget_SingleInRange: No target unit");
		return false;
	}
	if (b_valid)
	{
		if (SourceUnit.TileDistanceBetween(TargetUnit) > RangeInTiles)
		{
			//`LOG("X2AbilityTarget_SingleInRange: Target too far");
			return false;
		}
	}
	return b_valid;
}