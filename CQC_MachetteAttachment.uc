class CQC_MachetteAttachment extends CQC_WeaponAttachment;

var SkeletalMeshComponent DualMesh;
var SkeletalMeshComponent DualOverlayMesh;

 simulated function AttachTo(UTPawn OwnerPawn)
 {
  	local UTPawn P;
	local vector LeftScale;

	P = UTPawn(Instigator);
	if (P != None)
	{

			if (DualMesh == None && Mesh != None)
			{
				DualMesh = new(self) Mesh.Class(Mesh);

				// reverse the mesh, like we do in 1st person
				LeftScale = DualMesh.Scale3D;
				LeftScale.X *= -1;
				DualMesh.SetScale3D(LeftScale);
			}
         }
         if (DualMesh != None)
			{
				P.Mesh.AttachComponentToSocket(DualMesh, P.WeaponSocket2);

				// Weapon Mesh Shadow
				DualMesh.SetShadowParent(P.Mesh);
				DualMesh.SetLightEnvironment(P.LightEnvironment);

				if (P.ReplicatedBodyMaterial != None)
				{
					SetSkin(P.ReplicatedBodyMaterial);
				}
				/*if ( MuzzleFlashSocket != 'None' &&
					(MuzzleFlashPSCTemplate != None || MuzzleFlashAltPSCTemplate != None) )
				{
					DualMuzzleFlashPSC = new(self) class'UTParticleSystemComponent';
					DualMuzzleFlashPSC.bAutoActivate = false;
					DualMuzzleFlashPSC.SetOwnerNoSee(true);
					DualMesh.AttachComponentToSocket(DualMuzzleFlashPSC, MuzzleFlashSocket);
				}
                                */
				if (OverlayMesh != None && DualOverlayMesh == None)
				{
					DualOverlayMesh = new(self) OverlayMesh.Class(OverlayMesh);
					DualOverlayMesh.SetParentAnimComponent(DualMesh);
					DualOverlayMesh.SetScale3D(DualMesh.Scale3D);
				}
				if (DualOverlayMesh != None && OverlayMesh.bAttached)
				{
					P.Mesh.AttachComponentToSocket(DualOverlayMesh, P.WeaponSocket2);
				}
			}

 super.AttachTo(OwnerPawn);
 }


defaultproperties
{
      SpecialMoveFX(0)=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
      ShieldTemplate=ParticleSystem'UTCQC_Weapons.FX.ShieldEffect'
      ShieldSocket="Shield"
                          //Class=SkeletalMeshComponent
         Begin Object Name=SkeletalMeshComponent0 ObjName=SkeletalMeshComponent0 Archetype=SkeletalMeshComponent'UTGame.Default__UTWeaponAttachment:SkeletalMeshComponent0'
     /* Begin Object Class=UTAnimNodeSequence Name=MeshSequenceA ObjName=MeshSequenceA Archetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
         ObjectArchetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
      End Object*/
      SkeletalMesh=SkeletalMesh'UTCQC_Weapons.Mesh.CQC_Machette'
      Animations=none
      //UTAnimNodeSequence'UTCQC.Default__CQC_AttachmentMeleeDefault:SkeletalMeshComponentCQCDefault.MeshSequenceA'
      AnimSets(0)=none
      //AnimSet'WP_FlakCannon.Anims.K_WP_FlakCannon_3P_Base'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTWeaponAttachment:SkeletalMeshComponent0'
   End Object

   Mesh=SkeletalMeshComponent0
   MuzzleFlashSocket=""
   MuzzleFlashPSCTemplate=none
   MuzzleFlashAltPSCTemplate=none
   MuzzleFlashLightClass=none
   MuzzleFlashDuration=0.330000
   WeaponClass=Class'UTCQC.CQC_Machette'
   FireAnim=none
   Name="Default__CQC_AttachmentMeleeDefault"
   ObjectArchetype=UTWeaponAttachment'UTGame.Default__UTWeaponAttachment'
}
