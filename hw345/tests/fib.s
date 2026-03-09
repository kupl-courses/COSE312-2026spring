/* Fibonacci number */
{
  int x;
  int y;
  int n;
  int i;
  x = 0;
  y = 1;
  i = 0;
  read (n); 
  while (i < n) {
    x = y;
    y = x + y;
    i++;
  }
  print (y);
}
