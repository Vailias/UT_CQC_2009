/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class CQCDmgType_TestHammer extends UTDamageType
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
   DamageWeaponClass=Class'UTGame.UTWeap_ImpactHammer'
   DamageWeaponFireMode=1
   DeathCameraEffectInstigator=Class'UTGame.UTEmitCameraEffect_BloodSplatter'
   DamageCameraAnim=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Primary_Fire_GetHit_Shake'
   KillStatsName="KILLS_IMPACTHAMMER"
   DeathStatsName="DEATHS_IMPACTHAMMER"
   SuicideStatsName="SUICIDES_IMPACTHAMMER"
   RewardCount=15
   RewardAnnouncementSwitch=5
   RewardEvent="REWARD_JACKHAMMER"
   CustomTauntIndex=5
   DeathString="`o was hammered by `k."
   FemaleSuicide="`o pounded herself."
   MaleSuicide="`o pounded himself."
   bAlwaysGibs=False
   bThrowRagdoll=True
   KDamageImpulse=20000.000000
   PhysicsTakeHitMomentumThreshold=2.000000
   VehicleDamageScaling=0.200000
   Name="Default__UTDmgType_ImpactHammer"
   ObjectArchetype=UTDamageType'UTGame.Default__UTDamageType'
}