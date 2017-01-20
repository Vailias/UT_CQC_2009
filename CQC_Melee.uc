/*
    CQC_Melee by Brandon "vailias" Newton - 2009
    This is the base class of all UTCQC melee weapons

*/
class CQC_Melee extends UTWeapon
                abstract //add this back in after testing
                ;

/** Path to animations for weapon strikes **/
var AnimSet AttackAnims;
//var AnimSet AttackAnimsKrall; //ToDO Add hooks for this so that the Krall get animated properly.

var soundCue WeaponIdleSnd;
var array<soundCue> SpecialMoveSound;
var soundCue ReflectSound;
var AudioComponent IdleComponent;

/** name of attack sequence for weapon strike
!note!
This would be great if we could use an ANIMTREE for Directional Attacks, but it seems that each player can have only one anim tree, so we're handling it in code.
**/
var array<Name> AttackSequenceF, AttackSequenceB, AttackSequenceSide;
var name ReflectSequence, BlockSequence, IdleSequence;
var array<Name> SpecialMoveSequence;
var array<CameraAnim> SpecialMoveCamAnim;

var bool bBlocking;

/**
timer length set on entry to blocking state.
If player takes damage during this (very short) window, the attack is reflected along its vector and a "DENIED!" is played. (consider recording a "REJECTED!" soundbyte

**/
var array<pawn> oldOwners, ReflectedProjectiles;
var float fReflectWindow;
var bool bReflect;

var float ammoRecharge; //per second
var float VehDamageMult;

var float currentTime;

//used in special move catch
enum WMD_Direction
{
WMD_Forward,
WMD_Back,
WMD_Left,
WMD_Right,
WMD_Still
};

var array<int> SpecialMoveAmmo;//Ammount of ammo to consume for this combo
var array<int> SpecialMoveDamage;//damage for this special move
var array<float> SpecialMoveMomentum;//Momentum for special
var array< class<UTDamageType> > SpecialMoveDamageTypes;//Damage types for each special type

var array<string> SpecialMoves; // a string that is the combo move encoded. IE FFFF = forward 4 times.
var array<float> SpecialMoveDuration; //how long each one takes.
var string SpecialMoveString;
var int longestMove, currentSpecial;
var array<ParticleSystem> SpecialMoveFX;


var ParticleSystem HitTemplate;
var ParticleSystem ReflectTemplate;
var ParticleSystem ShieldTemplate;

var string Faction; //name of faction creating this weapon type. Used in FactionWeapons Mutator. Still to come.


var string NowState;//debugvar remove laters

function GivenTo(Pawn ThisPawn, optional bool bDoNotActivate)
{
        local UTPawn UTP;
        local int i;
        UTP = UTPawn(ThisPawn);
        UTP.Mesh.AnimSets.AddItem(AttackAnims);
              if (WeaponIdleSnd != none)
              {
              IdleComponent = CreateAudioComponent(WeaponIdleSnd, false, true, true, instigator.location, true);
              }

        longestMove = 0;
        for (i=0; i<SpecialMoves.length; i++)
        {
        if (longestMove < Len(SpecialMoves[i]))
           {
           longestMove = Len(SpecialMoves[i]);
           }
        }
         SpecialMoveString = "";

                Super.GivenTo(ThisPawn, bDoNotActivate);


}

 //debug
 /*
 simulated function DrawWeaponCrosshair( Hud HUD )
 {
  local UTHUD H;
  local UTPlayerController PC;
  local UTPlayerInput IP;

                 if ((Instigator!= none) && Instigator.IsHumanControlled())     //just ignore bots for now..
                 {
                 PC = UTPlayerController(Instigator.Controller);
                  IP = UTPlayerInput(PC.PlayerInput);
                  H = UTHUD(HUD);
                  H.Canvas.SetDrawColor(255,0,0);
                  H.Canvas.SetPos(4,200);
                  H.Canvas.DrawText("Current Combo String="@SpecialMoveString);
                  H.Canvas.SetPos(4,215);
                  H.Canvas.DrawText("State="@NowState);
                  //H.Canvas.DrawText("aStrafe="@IP.aStrafe@"aForward="@IP.aForward);
                  H.Canvas.SetPos(4,230);
                  H.Canvas.DrawText("Velocity="@Instigator.Velocity@"Groundspeed="@UTPawn(Instigator).groundSpeed@"Jump="@UTPawn(Instigator).jumpz);

                  H.Canvas.SetPos(4,245);
                  H.Canvas.DrawText("bReflect="@bReflect@"CurrentFireMode="@CurrentFireMode);


                  //H.Canvas.DrawText("PCaStrafe="@PC.aStrafe@"PCaForward="@PC.aForward);


                //  H.DisplayHudMessage(PC.PlayerInput.aTurn@PC.PlayerInput.aLookup);
                //  H.DisplayHudMessage("DISPLAY THIS MESSAGE!!",0.5,0.5);
                 }
                 Super.DrawWeaponCrosshair(HUD);

 }

 */
simulated function bool HasAnyAmmo()
{

        return true;

}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
        if(FireModeNum ==  0)
        {
               return True;
        }
        if(FireModeNum >= 1)
        {
       	       if (Amount > 0)
	       {
                   return (AmmoCount>Amount) ? true : false ;//gotta love the ternary operator
               }
               return true;
        }
}



//subclassed here to override normal ammo consumption. Handled outside of this function.
function ConsumeAmmo( byte FireModeNum )
{
}


simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{


        Super.AttachWeaponTo(MeshCpnt, SocketName);
	// so replication is guaranteed to happen when we change it later.
	SetCurrentFireMode(128);


}

//AI Functions
//
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

//This sets conditions for attacking.

function bool CanAttack(Actor Other)
{
	return true;
}

function float SuggestAttackStyle()
{
	return 1.0;
}




/*****************************
Player animation and perspective controls

******************************/

simulated function Set3p(bool TP)
{
    local UTPlayerController PC;

    if ((Instigator!= none) && Instigator.IsHumanControlled())
    {
    PC = UTPlayerController(Instigator.Controller);

                if(PC.bBehindView != TP)     //IF WE'RE not in the right view perspective, change to the new one.
                {
                PC.ClientSetBehindView(TP);
		}
    }
 }

 function PlayPlayerAnim(UTPawn UTP, bool Fullbody, name Anim, float duration, optional bool override)
{
        if(!Fullbody)
        {
                 UTP.TopHalfAnimSlot.PlayCustomAnimByDuration(Anim, duration,0.1,0.1,false,override);
                 UTP.TopHalfAnimSlot.SetActorAnimEndNotification(true);
         }
         else
         {
              UTP.FullBodyAnimSlot.PlayCustomAnimByDuration(Anim, duration,0.1,0.1,false,override);
              UTP.FullBodyAnimSlot.SetActorAnimEndNotification(true);
         }
}

function LoopPlayerAnim(UTPawn UTP, bool Fullbody, name Anim, float rate)
{
         if(!FullBody)
             UTP.TopHalfAnimSlot.PlayCustomAnim(Anim, rate,0.1,0.1,true,true);

         else
            UTP.FullBodyAnimSlot.PlayCustomAnim(Anim, rate,0.1,0.1,true,true);

}

function StopPlayerAnim(UTPawn UTP, bool Fullbody)
{
         if(FullBody)
                     UTP.FullBodyAnimSlot.StopCustomAnim(0.1);
         else
                     UTP.TopHalfAnimSlot.StopCustomAnim(0.1);
}

function PlayReflectSound()
{
    UTPlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'UTLastSecondMessage', 1, UTPlayerController(Instigator.Controller).PlayerReplicationInfo, None, None);

}


function WMD_Direction CheckMove()
{
 //catch function for directional input. Used with special move system.
 //Note that standing still is checked first, and side to side movement trumps forward movement

 local vector VCR;
  local float Strafe, Forward;
   if ((Instigator!= none) && Instigator.IsHumanControlled())     //just ignore bots for now..
   {
   VCR = Normal(Instigator.Velocity) cross Normal(Vector(Instigator.Rotation));


  Strafe = VCR.Z;
  Forward = Normal(Instigator.Velocity) dot Normal(Vector(Instigator.Rotation));



  if (Forward == 0 && Strafe == 0)
  {
  return WMD_Still;
  }
    if (Strafe > 0.9)
   {
   return WMD_Left;
   }
   else if (Strafe < -0.9)
   {
   return WMD_Right;
   }
   if(Forward > 0.5)
   {
   return WMD_Forward;
   }
   else if (Forward < -0.5)
   {
     return WMD_Back;
   }
  return WMD_Still;

  }
  return WMD_Still;

}


function CreateSpecialString(WMD_Direction dir)
{
  switch(dir)
  {
  case WMD_Still:
  SpecialMoveString $= "S";
  break;

  case WMD_Forward:
  SpecialMoveString $= "F";
  break;

  case WMD_Back:
  SpecialMoveString $= "B";
  break;

  case WMD_Left:
  SpecialMoveString $= "L";
  break;

  case WMD_Right:
  SpecialMoveString $= "R";
  break;
  }

}

simulated function playHitEffects(vector HitLocation, vector HitNormal)//snagged from projectile.uc  simpleImplementation
{

	local ParticleSystemComponent PSC;
        if (WorldInfo.NetMode != NM_DedicatedServer)
	{
         if (bReflect)
         {
         PSC = WorldInfo.MyEmitterPool.SpawnEmitter(ReflectTemplate, HitLocation, rotator(HitNormal), none);
             if(ReflectSound != none)
             {
             WeaponPlaySound(ReflectSound);
             }
         }
         else
         {
         PSC = WorldInfo.MyEmitterPool.SpawnEmitter(HitTemplate, HitLocation, rotator(HitNormal), none);
         }
        }

       //toDo add sound here

}
/************************************

we're handling special moves as a constant running string of input characters.
This running move string is then checked against the special move strings defined in the defaultproperties
 If it occurs as the last N characters in the running string then we can do a special.

************************************/
function bool CheckSpecial()
{
         local int i;

         for (i=0; i<SpecialMoveSequence.length; i++)
         {
         if (InStr(SpecialMoveString, Caps(SpecialMoves[i]), true) == (Len(SpecialMoveString) - Len(SpecialMoves[i])))
          {
           currentSpecial = i;
           if(hasAmmo(CurrentFireMode, SpecialMoveAmmo[currentSpecial]))
           {
           SpecialMoveString="";//if we're successfull then clear the movestring so no spamming specials.
           return True;
           }
          }

         }
         return false;
}

/***************
Fireing routines

****************/

simulated function HandleMeleeFire(int FiringMode)
{
                local UTPawn UTP;
                //local string Trash;
                local name attackToPlay;
                local WMD_Direction Dir;
                local int random;

                UTP = UTPawn(Instigator);
                Dir = CheckMove();
                random = Rand(AttackSequenceF.Length); //assuming all animtypes have the same number of sequences. NOt the most robust.

                if(FiringMode == 0) //primary fire plus direction is what sets up the specials.
                {
                  switch(dir)
                     {
                       case WMD_Still:
                       case WMD_Forward:
                       attackToPlay = AttackSequenceF[random];
                       break;

                       case WMD_Back:
                        attackToPlay = AttackSequenceB[random];
                       break;

                       case WMD_Left:
                       case WMD_Right:
                        attackToPlay = AttackSequenceSide[random];
                       break;
                     }

                PlayPlayerAnim(UTP, false, attackToPlay, FireInterval[CurrentFireMode], true);

             /*
                //keeps our move string managable, while allowing for multiple tries at getting the right sequence.
                if (Len(SpecialMoveString) > (longestMove*2))
                   {
                   EatStr(Trash,SpecialMoveString, longestMove);
                   //turns out this has been removed. :(
                   }
                   */
                 CreateSpecialString(CheckMove());
                }

                if(FiringMode == 1)
                {
                PlayPlayerAnim(UTP, false, ReflectSequence, 0.25, true);

                }
                if (FiringMode == 2)
                {
                 if(SpecialMoveSound[currentSpecial] != none)
                 {
                 WeaponPlaySound(SpecialMoveSound[currentSpecial]);
                 }
                }
}






/********************************
*  Fireing stuff
*
*
*
********************************/
/*
simulated function PlayImpactEffect(byte FiringMode, ImpactInfo Impact)
{
   //For hit effects
}
*/

//override this in subclasses for individual effects.
simulated function doSpecial(int SpecialNum)
 {
  local Pawn HitPawn, BoardPawn;
  local vector Facing, HitDirection;
  local UTVehicle UTV;

  PlayPlayerAnim(UTPawn(Instigator), false, SpecialMoveSequence[currentSpecial], SpecialMoveDuration[currentSpecial], false);
  UTPlayerController(Instigator.Controller).PlayCameraAnim(SpecialMoveCamAnim[SpecialNum]);
  addAmmo(-SpecialMoveAmmo[SpecialNum]);
          if (Role == ROLE_Authority)
          {
             foreach OverlappingActors(class 'Pawn', HitPawn, WeaponRange, Instigator.Location)
             {
              LogInternal(Instigator@"hit"@HitPawn@"using special move!");
             HitDirection = Normal(HitPawn.Location - Instigator.Location);

             if ( (HitPawn.Mesh != None) && !WorldInfo.GRI.OnSameTeam(HitPawn, self))
			{
                         if (HitDirection dot Facing > 0.25) //if what we hit is witin 45degrees in front of us
                         {

				if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
				{
				 //if the pawn would almost be killed by this, then just kill them. Its a special afterall.
                                      if(HitPawn.Health <= SpecialMoveDamage[SpecialNum]+5)
                                      {
                                      HitPawn.TakeDamage(HitPawn.Health+15, Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[currentSpecial]*HitDirection, SpecialMoveDamageTypes[currentSpecial], , Instigator );

                                      }
                                    else
                                    {
                                      HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[currentSpecial]*HitDirection, SpecialMoveDamageTypes[currentSpecial], , Instigator );
                                    }
                        	}
				else if( UTVehicle_Hoverboard(HitPawn) != none)
				{
					BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
					UTVehicle_Hoverboard(HitPawn).RagdollDriver();
					HitPawn = BoardPawn;
					HitPawn.LastHitBy = Instigator.Controller;
                                    if(HitPawn.Health <= SpecialMoveDamage[SpecialNum]+5)
                                      {
                                      HitPawn.TakeDamage(HitPawn.Health+15, Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection, SpecialMoveDamageTypes[SpecialNum], , Instigator );

                                      }
                                    else
                                    {
                                      HitPawn.TakeDamage(SpecialMoveDamage[SpecialNum], Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection, SpecialMoveDamageTypes[SpecialNum], , Instigator );
                                    }
				}
				else if ( HitPawn.Physics == PHYS_RigidBody )
				{
					UTV = UTVehicle(HitPawn);
                                        UTV.TakeDamage(SpecialMoveDamage[SpecialNum]*VehDamageMult, Instigator.Controller, HitPawn.Location, SpecialMoveMomentum[SpecialNum]*HitDirection, SpecialMoveDamageTypes[SpecialNum], , Instigator );
                                }
                          }

                     }
                 }
             }
 }

//Called for both fire modes.
simulated function CustomFire()
{
  //local UTProjectile HitProj;
  local Pawn HitPawn, BoardPawn;
  local vector Facing, HitDirection, NewVel, NewLoc;
  local UTVehicle UTV;
  local Projectile proj, newproj;
  local class<projectile> tempProj;
  Local actor Target;



  //local WorldInfo WI;
   Facing = Normal(vector(Instigator.Rotation));

   //////////////////////
   //special move
   //////////////////////
   if (CurrentFireMode == 2)
   {
     doSpecial(currentSpecial);
   }

   if (CurrentFireMode == 0)
   {
          if (Role == ROLE_Authority)
          {
             foreach OverlappingActors(class 'Pawn', HitPawn, WeaponRange, Instigator.Location)
             {
             HitDirection = Normal(HitPawn.Location - Instigator.Location);

             if ( (HitPawn.Mesh != None) && !WorldInfo.GRI.OnSameTeam(HitPawn, self))
             {
                         if (HitDirection dot Facing > 0) //if what we hit is witin 180degrees in front of us
                         {
                             addAmmo(ammoRecharge);

				if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
				{
                                      HitPawn.TakeDamage(InstantHitDamage[CurrentFireMode], Instigator.Controller, HitPawn.Location, InstantHitMomentum[CurrentFireMode]*HitDirection, InstantHitDamageTypes[CurrentFireMode], , Instigator );
                        	}
				else if( UTVehicle_Hoverboard(HitPawn) != none)
				{
					BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
					UTVehicle_Hoverboard(HitPawn).RagdollDriver();
					HitPawn = BoardPawn;
					HitPawn.LastHitBy = Instigator.Controller;
					HitPawn.TakeDamage(InstantHitDamage[CurrentFireMode], Instigator.Controller, HitPawn.Location, InstantHitMomentum[CurrentFireMode]*HitDirection, InstantHitDamageTypes[CurrentFireMode], , Instigator );
				}
				else if ( HitPawn.Physics == PHYS_RigidBody && HitPawn.IsA('UTVehicle') )
				{
					UTV = UTVehicle(HitPawn);
					UTV.TakeDamage(InstantHitDamage[CurrentFireMode]*VehDamageMult, Instigator.Controller, HitPawn.Location, InstantHitMomentum[CurrentFireMode]*HitDirection, InstantHitDamageTypes[CurrentFireMode], , Instigator );

                                }
                          }
                      PlayHitEffects(HitPawn.Location,HitDirection);
                     }
                 }
             }
        }

   if (CurrentFireMode == 1)
    {
    if(ROLE ==  ROLE_Authority)
    {
       ForEach DynamicActors(class'Projectile', proj)
       {
             if(bReflect && (proj.instigator != instigator) && !WorldInfo.GRI.OnSameTeam(proj.instigator, instigator) )//only reflect other peoples shots, not ours or our friends'
             {
                hitDirection =  proj.Location - Instigator.location;
                if ((VsizeSQ(proj.Location - Instigator.location) <= WeaponRange*WeaponRange) && ((normal(hitDirection) dot Facing) > 0) )//only reflect if within weapon range and in front of us
                {
                   tempProj = Proj.class;
                   newVel = -proj.Velocity;
                   newLoc = proj.location;
                   if (tempProj == class'UTProj_SeekingRocket')
                   {
                      target = proj.owner;
                   }
                   UTProjectile(proj).bSuppressExplosionFX = true;
                   UTProjectile(proj).Reset();
                }

                if (tempProj != none)
                {
                    newproj = ReflectedProjFire(tempProj, NewVel, newLoc);
                    if (newproj != none)
                    {
                    newproj.velocity = newVel;
                    newproj.SetRotation(rotator(newVel));
                                     if (tempProj == class'UTProj_SeekingRocket')
                                     {
                                       UTProj_SeekingRocket(newProj).Seeking = target;
                                     }
                    }
                    PlayHitEffects(newproj.Location,Normal(HitDirection));
                }
             }
       }//end forEach
    }//end role
    }//end firemode1

}

 simulated function Projectile ReflectedProjFire(class<projectile> Proj, vector direction, vector SpawnLoc)
{

	local Projectile	SpawnedProjectile;

	if( Role == ROLE_Authority )
	{

		SpawnedProjectile = Spawn(Proj, Self,, SpawnLoc);

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

function ReflectEnd()
{
 local UTPawn UTP;
 UTP = UTPawn(Instigator);
 LoopPlayerAnim(UTP, false, BlockSequence, 1.0);
 bReflect=false;
 NowState="ReflectEnd";
}




/***************************
* States
*
*
**************************/

simulated state Active
{
          simulated function BeginState(Name PreviousStateName)
          {
             local UTPawn UTP;
             local int i;
             local bool hasAnims;
             UTP = UTPawn(Instigator);
             UTP.SetHandIKEnabled(false); 
              for(i=0; i< UTP.Mesh.Animsets.Length; i++)
              {
              if (UTP.Mesh.Animsets[i] == AttackAnims)
                 {
                 hasAnims = true;
                 }
              }
              if (!hasAnims)
              {
              UTP.Mesh.AnimSets.AddItem(AttackAnims);
              }
             if (IdleComponent != none && !IdleComponent.IsPlaying())
             {
             IdleComponent.Play();
             }


              LoopPlayerAnim(UTP, false, IdleSequence, 1.0);
              Set3p(True);

                Super.BeginState(PreviousStateName);
          }


          simulated function Tick(float DeltaTime)
          {

          Set3p(true);

          Super.Tick(DeltaTime);



          }

          simulated function EndState(Name NextStateName)
          {
                Super.EndState(NextStateName);
          }

}


simulated state WeaponFiring
{
	simulated event bool IsFiring()
	{
		return true;
	}

          simulated function bool TryPutdown()
	{

                bWeaponPutDown = true;
		return true;
	}

        simulated function RefireCheckTimer()
	{

                // if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}
                if( ShouldRefire() )
		{
			return;
		}


                GotoState('Active');
        }

        	simulated function bool ShouldRefire()
	{
		// in single fire more, it is not possible to refire. You have to release and re-press fire to shot every time
                EndFire( CurrentFireMode );

		return false;
	}

	simulated function BeginState( Name PreviousStateName )
	{

              NowState="Fireing";
              Set3p(true);//just incase we're somehow not in third person view when entering this state
              TimeWeaponFiring( CurrentFireMode );
              FireAmmunition();
              HandleMeleeFire( CurrentFireMode );
             // IncrementFlashCount();


	}

	simulated function EndState( Name NextStateName )
	{
		// Set weapon as not firing
		ClearFlashCount();
		ClearFlashLocation();
		ClearTimer('RefireCheckTimer');

		if (Instigator != none && AIController(Instigator.Controller) != None)
		{
			AIController(Instigator.Controller).NotifyWeaponFinishedFiring(self,CurrentFireMode);
		}
	}
}


/**
//reference
function float PlayCustomAnim
(
	name	AnimName,
	float	Rate,
	optional	float	BlendInTime,
	optional	float	BlendOutTime,
	optional	bool	bLooping,
	optional	bool	bOverride
)

function PlayCustomAnimByDuration
(
	name	AnimName,
	float	Duration,
	optional	float	BlendInTime,
	optional	float	BlendOutTime,
	optional	bool	bLooping,
	optional	bool	bOverride = TRUE
) //copied for reference

//custom animation implementation
///this should work. Also needs
var UTPawn UTP;
UTP = UTPawn(Instigator);
UTP.TopHalfAnimSlot.PlayCustomAnim(AttackSequence,1.0);

**/
simulated state doingSpecial extends Active
{

         simulated event bool IsFiring()
	{
		return true;
	}

          simulated function bool TryPutdown()
	{

                bWeaponPutDown = true;
		return true;
	}

         function AdjustPlayerDamage( out int Damage, Controller InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
           {
                    Damage = 0;
                    Momentum *= 0;
                          //temporary invincibility

           }

        simulated function bool ShouldRefire()
	{
		// in single fire more, it is not possible to refire. You have to release and re-press fire to shot every time
                EndFire( CurrentFireMode );

		return false;
	}


        simulated function RefireCheckTimer()
	{

                // if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}
                if( ShouldRefire() )
		{
			return;
		}


                GotoState('Active');
        }
         simulated function BeginState( Name PreviousStateName )
	{
                NowState="SPECIAL!";
                UTPawn(Instigator).Velocity *=0;
                UTPawn(Instigator).groundSpeed *= 0.1;//hold in place while doing combo
                UTPawn(Instigator).jumpz *= 0.10;//hold in place while doing combo

           	// if weapon is not firing, then start timer. Firing state is responsible to stopping the timer.
	        if( !IsTimerActive('RefireCheckTimer') )
	        {
		SetTimer(SpecialMoveDuration[currentSpecial], false, 'RefireCheckTimer' );
	        }
		HandleMeleeFire( CurrentFireMode );
                FireAmmunition();

	}


 	simulated function EndState( Name NextStateName )
	{

                // Set weapon as not firing
		UTPawn(Instigator).groundSpeed *= 10.0;//let them go
                 UTPawn(Instigator).jumpz *= 10.0;//hold in place while doing combo
                ClearFlashCount();
		ClearFlashLocation();
		ClearTimer('RefireCheckTimer');
                ClearTimer('ReflectEnd');

                if (Instigator != none && AIController(Instigator.Controller) != None)
		{
			AIController(Instigator.Controller).NotifyWeaponFinishedFiring(self,CurrentFireMode);
		}
		Super.EndState(NextStateName);
	}


}


/**
Fireing state for block mode.
Effectively a charge state similar to the impact hammer
*/
simulated state Blocking   extends Active
{

         simulated event bool IsFiring()
	{
		return false;
	}

          simulated function bool TryPutdown()
	{

                bWeaponPutDown = true;
		return true;
	}

       simulated function BeginFire(byte FireModeNum)
        {
        if (FireModeNum == 0)
        {
            if (CheckSpecial())//if we can do a special move
            {
            FireModeNum = 2;          //then DO a special move. Handled in CustomFire.
            CurrentFireMode = 2;
            goToState('doingSpecial');
            }

       }

        global.BeginFire(FireModeNum);
        }


        simulated function RefireCheckTimer()
	{
				// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}
                	// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			if (AmmoCount>0)
			{
                        FireAmmunition();
			IncrementFlashCount();
                        return;
                        }
                        else
                        {
                        EndFire(CurrentFireMode);
                        Return;
                        }
                }

		// Otherwise we're done firing, so go back to active state.
		GotoState('Active');
             }




           function AdjustPlayerDamage( out int Damage, Controller InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
           {
            //take up energy for preventing hits presently 1 ammo = 5 damage
                  local float newDamage;
                  newDamage = damage*0.2;
                  if (newDamage < 1.0)
                  {
                  newDamage = 1;
                  }
                 if (bReflect)
                 {
                     Momentum *= 0;
                 }
                 if ( HasAmmo(currentFireMode, Round(damage*0.2)))
                 {
                    addAmmo(-newDamage);
                    Damage = 0;
                    Momentum = Momentum*0.5;
                 }
                 else
                 {
                     Damage -= AmmoCount*5;
                     addAmmo(-ammoCount);
                     Momentum *= 0.5;
                 }

           }

         simulated function BeginState( Name PreviousStateName )
	{

                //reflection stuff. Set flag to true, then time it for the reflection window of opportunity
                NowState="BlockingStart";
                bReflect=True;
                IncrementFlashCount();
                setTimer(fReflectWindow,false,'ReflectEnd');
                 PlayPlayerAnim(UTPawn(Instigator), false, ReflectSequence, 0.25, true);
                TimeWeaponFiring( CurrentFireMode );
		HandleMeleeFire( CurrentFireMode );//this takes the place in the chain of FireAmmunition. Will call fireammunition once firing type is determined.
                FireAmmunition();

	}


 	simulated function EndState( Name NextStateName )
	{

                // Set weapon as not firing
		ClearFlashCount();
		ClearFlashLocation();
		ClearTimer('RefireCheckTimer');
                ClearTimer('ReflectEnd');
                bReflect = false;
                if (Instigator != none && AIController(Instigator.Controller) != None)
		{
			AIController(Instigator.Controller).NotifyWeaponFinishedFiring(self,CurrentFireMode);
		}
		Super.EndState(NextStateName);
	}


 }

simulated state WeaponPuttingDown
{
	simulated function BeginState( Name PreviousStateName )
	{

          local UTPawn UTP;

        	if (bDebugWeapon)
		{
			LogInternal("---"@self$"."$GetStateName()$".BeginState("$PreviousStateName$")");
		}
                TimeWeaponPutDown();
                bWeaponPutDown = false;

                //Cleanup
                Set3p(false);
                UTP = UTPawn(Instigator);
                StopPlayerAnim(UTP, False);
                StopPlayerAnim(UTP, True);
                SpecialMoveString="";
                UTP.SetHandIKEnabled(True);
                ///
                if(IdleComponent != none)
                {
                  IdleComponent.FadeOut(0.3, 0.0);
                }
                Super.BeginState(PreviousStateName);

	}

	simulated function EndState(Name NextStateName)
	{

		Super.EndState(NextStateName);

	}

        simulated function Activate();

	simulated function bool bReadyToFire()
	{
		return false;
	}
}






defaultproperties
{

   Faction="none"

   AttackAnims=AnimSet'UTCQC_Weapons.Anims.CQC_animtest'
   AttackSequenceF(0)="TestSwing"
   AttackSequenceB(0)="TestSwing"
   AttackSequenceSide(0)="TestSwing"
   ReflectSequence="TestSwing"
   BlockSequence="Idle_Ready_Pis"
   IdleSequence="CC_Human_Male_Idle"

   SpecialMoveSequence(0)="SpecialTest"
   SpecialMoveCamAnim(0)=CameraAnim'UTCQC_Weapons.CamAnims.TestCamAnim'
   SpecialMoveSound(0)=none
   SpecialMoveDamage(0)=40
   SpecialMoveDamageTypes(0)=Class'UTCQC.CQCDmgType_Default'
   SpecialMoveMomentum(0)=1500
   SpecialMoveAmmo(0)=25
   SpecialMoveDuration(0)=1.0
   SpecialMoves(0)="FFFF"

   ItemName="UTCQC BaseWeapon"
   Name="UTCQC BaseWeapon"
   bCanThrow=False
   bInstantHit=True
   bMeleeWeapon=True
   WeaponRange=150.000000
   VehDamageMult = 1.0

   fReflectWindow = 0.25;
   ammoRecharge = 5.0;

   HitTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
   ReflectTemplate=ParticleSystem'UTCQC_Weapons.FX.ReflectFX'
   ShieldTemplate=ParticleSystem'UTCQC_Weapons.FX.ShieldEffect'

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
   AmmoDisplayType=EAWDS_Both
   AttachmentClass=Class'UTCQC.CQC_WeaponAttachment'
   CrosshairColor=(B=255,G=255,R=255,A=255)
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




   NeedToPickUpAnnouncement=(AnnouncementText="Get your melee weapon!")
   PrimaryFireHintString="attacks."
   SecondaryFireHintString="blocks and reflects projectiles if timed right. ."

   ShouldFireOnRelease(0)=0
   ShouldFireOnRelease(1)=0
   ShouldFireOnRelease(2)=0

   WeaponIdleSnd=none
   WeaponFireSnd(0)=None
   WeaponFireSnd(1)=None
   WeaponFireSnd(2)=None
   ReflectSound=soundCue'UTCQC_Weapons.Sounds.shock_staff_popCue'

   WeaponFireTypes(0)=EWFT_Custom //attack
   WeaponFireTypes(1)=EWFT_Custom //block
   WeaponFireTypes(2)=EWFT_Custom //special1

   FiringStatesArray(0)="WeaponFiring"  //Attack
   FiringStatesArray(1)="Blocking"  //Blocking
   FiringStatesArray(2)="doingSpecial"  //Special Move

   FireInterval(0)=0.5
   FireInterval(1)=0.1    //keep on blocking
   FireInterval(2)=0.5


   InstantHitDamage(0)=10.000000 //simply using these to store damage ratings
   InstantHitDamage(1)=20.000000
   InstantHitDamage(2)=0.000

   InstantHitMomentum(0)=100.000000
   InstantHitMomentum(1)=100.000000
   InstantHitMomentum(2)=0.000000


   InstantHitDamageTypes(0)=Class'UTCQC.CQCDmgType_Default'
   InstantHitDamageTypes(1)=Class'UTCQC.CQCDmgType_Default'
  //InstantHitDamageTypes(2)=Class'UTCQC.CQCDmgType_Default' //change to special type
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

