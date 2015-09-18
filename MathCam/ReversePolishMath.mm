//
//  ReversePolishMath.m
//  MathCam
//
//  Created by Achintya Gopal on 4/29/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "ReversePolishMath.h"
#include <vector>
#include <map>
#include <sstream>
#include <cctype>
#include <iostream>
#include <cmath>

@implementation ReversePolishMath

using std::vector;
using std::map;
using std::pair;
using std::string;
using std::stringstream;

-(string)solve: (string)problem
{
    
    vector<char> operations;
    vector<string> values;
    vector<char> temp;
    map<char,int> operatorToInt;
    operatorToInt.insert(pair<char,int>('+',1));
    operatorToInt.insert(pair<char,int>('-',1));
    operatorToInt.insert(pair<char,int>('*',2));
    operatorToInt.insert(pair<char,int>('/',2));
    operatorToInt.insert(pair<char,int>('^',3));
    operatorToInt.insert(pair<char,int>('(',0));
    operatorToInt.insert(pair<char,int>(')',0));
    
    //convert to post fix
    for(int i = 0; i<problem.length(); i++){
        if(problem[i] == '+' ||  problem[i] == '*' || problem[i] == '/' ){
            if(temp.size() != 0){
                string temp2(temp.begin(), temp.end());
                values.push_back(temp2);
                temp.clear();
            }
            while(operatorToInt.at(operations.back()) >= operatorToInt.at(problem[i])){
                stringstream ss;
                ss << *operations.end();
                string operator1 = ss.str();                values.push_back(operator1);
                operations.pop_back();
            }
            operations.push_back(problem[i]);
        }
        else if(problem[i] == '-' ){
            if(temp.size() != 0){
                string temp2(temp.begin(), temp.end());
                values.push_back(temp2);
                while(operatorToInt.at(operations.back()) >= operatorToInt.at(problem[i])){
                    stringstream ss;
                    ss << *operations.end();
                    string operator1 = ss.str();                values.push_back(operator1);
                    operations.pop_back();
                }
                operations.push_back(problem[i]);
                temp.clear();
            }
            else{
                while(operatorToInt.at(operations.back()) >= operatorToInt.at(problem[i])){
                    stringstream ss;
                    ss << *operations.end();
                    string operator1 = ss.str();                values.push_back(operator1);
                    operations.pop_back();
                }
                temp.push_back(problem[i]);
            }
        }
        else if(problem[i] == '^'){
            if(temp.size() != 0){
                string temp2(temp.begin(), temp.end());
                values.push_back(temp2);
                temp.clear();
            }
            while(operatorToInt.at(operations.back()) >= operatorToInt.at(problem[i])){
                stringstream ss;
                ss << *operations.end();
                string operator1 = ss.str();                values.push_back(operator1);
                operations.pop_back();
            }
            operations.push_back(problem[i]);
            
        }
        else if(problem[i] == '(' ){
            if(temp.size() != 0){
                string temp2(temp.begin(), temp.end());
                values.push_back(temp2);
                temp.clear();
            }
            while(operatorToInt.at(operations.back()) >= operatorToInt.at(problem[i])){
                stringstream ss;
                ss << *operations.end();
                string operator1 = ss.str();                values.push_back(operator1);
                operations.pop_back();
            }
            operations.push_back(problem[i]);
        }
        else if(problem[i] == ')'){
            if(temp.size() != 0){
                string temp2(temp.begin(), temp.end());
                values.push_back(temp2);
                temp.clear();
            }
            while(operatorToInt.at(operations.back()) >= operatorToInt.at(problem[i])){
                stringstream ss;
                ss << *operations.end();
                string operator1 = ss.str();                values.push_back(operator1);
                operations.pop_back();
            }
        }
        else{
            temp.push_back(problem[i]);
        }
    }
    while(operations.size() != 0){
        stringstream ss;
        ss << *operations.end();
        string operator1 = ss.str();
        values.push_back(operator1);
        operations.pop_back();
    }
    
    //calculate post fix
    vector<std::__1::string> result;
    vector<string>::iterator it = values.begin();
    while(it != values.end()){
        if(is_digits(*it)){
            result.push_back(*it);
        }
        else{
            string b = result.back();
            result.pop_back();
            string a = result.back();
            result.pop_back();
            string c;
            if(*it == "+"){
                c = [self add:a toString:b];;
            }
            else if(*it == "-"){
                c = [self subtract:a fromString:b];            }
            else if(*it == "*"){
                c = [self multiply:a byString:b];
            }
            else if(*it == "/"){
                c = [self divide:a byString:b];
            }
            else if(*it == "^"){
                c = [self exponentiate:a toString:b];
            }
            result.push_back(c);
        }
        it++;
    }
    
    return result.at(0);
}

-(BOOL)compare:(string)a toString: (string)b {
    string temp1 = "";
    string temp2 = "";
    for(int i = 0; i <= a.length(); i++){
        if(!isdigit(a[i]) && a[i] != '.' && a[i] != '-'){
            temp1 = a.substr(i);
            break;
        }
    }
    
    for(int i = 0; i <= b.length(); i++){
        if(!isdigit(b[i]) && b[i] != '.'  && b[i] != '-'){
            temp1 = b.substr(i);
            break;
        }
    }
    
    return temp1 == temp2;
}

-(string)add:(string)a toString: (string)b {
    //vector<string> termsA;
    //vector<string> termsB;
    
    string termsNumA = "";
    string termsDenA = "1";
    vector<string> termsNumATerms;
    string termsNumB = "";
    string termsDenB = "1";
    vector<string> termsNumBTerms;
    
    vector<char> temp;
    
    int p = 0;
    for(int i = 0; i < a.length(); i++){
        if(a[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(p == 0){
                termsNumA = temp2;
                p = 1;
            }
            else{
                termsDenA = temp2;
                p = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(a[i]);
        }
    }
    string temp2(temp.begin(), temp.end());
    if(p == 0){
        termsNumA = temp2;
        p = 1;
    }
    else{
        termsDenA = temp2;
        p = 2;
    }
    temp.clear();
    
    int q = 0;
    temp.clear();
    for(int i = 0; i < b.length(); i++){
        if(b[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(q == 0){
                termsNumB = temp2;
                q = 1;
            }
            else{
                termsDenB = temp2;
                q = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(b[i]);
        }
    }
    string temp3(temp.begin(), temp.end());
    temp2 = temp3;
    if(q == 0){
        termsNumB = temp2;
        q = 1;
    }
    else{
        termsDenB = temp2;
        q = 2;
    }
    temp.clear();
    
    if(termsNumA[0] == '('){
        termsNumA.erase(termsNumA.begin());
    }
    if (termsNumB[0] == '('){
        termsNumB.erase(termsNumB.begin());
    }
    if(termsDenA[0] == '(' ){
        termsDenA.erase(termsDenA.begin());
    }
    if(termsDenB[0] == '(' ){
        termsDenB.erase(termsDenB.begin());
    }
    if(termsNumA[termsNumA.length() -1] == ')' ){
        termsNumA.erase(termsNumA.end() - 1);
    }
    if(termsNumB[termsNumB.length() -1] == ')' ){
        termsNumB.erase(termsNumB.end() - 1);
    }
    if(termsDenA[termsDenA.length() -1] == ')' ){
        termsDenA.erase(termsDenA.end() - 1);
    }
    if(termsDenB[termsDenB.length() -1] == ')' ){
        termsDenB.erase(termsDenB.end() - 1);
    }
    
    termsNumA = [self multiply:termsNumA byString:termsDenB];
    termsNumB = [self multiply:termsNumB byString:termsDenA];
    termsDenA = [self multiply:termsDenA byString:termsDenB];
    
    bool parenthesis = false;
    bool exponent = false;
    for(int i = 0; i < termsNumA.length(); i++){
        if(termsNumA[i] == '('){
            if(!exponent){
                temp.push_back(termsNumA[i]);
            }
            parenthesis = true;
        }
        else if(termsNumA[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsNumATerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsNumA[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsNumATerms.push_back(temp2);
                temp.clear();
            }
            else if(termsNumA[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsNumA[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsNumATerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsNumA[i]);
                }
            }
            else{
                temp.push_back(termsNumA[i]);
            }
        }
    }
    temp.clear();
    
    exponent = false;
    parenthesis = false;
    for(int i = 0; i < termsNumB.length(); i++){
        if(termsNumB[i] == '('){
            if(!exponent){
                temp.push_back(termsNumB[i]);
            }
            parenthesis = true;
        }
        else if(termsNumB[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsNumBTerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsNumB[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsNumBTerms.push_back(temp2);
                temp.clear();
            }
            else if(termsNumB[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsNumB[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsNumBTerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsNumB[i]);
                }
            }
            else{
                temp.push_back(termsNumB[i]);
            }
        }
    }
    temp.clear();
    
    
    vector<string>::iterator it = termsNumBTerms.begin();
    vector<string>::iterator it2 = termsNumATerms.begin();
    string result = "";
    while(it != termsNumBTerms.end()){
        bool found = false;
        while(it2 != termsNumATerms.end()){
            if(*it == *it2){
                string substring1 = *it;
                string substring3 = "";
                for(int i = 0; i<(*it).length(); i++){
                    if(!isdigit((*it)[i]) && (*it)[i] != '.' && (*it)[i] != '-'){
                        substring1 = substring1.substr(0,i);
                        substring3 = (*it).substr(i);
                        break;
                    }
                }
                string substring2 = *it2;
                for(int i = 0; i<(*it2).length(); i++){
                    if(!isdigit((*it2)[i]) && (*it2)[i] != '.' && (*it2)[i] != '-'){
                        substring2 = substring2.substr(0,i);
                        break;
                    }
                }
                if(substring1 == ""){
                    substring1 = "1";
                }
                if(substring2 == ""){
                    substring2 = "1";
                }
                float firstValue = std::stof(substring1);
                float secondValue = std::stof(substring2);
                float total = firstValue + secondValue;
                stringstream ss;
                ss << total;
                ss << substring3;
                (*it2) = ss.str();
                found = true;
                break;
            }
            it2++;
        }
        if(!found){
            stringstream ss;
            ss << result;
            ss << (*it);
            result = ss.str();
        }
        it2 = termsNumATerms.begin();
        it++;
    }
    
    while (it2 != termsNumATerms.end()) {
        std::__1::stringstream ss;
        ss << result;
        if((*it2)[0] != '-'){
            ss << "+";
        }
        ss << (*it2);
        result = ss.str();
        it2++;
    }
    
    if([self compare:"1" toString:termsDenA]){
        if(std::stof(termsDenA) != 1){
            std::__1::stringstream ss;
            ss << "(";
            ss << result;
            ss << ")/(";
            ss << termsDenA;
            ss << ")";
            result = ss.str();
        }
    }
    else{
        std::__1::stringstream ss;
        ss << "(";
        ss << result;
        ss << ")/(";
        ss << termsDenA;
        ss << ")";
        result = ss.str();
    }
    
    return result;
}

-(string)subtract:(string)a fromString: (string)b {
    //vector<string> termsA;
    //vector<string> termsB;
    
    string termsNumA = "";
    string termsDenA = "1";
    vector<string> termsNumATerms;
    string termsNumB = "";
    string termsDenB = "1";
    vector<string> termsNumBTerms;
    
    vector<char> temp;
    
    int p = 0;
    for(int i = 0; i < a.length(); i++){
        if(a[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(p == 0){
                termsNumA = temp2;
                p = 1;
            }
            else{
                termsDenA = temp2;
                p = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(a[i]);
        }
    }
    string temp2(temp.begin(), temp.end());
    if(p == 0){
        termsNumA = temp2;
        p = 1;
    }
    else{
        termsDenA = temp2;
        p = 2;
    }
    temp.clear();
    
    int q = 0;
    temp.clear();
    for(int i = 0; i < b.length(); i++){
        if(b[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(q == 0){
                termsNumB = temp2;
                q = 1;
            }
            else{
                termsDenB = temp2;
                q = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(b[i]);
        }
    }
    string temp3(temp.begin(), temp.end());
    temp2 = temp3;
    if(q == 0){
        termsNumB = temp2;
        q = 1;
    }
    else{
        termsDenB = temp2;
        q = 2;
    }
    temp.clear();
    
    if(termsNumA[0] == '('){
        termsNumA.erase(termsNumA.begin());
    }
    if (termsNumB[0] == '('){
        termsNumB.erase(termsNumB.begin());
    }
    if(termsDenA[0] == '(' ){
        termsDenA.erase(termsDenA.begin());
    }
    if(termsDenB[0] == '(' ){
        termsDenB.erase(termsDenB.begin());
    }
    if(termsNumA[termsNumA.length() -1] == ')' ){
        termsNumA.erase(termsNumA.end() - 1);
    }
    if(termsNumB[termsNumB.length() -1] == ')' ){
        termsNumB.erase(termsNumB.end() - 1);
    }
    if(termsDenA[termsDenA.length() -1] == ')' ){
        termsDenA.erase(termsDenA.end() - 1);
    }
    if(termsDenB[termsDenB.length() -1] == ')' ){
        termsDenB.erase(termsDenB.end() - 1);
    }
    
    termsNumA = [self multiply:termsNumA byString:termsDenB];
    termsNumB = [self multiply:termsNumB byString:termsDenA];
    termsDenA = [self multiply:termsDenA byString:termsDenB];
    
    bool parenthesis = false;
    bool exponent = false;
    for(int i = 0; i < termsNumA.length(); i++){
        if(termsNumA[i] == '('){
            if(!exponent){
                temp.push_back(termsNumA[i]);
            }
            parenthesis = true;
        }
        else if(termsNumA[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsNumATerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsNumA[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsNumATerms.push_back(temp2);
                temp.clear();
            }
            else if(termsNumA[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsNumA[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsNumATerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsNumA[i]);
                }
            }
            else{
                temp.push_back(termsNumA[i]);
            }
        }
    }
    temp.clear();
    exponent = false;
    parenthesis = false;
    for(int i = 0; i < termsNumB.length(); i++){
        if(termsNumB[i] == '('){
            if(!exponent){
                temp.push_back(termsNumB[i]);
            }
            parenthesis = true;
        }
        else if(termsNumB[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsNumBTerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsNumB[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsNumBTerms.push_back(temp2);
                temp.clear();
            }
            else if(termsNumB[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsNumB[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsNumBTerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsNumB[i]);
                }
            }
            else{
                temp.push_back(termsNumB[i]);
            }
        }
    }
    temp.clear();
    
    vector<string>::iterator it = termsNumBTerms.begin();
    vector<string>::iterator it2 = termsNumATerms.begin();
    string result = "";
    while(it != termsNumBTerms.end()){
        bool found = false;
        while(it2 != termsNumATerms.end()){
            if(*it == *it2){
                string substring1 = *it;
                string substring2 = *it2;
                string substring3 = "";
                for(int i = 0; i<(*it).length(); i++){
                    if(!isdigit((*it)[i]) && (*it)[i] != '.'&& (*it)[i] != '-'){
                        substring1 = substring1.substr(0,i);
                        substring2 = substring2.substr(0,(*it2).length() - (*it).length() + i);
                        substring3 = (*it).substr(i);
                        break;
                    }
                }
                if(substring1 == ""){
                    substring1 = "1";
                }
                if(substring2 == ""){
                    substring2 = "1";
                }
                float firstValue = std::stof(substring1);
                float secondValue = std::stof(substring2);
                float total = firstValue - secondValue;
                stringstream ss;
                ss << total;
                ss << substring3;
                (*it2) = ss.str();
                found = true;
                break;
            }
            it2++;
        }
        if(!found){
            stringstream ss;
            ss << result;
            ss << (*it);
            result = ss.str();
        }
        it2 = termsNumATerms.begin();
        it++;
    }
    
    while (it2 != termsNumATerms.end()) {
        std::__1::stringstream ss;
        ss << result;
        if((*it2)[0] != '-'){
            ss << "+";
        }
        ss << (*it2);
        result = ss.str();
        it2++;
    }
    
    if([self compare:"1" toString:termsDenA]){
        if(std::stof(termsDenA) != 1){
            std::__1::stringstream ss;
            ss << "(";
            ss << result;
            ss << ")/(";
            ss << termsDenA;
            ss << ")";
            result = ss.str();
        }
    }
    else{
        std::__1::stringstream ss;
        ss << "(";
        ss << result;
        ss << ")/(";
        ss << termsDenA;
        ss << ")";
        result = ss.str();
    }
    
    return result;
}

-(string)multiply:(string)a byString: (string)b{
    string termsNumA = "";
    string termsDenA = "1";
    vector<string> termsNumATerms;
    vector<string> termsDenATerms;
    string termsNumB = "";
    string termsDenB = "1";
    vector<string> termsNumBTerms;
    vector<string> termsDenBTerms;
    
    vector<char> temp;
    
    int p = 0;
    for(int i = 0; i < a.length(); i++){
        if(a[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(p == 0){
                termsNumA = temp2;
                p = 1;
            }
            else{
                termsDenA = temp2;
                p = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(a[i]);
        }
    }
    string temp2(temp.begin(), temp.end());
    if(p == 0){
        termsNumA = temp2;
        p = 1;
    }
    else{
        termsDenA = temp2;
        p = 2;
    }
    temp.clear();
    
    int q = 0;
    temp.clear();
    for(int i = 0; i < b.length(); i++){
        if(b[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(q == 0){
                termsNumB = temp2;
                q = 1;
            }
            else{
                termsDenB = temp2;
                q = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(b[i]);
        }
    }
    string temp3(temp.begin(), temp.end());
    temp2 = temp3;
    if(q == 0){
        termsNumB = temp2;
        q = 1;
    }
    else{
        termsDenB = temp2;
        q = 2;
    }
    temp.clear();
    
    if(termsDenA != "1" || termsDenB != "1"){
        std::__1::stringstream ss;
        string numTerms = [self multiply:termsNumA byString:termsNumB];
        string denTerms = [self multiply:termsDenA byString:termsDenB];
        ss << numTerms << "/" << denTerms;
        return ss.str();
    }
    
    if(termsNumA[0] == '('){
        termsNumA.erase(termsNumA.begin());
    }
    if (termsNumB[0] == '('){
        termsNumB.erase(termsNumB.begin());
    }
    if(termsDenA[0] == '(' ){
        termsDenA.erase(termsDenA.begin());
    }
    if(termsDenB[0] == '(' ){
        termsDenB.erase(termsDenB.begin());
    }
    if(termsNumA[termsNumA.length() -1] == ')' ){
        termsNumA.erase(termsNumA.end() - 1);
    }
    if(termsNumB[termsNumB.length() -1] == ')' ){
        termsNumB.erase(termsNumB.end() - 1);
    }
    if(termsDenA[termsDenA.length() -1] == ')' ){
        termsDenA.erase(termsDenA.end() - 1);
    }
    if(termsDenB[termsDenB.length() -1] == ')' ){
        termsDenB.erase(termsDenB.end() - 1);
    }
    
    bool parenthesis = false;
    bool exponent = false;
    for(int i = 0; i < termsNumA.length(); i++){
        if(termsNumA[i] == '('){
            if(!exponent){
                temp.push_back(termsNumA[i]);
            }
            parenthesis = true;
        }
        else if(termsNumA[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsNumATerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsNumA[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsNumATerms.push_back(temp2);
                temp.clear();
            }
            else if(termsNumA[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsNumA[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsNumATerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsNumA[i]);
                }
            }
            else{
                temp.push_back(termsNumA[i]);
            }
        }
    }
    temp.clear();
    

    exponent = false;
    parenthesis = false;
    for(int i = 0; i < termsDenA.length(); i++){
        if(termsDenA[i] == '('){
            if(!exponent){
                temp.push_back(termsDenA[i]);
            }
            parenthesis = true;
        }
        else if(termsDenA[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsDenATerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsDenA[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsDenATerms.push_back(temp2);
                temp.clear();
            }
            else if(termsDenA[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsDenA[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsDenATerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsDenA[i]);
                }
            }
            else{
                temp.push_back(termsDenA[i]);
            }
        }
    }
    temp.clear();
    
    exponent = false;
    parenthesis = false;
    for(int i = 0; i < termsNumB.length(); i++){
        if(termsNumB[i] == '('){
            if(!exponent){
                temp.push_back(termsNumB[i]);
            }
            parenthesis = true;
        }
        else if(termsNumB[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsNumBTerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsNumB[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsNumBTerms.push_back(temp2);
                temp.clear();
            }
            else if(termsNumB[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsNumB[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsNumBTerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsNumB[i]);
                }
            }
            else{
                temp.push_back(termsNumB[i]);
            }
        }
    }
    temp.clear();
    
    exponent = false;
    parenthesis = false;
    for(int i = 0; i < termsDenB.length(); i++){
        if(termsDenB[i] == '('){
            if(!exponent){
                temp.push_back(termsDenB[i]);
            }
            parenthesis = true;
        }
        else if(termsDenB[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsDenBTerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsDenB[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsDenBTerms.push_back(temp2);
                temp.clear();
            }
            else if(termsDenB[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsDenB[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsDenBTerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsDenB[i]);
                }
            }
            else{
                temp.push_back(termsDenB[i]);
            }
        }
    }
    temp.clear();
    
    vector<string>::iterator it = termsNumATerms.begin();
    vector<string>::iterator it2 = termsNumBTerms.begin();
    string result = "";
    while(it != termsNumATerms.end()){
        while(it2 != termsNumBTerms.end()){
            stringstream ss;
            
            string substring1 = *it;
            string substring2 = *it2;
            string substring3 = "";
            string substring4 = "";
            for(int i = 0; i<(*it).length(); i++){
                if(!isdigit((*it)[i]) && (*it)[i] != '.' && (*it)[i] != '-'){
                    substring1 = substring1.substr(0,i);
                    substring3 = (*it).substr(i);
                    break;
                }
            }
            
            for(int i = 0; i<(*it2).length(); i++){
                if(!isdigit((*it2)[i]) && (*it2)[i] != '.' && (*it2)[i] != '-'){
                    substring2 = substring2.substr(0,i);
                    substring4 = (*it2).substr(i);
                    break;
                }
            }
            if(substring1 == ""){
                substring1 = "1";
            }
            if(substring2 == ""){
                substring2 = "1";
            }
            float product = std::stof(substring1) * std::stof(substring2);
            ss << product;
            
            vector<vector<string>> terms1;
            bool parenthesis = false;
            bool exponent = false;
            int j = -1;
            for(int i = 0; i<substring3.length(); i++){
                if(substring3[i] == '('){
                    if(!exponent){
                        parenthesis = true;
                        j++;
                        //terms1[j][0] = "(";
                        terms1[j][1] = "";
                    }
                }
                else if(substring3[i] == ')'){
                    stringstream cc;
                    cc << terms1[j][0];
                    //cc << ")";
                    terms1[j][0] = cc.str();
                    parenthesis = false;
                    exponent = !exponent;
                }
                if(!parenthesis){
                    if(isalpha(substring3[i])){
                        if(j!= -1){
                            if(terms1[j][1] ==""){
                                terms1[j][1] = "1";
                            }
                        }
                        j++;
                        stringstream cc;
                        cc << substring3[i];
                        terms1[j][0] = cc.str();
                        terms1[j][1] = "";
                    }
                    else if(isdigit(substring3[i]) || substring3[i] == '/'){
                        stringstream cc;
                        cc << terms1[j][1];
                        cc << substring3[i];
                        terms1[j][1] = cc.str();
                    }
                }
                else{
                    stringstream cc;
                    cc << terms1[j][0];
                    cc << substring3[i];
                    terms1[j][0] = cc.str();
                }
            }
            
            if(j!= -1){
                if(terms1[j][1] ==""){
                    terms1[j][1] = "1";
                }
            }
            
            vector<vector<string>> terms2;
            int k = -1;
            exponent = false;
            exponent = true;
            for(int i = 0; i<substring4.length(); i++){
                if(substring4[i] == '('){
                    if(!exponent){
                        parenthesis = true;
                        j++;
                       // terms2[k][0] = "(";
                        terms2[k][1] = "";
                    }
                }
                else if(substring4[i] == ')'){
                    stringstream cc;
                    cc << terms2[k][0];
                    //cc << ")";
                    terms2[k][0] = cc.str();
                    parenthesis = false;
                    exponent = !exponent;
                }
                if(!parenthesis){
                    if(isalpha(substring4[i])){
                        if(k!= -1){
                            if(terms2[k][1] ==""){
                                terms2[k][1] = "1";
                            }
                        }
                        k++;
                        stringstream cc;
                        cc << substring4[i];
                        terms2[k][0] = cc.str();
                        terms2[k][1] = "";
                    }
                    else if(isdigit(substring4[i]) || substring4[i] == '/'){
                        stringstream cc;
                        cc << terms2[k][1];
                        cc << substring4[i];
                        terms2[k][1] = cc.str();
                    }
                }
                else{
                    stringstream cc;
                    cc << terms2[k][0];
                    cc << substring4[i];
                    terms2[k][0] = cc.str();
                }
            }
            
            if(k!= -1){
                if(terms1[k][1] ==""){
                    terms1[k][1] = "1";
                }
            }
            
            for(int i = 0; i<=j;i++){
                bool found = false;
                for(int m = 0; m<=k; m++){
                    if(terms1[i][0] == terms2[m][0]){
                        found = true;
                        stringstream cc;
                        cc << (std::stof(terms1[i][1]) + std::stof(terms2[m][1]));
                        terms2[m][1] = cc.str();
                        ss << "(";
                        ss << terms2[m][0];
                        ss << ")^(";
                        ss << terms2[m][1];
                        ss << ")";
                        break;
                    }
                }
                if(!found){
                    ss << "(";
                    ss << terms1[i][0];
                    if(terms1[i][1] != "1"){
                        ss << ")^(";
                        ss << terms1[i][1];
                        ss << ")";
                    }
                }
                found = false;
            }
            if(result != ""){
                result = result + ss.str();
            }
            else{
                result = ss.str();
            }
            it2++;
        }
        it2 = termsNumBTerms.begin();
        it++;
    }
    
    return result;
}

-(string)divide:(string)a byString: (string)b {
    string termsNumA = "";
    string termsDenA = "1";
    string termsNumB = "";
    string termsDenB = "1";
    
    vector<char> temp;
    
    int q = 0;
    temp.clear();
    for(int i = 0; i < b.length(); i++){
        if(b[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(q == 0){
                termsNumB = temp2;
                q = 1;
            }
            else{
                termsDenB = temp2;
                q = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(b[i]);
        }
    }
    temp.clear();
    
    stringstream ss;
    ss << termsDenB;
    ss << "/";
    ss << termsNumB;
    string c = ss.str();
    
    return [self multiply:a byString:c];
}

-(string)exponentiate:(string)a toString: (string)b{
    string termsNumA = "";
    string termsDenA = "1";
    string termsNumB = "";
    string termsDenB = "1";
    
    vector<char> temp;
    
    int p = 0;
    for(int i = 0; i < a.length(); i++){
        if(a[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(p == 0){
                termsNumA = temp2;
                p = 1;
            }
            else{
                termsDenA = temp2;
                p = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(a[i]);
        }
    }
    int q = 0;
    temp.clear();
    for(int i = 0; i < b.length(); i++){
        if(b[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(q == 0){
                termsNumB = temp2;
                q = 1;
            }
            else{
                termsDenB = temp2;
                q = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(b[i]);
        }
    }
    temp.clear();
    
    if(termsNumA[0] == '('){
        termsNumA.erase(termsNumA.begin());
    }
    if (termsNumB[0] == '('){
        termsNumB.erase(termsNumB.begin());
    }
    if(termsDenA[0] == '(' ){
        termsDenA.erase(termsDenA.begin());
    }
    if(termsDenB[0] == '(' ){
        termsDenB.erase(termsDenB.begin());
    }
    if(termsNumA[termsNumA.length() -1] == ')' ){
        termsNumA.erase(termsNumA.end() - 1);
    }
    if(termsNumB[termsNumB.length() -1] == ')' ){
        termsNumB.erase(termsNumB.end() - 1);
    }
    if(termsDenA[termsDenA.length() -1] == ')' ){
        termsDenA.erase(termsDenA.end() - 1);
    }
    if(termsDenB[termsDenB.length() -1] == ')' ){
        termsDenB.erase(termsDenB.end() - 1);
    }
    
    if(termsDenA != "1") {
        return [self divide:[self exponentiate:termsNumA toString:b] byString:[self exponentiate:termsDenA toString:b]];
        //return (termsNumA^b) / (termsDenA^b);
    }
    if(termsDenB == "1"){
        if(is_digits(termsNumA) && is_digits(termsNumB)){
            if(termsNumA[0] == '('){
                termsNumA.erase(termsNumA.begin());
            }
            if (termsNumB[0] == '('){
                termsNumB.erase(termsNumB.begin());
            }
            if(termsNumA[termsNumA.length() -1] == ')' ){
                termsNumA.erase(termsNumA.end() - 1);
            }
            if(termsNumB[termsNumB.length() -1] == ')' ){
                termsNumB.erase(termsNumB.end() - 1);
            }
            
            std::__1::stringstream ss;
            float firstValue = std::stof(termsNumA);
            float secondValue = std::stof(termsNumB);
            ss << pow(firstValue,secondValue);
            return  ss.str();
        }
        if(ceilf(std::stof(termsNumB)) == std::stof(termsNumB)) {
            string c = a;
            for(int i = 1; i<std::stoi(b);i++){
                c = [self multiply:c byString:a];
            }
            return c;
        }
        if(termsNumB[0] == '-'){
            if(ceilf(std::stof(b)) == std::stof(b)){
                string c = [self exponentiate:a toString:b.substr(1)];
                c = [self divide:"1" byString:c];
                return c;
            }
            else{
                std::__1::stringstream ss;
                ss << "1/";
                ss << "(";
                ss << a;
                ss << ")^(";
                ss << b;
                ss << ")";
                return ss.str();
            }
        }
        std::__1::stringstream ss;
        ss << a;
        ss << "^(";
        ss << b;
        ss << ")";
        return  ss.str();
    }
    if(b[0] == '-'){
        std::__1::stringstream ss;
        ss << "1/";
        ss << "(";
        ss << a;
        ss << ")^(";
        ss << b;
        ss << ")";
        return ss.str();
    }
    std::__1::stringstream ss;
    ss << "(";
    ss << a;
    ss << ")";
    ss << "^(";
    ss << b;
    ss << ")";
    return  ss.str();
}

-(string)simplifyString: (string)a {
    //find smallest term, split into array (vector<Vector>)
    string termsNumA = "";
    string termsDenA = "1";
    vector<string> termsNumATerms;
    vector<string> termsDenATerms;
    
    vector<char> temp;
    
    int p = 0;
    for(int i = 0; i < a.length(); i++){
        if(a[i] == '/'){
            string temp2(temp.begin(), temp.end());
            if(p == 0){
                termsNumA = temp2;
                p = 1;
            }
            else{
                termsDenA = temp2;
                p = 2;
            }
            temp.clear();
        }
        else{
            temp.push_back(a[i]);
        }
    }
    string temp2(temp.begin(), temp.end());
    if(p == 0){
        termsNumA = temp2;
        p = 1;
    }
    else{
        termsDenA = temp2;
        p = 2;
    }
    temp.clear();
    
    if(termsDenA != "1"){
        return a;
    }
    
    if(termsNumA[0] == '('){
        termsNumA.erase(termsNumA.begin());
    }
    if(termsDenA[0] == '(' ){
        termsDenA.erase(termsDenA.begin());
    }
    if(termsNumA[termsNumA.length() -1] == ')' ){
        termsNumA.erase(termsNumA.end() - 1);
    }
    if(termsDenA[termsDenA.length() -1] == ')' ){
        termsDenA.erase(termsDenA.end() - 1);
    }
    
    bool parenthesis = false;
    bool exponent = false;
    for(int i = 0; i < termsNumA.length(); i++){
        if(termsNumA[i] == '('){
            if(!exponent){
                temp.push_back(termsNumA[i]);
            }
            parenthesis = true;
        }
        else if(termsNumA[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsNumATerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsNumA[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsNumATerms.push_back(temp2);
                temp.clear();
            }
            else if(termsNumA[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsNumA[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsNumATerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsNumA[i]);
                }
            }
            else{
                temp.push_back(termsNumA[i]);
            }
        }
    }
    temp.clear();
    
    exponent = false;
    parenthesis = false;
    for(int i = 0; i < termsDenA.length(); i++){
        if(termsDenA[i] == '('){
            if(!exponent){
                temp.push_back(termsDenA[i]);
            }
            parenthesis = true;
        }
        else if(termsDenA[i] == ')'){
            string temp2(temp.begin(), temp.end());
            termsDenATerms.push_back(temp2);
            temp.clear();
            parenthesis = false;
            exponent = !exponent;
        }
        else if(parenthesis || exponent) {
            if(termsDenA[i] == '+'){
                string temp2(temp.begin(), temp.end());
                termsDenATerms.push_back(temp2);
                temp.clear();
            }
            else if(termsDenA[i] == '-'){
                if(temp.size() == 0){
                    temp.push_back(termsDenA[i]);
                }
                else{
                    string temp2(temp.begin(), temp.end());
                    termsDenATerms.push_back(temp2);
                    temp.clear();
                    temp.push_back(termsDenA[i]);
                }
            }
            else{
                temp.push_back(termsDenA[i]);
            }
        }
    }
    temp.clear();
    
    vector<string>::iterator it1 = termsNumATerms.begin();
    vector<string>::iterator it2 = termsDenATerms.begin();
    int length = 100;
    int position = -1;
    int numOrDen = -1;
    int i = 0;
    while(it1 != termsNumATerms.end()){
        if((*it1).length() < length){
            length = (int)(*it1).length();
            numOrDen = 0;
            position = i;
        }
        it1++;
        i++;
    }
    i = 0;
    while(it2 != termsDenATerms.end()){
        if((*it2).length() < length){
            length = (int)(*it2).length();
            numOrDen = 1;
            position = i;
        }
        it2++;
        i++;
    }
    
    vector<string>::iterator it3 = termsNumATerms.begin();
    if(numOrDen == 1){
        it3 = termsNumATerms.begin() + position;
    }
    else if(numOrDen == 0){
        it3 = termsDenATerms.begin() + position;
    }
    
    it1 = it3;
    it2 = termsNumATerms.begin();
    
    string substring1 = *it1;
    string substring3 = "";
    for(int i = 0; i<(*it1).length(); i++){
        if(!isdigit((*it1)[i]) && (*it1)[i] != '.' && (*it1)[i] != '-'){
            substring1 = substring1.substr(0,i);
            substring3 = (*it1).substr(i);
            break;
        }
    }
    if(substring1 == ""){
        substring1 = "1";
    }
    
    vector<vector<string>> terms1;
    parenthesis = false;
    exponent = false;
    int j = -1;
    for(int i = 0; i<substring3.length(); i++){
        if(substring3[i] == '('){
            if(!exponent){
                parenthesis = true;
                j++;
                //terms1[j][0] = "(";
                terms1[j][1] = "";
            }
        }
        else if(substring3[i] == ')'){
            stringstream cc;
            cc << terms1[j][0];
            //cc << ")";
            terms1[j][0] = cc.str();
            parenthesis = false;
            exponent = !exponent;
        }
        if(!parenthesis){
            if(isalpha(substring3[i])){
                if(j!= -1){
                    if(terms1[j][1] ==""){
                        terms1[j][1] = "1";
                    }
                }
                j++;
                stringstream cc;
                cc << substring3[i];
                terms1[j][0] = cc.str();
                terms1[j][1] = "";
            }
            else if(isdigit(substring3[i]) || substring3[i] == '/'){
                stringstream cc;
                cc << terms1[j][1];
                cc << substring3[i];
                terms1[j][1] = cc.str();
            }
        }
        else{
            stringstream cc;
            cc << terms1[j][0];
            cc << substring3[i];
            terms1[j][0] = cc.str();
        }
    }
    
    if(j!= -1){
        if(terms1[j][1] ==""){
            terms1[j][1] = "1";
        }
    }
    
    int m = 0;
    while(it2 != termsNumATerms.end()){
        
        string substring2 = *it2;
        string substring4 = "";
        for(int i = 0; i<(*it2).length(); i++){
            if(!isdigit((*it2)[i]) && (*it2)[i] != '.' && (*it2)[i] != '-'){
                substring2 = substring2.substr(0,i);
                substring4 = (*it2).substr(i);
                break;
            }
        }
        if(substring2 == ""){
            substring2 = "1";
        }
        
        if(numOrDen == 0 && position == m){
            continue;
        }
        
        vector<vector<string>> terms2;
        int k = -1;
        exponent = false;
        exponent = true;
        for(int i = 0; i<substring4.length(); i++){
            if(substring4[i] == '('){
                if(!exponent){
                    parenthesis = true;
                    j++;
                    // terms2[k][0] = "(";
                    terms2[k][1] = "";
                }
            }
            else if(substring4[i] == ')'){
                stringstream cc;
                cc << terms2[k][0];
                //cc << ")";
                terms2[k][0] = cc.str();
                parenthesis = false;
                exponent = !exponent;
            }
            if(!parenthesis){
                if(isalpha(substring4[i])){
                    if(k!= -1){
                        if(terms2[k][1] ==""){
                            terms2[k][1] = "1";
                        }
                    }
                    k++;
                    stringstream cc;
                    cc << substring4[i];
                    terms2[k][0] = cc.str();
                    terms2[k][1] = "";
                }
                else if(isdigit(substring4[i]) || substring4[i] == '/'){
                    stringstream cc;
                    cc << terms2[k][1];
                    cc << substring4[i];
                    terms2[k][1] = cc.str();
                }
            }
            else{
                stringstream cc;
                cc << terms2[k][0];
                cc << substring4[i];
                terms2[k][0] = cc.str();
            }
        }
        
        
        
        if(k!= -1){
            if(terms1[k][1] ==""){
                terms1[k][1] = "1";
            }
        }
        
        m++;
        it2++;
    }
    
    it2 = termsDenATerms.begin();
    m= 0;
    while(it2 != termsDenATerms.end()){
        
        string substring2 = *it2;
        string substring4 = "";
        for(int i = 0; i<(*it2).length(); i++){
            if(!isdigit((*it2)[i]) && (*it2)[i] != '.' && (*it2)[i] != '-'){
                substring2 = substring2.substr(0,i);
                substring4 = (*it2).substr(i);
                break;
            }
        }
        if(substring2 == ""){
            substring2 = "1";
        }
        
        vector<vector<string>> terms2;
        int k = -1;
        exponent = false;
        exponent = true;
        for(int i = 0; i<substring4.length(); i++){
            if(substring4[i] == '('){
                if(!exponent){
                    parenthesis = true;
                    j++;
                    // terms2[k][0] = "(";
                    terms2[k][1] = "";
                }
            }
            else if(substring4[i] == ')'){
                stringstream cc;
                cc << terms2[k][0];
                //cc << ")";
                terms2[k][0] = cc.str();
                parenthesis = false;
                exponent = !exponent;
            }
            if(!parenthesis){
                if(isalpha(substring4[i])){
                    if(k!= -1){
                        if(terms2[k][1] ==""){
                            terms2[k][1] = "1";
                        }
                    }
                    k++;
                    stringstream cc;
                    cc << substring4[i];
                    terms2[k][0] = cc.str();
                    terms2[k][1] = "";
                }
                else if(isdigit(substring4[i]) || substring4[i] == '/'){
                    stringstream cc;
                    cc << terms2[k][1];
                    cc << substring4[i];
                    terms2[k][1] = cc.str();
                }
            }
            else{
                stringstream cc;
                cc << terms2[k][0];
                cc << substring4[i];
                terms2[k][0] = cc.str();
            }
        }
        
        if(k!= -1){
            if(terms1[k][1] ==""){
                terms1[k][1] = "1";
            }
        }
        
        if(numOrDen == 1 && position == m){
            continue;
        }
        m++;
        it2++;
    }
    
    
   
    
    return "";
}

bool isInteger(const std::string &str){
    return str.find_first_not_of("0123456789.()") == std::string::npos;
}

bool is_digits(const std::string &str)
{
    return str.find_first_not_of("0123456789.()") == std::string::npos;
}



@end
