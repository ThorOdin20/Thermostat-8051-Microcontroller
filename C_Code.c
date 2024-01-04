//The code in C still needs some adjustments, but the assembly file works perfectly.

#include <reg51.h>

sbit D7 = P1^7;
sbit START = P2^3;
sbit EOC = P2^4;
sbit R_W = P2^0;
sbit RS = P2^1;
sbit EN = P2^2;
sbit CLK  = P3^0;
sbit CMP = P3^1;
sbit BUTP = P3^2;
sbit BUTM = P3^3;

void display_temperature();
void command_LCD(unsigned char x);
void display_LCD(unsigned char x);
void ready_LCD();
void ready_conversion()	;
void display_string(unsigned char *x);
void compare();

void timer1() interrupt 3{
	CLK =~ CLK;
}

void btn1() interrupt 0{

}

void btn0() interrupt 2{

}

	
code unsigned char str[] = {"Temp is:"};
code unsigned char str2[] = {"Temp want:"};
unsigned char r0, r3, r4, r5;

void main() {
	
	  command_LCD(0x38);    
    command_LCD(0x0E);    
    command_LCD(0x01);    

    IE = 0x8D;
    TCON = 0x05;
    r0 = 44;
	
		TMOD = 0x20;    
    TL1 = -92;     
    TH1 = TL1;     
    TR1 = 1;       

    command_LCD(0xC0);    

    int i = 0;
    while (str2[i] != '\0') {
        display_LCD(str2[i]);
        i++;
    }

    command_LCD(0x80);    

    char str[] = "Temperature: ";
    i = 0;
    while (str[i] != '\0') {
        display_LCD(str[i]);
        i++;
    }

    while (1) {
        display_temperature();
        command(0x10);
        command(0x10);
        command(0x10);
        command(0x10);
    }
}

void display_temperature(){
    ready_conversion();
    
    // tens
    unsigned char A, B;
    A = P0;
    B = 0x33;
    A = A / B;
    A = A + 0x30;
    r3 = A;
    display(r3);
    
    // units
    A = B;
    B = 0x05;
    A = A / B;
    A = A + 0x30;
    r4 = A;
    display(r4);
    
    // first decimal
    A = '.';
    display(A);
    A = B;
    B = 0x03;
    A = A / B;
    if (A == 0) {
        A = '0';
    } else {
        A = '5';
    }
    r5 = A;
    display(r5);
    
    compare();
}

void command_LCD(unsigned char x){
	ready_LCD();
	P1 = x;
	RS = 0;
	R_W = 0;
  EN = 1;
	{}{}
	EN = 0;
}

void display_LCD(unsigned char x) {
	ready_LCD();
	P1 = x;
	RS = 1;
	R_W = 0;
	EN = 1;
	{}{}
	EN = 0;
}

void ready_LCD(){
	EN = 0;
	D7 = 1;
	RS  = 0;
	R_W = 1;
	while(D7==0){
	EN = 0;
	{}{}
	EN = 1;}
	EN = 0;
}

void ready_conversion(){
	EOC = 1;
	{}
	START = 1;
	{}{}
	START = 0;
	while(EOC!=0){}
}

void display_string(unsigned char *x){
	while(*x!=0){
		display_LCD(*x);
		x++;
	}
}

void compare(){

}

	