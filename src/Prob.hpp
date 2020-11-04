#ifndef _PROB_
#define _PROB_




#include "Node.hpp"
#include <map>
namespace Prob{
     // const double LEFT=.15;
     // const double STRAIGHT=.7;
     // const double RIGHT=.15;
     enum dir{WEST, NORTH, EAST, SOUTH};
     extern dir directions[4];
     
     namespace drift{extern double LEFT; extern double STRAIGHT; extern double RIGHT;};
     typedef bool evid[4];
     typedef std::pair<int,int> Pos;
     enum block{OPEN, CLOSED};
     extern std::map<std::pair<bool,bool>, float> square_prob;
     
     float ep(Node::node nodeGrid[][WIDTH], Pos pos, evid evidence);
     void filter(Node::node nodeGrid[][WIDTH], evid evidence );

     // Gets all possiple ways to get to posstion
     float tp(Node::node nodeGrid[][WIDTH], Pos pos, dir direction);
     float pred(Node::node nodeGrid[][WIDTH], dir direction);

}

#endif /* PROB_H */
