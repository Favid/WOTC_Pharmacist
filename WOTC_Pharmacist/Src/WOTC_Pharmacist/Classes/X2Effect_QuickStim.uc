class X2Effect_QuickStim extends X2Effect_Persistent;

var array<name> ValidAbilities;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'SG_QuickStim', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local name						AbilityName;
	local XComGameState_Ability		AbilityState;

    `LOG("X2Effect_QuickStim: Enter");

	if(kAbility == none)
    {
        `LOG("X2Effect_QuickStim: No ability");
		return false;
    }

	AbilityName = kAbility.GetMyTemplateName();

	if(ValidAbilities.Find(AbilityName) != INDEX_NONE)
	{
        `LOG("X2Effect_QuickStim: Invalid ability");
		if (SourceUnit.ActionPoints.Length != PreCostActionPoints.Length)
		{
            `LOG("X2Effect_QuickStim: No action cost");
			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (AbilityState != none)
			{
                `LOG("X2Effect_QuickStim: AbilityState found, attempting to refund action points...");
				SourceUnit.ActionPoints = PreCostActionPoints;
				EffectState.RemoveEffect(NewGameState, NewGameState);

				`XEVENTMGR.TriggerEvent('SG_QuickStim', AbilityState, SourceUnit, NewGameState);

				return true;
			}
		}
	}
	return false;
}