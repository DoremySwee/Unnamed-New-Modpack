#reloadable
#priority 1000000030
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;

static TEST as bool = false;
static TEST2 as bool = true;
function hung(graph as bool[][])as int[]{
    //graph [i][j] == Whether LEFT[i] and RIGHT[j] has a edge connecting them
    var m = graph.length;
    var n = graph[0].length;
    var matching as int[] = intArrayOf(m, -1 as int);
    var mInverse as int[] = intArrayOf(n, -1 as int);
    var LR as int[][] = [] as int[][];  //TODO: [LIST-ARRAY] [20240331]
    //init
    for i in 0 to m{
        var t as int[] = [] as int[];
        for j in 0 to n{
            if(graph[i][j]) t = t + j;
        }
        LR = LR + t;
    }

    //alg
    for i in 0 to m{
        //The algorithm is sort of greedy algorithm. But it allows adjusts in later decisions.
        //It use BFS/DFS to search for the adjust.

        //bfs on related nodes on RHS for unoccupied nodes
        //Directly linked nodes are obviously related
        //If a related node is occupied, the occupier's related nodes are also related - a shift can be formed on the path
        //The path is wanted, to form the shift

        var pathRecorder = intArrayOf(m, -1 as int); //It records which LHS node evoke the RHS nodes, to avoid repeated search and record the path.
        var queue as int[] = [] as int[]; //TODO: [LIST-ARRAY] [20240331]
        
        for j in LR[i]{
            queue += j;
            pathRecorder[j] = i;
        }
        if(TEST){
            print("New I = "~i);
            print("Printing current matching");
            for j in matching{print(j);}
            print("queue.length = "~queue.length);
        }
        var k = 0;
        while (k<queue.length){
            var j = queue[k];
            if(TEST){
                print("   New j = "~j);
                print("   mInverse[j] = "~mInverse[j]);
            }
            if(mInverse[j]>=0){
                for t in LR[mInverse[j]]{
                    if(pathRecorder[t]<0){
                        queue += t;
                        pathRecorder[t] = mInverse[j];
                    }
                }
            }
            else{ //mInverse[j]<0
                //Then j is unoccupied, we do the end up.
                while(j>=0){
                    var R = j;
                    var L = pathRecorder[j];
                    j = matching[L];
                    matching[L] = R;
                    mInverse[R] = L;
                }
                break;
            }
            k+=1;
        }
    }
    return matching;
}
function hungEdge(m as int, n as int, edges as int[][], startFromOne as bool = false)as int[]{
    var graph as bool[][] = [] as bool[][]; //TODO: [LIST-ARRAY] [20240331]
    for i in 0 to m{
        var t as bool[] = [] as bool[];
        for j in 0 to n{
            t += false;
        }
        graph += t;
    }
    var t = startFromOne? 1: 0;
    for e in edges{
        graph[e[0]-t][e[1]-t]=true;
    }
    return hung(graph);
}
if(TEST){
    print("Test Hungarian Algorithm!");
    var edges = [[1,2],[1,4],[1,7],[2,1],[2,6],[3,2],[3,3],[4,2],[4,5],[4,7],[5,3],[6,3],[7,3],[7,5]] as int[][];
    var output = hungEdge(7,7,edges,true);
    print("Ans");
    for i in output{
        print(i);
    }
}

function testShapeless(requirements as IIngredient[], inputs as IItemStack[], mergeItems as bool = true, splitItems as bool = true)as bool{
    //Split Item & Merge Item cannot coexists. It turns into smart mode if they are both true.
    //Merge Item : Merge all same inputs into one huge stack.
    //Split Item : Split all items and requirements into single items, so that the test is always accurate, no matter how weird the requirement is. But it may take long time if there are many items.
    if(mergeItems&&splitItems){
        var count = 0;
        for i in requirements{
            count += i.amount;
        }
        if(count<30){
            return testShapeless(requirements,inputs,false,true);
        }
        return testShapeless(requirements,inputs,true,false);
    }
    if(mergeItems){
        var inputs2 = [] as IItemStack[]; //TODO: [LIST-ARRAY] [20240331]
        for i in inputs{
            if(inputs2.length==0) inputs2+=i;
            else {
                var flag = true;
                for t in 0 to inputs2.length{
                    var j = inputs2[t];
                    if((i*1).commandString == (j*1).commandString){
                        inputs2[t] = i * (i.amount + j.amount);
                        flag=false;
                    }
                }
                if(flag){
                    inputs2 = inputs2 + i;
                }
            }
        }
        return testShapeless(requirements,inputs2,false,false);
    }
    if(splitItems){
        var req = [] as IIngredient[]; //TODO: [LIST-ARRAY] [20240331]
        var inp = [] as IItemStack[]; //TODO: [LIST-ARRAY] [20240331]
        for r in requirements{
            for i in 0 to r.amount{
                req = req + r*1;
            }
        }
        for i in inputs{
            for j in 0 to i.amount{
                inp = inp + i*1;
            }
        }
        return testShapeless(req,inp,false,false);
    }
    //if(TEST2)for i in inputs{print(i.commandString);}
    var m = requirements.length;
    if(m!=inputs.length)return false;

    var graph as bool[][] = [] as bool[][]; //TODO: [LIST-ARRAY] [20240331]
    for i in 0 to m{
        var t as bool[] = [] as bool[];
        for j in 0 to m{
            t += (requirements[i].amount==inputs[j].amount) && (requirements[i].matches(inputs[j]));
        }
        graph += t;
    }
    
    var output = hung(graph);
    for i in output {
        if(i<0) return false;
    }
    return true;
}
if(TEST2){
    print("Test2 Hungarian Algorithm!");
    print(testShapeless([<appliedenergistics2:io_port>],[<appliedenergistics2:chest>]));
    print(testShapeless([<appliedenergistics2:chest>],[<appliedenergistics2:chest>]));
    print(testShapeless([<appliedenergistics2:io_port>,<ore:logWood>],[<appliedenergistics2:chest>,<minecraft:log>]));
    print(testShapeless([<appliedenergistics2:chest>,<ore:logWood>],[<appliedenergistics2:chest>,<minecraft:log>]));
    print("Test3 Hungarian Algorithm!");
    print(testShapeless([<ore:dye>,<ore:dyeRed>,<ore:gemLapis>],[<minecraft:dye:9>,<minecraft:dye:4>,<minecraft:dye:1>]));
    print(testShapeless([<ore:dye>*3,<ore:dyeRed>,<ore:gemLapis>],[<minecraft:dye:9>,<minecraft:dye:4>*3,<minecraft:dye:1>]));
    print(testShapeless([<ore:dye>*30,<ore:dyeRed>,<ore:gemLapis>],[<minecraft:dye:9>,<minecraft:dye:4>*30,<minecraft:dye:1>]));    //False, since did not use split items
    print(testShapeless([<ore:dye>,<ore:dyeRed>,<ore:gemLapis>*128],[<minecraft:dye:9>,<minecraft:dye:4>*64,<minecraft:dye:4>*64,<minecraft:dye:1>]));
}