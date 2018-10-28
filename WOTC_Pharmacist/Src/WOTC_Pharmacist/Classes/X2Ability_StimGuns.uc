class X2Ability_StimGuns extends XMBAbility config (SoldierSkills_StimGun);

var config int RECOVERYSTIM_BASE_CHARGES;
var config int RECOVERYSTIM_BONUS_HEAL_CV;
var config int RECOVERYSTIM_BONUS_HEAL_MG;
var config int RECOVERYSTIM_BONUS_HEAL_BM;

var config int OVERTHECOUNTER_BONUS_RECOVERY_STIMS;

var config int LINGERINGEFFECTS_HEAL_PER_TURN;
var config int LINGERINGEFFECTS_MAX_HEALTH;

var config int VENOMSTIM_BASE_CHARGES;

var config int INCREASEDDOSAGE_DOT_BONUS;

var config int UNDERTHECOUNTER_BONUS_VENOM_STIMS;

var config int QUICKSTIM_COOLDOWN;
var config array<name> QUICKSTIM_APPLY_TO_ABILITIES;

var config int TOXICCLOUD_CHARGES;

var config int COMBATCLINIC_CHARGES;

var config int NITROSTIM_BASE_CHARGES;
var config int NITROSTIM_DURATION;
var config int NITROSTIM_CRIT_BONUS;
var config int NITROSTIM_MOBILITY_BONUS;

var config int FOCUSSTIM_BASE_CHARGES;
var config int FOCUSSTIM_DURATION;
var config int FOCUSSTIM_AIM_BONUS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RecoveryStim());
	Templates.AddItem(RecoveryStimPassive());
	Templates.AddItem(StabilizeStim());
	Templates.AddItem(VenomStim());
	Templates.AddItem(VenomStimPassive());
	Templates.AddItem(PinsAndNeedles());
	Templates.AddItem(Neurotoxin());
	Templates.AddItem(LingeringEffects());
	Templates.AddItem(OverTheCounter());
	Templates.AddItem(UnderTheTable());
	Templates.AddItem(CombatClinic());
	Templates.AddItem(QuickStim());
	Templates.AddItem(ToxicCloud());
	Templates.AddItem(IncreasedDosage());
	Templates.AddItem(NitroStim());
	Templates.AddItem(FocusStim());
	
	return Templates;
}

static function X2AbilityTemplate RecoveryStim()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
    local X2AbilityCharges_BonusStims           Charges;
    local X2AbilityCost_Charges                 ChargeCost;
	local X2Effect_ApplyRecoveryStimHeal		MedikitHeal;
    local X2Effect_RemoveEffectsByDamageType    RemoveEffects;
    local X2Effect_Regeneration                 RegenerationEffect;
    local X2Condition_AbilityProperty           RegenerationCondition;
	local X2Condition_Visibility			    TargetVisibilityCondition;
    local X2Condition_UnitProperty              UnitPropertyCondition;
	local name                                  HealType;
	local array<name>                           SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_RecoveryStim');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///Pharmacist.Perk_Ph_RecoveryStim";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY + 10;
	Template.Hostility = eHostility_Defensive;

	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
    Template.DisplayTargetHitChance = false;
	Template.bShowActivation = false;
	Template.bSkipFireAction = false;
	Template.ConcealmentRule = eConceal_Always;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

    // Uses Gremlin Heal calculations for number of charges - meaning charges are incresed by equiping medikits
    // Also grants bonus charges for the Over the Counter ability
    Charges = new class'X2AbilityCharges_BonusStims';
    Charges.InitialCharges = default.RECOVERYSTIM_BASE_CHARGES;
    Charges.RequiredAbility = 'SG_OverTheCounter';
    Charges.BonusStimCharges = default.OVERTHECOUNTER_BONUS_RECOVERY_STIMS;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	ChargeCost.SharedAbilityCharges.AddItem('SG_StabilizeStim');
	Template.AbilityCosts.AddItem(ChargeCost);
    
    // Only organic allies who have been wounded
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeFullHealth = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	// Must be visible, does not work at squadsight ranges
	TargetVisibilityCondition = new class'X2Condition_Visibility';
    TargetVisibilityCondition.bRequireGameplayVisible = true;
    TargetVisibilityCondition.bAllowSquadsight = false;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Only at single targets that are in range, or self
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	// Medikit Heal Effect
	MedikitHeal = new class'X2Effect_ApplyRecoveryStimHeal';
	MedikitHeal.PerUseHP = class'X2Ability_DefaultAbilitySet'.default.MEDIKIT_PERUSEHP;
	MedikitHeal.IncreasedHealProject = 'BattlefieldMedicine';
	MedikitHeal.IncreasedPerUseHP = class'X2Ability_DefaultAbilitySet'.default.NANOMEDIKIT_PERUSEHP;
	MedikitHeal.BonusHealAmount_CV = default.RECOVERYSTIM_BONUS_HEAL_CV;
	MedikitHeal.BonusHealAmount_MG = default.RECOVERYSTIM_BONUS_HEAL_MG;
	MedikitHeal.BonusHealAmount_BM = default.RECOVERYSTIM_BONUS_HEAL_BM;
	Template.AddTargetEffect(MedikitHeal);

    // Remove effects that a Medikit removes
	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	foreach class'X2Ability_DefaultAbilitySet'.default.MedikitHealEffectTypes(HealType)
	{
		RemoveEffects.DamageTypesToRemove.AddItem(HealType);
	}
	Template.AddTargetEffect(RemoveEffects);

    // Regeneration Effect if user has Lingering Effects
	RegenerationEffect = new class'X2Effect_Regeneration';
	RegenerationEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
	RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	RegenerationEffect.HealAmount = default.LINGERINGEFFECTS_HEAL_PER_TURN;
	RegenerationEffect.MaxHealAmount = default.LINGERINGEFFECTS_MAX_HEALTH;
	RegenerationEffect.HealthRegeneratedName = 'SG_LingeringEffects_Regeneration';
	RegenerationCondition = new class'X2Condition_AbilityProperty';
	RegenerationCondition.OwnerHasSoldierAbilities.AddItem('SG_LingeringEffects');
	RegenerationEffect.TargetConditions.AddItem(RegenerationCondition);
	Template.AddTargetEffect(RegenerationEffect);

	Template.ActivationSpeech = 'HealingAlly';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.OverrideAbilities.AddItem('MedikitHeal');
	Template.OverrideAbilities.AddItem('NanoMedikitHeal');

	Template.AdditionalAbilities.AddItem('SG_StabilizeStim');

	Template.bOverrideWeapon = true;
    
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	return Template;
}

static function X2AbilityTemplate RecoveryStimPassive()
{
	local X2AbilityTemplate Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_RecoveryStim_Passive');

	Template.IconImage = "img:///Pharmacist.Perk_Ph_RecoveryStim";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate StabilizeStim()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
    local X2AbilityCharges_BonusStims           Charges;
    local X2AbilityCost_Charges                 ChargeCost;
    local X2Effect_RemoveEffects                RemoveEffects;
	local X2Condition_Visibility			    TargetVisibilityCondition;
    local X2Condition_UnitProperty              UnitPropertyCondition;
	local array<name>                           SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_StabilizeStim');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///Pharmacist.Perk_Ph_StabilizeStim";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STABILIZE_PRIORITY;
	Template.Hostility = eHostility_Defensive;

	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
    Template.DisplayTargetHitChance = false;
	Template.bShowActivation = false;
	Template.bSkipFireAction = false;
	Template.ConcealmentRule = eConceal_Always;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

    //
    Charges = new class'X2AbilityCharges_BonusStims';
	Charges.bStabilize = true;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	ChargeCost.SharedAbilityCharges.AddItem('SG_RecoveryStim');
	Template.AbilityCosts.AddItem(ChargeCost);
    
    // Only organic allies who are bleeding out
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeAlive = false;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.IsBleedingOut = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	// Must be visible, does not work at squadsight ranges
	TargetVisibilityCondition = new class'X2Condition_Visibility';
    TargetVisibilityCondition.bRequireGameplayVisible = true;
    TargetVisibilityCondition.bAllowSquadsight = false;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Only at single targets that are in range, or self
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

    // Remove bleeding out and knock the target out
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);
	Template.AddTargetEffect(RemoveEffects);
	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateUnconsciousStatusEffect(, true));

	Template.ActivationSpeech = 'StabilizingAlly';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bOverrideWeapon = true;

	Template.OverrideAbilities.AddItem('MedikitStabilize');
    
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	return Template;
}

static function X2AbilityTemplate VenomStim()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
    local X2Effect_PersistentStatChange     DisorientEffect;
    local X2Condition_UnitImmunities        VulnerableToPoisonCondition;
    local X2Condition_AbilityProperty       WeaponDamageCondition;
    local X2Condition_AbilityProperty       DisorientCondition;
    local X2AbilityCharges_BonusStims       Charges;
    local X2AbilityCost_Charges             ChargeCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_VenomStim');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///Pharmacist.Perk_Ph_VenomStim";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY + 11;
	Template.Hostility = eHostility_Offensive;

	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
    Template.DisplayTargetHitChance = true;
	Template.bShowActivation = false;
	Template.bSkipFireAction = false;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

    // Uses Gremlin Heal calculations for number of charges - meaning charges are incresed by equiping medikits
    // Also grants bonus chargess for the Under the Table ability
    Charges = new class'X2AbilityCharges_BonusStims';
    Charges.InitialCharges = default.VENOMSTIM_BASE_CHARGES;
    Charges.RequiredAbility = 'SG_UnderTheTable';
    Charges.BonusStimCharges = default.UNDERTHECOUNTER_BONUS_VENOM_STIMS;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

    // Cannot be used on enemies immune to Poison
    VulnerableToPoisonCondition = new class'X2Condition_UnitImmunities';
    VulnerableToPoisonCondition.ExcludeDamageTypes.AddItem('Poison');
	Template.AbilityTargetConditions.AddItem(VulnerableToPoisonCondition);
    
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
    
	Template.AddTargetEffect(class'X2StatusEffects'.static.CreatePoisonedStatusEffect());

    // Disorient effect which only applies if the user has Neurotoxin
    DisorientEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, 0.0f, false);
	DisorientCondition = new class'X2Condition_AbilityProperty';
	DisorientCondition.OwnerHasSoldierAbilities.AddItem('SG_Neurotoxin');
	DisorientEffect.TargetConditions.AddItem(DisorientCondition);
	Template.AddTargetEffect(DisorientEffect);
    
    // Damage effect which only applies if the user has Pins and Needles
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bIgnoreBaseDamage = true;
	WeaponDamageEffect.DamageTag = 'VenomStim';
	WeaponDamageEffect.bBypassShields = true;
	WeaponDamageEffect.bIgnoreArmor = true;
	WeaponDamageCondition = new class'X2Condition_AbilityProperty';
	WeaponDamageCondition.OwnerHasSoldierAbilities.AddItem('SG_PinsAndNeedles');
	WeaponDamageEffect.TargetConditions.AddItem(WeaponDamageCondition);
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.AssociatedPassives.AddItem('SG_PinsAndNeedles');
	Template.AssociatedPassives.AddItem('SG_Neurotoxin');

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	return Template;
}

static function X2AbilityTemplate VenomStimPassive()
{
	local X2AbilityTemplate Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_VenomStim_Passive');

	Template.IconImage = "img:///Pharmacist.Perk_Ph_VenomStim";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate PinsAndNeedles()
{
    return PurePassive('SG_PinsAndNeedles', "img:///Pharmacist.Perk_Ph_PinsNeedles", false);
}

static function X2AbilityTemplate Neurotoxin()
{
    return PurePassive('SG_Neurotoxin', "img:///Pharmacist.Perk_Ph_Neurotoxin", false);
}

static function X2AbilityTemplate LingeringEffects()
{
    return PurePassive('SG_LingeringEffects', "img:///Pharmacist.Perk_Ph_LingeringEffects", false);
}

static function X2AbilityTemplate OverTheCounter()
{
    return PurePassive('SG_OverTheCounter', "img:///Pharmacist.Perk_Ph_OverCounter", false);
}

static function X2AbilityTemplate UnderTheTable()
{
    return PurePassive('SG_UnderTheTable', "img:///Pharmacist.Perk_Ph_UnderTabel", false);
}

static function X2AbilityTemplate IncreasedDosage()
{
    local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_IncreasedDosage              DamageModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_IncreasedDosage');
	Template.IconImage = "img:///Pharmacist.Perk_Ph_IncreasedDosage";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	DamageModifier = new class'X2Effect_IncreasedDosage';
    DamageModifier.BonusDamageOverTime = default.INCREASEDDOSAGE_DOT_BONUS;
	DamageModifier.BuildPersistentEffect(1, true, false, true);
	DamageModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageModifier);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate QuickStim()
{
    local X2AbilityTemplate					Template;
	local X2Effect_QuickStim			    QuickStimEffect;
	local X2AbilityCooldown					Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_QuickStim');
	Template.IconImage = "img:///Pharmacist.Perk_Ph_QuickStims";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STASIS_LANCE_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Cooldown = new class'X2AbilityCooldown';
    Cooldown.iNumTurns = default.QUICKSTIM_COOLDOWN;
    Template.AbilityCooldown = Cooldown;

	Template.AbilityCosts.AddItem(default.FreeActionCost);
	
	QuickStimEffect = new class 'X2Effect_QuickStim';
	QuickStimEffect.BuildPersistentEffect (1, false, true, true, eGameRule_PlayerTurnEnd);
	QuickStimEffect.EffectName = 'QuickStimEffect';
	QuickStimEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
    QuickStimEffect.ValidAbilities = default.QUICKSTIM_APPLY_TO_ABILITIES;
	Template.AddTargetEffect(QuickStimEffect);

	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate ToxicCloud()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
    local X2Effect_PersistentStatChange     DisorientEffect;
    local X2Condition_UnitImmunities        VulnerableToPoisonCondition;
    local X2Condition_AbilityProperty       WeaponDamageCondition;
    local X2Condition_AbilityProperty       DisorientCondition;
    local X2AbilityCharges                  Charges;
    local X2AbilityCost_Charges             ChargeCost;
    local X2AbilityMultiTarget_Radius       MultiTargetRadius;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_ToxicCloud');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///Pharmacist.Perk_Ph_ToxicCloud";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.Hostility = eHostility_Offensive;

	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
    Template.DisplayTargetHitChance = true;
	Template.bShowActivation = false;
	Template.bSkipFireAction = false;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
    
    // One charge
    Charges = new class'X2AbilityCharges';
    Charges.InitialCharges = default.TOXICCLOUD_CHARGES;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

    // Cannot be used on enemies immune to Poison
    VulnerableToPoisonCondition = new class'X2Condition_UnitImmunities';
    VulnerableToPoisonCondition.ExcludeDamageTypes.AddItem('Poison');
	Template.AbilityTargetConditions.AddItem(VulnerableToPoisonCondition);
    
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
    
	Template.AddTargetEffect(class'X2StatusEffects'.static.CreatePoisonedStatusEffect());

    // Disorient effect which only applies if the user has Neurotoxin
    DisorientEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, 0.0f, false);
	DisorientCondition = new class'X2Condition_AbilityProperty';
	DisorientCondition.OwnerHasSoldierAbilities.AddItem('SG_Neurotoxin');
	DisorientEffect.TargetConditions.AddItem(DisorientCondition);
	Template.AddTargetEffect(DisorientEffect);
	Template.AddMultiTargetEffect(DisorientEffect);
    
    // Damage effect which only applies if the user has Pins and Needles
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bIgnoreBaseDamage = true;
	WeaponDamageEffect.DamageTag = 'VenomStim';
	WeaponDamageEffect.bBypassShields = true;
	WeaponDamageEffect.bIgnoreArmor = true;
	WeaponDamageCondition = new class'X2Condition_AbilityProperty';
	WeaponDamageCondition.OwnerHasSoldierAbilities.AddItem('SG_PinsAndNeedles');
	WeaponDamageEffect.TargetConditions.AddItem(WeaponDamageCondition);
	Template.AddTargetEffect(WeaponDamageEffect);
	Template.AddMultiTargetEffect(WeaponDamageEffect);

    // Mutli target
    MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
    MultiTargetRadius.bUseWeaponRadius = true;
    MultiTargetRadius.bIgnoreBlockingCover = true;
    //MultiTargetRadius.bAddPrimaryTargetAsMultiTarget = true;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;
	
    // Create the poison cloud
	Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreatePoisonedStatusEffect());
	Template.AddMultiTargetEffect(new class'X2Effect_ApplyPoisonToWorld');

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.AssociatedPassives.AddItem('SG_PinsAndNeedles');
	Template.AssociatedPassives.AddItem('SG_Neurotoxin');

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	return Template;
}

static function X2AbilityTemplate CombatClinic()
{
    local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2AbilityMultiTarget_AllAllies	    MultiTargetUnits;
    local X2AbilityCharges                      Charges;
    local X2AbilityCost_Charges                 ChargeCost;
	local X2Effect_ApplyRecoveryStimHeal		MedikitHeal;
    local X2Effect_RemoveEffectsByDamageType    RemoveEffects;
    local X2Effect_Regeneration                 RegenerationEffect;
    local X2Condition_AbilityProperty           RegenerationCondition;
	local X2Condition_Visibility			    TargetVisibilityCondition;
    local X2Condition_UnitProperty              UnitPropertyCondition;
	local name                                  HealType;
	local array<name>                           SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_CombatClinic');

	Template.IconImage = "img:///Pharmacist.Perk_Ph_CombatMedic";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Defensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
    
    // One charge
    Charges = new class'X2AbilityCharges';
    Charges.InitialCharges = default.COMBATCLINIC_CHARGES;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
    
    // Cannot miss
	Template.AbilityToHitCalc = default.DeadEye;

    // One action point cost, does not end turn
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

    // Targets all allies
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	MultiTargetUnits = new class'X2AbilityMultiTarget_AllAllies';
	MultiTargetUnits.bUseAbilitySourceAsPrimaryTarget = true;
	Template.AbilityMultiTargetStyle = MultiTargetUnits;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

    // Shooter must be alive
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    
    // Cannot be used while disoriented
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

    // Only organic allies who have been wounded
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeFullHealth = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	// Must be visible, does not work at squadsight ranges
	TargetVisibilityCondition = new class'X2Condition_Visibility';
    TargetVisibilityCondition.bRequireGameplayVisible = true;
    TargetVisibilityCondition.bAllowSquadsight = false;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Medikit Heal Effect
	MedikitHeal = new class'X2Effect_ApplyRecoveryStimHeal';
	MedikitHeal.PerUseHP = class'X2Ability_DefaultAbilitySet'.default.MEDIKIT_PERUSEHP;
	MedikitHeal.IncreasedHealProject = 'BattlefieldMedicine';
	MedikitHeal.IncreasedPerUseHP = class'X2Ability_DefaultAbilitySet'.default.NANOMEDIKIT_PERUSEHP;
	MedikitHeal.BonusHealAmount_CV = default.RECOVERYSTIM_BONUS_HEAL_CV;
	MedikitHeal.BonusHealAmount_MG = default.RECOVERYSTIM_BONUS_HEAL_MG;
	MedikitHeal.BonusHealAmount_BM = default.RECOVERYSTIM_BONUS_HEAL_BM;
	Template.AddTargetEffect(MedikitHeal);
	Template.AddMultiTargetEffect(MedikitHeal);

    // Remove effects that a Medikit removes
	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	foreach class'X2Ability_DefaultAbilitySet'.default.MedikitHealEffectTypes(HealType)
	{
		RemoveEffects.DamageTypesToRemove.AddItem(HealType);
	}
	Template.AddTargetEffect(RemoveEffects);
	Template.AddMultiTargetEffect(RemoveEffects);

    // Regeneration Effect if user has Lingering Effects
	RegenerationEffect = new class'X2Effect_Regeneration';
	RegenerationEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
	RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	RegenerationEffect.HealAmount = default.LINGERINGEFFECTS_HEAL_PER_TURN;
	RegenerationEffect.MaxHealAmount = default.LINGERINGEFFECTS_MAX_HEALTH;
	RegenerationEffect.HealthRegeneratedName = 'SG_LingeringEffects_Regeneration';
	RegenerationCondition = new class'X2Condition_AbilityProperty';
	RegenerationCondition.OwnerHasSoldierAbilities.AddItem('SG_LingeringEffects');
	RegenerationEffect.TargetConditions.AddItem(RegenerationCondition);
	Template.AddTargetEffect(RegenerationEffect);
	Template.AddMultiTargetEffect(RegenerationEffect);

    // Use Faceoff visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = CombatClinic_BuildVisualization;

	//Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	//Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	//Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

// Copy of Facoff_BuildVisualization
function CombatClinic_BuildVisualization(XComGameState VisualizeGameState)
{
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	local StateObjectReference          ShootingUnitRef;
	local X2Action_Fire                 FireAction;
	local X2Action_Fire_Faceoff         FireFaceoffAction;
	local XComGameState_BaseObject      TargetStateObject;//Container for state objects within VisualizeGameState	

	local Actor                     TargetVisualizer, ShooterVisualizer;
	local X2VisualizerInterface     TargetVisualizerInterface;
	local int                       EffectIndex, TargetIndex;

	local VisualizationActionMetadata        EmptyTrack;
	local VisualizationActionMetadata        ActionMetadata;
	local VisualizationActionMetadata        SourceTrack;
	local XComGameStateHistory      History;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;
	local name         ApplyResult;

	local X2Action_StartCinescriptCamera CinescriptStartAction;
	local X2Action_EndCinescriptCamera   CinescriptEndAction;
	local X2Camera_Cinescript            CinescriptCamera;
	local string                         PreviousCinescriptCameraType;
	local X2Effect                       TargetEffect;

	local X2Action_MarkerNamed				JoinActions;
	local array<X2Action>					LeafNodes;
	local XComGameStateVisualizationMgr		VisualizationMgr;
	local X2Action_ApplyWeaponDamageToUnit	ApplyWeaponDamageAction;


	History = `XCOMHISTORY;
	VisualizationMgr = `XCOMVISUALIZATIONMGR;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	ShootingUnitRef = Context.InputContext.SourceObject;

	ShooterVisualizer = History.GetVisualizer(ShootingUnitRef.ObjectID);

	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	if( SourceTrack.StateObject_NewState == none )
		SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;
	SourceTrack.VisualizeActor = ShooterVisualizer;

	if( AbilityTemplate.ActivationSpeech != '' )     //  allows us to change the template without modifying this function later
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(SourceTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.ActivationSpeech, eColor_Good);
	}


	// Add a Camera Action to the Shooter's Metadata.  Minor hack: To create a CinescriptCamera the AbilityTemplate 
	// must have a camera type.  So manually set one here, use it, then restore.
	PreviousCinescriptCameraType = AbilityTemplate.CinescriptCameraType;
	AbilityTemplate.CinescriptCameraType = "StandardGunFiring";
	CinescriptCamera = class'X2Camera_Cinescript'.static.CreateCinescriptCameraForAbility(Context);
	CinescriptStartAction = X2Action_StartCinescriptCamera(class'X2Action_StartCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
	CinescriptStartAction.CinescriptCamera = CinescriptCamera;
	AbilityTemplate.CinescriptCameraType = PreviousCinescriptCameraType;


	class'X2Action_ExitCover'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);

	//  Fire at the primary target first
	FireAction = X2Action_Fire(class'X2Action_Fire'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
	FireAction.SetFireParameters(Context.IsResultContextHit(), , false);
	//  Setup target response
	TargetVisualizer = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);
	TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);
	ActionMetadata = EmptyTrack;
	ActionMetadata.VisualizeActor = TargetVisualizer;
	TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
	if( TargetStateObject != none )
	{
		History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.PrimaryTarget.ObjectID,
														   ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState,
														   eReturnType_Reference,
														   VisualizeGameState.HistoryIndex);
		`assert(ActionMetadata.StateObject_NewState == TargetStateObject);
	}
	else
	{
		//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
		//and show no change.
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
		ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	}

	for( EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex )
	{
		ApplyResult = Context.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[EffectIndex]);

		// Target effect visualization
		AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, ApplyResult);

		// Source effect visualization
		AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
	}
	if( TargetVisualizerInterface != none )
	{
		//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
		TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
	}

	ApplyWeaponDamageAction = X2Action_ApplyWeaponDamageToUnit(VisualizationMgr.GetNodeOfType(VisualizationMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', TargetVisualizer));
	if ( ApplyWeaponDamageAction != None)
	{
		VisualizationMgr.DisconnectAction(ApplyWeaponDamageAction);
		VisualizationMgr.ConnectAction(ApplyWeaponDamageAction, VisualizationMgr.BuildVisTree, false, FireAction);
	}

	//  Now configure a fire action for each multi target
	for( TargetIndex = 0; TargetIndex < AbilityContext.MultiTargets.Length; ++TargetIndex )
	{
		// Add an action to pop the previous CinescriptCamera off the camera stack.
		CinescriptEndAction = X2Action_EndCinescriptCamera(class'X2Action_EndCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
		CinescriptEndAction.CinescriptCamera = CinescriptCamera;
		CinescriptEndAction.bForceEndImmediately = true;

		// Add an action to push a new CinescriptCamera onto the camera stack.
		AbilityTemplate.CinescriptCameraType = "StandardGunFiring";
		CinescriptCamera = class'X2Camera_Cinescript'.static.CreateCinescriptCameraForAbility(Context);
		CinescriptCamera.TargetObjectIdOverride = AbilityContext.MultiTargets[TargetIndex].ObjectID;
		CinescriptStartAction = X2Action_StartCinescriptCamera(class'X2Action_StartCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
		CinescriptStartAction.CinescriptCamera = CinescriptCamera;
		AbilityTemplate.CinescriptCameraType = PreviousCinescriptCameraType;

		// Add a custom Fire action to the shooter Metadata.
		TargetVisualizer = History.GetVisualizer(AbilityContext.MultiTargets[TargetIndex].ObjectID);
		FireFaceoffAction = X2Action_Fire_Faceoff(class'X2Action_Fire_Faceoff'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
		FireFaceoffAction.SetFireParameters(Context.IsResultContextMultiHit(TargetIndex), AbilityContext.MultiTargets[TargetIndex].ObjectID, false);
		FireFaceoffAction.vTargetLocation = TargetVisualizer.Location;


		//  Setup target response
		TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);
		ActionMetadata = EmptyTrack;
		ActionMetadata.VisualizeActor = TargetVisualizer;
		TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
		if( TargetStateObject != none )
		{
			History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID,
															   ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState,
															   eReturnType_Reference,
															   VisualizeGameState.HistoryIndex);
			`assert(ActionMetadata.StateObject_NewState == TargetStateObject);
		}
		else
		{
			//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
			//and show no change.
			ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
			ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
		}

		for( EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityMultiTargetEffects.Length; ++EffectIndex )
		{
			TargetEffect = AbilityTemplate.AbilityMultiTargetEffects[EffectIndex];
			ApplyResult = Context.FindMultiTargetEffectApplyResult(TargetEffect, TargetIndex);

			// Target effect visualization
			AbilityTemplate.AbilityMultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, ApplyResult);

			// Source effect visualization
			AbilityTemplate.AbilityMultiTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
		}
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}

		ApplyWeaponDamageAction = X2Action_ApplyWeaponDamageToUnit(VisualizationMgr.GetNodeOfType(VisualizationMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', TargetVisualizer));
		if( ApplyWeaponDamageAction != None )
		{
			VisualizationMgr.DisconnectAction(ApplyWeaponDamageAction);
			VisualizationMgr.ConnectAction(ApplyWeaponDamageAction, VisualizationMgr.BuildVisTree, false, FireFaceoffAction);
		}
	}
	class'X2Action_EnterCover'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);

	// Add an action to pop the last CinescriptCamera off the camera stack.
	CinescriptEndAction = X2Action_EndCinescriptCamera(class'X2Action_EndCinescriptCamera'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded));
	CinescriptEndAction.CinescriptCamera = CinescriptCamera;

	//Add a join so that all hit reactions and other actions will complete before the visualization sequence moves on. In the case
	// of fire but no enter cover then we need to make sure to wait for the fire since it isn't a leaf node
	VisualizationMgr.GetAllLeafNodes(VisualizationMgr.BuildVisTree, LeafNodes);

	if( VisualizationMgr.BuildVisTree.ChildActions.Length > 0 )
	{
		JoinActions = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(SourceTrack, Context, false, none, LeafNodes));
		JoinActions.SetName("Join");
	}
}

static function X2AbilityTemplate NitroStim()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
    local X2AbilityCharges_BonusStims           Charges;
    local X2AbilityCost_Charges                 ChargeCost;
	local X2Condition_Visibility			    TargetVisibilityCondition;
    local X2Condition_UnitProperty              UnitPropertyCondition;
	local array<name>                           SkipExclusions;
    local X2Effect_PersistentStatChange         StatEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_NitroStim');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///Pharmacist.Perk_Ph_NitroStim";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY + 30;
	Template.Hostility = eHostility_Defensive;

	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
    Template.DisplayTargetHitChance = false;
	Template.bShowActivation = false;
	Template.bSkipFireAction = false;
	Template.ConcealmentRule = eConceal_Always;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

    Charges = new class'X2AbilityCharges_BonusStims';
    Charges.InitialCharges = default.NITROSTIM_BASE_CHARGES;
    Charges.bCountMedikits = false;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
    
    // Only organic allies who have been wounded
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeRobotic = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	// Must be visible, does not work at squadsight ranges
	TargetVisibilityCondition = new class'X2Condition_Visibility';
    TargetVisibilityCondition.bRequireGameplayVisible = true;
    TargetVisibilityCondition.bAllowSquadsight = false;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Only at single targets that are in range, or self
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	// Stat bonus effect
	StatEffect = new class'X2Effect_PersistentStatChange';
	StatEffect.EffectName = 'SG_NitroStim_Bonuses';
	StatEffect.DuplicateResponse = eDupe_Refresh;
	StatEffect.BuildPersistentEffect(default.NITROSTIM_DURATION, false, true, false, eGameRule_PlayerTurnEnd);
	StatEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true);
	StatEffect.AddPersistentStatChange(eStat_Mobility, default.NITROSTIM_MOBILITY_BONUS);
	StatEffect.AddPersistentStatChange(eStat_CritChance, default.NITROSTIM_CRIT_BONUS);
	StatEffect.VisualizationFn = EffectFlyOver_Visualization;
	Template.AddTargetEffect(StatEffect);

	Template.ActivationSpeech = 'CombatStim';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
    
    // TODO see what this does
	Template.CustomSelfFireAnim = 'FF_FireMedkitSelf';

	return Template;
}

static function X2AbilityTemplate FocusStim()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
    local X2AbilityCharges_BonusStims           Charges;
    local X2AbilityCost_Charges                 ChargeCost;
	local X2Condition_Visibility			    TargetVisibilityCondition;
    local X2Condition_UnitProperty              UnitPropertyCondition;
	local array<name>                           SkipExclusions;
    local X2Effect_PersistentStatChange         StatEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SG_FocusStim');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///Pharmacist.Perk_Ph_FocusStim";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY + 31;
	Template.Hostility = eHostility_Defensive;

	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
    Template.DisplayTargetHitChance = false;
	Template.bShowActivation = false;
	Template.bSkipFireAction = false;
	Template.ConcealmentRule = eConceal_Always;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

    Charges = new class'X2AbilityCharges_BonusStims';
    Charges.InitialCharges = default.FOCUSSTIM_BASE_CHARGES;
    Charges.bCountMedikits = false;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
    
    // Only organic allies who have been wounded
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeRobotic = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	// Must be visible, does not work at squadsight ranges
	TargetVisibilityCondition = new class'X2Condition_Visibility';
    TargetVisibilityCondition.bRequireGameplayVisible = true;
    TargetVisibilityCondition.bAllowSquadsight = false;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Only at single targets that are in range, or self
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	// Stat bonus effect
	StatEffect = new class'X2Effect_PersistentStatChange';
	StatEffect.EffectName = 'SG_FocusStim_Bonuses';
	StatEffect.DuplicateResponse = eDupe_Refresh;
	StatEffect.BuildPersistentEffect(default.FOCUSSTIM_DURATION, false, true, false, eGameRule_PlayerTurnEnd);
	StatEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true);
	StatEffect.AddPersistentStatChange(eStat_Offense, default.FOCUSSTIM_AIM_BONUS);
	StatEffect.VisualizationFn = EffectFlyOver_Visualization;
	Template.AddTargetEffect(StatEffect);

	Template.ActivationSpeech = 'CombatStim';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
    
    // TODO see what this does
	Template.CustomSelfFireAnim = 'FF_FireMedkitSelf';

	return Template;
}


