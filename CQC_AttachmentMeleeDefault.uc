class CQC_AttachmentMeleeDefault extends UTWeaponAttachment
                                   //abstract
                                   ;
                                   
defaultproperties
{
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
   MuzzleFlashSocket="HitEffector"
   MuzzleFlashPSCTemplate=ParticleSystem'WP_FlakCannon.Effects.P_WP_FlakCannon_3P_Muzzle_Flash'
   MuzzleFlashAltPSCTemplate=ParticleSystem'WP_FlakCannon.Effects.P_WP_FlakCannon_3P_Muzzle_Flash'
   MuzzleFlashLightClass=Class'UTGame.UTRocketMuzzleFlashLight'
   MuzzleFlashDuration=0.330000
   WeaponClass=Class'UTCQC.CQC_Melee'
   FireAnim=none
   Name="Default__CQC_AttachmentMeleeDefault"
   ObjectArchetype=UTWeaponAttachment'UTGame.Default__UTWeaponAttachment'
}
