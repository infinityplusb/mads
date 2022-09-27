module mads.core.data_object;

class DataObject
{
    string name;
    string id;
    long numberOfObs;

    /***
        looking up the data by the row number
    */
    int[][] data;

    /***
        looking up the column name will give you the order of the column
    */
    int[string] columnOrderByName;

    string[] sortOrder;

    struct record
    {
        int rownumber;
    }

    struct dataTableConfig
    {
        public columnMetadata[] columns;
    }

    struct columnMetadata
    {
        public int index;
        public string columnName;
        public float average;
        public float min;
        public float max;
        public float range;
        public bool isCharacterColumn;
        public int numMissing;
        public bool isPredictor = false;

        // add in count array for character variables
        public int[string] valueCounter;
    }

    this()
    {

    }
}