#include "Prob.hpp"
#include<array>
#include<cassert>

#include<iostream>
#include<map>
#include<cmath>
using namespace std;
namespace Prob{

     std::map<std::pair<bool,bool>, float> square_prob={
	  {std::make_pair(OPEN,OPEN),      .8},
	  {std::make_pair(OPEN,CLOSED),    .2},
	  {std::make_pair(CLOSED,OPEN),    .25},
	  {std::make_pair(CLOSED,CLOSED),  .75}
     };
     // map[True][Senes]

     // square_prob[1][1] = .8;
     // square_prob[CLOSED][CLOSED] = .75;
     // square_prob[OPEN][CLOSED] = .20;
     // square_prob[CLOSED][OPEN] = .15;
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
     
     float tp(Node::node nodeGrid[][WIDTH], Pos pos,  dir direction){
	  // Get each square around pos
	  std::array<Pos, 3> adj;
	  {
	       // North=[-1,0]
	       // South=[1,0]
	       // East=[0,-1]
	       // West=[0,1]
	    
	       // North east west
	       if(direction == NORTH){
		    adj[0] = move(pos, NORTH);
		    adj[1] = move(pos, WEST);
		    adj[2] = move(pos, EAST);

	       }
	       // East North South
	       else if(direction == EAST){
		    adj[0] = move(pos, EAST);
		    adj[1] = move(pos, NORTH);
		    adj[2] = move(pos, SOUTH);

	       }
	       // West North South
	       else if(direction == WEST){
		    adj[0] = move(pos, WEST);
		    adj[1] = move(pos, NORTH);
		    adj[2] = move(pos, SOUTH);

	       }
	       // South east west
	       else if(direction == SOUTH){
		    adj[0] = move(pos, SOUTH);
		    adj[1] = move(pos, EAST);
		    adj[2] = move(pos, WEST);

	       }
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


     float ep(Node::node nodeGrid[][WIDTH], Pos pos, evid evidence){
	  // float prod=nodeGrid[pos.first][pos.second].prob;
	  float prod=nodeGrid[pos.first][pos.second].prob;
	  cout << prod << '\t' <<endl;
	  for(int i=0; i<4; i++){
	       Pos tmp = move(pos, directions[i]);
	       if((tmp.first > 0 && tmp.first < HEIGHT ) && (tmp.second > 0 && tmp.second < WIDTH ) ){
		    Node::node node = nodeGrid[tmp.first][tmp.second];
		    // cout << prod << '\t' << tmp.first << '\t' << tmp.second  << '\t' <<  node.prob << '\t' << square_prob[std::make_pair(node.isBlock ,evidence[i])] << endl;
		    prod *= square_prob[std::make_pair(node.isBlock, evidence[i])];
	       }
	       else{
		    prod *= square_prob[std::make_pair(CLOSED, evidence[i])];
	       }
	       if(pos.first == 5 && pos.second == 3){
		    cout << "NOVEMBER\t" <<  prod << '\t'; 
		    if((tmp.first > 0 && tmp.first < HEIGHT ) && (tmp.second > 0 && tmp.second < WIDTH ) ){
			 Node::node node = nodeGrid[tmp.first][tmp.second];
			 // cout << prod << '\t' << tmp.first << '\t' << tmp.second  << '\t' <<  node.prob << '\t' << square_prob[std::make_pair(node.isBlock ,evidence[i])] << endl;
			 // cout << square_prob[std::make_pair(node.isBlock, evidence[i])] << endl;
		    }
		    else{
			 // cout << square_prob[std::make_pair(CLOSED, evidence[i])] << endl;
			 // prod *= square_prob[std::make_pair(CLOSED, evidence[i])];
		    }
	       }
	  }
	  if(pos.first == 5 && pos.second == 3){
	       // cout << prod << "\tNOVEMBER" << endl;

	  }

	  return prod;
     }

     void filter(Node::node nodeGrid[][WIDTH], evid evidence ){
	  std::array<std::array<float, WIDTH>, HEIGHT> prob;
	  float sum=0;
	  for(int i=0; i<HEIGHT; i++){
	       for(int j=0; j<WIDTH; j++){
		    if(nodeGrid[i][j].isBlock != true){
			 // cout << i << '\t' << j <<endl;
			 prob[i][j] = ep(nodeGrid, make_pair(i,j), evidence);
			 // cout << prob[i][j] << '\n';
			 sum += prob[i][j];
		    }
	       }
	  }
	  for(int i=0; i<HEIGHT; i++){
	       for(int j=0; j<WIDTH; j++){
		    if(nodeGrid[i][j].isBlock != true){
			 cout << prob[i][j] << '\t' << sum << '\t' << prob[i][j]/sum << '\t' << i <<':' << j << endl;
			 // prob[i][j] /= sum;
			 nodeGrid[i][j].prob = prob[i][j]/sum;
			 std::ostringstream s;
			 // s << floorf(prob[i][j]*10000)/100;
			 s << prob[i][j]/sum;
			 std::string ss(s.str());
			 nodeGrid[i][j].label = ss;
		    }
	       }
	  }
     }
}
