#include <stdio.h>
#include <stdlib.h>
#include <string.h>	
extern "C" int decode(char *pic, int scan_line_no, char*text);

int main(int argc, char *argv[])
{
	if(argc != 2)
	{
		printf("Pass only the name of bmp file and scanned line!\n");
		return 0;
	}
	char text[50]={' '};
	char *name = argv[1];
    FILE *file;
	char *pic;
  	
  	int scan_line = 25;;
	unsigned long fileLenght;
	
	
	file = fopen(name, "rb");

	if (!file)
	{
		fprintf(stderr, "Cannot open the file %s\n", name);
		return 1;
	}
	fseek(file, 0, SEEK_END);
	fileLenght=ftell(file);
	fseek(file, 0, SEEK_SET);
	pic=(char *)malloc(fileLenght+1);
	if (!pic)
	{
		fprintf(stderr, "Memory crashed!!!\n");
        fclose(file);
		return 2;
	}

	
	fread(pic, fileLenght, 1, file);
	fclose(file);

	 char* bmp = pic + 54; 
		int l = decode(bmp, scan_line, text);
		if(strlen(text)<2)
		printf("Decode failed!\n");
		else
		printf("Decoded text: %s \n ", text);
        free(pic);

	return 0;
}
