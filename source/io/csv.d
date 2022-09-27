module mads.io.csv;

import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.math;
import std.datetime.stopwatch;
import core.thread : Thread;

//import core.data_object;

class CSV
{
    //DataObject data;
    int[][] data;

    this(string infile)
    {
        writeln("Test");
        this.data = load(infile);
    }

    int[][] load(string file2load)
    {
        auto records = File(file2load).byLine();
        int[][] returnme;
        int i = 0;
        foreach(thing; records)
        {
            if(i != 0)
            {
                //debug writeln(thing);
                int[] dataLine;
                foreach(j, ob; thing.chomp().split(","))
                {
                    if(j < 3)
                    {
                        // debug writeln(ob);
                        // debug writeln(to!string(ob));
                        // debug writeln(tr(to!string(ob), ".", "", "d"));
                        // debug writeln(to!int(tr(to!string(ob), ".", "", "d")));
                        dataLine ~= to!int(tr(to!string(ob), ".", "", "d"));
                    }
                }
                returnme ~= dataLine;
            }
            //writeln(dataLine);
            i++;
        }
        return returnme;
    }

    // int[][] load(string file2load)
    // {
    //     auto records = File(file2load).byLine();
    //     int[][] data;
    //     int i = 0;
    //     foreach(thing; records)
    //     {
    //         if(i != 0)
    //         {
    //             //debug writeln(thing);
    //             int[] dataLine;
    //             foreach(j, ob; thing.chomp().split(","))
    //             {
    //                 if(j < 3)
    //                 {
    //                     // debug writeln(ob);
    //                     // debug writeln(to!string(ob));
    //                     // debug writeln(tr(to!string(ob), ".", "", "d"));
    //                     // debug writeln(to!int(tr(to!string(ob), ".", "", "d")));
    //                     dataLine ~= to!int(tr(to!string(ob), ".", "", "d"));
    //                 }
    //             }
    //             data ~= dataLine;
    //         }
    //         //writeln(dataLine);
    //         i++;
    //     }
    //     return data;
    // }
}
