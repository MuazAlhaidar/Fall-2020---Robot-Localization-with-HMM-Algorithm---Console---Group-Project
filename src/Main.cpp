#include "Node.hpp"
#include "Prob.hpp"
#include <iostream>

int main() {

    Node::node nodeGrid[HEIGHT][WIDTH];

    Node::setGrid(nodeGrid, 24.0f);

    // Node::printGrid(nodeGrid);

    std::pair<int,int> q={3,3};
    std::cout << Prob::tp(nodeGrid,  q, Prob::WEST) << std::endl;

    return 0;
}
