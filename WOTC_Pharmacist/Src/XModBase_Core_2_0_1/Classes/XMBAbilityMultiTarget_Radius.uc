//---------------------------------------------------------------------------------------
//  FILE:    XMBAbilityMultiTarget_Radius.uc
//  AUTHOR:  xylthixlm
//
//  This file contains internal implementation of XModBase. You don't need to, and
//  shouldn't, use it directly.
//
//  INSTALLATION
//
//  Copy all the files in XModBase_Core_2_0_1/Classes/, XModBase_Interfaces/Classes/,
//  and LW_Tuple/Classes/ into similarly named directories under Src/.
//
//  DO NOT EDIT THIS FILE. This class is shared with other mods that use XModBase. If
//  you change this file, your mod will become incompatible with any other mod using
//  XModBase.
//---------------------------------------------------------------------------------------
class XMBAbilityMultiTarget_Radius extends X2AbilityMultiTarget_Radius
	implements(XMBOverrideInterface);

// XModBase version
var int MajorVersion, MinorVersion, PatchVersion;

// This is similar to the vanilla X2AbilityMultiTarget_SoldierBonusRadius, but that class only
// allows one radius-boosting effect, which is used by Volatile Mix. This class extends that
// to have multiple radius-boosting effects defined by XMBEffect_BonusRadius.
//
// The native-code bits of the targetting system are kind of funky, and just overriding
// GetTargetRadius doesn't work like you would expect. Instead, we modify fRadius directly.
// We save the modifier we used so we can undo the change before applying a new modifier.

var private float fRadiusModifier;		// The current modifier added into fRadius

// Calculate ability-specific radius modifiers.
simulated function CalculateRadiusModifier(const XComGameState_Ability Ability)
{
	local XComGameState_Unit SourceUnit;
	local StateObjectReference EffectRef;
	local XComGameState_Effect EffectState;
	local XMBEffectInterface BonusRadiusEffect;
	local XComGameStateHistory History;
	local LWTuple Tuple;

	Tuple = new class'LWTuple';
	Tuple.id = 'BonusRadius';

	fRadiusModifier = 0;

	History = `XCOMHISTORY;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));

	foreach SourceUnit.AffectedByEffects(EffectRef)
	{
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
		BonusRadiusEffect = XMBEffectInterface(EffectState.GetX2Effect());
		if (BonusRadiusEffect != none)
		{
			Tuple.Data.Length = 4;
			Tuple.Data[0].o = EffectState;
			Tuple.Data[0].kind = LWTVObject;
			Tuple.Data[1].o = SourceUnit;
			Tuple.Data[1].kind = LWTVObject;
			Tuple.Data[2].o = Ability;
			Tuple.Data[2].kind = LWTVObject;
			Tuple.Data[3].f = fTargetRadius;
			Tuple.Data[3].kind = LWTVFloat;

			if (BonusRadiusEffect.GetExtValue(Tuple))
				fRadiusModifier += Tuple.Data[0].f;
		}
	}
}

// Modify radius to include ability-specific modifiers. Note that fTargetRadius applies to all uses of the ability
// template (e.g. launch grenade) so we have to restore it correctly. This is a terrible hack.
simulated function float GetTargetRadius(const XComGameState_Ability Ability)
{
	fTargetRadius -= fRadiusModifier;
	CalculateRadiusModifier(Ability);
	fTargetRadius += fRadiusModifier;

	return super.GetTargetRadius(Ability);
}

// XMBOverrideInterface

function class GetOverrideBaseClass() 
{ 
	return class'X2AbilityMultiTarget_Radius';
}

function GetOverrideVersion(out int Major, out int Minor, out int Patch)
{
	Major = MajorVersion;
	Minor = MinorVersion;
	Patch = PatchVersion;
}

function bool GetExtValue(LWTuple Data) { return false; }
function bool SetExtValue(LWTuple Data) { return false; }
