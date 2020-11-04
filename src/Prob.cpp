#include "Prob.hpp"
#include<array>
#include<cassert>

#include<iostream>
using namespace std;
namespace Prob{

     namespace drift{double LEFT=.15; double STRAIGHT=.7; double RIGHT=.15;};
     dir directions[] = {WEST, NORTH, EAST, SOUTH};
     std::pair<int,int> move(Pos pos, dir direction){
	  std::pair<int,int> tmp={pos.first, pos.second};
	  if(direction==WEST){
	       tmp.second-=1;
	       return tmp;
	  }
	  else if(direction==NORTH){
	       tmp.first-=1;
	       return tmp;
	  }
	  else if(direction==EAST){
	       tmp.second+=1;
	       return tmp;
	  }
	  else if(direction==SOUTH){
	       tmp.first+=1;
	       return tmp;
	  }
	  else{
	       assert("THIS shouldn't happen");
	       return tmp;
	  }
     }
     
     double tp(Node::node nodeGrid[][WIDTH], Pos pos,  dir direction){
	  // Get each square around pos
	  std::array<Pos, 3> adj;
	  {
	    // North=[-1,0]
	    // South=[1,0]
	    // East=[0,-1]
	    // West=[0,1]
	    
	       // North east west
	       if(direction == NORTH){adj[0] = move(pos, NORTH); adj[1] = move(pos, WEST); adj[2] = move(pos, EAST);}
	       // East North South
	       else if(direction == EAST){adj[0] = move(pos, EAST); adj[1] = move(pos, NORTH); adj[2] = move(pos, SOUTH);}
	       // West North South
	       else if(direction == WEST){adj[0] = move(pos, WEST); adj[1] = move(pos, NORTH); adj[2] = move(pos, SOUTH);}
	       // South east west
	       else if(direction == SOUTH){adj[0] = move(pos, SOUTH); adj[1] = move(pos, EAST); adj[2] = move(pos, WEST);}
	  }

	  std::cout << adj[0].first << "\t" << adj[0].second << std::endl;
	  std::cout << adj[1].first << "\t" << adj[1].second << std::endl;
	  std::cout << adj[2].first << "\t" << adj[2].second << std::endl;

	  std::cout << nodeGrid[adj[0].first][adj[0].second].prob << std::endl;
	  std::cout << nodeGrid[adj[1].first][adj[1].second].prob << std::endl;
	  std::cout << nodeGrid[adj[2].first][adj[2].second].prob << std::endl;
	  // Get it's transitional probabilty * S1 probabilty
	  auto prob = [nodeGrid, pos](Node::node curnode, double dir){
	       // Bounce
	       if(curnode.isBlock){
		    return nodeGrid[pos.first][pos.second].prob * dir;
	       }
	       // From curnode to pos
	       else{
		    return curnode.prob * dir;
	       }
	  };
	  std::cout <<prob(nodeGrid[adj[0].first][adj[0].second], .70) << std::endl;
	  std::cout <<prob(nodeGrid[adj[1].first][adj[1].second], .15) << std::endl;
	  std::cout <<prob(nodeGrid[adj[2].first][adj[2].second], .15) << std::endl;

	  

return .5;
	 
}

}
