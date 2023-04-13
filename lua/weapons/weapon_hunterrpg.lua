SWEP.PrintName = "Hunter's RPG"
SWEP.Author = "Bloomstorm"
SWEP.Instructions = "Left click - Launch rocket. Right click - Hunter's laugh"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.HoldType = "rpg"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Secondary.Automatic = false
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl" 
SWEP.WorldModel = "models/weapons/emesisblue/w_rocket_launcher.mdl"

local laserDotMat = Material("effects/brightglow_y")

//Set holdtype in Initialize for animations
function SWEP:Initialize()
	self:SetWeaponHoldType("rpg")
	util.PrecacheSound("pj/bloomstorm/emesisblue/emesis_blue_hunter_signal.wav");
	util.PrecacheSound("pj/bloomstorm/emesisblue/emesis_blue_hunter_kill.wav");
	self.UseDelay = 1.5;
end

// Draw red point in thirdperson for all
function SWEP:DrawWorldModel(flags)
	self:DrawModel(flags)
	local tr = self.Owner:GetEyeTraceNoCursor();
	render.SetMaterial(laserDotMat)
	render.DrawSprite(tr.HitPos, 16, 16, Color(255, 0, 0, 255))
end

if CLIENT then
// Draw red point in firstperson for client, cam Start3D is bugged for some reason
function SWEP:ViewModelDrawn()
	local tr = self.Owner:GetEyeTraceNoCursor();
	//cam.Start3D(EyePos(), EyeAngles())
		render.SetMaterial(laserDotMat)
		render.DrawSprite(tr.HitPos, 16, 16, Color(255, 0, 0, 255))
	//cam.End3D()
end
end

// Create signal, wait 0.8 and then shoot
function SWEP:PrimaryAttack()
        self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
        if not self:CanPrimaryAttack() then return end  
        if ( self.Owner:GetAmmoCount( "RPG_Round" ) < 0 ) then return end
        self.Weapon:SetNextPrimaryFire(CurTime() + 2.0)
        self.Weapon:TakePrimaryAmmo(1)

		if SERVER then
			self.Owner:EmitSound("pj/bloomstorm/emesisblue/emesis_blue_hunter_signal.wav", 80, 100, 0.4)
		end
		
		timer.Simple(0.8, function() 
				self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
				self.Weapon:EmitSound("Weapon_RPG.Single")
		
				if ( SERVER ) then
				
        
                local grenade = ents.Create( "rpg_rocket" )
                grenade:SetPos( self.Owner:GetShootPos() )
                grenade:SetOwner( self.Owner )
                grenade.FlyAngle = self.Owner:GetAimVector():Angle()
                grenade:Spawn()
                
                local phys = grenade:GetPhysicsObject()
                if (phys:IsValid()) then
                        phys:SetVelocity( self.Owner:GetAimVector() * 1500 )
                end  
			end 
		end)

end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 2.0)
	if SERVER then
		self.Owner:EmitSound("pj/bloomstorm/emesisblue/emesis_blue_hunter_kill.wav", 80, 100, 0.4)
	end
end