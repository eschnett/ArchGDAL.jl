import DiskArrays: AbstractDiskArray
import Base.convert

abstract type AbstractGeometry{T} end
# needs to have a `ptr::GDAL.OGRGeometryH` attribute

abstract type AbstractPreparedGeometry{T} <: AbstractGeometry{T} end
# needs to have a `ptr::GDAL.OGRPreparedGeometryH` attribute

abstract type AbstractSpatialRef end
# needs to have a `ptr::GDAL.OGRSpatialReferenceH` attribute

abstract type AbstractDataset end
# needs to have a `ptr::GDAL.GDALDatasetH` attribute

abstract type AbstractFeature end
# needs to have a `ptr::GDAL.OGRFeatureH` attribute

abstract type AbstractFeatureDefn end
# needs to have a `ptr::GDAL.OGRFeatureDefnH` attribute

abstract type AbstractFeatureLayer end
# needs to have a `ptr::GDAL.OGRLayerH` attribute

abstract type AbstractFieldDefn end
# needs to have a `ptr::GDAL.OGRFieldDefnH` attribute

abstract type AbstractGeomFieldDefn end
# needs to have a `ptr::GDAL.OGRGeomFieldDefnH` attribute

abstract type AbstractRasterBand{T} <: AbstractDiskArray{T,2} end
# needs to have a `ptr::GDAL.GDALRasterBandH` attribute

mutable struct CoordTransform
    ptr::GDAL.OGRCoordinateTransformationH
end

mutable struct Dataset <: AbstractDataset
    ptr::GDAL.GDALDatasetH

    Dataset(ptr::GDAL.GDALDatasetH = C_NULL) = new(ptr)
end

mutable struct IDataset <: AbstractDataset
    ptr::GDAL.GDALDatasetH

    function IDataset(ptr::GDAL.GDALDatasetH = C_NULL)
        dataset = new(ptr)
        finalizer(destroy, dataset)
        return dataset
    end
end

mutable struct Driver
    ptr::GDAL.GDALDriverH
end

mutable struct Field
    ptr::GDAL.OGRField
end

mutable struct FieldDefn <: AbstractFieldDefn
    ptr::GDAL.OGRFieldDefnH
end

mutable struct IFieldDefnView <: AbstractFieldDefn
    ptr::GDAL.OGRFieldDefnH

    function IFieldDefnView(ptr::GDAL.OGRFieldDefnH = C_NULL)
        fielddefn = new(ptr)
        finalizer(destroy, fielddefn)
        return fielddefn
    end
end

mutable struct GeomFieldDefn <: AbstractGeomFieldDefn
    ptr::GDAL.OGRGeomFieldDefnH
    spatialref::AbstractSpatialRef

    function GeomFieldDefn(
        ptr::GDAL.OGRGeomFieldDefnH = C_NULL;
        spatialref::AbstractSpatialRef = SpatialRef(),
    )
        return new(ptr, spatialref)
    end
end

mutable struct IGeomFieldDefnView <: AbstractGeomFieldDefn
    ptr::GDAL.OGRGeomFieldDefnH

    function IGeomFieldDefnView(ptr::GDAL.OGRGeomFieldDefnH = C_NULL)
        geomdefn = new(ptr)
        finalizer(destroy, geomdefn)
        return geomdefn
    end
end

mutable struct RasterAttrTable
    ptr::GDAL.GDALRasterAttributeTableH
end

mutable struct StyleManager
    ptr::GDAL.OGRStyleMgrH

    StyleManager(ptr::GDAL.OGRStyleMgrH = C_NULL) = new(ptr)
end

mutable struct StyleTable
    ptr::GDAL.OGRStyleTableH

    StyleTable(ptr::GDAL.OGRStyleTableH = C_NULL) = new(ptr)
end

mutable struct StyleTool
    ptr::GDAL.OGRStyleToolH
end

mutable struct FeatureLayer <: AbstractFeatureLayer
    ptr::GDAL.OGRLayerH
    ownedby::AbstractDataset
    spatialref::AbstractSpatialRef
end

function FeatureLayer(
    ptr::GDAL.OGRLayerH = C_NULL;
    ownedby::AbstractDataset = Dataset(),
    spatialref::AbstractSpatialRef = SpatialRef(),
)
    return FeatureLayer(ptr, ownedby, spatialref)
end

mutable struct IFeatureLayer <: AbstractFeatureLayer
    ptr::GDAL.OGRLayerH
    ownedby::AbstractDataset
    spatialref::AbstractSpatialRef

    function IFeatureLayer(
        ptr::GDAL.OGRLayerH = C_NULL;
        ownedby::AbstractDataset = Dataset(),
        spatialref::AbstractSpatialRef = SpatialRef(),
    )
        layer = new(ptr, ownedby, spatialref)
        finalizer(destroy, layer)
        return layer
    end
end

mutable struct Feature <: AbstractFeature
    ptr::GDAL.OGRFeatureH
end

mutable struct IFeature <: AbstractFeature
    ptr::GDAL.OGRFeatureH

    function IFeature(ptr::GDAL.OGRFeatureH = C_NULL)
        feature = new(ptr)
        finalizer(destroy, feature)
        return feature
    end
end

mutable struct FeatureDefn <: AbstractFeatureDefn
    ptr::GDAL.OGRFeatureDefnH
end

mutable struct IFeatureDefnView <: AbstractFeatureDefn
    ptr::GDAL.OGRFeatureDefnH

    function IFeatureDefnView(ptr::GDAL.OGRFeatureDefnH = C_NULL)
        featuredefn = new(ptr)
        finalizer(destroy, featuredefn)
        return featuredefn
    end
end

"Fetch the pixel data type for this band."
pixeltype(ptr::GDAL.GDALRasterBandH)::DataType =
    convert(GDALDataType, GDAL.gdalgetrasterdatatype(ptr))

mutable struct RasterBand{T} <: AbstractRasterBand{T}
    ptr::GDAL.GDALRasterBandH
end

RasterBand(ptr::GDAL.GDALRasterBandH)::RasterBand{pixeltype(ptr)} =
    RasterBand{pixeltype(ptr)}(ptr)

mutable struct IRasterBand{T} <: AbstractRasterBand{T}
    ptr::GDAL.GDALRasterBandH
    ownedby::AbstractDataset

    function IRasterBand{T}(
        ptr::GDAL.GDALRasterBandH = C_NULL;
        ownedby::AbstractDataset = Dataset(),
    )::IRasterBand{T} where {T}
        rasterband = new(ptr, ownedby)
        finalizer(destroy, rasterband)
        return rasterband
    end
end

function IRasterBand(
    ptr::GDAL.GDALRasterBandH;
    ownedby = Dataset(),
)::IRasterBand{pixeltype(ptr)}
    return IRasterBand{pixeltype(ptr)}(ptr, ownedby = ownedby)
end

mutable struct SpatialRef <: AbstractSpatialRef
    ptr::GDAL.OGRSpatialReferenceH

    SpatialRef(ptr::GDAL.OGRSpatialReferenceH = C_NULL) = new(ptr)
end

mutable struct ISpatialRef <: AbstractSpatialRef
    ptr::GDAL.OGRSpatialReferenceH

    function ISpatialRef(ptr::GDAL.OGRSpatialReferenceH = C_NULL)
        spref = new(ptr)
        finalizer(destroy, spref)
        return spref
    end
end

function _infergeomtype(ptr::GDAL.OGRGeometryH)::OGRwkbGeometryType
    return if ptr == C_NULL
        wkbUnknown
    else
        convert(OGRwkbGeometryType, GDAL.ogr_g_getgeometrytype(ptr))
    end
end

mutable struct Geometry{OGRwkbGeometryType} <:
               AbstractGeometry{OGRwkbGeometryType}
    ptr::GDAL.OGRGeometryH
    Geometry{wkbUnknown}() = new{wkbUnknown}(C_NULL)
    Geometry{T}(ptr::GDAL.OGRGeometryH) where {T} = new{T}(ptr)
end
Geometry(ptr::GDAL.OGRGeometryH) = Geometry{_infergeomtype(ptr)}(ptr)
Geometry() = Geometry{wkbUnknown}()
_geomtype(::Geometry{T}) where {T} = T

mutable struct IGeometry{OGRwkbGeometryType} <:
               AbstractGeometry{OGRwkbGeometryType}
    ptr::GDAL.OGRGeometryH

    function IGeometry{wkbUnknown}()
        geom = new{wkbUnknown}(C_NULL)
        finalizer(destroy, geom)
        return geom
    end
    function IGeometry{T}(ptr::GDAL.OGRGeometryH) where {T}
        geom = new{T}(ptr)
        finalizer(destroy, geom)
        return geom
    end
end
IGeometry(ptr::GDAL.OGRGeometryH) = IGeometry{_infergeomtype(ptr)}(ptr)
IGeometry() = IGeometry{wkbUnknown}()
_geomtype(::IGeometry{T}) where {T} = T

mutable struct PreparedGeometry{T} <: AbstractPreparedGeometry{T}
    ptr::GDAL.OGRPreparedGeometryH
end

mutable struct IPreparedGeometry{T} <: AbstractPreparedGeometry{T}
    ptr::GDAL.OGRPreparedGeometryH

    function IPreparedGeometry{T}(ptr::GDAL.OGRPreparedGeometryH) where {T}
        geom = new{T}(ptr)
        finalizer(destroy, geom)
        return geom
    end
end

mutable struct ColorTable
    ptr::GDAL.GDALColorTableH
end

@convert(
    GDALDataType::GDAL.GDALDataType,
    GDT_Unknown::GDAL.GDT_Unknown,
    GDT_Byte::GDAL.GDT_Byte,
    GDT_Int8::GDAL.GDT_Int8,
    GDT_UInt16::GDAL.GDT_UInt16,
    GDT_Int16::GDAL.GDT_Int16,
    GDT_UInt32::GDAL.GDT_UInt32,
    GDT_Int32::GDAL.GDT_Int32,
    GDT_UInt64::GDAL.GDT_UInt64,
    GDT_Int64::GDAL.GDT_Int64,
    GDT_Float32::GDAL.GDT_Float32,
    GDT_Float64::GDAL.GDT_Float64,
    GDT_CInt16::GDAL.GDT_CInt16,
    GDT_CInt32::GDAL.GDT_CInt32,
    GDT_CFloat32::GDAL.GDT_CFloat32,
    GDT_CFloat64::GDAL.GDT_CFloat64,
    GDT_TypeCount::GDAL.GDT_TypeCount,
)

@convert(
    GDALDataType::Normed,
    GDT_Byte::N0f8,
    GDT_UInt16::N0f16,
    GDT_UInt32::N0f32,
)

@convert(
    GDALDataType::DataType,
    GDT_Unknown::Any,
    GDT_Byte::UInt8,
    GDT_Int8::Int8,
    GDT_UInt16::UInt16,
    GDT_Int16::Int16,
    GDT_UInt32::UInt32,
    GDT_Int32::Int32,
    GDT_UInt64::UInt64,
    GDT_Int64::Int64,
    GDT_Float32::Float32,
    GDT_Float64::Float64,
    GDT_CInt16::Complex{Int16},
    GDT_CInt32::Complex{Int32},
    GDT_CFloat32::ComplexF32,
    GDT_CFloat64::ComplexF64
)

@convert(
    OGRFieldType::GDAL.OGRFieldType,
    OFTInteger::GDAL.OFTInteger,
    OFTIntegerList::GDAL.OFTIntegerList,
    OFTReal::GDAL.OFTReal,
    OFTRealList::GDAL.OFTRealList,
    OFTString::GDAL.OFTString,
    OFTStringList::GDAL.OFTStringList,
    OFTWideString::GDAL.OFTWideString, # deprecated
    OFTWideStringList::GDAL.OFTWideStringList, # deprecated
    OFTBinary::GDAL.OFTBinary,
    OFTDate::GDAL.OFTDate,
    OFTTime::GDAL.OFTTime,
    OFTDateTime::GDAL.OFTDateTime,
    OFTInteger64::GDAL.OFTInteger64,
    OFTInteger64List::GDAL.OFTInteger64List,
)

@convert(
    OGRFieldType::DataType,
    OFTInteger::Bool,
    OFTInteger::UInt8,
    OFTInteger::Int8,
    OFTInteger::UInt16,
    OFTInteger::Int16,
    OFTInteger::Int32,  # default type comes last
    OFTIntegerList::Vector{Int8},
    OFTIntegerList::Vector{Int16},
    OFTIntegerList::Vector{UInt16},
    OFTIntegerList::Vector{Int32},  # default type comes last
    OFTReal::Float16,
    OFTReal::Float32,
    OFTReal::Float64,  # default type comes last
    OFTRealList::Vector{Float16},
    OFTRealList::Vector{Float32},
    OFTRealList::Vector{Float64},
    OFTString::String,
    OFTStringList::Vector{String},
    OFTBinary::Vector{UInt8},
    OFTDate::Dates.Date,
    OFTTime::Dates.Time,
    OFTDateTime::Dates.DateTime,
    OFTInteger64::UInt32,
    OFTInteger64::Int64,  # default type comes last
    OFTInteger64List::Vector{UInt32},
    OFTInteger64List::Vector{Int64},
)

function Base.convert(og::Type{OGRFieldType}, ::Type{<:Enum{T}}) where {T}
    return Base.convert(og, T)
end

@convert(
    OGRFieldSubType::GDAL.OGRFieldSubType,
    OFSTNone::GDAL.OFSTNone,
    OFSTBoolean::GDAL.OFSTBoolean,
    OFSTInt16::GDAL.OFSTInt16,
    OFSTFloat32::GDAL.OFSTFloat32,
    OFSTJSON::GDAL.OFSTJSON,
)

@convert(
    OGRFieldSubType::DataType,
    OFSTBoolean::Vector{Bool},
    OFSTBoolean::Bool,  # default type comes last
    OFSTInt16::UInt8,
    OFSTInt16::Int8,
    OFSTInt16::Vector{Int8},
    OFSTInt16::Vector{Int16},
    OFSTInt16::Int16, # default type comes last
    OFSTFloat32::Float16,
    OFSTFloat32::Vector{Float16},
    OFSTFloat32::Vector{Float32},
    OFSTFloat32::Float32, # default type comes last
    OFSTNone::UInt16,
    OFSTNone::Vector{UInt16},
    OFSTNone::Int32,
    OFSTNone::Vector{Int32},
    OFSTNone::Float64,
    OFSTNone::Vector{Float64},
    OFSTNone::String,
    OFSTNone::Vector{String},
    OFSTNone::Vector{UInt8},
    OFSTNone::Dates.Date,
    OFSTNone::Dates.Time,
    OFSTNone::Dates.DateTime,
    OFSTNone::UInt32,
    OFSTNone::Vector{UInt32},
    OFSTNone::Int64,
    OFSTNone::Vector{Int64},
    # Lacking OFSTUUID and OFSTJSON defined in GDAL ≥ v"3.3"
    OFSTNone::Nothing, # default type comes last
)

function Base.convert(og::Type{OGRFieldSubType}, ::Type{<:Enum{T}}) where {T}
    return Base.convert(og, T)
end

@convert(
    OGRJustification::GDAL.OGRJustification,
    OJUndefined::GDAL.OJUndefined,
    OJLeft::GDAL.OJLeft,
    OJRight::GDAL.OJRight,
)

@convert(
    GDALRATFieldType::GDAL.GDALRATFieldType,
    GFT_Integer::GDAL.GFT_Integer,
    GFT_Real::GDAL.GFT_Real,
    GFT_String::GDAL.GFT_String,
)

@convert(
    GDALRATFieldUsage::GDAL.GDALRATFieldUsage,
    GFU_Generic::GDAL.GFU_Generic,
    GFU_PixelCount::GDAL.GFU_PixelCount,
    GFU_Name::GDAL.GFU_Name,
    GFU_Min::GDAL.GFU_Min,
    GFU_Max::GDAL.GFU_Max,
    GFU_MinMax::GDAL.GFU_MinMax,
    GFU_Red::GDAL.GFU_Red,
    GFU_Green::GDAL.GFU_Green,
    GFU_Blue::GDAL.GFU_Blue,
    GFU_Alpha::GDAL.GFU_Alpha,
    GFU_RedMin::GDAL.GFU_RedMin,
    GFU_GreenMin::GDAL.GFU_GreenMin,
    GFU_BlueMin::GDAL.GFU_BlueMin,
    GFU_AlphaMin::GDAL.GFU_AlphaMin,
    GFU_RedMax::GDAL.GFU_RedMax,
    GFU_GreenMax::GDAL.GFU_GreenMax,
    GFU_BlueMax::GDAL.GFU_BlueMax,
    GFU_AlphaMax::GDAL.GFU_AlphaMax,
    GFU_MaxCount::GDAL.GFU_MaxCount,
)

@convert(
    GDALAccess::GDAL.GDALAccess,
    GA_ReadOnly::GDAL.GA_ReadOnly,
    GA_Update::GDAL.GA_Update,
)

@convert(
    GDALRWFlag::GDAL.GDALRWFlag,
    GF_Read::GDAL.GF_Read,
    GF_Write::GDAL.GF_Write,
)

@convert(
    GDALPaletteInterp::GDAL.GDALPaletteInterp,
    GPI_Gray::GDAL.GPI_Gray,
    GPI_RGB::GDAL.GPI_RGB,
    GPI_CMYK::GDAL.GPI_CMYK,
    GPI_HLS::GDAL.GPI_HLS,
)

@convert(
    GDALColorInterp::GDAL.GDALColorInterp,
    GCI_Undefined::GDAL.GCI_Undefined,
    GCI_GrayIndex::GDAL.GCI_GrayIndex,
    GCI_PaletteIndex::GDAL.GCI_PaletteIndex,
    GCI_RedBand::GDAL.GCI_RedBand,
    GCI_GreenBand::GDAL.GCI_GreenBand,
    GCI_BlueBand::GDAL.GCI_BlueBand,
    GCI_AlphaBand::GDAL.GCI_AlphaBand,
    GCI_HueBand::GDAL.GCI_HueBand,
    GCI_SaturationBand::GDAL.GCI_SaturationBand,
    GCI_LightnessBand::GDAL.GCI_LightnessBand,
    GCI_CyanBand::GDAL.GCI_CyanBand,
    GCI_MagentaBand::GDAL.GCI_MagentaBand,
    GCI_YellowBand::GDAL.GCI_YellowBand,
    GCI_BlackBand::GDAL.GCI_BlackBand,
    GCI_YCbCr_YBand::GDAL.GCI_YCbCr_YBand,
    GCI_YCbCr_CbBand::GDAL.GCI_YCbCr_CbBand,
    GCI_YCbCr_CrBand::GDAL.GCI_YCbCr_CrBand,
)

@convert(
    GDALAsyncStatusType::GDAL.GDALAsyncStatusType,
    GARIO_PENDING::GDAL.GARIO_PENDING,
    GARIO_UPDATE::GDAL.GARIO_UPDATE,
    GARIO_ERROR::GDAL.GARIO_ERROR,
    GARIO_COMPLETE::GDAL.GARIO_COMPLETE,
    GARIO_TypeCount::GDAL.GARIO_TypeCount,
)

@convert(
    OGRSTClassId::GDAL.OGRSTClassId,
    OGRSTCNone::GDAL.OGRSTCNone,
    OGRSTCPen::GDAL.OGRSTCPen,
    OGRSTCBrush::GDAL.OGRSTCBrush,
    OGRSTCSymbol::GDAL.OGRSTCSymbol,
    OGRSTCLabel::GDAL.OGRSTCLabel,
    OGRSTCVector::GDAL.OGRSTCVector,
)

@convert(
    OGRSTUnitId::GDAL.OGRSTUnitId,
    OGRSTUGround::GDAL.OGRSTUGround,
    OGRSTUPixel::GDAL.OGRSTUPixel,
    OGRSTUPoints::GDAL.OGRSTUPoints,
    OGRSTUMM::GDAL.OGRSTUMM,
    OGRSTUCM::GDAL.OGRSTUCM,
    OGRSTUInches::GDAL.OGRSTUInches,
)

@convert(
    OGRwkbGeometryType::GDAL.OGRwkbGeometryType,
    wkbUnknown::GDAL.wkbUnknown,
    wkbPoint::GDAL.wkbPoint,
    wkbLineString::GDAL.wkbLineString,
    wkbPolygon::GDAL.wkbPolygon,
    wkbMultiPoint::GDAL.wkbMultiPoint,
    wkbMultiLineString::GDAL.wkbMultiLineString,
    wkbMultiPolygon::GDAL.wkbMultiPolygon,
    wkbGeometryCollection::GDAL.wkbGeometryCollection,
    wkbCircularString::GDAL.wkbCircularString,
    wkbCompoundCurve::GDAL.wkbCompoundCurve,
    wkbCurvePolygon::GDAL.wkbCurvePolygon,
    wkbMultiCurve::GDAL.wkbMultiCurve,
    wkbMultiSurface::GDAL.wkbMultiSurface,
    wkbCurve::GDAL.wkbCurve,
    wkbSurface::GDAL.wkbSurface,
    wkbPolyhedralSurface::GDAL.wkbPolyhedralSurface,
    wkbTIN::GDAL.wkbTIN,
    wkbTriangle::GDAL.wkbTriangle,
    wkbNone::GDAL.wkbNone,
    wkbLinearRing::GDAL.wkbLinearRing,
    wkbCircularStringZ::GDAL.wkbCircularStringZ,
    wkbCompoundCurveZ::GDAL.wkbCompoundCurveZ,
    wkbCurvePolygonZ::GDAL.wkbCurvePolygonZ,
    wkbMultiCurveZ::GDAL.wkbMultiCurveZ,
    wkbMultiSurfaceZ::GDAL.wkbMultiSurfaceZ,
    wkbCurveZ::GDAL.wkbCurveZ,
    wkbSurfaceZ::GDAL.wkbSurfaceZ,
    wkbPolyhedralSurfaceZ::GDAL.wkbPolyhedralSurfaceZ,
    wkbTINZ::GDAL.wkbTINZ,
    wkbTriangleZ::GDAL.wkbTriangleZ,
    wkbPointM::GDAL.wkbPointM,
    wkbLineStringM::GDAL.wkbLineStringM,
    wkbPolygonM::GDAL.wkbPolygonM,
    wkbMultiPointM::GDAL.wkbMultiPointM,
    wkbMultiLineStringM::GDAL.wkbMultiLineStringM,
    wkbMultiPolygonM::GDAL.wkbMultiPolygonM,
    wkbGeometryCollectionM::GDAL.wkbGeometryCollectionM,
    wkbCircularStringM::GDAL.wkbCircularStringM,
    wkbCompoundCurveM::GDAL.wkbCompoundCurveM,
    wkbCurvePolygonM::GDAL.wkbCurvePolygonM,
    wkbMultiCurveM::GDAL.wkbMultiCurveM,
    wkbMultiSurfaceM::GDAL.wkbMultiSurfaceM,
    wkbCurveM::GDAL.wkbCurveM,
    wkbSurfaceM::GDAL.wkbSurfaceM,
    wkbPolyhedralSurfaceM::GDAL.wkbPolyhedralSurfaceM,
    wkbTINM::GDAL.wkbTINM,
    wkbTriangleM::GDAL.wkbTriangleM,
    wkbPointZM::GDAL.wkbPointZM,
    wkbLineStringZM::GDAL.wkbLineStringZM,
    wkbPolygonZM::GDAL.wkbPolygonZM,
    wkbMultiPointZM::GDAL.wkbMultiPointZM,
    wkbMultiLineStringZM::GDAL.wkbMultiLineStringZM,
    wkbMultiPolygonZM::GDAL.wkbMultiPolygonZM,
    wkbGeometryCollectionZM::GDAL.wkbGeometryCollectionZM,
    wkbCircularStringZM::GDAL.wkbCircularStringZM,
    wkbCompoundCurveZM::GDAL.wkbCompoundCurveZM,
    wkbCurvePolygonZM::GDAL.wkbCurvePolygonZM,
    wkbMultiCurveZM::GDAL.wkbMultiCurveZM,
    wkbMultiSurfaceZM::GDAL.wkbMultiSurfaceZM,
    wkbCurveZM::GDAL.wkbCurveZM,
    wkbSurfaceZM::GDAL.wkbSurfaceZM,
    wkbPolyhedralSurfaceZM::GDAL.wkbPolyhedralSurfaceZM,
    wkbTINZM::GDAL.wkbTINZM,
    wkbTriangleZM::GDAL.wkbTriangleZM,
    wkbPoint25D::GDAL.wkbPoint25D,
    wkbLineString25D::GDAL.wkbLineString25D,
    wkbPolygon25D::GDAL.wkbPolygon25D,
    wkbMultiPoint25D::GDAL.wkbMultiPoint25D,
    wkbMultiLineString25D::GDAL.wkbMultiLineString25D,
    wkbMultiPolygon25D::GDAL.wkbMultiPolygon25D,
    wkbGeometryCollection25D::GDAL.wkbGeometryCollection25D,
)

function basetype(gt::OGRwkbGeometryType)::OGRwkbGeometryType
    wkbGeomType = convert(GDAL.OGRwkbGeometryType, gt)
    wkbGeomType &= (~0x80000000) # Remove 2.5D flag.
    wkbGeomType %= 1000 # Normalize Z, M, and ZM types.
    return GDAL.OGRwkbGeometryType(wkbGeomType)
end

@convert(
    OGRwkbByteOrder::GDAL.OGRwkbByteOrder,
    wkbXDR::GDAL.wkbXDR,
    wkbNDR::GDAL.wkbNDR,
)

import Base.|

for T in (GDALOpenFlag, FieldValidation)
    eval(quote
        |(x::$T, y::UInt8)::UInt8 = UInt8(x) | y
        |(x::UInt8, y::$T)::UInt8 = x | UInt8(y)
        |(x::$T, y::$T)::UInt8 = UInt8(x) | UInt8(y)
    end)
end

"""
    typesize(dt::GDALDataType)

Get the number of bits or zero if it is not recognised.
"""
typesize(dt::GDALDataType)::Integer = GDAL.gdalgetdatatypesize(dt)

"""
    typename(dt::GDALDataType)

name (string) corresponding to GDAL data type.
"""
typename(dt::GDALDataType)::String = GDAL.gdalgetdatatypename(dt)

"""
    gettype(name::AbstractString)

Returns GDAL data type by symbolic name.
"""
gettype(name::AbstractString)::GDALDataType = GDAL.gdalgetdatatypebyname(name)

"""
    typeunion(dt1::GDALDataType, dt2::GDALDataType)

Return the smallest data type that can fully express both input data types.
"""
typeunion(dt1::GDALDataType, dt2::GDALDataType)::GDALDataType =
    GDAL.gdaldatatypeunion(dt1, dt2)

"""
    iscomplex(dtype::GDALDataType)

`true` if `dtype` is one of `GDT_{CInt16|CInt32|CFloat32|CFloat64}.`
"""
iscomplex(dtype::GDALDataType)::Bool = Bool(GDAL.gdaldatatypeiscomplex(dtype))

"""
    getname(dtype::GDALAsyncStatusType)

Get name of AsyncStatus data type.
"""
getname(dtype::GDALAsyncStatusType)::String =
    GDAL.gdalgetasyncstatustypename(dtype)

"""
    asyncstatustype(name::AbstractString)

Get AsyncStatusType by symbolic name.
"""
asyncstatustype(name::AbstractString)::GDALAsyncStatusType =
    GDAL.gdalgetasyncstatustypebyname(name)

"""
    getname(obj::GDALColorInterp)

Return name (string) corresponding to color interpretation.
"""
getname(obj::GDALColorInterp)::String = GDAL.gdalgetcolorinterpretationname(obj)

"""
    colorinterp(name::AbstractString)

Get color interpretation corresponding to the given symbolic name.
"""
colorinterp(name::AbstractString)::GDALColorInterp =
    GDAL.gdalgetcolorinterpretationbyname(name)

"""
    getname(obj::GDALPaletteInterp)

Get name of palette interpretation.
"""
getname(obj::GDALPaletteInterp)::String =
    GDAL.gdalgetpaletteinterpretationname(obj)

"""
    getname(obj::OGRFieldType)

Fetch human readable name for a field type.
"""
getname(obj::OGRFieldType)::String = GDAL.ogr_getfieldtypename(obj)

"""
    getname(obj::OGRFieldSubType)

Fetch human readable name for a field subtype.

### References
* https://gdal.org/development/rfc/rfc50_ogr_field_subtype.html
"""
getname(obj::OGRFieldSubType)::String = GDAL.ogr_getfieldsubtypename(obj)

"""
    arecompatible(dtype::OGRFieldType, subtype::OGRFieldSubType)

Return if type and subtype are compatible.

### References
* https://gdal.org/development/rfc/rfc50_ogr_field_subtype.html
"""
arecompatible(dtype::OGRFieldType, subtype::OGRFieldSubType)::Bool =
    Bool(GDAL.ogr_aretypesubtypecompatible(dtype, subtype))

# teach ccall how to get the pointer to pass to libgdal
# this way the Julia compiler will track the lifetimes for us
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractGeometry) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractSpatialRef) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractDataset) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractFeature) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractFeatureDefn) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractFeatureLayer) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractFieldDefn) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractGeomFieldDefn) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::AbstractRasterBand) = x.ptr

Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::CoordTransform) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::Driver) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::Field) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::RasterAttrTable) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::StyleManager) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::StyleTable) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::StyleTool) = x.ptr
Base.unsafe_convert(::Type{Ptr{Cvoid}}, x::ColorTable) = x.ptr
