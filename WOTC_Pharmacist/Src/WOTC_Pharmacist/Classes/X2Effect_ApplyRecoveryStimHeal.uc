class X2Effect_ApplyRecoveryStimHeal extends X2Effect_ApplyMedikitHeal;

var int BonusHealAmount_CV;
var int BonusHealAmount_MG;
var int BonusHealAmount_BM;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Ability Ability;
	local XComGameState_Unit TargetUnit, SourceUnit;
	local XComGameState_Item ItemState;
	local X2WeaponTemplate StimGunTemplate;
	local int SourceObjectID, HealAmount;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	Ability = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (Ability == none)
		Ability = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (Ability != none && TargetUnit != none)
	{
		HealAmount = PerUseHP;

		if (IncreasedHealProject != '')
		{
			XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
			if (XComHQ != None && XComHQ.IsTechResearched(IncreasedHealProject))
				HealAmount = IncreasedPerUseHP;
		}

		ItemState = Ability.GetSourceWeapon();
		if (ItemState != none)
		{
			StimGunTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
			if (StimGunTemplate != none && StimGunTemplate.WeaponCat == 'stimgun')
            {
				if (StimGunTemplate.WeaponTech == 'conventional')
                {
                    HealAmount += BonusHealAmount_CV;
                }
                else if (StimGunTemplate.WeaponTech == 'magnetic')
                {
                    HealAmount += BonusHealAmount_MG;
                }
                else if (StimGunTemplate.WeaponTech == 'beam')
                {
                    HealAmount += BonusHealAmount_BM;
                }
            }
		}

		TargetUnit.ModifyCurrentStat(eStat_HP, HealAmount);
		`TRIGGERXP('XpHealDamage', ApplyEffectParameters.SourceStateObjectRef, kNewTargetState.GetReference(), NewGameState);

		SourceObjectID = ApplyEffectParameters.SourceStateObjectRef.ObjectID;
		SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(SourceObjectID));
		if ((SourceObjectID != TargetUnit.ObjectID) && SourceUnit.CanEarnSoldierRelationshipPoints(TargetUnit)) // pmiller - so that you can't have a relationship with yourself
		{
			SourceUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SourceObjectID));
			SourceUnit.AddToSquadmateScore(TargetUnit.ObjectID, class'X2ExperienceConfig'.default.SquadmateScore_MedikitHeal);
			TargetUnit.AddToSquadmateScore(SourceUnit.ObjectID, class'X2ExperienceConfig'.default.SquadmateScore_MedikitHeal);
		}
	}
}