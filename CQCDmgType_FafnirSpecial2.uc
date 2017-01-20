/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class CQCDmgType_FafnirSpecial2 extends UTDamageType
	abstract;




/** Return the DeathCameraEffect that will be played on the instigator that was caused by this damagetype and the Pawn type (e.g. robot) */
simulated static function class<UTEmitCameraEffect> GetDeathCameraEffectInstigator( UTPawn UTP )
{
		// robots need to splatter oil instead of blood
		if( (UTP != none) && (UTP.GetFamilyInfo() != None) )
		{
			return UTP.GetFamilyInfo().default.DeathCameraEffect;
		}
		else
		{
			return default.DeathCameraEffectInstigator;
		}
}

defaultproperties
{
   bSeversHead=True
  GibPerterbation=0.500000
   DamageWeaponClass=Class'UTCQC.CQC_Fafnir'
   DamageWeaponFireMode=0
   DeathCameraEffectInstigator=Class'UTGame.UTEmitCameraEffect_BloodSplatter'
   DamageCameraAnim=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Primary_Fire_GetHit_Shake'//CHANGE ME!!
   KillStatsName="KILLS_Fafnir"
   DeathStatsName="DEATHS_Fafnir"
   SuicideStatsName="SUICIDES_Fafnir"

   DeathAnim="Death_Headshot"

   CustomTauntIndex=6
   DeathString="`o lost their head to `k."
   FemaleSuicide="`o pointed her sword the wrong way."
   MaleSuicide="`o pointed her sword the wrong way."
   bNeverGibs=true

   bThrowRagdoll=True
   KDamageImpulse=500.000000
   PhysicsTakeHitMomentumThreshold=2.000000
   VehicleDamageScaling=1.500000
   VehicleMomentumScaling=1.000//vehicular launch initiated
   Name="Default__CQCDmgType_Fafnir"
   ObjectArchetype=UTDamageType'UTGame.Default__UTDamageType'
}