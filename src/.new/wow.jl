grid = [
	 [1/24, 1/24, 1/24, 1/24, 1/24]
	,[1/24, 0.0, 0.0, 1/24, 1/24]
	,[1/24, 0.0, 1/24, 1/24, 1/24]
	,[1/24, 0.0, 0.0, 1/24, 1/24]
	,[1/24, 0.0, 1/24, 1/24, 1/24]
	,[1/24, 1/24, 1/24, 1/24, 1/24]

	]
function reload()
	include("wow.jl")
end
const HEIGHT=6
const WIDTH=5
# const OPEN=0
# const CLOSED=1
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

function ep(grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64})
	println(pos, pos[1], "\t",  pos[2])
end

function notblocked(grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64})
	if( (pos[1]>0 && pos[1]<=HEIGHT) && (pos[2]>0 && pos[2]<=WIDTH) )
		return (grid[pos[1]][pos[2]] != 0.0)
	end
	return false
end

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

function cep(grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64}, evidence::Tuple{SquareType, SquareType, SquareType, SquareType})
	prod = 1
	for i in 1:4
		tmp_pos = move(pos,AllDirects[i])
		block = notblocked(grid, tmp_pos)
		if (block)
			# println("OPEN\t",tmp_pos, Sense[OPEN][evidence[i]])
			prod*= Sense[OPEN][evidence[i]]
		else
			# println("CLOSED\t",tmp_pos, Sense[CLOSED][evidence[i]])
			prod*= Sense[CLOSED][evidence[i]]
		end
	end
	prod 

end

function filter(grid::Array{Array{Float64,1},1}, evidence::Tuple{SquareType, SquareType, SquareType, SquareType})
	tmp_grid = deepcopy(grid)
	for row in 1:6
		for col in 1:5
			if(notblocked(grid, (row,col)))
			tmp_grid[row][col]*=cep(grid, (row, col), evidence)
			end

		end
	end
	total_sum = sum(sum(tmp_grid))
	tmp_grid/ total_sum
end
function transprob( grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64}, dir::Direction)
	arr = []
	function _gen_parts(straightDir::Direction , leftDir::Direction, rightDir::Direction, behindDir::Direction, grid::Array{Array{Float64,1},1}, pos::Tuple{Int64,Int64} )
		parent_pos = []
		behind = move(pos, behindDir)
		straight = move(pos, straightDir)
		left = move(pos, leftDir)
		right = move(pos, rightDir)
		println(left, right, straight, behind)


		if( notblocked(grid, behind)) # Prob of square behind current ot move to current
			push!(parent_pos, (behind,Drift[STRAIGHT]*grid[behind[1]][behind[2]], behind,Drift[STRAIGHT], behind))
		end
		if( !notblocked(grid, straight)) # Bounce
			push!(parent_pos, (pos,Drift[STRAIGHT]*grid[pos[1]][pos[2]], pos,Drift[STRAIGHT], straight))
		end

		if(notblocked(grid, left))
			push!(parent_pos, (pos,Drift[LEFT]*grid[left[1]][left[2]], pos,Drift[LEFT], left))
		else
			push!(parent_pos, (pos,Drift[LEFT]*grid[pos[1]][pos[2]], pos,Drift[LEFT], left))
		end

		if(notblocked(grid, right))
			push!(parent_pos, (pos,Drift[RIGHT]*grid[right[1]][right[2]], pos,Drift[RIGHT],right))
		else
			push!(parent_pos, (pos,Drift[RIGHT]*grid[pos[1]][pos[2]], pos,Drift[RIGHT], right))
		end
	end
	if(dir==WEST)
		arr=_gen_parts(WEST, SOUTH, NORTH, EAST, grid, pos)
	end
	if(dir==NORTH)
		arr=_gen_parts(NORTH, EAST, WEST, SOUTH, grid, pos)
	end
	if(dir==SOUTH)
		arr=_gen_parts(SOUTH, EAST, WEST, NORTH, grid, pos)
	end
	if(dir==EAST)
		arr=_gen_parts(EAST, SOUTH, NORTH, WEST, grid, pos)
	end
	arr
end


function predict(grid::Array{Array{Float64,1}}, dir::Direction)
	tmp_grid = deepcopy(grid)
	for row in 1:6
		for col in 1:5
			if(notblocked(grid, (row,col)))
				val=sum([x[2] for x in transprob(grid, (row, col), dir)])
				tmp_grid[row][col]=val
			end
		end
	end
	tmp_grid

end

function smoothpart( grid::Array{Array{Float64,1}}, last_grid::Array{Array{Float64,1}}, Bgrid::Array{Array{Float64,1}},  evidence::Tuple{SquareType, SquareType, SquareType, SquareType},  dir::Direction, pos::Tuple{Int64, Int64})
	parent_pos=transprob(grid, pos, dir )
	x=0
	for i in parent_pos[2:4]
		tmp_pos = i[1]
		# println(i[1], "\t", cep(grid, i[1], evidence ), "\t", last_grid[i[1][1]][i[1][2]], Bgrid[i[1][1]][i[1][2]], i[2])
		y=cep(grid, tmp_pos, evidence)* Bgrid[tmp_pos[1]][tmp_pos[2]]* i[4]
		println(y, "=\t", cep(grid, tmp_pos, evidence), "*\t","*\t", Bgrid[tmp_pos[1]][tmp_pos[2]], "*\t", i[4], "------------", i[1])
		x+=y
	end
	(x, x *last_grid[pos[1]][pos[2]])
end

# function smooth( grid::Array{Array{Float64,1}}, last_grid::Array{Array{Float64,1}}, Bgrid::Array{Array{Float64,1}},  evidence::Tuple{SquareType, SquareType, SquareType, SquareType},  dir::Direction)
# 	SP = deepcopy(grid)
# 	B = deepcopy(Bgrid)
# 	for row in 1:6
# 		for col in 1:5
# 			if(notblocked(grid, (row,col)))
# 				val=smoothpart(grid, last_grid, Bgrid, evidence, dir, (row,col))
# 				B[row][col] = val[1]
# 				SP[row][col] = val[2]
# 			end
# 		end
# 	end
# 	SP/=sum(sum(SP))

# 	(SP, B)
# end
tmp=filter(grid, (OPEN, OPEN, OPEN, OPEN))
tmp2=predict(tmp, WEST)
tmp3=filter(tmp2, (CLOSED, CLOSED, OPEN, CLOSED))
tmp4=predict(tmp3, NORTH)
tmp5= filter(tmp4, (CLOSED, CLOSED, OPEN, CLOSED))
# print_grid(tmp); println()
# print_grid(tmp2); println()
# print_grid(tmp); println()
# print_grid(tmp); println()
# print_grid(tmp); println()
# print_grid(tmp); println()
Bgrid = [
	 [1.0, 1.0, 1.0, 1.0, 1.0]
	,[1.0, 1.0, 1.0, 1.0, 1.0]
	,[1.0, 1.0, 1.0, 1.0, 1.0]
	,[1.0, 1.0, 1.0, 1.0, 1.0]
	,[1.0, 1.0, 1.0, 1.0, 1.0]
	,[1.0, 1.0, 1.0, 1.0, 1.0]

	]

# println(tmp2[6][1])
# println(smooth(tmp5,tmp,Bgrid,(CLOSED,CLOSED,OPEN,CLOSED),NORTH))
#
#
#
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
