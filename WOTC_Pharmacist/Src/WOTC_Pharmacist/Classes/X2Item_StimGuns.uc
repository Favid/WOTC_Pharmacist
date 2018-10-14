class X2Item_StimGuns extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue STIMGUN_CONVENTIONAL_BASEDAMAGE;
var config array <WeaponDamageValue> STIMGUN_CONVENTIONAL_ABILITY_DAMAGE;
var config int STIMGUN_CONVENTIONAL_AIM;
var config int STIMGUN_CONVENTIONAL_RADIUS;
var config int STIMGUN_CONVENTIONAL_CRITCHANCE;
var config int STIMGUN_CONVENTIONAL_ICLIPSIZE;
var config int STIMGUN_CONVENTIONAL_ISOUNDRANGE;
var config int STIMGUN_CONVENTIONAL_IENVIRONMENTDAMAGE;

var config WeaponDamageValue STIMGUN_MAGNETIC_BASEDAMAGE;
var config array <WeaponDamageValue> STIMGUN_MAGNETIC_ABILITY_DAMAGE;
var config int STIMGUN_MAGNETIC_AIM;
var config int STIMGUN_MAGNETIC_RADIUS;
var config int STIMGUN_MAGNETIC_CRITCHANCE;
var config int STIMGUN_MAGNETIC_ICLIPSIZE;
var config int STIMGUN_MAGNETIC_ISOUNDRANGE;
var config int STIMGUN_MAGNETIC_IENVIRONMENTDAMAGE;

var config WeaponDamageValue STIMGUN_BEAM_BASEDAMAGE;
var config array <WeaponDamageValue> STIMGUN_BEAM_ABILITY_DAMAGE;
var config int STIMGUN_BEAM_AIM;
var config int STIMGUN_BEAM_RADIUS;
var config int STIMGUN_BEAM_CRITCHANCE;
var config int STIMGUN_BEAM_ICLIPSIZE;
var config int STIMGUN_BEAM_ISOUNDRANGE;
var config int STIMGUN_BEAM_IENVIRONMENTDAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTemplate_StimGun_Conventional());
	Templates.AddItem(CreateTemplate_StimGun_Magnetic());
	Templates.AddItem(CreateTemplate_StimGun_Beam());

	return Templates;
}

static function X2DataTemplate CreateTemplate_StimGun_Conventional()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'StimGun_CV');
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'stimgun';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.ConvSecondaryWeapons.ConvPistol";
	Template.EquipSound = "Secondary_Weapon_Equip_Conventional";
	Template.Tier = 0;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.FLAT_CONVENTIONAL_RANGE;
	Template.BaseDamage = default.STIMGUN_CONVENTIONAL_BASEDAMAGE;
	Template.Aim = default.STIMGUN_CONVENTIONAL_AIM;
	Template.iRadius = default.STIMGUN_CONVENTIONAL_RADIUS;
	Template.CritChance = default.STIMGUN_CONVENTIONAL_CRITCHANCE;
	Template.iClipSize = default.STIMGUN_CONVENTIONAL_ICLIPSIZE;
	Template.iSoundRange = default.STIMGUN_CONVENTIONAL_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.STIMGUN_CONVENTIONAL_IENVIRONMENTDAMAGE;

	Template.NumUpgradeSlots = 1;

	Template.InfiniteAmmo = true;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	
	Template.ExtraDamage = default.STIMGUN_CONVENTIONAL_ABILITY_DAMAGE;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Pistol_CV.WP_Pistol_CV";

	Template.iPhysicsImpulse = 1;

	Template.DamageTypeTemplateName = 'Projectile_Conventional';

	Template.bHideClipSizeStat = true;
	
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}

static function X2DataTemplate CreateTemplate_StimGun_Magnetic()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'StimGun_MG');
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'stimgun';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.MagSecondaryWeapons.MagPistol";
	Template.EquipSound = "Secondary_Weapon_Equip_Magnetic";
	Template.Tier = 2;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.FLAT_MAGNETIC_RANGE;
	Template.BaseDamage = default.STIMGUN_MAGNETIC_BASEDAMAGE;
	Template.Aim = default.STIMGUN_MAGNETIC_AIM;
	Template.iRadius = default.STIMGUN_MAGNETIC_RADIUS;
	Template.CritChance = default.STIMGUN_MAGNETIC_CRITCHANCE;
	Template.iClipSize = default.STIMGUN_MAGNETIC_ICLIPSIZE;
	Template.iSoundRange = default.STIMGUN_MAGNETIC_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.STIMGUN_MAGNETIC_IENVIRONMENTDAMAGE;

	Template.NumUpgradeSlots = 1;

	Template.InfiniteAmmo = true;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	
	Template.ExtraDamage = default.STIMGUN_MAGNETIC_ABILITY_DAMAGE;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Pistol_MG.WP_Pistol_MG";

	Template.iPhysicsImpulse = 1;

	Template.DamageTypeTemplateName = 'Projectile_MagXCom';

	Template.bHideClipSizeStat = true;
	
	Template.CreatorTemplateName = 'StimGun_MG_Schematic'; // The schematic which creates this item TODO
	Template.BaseItem = 'StimGun_CV'; // Which item this will be upgraded from
    
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}

static function X2DataTemplate CreateTemplate_StimGun_Beam()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'StimGun_BM');
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'stimgun';
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///UILibrary_Common.BeamSecondaryWeapons.BeamPistol";
	Template.EquipSound = "Secondary_Weapon_Equip_Beam";
	Template.Tier = 4;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.FLAT_BEAM_RANGE;
	Template.BaseDamage = default.STIMGUN_BEAM_BASEDAMAGE;
	Template.Aim = default.STIMGUN_BEAM_AIM;
	Template.iRadius = default.STIMGUN_BEAM_RADIUS;
	Template.CritChance = default.STIMGUN_BEAM_CRITCHANCE;
	Template.iClipSize = default.STIMGUN_BEAM_ICLIPSIZE;
	Template.iSoundRange = default.STIMGUN_BEAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.STIMGUN_BEAM_IENVIRONMENTDAMAGE;

	Template.NumUpgradeSlots = 1;

	Template.InfiniteAmmo = true;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	
	Template.ExtraDamage = default.STIMGUN_BEAM_ABILITY_DAMAGE;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Pistol_BM.WP_Pistol_BM";

	Template.iPhysicsImpulse = 1;

	Template.DamageTypeTemplateName = 'Projectile_BeamXCom';

	Template.bHideClipSizeStat = true;
	
	Template.CreatorTemplateName = 'StimGun_BM_Schematic'; // The schematic which creates this item TODO
	Template.BaseItem = 'StimGun_MG'; // Which item this will be upgraded from
    
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}