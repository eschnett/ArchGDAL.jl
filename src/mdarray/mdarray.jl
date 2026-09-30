# GDALMDArray

function MDArray(ptr::GDAL.GDALMDArrayH, dataset::WeakRef)
    @assert ptr != C_NULL
    datatype = IExtendedDataType(GDAL.gdalmdarraygetdatatype(ptr))
    class = getclass(datatype)
    @assert class == GDAL.GEDTC_NUMERIC
    T = convert(DataType, getnumericdatatype(datatype))
    D = Int(GDAL.gdalmdarraygetdimensioncount(ptr))
    return MDArray{T,D}(ptr, dataset)
end

function IMDArray(ptr::GDAL.GDALMDArrayH, dataset::WeakRef)
    @assert ptr != C_NULL
    datatype = IExtendedDataType(GDAL.gdalmdarraygetdatatype(ptr))
    class = getclass(datatype)
    @assert class == GDAL.GEDTC_NUMERIC
    T = convert(DataType, getnumericdatatype(datatype))
    D = Int(GDAL.gdalmdarraygetdimensioncount(ptr))
    return IMDArray{T,D}(ptr, dataset)
end

# function iswritable(mdarray::AbstractMDArray)::Bool
#     return GDAL.gdalmdarrayiswritable(mdarray)
# end
# 
# Base.iswritable(mdarray::AbstractMDArray)::Bool = iswritable(mdarray)
# Base.isreadonly(mdarray::AbstractMDArray)::Bool = !iswritable(mdarray)

# getfilename: not available in the C API

function getstructuralinfo(
    mdarray::AbstractMDArray,
)::AbstractVector{<:AbstractString}
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraygetstructuralinfo(mdarray)
end

function getunit(mdarray::AbstractMDArray)::AbstractString
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraygetunit(mdarray)
end

function setunit!(mdarray::AbstractMDArray, unit::AbstractString)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetunit(mdarray, unit)
end

function setspatialref!(mdarray::AbstractMDArray, srs::AbstractSpatialRef)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetspatialref(mdarray, srs)
end

function unsafe_getspatialref(mdarray::AbstractMDArray)::AbstractSpatialRef
    @assert !isnull(mdarray)
    return SpatialRef(GDAL.gdalmdarraygetspatialref(mdarray))
end

function getspatialref(mdarray::AbstractMDArray)::AbstractSpatialRef
    @assert !isnull(mdarray)
    return ISpatialRef(GDAL.gdalmdarraygetspatialref(mdarray))
end

function getrawnodatavalue(mdarray::AbstractMDArray)::Ptr{Cvoid}
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraygetrawnodatavalue(mdarray)
end

function getrawnodatavalueasdouble(
    mdarray::AbstractMDArray,
)::Union{Nothing,Float64}
    @assert !isnull(mdarray)
    hasnodata = Ref{Cint}()
    nodatavalue = GDAL.gdalmdarraygetnodatavalueasdouble(mdarray, hasnodata)
    return hasnodata[] != 0 ? nodatavalue : nothing
end

function getrawnodatavalueasint64(
    mdarray::AbstractMDArray,
)::Union{Nothing,Int64}
    @assert !isnull(mdarray)
    hasnodata = Ref{Cint}()
    nodatavalue = GDAL.gdalmdarraygetnodatavalueasint64(mdarray, hasnodata)
    return hasnodata[] != 0 ? nodatavalue : nothing
end

function getrawnodatavalueasuint64(
    mdarray::AbstractMDArray,
)::Union{Nothing,UInt64}
    @assert !isnull(mdarray)
    hasnodata = Ref{Cint}()
    nodatavalue = GDAL.gdalmdarraygetnodatavalueasuint64(mdarray, hasnodata)
    return hasnodata[] != 0 ? nodatavalue : nothing
end

function getnodatavalue(::Type{Float64}, mdarray::AbstractMDArray)
    @assert !isnull(mdarray)
    return getrawnodatavalueasdouble(mdarray)
end
function getnodatavalue(::Type{Int64}, mdarray::AbstractMDArray)
    @assert !isnull(mdarray)
    return getrawnodatavalueasint64(mdarray)
end
function getnodatavalue(::Type{UInt64}, mdarray::AbstractMDArray)
    @assert !isnull(mdarray)
    return getrawnodatavalueasuint64(mdarray)
end

function setrawnodatavalue!(
    mdarray::AbstractMDArray,
    rawnodata::Ptr{Cvoid},
)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetrawnodatavalue(mdarray, rawnodata)
end

function setnodatavalue!(mdarray::AbstractMDArray, nodata::Float64)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetnodatavalueasdouble(mdarray, nodata)
end

function setnodatavalue!(mdarray::AbstractMDArray, nodata::Int64)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetnodatavalueasint64(mdarray, nodata)
end

function setnodatavalue!(mdarray::AbstractMDArray, nodata::UInt64)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetnodatavalueasuint64(mdarray, nodata)
end

function resize!(
    mdarray::AbstractMDArray{<:Any,D},
    newdimsizes::VectorLike{<:Integer},
    options::OptionList = nothing,
)::Bool where {D}
    @assert !isnull(mdarray)
    @assert length(newdimsizes) == D
    gdal_newdimsizes = UInt64[newdimsizes[d] for d in D:-1:1]
    return GDAL.gdalmdarrayresize(
        mdarray,
        gdal_newdimsizes,
        CSLConstListWrapper(options),
    )
end

function getoffset(mdarray::AbstractMDArray)::Union{Nothing,Float64}
    @assert !isnull(mdarray)
    hasoffset = Ref{Cint}()
    offset = GDAL.gdalmdarraygetoffset(mdarray, hasoffset)
    return hasoffset[] != 0 ? offset : nothing
end

function getoffsetex(
    mdarray::AbstractMDArray,
)::Union{Nothing,Tuple{Float64,Type}}
    @assert !isnull(mdarray)
    hasoffset = Ref{Cint}()
    storagetyperef = Ref{GDAL.GDALDataType}()
    offset = GDAL.gdalmdarraygetoffsetex(mdarray, hasoffset, storagetyperef)
    hasoffset[] == 0 && return nothing
    storagetype = convert(DataType, convert(GDALDataType, storagetyperef[]))
    return offset, storagetype
end

function getscale(mdarray::AbstractMDArray)::Union{Nothing,Float64}
    @assert !isnull(mdarray)
    hasscale = Ref{Cint}()
    scale = GDAL.gdalmdarraygetscale(mdarray, hasscale)
    return hasscale[] != 0 ? scale : nothing
end

function getscaleex(
    mdarray::AbstractMDArray,
)::Union{Nothing,Tuple{Float64,Type}}
    @assert !isnull(mdarray)
    hasscale = Ref{Cint}()
    storagetyperef = Ref{GDAL.GDALDataType}()
    scale = GDAL.gdalmdarraygetscaleex(mdarray, hasscale, storagetyperef)
    hasscale[] == 0 && return nothing
    storagetype = convert(DataType, convert(GDALDataType, storagetyperef[]))
    return scale, storagetype
end

function setoffset!(
    mdarray::AbstractMDArray,
    offset::Float64,
    storagetype::Union{Type,Nothing} = nothing,
)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetoffsetex(
        mdarray,
        offset,
        isnothing(storagetype) ? GDAL.GDT_Unknown :
        convert(GDAL.GDALDataType, convert(GDALDataType, storagetype)),
    )
end

function setscale!(
    mdarray::AbstractMDArray,
    scale::Float64,
    storagetype::Union{Type,Nothing} = nothing,
)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraysetscaleex(
        mdarray,
        scale,
        isnothing(storagetype) ? GDAL.GDT_Unknown :
        convert(GDAL.GDALDataType, convert(GDALDataType, storagetype)),
    )
end

function unsafe_getview(
    mdarray::AbstractMDArray,
    viewexpr::AbstractString,
)::AbstractMDArray
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetview(mdarray, viewexpr)
    ptr == C_NULL && error("Could not get view \"$viewexpr\"")
    return MDArray(ptr, mdarray.dataset)
end

"""
    getview(mdarray::AbstractMDArray, viewexpr::AbstractString)

Return a view of `mdarray` described by a GDAL view expression, e.g.
`"[1:3,...]"`.

The expression uses GDAL's syntax: indices are 0-based, ranges exclude
their end, and axes are in GDAL's order, which is the reverse of Julia's.
See `GDALMDArray::GetView` in the GDAL documentation.
"""
function getview(
    mdarray::AbstractMDArray,
    viewexpr::AbstractString,
)::AbstractMDArray
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetview(mdarray, viewexpr)
    ptr == C_NULL && error("Could not get view \"$viewexpr\"")
    return IMDArray(ptr, mdarray.dataset)
end

# Corresponds to `GDALMDArray::GetView(const std::vector<GUInt64>&)`,
# which is not available in the C API. `indices` are 1-based and in
# Julia order; they fix the trailing axes.
function _indexviewexpr(
    mdarray::AbstractMDArray{<:Any,D},
    indices::NTuple{N,Integer},
)::String where {D,N}
    @assert 1 <= N <= D
    @assert all(>=(1), indices)
    return "[" * join(reverse(indices) .- 1, ",") * "]"
end

function unsafe_getview(
    mdarray::AbstractMDArray,
    index::Integer,
    indices::Integer...,
)::AbstractMDArray
    @assert !isnull(mdarray)
    return unsafe_getview(mdarray, _indexviewexpr(mdarray, (index, indices...)))
end

"""
    getview(mdarray::AbstractMDArray, indices::Integer...)

Return a view of `mdarray` with its trailing axes fixed to `indices`.

The indices are 1-based and in Julia order. For a 3-dimensional array
`a`, `getview(a, j, k)` corresponds to `view(a, :, j, k)`, and
`getview(a, i, j, k)` to the 0-dimensional `view(a, i, j, k)`. Unlike
`view`, the result is a lazy GDAL array: it reads data only when
accessed.
"""
function getview(
    mdarray::AbstractMDArray,
    index::Integer,
    indices::Integer...,
)::AbstractMDArray
    @assert !isnull(mdarray)
    return getview(mdarray, _indexviewexpr(mdarray, (index, indices...)))
end

# Corresponds to `GDALMDArray::operator[](const std::string&)`, which
# is not available in the C API
function _fieldviewexpr(fieldname::AbstractString)::String
    return "['" * replace(fieldname, '\\' => "\\\\", '\'' => "\\\'") * "']"
end

function unsafe_getfieldview(
    mdarray::AbstractMDArray,
    fieldname::AbstractString,
)::AbstractMDArray
    @assert !isnull(mdarray)
    return unsafe_getview(mdarray, _fieldviewexpr(fieldname))
end

"""
    getfieldview(mdarray::AbstractMDArray, fieldname::AbstractString)

Return a view of the field `fieldname` of an array with a compound data
type.
"""
function getfieldview(
    mdarray::AbstractMDArray,
    fieldname::AbstractString,
)::AbstractMDArray
    @assert !isnull(mdarray)
    return getview(mdarray, _fieldviewexpr(fieldname))
end

# `perm[k]` is the (1-based, Julia order) axis of `mdarray` that becomes
# axis `k` of the result, as for `permutedims`. The default reverses
# all axes.
function unsafe_transpose(
    mdarray::AbstractMDArray{<:Any,D},
    perm::VectorLike{<:Integer} = D:-1:1,
)::AbstractMDArray where {D}
    @assert !isnull(mdarray)
    N = length(perm)
    @assert all(1 <= p <= D for p in perm)
    gdal_perm = Cint[D - perm[N-i] for i in 0:(N-1)]
    ptr = GDAL.gdalmdarraytranspose(mdarray, N, gdal_perm)
    ptr == C_NULL && error("Could not transpose mdarray")
    return MDArray(ptr, mdarray.dataset)
end

function transpose(
    mdarray::AbstractMDArray{<:Any,D},
    perm::VectorLike{<:Integer} = D:-1:1,
)::AbstractMDArray where {D}
    @assert !isnull(mdarray)
    N = length(perm)
    @assert all(1 <= p <= D for p in perm)
    gdal_perm = Cint[D - perm[N-i] for i in 0:(N-1)]
    ptr = GDAL.gdalmdarraytranspose(mdarray, N, gdal_perm)
    ptr == C_NULL && error("Could not transpose mdarray")
    return IMDArray(ptr, mdarray.dataset)
end

function unsafe_getunscaled(mdarray::AbstractMDArray)::AbstractMDArray
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetunscaled(mdarray)
    ptr == C_NULL && error("Could not get unscaled mdarray")
    return MDArray(ptr, mdarray.dataset)
end

function getunscaled(mdarray::AbstractMDArray)::AbstractMDArray
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetunscaled(mdarray)
    ptr == C_NULL && error("Could not get unscaled mdarray")
    return IMDArray(ptr, mdarray.dataset)
end

function unsafe_getmask(
    mdarray::AbstractMDArray,
    options::OptionList = nothing,
)::AbstractMDArray
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetmask(mdarray, CSLConstListWrapper(options))
    ptr == C_NULL && error("Could not get mask for mdarray")
    return MDArray(ptr, mdarray.dataset)
end

function getmask(
    mdarray::AbstractMDArray,
    options::OptionList = nothing,
)::AbstractMDArray
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetmask(mdarray, CSLConstListWrapper(options))
    ptr == C_NULL && error("Could not get mask for mdarray")
    return IMDArray(ptr, mdarray.dataset)
end

# TODO: Wrap GDAL.GDALRIOResampleAlg
function unsafe_getresampled(
    mdarray::AbstractMDArray{<:Any,D},
    newdims::Union{Nothing,VectorLike{<:AbstractDimension}},
    resamplealg::GDAL.GDALRIOResampleAlg,
    targetsrs::Union{Nothing,AbstractSpatialRef},
    options::OptionList = nothing,
)::AbstractMDArray where {D}
    @assert !isnull(mdarray)
    @assert isnothing(newdims) || length(newdims) == D
    ptr = GDAL.gdalmdarraygetresampled(
        mdarray,
        D,
        # A null dimension handle keeps the corresponding dimension
        isnothing(newdims) ? GDAL.GDALDimensionH[C_NULL for d in 1:D] :
        DimensionHList(reverse(newdims)),
        resamplealg,
        isnothing(targetsrs) ? C_NULL : targetsrs,
        CSLConstListWrapper(options),
    )
    ptr == C_NULL && error("Could not get resampled mdarray")
    return MDArray(ptr, mdarray.dataset)
end

function getresampled(
    mdarray::AbstractMDArray{<:Any,D},
    newdims::Union{Nothing,VectorLike{<:AbstractDimension}},
    resamplealg::GDAL.GDALRIOResampleAlg,
    targetsrs::Union{Nothing,AbstractSpatialRef},
    options::OptionList = nothing,
)::AbstractMDArray where {D}
    @assert !isnull(mdarray)
    @assert isnothing(newdims) || length(newdims) == D
    ptr = GDAL.gdalmdarraygetresampled(
        mdarray,
        D,
        # A null dimension handle keeps the corresponding dimension
        isnothing(newdims) ? GDAL.GDALDimensionH[C_NULL for d in 1:D] :
        DimensionHList(reverse(newdims)),
        resamplealg,
        isnothing(targetsrs) ? C_NULL : targetsrs,
        CSLConstListWrapper(options),
    )
    ptr == C_NULL && error("Could not get resampled mdarray")
    return IMDArray(ptr, mdarray.dataset)
end

function unsafe_getgridded(
    mdarray::AbstractMDArray,
    gridoptions::AbstractString,
    xarray::AbstractMDArray,
    yarray::AbstractMDArray,
    options::OptionList = nothing,
)::AbstractMDArray
    @assert !isnull(mdarray)
    @assert !isnull(xarray)
    @assert !isnull(yarray)
    ptr = GDAL.gdalmdarraygetgridded(
        mdarray,
        gridoptions,
        xarray,
        yarray,
        CSLConstListWrapper(options),
    )
    ptr == C_NULL && error("Could not get gridded mdarray")
    return MDArray(ptr, mdarray.dataset)
end

function getgridded(
    mdarray::AbstractMDArray,
    gridoptions::AbstractString,
    xarray::AbstractMDArray,
    yarray::AbstractMDArray,
    options::OptionList = nothing,
)::AbstractMDArray
    @assert !isnull(mdarray)
    @assert !isnull(xarray)
    @assert !isnull(yarray)
    ptr = GDAL.gdalmdarraygetgridded(
        mdarray,
        gridoptions,
        xarray,
        yarray,
        CSLConstListWrapper(options),
    )
    ptr == C_NULL && error("Could not get gridded mdarray")
    return IMDArray(ptr, mdarray.dataset)
end

# `xdim` and `ydim` are 1-based axes in Julia order
function unsafe_asclassicdataset(
    mdarray::AbstractMDArray{<:Any,D},
    xdim::Integer,
    ydim::Integer,
    rootgroup::Union{Nothing,AbstractGroup} = nothing,
    options::OptionList = nothing,
)::AbstractDataset where {D}
    @assert !isnull(mdarray)
    @assert 1 <= xdim <= D
    @assert 1 <= ydim <= D
    @assert isnothing(rootgroup) || !isnull(rootgroup)
    return Dataset(
        GDAL.gdalmdarrayasclassicdatasetex(
            mdarray,
            D - xdim,
            D - ydim,
            isnothing(rootgroup) ? C_NULL : rootgroup,
            CSLConstListWrapper(options),
        ),
    )
end

# `xdim` and `ydim` are 1-based axes in Julia order
function asclassicdataset(
    mdarray::AbstractMDArray{<:Any,D},
    xdim::Integer,
    ydim::Integer,
    rootgroup::Union{Nothing,AbstractGroup} = nothing,
    options::OptionList = nothing,
)::AbstractDataset where {D}
    @assert !isnull(mdarray)
    @assert 1 <= xdim <= D
    @assert 1 <= ydim <= D
    @assert isnothing(rootgroup) || !isnull(rootgroup)
    return IDataset(
        GDAL.gdalmdarrayasclassicdatasetex(
            mdarray,
            D - xdim,
            D - ydim,
            isnothing(rootgroup) ? C_NULL : rootgroup,
            CSLConstListWrapper(options),
        ),
    )
end

function unsafe_asmdarray(rasterband::AbstractRasterBand)::AbstractMDArray
    @assert !isnull(rasterband)
    ptr = GDAL.gdalrasterbandasmdarray(rasterband)
    ptr == C_NULL && error("Could not get rasterband as mdarray")
    # Classic datasets do not track their children
    return MDArray(ptr, WeakRef())
end

function asmdarray(rasterband::AbstractRasterBand)::AbstractMDArray
    @assert !isnull(rasterband)
    ptr = GDAL.gdalrasterbandasmdarray(rasterband)
    ptr == C_NULL && error("Could not get rasterband as mdarray")
    # Classic datasets do not track their children
    return IMDArray(ptr, WeakRef())
end

# TODO: Wrap GDAL.CPLErr
# TODO: Allow a progress function
function getstatistics(
    mdarray::AbstractMDArray,
    approxok::Bool,
    force::Bool,
)::Tuple{GDAL.CPLErr,Float64,Float64,Float64,Float64,Int64}
    @assert !isnull(mdarray)
    dataset = C_NULL            # apparently unused
    min = Ref{Float64}()
    max = Ref{Float64}()
    mean = Ref{Float64}()
    stddev = Ref{Float64}()
    validcount = Ref{UInt64}()
    err = GDAL.gdalmdarraygetstatistics(
        mdarray,
        dataset,
        approxok,
        force,
        min,
        max,
        mean,
        stddev,
        validcount,
        C_NULL,
        C_NULL,
    )
    return err, min[], max[], mean[], stddev[], Int64(validcount[])
end

# TODO: Allow a progress function
function computestatistics(
    mdarray::AbstractMDArray,
    approxok::Bool,
    options::OptionList = nothing,
)::Tuple{Bool,Float64,Float64,Float64,Float64,Int64}
    @assert !isnull(mdarray)
    dataset = C_NULL            # apparently unused
    min = Ref{Float64}()
    max = Ref{Float64}()
    mean = Ref{Float64}()
    stddev = Ref{Float64}()
    validcount = Ref{UInt64}()
    success = GDAL.gdalmdarraycomputestatisticsex(
        mdarray,
        dataset,
        approxok,
        min,
        max,
        mean,
        stddev,
        validcount,
        C_NULL,
        C_NULL,
        CSLConstListWrapper(options),
    )
    return Bool(success), min[], max[], mean[], stddev[], Int64(validcount[])
end

# clearstatistics: not available in the C API

function getcoordinatevariables(
    mdarray::AbstractMDArray,
)::AbstractVector{<:AbstractMDArray}
    @assert !isnull(mdarray)
    count = Ref{Csize_t}()
    coordinatevariablesptr =
        GDAL.gdalmdarraygetcoordinatevariables(mdarray, count)
    coordinatevariables = AbstractMDArray[
        IMDArray(unsafe_load(coordinatevariablesptr, n), mdarray.dataset)
        for n in 1:count[]
    ]
    GDAL.vsifree(coordinatevariablesptr)
    return coordinatevariables
end

function adviseread(
    mdarray::AbstractMDArray{<:Any,D},
    arraystartidx::Union{Nothing,IndexLike{D}},
    count::Union{Nothing,IndexLike{D}},
    options::OptionList = nothing,
)::Bool where {D}
    @assert !isnull(mdarray)
    @assert isnothing(arraystartidx) || length(arraystartidx) == D
    @assert isnothing(count) || length(count) == D
    gdal_arraystartidx =
        isnothing(arraystartidx) ? C_NULL :
        UInt64[arraystartidx[d] - 1 for d in D:-1:1]
    gdal_count = isnothing(count) ? C_NULL : Csize_t[count[d] for d in D:-1:1]
    return GDAL.gdalmdarrayadvisereadex(
        mdarray,
        gdal_arraystartidx,
        gdal_count,
        CSLConstListWrapper(options),
    )
end

# isregularlyspaced: not available in the C API

# guessgeotransform: not available in the C API

function cache(mdarray::AbstractMDArray, options::OptionList = nothing)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraycache(mdarray, CSLConstListWrapper(options))
end

# getrootgroup: not available in the C API

################################################################################

function getname(mdarray::AbstractMDArray)::AbstractString
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraygetname(mdarray)
end

function getfullname(mdarray::AbstractMDArray)::AbstractString
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraygetfullname(mdarray)
end

function gettotalelementscount(mdarray::AbstractMDArray)::Int64
    @assert !isnull(mdarray)
    return Int64(GDAL.gdalmdarraygettotalelementscount(mdarray))
end

function Base.length(mdarray::AbstractMDArray)
    @assert !isnull(mdarray)
    return Int(gettotalelementscount(mdarray))
end

# function getdimensioncount(mdarray::AbstractMDArray)::Int
#     @assert !isnull(mdarray)
#     return Int(GDAL.gdalmdarraygetdimensioncount(mdarray))
# end
getdimensioncount(mdarray::AbstractMDArray{<:Any,D}) where {D} = D

Base.ndims(mdarray::AbstractMDArray)::Int = getdimensioncount(mdarray)

function getdimensions(
    mdarray::AbstractMDArray{<:Any,D},
)::NTuple{D,T where T<:AbstractDimension} where {D}
    @assert !isnull(mdarray)
    dimensionscountref = Ref{Csize_t}()
    dimensionshptr = GDAL.gdalmdarraygetdimensions(mdarray, dimensionscountref)
    dimensions = reverse(
        ntuple(
            d ->
                IDimension(unsafe_load(dimensionshptr, d), mdarray.dataset),
            dimensionscountref[],
        ),
    )
    GDAL.vsifree(dimensionshptr)
    return dimensions
end

function unsafe_getdimensions(
    mdarray::AbstractMDArray{<:Any,D},
)::NTuple{D,T where T<:AbstractDimension} where {D}
    @assert !isnull(mdarray)
    dimensionscountref = Ref{Csize_t}()
    dimensionshptr = GDAL.gdalmdarraygetdimensions(mdarray, dimensionscountref)
    dimensions = reverse(
        ntuple(
            d -> Dimension(unsafe_load(dimensionshptr, d), mdarray.dataset),
            dimensionscountref[],
        ),
    )
    GDAL.vsifree(dimensionshptr)
    return dimensions
end

function Base.size(mdarray::AbstractMDArray{<:Any,D})::NTuple{D,Int} where {D}
    getdimensions(mdarray) do dimensions
        return ntuple(d -> getsize(dimensions[d]), D)
    end
end

function unsafe_getdatatype(mdarray::AbstractMDArray)::AbstractExtendedDataType
    @assert !isnull(mdarray)
    return ExtendedDataType(GDAL.gdalmdarraygetdatatype(mdarray))
end

function getdatatype(mdarray::AbstractMDArray)::AbstractExtendedDataType
    @assert !isnull(mdarray)
    return IExtendedDataType(GDAL.gdalmdarraygetdatatype(mdarray))
end

Base.eltype(mdarray::AbstractMDArray{T}) where {T} = T

function getblocksize(
    mdarray::AbstractMDArray{<:Any,D},
)::NTuple{D,Int} where {D}
    @assert !isnull(mdarray)
    count = Ref{Csize_t}()
    blocksizeptr = GDAL.gdalmdarraygetblocksize(mdarray, count)
    blocksize = reverse(ntuple(d -> Int(unsafe_load(blocksizeptr, d)), count[]))
    GDAL.vsifree(blocksizeptr)
    return blocksize
end

# GDAL reports a block size of 0 for arrays that are not chunked
function DiskArrays.haschunks(mdarray::AbstractMDArray)
    return all(>(0), getblocksize(mdarray)) ? DiskArrays.Chunked() :
           DiskArrays.Unchunked()
end

function DiskArrays.eachchunk(mdarray::AbstractMDArray)
    blocksize = getblocksize(mdarray)
    all(>(0), blocksize) || return DiskArrays.estimate_chunksize(mdarray)
    return DiskArrays.GridChunks(mdarray, blocksize)
end

function getprocessingchunksize(
    mdarray::AbstractMDArray,
    maxchunkmemory::Integer,
)::AbstractVector{Int}
    @assert !isnull(mdarray)
    count = Ref{Csize_t}()
    chunksizeptr =
        GDAL.gdalmdarraygetprocessingchunksize(mdarray, count, maxchunkmemory)
    chunksize = Int[unsafe_load(chunksizeptr, n) for n in count[]:-1:1]
    GDAL.vsifree(chunksizeptr)
    return chunksize
end

# processperchunk

function read!(
    mdarray::AbstractMDArray,
    arraystartidx::IndexLike{D},
    count::IndexLike{D},
    arraystep::Union{Nothing,IndexLike{D}},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    @assert !isnull(mdarray)
    @assert length(arraystartidx) == D
    @assert length(count) == D
    @assert isnothing(arraystep) ? true : length(arraystep) == D
    gdal_arraystartidx = UInt64[arraystartidx[d] - 1 for d in D:-1:1]
    gdal_count = Csize_t[count[d] for d in D:-1:1]
    gdal_arraystep =
        isnothing(arraystep) ? C_NULL : Int64[arraystep[d] for d in D:-1:1]
    gdal_bufferstride = Cptrdiff_t[stride(buffer, d) for d in D:-1:1]
    return extendeddatatypecreate(T) do bufferdatatype
        success = GDAL.gdalmdarrayread(
            mdarray,
            gdal_arraystartidx,
            gdal_count,
            gdal_arraystep,
            gdal_bufferstride,
            bufferdatatype,
            buffer,
            buffer,
            sizeof(buffer),
        )
        success == 0 && error("Could not read mdarray")
        return nothing
    end
end

function read!(
    mdarray::AbstractMDArray,
    region::RangeLike{D},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    @assert length(region) == D
    arraystartidx = first.(region)
    count = length.(region)
    arraystep = step.(region)
    return read!(mdarray, arraystartidx, count, arraystep, buffer)
end

function read!(
    mdarray::AbstractMDArray,
    indices::CartesianIndices{D},
    arraystep::Union{Nothing,IndexLike{D}},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    arraystartidx = first.(indices.indices)
    count = length.(indices.indices)
    return read!(mdarray, arraystartidx, count, arraystep, buffer)
end

function read!(
    mdarray::AbstractMDArray,
    indices::CartesianIndices{D},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    return read!(mdarray, indices, nothing, buffer)
end

function read!(
    mdarray::AbstractMDArray,
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    return read!(mdarray, axes(buffer), buffer)
end

function read(mdarray::AbstractMDArray)::AbstractArray
    getdimensions(mdarray) do dimensions
        D = length(dimensions)
        sz = [getsize(dimensions[d]) for d in 1:D]
        getdatatype(mdarray) do datatype
            class = getclass(datatype)
            @assert class == GDAL.GEDTC_NUMERIC
            T = convert(DataType, getnumericdatatype(datatype))
            buffer = Array{T}(undef, sz...)
            read!(mdarray, buffer)
            return buffer
        end
    end
end

function DiskArrays.readblock!(
    mdarray::AbstractMDArray{T,D},
    aout,
    r::Vararg{AbstractUnitRange,D},
)::Nothing where {T,D}
    if aout isa StridedArray{T,D}
        read!(mdarray, r, aout)
    else
        buffer = Array{T,D}(undef, length.(r))
        read!(mdarray, r, buffer)
        aout .= buffer
    end
    return nothing
end

function write(
    mdarray::AbstractMDArray,
    arraystartidx::IndexLike{D},
    count::IndexLike{D},
    arraystep::Union{Nothing,IndexLike{D}},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    @assert !isnull(mdarray)
    @assert length(arraystartidx) == D
    @assert length(count) == D
    @assert isnothing(arraystep) ? true : length(arraystep) == D
    gdal_arraystartidx = UInt64[arraystartidx[d] - 1 for d in D:-1:1]
    gdal_count = Csize_t[count[d] for d in D:-1:1]
    gdal_arraystep =
        isnothing(arraystep) ? C_NULL : Int64[arraystep[d] for d in D:-1:1]
    gdal_bufferstride = Cptrdiff_t[stride(buffer, d) for d in D:-1:1]
    return extendeddatatypecreate(T) do bufferdatatype
        success = GDAL.gdalmdarraywrite(
            mdarray,
            gdal_arraystartidx,
            gdal_count,
            gdal_arraystep,
            gdal_bufferstride,
            bufferdatatype,
            buffer,
            buffer,
            sizeof(buffer),
        )
        success == 0 && error("Could not write mdarray")
        return nothing
    end
end

function write(
    mdarray::AbstractMDArray,
    region::RangeLike{D},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    @assert length(region) == D
    arraystartidx = first.(region)
    count = length.(region)
    arraystep = step.(region)
    return write(mdarray, arraystartidx, count, arraystep, buffer)
end

function write(
    mdarray::AbstractMDArray,
    indices::CartesianIndices{D},
    arraystep::Union{Nothing,IndexLike{D}},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    arraystartidx = first.(indices.indices)
    count = length.(indices.indices)
    return write(mdarray, arraystartidx, count, arraystep, buffer)
end

function write(
    mdarray::AbstractMDArray,
    indices::CartesianIndices{D},
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    return write(mdarray, indices, nothing, buffer)
end

function write(
    mdarray::AbstractMDArray,
    buffer::StridedArray{T,D},
)::Nothing where {T,D}
    return write(mdarray, axes(buffer), buffer)
end

function DiskArrays.writeblock!(
    mdarray::AbstractMDArray{T,D},
    ain,
    r::Vararg{AbstractUnitRange,D},
)::Nothing where {T,D}
    buffer = ain isa StridedArray{T,D} ? ain : Array{T,D}(ain)
    write(mdarray, r, buffer)
    return nothing
end

function rename!(mdarray::AbstractMDArray, newname::AbstractString)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarrayrename(mdarray, newname)
end

################################################################################

function unsafe_getattribute(
    mdarray::AbstractMDArray,
    name::AbstractString,
)::AbstractAttribute
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetattribute(mdarray, name)
    ptr == C_NULL && error("Could not get attribute \"$name\"")
    return Attribute(ptr, mdarray.dataset)
end

function getattribute(
    mdarray::AbstractMDArray,
    name::AbstractString,
)::AbstractAttribute
    @assert !isnull(mdarray)
    ptr = GDAL.gdalmdarraygetattribute(mdarray, name)
    ptr == C_NULL && error("Could not get attribute \"$name\"")
    return IAttribute(ptr, mdarray.dataset)
end

function unsafe_getattributes(
    mdarray::AbstractMDArray,
    options::OptionList = nothing,
)::AbstractVector{<:AbstractAttribute}
    @assert !isnull(mdarray)
    count = Ref{Csize_t}()
    ptr = GDAL.gdalmdarraygetattributes(
        mdarray,
        count,
        CSLConstListWrapper(options),
    )
    attributes = AbstractAttribute[
        Attribute(unsafe_load(ptr, n), mdarray.dataset) for n in 1:count[]
    ]
    GDAL.vsifree(ptr)
    return attributes
end

function getattributes(
    mdarray::AbstractMDArray,
    options::OptionList = nothing,
)::AbstractVector{<:AbstractAttribute}
    @assert !isnull(mdarray)
    count = Ref{Csize_t}()
    ptr = GDAL.gdalmdarraygetattributes(
        mdarray,
        count,
        CSLConstListWrapper(options),
    )
    attributes = AbstractAttribute[
        IAttribute(unsafe_load(ptr, n), mdarray.dataset) for n in 1:count[]
    ]
    GDAL.vsifree(ptr)
    return attributes
end

function unsafe_createattribute(
    mdarray::AbstractMDArray,
    name::AbstractString,
    dimensions::AbstractVector{<:Integer},
    datatype::AbstractExtendedDataType,
    options::OptionList = nothing,
)::AbstractAttribute
    @assert !isnull(mdarray)
    @assert !isnull(datatype)
    ptr = GDAL.gdalmdarraycreateattribute(
        mdarray,
        name,
        length(dimensions),
        dimensions,
        datatype,
        CSLConstListWrapper(options),
    )
    ptr == C_NULL && error("Could not create attribute \"$name\"")
    return Attribute(ptr, mdarray.dataset)
end

function createattribute(
    mdarray::AbstractMDArray,
    name::AbstractString,
    dimensions::AbstractVector{<:Integer},
    datatype::AbstractExtendedDataType,
    options::OptionList = nothing,
)::AbstractAttribute
    @assert !isnull(mdarray)
    @assert !isnull(datatype)
    ptr = GDAL.gdalmdarraycreateattribute(
        mdarray,
        name,
        length(dimensions),
        dimensions,
        datatype,
        CSLConstListWrapper(options),
    )
    ptr == C_NULL && error("Could not create attribute \"$name\"")
    return IAttribute(ptr, mdarray.dataset)
end

function deleteattribute(
    mdarray::AbstractMDArray,
    name::AbstractString,
    options::OptionList = nothing,
)::Bool
    @assert !isnull(mdarray)
    return GDAL.gdalmdarraydeleteattribute(
        mdarray,
        name,
        CSLConstListWrapper(options),
    )
end
