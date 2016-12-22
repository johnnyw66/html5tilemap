-- Copyright 2012, John Wilson, Brighton Sussex UK. Licensed under the BSD License. See licence.txt
if (not KDampedOscillator) then
KDampedOscillator	=	{ }

KDampedOscillator.className			 	= 	'kDampedOscillator'

KDampedOscillator.k_strongly_damped 	= 	0
KDampedOscillator.k_weakly_damped		=	1
KDampedOscillator.k_critically_damped	=	2

--						Based on my old MST204 math course notes.
--						m_ 				=	0,
--						r_ 				=	0,
--						k_ 				=	0,
--	
--						x0_				=	0,
--						v0_				=	0,
--						xe_ 			=	0,
--	
						-- Natural angular frequency and damping ratio.
--						v_ 
--						w_ 
--						alpha_ 
--
						-- Coefficients speficic to strong damping.
--						private float	b_, c_ 
--						private float	l1_, l2_
						-- Coefficients specific to weak damping.
--						private float	a_ 
--						private float 	p_, phi_ 

--
--	kdampedoscillator()	-	default constructor
--
--	Initialise the spring constants to something...
--
--	public KDampedOscillator()
--	{
--		this(1.0f,1.0f,100.0f,0.0f,0.0f) 
--	} 
	
--	public KDampedOscillator(float m, float r, float k)
--	{
--		this(m,r,k,0.0f,0.0f) 
--	}

--m=1 r=0 k=100 will make it shake very fast

	function KDampedOscillator.Create( m,  r,  k,  x,  v)
		local kdampedoscillator = {
			x0_ 		= x, 
			v0_			= v,
			m_			= m,
			r_			= r,
			k_  		= k,
			xe_			= 0,
			v_			= 0,
			w_			= 0,
		    alpha 		= 0,
			p_			= 0,
			className	= KDampedOscillator.className,
		}
		setmetatable(kdampedoscillator,{__index = KDampedOscillator})	
		return kdampedoscillator
	end
	
	
	-- Reference MST204/MST209 Handbook
	function KDampedOscillator.reset(kdampedoscillator, x0,  v0,  xe)
		
		kdampedoscillator.x0_ = x0 - xe 
		kdampedoscillator.v0_ = v0 
		kdampedoscillator.xe_ = xe 

		-- Calculate the natural angular frequency and damping ratio.

		kdampedoscillator.w_ = math.sqrt( kdampedoscillator.k_ / kdampedoscillator.m_ ) 
		kdampedoscillator.alpha_ = kdampedoscillator.r_ / ( 2 * math.sqrt( kdampedoscillator.m_ * kdampedoscillator.k_ ) ) 

	 	-- Calculate the solution type.

		if ( kdampedoscillator.alpha_ > 1 ) then
			kdampedoscillator.damping_type_ = KDampedOscillator.k_strongly_damped 
		elseif ( kdampedoscillator.alpha_ < 1 ) then
			kdampedoscillator.damping_type_ = KDampedOscillator.k_weakly_damped 
		else
			kdampedoscillator.damping_type_ = KDampedOscillator.k_critically_damped 
		end
		--assert(false,'DT = '..kdampedoscillator.damping_type_)	
	 	-- Solve the equation of motion.
		
		local damping_type_ = kdampedoscillator.damping_type_ 
		
			
		if (damping_type_ ==  KDampedOscillator.k_strongly_damped) then
		
			local a = math.sqrt( kdampedoscillator.alpha_*kdampedoscillator.alpha_ - 1.0) 

			kdampedoscillator.l1_ = kdampedoscillator.w_*( -kdampedoscillator.alpha_ + a ) 
			kdampedoscillator.l2_ = kdampedoscillator.w_*( -kdampedoscillator.alpha_ - a ) 

			-- Initial conditions.

			kdampedoscillator.c_ = ( kdampedoscillator.v0_ - kdampedoscillator.l1_*kdampedoscillator.x0_ ) / ( kdampedoscillator.l2_ - kdampedoscillator.l1_ ) 
			kdampedoscillator.b_ = kdampedoscillator.x0_ - kdampedoscillator.c_ 
			
		elseif (damping_type_ ==  KDampedOscillator.k_weakly_damped) then
			
			-- x(t) = A*exp(-pt)*cos(vt+phi)

			kdampedoscillator.p_ = kdampedoscillator.r_ / kdampedoscillator.m_ * 0.5 
			kdampedoscillator.v_ = math.sqrt( 4.0*kdampedoscillator.m_*kdampedoscillator.k_ - kdampedoscillator.r_*kdampedoscillator.r_ ) / kdampedoscillator.m_ * 0.5
			kdampedoscillator.a_ = math.sqrt( kdampedoscillator.x0_*kdampedoscillator.x0_ + kdampedoscillator.v0_*kdampedoscillator.v0_ / (kdampedoscillator.p_*kdampedoscillator.p_))

			if (kdampedoscillator.a_ == 0.0) then
				kdampedoscillator.phi_ =	0.0
			else
				kdampedoscillator.phi_ =	math.acos( kdampedoscillator.x0_ / kdampedoscillator.a_ ) 
			end
		
		elseif (damping_type_ ==  KDampedOscillator.k_critically_damped) then

			kdampedoscillator.c_ = kdampedoscillator.x0_ 
			kdampedoscillator.b_ = kdampedoscillator.v0_ + kdampedoscillator.x0_ * kdampedoscillator.w_ 
		end
			
			
		
		
	end
	
	
	-- 
	-- 	centre()	-	returns the centre position of the spring
	-- 
	-- 	The centre is the position when the spring is in equilibrium.
	-- 
	-- public void centre( float & x ) -- const
	-- {
	-- 	x = xe_ 
	-- }
	
	function KDampedOscillator.centre(kdampedoscillator) 
		return kdampedoscillator.xe_ 
	end
	

	-- 
	-- 	equilibrium()	-	check if the oscillator is in static equilibrium
	-- 
	-- 	The oscillator is static if it is at the equilibrium position with zero velocity.
	-- 
	-- 	Parameters:
	-- 
	-- 		t		-	the time to evaluate the system at
	-- 		epsilon	-	how near to true equilbrium to calculate to
	-- 
	-- 	Returns:
	-- 
	-- 		the position of the system at the time t
	-- 

	function KDampedOscillator.equilibrium(kdampedoscillator, t,  epsilon ) 
		return math.abs( KDampedOscillator.evaluate(kdampedoscillator, t ) - kdampedoscillator.xe_ ) <= epsilon and math.abs( KDampedOscillator.velocity(kdampedoscillator, t ) ) <= epsilon 
	end
	
	
	
	function KDampedOscillator.evaluate(kdampedoscillator, t)

		local x = 0.0
		local damping_type_ = kdampedoscillator.damping_type_ 
		
		if (damping_type_ == KDampedOscillator.k_strongly_damped) then
			x = kdampedoscillator.b_*math.exp( kdampedoscillator.l1_*t ) + kdampedoscillator.c_*math.exp( kdampedoscillator.l2_*t ) 
		elseif (damping_type_ == KDampedOscillator.k_weakly_damped) then
			x = kdampedoscillator.a_*math.exp( -kdampedoscillator.p_*t ) * math.cos( kdampedoscillator.v_*t + kdampedoscillator.phi_ ) 
		elseif (damping_type_ == KDampedOscillator.k_critically_damped) then
			x = (kdampedoscillator.b_*t +kdampedoscillator.c_)*math.exp( -kdampedoscillator.w_*t ) 
		end			
		
		return kdampedoscillator.xe_ + x
		
	end
	
	function KDampedOscillator.velocity(kdampedoscillator, t)

		local v = 0.0
		local damping_type_ = kdampedoscillator.damping_type_ 
		if (damping_type_ == KDampedOscillator.k_strongly_damped) then
				v = kdampedoscillator.b_*kdampedoscillator.l1_*math.exp( kdampedoscillator.l1_*t ) + kdampedoscillator.c_*kdampedoscillator.l2_*math.exp( kdampedoscillator.l2_*t ) 
		elseif (damping_type_ == KDampedOscillator.k_weakly_damped) then
				v = -kdampedoscillator.a_*kdampedoscillator.p_*math.exp( -kdampedoscillator.p_*t ) * math.cos( kdampedoscillator.v_*t + kdampedoscillator.phi_ ) - kdampedoscillator.v_ * kdampedoscillator.a_*math.exp( -kdampedoscillator.p_*t ) * math.sin( kdampedoscillator.v_*t + kdampedoscillator.phi_ ) 
		elseif (damping_type_  == KDampedOscillator.k_critically_damped) then
				v = ( kdampedoscillator.b_ - kdampedoscillator.w_*(kdampedoscillator.b_*t +kdampedoscillator.c_ ) )*math.exp( -kdampedoscillator.w_*t ) 
		end		

		return v 
	end
	
end
