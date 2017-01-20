/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class CQCDmgType_Shockstaff extends UTDamageType
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
   GibPerterbation=0.500000
   DamageWeaponClass=Class'UTCQC.CQC_ShockStaff'
   DamageWeaponFireMode=0
   DeathCameraEffectInstigator=Class'UTGame.UTEmitCameraEffect_BloodSplatter'
   DamageCameraAnim=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Primary_Fire_GetHit_Shake'
   KillStatsName="KILLS_ShockStaff"
   DeathStatsName="DEATHS_ShockStaff"
   SuicideStatsName="SUICIDES_ShockStaff"

   CustomTauntIndex=4
   DeathString="`o was was bashed `k."
   FemaleSuicide="`o can't handle her big stick."
   MaleSuicide="`o can't handle his big stick."
   bAlwaysGibs=False
   bThrowRagdoll=True
   KDamageImpulse=500.000000
   PhysicsTakeHitMomentumThreshold=2.000000
   VehicleDamageScaling=1.500000
   VehicleMomentumScaling=1.000
   Name="Default__CQCDmgType_ShockStaff"
   ObjectArchetype=UTDamageType'UTGame.Default__UTDamageType'
}