module csv;

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
    double[][] data;
    int numberOfObs = 0;

    this(string infile, bool hasHeader)
    {
        writeln("Test");
        this.data = load(infile);
    }

    this(string infile)
    {
        this(infile, true);
    }

    double[][] load(string file2load)
    {
        auto records = File(file2load).byLine();
        double[][] returnme;
        int i = 0;
        foreach(thing; records)
        {
            if(i != 0)
            {
                //debug writeln(thing);
                double[] dataLine;
                foreach(j, ob; thing.chomp().split(","))
                {
                    if(j < 4)
                    {
                        dataLine ~= to!double(to!string(ob));
                    }
                }
                returnme ~= dataLine;
            }
            //writeln(dataLine);
            i++;
        }
        numberOfObs = i;
        return returnme;
    }
}