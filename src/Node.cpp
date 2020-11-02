#include "Node.hpp"
namespace Node {

void printGrid(node nodeGrid[][WIDTH]) {

    std::cout << "+++++++++++++++++++++++++++++++++++++\n";

    for (short row = 0; row < HEIGHT; row++) {
        for (short col = 0; col < WIDTH; col++) {
            std::cout << nodeGrid[row][col].label << "   ";
        }

        std::cout << "\n";
    }

    std::cout << "+++++++++++++++++++++++++++++++++++++\n";
}

void setGrid(node nodeGrid[][WIDTH], float freeNodes) {

    float defaultNodeProb = 100 / freeNodes;

    std::cout << "default prob: " << defaultNodeProb << std::endl;

    for (short row = 0; row < HEIGHT; row++) {
        for (short col = 0; col < WIDTH; col++) {
            setNode(nodeGrid, row, col, defaultNodeProb, false);
        }
    }

    for (short row = 1; row < HEIGHT - 1; row++) {
        setNode(nodeGrid, row, 1, 0.0f, true, " ####");
    }

    setNode(nodeGrid, 1, 2, 0.0f, true, " ####");
    setNode(nodeGrid, 3, 2, 0.0f, true, " ####");
}

void setNode(node nodeGrid[][WIDTH], int row, int col,
             float nodeProb, bool isBlock, std::string label) {

    nodeGrid[row][col].prob = nodeProb;
    nodeGrid[row][col].isBlock = isBlock;

    // If no label is given
    if (label.empty()) {
        std::stringstream stream;
        stream << std::fixed << std::setprecision(2) << std::setw(5) << nodeProb;
        nodeGrid[row][col].label = stream.str();
    } else {
        // If a label is given
        nodeGrid[row][col].label = label;
    }
}

} // namespace Node