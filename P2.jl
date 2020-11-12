grid = [
	 [1/24, 1/24, 1/24, 1/24, 1/24]
	,[1/24, 0.0, 0.0, 1/24, 1/24]
	,[1/24, 0.0, 1/24, 1/24, 1/24]
	,[1/24, 0.0, 0.0, 1/24, 1/24]
	,[1/24, 0.0, 1/24, 1/24, 1/24]
	,[1/24, 1/24, 1/24, 1/24, 1/24]

	]
	
const HEIGHT=6
const WIDTH=5

@enum SquareType OPEN CLOSED
@enum Direction WEST NORTH EAST SOUTH
@enum DriftType STRAIGHT LEFT RIGHT

const Drift=Dict(STRAIGHT=>.7, LEFT=>.15, RIGHT=>.15)
const AllDirects =(WEST, NORTH, EAST, SOUTH)

# Actual => Evidence
const Sense=Dict(OPEN=>Dict(OPEN=>.8, CLOSED=>.2), CLOSED=>Dict(OPEN=>.25, CLOSED=>.75))

function print_grid(grid::Array{Array{Float64,1},1})
	for i = 1:HEIGHT
		for j = 1:WIDTH
			if(!notblocked(grid, (i,j)))
				print("####","\t")
			else
				print(round(grid[i][j]*100, digits=2), "\t")
		   	end
		end
		println()
	end
end


# Check if the posistion is blocked (either out of boudns/obstacles) or a free space
function notblocked(grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64})
	if( (pos[1]>0 && pos[1]<=HEIGHT) && (pos[2]>0 && pos[2]<=WIDTH) )
		return (grid[pos[1]][pos[2]] != 0.0)
	end
	return false
end

# Given direction adn posistions return psostion that is pos+direction
function move(pos::Tuple{Int64, Int64}, dir::Direction)
	
	if(dir==WEST)
		return (pos[1], pos[2]-1)
	end
	
	if(dir==NORTH)
		return (pos[1]-1, pos[2])
	end
	
	if(dir==EAST)
		return (pos[1], pos[2]+1)
	end
	
	if(dir==SOUTH)
		return (pos[1]+1, pos[2])
	end
end

# Given posistion and evidecne return probabilty of being in that posistion
# PRECONDITION: Grid, position and evidecne
# POSTCONDITION: Conditonal Evidence Probabilty at that point
function evidence_Probabilty(grid::Array{Array{Float64,1},1}, 
							pos::Tuple{Int64, Int64}, 
							evidence::Tuple{SquareType, SquareType, SquareType, SquareType})
	prod = 1
	for i in 1:4
		tmp_pos = move(pos,AllDirects[i])
		block = notblocked(grid, tmp_pos)
		if (block)
			prod*= Sense[OPEN][evidence[i]]
		else
			prod*= Sense[CLOSED][evidence[i]]
		end
	end
	prod 
end

# Get the evidecne contional probabilty of each posistoin*Pos(s_i)
# Then divide each posistion with the evidnece conditonal probabilty
# PRECONDITION: Given grid and evidence
# POSTCONDITION: Return filter of the grid, usign conditonal evdiecne probabilty
function filter(grid::Array{Array{Float64,1},1}, evidence::Tuple{SquareType, SquareType, SquareType, SquareType})
	tmp_grid = deepcopy(grid)
	for row in 1:6
		for col in 1:5
			if(notblocked(grid, (row,col)))
				tmp_grid[row][col]*=evidence_Probabilty(grid, (row, col), evidence)
			end
		end
	end
	total_sum = sum(sum(tmp_grid))
	tmp_grid / total_sum
end

# Gets the transitional probabilty of posistions going into a point,
# or transitional probablites from the point
# the first is used for prediction, the other for smoothing
# PRECONDITION: Given grid, position, a direction and type of transtional probabitly
# POSTCONDITION: Return probabilty of points going into pos, or probabitly of points going away from pos.
function transprob( grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64}, dir::Direction, getforward=false) # => array of  (pos::Tuple{Int64, Int64}, Drift[Direction] * P(s), Drift[Direction])
	arr = []
	function _gen_parts(straightDir::Direction , 
						leftDir::Direction, 
						rightDir::Direction, 
						behindDir::Direction, 
						grid::Array{Array{Float64,1},1}, 
						pos::Tuple{Int64,Int64} )
		parent_pos = []
		behind = move(pos, behindDir)
		straight = move(pos, straightDir)
		left = move(pos, leftDir)
		right = move(pos, rightDir)
            
		if( !notblocked(grid, straight)) # Bounce
			push!(parent_pos, (pos,Drift[STRAIGHT]*grid[pos[1]][pos[2]], Drift[STRAIGHT] ))
		elseif (getforward) # If this is smoothing, want the probabilty in front
			push!(parent_pos, (straight,Drift[STRAIGHT]*grid[straight[1]][straight[2]], Drift[STRAIGHT] ))
		end
		if( notblocked(grid, behind) && !getforward) # Prob of square behind current ot move to current
			push!(parent_pos, (behind,Drift[STRAIGHT]*grid[behind[1]][behind[2]], Drift[STRAIGHT]))
		end
		if(notblocked(grid, left)) # Get probabitly of the left pos coming to curretn
			push!(parent_pos, (left,Drift[LEFT]*grid[left[1]][left[2]], Drift[LEFT] ))
		else #Bounce from left
			push!(parent_pos, (pos,Drift[LEFT]*grid[pos[1]][pos[2]], Drift[LEFT] ))
		end
		if(notblocked(grid, right)) #Get probabilty of right pos coming to current
			push!(parent_pos, (right,Drift[RIGHT]*grid[right[1]][right[2]],Drift[RIGHT]))
		else #Bounce
			push!(parent_pos, (pos,Drift[RIGHT]*grid[pos[1]][pos[2]], Drift[RIGHT]))
		end
	end

	if(dir==WEST)
		arr=_gen_parts(WEST, SOUTH, NORTH, EAST, grid, pos)
	elseif(dir==NORTH)
		arr=_gen_parts(NORTH, EAST, WEST, SOUTH, grid, pos)
	elseif(dir==SOUTH)
		arr=_gen_parts(SOUTH, EAST, WEST, NORTH, grid, pos)
	elseif(dir==EAST)
		arr=_gen_parts(EAST, SOUTH, NORTH, WEST, grid, pos)
	end
	
	arr
end




# Prediction is the sum of possiple transitional probabilties
# that can reach pos_i, * P(pos).j
# PRECONDITON: Given a grid and direction
# POSTCONDITION: Prediction of where the agent will go after this movement.
function predict(grid::Array{Array{Float64,1}}, dir::Direction)
	tmp_grid = deepcopy(grid)
	for row in 1:6
		for col in 1:5
			if(notblocked(grid, (row,col)))
				x= transprob(grid, (row, col), dir)
				val=sum([x[2] for x in transprob(grid, (row, col), dir)])
				tmp_grid[row][col]=val
			end
		end
	end
	
	tmp_grid
end

# Get the transitional probabilty of a point going OUT, not in
# an it's conditional probabilty, with it's inital probabilty
# returns 2 things: B at pos, and B*p(s)
# PRECONDITON: Grid
function smoothpart( grid::Array{Array{Float64,1}}, 
					Bgrid::Array{Array{Float64,1}},  
					evidence::Tuple{SquareType, SquareType, SquareType, SquareType},  
					dir::Direction, pos::Tuple{Int64, Int64})
					
	parent_pos=transprob(grid, pos, dir, true)
         x=(sum([evidence_Probabilty(grid, i[1], evidence)* Bgrid[i[1][1]][i[1][2]]* i[3] for i in parent_pos]))
	(x, x * grid[pos[1]][pos[2]])
end

# Get the smoothing part for each posistion in grid
# Then divide the whoel grid by the sum of it's parts
function smooth(                grid::Array{Array{Float64,1}}, 
				Bgrid::Array{Array{Float64,1}},  
				evidence::Tuple{SquareType, SquareType, SquareType, SquareType},  
				dir::Direction)
				
	NewGrid = deepcopy(grid)
	B = deepcopy(Bgrid)
	
	for row in 1:6
		for col in 1:5
			if(notblocked(grid, (row,col)))
				val=smoothpart(grid, Bgrid, evidence, dir, (row,col))
				B[row][col] = val[1]
				NewGrid[row][col] = val[2]
			else
				B[row][col]  = 0
				NewGrid[row][col] = 0
			end
		end
	end
	NewGrid/=sum(sum(NewGrid))
	(NewGrid, B)
end

tmp  = filter(grid, (OPEN, OPEN, OPEN, OPEN))
tmp2 = predict(tmp, WEST)
tmp3 = filter(tmp2, (CLOSED, CLOSED, OPEN, CLOSED))
tmp4 = predict(tmp3, NORTH)
tmp5 = filter(tmp4, (CLOSED, CLOSED, OPEN, CLOSED))

Bgrid = [
	 [1.0, 1.0, 1.0, 1.0, 1.0]
	 ,[1.0, 1.0, 1.0, 1.0, 1.0]
	 ,[1.0, 1.0, 1.0, 1.0, 1.0]
	 ,[1.0, 1.0, 1.0, 1.0, 1.0]
	 ,[1.0, 1.0, 1.0, 1.0, 1.0]
	 ,[1.0, 1.0, 1.0, 1.0, 1.0]

	 ]

(tmp6,b)=smooth(tmp3,Bgrid,(CLOSED,CLOSED,OPEN,CLOSED),NORTH)
(tmp7,c)=smooth(tmp,b,(CLOSED,CLOSED,OPEN,CLOSED),WEST)

println("Initial Location Probabilities")
print_grid(grid)
println("\nFiltering after Evidence [0, 0, 0, 0]")
print_grid(tmp)
println("\nPrediction after Action W")
print_grid(tmp2)
println("\nFiltering after Evidence [1, 1, 0, 1]")
print_grid(tmp3)
println("\nPrediction after Action N")
print_grid(tmp4)
println("\nFiltering after Evidence [1, 1, 0, 1]")
print_grid(tmp5)
println("\nLast position Smoothing with Evidence [1, 1, 0, 1] and north")
print_grid(tmp6)
println("\nSecond Last posistion smoothing with Evidence [1, 1, 0, 1] And west")
print_grid(tmp7)
