/* Fibonacci number */
{
  int x;
  int y;
  int n;
  int i;
  int[10] fib;
  x = 0;
  y = 1;
  i = 0;
  n = 10;
  while (i < n) {
    x = y;
    y = x + y;
    fib[i] = y;
    i++;
  }
  i = 0;
  while (i < n) {
    print (fib[i]);
    i++;
  }
}
