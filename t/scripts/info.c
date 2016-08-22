#include "traildb.h"
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <assert.h>

int main(int argc, char **argv) {
    assert(argc == 1 + 1);
    char *filepath = argv[1];

    tdb *tdb1 = tdb_init();
    tdb_error err = tdb_open(tdb1, filepath);
    assert(err == 0);
    // print the number of fields
    printf("tdb_num_fields: %" PRIx64 "\n", tdb_num_fields(tdb1));

    printf("tdb_num_events: %" PRIx64 "\n", tdb_num_events(tdb1));

    printf("tdb_num_events: %" PRIx64 "\n", tdb_num_trails(tdb1));
    
    printf("tdb_num_events: %" PRIx64 "\n", tdb_min_timestamp(tdb1));
   
    printf("tdb_num_events: %" PRIx64 "\n", tdb_max_timestamp(tdb1));
}
