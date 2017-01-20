class CQC_Machette extends CQC_Melee;

var bool bIsSpeedy;//if were already fast

simulated function AdjustPawn(UTPawn P, bool bRemoveBonus)//grabbed from the Berzerk powerup
{
	if (P != None && Role == ROLE_Authority)
	{
		if (bRemoveBonus)
		{
			P.FireRateMultiplier *= 2.0;
			P.GroundSpeed *= 0.625;
			P.JumpZ *= 0.625;
			bIsSpeedy = false;
		}
		else
		{
			// halve firing time
			P.FireRateMultiplier *= 0.5;
			P.GroundSpeed *= 1.6;
			P.JumpZ *= 1.6;
			bIsSpeedy = true;
		}
		P.FireRateChanged();
	}
}

simulated function BonusDone()
{
AdjustPawn (UTPawn(Instigator), true);
}
Simulated function doSpecial(int specialNum)
{
local Pawn HitPawn;
Local UTPawn UTP;
local actor HitActor;
local vector HitLocation, HitNormal, StartTrace, EndTrace;

          if (Role == ROLE_Authority)
          {
            if (specialNum == 0 && !bIsSpeedy)//speed bonus. Faster movement and attack
              {
              UTP = UTPawn(Instigator);
              AdjustPawn(UTP, False);
              SetTimer(15.0, false, 'BonusDone');

              PlayPlayerAnim(UTPawn(Instigator), false, SpecialMoveSequence[currentSpecial], SpecialMoveDuration[currentSpecial], false);
              UTPlayerController(Instigator.Controller).PlayCameraAnim(SpecialMoveCamAnim[SpecialNum]);
              addAmmo(-SpecialMoveAmmo[SpecialNum]);

              } //End first special

             if (specialNum == 1)//first special. Single hit enemy.
             {
             PlayPlayerAnim(UTPawn(Instigator), false, SpecialMoveSequence[currentSpecial], SpecialMoveDuration[currentSpecial], false);
             UTPlayerController(Instigator.Controller).PlayCameraAnim(SpecialMoveCamAnim[SpecialNum]);
             addAmmo(-SpecialMoveAmmo[SpecialNum]);

             StartTrace	= Instigator.GetWeaponStartTraceLocation();
	     EndTrace	= StartTrace + Vector(GetAdjustedAim( StartTrace )) * WeaponRange;
	     HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true,,,TRACEFLAG_Blocking);
             HitPawn = Pawn(HitActor);
	     if ( (HitActor != None) && !HitActor.bWorldGeometry )
	     {

             if  (HitActor.IsA('Pawn') && !WorldInfo.GRI.OnSameTeam(HitPawn, self))
             {
             doSpecialHit(Normal(EndTrace-StartTrace), HitPawn, SpecialNum);
             }
             }
             }
            }

}
simulated function doSpecialHit(vector HitDirection, Pawn HitPawn, int SpecialNum)
{

local Pawn BoardPawn;
local UTVehicle UTV;
//local vector HitNormal;
//HitNormal = normal(HitDirection - HitPawn.Location);
          if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
	  {

            HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection, SpecialMoveDamageTypes[SpecialNum], , Instigator );

          }

          else if( UTVehicle_Hoverboard(HitPawn) != none)
	  {
	  BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
	  UTVehicle_Hoverboard(HitPawn).RagdollDriver();
	  HitPawn = BoardPawn;
	  HitPawn.LastHitBy = Instigator.Controller;
          HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection, SpecialMoveDamageTypes[SpecialNum], , Instigator );

          }

          else if ( HitPawn.Physics == PHYS_RigidBody )
	  {
	  UTV = UTVehicle(HitPawn);
          UTV.TakeDamage(SpecialMoveDamage[SpecialNum]*VehDamageMult, Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection*VehDamageMult*100, SpecialMoveDamageTypes[SpecialNum], , Instigator );

         }
}
defaultproperties
{

   Faction="AXON"

   AttackAnims=AnimSet'UTCQC_Weapons.Anims.CQC_MachetteAnims'
   AttackSequenceF(0)="MachetteSlash"
   AttackSequenceB(0)="MachetteSlash"
   AttackSequenceSide(0)="MachetteSlash"
   ReflectSequence="MachetteSlash"
   BlockSequence="Idle_Ready_Sti"//looping
   IdleSequence="Idle_Ready_DPi"

   SpecialMoveSequence(0)="MachetteSlash"
   SpecialMoveSequence(1)="MachetteSlash"
   SpecialMoveCamAnim(0)=CameraAnim'UTCQC_Weapons.CamAnims.CA_MachetteSpecial'
   SpecialMoveCamAnim(1)=none//CameraAnim'UTCQC_Weapons.CamAnims.CA_FafnirSpecial1'
   SpecialMoveSound(0)=none
   SpecialMoveSound(1)=none
   SpecialMoveDamage(0)=0
   SpecialMoveDamage(1)=45
   SpecialMoveDamageTypes(0)=none
   SpecialMoveDamageTypes(1)=Class'UTCQC.CQCDmgType_Machette'
   SpecialMoveMomentum(0)=500.0
   SpecialMoveMomentum(1)=0.0
   SpecialMoveAmmo(0)=20
   SpecialMoveAmmo(1)=40
   SpecialMoveDuration(0)=1.0
   SpecialMoveDuration(1)=1.0
   SpecialMoves(0)="FFFF"
   SpecialMoves(1)="LRLR"


   ItemName="Axon VibroShock"
   Name="Axon Vibroshock Machettes"
   bCanThrow=False
   bInstantHit=True
   bMeleeWeapon=True
   WeaponRange=100.000000
   VehDamageMult = 0.3

   fReflectWindow = 0.25
   ammoRecharge = 5.0





     //change all this
   bExportMenuData=True
   bLeadTarget=False
   bConsiderProjectileAcceleration=False
   AmmoCount=100
   LockerAmmoCount = 100 //even though this should never BE in a locker...
   MaxAmmoCount=100
   EffectSockets(0)=none
   EffectSockets(1)=none


   IconCoordinates=(U=453.000000,V=327.000000,UL=135.000000,VL=57.000000)
   CrossHairCoordinates=(U=64.000000,V=0.000000)
   InventoryGroup=1
   AmmoDisplayType=EAWDS_Numeric //damn bargraph is broken.
   AttachmentClass=Class'UTCQC.CQC_MachetteAttachment'
   CrosshairColor=(B=255,G=128,R=128,A=200)
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
   NeedToPickUpAnnouncement=(AnnouncementText="Get the Machettes!")

   WeaponEquipSnd=soundCue'UTCQC_Weapons.Sounds.Sword_DrawCue'
   WeaponFireSnd(0)=None
   WeaponFireSnd(1)=None
   WeaponFireSnd(2)=None

      FireInterval(0)=0.3
   FireInterval(1)=0.1    //keep on blocking
   FireInterval(2)=0.3

   InstantHitDamage(0)=15.000000 //simply using these to store damage ratings
   InstantHitDamage(1)=15.000000
   InstantHitDamage(2)=0.000

   InstantHitMomentum(0)=100.000000
   InstantHitMomentum(1)=100.000000
   InstantHitMomentum(2)=0.000000


   InstantHitDamageTypes(0)=Class'UTCQC.CQCDmgType_Machette'
   InstantHitDamageTypes(1)=Class'UTCQC.CQCDmgType_Machette'
   EquipTime=0.450000

   /*Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonMesh ObjName=FirstPersonMesh Archetype=UTSkeletalMeshComponent'UTGame.Default__UTWeapon:FirstPersonMesh'
    FOV=75.000000
      SkeletalMesh=SkeletalMesh'WP_ImpactHammer.Mesh.SK_WP_Impact_1P'
      Begin Object Class=AnimNodeSequence Name=MeshSequenceA ObjName=MeshSequenceA Archetype=AnimNodeSequence'Engine.Default__AnimNodeSequence'
         Name="MeshSequenceA"
         ObjectArchetype=AnimNodeSequence'Engine.Default__AnimNodeSequence'
      End Object
      Animations=AnimNodeSequence'UTGame.Default__UTWeap_ImpactHammer:MeshSequenceA'
      AnimSets(0)=AnimSet'WP_ImpactHammer.Anims.K_WP_Impact_1P_Base'
      Materials(0)=Material'WP_ImpactHammer.Materials.M_WP_ImpactHammer_Base'
      ObjectArchetype=UTSkeletalMeshComponent'UTGame.Default__UTWeapon:FirstPersonMesh'
   End Object*/
   Mesh=FirstPersonMesh
   DefaultAnimSpeed=0.900000
   MaxDesireability=0.500000
   DroppedPickupClass=Class'UTGame.UTDroppedPickup'
 /* Begin Object Class=SkeletalMeshComponent Name=PickupMesh ObjName=PickupMesh Archetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
   End Object*/
   DroppedPickupMesh=PickupMesh
   PickupFactoryMesh=PickupMesh
   MessageClass=Class'UTGame.UTPickupMessage'
   ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'
}