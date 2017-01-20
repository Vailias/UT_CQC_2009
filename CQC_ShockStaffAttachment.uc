class CQC_ShockStaffAttachment extends CQC_WeaponAttachment;

defaultproperties
{

      ShieldTemplate=ParticleSystem'UTCQC_Weapons.FX.ShieldEffect'
      ShieldSocket="Shield"
//                      Class=SkeletalMeshComponent
         Begin Object Name=SkeletalMeshComponent0 ObjName=SkeletalMeshComponent0 Archetype=SkeletalMeshComponent'UTGame.Default__UTWeaponAttachment:SkeletalMeshComponent0'
     /* Begin Object Class=UTAnimNodeSequence Name=MeshSequenceA ObjName=MeshSequenceA Archetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
         ObjectArchetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
      End Object*/
      SkeletalMesh=SkeletalMesh'UTCQC_Weapons.Mesh.CQC_ShockStaff'
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
   WeaponClass=Class'UTCQC.CQC_Melee'
   FireAnim=none
   Name="Default__CQC_AttachmentMeleeDefault"
   ObjectArchetype=UTWeaponAttachment'UTGame.Default__UTWeaponAttachment'
}
