module data_object;

class DataObject
{
    string name;
    string id;
    long numberOfObs;

    /***
        looking up the data by the row number
    */
    column[string] columnData;

    /***
        looking up the column name will give you the order of the column
    */
    int[string] columnOrderByName;

    string[] sortOrder;

    struct record
    {
        int rownumber;
    }

    public columnMetadata[] dataTableConfig;

    struct column
    {
        columnMetadata  columnMD;
        string[]        stringData;
        int[]           intData;
        float[]         floatData;
    }

    this()
    {

    }
}

struct columnMetadata
{
    public ulong index;
    public string columnName;
    public float average;
    public float min;
    public float max;
    public float range;
    public bool isCharacterColumn;
    public int numMissing;
    public bool isPredictor = false;

    // add in count array for character variables
    //public int[string] valueCounter;

    this(ulong index, string columnName)
    {
        average = 0.0f;
        min = 0.0f;
        max = 0.0f;
        range = 0.0f;
        isCharacterColumn = true;
        numMissing = 0;
        isPredictor = false;

        // add in count array for character variables
        // public int[string] valueCounter;


    }
}
