module neural_network;

import std.stdio;
import std.math;
import std.conv;
import std.random;
import std.uuid;

import io;

auto rnd = Random();

class neuron
{
    UUID neuron_id;
    double weight;
    double bias;
    double in_value;
    double out_value;

    this()
    {
        this.neuron_id = UUID.init;
        this.weight = uniform(-1.0, 1.0, rnd);
        this.bias = uniform(-1.0, 1.0, rnd);
        this.in_value = 0.0;
    }
}

class layer
{
    neuron[] neurons;

    this(uint layerSize)
    {
        foreach(node; neurons)
        {
            node = new neuron();
        }
    }
}

class nnet
{
    uint[] layerSizes;
    layer[] layers;
//    neuron[][] fullNeuralNet;
    double[][] weights;
    double[][] values;
    double[] input_vals;
    double[] target_vals;
    double error;

    // double[] input_vals;
    // double[] output_vals;

    auto rnd = Random();
    ulong input_dim = 0;
    ulong output_dim = 0;

    float eta = 0.15;

    this(CSV inData, double[] targetColumn)
    {
        writeln("Neural Network created");
        double[] _weights;

        output_dim = targetColumn.length;
        this.target_vals = targetColumn;
        writeln(targetColumn);
        
        // read in the data
        // run a forward pass and get the error
        foreach(thing;inData.data) //store the input vector
        {
            input_vals ~= thing;
            _weights ~= uniform(0.0, 1.0, rnd);
        }
        this.weights ~= _weights;
    }

    /***
        * Add a layer to the network
        * @param numberOfNeurons
        Creates the neurons and assigns a random weight to each neuron
    */
    void addLayer(int numberOfNeurons)
    {
        writefln("Adding layer of size %d ...", numberOfNeurons);
        this.layerSizes ~= numberOfNeurons;
        double[] layerWeights;
        layerWeights.length = numberOfNeurons;
//        foreach(weight; layerWeights)
        for(int i = 0; i < numberOfNeurons; i++)
        {
            layerWeights[i] = uniform(0.0, 1.0, rnd);
            write(layerWeights[i], " ");
        }
        layerWeights ~= uniform(0.0, 1.0, rnd); // create a bias term
        this.weights ~= layerWeights;
        writeln();
    }

    void train(int epochs, double learningRate)
    {
        writeln("Training...");
        int _epochs = 0;
        double[] output_vals = propogateForward(input_vals);
        error = calculateError(output_vals, target_vals);
        // for each epoch run a backward pass and a forward pass

        writeln("Error: ", error);
        do
        {
            _epochs++;
            writeln("\nEpoch: ", _epochs, " out of ", epochs );
            propogateBackward(output_vals, learningRate);
            output_vals = propogateForward(input_vals);
        
            error = calculateError(output_vals, target_vals);
            writeln("Error: ", error);
        }
        while(/*error > 0.01 && */_epochs < epochs);
    }

    double[] propogateForward(ref double[] input_vals)
    {
        writeln("Propogating forward");
        double[] output_vals;

        int layer_counter = 0;
        foreach(layer; layerSizes)
        {
            // writeln("Layer Counter: ", layer_counter);
            // writeln("Layer: ", layer);
            // writeln("Input size: ", input_vals.length);
            // writeln("Weights size: ", weights[layer_counter].length);
            // writeln("Output dim: ", layerSizes[layer_counter]);
            output_vals.length = layerSizes[layer_counter];

            // foreach output node
            for(int _out = 0; _out < output_vals.length; _out++)
            {
                // writeln("_out: ", _out);
                // writeln("Inputs: ", weights[layer_counter].length);
                
                double sum = 0.0;
                // foreach weight and input node feeding into the output node
                for(int w = 0; w < weights[layer_counter].length; w++)
                {

                    // writeln("w: ", w );
                    // writeln("Weight: ", weights[layer_counter][w]);
//                    writeln("Input: ", input_vals[w]);
                    sum += weights[layer_counter][w] * input_vals[w];
//                    writeln("Sum: ", sum);
                }
                sum += weights[layer_counter][input_dim]; //account for the bias
//                writeln("Final Sum: ", sum);
                output_vals[_out] = sum; //sigmoid(sum);
//                writeln("Output: ", output_vals[_out]);
//                writeln();
            }

            input_vals = output_vals;
            layer_counter++;
        }

        // writeln("\nLast layer");
        // writeln("Input size: ", input_vals.length);
        // writeln("Output dim: ", target_vals.length);
        output_vals.length = target_vals.length;

        //perform matrix multiplication
        for(int _out = 0; _out < output_vals.length; _out++)
        {
            double sum = 0.0;
            for(int w = 0; w < input_dim; w++)
            {
                sum += input_vals[w];
            }
            output_vals[_out] = sum; //sigmoid(sum);
        }

        input_vals = output_vals;
        layer_counter++;


        return output_vals;
    }

    double[] propogateBackward(ref double[] in_vals, double learningRate)
    {
        writeln("Propogating backward");
        double[] prev_layer_grad;
        double[] errors ;
        int counter = 0;

        foreach(node; in_vals)
        {
            errors ~= node - target_vals[counter];
            // writeln("Node: ", node);
            // writeln(-(target_vals[counter] - node));
            // writeln(node*(1-node));
            counter++;
        }

        writeln(layerSizes.length);
        // // iterate through the layers backwards
        for(auto i = layerSizes.length; i > 0; i--)
        {
            writeln("Layer: ", i);
            if(i == layerSizes.length)
            {
                foreach(weight; weights[i])
                {
                    writeln("Weight: ", weight);
                    // change in weight wrt error 
                    // dErrorTotal/dWeight = dErrorTotal/dOutput * dOutput/dNet * dNet/dWeight

                    // dErrorTotal/dOutput
                    // -(target-out)
//                    in_vals[i] - target_vals[i];

                    // dOutput/dNet
                    // out(1-out)
//                    target_vals[i] * (1.0 - target_vals[i]);                    

                    // dNet/dWeight
                    // node

                }
            }
            // prepare the output layer (going backwards)
            // prev_layer_grad.length = layers[i];
            // // iterate through the nodes of the layer and calculate the new weight
            // // W(n+1)=W(n)+η[d(n)-Y(n)]X(n);
            // for(int _out = 0; _out < output_vals.size(); _out++)
            // {
            //     prev_layer_grad[_out] = learningRate * error[_out] ;
            //     // output_vals[_out] * (1.0 - output_vals[_out]);
            // }

        }

        //return computed partial derivatives to be passed to preceding layer
        return prev_layer_grad;
    }

    double sigmoid(double x)
    {
        return 1.0 / (1.0 + exp(-x));
    }

    double calculateError(ref double[] output_vals, ref double[] target_vals)
    {
        double error = 0.0;
        for(int i = 0; i < output_vals.length; i++)
        {
            error += 0.5 * (output_vals[i] - target_vals[i]) * (output_vals[i] - target_vals[i]);
        }
        return error;
    }

    unittest
    {
    }

    void test(){};
    void save(){};
    void load(){};    
}
