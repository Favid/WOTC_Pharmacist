//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTC_Pharmacist.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTC_Pharmacist extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	UpdateStorage();
}

static function UpdateStorage()
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local array<X2ItemTemplate> ItemTemplates;
	local XComGameState_Item NewItemState;
	local int i;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Pharmacist: Updating HQ Storage to add Stim Gun");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('StimGun_CV'));

	for (i = 0; i < ItemTemplates.Length; ++i)
	{
		if(ItemTemplates[i] != none)
		{
			if (!XComHQ.HasItem(ItemTemplates[i]))
			{
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " not found, adding to inventory",, 'WOTC_Pharmacist');
				NewItemState = ItemTemplates[i].CreateInstanceFromTemplate(NewGameState);
				NewGameState.AddStateObject(NewItemState);
				XComHQ.AddItemToHQInventory(NewItemState);
				History.AddGameStateToHistory(NewGameState);
			} else {
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " found, skipping inventory add",, 'WOTC_Pharmacist');
				History.CleanupPendingGameState(NewGameState);
			}
		}
	}

	//schematics should be handled already, as the BuildItem UI draws from ItemTemplates, which are automatically loaded
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static event OnPostTemplatesCreated()
{

}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name Type;

	Type = name(InString);
	switch(Type)
	{
		case 'RECOVERYSTIM_BONUS_HEAL_CV':
			OutString = string(class'X2Ability_StimGuns'.default.RECOVERYSTIM_BONUS_HEAL_CV);
			return true;
		case 'RECOVERYSTIM_BONUS_HEAL_MG':
			OutString = string(class'X2Ability_StimGuns'.default.RECOVERYSTIM_BONUS_HEAL_MG);
			return true;
		case 'RECOVERYSTIM_BONUS_HEAL_BM':
			OutString = string(class'X2Ability_StimGuns'.default.RECOVERYSTIM_BONUS_HEAL_BM);
			return true;
		case 'RECOVERYSTIM_BASE_CHARGES':
			OutString = string(class'X2Ability_StimGuns'.default.RECOVERYSTIM_BASE_CHARGES);
			return true;
		case 'VENOMSTIM_BASE_CHARGES':
			OutString = string(class'X2Ability_StimGuns'.default.VENOMSTIM_BASE_CHARGES);
			return true;
		case 'LINGERINGEFFECTS_HEAL_PER_TURN':
			OutString = string(class'X2Ability_StimGuns'.default.LINGERINGEFFECTS_HEAL_PER_TURN);
			return true;
		case 'LINGERINGEFFECTS_MAX_HEALTH':
			OutString = string(class'X2Ability_StimGuns'.default.LINGERINGEFFECTS_MAX_HEALTH);
			return true;
		case 'OVERTHECOUNTER_BONUS_RECOVERY_STIMS':
			OutString = string(class'X2Ability_StimGuns'.default.OVERTHECOUNTER_BONUS_RECOVERY_STIMS);
			return true;
		case 'UNDERTHECOUNTER_BONUS_VENOM_STIMS':
			OutString = string(class'X2Ability_StimGuns'.default.UNDERTHECOUNTER_BONUS_VENOM_STIMS);
			return true;
		case 'QUICKSTIM_COOLDOWN':
			OutString = string(class'X2Ability_StimGuns'.default.QUICKSTIM_COOLDOWN);
			return true;
		case 'INCREASEDDOSAGE_DOT_BONUS':
			OutString = string(class'X2Ability_StimGuns'.default.INCREASEDDOSAGE_DOT_BONUS);
			return true;
		case 'NITROSTIM_MOBILITY_BONUS':
			OutString = string(class'X2Ability_StimGuns'.default.NITROSTIM_MOBILITY_BONUS);
			return true;
		case 'NITROSTIM_CRIT_BONUS':
			OutString = string(class'X2Ability_StimGuns'.default.NITROSTIM_CRIT_BONUS);
			return true;
		case 'NITROSTIM_DURATION':
			OutString = string(class'X2Ability_StimGuns'.default.NITROSTIM_DURATION);
			return true;
		case 'NITROSTIM_BASE_CHARGES':
			OutString = string(class'X2Ability_StimGuns'.default.NITROSTIM_BASE_CHARGES);
			return true;
		case 'FOCUSSTIM_BASE_CHARGES':
			OutString = string(class'X2Ability_StimGuns'.default.FOCUSSTIM_BASE_CHARGES);
			return true;
		case 'FOCUSSTIM_DURATION':
			OutString = string(class'X2Ability_StimGuns'.default.FOCUSSTIM_DURATION);
			return true;
		case 'FOCUSSTIM_AIM_BONUS':
			OutString = string(class'X2Ability_StimGuns'.default.FOCUSSTIM_AIM_BONUS);
			return true;
		case 'SAVIOR_BONUS_HEAL_AMMOUNT':
			OutString = string(class'X2Effect_LW2WotC_Savior'.default.SAVIOR_BONUS_HEAL_AMMOUNT);
			return true;
		default: 
			return false;
	}
}