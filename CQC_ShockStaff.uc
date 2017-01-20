Class CQC_ShockStaff extends CQC_Melee;

var array<vector> SpecialMoveForceVector;

Simulated function doSpecial(int specialNum)
{
local Pawn HitPawn;
local actor HitActor;
  local vector HitLocation, HitNormal, StartTrace, EndTrace;
  local particleSystemComponent PSC;
  //local UTVehicle UTV;


  PlayPlayerAnim(UTPawn(Instigator), false, SpecialMoveSequence[currentSpecial], SpecialMoveDuration[currentSpecial], false);
  UTPlayerController(Instigator.Controller).PlayCameraAnim(SpecialMoveCamAnim[SpecialNum]);
  addAmmo(-SpecialMoveAmmo[SpecialNum]);

          if (Role == ROLE_Authority)
          {
             if (specialNum == 0)//first special. Single hit high force.
             {
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
             //End first special

             if (SpecialNum == 1) // Second special, Radial Burst
             {
               PSC = WorldInfo.MyEmitterPool.SpawnEmitter(SpecialMoveFX[specialNum], Instigator.Location, Instigator.Rotation, none);
              foreach OverlappingActors(class 'Pawn', HitPawn, WeaponRange*3, Instigator.Location)
             {
             HitNormal = Normal(HitPawn.Location - Instigator.Location);
             doSpecialHit(HitNormal, HitPawn, SpecialNum);
             }
             }//End second special
          }
}

simulated function doSpecialHit(vector HitDirection, Pawn HitPawn, int SpecialNum)
{

local Pawn BoardPawn;
local UTVehicle UTV;
local vector newVelocity;
//HitNormal = normal(HitDirection - HitPawn.Location);
           newVelocity = SpecialMoveMomentum[SpecialNum]*(Normal(HitDirection+SpecialMoveForceVector[SpecialNum]));
          if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
	  {

            HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection, SpecialMoveDamageTypes[SpecialNum], , Instigator );
             UTPawn(HitPawn).AddVelocity(newVelocity*0.75,HitDirection,SpecialMoveDamageTypes[SpecialNum]);
            UTPawn(HitPawn).ForceRagdoll();
            HitPawn.LastHitBy = Instigator.Controller;
          }

          else if( UTVehicle_Hoverboard(HitPawn) != none)
	  {
	  BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
	  UTVehicle_Hoverboard(HitPawn).RagdollDriver();
	  HitPawn = BoardPawn;
	  HitPawn.LastHitBy = Instigator.Controller;
          HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection, SpecialMoveDamageTypes[SpecialNum], , Instigator );
          HitPawn.LastHitBy = Instigator.Controller;
          }

          else if ( HitPawn.Physics == PHYS_RigidBody )
	  {
	  UTV = UTVehicle(HitPawn);
          UTV.TakeDamage(SpecialMoveDamage[SpecialNum]*VehDamageMult, Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection*VehDamageMult*100, SpecialMoveDamageTypes[SpecialNum], , Instigator );
          newVelocity = SpecialMoveMomentum[SpecialNum]*(1/UTV.MomentumMult)*(Normal(HitDirection+SpecialMoveForceVector[SpecialNum]));

          if (UTV.isA('UTVehicle_Goliath') || UTV.isA('UTVehicle_SPMA') )
          {
          newVelocity *= 200;//want to launch the heavier things but not utterly anihilating the little ones.
          }
          else
          {
          newVelocity *= 1;
          }
          UTV.AddVelocity(newVelocity,HitDirection,SpecialMoveDamageTypes[SpecialNum]);
          }
}
defaultproperties
{

   Faction="AXON"

   AttackAnims=AnimSet'UTCQC_Weapons.Anims.CQC_FafnirAnims'
   AttackSequenceF(0)="FafnirSlash"
   AttackSequenceB(0)="FafnirAttack"
   AttackSequenceSide(0)="FafnirSlash"
   ReflectSequence="FafnirSlash"
   BlockSequence="Idle_Ready_Pis"//looping
   IdleSequence="CC_Human_Male_Idle"

   SpecialMoveSequence(0)="FafnirAttack"
   SpecialMoveSequence(1)="FafnirSlash"
   SpecialMoveCamAnim(0)=none//CameraAnim'UTCQC_Weapons.CamAnims.CA_FafnirSpecial1'
   SpecialMoveCamAnim(1)=CameraAnim'UTCQC_Weapons.CamAnims.CA_ShockStaff2'
   SpecialMoveSound(0)=soundCue'UTCQC_Weapons.Sounds.Shock_Staff_mediumCue'
   SpecialMoveSound(1)=soundCue'UTCQC_Weapons.Sounds.Shock_Staff_shockwaveCue'
   SpecialMoveDamage(0)=20
   SpecialMoveDamage(1)=20
   SpecialMoveDamageTypes(0)=Class'UTCQC.CQCDmgType_ShockStaffSpecial'
   SpecialMoveDamageTypes(1)=Class'UTCQC.CQCDmgType_ShockStaffSpecial'
   SpecialMoveMomentum(0)=2500.0
   SpecialMoveMomentum(1)=2000.0
   SpecialMoveAmmo(0)=10
   SpecialMoveAmmo(1)=30
   SpecialMoveDuration(0)=1.0
   SpecialMoveDuration(1)=1.0
   SpecialMoves(0)="FFFF"
   SpecialMoves(1)="LRLR"
   SpecialMoveForceVector(0) = (x=0.0,y=0.0,z=0.25)
   SpecialMoveForceVector(1) = (x=0.0,y=0.0,z=10.0)//high vertical component
   SpecialMoveFX(0)=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
   SpecialMoveFX(1)=ParticleSystem'UTCQC_Weapons.FX.Shockwave'


   ItemName="Axon ShockStaff"
   Name="Axon ShockStaff"
   bCanThrow=False
   bInstantHit=True
   bMeleeWeapon=True
   WeaponRange=150.000000
   VehDamageMult = 1.5

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
   AttachmentClass=Class'UTCQC.CQC_ShockStaffAttachment'
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
   NeedToPickUpAnnouncement=(AnnouncementText="Get the Shock Staff!")

   WeaponEquipSnd=none
   WeaponIdleSnd=soundCue'UTCQC_Weapons.Sounds.Shock_Staff_IdleCue'
   WeaponFireSnd(0)=None
   WeaponFireSnd(1)=none
   WeaponFireSnd(2)=None

   InstantHitDamage(0)=10.000000 //simply using these to store damage ratings
   InstantHitDamage(1)=20.000000
   InstantHitDamage(2)=0.000

   InstantHitMomentum(0)=100.000000
   InstantHitMomentum(1)=100.000000
   InstantHitMomentum(2)=0.000000


   InstantHitDamageTypes(0)=Class'UTCQC.CQCDmgType_ShockStaff'
   InstantHitDamageTypes(1)=Class'UTCQC.CQCDmgType_ShockStaff'
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