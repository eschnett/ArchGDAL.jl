# Global functions

function unsafe_createmultidimensional(
    driver::Driver,
    name::AbstractString,
    rootgroupoptions::OptionList = nothing,
    options::OptionList = nothing,
    ;
    hard_close::Bool = true,
)::AbstractDataset
    @assert !isnull(driver)
    return Dataset(
        GDAL.gdalcreatemultidimensional(
            driver,
            name,
            CSLConstListWrapper(rootgroupoptions),
            CSLConstListWrapper(options),
        ),
        hard_close = hard_close,
    )
end

function createmultidimensional(
    driver::Driver,
    name::AbstractString,
    rootgroupoptions::OptionList = nothing,
    options::OptionList = nothing,
    ;
    hard_close::Bool = true,
)::AbstractDataset
    @assert !isnull(driver)
    return IDataset(
        GDAL.gdalcreatemultidimensional(
            driver,
            name,
            CSLConstListWrapper(rootgroupoptions),
            CSLConstListWrapper(options),
        ),
        hard_close = hard_close,
    )
end

function unsafe_open(
    filename::AbstractString,
    openflags::Integer,
    alloweddrivers::OptionList,
    openoptions::OptionList,
    siblingfiles::OptionList,
    hard_close::Union{Nothing,Bool} = nothing,
)::AbstractDataset
    if isnothing(hard_close)
        # We hard-close the dataset if it is a writable multidim dataset
        hard_close =
            (openflags & OF_MULTIDIM_RASTER != 0) &&
            (openflags & OF_UPDATE != 0)
    end
    return Dataset(
        GDAL.gdalopenex(
            filename,
            openflags,
            CSLConstListWrapper(alloweddrivers),
            CSLConstListWrapper(openoptions),
            CSLConstListWrapper(siblingfiles),
        ),
        hard_close = hard_close,
    )
end

function open(
    filename::AbstractString,
    openflags::Integer,
    alloweddrivers::OptionList,
    openoptions::OptionList,
    siblingfiles::OptionList,
    hard_close::Union{Nothing,Bool} = nothing,
)::AbstractDataset
    if isnothing(hard_close)
        # We hard-close the dataset if it is a writable multidim dataset
        hard_close =
            (openflags & OF_MULTIDIM_RASTER != 0) &&
            (openflags & OF_UPDATE != 0)
    end
    return IDataset(
        GDAL.gdalopenex(
            filename,
            openflags,
            CSLConstListWrapper(alloweddrivers),
            CSLConstListWrapper(openoptions),
            CSLConstListWrapper(siblingfiles),
        ),
        hard_close = hard_close,
    )
end

# TODO: Wrap `GDAL.CPLErr`
function flushcache!(dataset::AbstractDataset)::GDAL.CPLErr
    @assert !isnull(dataset)
    return GDAL.gdalflushcache(dataset)
end

"""
    force_close_mdarray_dataset!(dataset::AbstractDataset)

Close a multidimensional dataset, releasing all interactive objects
(groups, arrays, attributes, dimensions) that were obtained from it and
are still alive.

In GDAL's multidimensional API, these objects keep the underlying file
open, and a file being written is only complete once all of them have
been released. Interactive objects are released by the garbage
collector at an unpredictable time; this function releases them
immediately, so that the file is complete when it returns.

Afterwards, the dataset and all its interactive children are null
(`isnull` returns `true`) and must not be used any more. Scoped objects
(obtained via `unsafe_*` functions) are not tracked and must be
destroyed by the caller beforehand.

Child tracking is enabled by default for datasets returned by
`createmultidimensional`, and by `open` when both `OF_MULTIDIM_RASTER`
and `OF_UPDATE` are set. For other datasets, this function only closes
the dataset itself.
"""
function force_close_mdarray_dataset!(dataset::AbstractDataset)::Nothing
    isnull(dataset) && return nothing
    if !isnothing(dataset.children)
        for child in dataset.children
            value = child.value
            !isnothing(value) && destroy(value)
        end
        Base.empty!(dataset.children)
    end
    err = GDAL.gdalclose(dataset)
    dataset.ptr = C_NULL
    @cplerr err "Failed to close dataset"
    return nothing
end

function unsafe_getrootgroup(dataset::AbstractDataset)::AbstractGroup
    @assert !isnull(dataset)
    return Group(GDAL.gdaldatasetgetrootgroup(dataset), WeakRef(dataset))
end

function getrootgroup(dataset::AbstractDataset)::AbstractGroup
    @assert !isnull(dataset)
    return IGroup(GDAL.gdaldatasetgetrootgroup(dataset), WeakRef(dataset))
end
