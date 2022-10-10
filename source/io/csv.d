module mads.io.csv;

import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.math;
import std.path;
import std.datetime.stopwatch;
import core.thread : Thread;

// import mads.data.data_object;

class CSV
{
    //DataObject data;
    int[][] data;

    this(string infile, bool hasHeader)
    {
        writeln("Test");
        this.data = load(infile);//, hasHeader);
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
/*
    DataObject load(string file2load, bool hasHeader)
    {
        DataObject returnme = new DataObject();
        returnme.name = baseName(file2load);
        string[][] data;

        auto records = File(file2load).byLine();
        long recordCounter = 0;
        foreach(thing; records)
        {
            string[] dataLine;

            if(recordCounter != 0)
            {
//debug writeln(thing);

                foreach(j, ob; thing.chomp().split(","))
                {
                    // debug writeln(ob);
                    // debug writeln(to!string(ob));
                    // debug writeln(tr(to!string(ob), ".", "", "d"));
                    // debug writeln(to!int(tr(to!string(ob), ".", "", "d")));
                    dataLine ~= to!string(ob);
//                    dataLine ~= to!int(tr(to!string(ob), ".", "", "d"));
                }
                data ~= dataLine;
            }
            else // i = 0, so it's the first line 
            {
                if(hasHeader)
                {
                    foreach(j, ob; thing.chomp().split(","))
                    {
                        columnMetadata column = columnMetadata(j, to!string(ob));
                        returnme.dataTableConfig ~= column;
                    }
                }
                else
                {

                    foreach(j, ob; thing.chomp().split(","))
                    {
                        columnMetadata column = columnMetadata(j, "Column_" ~ to!string(j));
                        // column.index = j;
                        // column.name = "Column_" + to!string(j);
                        returnme.dataTableConfig ~= column;

                        dataLine ~= to!string(ob);
                    }
                }
            }
            recordCounter++;
        }
        returnme.numberOfObs = recordCounter;

        return returnme;
    }
*/
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
