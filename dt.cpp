//for translating BIN files into DATA statments for BASIC
//makes a basic program that loads the payload into TRS-80 RAM
//alnwlsn 2021
//
//Argument format: dt infilename linestart(dec) addressstart(hex) outfilename
//
#include <fstream>
#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    if (argc >= 4) {
        std::string inFile(argv[1]);
        uint16_t lineno = (int)strtol(argv[2], NULL, 10);
        uint16_t targetAddress = (int)strtol(argv[3], NULL, 16);
        std::string outFile(argv[4]);
        uint16_t linenoint = lineno;
        char str[256];
        std::ofstream ofile(outFile, std::ofstream::binary);
        std::ifstream cfile(inFile, std::ifstream::binary);
        int8_t datix = 0;
        sprintf(str, "%d 'DATA LOADER TO RAM\r\n", lineno);
        ofile << str;
        sprintf(str, "%d IX = %d 'ADDRESS IN RAM 0X%04x\r\n", lineno + 1, targetAddress, targetAddress);
        ofile << str;
        sprintf(str, "%d RESTORE\r\n", lineno + 2);
        ofile << str;
        sprintf(str, "%d READ Z\r\n", lineno + 3);
        ofile << str;
        sprintf(str, "%d POKE IX,Z\r\n", lineno + 5);
        ofile << str;
        sprintf(str, "%d IX = IX + 1\r\n", lineno + 6);
        ofile << str;
        sprintf(str, "%d GOTO %d\r\n", lineno + 7, lineno + 3);
        ofile << str;
        lineno = lineno + 8;
        while (1) {
            unsigned char a = 0;
            cfile.read((char*)&a, sizeof(unsigned char));
            if (cfile.eof()) {
                break;
            }
            if (datix == 0) {
                sprintf(str, "%d DATA %d", lineno, a);
                ofile << str;
                lineno++;
            } else if (datix == 11) {
                sprintf(str, ",%d\r\n", a);
                ofile << str;
                datix = -1;
            } else {
                sprintf(str, ",%d", a);
                ofile << str;
            }
            datix++;
        }
        sprintf(str, "\r\n%d DATA -1\r\n%d IF Z = -1 THEN GOTO %d\r\n", lineno, linenoint + 4, lineno + 1);
        ofile << str;
        lineno++;
        sprintf(str, "%d POKE 16526,%d\r\n", lineno, targetAddress & 255);
        ofile << str;
        lineno++;
        sprintf(str, "%d POKE 16527,%d\r\n", lineno, (targetAddress >> 8) & 255);
        ofile << str;
        lineno++;
        sprintf(str, "%d 'END OF LOADER\r\n", lineno);
        ofile << str;
        lineno++;
        sprintf(str, "%d X=USR(0)\r\n", lineno);
        ofile << str;
        lineno++;
        sprintf(str, "CLS\r\nRUN\r\n");
        ofile << str;
        cfile.close();
        ofile.close();
    } else {
        printf("\r\nNot Enough Arguments!");
        return 0;
    }
    return 0;
}