/*
 * Add patch records for output sections
 */

    .section patch_index

    /**********************************************************
     * .text
     */
    .dc.l   _text_offset
    .dc.l   _text
    .dc.l   _text_size


    /**********************************************************
     * .data
     */
    .dc.l   _data_offset
    .dc.l   _data_source
    .dc.l   _data_size
