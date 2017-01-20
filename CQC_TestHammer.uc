/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class  CQC_TestHammer extends UTWeap_ImpactHammer
	HideDropDown
	;

var AnimSet WeaponAnims;
var name AttackAnim;

simulated function SetSkin(Material NewMaterial)
{
	super.SetSkin(NewMaterial);
}

function GivenTo(Pawn ThisPawn, optional bool bDoNotActivate)
{
        local UTPawn UTP;
        UTP = UTPawn(ThisPawn);
	UTP.Mesh.AnimSets[3]=AnimSet'UTCQC_Weapons.Anims.CQC_animtest';
        Super.GivenTo(ThisPawn, bDoNotActivate);

}

simulated function rotator GetAdjustedAim(vector StartFireLoc)
{

	return Super.GetAdjustedAim(StartFireLoc);
}

function float GetAIRating()
{
         return Super.GetAIRating();
}

function byte BestMode()
{
         return Super.BestMode();
}

/**
  * Always keep charging impact hammer
  */
function bool CanAttack(Actor Other)
{
	return true;
}

function float SuggestAttackStyle()
{
	return 1.0;
}

reliable client function ClientAutoFire()
{
	if (Role < ROLE_Authority)
	{
		PlayFireEffects(0, Location);
		ImpactFire();
	}
}

simulated function ImpactFire()
{
	local UTPawn UTP;
        
        FireAmmunition();
	//StopMuzzleFlash();
	MuzzleFlashAltPSCTemplate = default.MuzzleFlashAltPSCTemplate;
	MuzzleFlashPSCTemplate = default.MuzzleFlashPSCTemplate;
	bMuzzleFlashPSCLoops = false;
	CauseMuzzleFlash();
	

        UTP = UTPawn(Instigator);
        UTP.TopHalfAnimSlot.PlayCustomAnim('TestSwing',1.0,0,0,false,false);

	GotoState('WeaponRecharge');
}

simulated function bool HasAnyAmmo()
{
	return true;
}

/**  figure out how close P is to aiming at the center of Target
	@return the cosine of the angle of P's aim
*/
function float CalcAim(Pawn P, Pawn Target)
{
	local float Aim, EffectiveSkill;
	local UTBot B;

	Aim = vector(P.GetViewRotation()) dot Normal(Target.Location - P.Location);
	B = UTBot(P.Controller);
	if (B != None)
	{
		EffectiveSkill = B.Skill + B.Accuracy;
		if (B.FavoriteWeapon == Class)
		{
			EffectiveSkill += 3.0;
		}
		// if the bot just happens to be looking away from the target, use the real angle, otherwise make one up based on the bot's skill
		Aim = FMin(Aim, FMin(1.0, 1.0 - 0.30 + (0.02 * EffectiveSkill) + (0.10 * FRand())));
	}

	return Aim;
}

simulated function InstantFire()
{
	super.InstantFire();
	SetFlashLocation(Location);
}

simulated function PlayImpactEffect(byte FiringMode, ImpactInfo Impact)
{
	local float Damage1,Damage2,Damage3;
	local Pawn HitPawn;

	if (FiringMode == 1 && Impact.HitActor != None)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(AltHitEffect, Impact.HitLocation, rotator(Impact.HitLocation - Instigator.Location));
	}
	else if( FiringMode == 0 )
	{
		HitPawn = UTPawn(Impact.HitActor);
		if ( HitPawn == None )
		{
			HitPawn = UTVehicle_Hoverboard(Impact.HitActor);
			if ( (HitPawn != None) && (HitPawn.PlayerReplicationInfo == None) )
			{
				HitPawn = None;
			}
		}
		if ( (HitPawn != None) && !WorldInfo.GRI.OnSameTeam(HitPawn, Instigator) && !class'GameInfo'.static.UseLowGore(WorldInfo) )
		{
			BloodMIC.GetScalarParameterValue('Damage1',Damage1);
			BloodMIC.GetScalarParameterValue('Damage2',Damage2);
			BloodMIC.GetScalarParameterValue('Damage3',Damage3);
			Damage1 = Damage1+frand()*2.0;
			Damage2 = Damage2+frand()*1.0;
			Damage3 = Damage3+frand()*0.75;
			BloodMIC.SetScalarParameterValue('Damage1',Damage1);
			BloodMIC.SetScalarParameterValue('Damage2',Damage2);
			BloodMIC.SetScalarParameterValue('Damage3',Damage3);
			SetCurrentFireMode(3); // replicate a hit out to weapon attachments
		}
	}
}

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact )
{
	local float Damage, SelfDamage, Force, Scale, Aim, EnemyAim;
	local UTInventoryManager UTInvManager;
	local UTPawn P;
	local UTVehicle_Hoverboard H;
	local class<UTEmitCameraEffect> CameraEffect;
	local class<UTDamageType> UTDT;
	local UTPlayerController PC;

	if (WorldInfo.NetMode != NM_DedicatedServer && Impact.HitActor != None)
	{
		PlayImpactEffect(FiringMode, Impact);
	}

	if (Role == Role_Authority )
	{
		// If we auto-hit something, guarantee the strike
		if ( AutoHitActor != none )
		{
			Impact.HitActor = AutoHitActor;
			AutoHitActor = none;
		}

		if ( Impact.HitActor != None && Instigator != None && Instigator.Health > 0 )
		{
			// if we hit something on the server, then deal damage to it.
		    Scale = (FClamp(WorldInfo.TimeSeconds - ChargeTime, MinChargeTime, MaxChargeTime) - MinChargeTime) / (MaxChargeTime - MinChargeTime); // result 0 to 1

			P = UTPawn(Impact.HitActor);
			if ( P == None )
			{
				H = UTVehicle_Hoverboard(Impact.HitActor);
				if ( H != None )
				{
					P = UTPawn(H.Driver);
					if ( P == None )
					{
						return;
					}
				}
			}

			if ( FiringMode == 0 )
			{
				Damage = MinDamage + Scale * (MaxDamage - MinDamage);
				Force = MinForce + Scale * (MaxForce - MinForce);
				if (P != None && P != Instigator)
				{
					if ( VSize(Impact.HitLocation - Instigator.GetWeaponStartTraceLocation()) > AutoFireRange )
					{
						// no damage if out of close range
						Damage = 0;
					}
					// if the other pawn is also trying to hammer us, allow the player with the better aim to win
					if (P.Weapon != None && P.Weapon.Class == Class && P.Weapon.IsFiring() && P.Weapon.CurrentFireMode == CurrentFireMode)
					{
						EnemyAim = CalcAim(P, Instigator);
						Aim = CalcAim(Instigator, P);
						if (EnemyAim > Aim)
						{
							// cause the enemy hammer to release and damage our pawn
							P.Weapon.StopFire(CurrentFireMode);
							// if our pawn died, bail
							if (Instigator == None || Instigator.Health <= 0)
							{
								return;
							}
						}
					}
					P.TakeDamage(Damage, Instigator.Controller, Impact.HitLocation, Force * Impact.RayDir, InstantHitDamageTypes[0], Impact.HitInfo, self);
                                          P.AddVelocity((Force/P.Mass) * Impact.Raydir, Impact.HitLocation, InstantHitDamageTypes[1]);
                                         P.ForceRagdoll();


					PC = UTPlayerController(Instigator.Controller);
					if (P.Health <= 0 && PC != None )
					{
						if ( !class'GameInfo'.static.UseLowGore(WorldInfo) )
						{
							UTDT = class<UTDamageType>(InstantHitDamageTypes[0]);
							if (UTDT != None)
							{
								CameraEffect = UTDT.static.GetDeathCameraEffectInstigator(P);
								if (CameraEffect != None)
								{
									UTPlayerController(Instigator.Controller).ClientSpawnCameraEffect(CameraEffect);
								}
							}
						}
						PC.ClientPlayCameraAnim(ImpactKillCameraAnim);
					}

				}
				else
				{
					SelfDamage = MinSelfDamage + (SelfDamageScale * Damage);
					Impact.HitActor.TakeDamage(0, Instigator.Controller, Impact.HitLocation, Force * Impact.RayDir, InstantHitDamageTypes[0], Impact.HitInfo, self);
					Instigator.TakeDamage(SelfDamage, Instigator.Controller, Location, SelfForceScale * Force * Impact.RayDir, InstantHitDamageTypes[0], Impact.HitInfo, self);
					WeaponPlaySound(ImpactJumpSound);



				}
			}
			else
			{
				// EMP pulse
				if ( P != None )
				{
					if ( !WorldInfo.GRI.OnSameTeam(P, Instigator) )
					{
						UTInvManager = UTInventoryManager(UTPawn(Impact.HitActor).InvManager);
						if(UTInvManager != none)
						{
							if (UTInvManager.DisruptInventory())
							{
								Force = MinForce + Scale * (MaxForce - MinForce);
								Impact.HitActor.TakeDamage(0,Instigator.Controller,Impact.HitLocation, Force*Impact.RayDir, InstantHitDamageTypes[1], Impact.HitInfo, self);
							}
						}
					}
                                        P.AddVelocity((Force/P.Mass) * Impact.Raydir, Impact.HitLocation, InstantHitDamageTypes[1]);
                                         P.ForceRagdoll();
				}
				else if ( Vehicle(Impact.HitActor) != None )
				{
					Impact.HitActor.TakeDamage(Scale * EMPDamage, Instigator.Controller, Impact.HitActor.location, -(Impact.HitActor.velocity * 0.2), InstantHitDamageTypes[1], Impact.HitInfo, self);
				}
			}
			PowerLevel = 0;
		}
	}
}

// always have hammer and always have EMPPulse.
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	return true;
}

simulated event float GetPowerPerc()
{
	return 0;
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	Super.AttachWeaponTo(MeshCpnt, SocketName);

	// so replication is guaranteed to happen when we start charging and set it to 0 or 1
	SetCurrentFireMode(2);
}

simulated function Set3p(bool TP)
{
                local UTPlayerController PC;
                PC = UTPlayerController(Instigator.Controller);
                if(PC.bBehindView != TP)     //IF WE'RE not in the right view perspective, change to the new one.
                {
                PC.ClientSetBehindView(TP);
		}


}


simulated state Active
{


        simulated function BeginState(name PreviousStateName)
	{
                Set3p(true);
                Super.BeginState(PreviousStateName);
        }


        simulated function Tick(float DeltaTime) //catch for getting up from a forced ragdoll. Simple check to keep player in 3rd person view while using this weapon.
        {
          Set3p(true);
        }


        simulated function EndState(name NextStateName)
	{

               	Super.EndState(NextStateName);
        }
}

event ImpactAutoFire()
{
	Super.ImpactAutoFire();
}



simulated state WeaponRecharge
{
	simulated function bool TryPutdown()
	{


                bWeaponPutDown = true;
		return true;
	}

	simulated function BeginState(Name PreviousStateName)
	{
               Set3p(True);

		Super.BeginState(PreviousStateName);
	}

	simulated function EndState(name NextStateName)
	{

                Super.EndState(NextStateName);
	}

	/** need to make sure fire mode is set to a unique value so we can be sure it gets replicated again when we start charging again */
	simulated function ResetFireMode()
	{
		if (CurrentFireMode != 3 && CurrentFireMode != 2)
		{
			SetCurrentFireMode(2);
		}
	}

	simulated function Recharged()
	{
		GotoState('Active');
	}

	simulated function bool IsFiring()
	{
		return true;
	}
}

simulated state WeaponPuttingDown
{
	simulated function BeginState( Name PreviousStateName )
	{
		
		if (bDebugWeapon)
		{
			LogInternal("---"@self$"."$GetStateName()$".BeginState("$PreviousStateName$")");
		}


                 Set3p(False);



		TimeWeaponPutDown();
		bWeaponPutDown = false;
	}

	simulated function EndState(Name NextStateName)
	{

		Super.EndState(NextStateName);

	}

	simulated function Activate();

	/**
	 * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
	 */
	simulated function bool bReadyToFire()
	{
		return false;
	}
}




simulated function StopFireEffects(byte FireModeNum);

defaultproperties
{
   WeaponAnims = AnimSet'UTCQC_Weapons.Anims.CQC_animtest'
   AttackAnim = "TestSwing"

   MinDamage=20.000000
   MaxDamage=140.000000
   MinForce=40000.000000
   MaxForce=100000.000000
   MinSelfDamage=8.000000
   SelfForceScale=-1.200000
   SelfDamageScale=0.300000
   ChargeAnim="weaponcharge"
   ChargeIdleAnim="weaponchargedidle"
   MaxChargeTime=2.500000
   MinChargeTime=1.000000
   WeaponChargeSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_FireLoop_Cue'
   WeaponEMPChargeSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltFireLoop_Cue'
   ImpactJumpSound=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_FireBodyThrow_Cue'
   AutoFireRange=110.000000
   EMPDamage=150.000000
   ChargeEffect(0)=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Charge_Primary'
   ChargeEffect(1)=ParticleSystem'WP_ImpactHammer.Particles.P_WP_Impact_Charge_Secondary'
   AltHitEffect=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Secondary_Hit_Impact'
   ImpactKillCameraAnim=CameraAnim'UTCQC_Weapons.CamAnims.TestCamAnim'
   bMuzzleFlashPSCLoops=True
   bFastRepeater=True
   bTargetFrictionEnabled=True
   bTargetAdhesionEnabled=True
   MaxAmmoCount=5
   ShotCost(0)=0
   FireCameraAnim(0)=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Primary_Fire_Shake'
   FireCameraAnim(1)=CameraAnim'Camera_FX.ImpactHammer.C_WP_ImpactHammer_Alt_Fire_Shake'
   IconCoordinates=(U=453.000000,V=327.000000,UL=135.000000,VL=57.000000)
   CrossHairCoordinates=(U=64.000000,V=0.000000)
   InventoryGroup=1
   AmmoDisplayType=EAWDS_None
   AttachmentClass=Class'UTGame.UTAttachment_ImpactHammer'
   GroupWeight=0.700000
   WeaponFireAnim(2)="WeaponFire"
   WeaponFireAnim(3)="WeaponFire"
   ArmFireAnim(2)="WeaponFire"
   ArmFireAnim(3)="WeaponFire"
   ArmsAnimSet=AnimSet'WP_ImpactHammer.Anims.K_WP_Impact_1P_Arms'
   WeaponFireSnd(0)=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltFire_Cue'
   WeaponFireSnd(1)=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_AltImpact_Cue'
   WeaponPutDownSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_Lower_Cue'
   WeaponEquipSnd=SoundCue'A_Weapon_ImpactHammer.ImpactHammer.A_Weapon_ImpactHammer_Raise_Cue'
   WeaponColor=(B=128,G=255,R=255,A=255)
   WeaponCanvasXPct=0.450000
   WeaponCanvasYPct=0.450000
   MuzzleFlashPSCTemplate=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Primary_Hit'
   MuzzleFlashAltPSCTemplate=ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Secondary_Hit'
   SmallWeaponsOffset=(X=12.000000,Y=6.000000,Z=-6.000000)
   CurrentRating=0.450000
   TargetFrictionDistanceMin=64.000000
   TargetFrictionDistancePeak=128.000000
   TargetFrictionDistanceMax=200.000000
   WeaponFireTypes(2)=EWFT_None
   WeaponFireTypes(3)=EWFT_None
  // FiringStatesArray(0)="WeaponChargeUp"
   //FiringStatesArray(1)="WeaponChargeUp"
   FireInterval(0)=1.100000
   FireInterval(1)=1.100000
   FireInterval(2)=1.100000
   FireInterval(3)=1.100000
   Spread(2)=0.000000
   InstantHitDamage(0)=10.000000
   InstantHitDamage(1)=10.000000
   InstantHitDamageTypes(0)=Class'UTGame.UTDmgType_ImpactHammer'
   InstantHitDamageTypes(1)=Class'UTCQC.CQCDmgType_TestHammer'
   InstantHitDamageTypes(2)=None
   InstantHitDamageTypes(3)=Class'UTGame.UTDmgType_ImpactHammer'
   FireOffset=(X=20.000000,Y=0.000000,Z=0.000000)
   bCanThrow=False
   bInstantHit=True
   bMeleeWeapon=True
   WeaponRange=110.000000
/*   Begin Object Class=UTSkeletalMeshComponent Name=FirstPersonMesh ObjName=FirstPersonMesh Archetype=UTSkeletalMeshComponent'UTGame.Default__UTWeapon:FirstPersonMesh'
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
   Priority=1.000000
   AIRating=0.350000
   ItemName="Test Hammer"
   PickupMessage="Test Hammer"
   /*Begin Object Class=SkeletalMeshComponent Name=PickupMesh ObjName=PickupMesh Archetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTWeapon:PickupMesh'
   End Object*/
   DroppedPickupMesh=PickupMesh
   PickupFactoryMesh=PickupMesh
   Name="Default__UTWeap_ImpactHammer"
   ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'
}
