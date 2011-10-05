/* This example will get some basic information about the
   SPI Flash.                                                     */

#include <SPIFlash.h>

#define SCK 2
#define MOSI 3
#define SS 4
#define MISO 5

SPIFlash flash(SCK, MISO, MOSI, SS);
uint8_t buffer[256];
uint32_t results;

void setup(void) 
{
  Serial.begin(9600);
  Serial.println("Hello!");

  flash.begin();
  
  Serial.println("Reading Unique 64-bit ID");
  flash.GetUniqueID(buffer);
  flash.PrintHex(buffer, 8);
  
  Serial.println("Erasing Sector 0 (Page 0..15)");
  results = flash.EraseSector(0);
  if (!results)
  {
    Serial.println("Danger, Will Robinson!");
    // Just hang out here for a while
    while(1);
  }
  
  Serial.println("Writing some data across a page boundary");
  buffer[0] = 0xDE;
  buffer[1] = 0xAD;
  buffer[2] = 0xBE;
  buffer[3] = 0xEF;
  buffer[4] = 0xC0;
  buffer[5] = 0xDE;
  buffer[6] = 0xBA;
  buffer[7] = 0xBE;
  Serial.print("--> ");
  flash.PrintHex(buffer, 8);
  // This should write four bytes at the end of page 0
  // and automagically wrap to the next four bytes over
  // to page 1
  results  = flash.Write(252, buffer, 8);
  // Make sure we really wrote 8 bytes of data
  if (results != 8)
  {
    Serial.println("HTTP/1.1 Error 301: Moved Permanently - Your data has migrated south");
    // Just hang out here for a while
    while(1);
  }

  Serial.println("Reading page 0 to 1");
  uint8_t page, row;
  for (page=0;page<2;page++)
  {
    Serial.println("00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  Char Value");
    Serial.println("===============================================  ================");
    results = flash.ReadBuffer (page*256, buffer, 256);
    // ToDo: Check for errors!
    for (row=0;row<16;row++)
    {
      // Sigh ... can't easily do address because of no decent printf :(
      flash.PrintHexChar(buffer+row*16, 16);
    }
    Serial.println("");
  }  
}

void loop(void) 
{
}

