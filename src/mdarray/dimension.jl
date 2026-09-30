# GDALDimension

function getname(dimension::AbstractDimension)::AbstractString
    @assert !isnull(dimension)
    return GDAL.gdaldimensiongetname(dimension)
end

function getfullname(dimension::AbstractDimension)::AbstractString
    @assert !isnull(dimension)
    return GDAL.gdaldimensiongetfullname(dimension)
end

function gettype(dimension::AbstractDimension)::AbstractString
    @assert !isnull(dimension)
    return GDAL.gdaldimensiongettype(dimension)
end

function getdirection(dimension::AbstractDimension)::AbstractString
    @assert !isnull(dimension)
    return GDAL.gdaldimensiongetdirection(dimension)
end

function getsize(dimension::AbstractDimension)::Int
    @assert !isnull(dimension)
    return Int(GDAL.gdaldimensiongetsize(dimension))
end

# These return `nothing` if the dimension has no indexing variable
function unsafe_getindexingvariable(
    dimension::AbstractDimension,
)::Union{Nothing,AbstractMDArray}
    @assert !isnull(dimension)
    ptr = GDAL.gdaldimensiongetindexingvariable(dimension)
    ptr == C_NULL && return nothing
    return MDArray(ptr, dimension.dataset)
end

function getindexingvariable(
    dimension::AbstractDimension,
)::Union{Nothing,AbstractMDArray}
    @assert !isnull(dimension)
    ptr = GDAL.gdaldimensiongetindexingvariable(dimension)
    ptr == C_NULL && return nothing
    return IMDArray(ptr, dimension.dataset)
end

# Not generated in context.jl, since there may be nothing to destroy
function getindexingvariable(f::Function, dimension::AbstractDimension)
    indexingvariable = unsafe_getindexingvariable(dimension)
    try
        return f(indexingvariable)
    finally
        isnothing(indexingvariable) || destroy(indexingvariable)
    end
end

function setindexingvariable!(
    dimension::AbstractDimension,
    indexingvariable::AbstractMDArray,
)::Nothing
    @assert !isnull(dimension)
    success = GDAL.gdaldimensionsetindexingvariable(dimension, indexingvariable)
    success == 0 && error("Could not set indexing variable for dimension")
    return nothing
end

function rename!(dimension::AbstractDimension, newname::AbstractString)::Bool
    @assert !isnull(dimension)
    return GDAL.gdaldimensionrename(dimension, newname)
end
