# The Elevate Program

This program calculates the minimum sum of all the floors that an elevator's passengers whould have to walk to get their provided destination, given the maximum number of stops the elevator can make, when the elevator and all the passengers are at floor 0. The program also finds the last stop that resulted in that minimum cost or the whole path of stops depending on the caclulation mode that was used.

The main elevate program must be provided an input file with the number of passengers, their destinations and the maximum number of stops for the elevator and will print the appropriate calculation data to stdout.

The secondary mcp program is an mcp server that models can interact with, through stdio, to use the elevate tool.

# Build

The main elevate program can be compiled and linked with the commands:

```bash
gcc -Os -c -Wall -Wextra -Werror -pedantic recurse.c
gcc -Os -c -Wall -Wextra -Werror -pedantic brute.c
gcc -Os -c -Wall -Wextra -Werror -pedantic memoize.c
gcc -Os -c -Wall -Wextra -Werror -pedantic dp.c
gcc -Os -c -Wall -Wextra -Werror -pedantic elevate.c
gcc -Os -o elevate recurse.o brute.o memoize.o dp.o elevate.o
```

The mcp program can be compiled and linked with the commands:

```bash
gcc -Os -c -Wall -Wextra -Werror -pedantic recurse.c
gcc -Os -c -Wall -Wextra -Werror -pedantic brute.c
gcc -Os -c -Wall -Wextra -Werror -pedantic memoize.c
gcc -Os -c -Wall -Wextra -Werror -pedantic dp.c
gcc -Os -c -Wall -Wextra -Werror -pedantic mcp.c
gcc -Os -o mcp recurse.o brute.o memoize.o dp.o mcp.o
```

The provided Makefile can also be used to compile and link both programs.

**The header file elevate.h must be included in all compilations.**

# Main Usage

```
$ ./elevate <input-file>
```

The above command calculates the minimum cost with the default mode of dynamic programming.

The format of the input file should be as the example below:

```
$ cat input1.txt
5 2
11 2 7 13 7
```

On the first line the number of passengers (5) and the maximum number of stops (2) are provided, delimited with a space.<br>
On the second line the destinations of the passengers are provided delimited with a space.<br>
The amount of numbers provided as destinations on the second line should much the number of passengers that was provided, otherwise the program will exit with exit code 1.

### There are 4 calculation modes that can be used in the program, their use can be specified with the --mode argument:

```
$ ./elevate <input-file> --mode=<selected-mode>
```

## Recurse:

This calculation method uses a recursive formula to find the minimum cost using simple recursion.<br>
$fw(a,b)$ is the sum of the number of floors all of the passengers with destinations $a \le destination \le b$ whould have to walk , $0 \le a < b$.<br>Then, the cost of not making any stops and just letting all the passengers walk is $fw(0,\infty)$.<br>
When one stop is made at floor j then the cost is $fw(0,j) + fw(j,\infty)$<br>
Thus, the minimum cost when making one stop is (a stop could be made at floor 0):
$$\min\limits_{j=0}^{numFloors} \{fw(0, j) + fw(j, \infty)\}$$
where $numFloors$ is the topmost stop in the provided destinations array.<br>
When two stops can be made the minimum cost is:
$$\min_{0 \le k \le j \le numFloors} \{fw(0, k) + fw(k,j) + fw(j, \infty)\}$$
which is equal to:
$$\min_{0 \le k \le j \le numFloors} \{fw(0, k) + fw(k,\infty) - fw(k,\infty) + fw(k,j) + fw(j, \infty)\}$$
This way, in order to find the minimum cost when the maximum number of stops the elevator can make is the provided $numStops$ we use the recursive function:

```math
M_{i,j} =
\begin{cases}
fw(0,\infty)  & \text{, } i=0 \\
\min\limits_{k=0}^{j} \{M_{i-1,k} - fw(k, \infty) + fw(k, j) + fw(j, \infty)\}  & \text{, } 1 \le i \le numStops
\end{cases} \text{ , where } 0 \le j \le numFloors
```

This function gives us the minimum cost of making a stop at floor j, when making i stops are made in total<br>
So in order to find the minimum cost when making numStops max stops we use:

```math
MinCost = \min\limits_{j=0}^{numFloors}\{M_{numStops,j}\}
```

Example:

```
$ ./elevate input1.txt --mode=recurse
Last stop at floor: 11
The minimum cost is: 4
```

## Brute:

This calculation method generated every possible stop path the elevator can take (assuming it only goes upwards from floor 0) and find the minimum of the costs that every path would have. This way the full path is also found by this method.

Example:

```
$ ./elevate input1.txt --mode=brute
Lift stops are: 7 11
The minimum cost is: 4
```

## Memoize:

This method uses the same recursive formula as recurse but uses a 2D array to store the results of the calculations it has already performed so that they are not performed again if they are needed.

Example:

```
$ ./elevate input1.txt --mode=memoize
Last stop at floor: 11
The minimum cost is: 4
```

## Dynamic Programming (dp):

This method uses the same recursive formula but works on it iteratively from the bottom up. Using a secondary array this method also finds the full stop path that results in the minimum cost.

**This is the default method.**

Example:

```
$ ./elevate input1.txt --mode=dp
Lift stops are: 7 13
The minimum cost is: 4
```

This method also has a debug mode that displays a 2D grid of numbers $(i,j)$.

```math
0 ≤ i ≤ numStops,
0 ≤ j ≤ numFloors
```

Where numStops is the maximum number of stops and numFloors is the topmost destination.
<br>
Each number is the minimum calculated cost of making the last stop at floor j when i stop have been made in total.

Example:

```
$ ./elevate input1.txt --mode=dp --debug
40      40      40      40      40      40      40      40      40      40      40      40      40      40
40      35      30      27      24      20      16      12      12      12      12      12      14      16
40      35      30      26      22      18      14      10      10      8       6       4       4       4
Lift stops are: 7 11
The minimum cost is: 4
```

The minimum cost is the smallest number of the last row (where i = numStops).

# MCP

The mcp program can respond to mcp messages and provide the use of the elevate tool to models through stdio.

The main json parser, although not required for this implementation, was designed to be able to handle any type of json input and parse it using tail recursion. It stores only the data that are required for the implementation. These data are given to the parser function through a specific graph data structure. This way the parser is dynamic and can work for any type of json just by changing the predetermined graph that is provided to it.
The structure is prebuilt and given to the parser according to the fields the parser needs to check for the implementation. Every node of the graph has a key that corresponds that to its entry key inside the json object (in some cases like the root object or array elements the key is ignored). Every node can have multiple children and has one parrent (expept the root).<br>
The graph essentialy repressents a tree where every node can have a different number of children and every child also points to its parent. To achieve this, in every node a value void pointer is kept that could point to another node as its first child or to a primitive data type. Every node also points to its next sibling.

# Sources

MCP error messages: https://www.mcpevals.io/blog/mcp-error-codes
