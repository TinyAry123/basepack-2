#ifndef SORTING_ARRAY_SIZE
    #define SORTING_ARRAY_SIZE 3 // Type uint, more than 2. 
#endif

#ifndef SORTING_TYPE
    #define SORTING_TYPE float // Set as float or int. 
#endif

void sortArray(inout SORTING_TYPE[SORTING_ARRAY_SIZE] array) {
    SORTING_TYPE temp;

    for (int i = 0; i < SORTING_ARRAY_SIZE; i++) {
        for (int j = 0; j < SORTING_ARRAY_SIZE - i - 1; j++) {
            if (array[j] > array[j + 1]) {
                temp         = array[j];
                array[j]     = array[j + 1];
                array[j + 1] = temp;
            }
        }
    }
}