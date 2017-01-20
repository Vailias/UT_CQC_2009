class CQC_TESTER extends UTWeapon
HideDropDown
;


/** Path to animations for weapon strikes **/
var AnimSet AttackAnims;

/** name of attack sequence for weapon strike
!note! 
To be replaced with proper anim tree sequenceing for blends based on player direction of travel
or by array. TBD
**/
var Name AttackSequence;

/*
function GivenTo(Pawn ThisPawn, optional bool bDoNotActivate)
{
        local UTPawn UTP;
        UTP = UTPawn(ThisPawn);
        UTP.Mesh.AnimSets[3]=AttackAnims; //slot7 should almost always be empty
        //bDoNotActivate = true;
        //Super.GivenTo(ThisPawn, bDoNotActivate);

}
*/
simulated function bool HasAnyAmmo()
{
	return true;
}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	return true;
}

       /*
       <todo>
       normal firemodes always return true.
       Special moves should take ammo to pull off
       Special moves will have a designated fire mode
       */



simulated function Set3p(bool TP)
{
                local UTPlayerController PC;
                PC = UTPlayerController(Instigator.Controller);
                if(PC.bBehindView != TP)     //IF WE'RE not in the right view perspective, change to the new one.
                {
                PC.ClientSetBehindView(TP);
		}


}

 simulated state Active
{


        simulated function BeginState(name PreviousStateName)
	{
                //Set3p(true);
                Super.BeginState(PreviousStateName);
        }

        /*
        simulated function Tick(float DeltaTime) //catch for getting up from a forced ragdoll. Simple check to keep player in 3rd person view while using this weapon.
        {
          Set3p(true);
          Super.Tick(DeltaTime);
        }
         */

        simulated function EndState(name NextStateName)
	{

         Super.EndState(NextStateName);
        }

}
/*

simulated state WeaponPuttingDown
{
	simulated function BeginState( Name PreviousStateName )
	{

		if (bDebugWeapon)
		{
			LogInternal("---"@self$"."$GetStateName()$".BeginState("$PreviousStateName$")");
		}


                 Set3p(False);



		TimeWeaponPutDown();
		bWeaponPutDown = false;
	}

	simulated function EndState(Name NextStateName)
	{

		Super.EndState(NextStateName);

	}

	simulated function Activate();

	simulated function bool bReadyToFire()
	{
		return false;
	}
}
*/
defaultproperties
{

   AttackAnims=AnimSet'UTCQC_Weapons.Anims.CQC_animtest'
   AttackSequence="TestSwing"
   ItemName="UTCQC TESTORZ"
   Name="UTCQC TESTORZ"
   bCanThrow=False
   bInstantHit=True
   bMeleeWeapon=True
   WeaponRange=150.000000
   
   ammoRecharge = 10.0;


     //change all this
   bExportMenuData=True
   bLeadTarget=False
   bConsiderProjectileAcceleration=False
   MaxAmmoCount=100
   ShotCost(0)=0
   ShotCost(1)=30
   EffectSockets(0)=none
   EffectSockets(1)=none


   IconCoordinates=(U=453.000000,V=327.000000,UL=135.000000,VL=57.000000)
   CrossHairCoordinates=(U=64.000000,V=0.000000)
   InventoryGroup=1
   AmmoDisplayType=EAWDS_BarGraph
   AttachmentClass=Class'UTGame.UTAttachment_ImpactHammer'
   CrosshairColor=(B=255,G=255,R=255,A=255)
   CrosshairScaling=1.000000

//first person stuff
   WeaponFireAnim(0)=none
   WeaponFireAnim(1)=none
   ArmFireAnim(0)=none
   ArmFireAnim(1)=none
   WeaponPutDownAnim=none
   ArmsPutDownAnim=none
   WeaponEquipAnim=none
   ArmsEquipAnim=none
   WeaponIdleAnims(0)=none
   ArmIdleAnims(0)=none
 //End firstperson




   NeedToPickUpAnnouncement=(AnnouncementText="Get your melee weapon!")
   PrimaryFireHintString="triggers the primary fire of this weapon."
   SecondaryFireHintString="triggers the alternate fire of this weapon."
   
   ShouldFireOnRelease(0)=0
   ShouldFireOnRelease(1)=0


   WeaponFireSnd(0)=None
   WeaponFireSnd(1)=None


   WeaponFireTypes(0)=EWFT_InstantHit
   WeaponFireTypes(1)=EWFT_InstantHit


   FiringStatesArray(0)="WeaponFiring"  //light attack
   FiringStatesArray(1)="WeaponFiring"  //Heavy attack


   FireInterval(0)=0.5
   FireInterval(1)=0.5

   InstantHitDamage(0)=10.000000
   InstantHitDamage(1)=20.000000

   InstantHitMomentum(0)=200.000000
   InstantHitMomentum(1)=1500.000000

   InstantHitDamageTypes(0)=Class'UTCQC.CQCDmgType_Default'
   InstantHitDamageTypes(1)=Class'UTCQC.CQCDmgType_Default'
   EquipTime=0.450000


   DefaultAnimSpeed=0.900000
   MaxDesireability=0.500000

   ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'

}