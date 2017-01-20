class CQC_WeaponAttachment extends UTWeaponAttachment;

var particleSystem ShieldTemplate;
var ParticleSystemComponent ShieldPSC;
var array<ParticleSystem> SpecialMoveFX;
var name ShieldSocket;

simulated function AttachTo(UTPawn OwnerPawn)
{
SetupFX();
Super.AttachTo(OwnerPawn);
 	if (MuzzleFlashSocket != '')
	{
		if (MuzzleFlashPSCTemplate != None || MuzzleFlashAltPSCTemplate != None)
		{
			MuzzleFlashPSC = new(self) class'UTParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetOwnerNoSee(false);
			Mesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}


}
Simulated function SetupFX()
{

 if (Mesh != none)
 {
  if(ShieldSocket != '')
  {
  ShieldPSC = new(self) class'UTParticleSystemComponent';
  ShieldPSC.bAutoActivate = false;
  if(ShieldTemplate != none)
  {
   ShieldPSC.SetTemplate(ShieldTemplate);
  }
  Mesh.AttachComponentToSocket(ShieldPSC, ShieldSocket);
  }
 }

}


/**
 * Spawn all of the effects that will be seen in behindview/remote clients.  This
 * function is called from the pawn, and should only be called when on a remote client or
 * if the local client is in a 3rd person mode.
*/
simulated function ThirdPersonFireEffects(vector HitLocation)
{
	/*local UTPawn P;
        	P = UTPawn(Instigator);
	if ( EffectIsRelevant(Location,false,MaxFireEffectDistance) )
	{
		// Light it up
		CauseMuzzleFlash();
	}
        */

	if (Instigator.FiringMode == 1 && ShieldPSC != none)
	{
		ShieldPSC.ActivateSystem();
	}
	Super.ThirdPersonFireEffects(HitLocation);
}
Simulated function StopThirdPersonFireEffects()
{
      Super.StopThirdPersonFireEffects();
      if (Instigator == None || IsZero(Instigator.FlashLocation))
      {
      ShieldPSC.DeactivateSystem();
      }
}

defaultproperties
{
      SpecialMoveFX(0)=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
      ShieldTemplate=ParticleSystem'UTCQC_Weapons.FX.ShieldEffect'
      ShieldSocket="Shield"

         Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponentCQCDefault ObjName=SkeletalMeshComponentCQCDefault Archetype=SkeletalMeshComponent'UTGame.Default__UTWeaponAttachment:SkeletalMeshComponent0'
      Begin Object Class=UTAnimNodeSequence Name=MeshSequenceA ObjName=MeshSequenceA Archetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
         ObjectArchetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
      End Object
      SkeletalMesh=SkeletalMesh'UTCQC_Weapons.Mesh.StaffPlaceholder'
      Animations=none
      //UTAnimNodeSequence'UTCQC.Default__CQC_AttachmentMeleeDefault:SkeletalMeshComponentCQCDefault.MeshSequenceA'
      AnimSets(0)=none
      //AnimSet'WP_FlakCannon.Anims.K_WP_FlakCannon_3P_Base'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTWeaponAttachment:SkeletalMeshComponent0'
   End Object
   Mesh=SkeletalMeshComponentCQCDefault
   MuzzleFlashSocket=""
   MuzzleFlashPSCTemplate=none
   MuzzleFlashAltPSCTemplate=none
   MuzzleFlashLightClass=none
   MuzzleFlashDuration=0.330000
   WeaponClass=Class'UTCQC.CQC_Melee'
   FireAnim=none
   Name="Default__CQC_AttachmentMeleeDefault"
   ObjectArchetype=UTWeaponAttachment'UTGame.Default__UTWeaponAttachment'
}
