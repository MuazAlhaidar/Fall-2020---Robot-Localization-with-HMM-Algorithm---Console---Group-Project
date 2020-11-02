#ifndef _NODE_
#define _NODE_

#define WIDTH 5
#define HEIGHT 6

#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

namespace Node {

struct node {
    // The current probability of that node
    float prob;
    // Is the node an obstacle
    bool isBlock;
    // What is going to display out of the node
    std::string label;
};

void printGrid(node nodeGrid[][WIDTH]);
void setGrid(node nodeGrid[][WIDTH], float freeNodes);
void setNode(node nodeGrid[][WIDTH], int row, int col, float nodeProb, bool isBlock, std::string label = "");
} // namespace Node

#endif