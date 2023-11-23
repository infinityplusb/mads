import std.stdio;
import std.array;

import mads;

void main()
{
    auto csv1 = new CSV("data/iris.data");
    writefln("Loaded %d records.", csv1.numberOfObs);   
    
    double[] targets;

    auto File = File("/home/brian/Documents/Programming/d/viewer/data/iris.data");
    foreach(line; File.byLine())
    {
        // split the line into an array of strings
        auto fields = line.split(",");
        //writefln("%s", fields[4]);
        if(fields[4] == "Iris-setosa")
            targets ~= -1.0;
        else if(fields[4] == "Iris-versicolor")
            targets ~= 0.0;
        else if(fields[4] == "Iris-virginica")
            targets ~= 1.0;
    }

    NeuralNet nn = new NeuralNet(10000,0.1);
    nn.addLayer(4);
    nn.addLayer(3);

    nn.train(csv1, targets);
}