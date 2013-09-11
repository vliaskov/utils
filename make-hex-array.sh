#!/bin/bash
# Use to format a hex code dump, and put it in a C-program data array.
# run the program in gdb, break in main, and type x/i to dissassemble the code

formatted=`echo $1 | sed 's/ \+/,0x/g' | sed 's/<//g' | sed 's/>//g'`
echo $formatted

cat > /tmp/test.c <<EOF &&
char foo[]={0x$formatted};
int main(void) {
  return 0;
}
EOF

gcc -g -o /tmp/test /tmp/test.c
#TODO: add gdb ./test -batch command to add breakpoint, run, and dump hex output
