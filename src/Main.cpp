#include "Node.hpp"
#include "Prob.hpp"
#include <iostream>

using namespace std;
int main() {

    Node::node nodeGrid[HEIGHT][WIDTH];

    Node::setGrid(nodeGrid, 24.0f);

    Node::printGrid(nodeGrid);

    std::pair<int,int> q={0,0};
    // std::cout << Prob::tp(nodeGrid,  q, Prob::WEST) << std::endl;

    bool tmp[]={Prob::OPEN, Prob::OPEN, Prob::OPEN, Prob::OPEN};
    // cout << Prob::ep(nodeGrid, q, tmp) << endl ;
    Prob::filter(nodeGrid, tmp);
    Node::printGrid(nodeGrid);
    return 0;
}
