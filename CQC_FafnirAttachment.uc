class CQC_FafnirAttachment extends CQC_WeaponAttachment;
var name idleSequence;

simulated function ThirdPersonFireEffects(vector HitLocation)
{
Play3pAnimation(idleSequence, 0.06, true);
}

simulated function Play3pAnimation(name Sequence, float fDesiredDuration, optional bool bLoop)
{
	// Check we have access to mesh and animations
	if (Mesh != None && Mesh.Animations != None)
	{
		// @todo - this should call GetWeaponAnimNodeSeq, move 'duration' code into AnimNodeSequence and use that.
		Mesh.PlayAnim(Sequence, fDesiredDuration, bLoop);
	}
}


defaultproperties
{
      idleSequence="Idle"
      SpecialMoveFX(0)=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
      ShieldTemplate=ParticleSystem'UTCQC_Weapons.FX.ShieldEffect'
      ShieldSocket="Shield"
                                    
  Begin Object Name=SkeletalMeshComponent0 ObjName=SkeletalMeshComponent0 Archetype=SkeletalMeshComponent'UTGame.Default__UTWeaponAttachment:SkeletalMeshComponent0'
      Begin Object Class=UTAnimNodeSequence Name=MeshSequenceFaf ObjName=MeshSequenceFaf Archetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
         ObjectArchetype=UTAnimNodeSequence'UTGame.Default__UTWeaponAttachment:MeshSequenceA'
      End Object
      SkeletalMesh=SkeletalMesh'UTCQC_Weapons.Mesh.CQC_Fafnir'
      Animations=UTAnimNodeSequence'UTCQC.Default__CQC_FafnirAttachment:SkeletalMeshComponent0.MeshSequenceFaf'
      AnimSets(0)=AnimSet'UTCQC_Weapons.Anims.CQC_Fafnir_SwordAnims'
      //AnimSet'WP_FlakCannon.Anims.K_WP_FlakCannon_3P_Base'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTWeaponAttachment:SkeletalMeshComponent0'
   End Object

   Mesh=SkeletalMeshComponent0
   MuzzleFlashSocket=""
   MuzzleFlashPSCTemplate=none
   MuzzleFlashAltPSCTemplate=none
   MuzzleFlashLightClass=none
   MuzzleFlashDuration=0.330000
   WeaponClass=Class'UTCQC.CQC_Fafnir'
   FireAnim=none
   Name="Default__CQC_AttachmentMeleeDefault"
   ObjectArchetype=UTWeaponAttachment'UTGame.Default__UTWeaponAttachment'
}
