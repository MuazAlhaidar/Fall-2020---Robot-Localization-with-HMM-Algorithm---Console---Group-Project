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
const AllDirects =(WEST, NORTH, EAST, SOUTH)
# Actual => Evidence
const Sense=Dict(OPEN=>Dict(OPEN=>.8, CLOSED=>.2), CLOSED=>Dict(OPEN=>.25, CLOSED=>.75))

function print_grid(grid::Array{Array{Float64,1},1})
	for i = 1:HEIGHT
		for j = 1:WIDTH
			if(!blocked(grid, (i,j)))
				print("####","\t")
			else
				print(round(grid[i][j]*100, digits=4), "\t")
		   	end
		end
		println()
	end
end

function ep(grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64})
	println(pos, pos[1], "\t",  pos[2])
end

function blocked(grid::Array{Array{Float64,1},1}, pos::Tuple{Int64, Int64})
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
		block = blocked(grid, tmp_pos)
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
			tmp_grid[row][col]*=cep(grid, (row, col), evidence)

		end
	end
	total_sum = sum(sum(tmp_grid))
	tmp_grid/ total_sum
end
