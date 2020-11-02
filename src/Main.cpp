#include "Node.hpp"
#include <iostream>

int main() {

    Node::node nodeGrid[HEIGHT][WIDTH];

    Node::setGrid(nodeGrid, 24.0f);

    Node::printGrid(nodeGrid);

    return 0;
}