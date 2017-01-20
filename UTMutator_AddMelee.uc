// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
class UTMutator_AddMelee extends UTMutator;

function InitMutator(string Options, out string ErrorMessage) //grabbed from instagib
{
	if ( UTGame(WorldInfo.Game) != None )
	{
		//UTGame(WorldInfo.Game).DefaultInventory.Length = 0;                   //just adding all of them currently
		UTGame(WorldInfo.Game).DefaultInventory.AddItem(class'UTCQC.CQC_ShockStaff');
                UTGame(WorldInfo.Game).DefaultInventory.AddItem(class'UTCQC.CQC_Fafnir');
                UTGame(WorldInfo.Game).DefaultInventory.AddItem(class'UTCQC.CQC_Machette');

	}

	Super.InitMutator(Options, ErrorMessage);
}



defaultproperties
{
   GroupNames(0)="WEAPONMOD"
/*   Begin Object Class=SpriteComponent Name=Sprite ObjName=Sprite Archetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
      ObjectArchetype=SpriteComponent'UTGame.Default__UTMutator:Sprite'
   End Object */
   Components(0)=Sprite
   Name="Default__UTMutator_AddMelee"
   ObjectArchetype=UTMutator'UTGame.Default__UTMutator'
}
