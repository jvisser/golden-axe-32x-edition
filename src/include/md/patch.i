|--------------------------------------------------------------------
| Patch macros.
|--------------------------------------------------------------------

    |-------------------------------------------------------------------
    | Create a new patch
    |-------------------------------------------------------------------
    .macro patch_start address
        | Add a record to the patch index section
        .pushsection patch_index
            .dc.l   _patch_\address\()_offset
            .dc.l   _patch_\address\()
            .dc.l   _patch_\address\()_size
        .popsection
        | Create a new section for the patch content
        .pushsection patch_\address, "ax"
    .endm


    |-------------------------------------------------------------------
    | End the patch
    |-------------------------------------------------------------------
    .macro patch_end
        .popsection
    .endm
