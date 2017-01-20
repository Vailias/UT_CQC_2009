class CQC_Fafnir extends CQC_Melee;

var CameraAnim ImpactKillCameraAnim;

simulated state Active
{
 simulated function BeginState(Name PreviousStateName)
 {
 UTPawn(Instigator).CurrentWeaponAttachment.ThirdPersonFireEffects(Instigator.Location);
 Super.BeginState(PreviousStateName);
 }

}

Simulated function doSpecial(int specialNum)
{
local Pawn HitPawn, BoardPawn;
local actor HitActor;
  local vector HitLocation, HitNormal, StartTrace, EndTrace, headLocation;
local ImpactInfo firstImpact;
//local array<ImpactInfo> ImpactList;
local class<UTDamageType> UTDT;
Local UTPlayerController PC;
local UTVehicle UTV;
local class<UTEmitCameraEffect> CameraEffect;

  PlayPlayerAnim(UTPawn(Instigator), false, SpecialMoveSequence[currentSpecial], SpecialMoveDuration[currentSpecial], false);
  UTPlayerController(Instigator.Controller).PlayCameraAnim(SpecialMoveCamAnim[SpecialNum]);
  addAmmo(-SpecialMoveAmmo[SpecialNum]);

          if (Role == ROLE_Authority)
          {
             if (specialNum == 0)//first special. Single hit enemy, should kill.
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

             if (SpecialNum == 1) // Second special, Radial HeadShot
             {
              foreach OverlappingActors(class 'Pawn', HitPawn, WeaponRange, Instigator.Location)
             {
             HitNormal = Normal(HitPawn.Location - Instigator.Location);

              if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
	     {
               StartTrace	= Instigator.GetWeaponStartTraceLocation();
             HeadLocation = UTPawn(HitPawn).Mesh.GetBoneLocation(UTPawn(HitPawn).HeadBone) + vect(0,0,1) * UTPawn(HitPawn).HeadHeight;//Calculate so headshot = true
             firstImpact = CalcWeaponFire(StartTrace, HeadLocation);

             if (UTPawn(HitPawn).TakeHeadShot(firstImpact, SpecialMoveDamageTypes[SpecialNum], SpecialMoveDamage[SpecialNum], 1.74, Instigator.Controller))
                 {
                 }
             else
                 {
                 HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitNormal, SpecialMoveDamageTypes[SpecialNum], , Instigator );
                 }
             }

              else if( UTVehicle_Hoverboard(HitPawn) != none)
	      {
	      BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
	      UTVehicle_Hoverboard(HitPawn).RagdollDriver();
	      HitPawn = BoardPawn;
	      HitPawn.LastHitBy = Instigator.Controller;
              HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitNormal, SpecialMoveDamageTypes[SpecialNum], , Instigator );
              HitPawn.LastHitBy = Instigator.Controller;
              }

              else if ( HitPawn.Physics == PHYS_RigidBody )
	      {
	      UTV = UTVehicle(HitPawn);
              UTV.TakeDamage(SpecialMoveDamage[SpecialNum]*VehDamageMult, Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitNormal*VehDamageMult, SpecialMoveDamageTypes[SpecialNum], , Instigator );
              }
             }
             }//End second special
             PC = UTPlayerController(Instigator.Controller);
          if (Hitpawn != none)
          {
          if (HitPawn.Health <= 0 && PC != None )
					{
						if ( !class'GameInfo'.static.UseLowGore(WorldInfo) )
						{
							UTDT = SpecialMoveDamageTypes[SpecialNum];
							if (UTDT != None)
							{
								CameraEffect = UTDT.static.GetDeathCameraEffectInstigator(UTPawn(HitPawn));
								if (CameraEffect != None)
								{
									UTPlayerController(Instigator.Controller).ClientSpawnCameraEffect(CameraEffect);
								}
							}
						}
						PC.ClientPlayCameraAnim(ImpactKillCameraAnim);
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

   AttackAnims=AnimSet'UTCQC_Weapons.Anims.Anim_GreatSword'
   AttackSequenceF(0)="F_Swing_1"
   AttackSequenceB(0)="F_Swing_1"
   AttackSequenceSide(0)="F_Swing_1"
   ReflectSequence="Reflect"
   BlockSequence="bLock"//looping
   IdleSequence="GS_Idle"

   SpecialMoveSequence(0)="F_Swing_Full"
   SpecialMoveSequence(1)="BigSlash"
   SpecialMoveCamAnim(0)=none//CameraAnim'UTCQC_Weapons.CamAnims.CA_FafnirSpecial1'
   SpecialMoveCamAnim(1)=none//CameraAnim'UTCQC_Weapons.CamAnims.CA_FafnirSpecial2'
   SpecialMoveSound(0)=none
   SpecialMoveSound(1)=none
   SpecialMoveDamage(0)=120
   SpecialMoveDamage(1)=200
   SpecialMoveDamageTypes(0)=Class'UTCQC.CQCDmgType_FafnirSpecial'
   SpecialMoveDamageTypes(1)=Class'UTCQC.CQCDmgType_FafnirSpecial2'
   SpecialMoveMomentum(0)=500.0
   SpecialMoveMomentum(1)=500.0
   SpecialMoveAmmo(0)=20
   SpecialMoveAmmo(1)=40
   SpecialMoveDuration(0)=1.0
   SpecialMoveDuration(1)=1.0
   SpecialMoves(0)="FFFF"
   SpecialMoves(1)="LLRR"


   ItemName="Axon ChainSword 'Fafnir'"
   Name="Axon ChainSword 'Fafnir'"
   bCanThrow=False
   bInstantHit=True
   bMeleeWeapon=True
   WeaponRange=200.000000
   VehDamageMult = 1.5

   fReflectWindow = 0.25
   ammoRecharge = 5.0

   HitTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
   ReflectTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'

   ImpactKillCameraAnim=CameraAnim'Camera_FX.Gameplay.C_Impact_CharacterGib_Near'

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
   AttachmentClass=Class'UTCQC.CQC_FafnirAttachment'
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
   NeedToPickUpAnnouncement=(AnnouncementText="Get the FAFNIR ChainSword!")

   WeaponEquipSnd=soundCue'UTCQC_Weapons.Sounds.Chainsword_startupCue'
   WeaponIdleSnd=soundCue'UTCQC_Weapons.Sounds.chainsword_idle_newCue'
   WeaponFireSnd(0)=None
   WeaponFireSnd(1)=None
   WeaponFireSnd(2)=None

      FireInterval(0)=0.75
   FireInterval(1)=0.1    //keep on blocking
   FireInterval(2)=0.75

   InstantHitDamage(0)=20.000000 //simply using these to store damage ratings
   InstantHitDamage(1)=20.000000
   InstantHitDamage(2)=0.000

   InstantHitMomentum(0)=100.000000
   InstantHitMomentum(1)=100.000000
   InstantHitMomentum(2)=0.000000


   InstantHitDamageTypes(0)=Class'UTCQC.CQCDmgType_Fafnir'
   InstantHitDamageTypes(1)=Class'UTCQC.CQCDmgType_Fafnir'
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