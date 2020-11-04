#ifndef _PROB_
#define _PROB_




#include "Node.hpp"
namespace Prob{
     // const double LEFT=.15;
     // const double STRAIGHT=.7;
     // const double RIGHT=.15;
     enum dir{WEST, NORTH, EAST, SOUTH};
     extern dir directions[4];
     namespace drift{extern double LEFT; extern double STRAIGHT; extern double RIGHT;};
     typedef bool evid[4];
     typedef std::pair<int,int> Pos;
     double filter(Node::node nodeGrid[][WIDTH], evid evidence );
     // double pred(Node::node nodeGrid[][WIDTH], dir direction);
     // Gets all possiple ways to get to posstion
     double tp(Node::node nodeGrid[][WIDTH], Pos pos, dir direction);

}

#endif /* PROB_H */
