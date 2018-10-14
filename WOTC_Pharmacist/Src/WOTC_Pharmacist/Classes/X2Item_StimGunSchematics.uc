class X2Item_StimGunSchematics extends X2Item config(Schematics_StimGun);

var config int STIMGUN_MG_SUPPLY_COST;
var config int STIMGUN_MG_ALLOY_COST;
var config int STIMGUN_MG_ELERIUM_COST;

var config int STIMGUN_BM_SUPPLY_COST;
var config int STIMGUN_BM_ALLOY_COST;
var config int STIMGUN_BM_ELERIUM_COST;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Schematics;

    // TODO Need to think what upgraded stim guns can bring to the table
    // More recovery/venom stim charges?
    // Improved healing?
    // More poison DoT?
	
	// Weapon Schematics
	Schematics.AddItem(CreateTemplate_StimGun_Magnetic_Schematic());
	Schematics.AddItem(CreateTemplate_StimGun_Beam_Schematic());

	return Schematics;
}

static function X2DataTemplate CreateTemplate_StimGun_Magnetic_Schematic()
{
	local X2SchematicTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SchematicTemplate', Template, 'StimGun_MG_Schematic');

	Template.ItemCat = 'weapon';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Mag_Pistol";
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.OnBuiltFn = class'X2Item_DefaultSchematics'.static.UpgradeItems;

	// Reference Item
	Template.ReferenceItemTemplate = 'StimGun_MG';
	Template.HideIfPurchased = 'StimGun_BM';

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('MagnetizedWeapons');
	Template.Requirements.RequiredEngineeringScore = 10;
	Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	// Cost
    if(default.STIMGUN_MG_SUPPLY_COST > 0)
    {
        Resources.ItemTemplateName = 'Supplies';
        Resources.Quantity = default.STIMGUN_MG_SUPPLY_COST;
	    Template.Cost.ResourceCosts.AddItem(Resources);
    }
    
    if(default.STIMGUN_MG_ALLOY_COST > 0)
    {
        Resources.ItemTemplateName = 'AlienAlloy';
	    Resources.Quantity = default.STIMGUN_MG_ALLOY_COST;
	    Template.Cost.ResourceCosts.AddItem(Resources);
    }
    
    if(default.STIMGUN_MG_ELERIUM_COST > 0)
    {
        Resources.ItemTemplateName = 'EleriumDust';
        Resources.Quantity = default.STIMGUN_MG_ELERIUM_COST;
	    Template.Cost.ResourceCosts.AddItem(Resources);
    }

	return Template;
}

static function X2DataTemplate CreateTemplate_StimGun_Beam_Schematic()
{
	local X2SchematicTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SchematicTemplate', Template, 'StimGun_BM_Schematic');

	Template.ItemCat = 'weapon';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Beam_Pistol";
	Template.PointsToComplete = 0;
	Template.Tier = 3;
	Template.OnBuiltFn = class'X2Item_DefaultSchematics'.static.UpgradeItems;
    
	// Reference Item
	Template.ReferenceItemTemplate = 'StimGun_BM';

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('PlasmaRifle');
	Template.Requirements.RequiredEngineeringScore = 20;
	Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	// Cost
    if(default.STIMGUN_BM_SUPPLY_COST > 0)
    {
        Resources.ItemTemplateName = 'Supplies';
        Resources.Quantity = default.STIMGUN_BM_SUPPLY_COST;
	    Template.Cost.ResourceCosts.AddItem(Resources);
    }
    
    if(default.STIMGUN_BM_ALLOY_COST > 0)
    {
        Resources.ItemTemplateName = 'AlienAlloy';
	    Resources.Quantity = default.STIMGUN_BM_ALLOY_COST;
	    Template.Cost.ResourceCosts.AddItem(Resources);
    }
    
    if(default.STIMGUN_BM_ELERIUM_COST > 0)
    {
        Resources.ItemTemplateName = 'EleriumDust';
        Resources.Quantity = default.STIMGUN_BM_ELERIUM_COST;
	    Template.Cost.ResourceCosts.AddItem(Resources);
    }

	return Template;
}