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
    double[] weight; // every node has an array of weights of connecting into it
    double bias;
    double in_value;
    double out_value;
    neuron[] in_neuron;
    neuron[] out_neuron;

    this()
    {
        this.neuron_id = UUID.init;
        this.bias = uniform(-1.0, 1.0, rnd);
        this.in_value = 0.0;
    }

    this(ref Layer layer, int numberOfNeurons)
    {
        foreach(node; 0 .. numberOfNeurons)
        {
            // writeln("Creating neuron");
            auto new_neuron = new neuron();
        }
    }
}

class Layer
{
    int layerNumber;
    neuron[] neurons;

    /***
        * Create a layer of neurons
        * @param layerSize
        Creates the neurons and assigns a random weight to each neuron
    */
    this(NeuralNet nnet, uint layerSize)
    {
        writeln("Creating layer of size ", layerSize);
        layerNumber = to!int(nnet.layers.length);

        foreach(node; 0 .. layerSize)
        {
            auto _neuron = new neuron();
            if(layerNumber == 0)
            {
                //writeln("First Layer. Not assigning weights");
            }
            else
            {
                foreach(prev_layer_node; nnet.layers[layerNumber-1].neurons)
                {
                    _neuron.weight ~= uniform(0.0, 1.0, rnd);
                }
            }
            neurons ~= _neuron;
        }    
    }
}

class NeuralNet
{
    /* structure */    
    int[int] layerSizes;
    Layer[] layers;

    /* training parameters */
    int epochs;
    double learningRate;

    /* node values */
    /* static */
    double[] input_vals;
    double[] target_vals;

    /* dynamic */
    // double[] input_weights;
    neuron[] output_nodes;
    //double[] output_weights;
    double error;

    this(int _numberOfEpochs, double _learningRate)
    {
        writeln("Neural Network created");
        epochs = _numberOfEpochs;
        learningRate = _learningRate;
    }

    /***
        * Add a layer to the network
        * @param numberOfNeurons
        Creates the neurons and assigns a random weight to each neuron
    */
    void addLayer(int numberOfNeurons)
    {
        // writefln("Adding layer of size %d ...", numberOfNeurons);
        layerSizes[layerSizes.sizeof] = numberOfNeurons;
        auto newLayer = new Layer(this, cast(uint)numberOfNeurons);
        layers ~= newLayer;
    }

    double sigmoid(double x)
    {
        return 1.0 / (1.0 + exp(-x));
    }

    double calculateError(ref neuron[] _output_vals, ref double[] _target_vals)
    {
        // writeln("Calculating error");
        double error = 0.0;
        for(int i = 0; i < _output_vals.length; i++)
        {
            debug(Errors)
            {
                writeln("Output: ", _output_vals[i].out_value);
                writeln("Target: ", _target_vals[i]);
            }
            error += 0.5 * pow((_output_vals[i].out_value - _target_vals[i]) * (_output_vals[i].out_value - _target_vals[i]),2);
        }
        return error;
    }

    /***
        * Train the network
        * @param inData
        * @param targetColumn
    */
    void train(CSV inData, double[] targetColumn)
    {
        writeln("Loading data...");
        foreach(counter, thing;inData.data) //store the input vector
        {
            input_vals ~= thing[0] * 0.1;
            input_vals ~= thing[3] * 0.1;
        }
        writefln("Loaded %d records", input_vals.length);

        this.target_vals = targetColumn;
//        output_nodes.length = target_vals.length;
        
        writeln(target_vals.length);

        // setup the weights for the first set of nodes
        writeln("Setting up weights for first set of nodes ...");
        foreach(node; layers[0].neurons)
        {
            foreach(inputVal; input_vals)
            {
                node.weight ~= uniform(0.0, 1.0, rnd);
            }
        }

        // setup the weights for the last set of nodes
        writeln("Setting up weights for last set of nodes ...");
        foreach(output; target_vals)
        {
            auto node = new neuron();
            // writeln(node);
            foreach(prev_layer_node; layers[layers.length-1].neurons)
            {
                node.weight ~= uniform(0.0, 1.0, rnd);
            }
            output_nodes ~= node; 
        }

        writeln("Training...");
        propogateForward();
        int _epochs = 0;

        auto _error = 0.0;
        do
        {
            _error = error;
            propogateBackward();
            propogateForward();
            if(_epochs % 100 == 0)
            {
                writefln("At epoch %s, error is %s", to!string(_epochs), to!string(error));
            }

            _epochs++;
        }
        while(error > 0.001 && _epochs < epochs && abs(error - _error) > 0.001);
        writefln("Finished after %s epochs. Final error %s", to!string(_epochs), to!string(error));
        // saveNetwork("data/nn.json");
    }

    void propogateForward()
    {
        // writefln("Error is %s", to!string(error));
        // writeln("\nPropogating forward");
        // print_weights();
        foreach(counter1, layer; layers)
        {
//            writeln("Layer: ", layer.layerNumber);
            // writeln("Neurons: ", layer.neurons.length);
            foreach(counter2, neuron; layer.neurons)
            {
//                writeln("Neuron: ", counter2);
                double sum = 0.0;
                int counter = 0;
                if(layer.layerNumber == 0)
                {
                    // int counter = 0;
                    foreach(input; input_vals)
                    {
                        // write("Input: ", input);
                        // write("\tWeight: ", neuron.weight[counter]);
                        // writeln("\tsum: ", input * neuron.weight[counter]);
                        sum += input * neuron.weight[counter];                        // TODO is this always > 1
                        counter++;
                    }
                }
                else
                {
                    foreach(prev_layer_node; layers[layer.layerNumber-1].neurons)
                    {
                        // write("Input (prev): ", prev_layer_node.out_value);
                        // writeln("\tWeight: ", neuron.weight[counter]);
                        sum += prev_layer_node.out_value * neuron.weight[counter];
                        counter++;
                    }
                }
                neuron.in_value = sum;
                debug (ForwardPropagation)
                {
                    writeln("Sum: ", sum);
                    writeln("Average: ", sum/counter);
                    writeln("Bias: ", neuron.bias);
                    writeln("Updating the values");
                    writeln(layers[counter1].layerNumber);
                    writeln(layers[counter1].neurons[counter2].out_value);
                    writeln(sigmoid(sum +  neuron.bias));
                }
                // neuron.out_value = sigmoid(sum +  neuron.bias);
                layers[counter1].neurons[counter2].out_value = sigmoid(sum +  neuron.bias); 
                debug (ForwardPropagation) writeln("After update: ", layers[counter1].neurons[counter2].out_value);
                // layers[counter1].neuron[counter2].out_value = sigmoid(sum) * neuron.bias;
                // .out_value = sigmoid(sum) * neuron.bias;
//                neuron.out_value = sum *  neuron.bias;
                // writeln("Output: ", neuron.out_value);
            }
        }

        // do the last layer
//        writeln("\nLast layer");
//        writeln(output_nodes.length);
        for(int i = 0; i< output_nodes.length; i++) // output_node; output_nodes)
        {
            double _sum = 0.0;
            foreach(counter, prev_layer_node; layers[layers.length-1].neurons)
            {
                // writeln(prev_layer_node.out_value, "\t*\t", output_nodes[i].weight[counter]);
                _sum += prev_layer_node.out_value * output_nodes[i].weight[counter];
            }
            auto sum = sigmoid(_sum + output_nodes[i].bias);
            debug(ForwardPropogation)
            {
                writeln(sum);
                writeln("i: ", i);
                writeln("Last Layer Output: ", sum);
                writeln("Target: ", target_vals[i]);
                writeln("Error: ", sum - target_vals[i]);
            }
            output_nodes[i].out_value = sum;
        }
        // writeln(output_vals);
        error = calculateError(output_nodes, target_vals);
        // print();
        // print_weights();

    }

    void propogateBackward()
    {
        // writeln("\nPropogating backward");

        // print();
        // print_weights();
        // calculate the error for the output layer
        double[] error;
        // writeln("\nTotal Error: ", error);
        double[] output_layer_updates;
        // writeln("Calculate the gradient of the first layer");
        foreach(counter, node; output_nodes)
        {
            error ~= node.out_value - target_vals[counter];
            // writeln("Calc'd Value: ", node.out_value);
            // writeln("Target Value: ", target_vals[counter]);
            auto dErrorTotal_dOutput = node.out_value - target_vals[counter];
            auto dOutput_dNet = node.out_value * (1.0 - node.out_value);
            // writeln("Total/Output: ", dErrorTotal_dOutput);
            // writeln("Output/Net: ", dOutput_dNet);

            // target_vals[i] * (1.0 - target_vals[i]);
            foreach(counter2, weight; node.weight)
            {
                // change in weight wrt error 
                // dErrorTotal/dWeight = dErrorTotal/dOutput * dOutput/dNet * dNet/dWeight

                // dErrorTotal/dOutput
                // -(target-out)
                // see above

                // dOutput/dNet
                // out(1-out)
                // see above

                // dNet/dWeight
                // node
                // TODO is this right, or should this be the output value of the previous node?
                auto dNet_dWeight = layers[layers.length-1].neurons[counter2].out_value; 
                // writeln("\nCounter2: ", counter2);
                // writeln("Total/Output: ", dErrorTotal_dOutput);
                // writeln("Output/Net: ", dOutput_dNet);
                // writeln("Net/Weight: ", dNet_dWeight);
                auto dErrorTotal_dWeight = dErrorTotal_dOutput * dOutput_dNet * dNet_dWeight;
                // writeln("Total/Weight:" , dErrorTotal_dWeight);
                // writeln("Old Weight: ", weight);
                // writeln("Calc: ", weight, " - (", learningRate, " * ", dErrorTotal_dWeight, ")");
                // output_layer_updates ~= weight - (learningRate * dErrorTotal_dWeight);
                node.weight[counter2] = weight - (learningRate * dErrorTotal_dWeight);
                // writeln("\tNew Weight: ", node.weight[counter2], "\n");

                //     double deriviate = (1 - pow(node.out_value, 2));
                //     outer_layer_error ~= deriviate * (target_vals[counter] - node.out_value);
            }
        }
        // print();
        // print_weights();

        // writeln("Errors: ", error);

        // iterate through the layers backwards
        for(auto i = layers.length; i > 0; i--)
        {
            // change in weight wrt error 

            // dErrorTotal/dWeight = dErrorTotal/dHidden * dHidden/dNet * dNet/dWeight
            // dErrorTotal/dWeight = sum_over_all_next_nodes(dNextNode_i/dHidden) * dHidden/dNet * dNet/dWeight
            // dErrorTotal/dWeight = sum_over_all_next_nodes(dNextNode_i/dNN_Input_i * dNN_Input_i/dHidden) * dHidden/dNet * dNet/dWeight

            // dNextNode_i/dNN_Input_i
            // -(target[n+1]-out[n+1])
            double sum_over_all_next_nodes = 0.0;
            double dNN_Input_i_dHidden;
            double dNextNode_i_dNN_Input_i;

            // writeln(layers.length);
            // Calculate the weights for the last hidden layer
            if(layers[i-1].layerNumber == layers.length - 1)
            {
                // writeln("Last hidden layer");
                foreach(counter, downStreamNode ; layers[i-1].neurons)
                {
                    dNN_Input_i_dHidden = downStreamNode.out_value * (1.0 - downStreamNode.out_value);
                    dNextNode_i_dNN_Input_i = downStreamNode.out_value - target_vals[counter];
                    sum_over_all_next_nodes += dNextNode_i_dNN_Input_i * dNN_Input_i_dHidden;
                    // writeln("Partial Sum: ", sum_over_all_next_nodes);
                }
            }
            // Calculate the weights for the first hidden layer
            else if(layers[i-1].layerNumber == 0)
            {
                // writeln("First hidden layer");
                foreach(counter, downStreamNode ; layers[i-1].neurons)
                {
                    // writeln("Counter: ", counter);
                    // writeln("Downstream Node: ", downStreamNode.out_value);
                    dNN_Input_i_dHidden = downStreamNode.out_value * (1.0 - downStreamNode.out_value);
                    dNextNode_i_dNN_Input_i = downStreamNode.out_value - target_vals[counter];
                    // writeln("dNN_Input_i_dHidden: ", dNN_Input_i_dHidden);
                    // writeln("dNextNode_i_dNN_Input_i: ", dNextNode_i_dNN_Input_i);
                    // writeln("Partial Sum: ", dNextNode_i_dNN_Input_i * dNN_Input_i_dHidden);
                    sum_over_all_next_nodes += dNextNode_i_dNN_Input_i * dNN_Input_i_dHidden;
                }
            }
            // Calculate the weights for the inner hidden layers
            else
            {
                // writeln("Inner hidden layer");
                foreach(counter, downStreamNode ; layers[i-1].neurons)
                {
                    // writeln("Counter: ", counter);
                    // writeln("Downstream Node: ", downStreamNode.out_value);
                    dNN_Input_i_dHidden = downStreamNode.out_value * (1.0 - downStreamNode.out_value);
                    dNextNode_i_dNN_Input_i = downStreamNode.out_value - target_vals[counter];
                    // writeln("dNN_Input_i_dHidden: ", dNN_Input_i_dHidden);
                    // writeln("dNextNode_i_dNN_Input_i: ", dNextNode_i_dNN_Input_i);

                    sum_over_all_next_nodes += dNextNode_i_dNN_Input_i * dNN_Input_i_dHidden;
                }
            }

            // writeln("Sum: ", sum_over_all_next_nodes);

            foreach(node; layers[i-1].neurons)
            {
                // dHidden/dNet
                // out(1-out)
                // writeln("Node: ", node.out_value);
                double dHidden_dNet = node.out_value * (1.0 - node.out_value);

                // dNet/dWeight
                // node
                foreach(prev_layer_counter, weight; node.weight)
                {
                    // dErrorTotal/dWeight
                    double dErrorTotal_dWeight;
                    double dNet_dWeight;
                    // if it's the first layer
                    if(layers[i-1].layerNumber == 0)
                    {
                        dNet_dWeight = input_vals[prev_layer_counter];
                    }
                    // if it's not the first layer
                    else 
                    {
                        dNet_dWeight = layers[i-2].neurons[prev_layer_counter].out_value;
                    }
                    dErrorTotal_dWeight = sum_over_all_next_nodes * dHidden_dNet * dNet_dWeight;

                    // writeln("\nOld Weight: ", weight);
                    // writeln("Other Old Weight: ", node.weight[prev_layer_counter]);
                    // writeln("sum_over_all_next_nodes: ", sum_over_all_next_nodes);
                    // writeln("dHidden_dNet: ", dHidden_dNet);
                    // writeln("dNet_dWeight: ", dNet_dWeight);
                    // writeln("dErrorTotal_dWeight: ", dErrorTotal_dWeight);
                    
                    if(layers[i-1].layerNumber == 0)
                    {
                        // write("\tChanging the Weight of Layer 0");
                        node.weight[prev_layer_counter] = weight - (learningRate * dErrorTotal_dWeight);

                    }
                    else
                    {
                        // writeln("Changing the Weight");
                        node.weight[prev_layer_counter] = weight - (learningRate * dErrorTotal_dWeight);
                    }
                    // writeln("\tNew Weight: ", weight - (learningRate * dErrorTotal_dWeight));
                }
            }
            // print();
            // print_weights();
            
            // double[] output_layer_updates;
        }

        // foreach(counter1, node; output_nodes)
        // {
        //     foreach(counter2, weight; node.weight)
        //     {
        //         auto m = (counter2 * counter1);
        //         node.weight[counter2] = output_layer_updates[counter2 * counter1];
        //         writeln("Updating weight ", counter2 % m + fmod(counter1,m), " to ", output_layer_updates[counter2 * counter1]);
        //     }
        // }

// create a formula for a=1 to 7 and b=1 to 5 with a single index


// counter1 = 0 .. 6
// counter2 = 0 .. 4

// ((counter2*10)-7)+ counter1

// 0 .. 35

// 00 01 02 03 04 05 06
// 10 11 12 13 14 15 16
// 20 21 22 23 24 25 26
// 30 31 32 33 34 35 36
// 40 41 42 43 44 45 46






        // writeln("After propogating backward");
        // print();
        // print_weights();
    }

    void print()
    {
        foreach(_layer; layers)
        {
            writeln("Layer: ", _layer.layerNumber);
            foreach(_neuron; _layer.neurons)
            {
                writeln(_neuron.out_value);
            }
        }
    }
    void print_weights()
    {
        foreach(_layer; layers)
        {
            if(_layer.layerNumber == 0) 
                continue;
            writeln("Layer: ", _layer.layerNumber);
            foreach(_neuron; _layer.neurons)
            {
                writeln(_neuron.weight);
            }
        }
    }

    void saveNetwork(string filename)
    {
        writeln("Saving network to ", filename);
        auto file = File(filename, "w");
        foreach(_layer; layers)
        {
            // writeln("Skipping Layer 0");
            // if(_layer.layerNumber == 0) 
            //     continue;
            // writeln("\nLayer: ", _layer.layerNumber);
            file.writeln("\nLayer: ", _layer.layerNumber);
            foreach(_neuron; _layer.neurons)
            {
                file.write(_neuron.weight, ", ");
            }
        }
        // writeln("\nLayer: ", layers.length);
        file.writeln("\nLayer: ", layers.length);

        foreach(_neuron; output_nodes)
        {
            file.write(_neuron.weight, ", \n");
        }        // file.writeln(to!string(this));
        file.close();
    }
}