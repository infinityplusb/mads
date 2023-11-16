import std.stdio;

import mads;

void main()
{
    auto csv1 = new CSV("/home/brian/Documents/Programming/d/viewer/data/iris.data");
//    data = csv1.data.dup;
    writefln("Loaded %d records.", csv1.numberOfObs);   

    double[] targets;
    foreach(row; csv1.data)
    {
        targets ~= row[0];
    }

    nnet nn = new nnet(csv1, targets);
    nn.addLayer(4);
//    nn.addLayer(3);

    nn.train(1000, 0.1);
}