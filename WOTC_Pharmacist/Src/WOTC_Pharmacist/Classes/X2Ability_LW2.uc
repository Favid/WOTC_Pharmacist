class X2Ability_LW2 extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Savior());
	
	return Templates;
}

// Copied from LW2
static function X2AbilityTemplate Savior()
{
	local X2Effect_LW2WotC_Savior				SaviorEffect;

	// This effect will add a listener to the soldier that listens for them to apply a heal.
	SaviorEffect = new class 'X2Effect_LW2WotC_Savior';

	// Create the template using a helper function
	return Passive('SG_Savior', "img:///Pharmacist.LW_AbilitySavior", false, SaviorEffect);
}