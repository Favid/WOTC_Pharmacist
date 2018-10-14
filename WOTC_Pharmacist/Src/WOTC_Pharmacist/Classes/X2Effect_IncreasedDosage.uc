class X2Effect_IncreasedDosage extends X2Effect_Persistent;

var int BonusDamageOverTime;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;

	if (!class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
    {
		return 0;
    }

	// Damage preview doesn't fill out the EffectRef, so skip this check if there's no EffectRef
	if (AppliedData.EffectRef.SourceTemplateName != '')
	{
		WeaponDamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
		if (WeaponDamageEffect != none && WeaponDamageEffect.EffectDamageValue.DamageType == 'Poison')
        {
            //`LOG("=== Increased Dosage SourceTemplateName: " $ AppliedData.EffectRef.SourceTemplateName);
			return BonusDamageOverTime;
        }
	}

	return 0;
}
